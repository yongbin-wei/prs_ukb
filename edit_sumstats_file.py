import os
import pandas as pd

# ------- settings --------
# filename = "daner_pgc_mdd_meta_w2_no23andMe_rmUKBB.gz"
# filename = 'AD_sumstats_Jansenetal_2019sept.txt.gz'
# filename = "BDvsCONT.sumstats.gz"
filename = "sczvscont-sumstat.gz"

pheno = 'scz_con'
stat = 'or'
# ------- settings done -------

(fn, ext) = os.path.splitext(filename)

filepath = "/home/yongbinw/prs_ukb/sumstats/"

if os.path.exists(filepath + fn):
    print('Read ' + fn + '...')
else:
    print('Gunzip ' + filepath + '...')
    cmd = 'gunzip ' + filepath + filename
    os.system(cmd)

# load data
tbl = pd.read_table(filepath + fn, sep='\t')
print(tbl.head())

if stat == 'beta':
    tbl_prs = tbl[['SNP','CHR','BP','A1','A2','BETA','P']]
else:
    tbl_prs = tbl[['SNP','CHR','BP','A1','A2','OR','P']]
print(tbl_prs.head())

# write to tmp.txt
tbl_prs.to_csv('/home/yongbinw/prs_ukb/sumstats/tmp.txt', index = False, sep = '\t')
print('Write to tmp.txt')
del tbl_prs

# change SNP names (alphabetic order)
print('Changing SNP names ...')
fid = open('/home/yongbinw/prs_ukb/sumstats/tmp.txt', 'r')
fod = open('/home/yongbinw/prs_ukb/sumstats/sumstats_' + pheno + '.txt', 'w')

tline = fid.readline()
fod.write(tline)

for ii in fid:
    tline = ii[0:-1]
    tmp = tline.split('\t')
    # sort alleles
    tmplist = [tmp[3], tmp[4]]
    tmplist.sort()
    # recombine snp id
    tmp[0] = tmp[1] + ':' + tmp[2] + ':' + tmplist[0] + '_' + tmplist[1]
    tmpline = "\t".join(tmp)
    fod.write(tmpline + '\n')

fid.close()
fod.close()

print('Finished without errors')
