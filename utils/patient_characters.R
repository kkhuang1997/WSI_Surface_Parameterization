library(ggplot2)
library(patchwork)

# clinical data
sex <- data.frame(
  Sex=c('Female', 'Male'),
  value=c(270, 303)
)

plot_1 <- ggplot(sex, aes(x="", y=value, fill=Sex)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE')) +
  coord_polar("y", start=0) +
  theme_void() + 
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

Disease_Stage <- data.frame(
  Disease_Stage=c('Stage I', 'Stage II','Stage III', 'Stage IV', 'NA'),
  value=c(99, 209, 169, 81, 15)
)
plot_2 <- ggplot(Disease_Stage, aes(x="", y=value, fill=Disease_Stage)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#AED8E5','#D1AEE5','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))


TNM <- data.frame(
  TNM_Stage=c('I', 'IIA','IIB/IIC', 'IIIA', 'IIIB', 'IIIC', 'IV', 'NA'),
  value=c(101, 198, 14, 13, 86, 74, 82, 5)
)
plot_3 <- ggplot(TNM, aes(x="", y=value, fill=TNM_Stage)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#AED8E5','#D1AEE5','#87B296','#FEEE85','#09436E','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

MSI <- data.frame(
  MSI_State=c('MSI', 'MSS', 'NA'),
  value=c(81,478, 14)
)
plot_4 <- ggplot(MSI, aes(x="", y=value, fill=MSI_State)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

CIMP <- data.frame(
  CIMP_State=c('High', 'Low/Neg', 'NA'),
  value=c(77, 399, 97)
)
plot_5 <- ggplot(CIMP, aes(x="", y=value, fill=CIMP_State)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

CMS <- data.frame(
  CMS=c('CMS1', 'CMS2', 'CMS3', 'CMS4', 'NA'),
  value=c(76, 220, 72, 144, 61)
)
plot_6 <- ggplot(CMS, aes(x="", y=value, fill=CMS)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#AED8E5','#D1AEE5','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

KRAS <- data.frame(
  KRAS=c('Wild-type', 'Mutated', 'NA'),
  value=c(239, 127, 207)
)
plot_7 <- ggplot(KRAS, aes(x="", y=value, fill=KRAS)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

BRAF <- data.frame(
  BRAF=c('Wild-type', 'Mutated', 'NA'),
  value=c(329, 37, 207)
)
plot_8 <- ggplot(BRAF, aes(x="", y=value, fill=BRAF)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

Site <- data.frame(
  Site=c('Ascending colon', 'Cecum', 'Colon(NOS)', 'Other', 'Descending colon','Rectosigmoid junction',
         'Rectum(NOS)', 'Sigmoid colon', 'NA'),
  value=c(80, 83, 98, 2+13+5+18, 15, 66, 85, 104, 4)
)
plot_9 <- ggplot(Site, aes(x="", y=value, fill=Site)) +
  geom_bar(stat="identity", width=1, color="white") +
  scale_fill_manual(values = c('#DED6A9','#E5ADAE','#AED8E5','#D1AEE5','#87B296',
                               '#CB6453','#FEEE85','#09436E','#C4C4C4')) +
  coord_polar("y", start=0) +
  theme_void() + # remove background, grid, numeric labels
  geom_text(aes(label = value), position = position_stack(vjust = 0.5))

plot_1 + plot_2 + plot_3 + plot_4 + plot_5 + plot_6 + plot_7 + plot_8 + plot_9
