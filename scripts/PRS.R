# All PRS analyses

#devtools::install_github("https://github.com/zhilizheng/SBayesRC")

# Tidy: optional step, tidy summary data
## "log2file=TRUE" means the messages will be redirected to a log file

setting_ld_folderPath<-"../data/ld_scores/ukbEUR_HM3"        # LD reference (download from "Resources")
setting_annot<-"../data/annot_baseline2.2.zip"         # Functional annotation (download from "Resources")

setting_originalBIMFilePath<-"CSSB_Apr_LC12+_fix.bim"
setting_originalFAMFilePath<-"CSSB_Apr_LC12+_fix.fam"
setting_originalFRQFilePath<-"CSSB_Apr_LC12+_fix.frq"
setting_originalGWASFilePath<-"CSSB_Apr_LC12+_fix.assoc.logistic"
setting_refFilePath<-"../data/variant_lists/hc1kgp3.b38.eur.l2.jz2024.gz"
setting_munged_filePath<-"WTRAIT.gz"
setting_out_prefix<-"test"   # Output prefix, e.g. "./test"
setting_ma_filePath<-"test_tidy.ma" # GWAS summary in COJO format (the only input)
setting_imp_filePath<-"test_imp.ma"
setting_score_filePath<-"test_sbrc.txt"
setting_PRS_covar_filePath<-"test.score.txt"



setting_n_cas<-454
setting_n_con<-1669

#effective sample size
#https://github.com/GenomicSEM/GenomicSEM/wiki/2.1-Calculating-Sum-of-Effective-Sample-Size-and-Preparing-GWAS-Summary-Statistics
samplePrevalence <- setting_n_cas/(setting_n_cas+setting_n_con)
sampleEffectiveN <- 4*samplePrevalence*(1-samplePrevalence)*(setting_n_cas+setting_n_con)

if(!file.exists(setting_munged_filePath)){
  #merge in missing columns
  originalGWAS <- shru::readFile(setting_originalGWASFilePath,nThreads = 6)

  originalBIM <- shru::readFile(setting_originalBIMFilePath,nThreads = 6)
  originalGWAS[originalBIM,on=c(SNP="V2"), c("A2"):=i.V6]

  originalFRQ <- shru::readFile(setting_originalFRQFilePath,nThreads = 6)
  originalGWAS[originalFRQ,on=c(SNP="SNP",CHR="CHR",A1="A1",A2="A2"), c("MAF"):=i.MAF]

  originalGWAS<-originalGWAS[,.(SNP,CHR,BP,A1,A2,MAF,BETA,SE,P)]

  smout<-shru::supermunge(
    list_df = list(WTRAIT=originalGWAS),
    refFilePath = setting_refFilePath,
    traitNames = "WTRAIT",
    N = sampleEffectiveN,
    outputFormat = "cojo",
    nThreads = 6
    )

  rm(originalBIM)
  rm(originalFRQ)
  rm(originalGWAS)
}


if(!file.exists(setting_ma_filePath)){
  SBayesRC::tidy(mafile=setting_munged_filePath, LDdir=setting_ld_folderPath, output=paste0(setting_out_prefix,"_tidy.ma"), log2file=TRUE)
}

if(!file.exists(setting_imp_filePath)){
  SBayesRC::impute(mafile=setting_ma_filePath, LDdir=setting_ld_folderPath, output=paste0(setting_out_prefix,'_imp.ma'), log2file=TRUE)
}

if(!file.exists(setting_score_filePath)){
  SBayesRC::sbayesrc(mafile=setting_imp_filePath, LDdir=setting_ld_folderPath, outPrefix=paste0(setting_out_prefix,'_sbrc'), annot=setting_annot, log2file=TRUE)
}

if(!file.exists(setting_PRS_covar_filePath)){
  # Polygenic risk score
  # genoPrefix="test_chr{CHR}" # {CHR} means multiple genotype file.
  ## If just one genotype, input the full prefix genoPrefix="test"
  # genoCHR="1-22,X" ## means {CHR} expands to 1-22 and X,
  ## if just one genotype file, input genoCHR=""
  # output="test"
  SBayesRC::prs(weight=setting_score_filePath, genoPrefix='CSSB_Apr_LC12+_fix', out='test', genoCHR='')
}

originalFAM <- shru::readFile(setting_originalFAMFilePath,nThreads = 6)
toTest <- shru::readFile(setting_PRS_covar_filePath, nThreads = 6)
toTest[originalFAM,on=c(FID="V1",IID="V2"),c('SEX','PHENO') := list(i.V5,i.V6)]
toTest[,PHENO:=PHENO-1]
toTest<-as.data.frame(toTest)
#toTest$PHENO<-as.factor(toTest$PHENO)
#toTest$SEX<-as.factor(toTest$SEX)
#testing
model1 <- glm(PHENO ~ SCORE,family=binomial(link='logit'),data=toTest)
summary(model1)
model2 <- glm(PHENO ~ SCORE + SEX,family=binomial(link='logit'),data=toTest)
summary(model1)
model3 <- glm(PHENO ~ SCORE, data=toTest)
summary(model3)
cor.test(toTest$PHENO, toTest$SCORE)






