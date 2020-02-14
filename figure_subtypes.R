# Load data ===================================================================

df1 <- read.csv("output/analysis_reg.csv", 
               stringsAsFactors = FALSE)

df1 <- df1[df1$cohort==1 & df1$analysis=="iv",]

df <- read.csv("output/analysis_reg_subtypes.csv", 
               stringsAsFactors = FALSE)

df <- rbind(df[,colnames(df1)],df1)

# Format outcome labels =======================================================

df$outcome <- ifelse(df$outcome=="dementia","Any dementia",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_oth","Other dementias",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_vas","Vascular dementia",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_adposs","Possible AD",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_adprob","Probable AD",df$outcome)

# Format treatment of interest labels =========================================

df$exposure <- ifelse(df$exposure=="ht_aab","Alpha-adrenoceptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_ace","Angiotensin converting enzyme inhibitors",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_arb","Angiotensin-II receptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_bab","Beta-adrenoceptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_ccb","Calcium channel blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_diu","Diuretics",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_vad","Vasodilator antihypertensives",df$exposure)

# Generate labels ============================================================

df$coef <- 1000*df$coef
df$ci_lower <- 1000*df$ci_lower
df$ci_upper <- 1000*df$ci_upper

df$lab <- paste0(df$outcome,"\n(",
                        sprintf("%.0f",df$coef),"; 95% CI: ",
                        sprintf("%.0f",df$ci_lower)," to ",
                        sprintf("%.0f",df$ci_upper),")")

df$lab <- factor(df$lab)
df$lab <- factor(df$lab, levels(df$lab)[c(8:14,29:35,15:21,22:28,1:7)])

df$exposed <- round(100*((df$X1Y0+df$X1Y1)/df$N))

tmp <- unique(df[,c("exposure","exposed")])
tmp$lab_facet <- paste0(tmp$exposure," (",tmp$exposed,"% exposure)")
df <- merge(df,tmp,by = c("exposure","exposed"))

# Generate plots ==============================================================

ggplot(df,aes(x = coef,y = lab)) + 
  geom_point() + 
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0) +
  geom_vline(xintercept=0, linetype = 2) +
  scale_y_discrete(name = "") +
  scale_x_continuous(name = "Additional cases per 1000 individuals when treated with the drug of interest versus other antihypertensives",
                     breaks = seq(-110,50,10)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text=element_text(size=8),
        text=element_text(size=8),
        strip.text.y = element_text(size=8,hjust = 1, angle = 180),
        legend.position="none") +
  facet_wrap(exposure~.,ncol = 1,scales = "free_y")

ggsave("output/figure_subtypes.jpeg", 
       height = 297, width = 210, unit = "mm", 
       dpi = 600, scale = 1)