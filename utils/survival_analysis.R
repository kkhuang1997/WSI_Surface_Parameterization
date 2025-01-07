library(knitr)
library(dplyr)
library(survival)
library(survminer)
library(ggplot2)
library(tibble)
library(lubridate)
library(ggsurvfit)
library(gtsummary)
library(tidycmprsk)
library(dplyr)
library(readxl)
library(readr) 

## laod and clean data
TCGA_CDR <- read_excel("/Liu_TCGA-CDR.xlsx", sheet = "TCGA-CDR")
merged_clinical_molecular_public_tcga <- read_csv("/merged_clinical_molecular_public_tcga.csv")
merged_clinical_molecular_public_tcga <- merged_clinical_molecular_public_tcga[, -1]

TCGA_CDR_df <- TCGA_CDR[, c('bcr_patient_barcode', 'OS', 'OS.time', 'DSS', 'DSS.time',
                            'DFI', 'DFI.time', 'PFI', 'PFI.time')]

survival_df <- merged_clinical_molecular_public_tcga %>%
  left_join(., TCGA_CDR_df, c('sample'='bcr_patient_barcode'))

## remove unclassified ans NA CMS samples (573 -> 512)
survival_df <- survival_df[!(survival_df[, 'cms_label'] == 'NOLBL'), ]
survival_df <- survival_df[!is.na(survival_df[, 'cms_label']), ]
## remove patients less than 1 month follow-up (512 -> 489)
survival_df <- survival_df[!(survival_df[, 'OS.time'] < 30), ]
## convert some var to category
survival_df <- as.data.frame(survival_df)
cate_var <- c('cms_label', 'gender', 'stage', 'msi', 'cimp', 'kras_mut', 'braf_mut','morphology')
for(i in cate_var) {
  survival_df[, i] <- factor(survival_df[, i])
}


## univariate Cox proportional hazards analyses (cms_labelCMS vs. other)
## OS
cms_fit <- coxph(Surv(OS.time, OS) ~ cms_label, data = survival_df, 
                 subset = cms_label %in% c('CMS3', 'CMS4'))
summary(cms_fit)
p1 <- ggsurvplot(survfit(Surv(OS.time, OS) ~ cms_label, data = survival_df),
           conf.int=F, pval=T, risk.table=TRUE,
           palette=c("#E99E33", "#0370A6", '#D079A4', '#029B75'))
p1$plot <- p1$plot + labs(
  title = "Overall survival",
)
p1
# p1$plot + annotate(geom = "text", x = 500, y = 0.1, label = 'some annotation')

## DSS
cms_fit <- coxph(Surv(DSS.time, DSS) ~ cms_label, data = survival_df,
                 subset = cms_label %in% c('CMS3', 'CMS4'))
summary(cms_fit)
p2 <- ggsurvplot(survfit(Surv(DSS.time, DSS) ~ cms_label, data = survival_df),
                 conf.int=F, pval=T, risk.table=TRUE,
                 palette=c("#E99E33", "#0370A6", '#D079A4', '#029B75'))
p2$plot <- p2$plot + labs(
  title = "Disease-specific survival",
)
p2

## DFI
cms_fit <- coxph(Surv(DFI.time, DFI) ~ cms_label, data = survival_df, 
                 subset = cms_label %in% c('CMS3', 'CMS4'))
summary(cms_fit)
p3 <- ggsurvplot(survfit(Surv(DFI.time, DFI) ~ cms_label, data = survival_df),
                 conf.int=F, pval=T, risk.table=TRUE,
                 palette=c("#E99E33", "#0370A6", '#D079A4', '#029B75'))
p3$plot <- p3$plot + labs(
  title = "Disease-free interval",
)
p3

## PFI
cms_fit <- coxph(Surv(PFI.time, PFI) ~ cms_label, data = survival_df, 
                 subset = cms_label %in% c('CMS3', 'CMS4'))
summary(cms_fit)
p4 <- ggsurvplot(survfit(Surv(PFI.time, PFI) ~ cms_label, data = survival_df),
                 conf.int=F, pval=T, risk.table=TRUE,
                 palette=c("#E99E33", "#0370A6", '#D079A4', '#029B75'))
p4$plot <- p4$plot + labs(
  title = "Progression-free interval",
)
p4

