#!/bin/bash -l
#SBATCH --output=/scratch/prj/cssb_long_covid_gwas/correct_IDs/new/Analysis/PGScalc/%j.out
#SBATCH --job-name=PGScalc
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=96000
#SBATCH --time=48:00:00


module load openjdk/11.0.20.1_1-gcc-13.2.0


java -Xmx10G -jar pgs-calc.jar apply \
--ref PGS001372,PGS001259,PGS001344,PGS001332,PGS001251,PGS001317,PGS001280,PGS001030,PGS000930,PGS001021,PGS000138,PGS000039 \
--out PGS_scores.txt chr{1..22}.dose.cases.vcf.gz\


java -Xmx10G -jar pgs-calc.jar apply \
--ref PGS001372,PGS001259,PGS001344,PGS001332,PGS001251,PGS001317,PGS001280,PGS001030,PGS000930,PGS001021,PGS000138,PGS000039 \
--out PGS_scores.txt chr{1..22}.dose.controls.vcf.gz\
