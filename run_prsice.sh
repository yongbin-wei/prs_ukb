#!/bin/bash
#SBATCH -t 24:00:00

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
		u) IS_OR=$OPTARG;;
	esac
done

# Make tmp folder
tmp_dir="$(mktemp -d)"
echo ">> Working directory is ${tmp_dir}"

echo ">> Copy target file to ${tmp_dir} ..."
rsync -P ${DATAPATH}/${TARGETFILE}* $tmp_dir

if [ "${LDFILE}" != "${TARGETFILE}" ]; then
	echo ">> Copy LD file to ${tmp_dir} ..."
	rsync -P ${DATAPATH}/${LDFILE} $tmp_dir
fi

if [ "$PHENOFILE" != "" ]; then
	echo ">> Copy PHENO file to ${tmp_dir} ..."
	rsync -P ${DATAPATH}/${PHENOFILE} $tmp_dir
fi

# Move to tmp folder
cd $tmp_dir

# Unzip .bed file
if [ -f "${TARGETFILE}.bed.gz" ]; then
	echo ">> Unzip ${TARGETFILE}.bed.gz ..."
	gunzip ${TARGETFILE}.bed.gz
fi

echo 'Current folder is: '
echo $(pwd)

# PRS full pvals
module load 2019
module load R/3.5.1-foss-2019b
if (($IS_OR==1))
then
	echo ">> Computing PRS based on Odd Ratio ..."
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
	--interval 5e-4 \
	--upper 0.5 \
	--all-score \
	--no-regress

	rm -r ${tmp_dir}
else
	echo ">> Computing PRS based on BETA ..."
	Rscript /home/ctgukbio/programs/PRSice_v2.2.12/PRSice.R --dir . \
	--prsice /home/ctgukbio/programs/PRSice_v2.2.12/PRSice_linux \
	--base ${SUMSTATPATH} \
	--target ${tmp_dir}/${TARGETFILE} \
	--ld ${tmp_dir}/${LDFILE} \
	--beta \
	--stat BETA \
	--out ${OUTPATH} \
	--binary-target F \
	--no-full \
	--lower 5e-8 \
	--interval 5e-4 \
	--upper 0.5 \
	--all-score \
	--no-regress

	rm -r ${tmp_dir}
fi

echo ">> Finished"
exit 0