## combine all plots
splots <- list(p1, p2, p3, p4)
arrange_ggsurvplots(splots, print = F,  
                    ncol = 3, nrow = 2, 
                    surv.plot.height = 2,
                    risk.table.height = 0.3) %>%
  ggsave(device="pdf", filename="/Univariate surivival analysis.pdf", width = 16, height = 12, units = "in")


## multivariate Cox proportional hazards analyses
## OS
cms_fit <- coxph(Surv(OS.time, OS) ~ cms_label + age + gender + stage + msi + cimp + 
                   kras_mut + braf_mut, data = survival_df)
summary(cms_fit)

## DSS
cms_fit <- coxph(Surv(DSS.time, DSS) ~ cms_label + age + gender + stage + msi + cimp + 
                   kras_mut + braf_mut, data = survival_df)
summary(cms_fit)

## DFI
cms_fit <- coxph(Surv(DFI.time, DFI) ~ cms_label + age + gender + stage + msi + cimp + 
                   kras_mut + braf_mut, data = survival_df)
summary(cms_fit)

## PFI
cms_fit <- coxph(Surv(PFI.time, PFI) ~ cms_label + age + gender + stage + msi + cimp + 
                   kras_mut + braf_mut, data = survival_df)
summary(cms_fit)


## using data from Nat Med 21, 1350–1356 (2015)
survival_df <- read_delim("/clinical_molecular_public_all.txt", delim = "\t", escape_double = FALSE, trim_ws = TRUE)
## remove unclassified ans NA CMS samples (2207 -> 1975)
survival_df <- survival_df[!(survival_df[, 'cms_label'] == 'NOLBL'), ]
survival_df <- survival_df[!is.na(survival_df[, 'cms_label']), ]
## remove patients less than 1 month follow-up (1975 -> 1793)
survival_df <- survival_df[!(survival_df[, 'osMo'] < 1), ]
## remove useless samples (1793 -> 845)
survival_df <- survival_df[!is.na(survival_df[, 'sample']), ]

## univariate Cox proportional hazards analyses (cms_labelCMS vs. other)
## OS
cms_fit <- coxph(Surv(osMo, osStat) ~ cms_label, data = survival_df, 
                 subset = cms_label %in% c('CMS4', 'CMS3'))
summary(cms_fit)
p5 <- ggsurvplot(survfit(Surv(osMo, osStat) ~ cms_label, data = survival_df),
                 conf.int=F, pval=T, risk.table=TRUE,
                 palette=c("#E99E33", "#0370A6", '#D079A4', '#029B75'))
p5$plot <- p5$plot + labs(
  title = "Overall survival",
)
p5

## RFS
cms_fit <- coxph(Surv(rfsMo, rfsStat) ~ cms_label, data = survival_df, 
                 subset = cms_label %in% c('CMS4', 'CMS3'))
summary(cms_fit)
p6 <- ggsurvplot(survfit(Surv(rfsMo, rfsStat) ~ cms_label, data = survival_df),
                 conf.int=F, pval=T, risk.table=TRUE,
                 palette=c("#E99E33", "#0370A6", '#D079A4', '#029B75'))
p6$plot <- p6$plot + labs(
  title = "Relapse-free survival",
)
p6
## combine 2 plots
splots <- list(p5, p6)
arrange_ggsurvplots(splots, print = F,  
                    ncol = 2, nrow = 1, 
                    surv.plot.height = 2,
                    risk.table.height = 0.3) %>%
  ggsave(device="pdf", filename="/Univariate surivival analysis for cms_2015.pdf", width = 16, height = 8, units = "in")


## assess cms_label contributions to the performance of survival models using data 
## from Nat Med 21, 1350–1356 (2015)
library(survAUC)
TR <- survival_df[1:600,]  # 2/3 for training
TE <- survival_df[601:845,]  # 1/3 for testing
## with cms_label
train.fit  <- survival::coxph(survival::Surv(osMo, osStat) ~ age + gender + stage + msi + cimp + 
                                kras_mut + braf_mut, 
                              x=TRUE, y=TRUE, method="breslow", data=TR)
lp <- predict(train.fit)
lpnew <- predict(train.fit, newdata=TE)
Surv.rsp <- survival::Surv(TR$osMo, TR$osStat)
Surv.rsp.new <- survival::Surv(TE$osMo, TE$osStat)
times <- seq(1, 72, 12)    
# tAUC
AUC_uno <- AUC.hc(Surv.rsp, Surv.rsp.new, lp, lpnew, times)
AUC_cd$auc
plot(AUC_cd)
