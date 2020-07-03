#!/bin/bash

## 1. download sumstats
# sh downloads.sh

## 2. edit sumstats
# python3 edit_sumstats_file.py

## 3. make subject list
SUBJ_PATH=/home/ctgukmri/dataready/grouped/2020_summer_data_release/
file=${SUBJ_PATH}/subjects_research.txt
if [ ! -f 'subjects_research.txt' ]
then	
	touch subjects_research.txt
	while read -r line;
	do
		subjectName=$(basename $line);
		echo $subjectName >> subjects_research.txt
	done < $file
fi

# hold out subjects
file=${SUBJ_PATH}/subjects_holdout.txt
if [ ! -f 'subjects_holdout.txt' ]
then	
	touch subjects_holdout.txt
	while read -r line;
	do
		subjectName=$(basename $line);
		echo $subjectName >> subjects_holdout.txt
	done < $file
fi

## genotype data




## run prs




