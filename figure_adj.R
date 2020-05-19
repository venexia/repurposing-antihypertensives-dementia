# Load data ===================================================================

df <- read.csv("output/analysis_reg_adj_mi.csv", 
               stringsAsFactors = FALSE)

# Combine 20 imputation results using Rubin's rules: ==========================
# https://bookdown.org/mwheymans/bookmi/rubins-rules.html#pooling-effect-estimates

tmp <- df %>%
  dplyr::group_by(adj,exposure,outcome) %>%
  dplyr::summarise(coef_pooled = mean(coef), 
                   v_w = mean(stderr^2)) %>%
  dplyr::ungroup()

df <- merge(df,tmp)

df$v_b <- (df$coef - df$coef_pooled)^2

df <- df %>%
  dplyr::group_by(adj,exposure,outcome,coef_pooled,v_w) %>%
  dplyr::summarise(v_b = sum(v_b)/(20-1)) %>%
  dplyr::ungroup()

df$v_total <- sqrt(df$v_w + df$v_b + (df$v_b/20))

df <- df[,c("exposure","outcome","adj","coef_pooled","v_total")]

colnames(df) <- c("exposure","outcome","adj","coef","stderr")

# Add unadjusted analysis =====================================================

unadj <- read.csv("output/analysis_reg.csv", 
                  stringsAsFactors = FALSE)

unadj <- unadj[unadj$cohort==1 & unadj$analysis=="iv",]

unadj$adj <- "unadj"

df <- rbind(df,unadj[,colnames(df)])

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

df$adj <- gsub(" ","",df$adj)

df$adjustment <- NA
df$adjustment <- ifelse(df$adj=="unadj","Unadjusted",df$adjustment)
df$adjustment <- ifelse(df$adj=="alcohol","Adjusted for alcohol status",df$adjustment)
df$adjustment <- ifelse(df$adj=="bmi","Adjusted for body mass index",df$adjustment)
df$adjustment <- ifelse(df$adj=="cad","Adjusted for coronary artery disease",df$adjustment)
df$adjustment <- ifelse(df$adj=="cbs","Adjusted for coronary bypass surgery",df$adjustment)
df$adjustment <- ifelse(df$adj=="charlson","Adjusted for chronic disease",df$adjustment)
df$adjustment <- ifelse(df$adj=="cons_rate","Adjusted for annual consultation rate",df$adjustment)
df$adjustment <- ifelse(df$adj=="cvd","Adjusted for cardiovascular disease",df$adjustment)
df$adjustment <- ifelse(df$adj=="imd2010","Adjusted for socioeconomic position",df$adjustment)
df$adjustment <- ifelse(df$adj=="index_age_start","Adjusted for age at index",df$adjustment)
df$adjustment <- ifelse(df$adj=="male","Adjusted for sex",df$adjustment)
df$adjustment <- ifelse(df$adj=="smoking","Adjusted for smoking status",df$adjustment)

df$adjustment <- factor(df$adjustment)
df$adjustment <- fct_rev(df$adjustment)
df$adjustment <- factor(df$adjustment,levels(df$adjustment)[c(2:12,1)])

# Scale estimates =============================================================

df$ci_lower <- 1000*(df$coef - qnorm(0.975)*df$stderr)
df$ci_upper <- 1000*(df$coef + qnorm(0.975)*df$stderr)
df$coef <- 1000*df$coef

# Generate plots ==============================================================

ggplot(df, 
       aes(x = coef,y = adjustment)) + 
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

ggsave("output/figure_adj_mi.jpeg", 
       height = 297, width = 210, unit = "mm", 
       dpi = 600, scale = 1)