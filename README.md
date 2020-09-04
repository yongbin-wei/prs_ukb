# prs_ukb
This project computes PRS using PRSice based on the UKB subjects

"main.sh"
-- main pipeline including all necessary steps

"edit_sumstats_file.py"
-- edit sumstats files to make them compatible to PRSices

"run_prsice.sh"
-- compute prs using PRSices

=================================================================
Notes:

-- Summary statistics of schizophrenia and bipolar were downloaded
from PGC: BIP and SCZ results from Cell Publication, 2018
https://www.med.unc.edu/pgc/download-results/scz-bip/?choice=Schizophrenia+%28SCZ%29Schizophrenia+%28SCZ%29+%2B+Bipolar+Disorder+%28BIP%29

-- Summary statistics of alzheimers disease was downloaded from 
https://ctg.cncr.nl/software/summary_statistics
Jansen et al., 2019, Nature Genetics, doi: 10.1038/s41588-018-0311-9

-- Summary statistics of MDD was downloaded from https://www.med.unc.edu/pgc/download-results/mdd/ ("PGC MDD No UKB / No 23andMe")

-- Summary statistics of ASD was downloaded from "https://www.med.unc.edu/pgc/download-results/asd/?choice=Autism+Spectrum+Disorder+%28ASD%29"ASD iPSYCH PGC GWAS 2017 (publ. 2019) 

-- Summary statistics of ADHD was downloaded from "https://www.med.unc.edu/pgc/download-results/adhd/?choice=Attention+Deficit+Hyperactivity+Disorder+%28ADHD%29" ADHD GWAS June 2017


-- Subject lists of release1/2/3 and holdout were obtained from "2020_summer_data_release"


