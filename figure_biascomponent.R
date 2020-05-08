# Load data ===================================================================

df <- read.csv("output/bias_scatter.csv",stringsAsFactors = FALSE)

# Add IV scale factor ==========================================================

scales <- read.csv("output/analysis_reg.csv",stringsAsFactors = FALSE)

scales <- scales[scales$cohort==1 & scales$analysis=="first",c("exposure","coef")]

scales$scale <- 1/scales$coef

scales$analysis <- "iv"

scales$coef <- NULL

scales <- rbind(scales,data.frame(exposure = unique(scales$exposure),scale = 1,analysis = "lin"))

df <- merge(df,scales,by=c("exposure","analysis"))

# Calculate scaled coefficient ================================================
# Note: logistic regression results are yet to be exponeniated ================

df$coef_scaled <- df$scale * df$coef
df$ci_lower_scaled <- df$scale * df$ci_lower
df$ci_upper_scaled <-df$scale * df$ci_upper

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

# Mark binary and continuous analyses =======================================

bin.cov <- c("male","cad","cbs","cvd","never_drink","never_smoke")

df$bin.cont <- ifelse(df$cov %in% bin.cov,
                      "binary",
                      "continuous")

# Tidy covariate names ======================================================

cov.names <- data.frame(cov = c("bmi","cad","cbs","charlson","cons_rate",
                                "cvd","imd2010","index_age_start","male",
                                "never_drink","never_smoke"),
                        cov.name = c("BMI",
                                     "Ever coronary artery disease [vs never]",
                                     "Ever coronary bypass surgery [vs never]",
                                     "Charlson index for chronic disease",
                                     "Annual consultation rate",
                                     "Ever cerebrovascular disease [vs never]",
                                     "Index of Multiple Deprivation 2010",
                                     "Age at index",
                                     "Male [vs female]",
                                     "Never drinker [vs ever]",
                                     "Never smoker [vs ever]"))

df <- merge(df,cov.names,by="cov",all.x = TRUE)

# Format analysis labels ======================================================

df$analysis <- ifelse(df$analysis=="iv","Instrumental variable analaysis",df$analysis)
df$analysis <- ifelse(df$analysis=="lin" & df$bin.cont=="continuous","Linear regression analaysis",df$analysis)
df$analysis <- ifelse(df$analysis=="lin" & df$bin.cont=="binary","Logistic regression analaysis",df$analysis)

# Generate continuous covariate plot ==========================================

ggplot(df[df$bin.cont=="continuous",],
       aes(y = coef_scaled,x = fct_rev(cov.name), color = analysis)) + 
  geom_point(position = position_dodge(width = 0.5)) + 
  geom_errorbar(aes(ymin = ci_lower_scaled, ymax = ci_upper_scaled),
                width = 0,position = position_dodge(width = 0.5)) +
  geom_hline(yintercept=0, linetype = 2) +
  labs(y = "Coefficient and 95% CI", x = "", color = "") +
  scale_y_continuous(lim = c(-13,13),breaks = seq(-12,12,2)) +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text=element_text(size=8),
        text=element_text(size=8),
        strip.text.y = element_text(size=8,hjust = 1, angle = 180),
        legend.position="bottom") +
  coord_flip() +
  facet_wrap(exposure~., ncol = 1)

ggsave("output/figure_biascomponent_con.jpeg", 
       height = 297, width = 210, unit = "mm", 
       dpi = 600, scale = 1)

# Generate binary covariate plot ==========================================

ggplot(df[df$bin.cont=="binary",],
       aes(y = exp(coef_scaled),x = fct_rev(cov.name), color = analysis)) + 
  geom_point(position = position_dodge(width = 0.5)) + 
  geom_errorbar(aes(ymin = exp(ci_lower_scaled), ymax = exp(ci_upper_scaled)),width = 0,position = position_dodge(width = 0.5)) +
  geom_hline(yintercept=1, linetype = 2) +
  scale_y_continuous(trans="log",lim = c(0.7,3.6), breaks = c(seq(0.75,2,0.25),seq(2.5,3.5,0.5))) + 
  labs(y = "Odds ratio and 95% CI", x = "", color = "") +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text=element_text(size=8),
        text=element_text(size=8),
        strip.text.y = element_text(size=8,hjust = 1, angle = 180),
        legend.position="bottom") +
  coord_flip() +
  facet_wrap(exposure~., ncol = 1)

ggsave("output/figure_biascomponent_bin.jpeg", 
       height = 297, width = 210, unit = "mm", 
       dpi = 600, scale = 1)