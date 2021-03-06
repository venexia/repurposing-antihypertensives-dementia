# Load data ===================================================================

df <- read.csv("output/analysis_reg.csv", 
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

# Generate labels =============================================================

df$coef <- 1000*df$coef
df$ci_lower <- 1000*df$ci_lower
df$ci_upper <- 1000*df$ci_upper
df$exposed <- 100*((df$X1Y0+df$X1Y1)/df$N)

df$lab <- paste0(df$exposure,"\n(",
                 sprintf("%.0f",df$coef),"; 95% CI: ",
                 sprintf("%.0f",df$ci_lower)," to ",
                 sprintf("%.0f",df$ci_upper),"; ",
                 sprintf("%.0f",df$exposed),"% exposure)")

# Generate plots ==============================================================

ggplot2::ggplot(df[df$analysis=="iv",], 
                ggplot2::aes(x = coef,y = forcats::fct_rev(lab))) + 
  ggplot2::geom_point() + 
  ggplot2::geom_errorbarh(ggplot2::aes(xmin = ci_lower, xmax = ci_upper), height = 0) +
  ggplot2::geom_vline(xintercept=0, linetype = 2) +
  ggplot2::scale_y_discrete(name = "") +
  ggplot2::scale_x_continuous(name = "Additional cases per 1000 individuals when treated with the drug of interest versus other antihypertensives",
                              breaks = seq(-70,40,10)) +
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(), 
                 panel.grid.minor = ggplot2::element_blank(),
                 axis.text = ggplot2::element_text(size=8),
                 text = ggplot2::element_text(size=8),
                 strip.text.y = ggplot2::element_text(size=8,hjust = 1, angle = 180),
                 legend.position="none")

ggplot2::ggsave("output/figure_main.pdf", 
                height = 100, width = 210, unit = "mm", 
                dpi = 600, scale = 1)