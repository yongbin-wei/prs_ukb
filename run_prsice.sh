#!/bin/bash
#SBATCH -t 1:00:00

source scriptSettings.sh

while getopts t:s:d:p:P:c:C:u:o:l: option
do
	case "${option}"
		in				                
		t) TARGETFILE=$OPTARG;;
		s) SUMSTATPATH=$OPTARG;;
		d) DATAPATH=$OPTARG;;
		p) PHENOFILE=$OPTARG;;
		P) PHENO_NAME=$OPTARG;;
		c) COVFILE=$OPTARG;;
		C) COV_NAME=$OPTARG;;
		o) OUTPATH=$OPTARG;;
		l) LDFILE=$OPTARG;;
	esac
done

# Make tmp folder
tmp_dir="$(mktemp -d)"
echo ">> Working directory is ${tmp_dir}"

echo ">> Copy target file to ${tmp_dir} ..."
cp ${DATAPATH}/${TARGETFILE}* $tmp_dir

if [ "${LDFILE}" != "${TARGETFILE}" ]; then
	echo ">> Copy LD file to ${tmp_dir} ..."
	cp ${DATAPATH}/${LDFILE} $tmp_dir
fi

if [ "$PHENOFILE" != "" ]; then
	echo ">> Copy PHENO file to ${tmp_dir} ..."
	cp ${DATAPATH}/${PHENOFILE} $tmp_dir
fi

# Move to tmp folder
cd $tmp_dir
if [ -f "${TARGETFILE}.bed.gz" ]; then
	echo ">> Unzip ${TARGETFILE}.bed.gz ..."
	gunzip ${TARGETFILE}.bed.gz
fi

# PRS full pvals
cat - <<EOF > ./prs_full_${PHENO_NAME}.sh
#!/bin/bash
module load 2019
module load R/3.5.1-foss-2019b
Rscript /home/ctgukbio/programs/PRSice_v2.2.12/PRSice.R --dir . \
	--prsice /home/ctgukbio/programs/PRSice_v2.2.12/PRSice_linux \
	--base ${SUMSTATPATH} \
	--target ${tmp_dir}/${TARGETFILE} \
	--ld ${tmp_dir}/${LDFILE} \
	--or \
	--stat OR \
	--out ${OUTPATH} \
	--binary-target T \
	--no-full \
	--lower 5e-8 \
	--interval 5e-5 \
	--upper 0.5 \
	--all-score \
	--no-regress
###
EOF

echo ">> Computing PRS ..."
sh ./prs_full_${PHENO_NAME}.sh

echo " >> Finished"
