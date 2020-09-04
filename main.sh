#!/bin/bash
echo ">> Start pipeline ..."
source scriptSettings.sh

DATAPATH=/home/yongbinw/prs_ukb

PHENO_NAME="adhd_con"	
SUMSTATS=${DATAPATH}/sumstats/sumstats_${PHENO_NAME}.txt

RELEASE="all" # holdout/all
SUBJECT_FILE="subjects_${RELEASE}.txt"

echo ">> Subject list file:"
echo $SUBJECT_FILE

if [ -f ${SUMSTATS}.gz ]; then
	gunzip ${SUMSTATS}.gz
fi

## ================ 1. edit sumstats ===================
isEditSumstat=0
if (($isEditSumstat==1))
then
	echo ">> Edit sumary statistics files ..."
	python3 edit_sumstats_file.py
fi

## =============== 2. get variant/subjects exclusion list ===============
isFilterOutVariants=0
if (($isFilterOutVariants==1))
then
	echo ">> Get exclusion lists ..."
	sbatch filterOutVariants.sh
	filterOutSubjects.sh
fi

## ================= 3. extract genotype data ==================
isExtractData=0 # 0 skip, 1 test, 2 full
GENOME_FOLDER=genotype_data
echo -e \
"runPlinkOnChunk.R
keep:=${SUBJECT_FILE}
remove:=defaultSubjectExclusions.txt
exclude:=defaultVariantExclusions.txt
make-bed:=
memory:=4000
maf:=0.005" | cat > ${GENOME_FOLDER}.txt

if (($isExtractData==1))
then
	echo ">> Extract Genotype data (test) ..."
	startPlinkChunkAnalysis.sh -f ${GENOME_FOLDER}.txt -w 2:00:00 -t test
elif (($isExtractData==2))
then
	echo ">> Extract Genotype data (all) ..."
	startPlinkChunkAnalysis.sh -f ${GENOME_FOLDER}.txt -w 24:00:00 -t imputed
fi

## =============== 4. merge genotype data =================
isMergeGeno=0
if (($isMergeGeno==1))
then
	echo ">> Merge chunks ..."
	cd ${GENOME_FOLDER}/results_imputed_EUR/
	CURRENTPATH=$(pwd)
	touch file_list.txt
	for ii in $(ls -a chunk_*.bim)
	do
        	echo "${ii%.*}" >> file_list.txt
	done

	tmp_dir="$(mktemp -d)"
	rm -r $tmp_dir

	echo -e \
"#!/bin/bash
#SBATCH -t 24:00:00
module load pre2019
module load plink/1.90b6.9

# Make tmp folder
echo 'tmp directory is: $tmp_dir'
mkdir $tmp_dir

echo '>> Start merge ...'
plink --bfile chunk_1 --merge-list ${CURRENTPATH}/file_list.txt --make-bed --out ${tmp_dir}/UKB_EUR_${RELEASE} --allow-no-sex

echo '>> Gzip .bed ...'
gzip  ${tmp_dir}/UKB_EUR_${RELEASE}.bed

echo '>> Copy to local ...'
rsync -P ${tmp_dir}/UKB_EUR_* ${DATAPATH}

echo '>> Delete tmp_dir ...'
rm -r ${tmp_dir}

echo '>> Finishing ...'
awk '{print \$2}' ${DATAPATH}/UKB_EUR_${RELEASE}.bim > ${DATAPATH}/UKB_EUR_${RELEASE}_snps.txt" | cat > plink_merge.sh

	sbatch ${CURRENTPATH}/plink_merge.sh
fi

## ================ 5. compute PRS ====================
isComputePRS=1
isOR=1 # 1. Odd Ratio, 0. Beta
if (($isComputePRS==1))
then
	echo ">> Compute PRS ..."
	sbatch run_prsice.sh -d ${DATAPATH} \
		-t UKB_EUR_${RELEASE} \
		-l UKB_EUR_${RELEASE} \
		-s ${SUMSTATS} \
		-o ${DATAPATH}/PRS_UKB_EUR_${PHENO_NAME}_${RELEASE} \
		-P ${PHENO_NAME} \
		-u ${isOR}
fi

echo ">> Pipeline finished"
exit 0

