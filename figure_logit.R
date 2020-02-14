# Load data ===================================================================

df <- read.csv("output/analysis_reg_cohorts.csv", 
               stringsAsFactors = FALSE)

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

df$exposed <- 100*((df$X1Y0+df$X1Y1)/df$N)

df$lab <- paste0(df$exposure,"\n(",
                 sprintf("%.2f",df$coef),"; 95% CI: ",
                 sprintf("%.2f",df$ci_lower)," to ",
                 sprintf("%.2f",df$ci_upper),"; ",
                 sprintf("%.0f",df$exposed),"% exposure)")

# Generate plots ==============================================================

ggplot(df[df$analysis=="logit",], 
       aes(x = coef,y = fct_rev(lab))) + 
  geom_point() + 
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0) +
  geom_vline(xintercept=1, linetype = 2) +
  scale_y_discrete(name = "") +
  scale_x_continuous(name = "Odds ratio and 95% confidence interval",
                     breaks = seq(0.5,1.5,0.1), lim = c(0.5,1.5)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text=element_text(size=8),
        text=element_text(size=8),
        strip.text.y = element_text(size=8,hjust = 1, angle = 180),
        legend.position="none")

ggsave("output/figure_logit.jpeg", 
       height = 100, width = 210, unit = "mm", 
       dpi = 600, scale = 1)