# Load data ===================================================================

df <- data.table::fread("output/analysis_reg_imputed.csv",
                        data.table = FALSE,
                        stringsAsFactors = FALSE)

cc <- data.table::fread("output/analysis_reg_cohorts.csv", 
                        select = colnames(df),
                        data.table = FALSE,
                        stringsAsFactors = FALSE)

cc <- cc[cc$analysis=="logistic_cc",]

df <- rbind(df,cc)

# Format analysis ===========================================================

df$analysis <- ifelse(df$analysis=="logistic_cc","cc",df$analysis)
df$analysis <- ifelse(df$analysis=="logit_imputed","mi",df$analysis)

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

tmp <- tidyr::pivot_wider(df[,c("exposure","outcome","analysis","coef","ci_lower","ci_upper")], 
                          names_from = "analysis", 
                          values_from = c("coef","ci_lower","ci_upper"))

tmp$lab <- paste0(tmp$exposure,"\n(CC: ",
                 sprintf("%.2f",tmp$coef_cc),"; 95% CI: ",
                 sprintf("%.2f",tmp$ci_lower_cc)," to ",
                 sprintf("%.2f",tmp$ci_upper_cc),")\n(MI: ",
                 sprintf("%.2f",tmp$coef_mi),"; 95% CI: ",
                 sprintf("%.2f",tmp$ci_lower_mi)," to ",
                 sprintf("%.2f",tmp$ci_upper_mi),")")

df <- merge(df,tmp[,c("exposure","outcome","lab")], by = c("exposure","outcome"))

# Generate plots ==============================================================

ggplot2::ggplot(df,ggplot2::aes(x = coef,y = forcats::fct_rev(lab), col = forcats::fct_rev(analysis))) + 
  ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.5)) + 
  ggplot2::geom_errorbarh(ggplot2::aes(xmin = ci_lower, xmax = ci_upper), height = 0, position = ggplot2::position_dodge(width = 0.5)) +
  ggplot2::geom_vline(xintercept=1, linetype = 2) +
  ggplot2::scale_y_discrete(name = "") +
  ggplot2::scale_x_continuous(name = "Odds ratio and 95% confidence interval",
                     breaks = seq(0.5,1.5,0.1), lim = c(0.5,1.5)) +
  ggplot2::labs(color = "") +
  ggplot2::scale_color_manual(values = c("#F8766D","#00BFc4"),
                              breaks = c("cc","mi"),
                              labels = c("Complete case (CC)",
                                         "Multiple imputation (MI)")) +
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(), 
        panel.grid.minor = ggplot2::element_blank(),
        axis.text = ggplot2::element_text(size=8),
        text = ggplot2::element_text(size=8),
        strip.text.y = ggplot2::element_text(size=8,hjust = 1, angle = 180),
        legend.position ="bottom")

ggplot2::ggsave("output/figure_logit.jpeg", 
       height = 100, width = 210, unit = "mm", 
       dpi = 600, scale = 1)