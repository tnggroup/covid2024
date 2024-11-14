#Command wrappers for performing analysis steps

##Interactive job
```sh

srun -p cpu --time 4:00:00 --ntasks 1 --cpus-per-task 6 --mem 32G --pty /bin/bash
export OMP_NUM_THREADS=6 # Revise the threads - from SBayesRC wiki

```

## GLAD+ Create UKB PCs

How it was done for the GLAD+ data.

LD pruning settings:window size = 1500kb; step size (variant ct) = 150; r^2 threshold = 0.2"

```sh

/scratch/users/k2261889/plink2/plink2 --bfile UKB_unrelated_50k.LD_Pruned \
       --freq counts \
       --pca 50 allele-wts \
       --threads 11 \
       --out UKB_unrelated_50k_50pcs

/scratch/users/k2261889/plink2/plink2 --bfile /scratch/prj/bioresource/Public/GLADv3_EDGIv1_NBRv2/genotyped/GLAD_EDGI_NBR_v3_EUR_20230512_maf0.01_sample95.SNP95 \
       --read-freq UKB_unrelated_50k_pcs.acount \
       --score UKB_unrelated_50k_pcs.eigenvec.allele 2 6 header-read no-mean-imputation \
               variance-standardize \
       --score-col-nums 7-16 \
       --out GLAD_EDGI_NBR_projected_UKB_50k

```

## Fix format error
The original file generates an error in plink2
```sh
plink --bfile "../data/CSSB_Apr_LC12+" --threads 6 --freq --out "CSSB_Apr_LC12+_fix" --make-bed
```

## Create 1kG PCs
```sh

module add plink2
module add plink

#echo "6   28510120    33480577    1" > toexclude.HLA.txt
#High-ld regions (highLDregions.b38.plink) from: 10.1016/j.ajhg.2008.06.005

#extract does not seem to be working when there are duplicates (which I hoped extract would save us from)
#gunzip -c /scratch/prj/gwas_sumstats/variant_lists/hc1kgp3.b38.mix.l2.jz2024.gz | awk 'NR>1{print $1}' > toextract.QC.txt

plink2 --bfile /scratch/prj/gwas_sumstats/reference_panel/hc1kgp3.b38.plink/1kGP_high_coverage_Illumina.filtered.SNV_INDEL_SV_phased_panel.frq.CM23 --maf 0.01 --threads 6 --rm-dup force-first --exclude bed1 ../data/highLDregions.b38.plink --indep-pairwise 1500 150 0.2 --out hc1kgp3.qc --make-bed

plink2 --bfile hc1kgp3.qc --threads 6 --extract hc1kgp3.qc.prune.in --freq counts --pca allele-wts 20 vcols=chrom,ref,alt --out hc1kgp3.qc.pcs

```


#Create covariates for the dataset based on the 1kG PCs

## Score individuals

10 PC's

```sh

plink2 --bfile "CSSB_Apr_LC12+_fix" --threads 6 --read-freq hc1kgp3.qc.pcs.acount --score hc1kgp3.qc.pcs.eigenvec.allele 2 5 header-read no-mean-imputation variance-standardize --score-col-nums 6-15 --out "CSSB_Apr_LC12+_projected"

```


## Merge old covars with newly generated genetic PC-covars

Run regenerateCovar.R


## Plink GWAS

Here, I did not use the BMI covariate due to the risk of inducing genetic associations of BMI when controlling for heritable covariates.

```sh

sbatch --time 2-00:00:00 --partition cpu --job-name="gwa" --ntasks 1 --cpus-per-task 5 --mem 16G --wrap="plink --bfile 'CSSB_Apr_LC12+_fix' --ci 0.95 --covar new_covar_w_PC.txt --covar-number 1,2,4-13 --logistic beta --hide-covar --out CSSB_Apr_LC12+_fix" --output "gwa.$(date +%Y%m%d).out.txt"

#--threads 5


```

# PRS analysis

## Get resources

```sh

sbatch --time 2-00:00:00 --partition cpu --job-name="wget" --ntasks 1 --cpus-per-task 6 --mem 16G --wrap="wget -c -t 10 https://sbayes.pctgplots.cloud.edu.au/data/SBayesRC/resources/v2.0/LD/HapMap3/ukbEUR_HM3.zip --no-check-certificate --continue -O ukbEUR_HM3.zip" --output "wget.$(date +%Y%m%d).out.txt"

sbatch --time 2-00:00:00 --partition cpu --job-name="wget" --ntasks 1 --cpus-per-task 6 --mem 16G --wrap="wget -c -t 10 https://sbayes.pctgplots.cloud.edu.au/data/SBayesRC/resources/v2.0/Annotation/annot_baseline2.2.zip --no-check-certificate --continue -O annot_baseline2.2.zip" --output "wget.$(date +%Y%m%d).out.txt"


#--continue 


```

##Run PRS.R

```sh
sbatch --time 2-00:00:00 --partition cpu --job-name="PRS" --ntasks 1 --cpus-per-task 6 --mem 16G --wrap="Rscript ../scripts/PRS.R" --output "PRS.$(date +%Y%m%d).out.txt"

```





