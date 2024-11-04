#Command wrappers for performing analysis steps

##Interactive job
```sh
srun -p cpu --time 4:00:00 --ntasks 1 --cpus-per-task 6 --mem 32G --pty /bin/bash

```

## GLAD+ Create UKB PCs

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

## Create 1kG PCs
```sh

module add plink2

echo "6   28510120    33480577    1" > toexclude.HLA.txt

#extract does not seem to be working when there are duplicates (which I hoped extract would save us from)
#gunzip -c /scratch/prj/gwas_sumstats/variant_lists/hc1kgp3.b38.mix.l2.jz2024.gz | awk 'NR>1{print $1}' > toextract.QC.txt

plink2 --bfile /scratch/prj/gwas_sumstats/reference_panel/hc1kgp3.b38.plink/1kGP_high_coverage_Illumina.filtered.SNV_INDEL_SV_phased_panel.frq.CM23 --maf 0.01 --threads 6 --rm-dup force-first --exclude bed1 toexclude.HLA.txt --indep-pairwise 500 50 0.2 --out hc1kgp3.pruned --make-bed #--extract toextract.QC.txt

plink2 --bfile hc1kgp3.pruned --threads 6 --freq counts --pca allele-wts 10 vcols=chrom,ref,alt --out hc1kgp3.pruned.pcs

```


#Create covariates for the dataset based on the 1kG PCs

```sh

plink2 --bfile "../data/CSSB_Apr_LC12+" --threads 6 --read-freq hc1kgp3.pruned.pcs.acount --score hc1kgp3.pruned.pcs.eigenvec.allele 2 5 header-read no-mean-imputation variance-standardize --score-col-nums 6-15 --out "CSSB_Apr_LC12+_projected"

```


