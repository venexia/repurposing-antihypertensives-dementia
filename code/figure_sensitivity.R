# Load data ===================================================================

df <- read.csv("output/analysis_reg.csv", 
               stringsAsFactors = FALSE)

df_cohorts <- read.csv("output/analysis_reg_cohorts.csv", 
                       stringsAsFactors = FALSE)

df <- rbind(df,df_cohorts)

df <- unique(df)

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

df$sensitivity <- NA
df$sensitivity <- ifelse(df$cohort==1 & df$analysis=="iv","Main analysis",df$sensitivity)
df$sensitivity <- ifelse(df$cohort==3 & df$analysis=="iv","Analysis excluding individuals with anxiety",df$sensitivity)
df$sensitivity <- ifelse(df$cohort==4 & df$analysis=="iv","Analysis excluding individuals on low doses",df$sensitivity)
df$sensitivity <- ifelse(df$cohort==5 & df$analysis=="iv","Analysis excluding individuals less than 55 years old",df$sensitivity)
df$sensitivity <- ifelse(df$cohort==1 & df$analysis=="iv_fe","Analysis with fixed effects",df$sensitivity)
df$sensitivity <- ifelse(df$cohort==1 & df$analysis=="iv_adj","Analysis adjusted for age and socioeconomic position",df$sensitivity)

df$coef <- 1000*df$coef
df$ci_lower <- 1000*df$ci_lower
df$ci_upper <- 1000*df$ci_upper
df$exposed <- 100*((df$X1Y0+df$X1Y1)/df$N)

df$lab <- ifelse(df$exposed<0.5,
                 paste0(df$sensitivity,"\n(insufficient exposure)"),
                 paste0(df$sensitivity,"\n(",
                        sprintf("%.0f",df$coef),"; 95% CI: ",
                        sprintf("%.0f",df$ci_lower)," to ",
                        sprintf("%.0f",df$ci_upper),")"))

df[df$exposed<0.5,]$coef <- NA
df[df$exposed<0.5,]$ci_lower <- NA
df[df$exposed<0.5,]$ci_upper <- NA

# Generate plots ==============================================================

ggplot2::ggplot(df[!is.na(df$sensitivity),], 
                ggplot2::aes(x = coef,y = lab)) + 
  ggplot2::geom_point() + 
  ggplot2::geom_errorbarh(ggplot2::aes(xmin = ci_lower, xmax = ci_upper), height = 0) +
  ggplot2::geom_vline(xintercept=0, linetype = 2) +
  ggplot2::scale_y_discrete(name = "") +
  ggplot2::scale_x_continuous(name = "Additional cases per 1000 individuals when treated with the drug of interest versus other antihypertensives",
                              breaks = seq(-110,50,10)) +
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(), 
                 panel.grid.minor = ggplot2::element_blank(),
                 axis.text = ggplot2::element_text(size=8),
                 text = ggplot2::element_text(size=8),
                 strip.text.y = ggplot2::element_text(size=8,hjust = 1, angle = 180),
                 legend.position="none") +
  ggplot2::facet_wrap(exposure~.,ncol = 1,scales = "free_y")

ggplot2::ggsave("output/figure_sensitivity.jpeg", 
                height = 297, width = 210, unit = "mm", 
                dpi = 600, scale = 1)