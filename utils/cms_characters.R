library(ggplot2)
library(viridis)
library(hrbrthemes)
library(dplyr, warn = FALSE)
library(patchwork)
library(readr)
library(writexl)

# create CMS dataset
merged_clinical_molecular_public_tcga <- read_csv("/merged_clinical_molecular_public_tcga.csv")
merged_clinical_molecular_public_tcga <- merged_clinical_molecular_public_tcga[, -1]

CMS_list <- split(merged_clinical_molecular_public_tcga, merged_clinical_molecular_public_tcga$cms_label)
# write_xlsx(CMS_list, "CMS characteristics.xlsx")

## gender
CMS1_gender <- CMS_list[["CMS1"]] %>%
  group_by(., gender) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1')
CMS2_gender <- CMS_list[["CMS2"]] %>%
  group_by(., gender) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2')
CMS3_gender <- CMS_list[["CMS3"]] %>%
  group_by(., gender) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3')
CMS4_gender <- CMS_list[["CMS4"]] %>%
  group_by(., gender) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4')
na_gender <- CMS_list[["NOLBL"]] %>%
  group_by(., gender) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL')
cms_gender <- rbind(CMS1_gender, CMS2_gender, CMS3_gender, CMS4_gender, na_gender)

p1 <- ggplot(cms_gender, aes(fill=gender, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9', '#707070')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p1
# p1 + theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),
#            panel.background = element_blank())

## site
CMS1_site <- CMS_list[["CMS1"]] %>%
  group_by(., site_of_resection_or_biopsy) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1') 
CMS1_site <- data.frame(
  site = c('Right', 'Left', 'Rectum', 'Other'),
  Count = c(19+30+3, 1+1+4, 4, 11+3),
  CMS = rep('CMS1', 4)
)
CMS2_site <- CMS_list[["CMS2"]] %>%
  group_by(., site_of_resection_or_biopsy) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2') 
CMS2_site <- data.frame(
  site = c('Right', 'Left', 'Rectum', 'Other'),
  Count = c(17+17+5, 6+57+31, 44, 34+7+2),
  CMS = rep('CMS2', 4)
)
CMS3_site <- CMS_list[["CMS3"]] %>%
  group_by(., site_of_resection_or_biopsy) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3') 
CMS3_site <- data.frame(
  site = c('Right', 'Left', 'Rectum', 'Other'),
  Count = c(21+7+3, 4+9+9, 9, 7+2+1),
  CMS = rep('CMS3', 4)
)
CMS4_site <- CMS_list[["CMS4"]] %>%
  group_by(., site_of_resection_or_biopsy) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4') 
CMS4_site <- data.frame(
  site = c('Right', 'Left', 'Rectum', 'Other'),
  Count = c(17+16+4, 4+29+20, 19, 1+28+2+1+1+2),
  CMS = rep('CMS4', 4)
)
NOLBL_site <- CMS_list[["NOLBL"]] %>%
  group_by(., site_of_resection_or_biopsy) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL') 
NOLBL_site <- data.frame(
  site = c('Right', 'Left', 'Rectum', 'Other'),
  Count = c(10+9+3, 5+5, 9, 18+1+1),
  CMS = rep('NOLBL', 4)
)
cms_site <- rbind(CMS1_site, CMS2_site, CMS3_site, CMS4_site, NOLBL_site)
cms_site$site <- factor(cms_site$site, levels = c('Other','Rectum','Left','Right'))
# plot cms site
p2 <- ggplot(cms_site, aes(fill=site, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9', '#d4d4d4','#9a9a9a', '#707070')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p2

## stage at diagnosis
CMS1_stage <- CMS_list[["CMS1"]] %>%
  group_by(., stage) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1') 
CMS2_stage <- CMS_list[["CMS2"]] %>%
  group_by(., stage) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2') 
CMS3_stage <- CMS_list[["CMS3"]] %>%
  group_by(., stage) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3') 
CMS4_stage <- CMS_list[["CMS4"]] %>%
  group_by(., stage) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4') 
NOLBL_stage <- CMS_list[["NOLBL"]] %>%
  group_by(., stage) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL') 
cms_stage <- rbind(CMS1_stage, CMS2_stage, CMS3_stage, CMS4_stage, NOLBL_stage) %>%
  na.omit()
cms_stage$stage <- as.character(cms_stage$stage)
# plot cms stage
p3 <- ggplot(cms_stage, aes(fill=stage, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9', '#d4d4d4','#9a9a9a', '#707070')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p3


## msi
CMS1_msi <- CMS_list[["CMS1"]] %>%
  group_by(., msi) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1') 
CMS2_msi <- CMS_list[["CMS2"]] %>%
  group_by(., msi) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2') 
CMS3_msi <- CMS_list[["CMS3"]] %>%
  group_by(., msi) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3') 
CMS4_msi <- CMS_list[["CMS4"]] %>%
  group_by(., msi) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4') 
NOLBL_msi <- CMS_list[["NOLBL"]] %>%
  group_by(., msi) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL') 
cms_msi <- rbind(CMS1_msi, CMS2_msi, CMS3_msi, CMS4_msi, NOLBL_msi) %>%
  na.omit()
# plot cms msi
p4 <- ggplot(cms_msi, aes(fill=msi, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9', '#707070')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p4


## cimp
CMS1_cimp <- CMS_list[["CMS1"]] %>%
  group_by(., cimp) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1') 
CMS2_cimp <- CMS_list[["CMS2"]] %>%
  group_by(., cimp) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2') 
CMS3_cimp <- CMS_list[["CMS3"]] %>%
  group_by(., cimp) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3') 
CMS4_cimp <- CMS_list[["CMS4"]] %>%
  group_by(., cimp) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4') 
NOLBL_cimp <- CMS_list[["NOLBL"]] %>%
  group_by(., cimp) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL') 
cms_cimp <- rbind(CMS1_cimp, CMS2_cimp, CMS3_cimp, CMS4_cimp, NOLBL_cimp) %>%
  na.omit()
cms_cimp$cimp <- factor(cms_cimp$cimp, levels = c('CIMP.High','CIMP.Low','CIMP.Neg'))
# plot cms cimp
p5 <- ggplot(cms_cimp, aes(fill=cimp, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9','#d4d4d4', '#707070')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p5

## kras 
CMS1_kras <- CMS_list[["CMS1"]] %>%
  group_by(., kras_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1') 
CMS2_kras <- CMS_list[["CMS2"]] %>%
  group_by(., kras_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2') 
CMS3_kras <- CMS_list[["CMS3"]] %>%
  group_by(., kras_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3') 
CMS4_kras <- CMS_list[["CMS4"]] %>%
  group_by(., kras_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4') 
NOLBL_kras <- CMS_list[["NOLBL"]] %>%
  group_by(., kras_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL') 
cms_kras <- rbind(CMS1_kras, CMS2_kras, CMS3_kras, CMS4_kras, NOLBL_kras) %>%
  na.omit()
cms_kras$kras_mut <- as.character(cms_kras$kras_mut)
# plot cms kras
p6 <- ggplot(cms_kras, aes(fill=kras_mut, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9', '#707070')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p6

## braf
CMS1_braf <- CMS_list[["CMS1"]] %>%
  group_by(., braf_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1') 
CMS2_braf <- CMS_list[["CMS2"]] %>%
  group_by(., braf_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2') 
CMS3_braf <- CMS_list[["CMS3"]] %>%
  group_by(., braf_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3') 
CMS4_braf <- CMS_list[["CMS4"]] %>%
  group_by(., braf_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4') 
NOLBL_braf <- CMS_list[["NOLBL"]] %>%
  group_by(., braf_mut) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL') 
cms_braf <- rbind(CMS1_braf, CMS2_braf, CMS3_braf, CMS4_braf, NOLBL_braf) %>%
  na.omit()
cms_braf$braf_mut <- as.character(cms_braf$braf_mut)
# plot cms braf
p7 <- ggplot(cms_braf, aes(fill=braf_mut, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9', '#707070')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p7

## morphology
CMS1_mor <- CMS_list[["CMS1"]] %>%
  group_by(., morphology) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS1') 
CMS2_mor <- CMS_list[["CMS2"]] %>%
  group_by(., morphology) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS2') 
CMS3_mor <- CMS_list[["CMS3"]] %>%
  group_by(., morphology) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS3') 
CMS4_mor <- CMS_list[["CMS4"]] %>%
  group_by(., morphology) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'CMS4') 
NOLBL_mor <- CMS_list[["NOLBL"]] %>%
  group_by(., morphology) %>%
  summarise(Count = n()) %>%
  mutate(CMS = 'NOLBL') 
cms_mor <- rbind(CMS1_mor, CMS2_mor, CMS3_mor, CMS4_mor, NOLBL_mor) %>%
  na.omit() 
cms_mor <- cms_mor[-c(16, 21),]
cms_mor$morphology <- factor(cms_mor$morphology, levels = c('m_8140/3', 'm_8480/3', 'm_8560/3',
                                      'm_8574/3', 'm_8255/3', 'm_8010/3', 'm_8260/3', 'm_8211/3',
                                      'm_8263/3'))
# plot cms morphology
p8 <- ggplot(cms_mor, aes(fill=morphology, x=CMS, y=Count)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = c('#e9e9e9','#C1C2C4','#B0B1B6','#AEAFB1',
                               '#838383','#707070','#595959', '#4E4E4E', '#3F3F3F')) +
  theme_ipsum(grid = 'Y') +
  xlab("") +
  ylab('Proportion') +
  geom_hline(aes(yintercept=0.25), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.5), colour="black", linetype="dashed") +
  geom_hline(aes(yintercept=0.75), colour="black", linetype="dashed")
p8

## combine 
(p1|p2|p3|p4) / (p5|p6|p7|p8)
