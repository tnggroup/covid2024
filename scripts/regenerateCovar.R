#creates a new covariate file based on the old covariate file, adding new projected PC's

library(data.table)

oldCovars <- fread(file = "../data/CSSB_APR_covar_w_PC.txt", na.strings = c(".", NA, "NA", ""), encoding = "UTF-8", check.names = T,
                  fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
                  showProgress = F)


oldCovars <- oldCovars[,c("FID","IID","SEX","AGE","BMI")]

projectedPCs <- fread(file = "CSSB_Apr_LC12+_projected.sscore", na.strings = c(".", NA, "NA", ""), encoding = "UTF-8", check.names = T,
                   fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
                   showProgress = F)

projectedPCs[,c("X.FID","PHENO1","ALLELE_CT","NAMED_ALLELE_DOSAGE_SUM")]<-NULL

dim(oldCovars)
newPCScores <- merge(oldCovars,projectedPCs,by="IID",all=T)
dim(newPCScores)


fwrite(x = newPCScores, file = "new_covar_w_PC.txt", append = F,
       quote = F, sep = "\t", col.names = T, nThread = 6)
