import os
import pandas as pd

filename = "clozuk_pgc2.meta.sumstats.txt.gz"

(fn, ext) = os.path.splitext(filename)

if os.path.exists(fn):
    print('Read ' + fn + '...')
else:
    print('Gunzip ' + filename + '...')
    cmd = 'gunzip ' + filename
    os.system(cmd)

# load data
tbl = pd.read_table(fn)
tbl_prs = tbl[['SNP','CHR','BP','A1','A2','OR','P']]
print(tbl_prs.head())

# change SNP names (alphabetic order)
snps = tbl_prs['SNP']
snps_new = []
for ii in snps:
    tmp = ii.split(':')
    tmplist = [tmp[2], tmp[3]]
    tmplist.sort()
    tmpsnp = tmp[0] + ':' + tmp[1] + ':' + tmplist[0] + '_' + tmplist[1]
    snps_new.append(tmpsnp)

# make new dataframe
tbl_prs = tbl_prs.drop('SNP', 1)
tbl_prs.insert(0, 'SNP', snps_new, True) 
print(tbl_prs.head())

# write file
tbl_prs.to_csv('sumstats_schizophrenia.txt', index = False, sep = '\t')


