#!/bin/bash
echo ">> Start pipeline ..."
source scriptSettings.sh

DATAPATH=/home/yongbinw/prs_ukb
SUMSTATS=${DATAPATH}/sumstats/sumstats_scz_con.txt

RELEASE="release3" # holdout release1/2/3
SUBJECT_FILE="subjects_${RELEASE}.txt"

echo ">> Subject list file:"
echo $SUBJECT_FILE

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

	echo -e \
"#!/bin/bash
module load pre2019
module load plink/1.90b6.9
plink --bfile chunk_1 --merge-list ${CURRENTPATH}/file_list.txt --make-bed --out ${DATAPATH}/UKB_EUR_${RELEASE} --allow-no-sex
gzip ${DATAPATH}/UKB_EUR_${RELEASE}.bed
awk '{print \$2}' ${DATAPATH}/UKB_EUR_${RELEASE}.bim > ${DATAPATH}/UKB_EUR_${RELEASE}_snps.txt" | cat > plink_merge.sh

	sbatch -t 24:00:00 ${CURRENTPATH}/plink_merge.sh
fi

## ================ 5. compute PRS ====================
isComputePRS=1
if (($isComputePRS==1))
then
	PHENO_NAME="scz_con"	
	echo ">> Compute PRS ..."
	sbatch run_prsice.sh -d ${DATAPATH} \
		-t UKB_EUR_${RELEASE} \
		-l UKB_EUR_${RELEASE} \
		-s ${SUMSTATS} \
		-o ${DATAPATH}/PRS_UKB_EUR_${PHENO_NAME}_${RELEASE} \
		-P ${PHENO_NAME}
fi

echo ">> Pipeline finished"
exit 0

