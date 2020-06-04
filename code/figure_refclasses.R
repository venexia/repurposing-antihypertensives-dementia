# Load data ===================================================================

df <- read.csv("output/analysis_reg_refclasses.csv", 
               stringsAsFactors = FALSE)

# Format treatment of interest labels =========================================

df$treat_int <- ifelse(df$treat_int=="ht_aab","Alpha-adrenoceptor blockers",df$treat_int)
df$treat_int <- ifelse(df$treat_int=="ht_ace","Angiotensin converting enzyme inhibitors",df$treat_int)
df$treat_int <- ifelse(df$treat_int=="ht_arb","Angiotensin-II receptor blockers",df$treat_int)
df$treat_int <- ifelse(df$treat_int=="ht_bab","Beta-adrenoceptor blockers",df$treat_int)
df$treat_int <- ifelse(df$treat_int=="ht_ccb","Calcium channel blockers",df$treat_int)
df$treat_int <- ifelse(df$treat_int=="ht_diu","Diuretics",df$treat_int)
df$treat_int <- ifelse(df$treat_int=="ht_vad","Vasodilator antihypertensives",df$treat_int)

# Format reference treatment labels ===========================================

df$treat_ref <- ifelse(df$treat_ref=="ht_aab","Alpha-adrenoceptor blockers",df$treat_ref)
df$treat_ref <- ifelse(df$treat_ref=="ht_ace","Angiotensin converting enzyme inhibitors",df$treat_ref)
df$treat_ref <- ifelse(df$treat_ref=="ht_arb","Angiotensin-II receptor blockers",df$treat_ref)
df$treat_ref <- ifelse(df$treat_ref=="ht_bab","Beta-adrenoceptor blockers",df$treat_ref)
df$treat_ref <- ifelse(df$treat_ref=="ht_ccb","Calcium channel blockers",df$treat_ref)
df$treat_ref <- ifelse(df$treat_ref=="ht_diu","Diuretics",df$treat_ref)
df$treat_ref <- ifelse(df$treat_ref=="ht_vad","Vasodilator antihypertensives",df$treat_ref)

# Make IV estimates per 1000 people treated ====================================

df$coef <- ifelse(df$analysis %in% c("iv","iv_adj","iv_bin","iv_fe"),1000*df$coef,df$coef)
df$ci_lower <- ifelse(df$analysis %in% c("iv","iv_adj","iv_bin","iv_fe"),1000*df$ci_lower,df$ci_lower)
df$ci_upper <- ifelse(df$analysis %in% c("iv","iv_adj","iv_bin","iv_fe"),1000*df$ci_upper,df$ci_upper)

# Use NA for estimates that do not have >0 for each treatment-outcome combination

df$coef <- ifelse(df$X0Y0==0 | df$X0Y1==0 | df$X1Y0==0 | df$X1Y1==0,NA,df$coef)
df$ci_lower <- ifelse(df$X0Y0==0 | df$X0Y1==0 | df$X1Y0==0 | df$X1Y1==0,NA,df$ci_lower)
df$ci_upper <- ifelse(df$X0Y0==0 | df$X0Y1==0 | df$X1Y0==0 | df$X1Y1==0,NA,df$ci_upper)
df$pval <- ifelse(df$X0Y0==0 | df$X0Y1==0 | df$X1Y0==0 | df$X1Y1==0,NA,df$pval)

# Format estimate labels ======================================================

df$gtext_pval <- ifelse(df$pval<0.0005,"<5e-4",format(df$pval,scientific = TRUE,digits = 2))

df$gtext <- ifelse(df$analysis %in% c("iv","iv_adj","iv_bin","iv_fe"),
                   paste0(sprintf("%.0f",df$coef)," (",
                          sprintf("%.0f",df$ci_lower)," to ",
                          sprintf("%.0f",df$ci_upper),"); ",
                          format(df$gtext_pval,scientific = TRUE,digits = 2)),
                   paste0(sprintf("%.2f",df$coef)," (",
                          sprintf("%.2f",df$ci_lower)," to ",
                          sprintf("%.2f",df$ci_upper),"); ",
                          format(df$gtext_pval,scientific = TRUE,digits = 2)))

df$gtext <- ifelse(is.na(df$coef),NA,df$gtext)
df$gtext <- ifelse(df$X0Y1+df$X1Y1<100 & !is.na(df$coef),paste0(df$gtext," [X]"),df$gtext)

# List all drugs under consideration ==========================================

drugs <- c("Alpha-adrenoceptor blockers",
           "Angiotensin-II receptor blockers",
           "Angiotensin converting enzyme inhibitors",
           "Beta-adrenoceptor blockers",
           "Calcium channel blockers",
           "Diuretics",
           "Vasodilator antihypertensives")

# Mark analyses to present (i.e. top right half of matrix) ====================

df$include <- 1
c <- 1

for (i in drugs[1:6]) {
  c <- c + 1
  j <- drugs[c:7]
  df[df$treat_ref==i & df$treat_int %in% j,]$include <- 0
}

df$treat_int <- factor(df$treat_int)
df$treat_ref <- factor(df$treat_ref)

# Set limit for colours and define colours for estimates outside limits as max

l <- 50

df$coef_di <- ifelse(abs(df$coef)>l,sign(df$coef)*l,df$coef)

# Generate plot ===============================================================

t <- 12

ggplot2::ggplot(df[df$include==1,], aes(x = treat_ref, y = treat_int, label = gtext)) +
  ggplot2::labs(x = "Reference drug class", y = "Drug class of interest", 
       fill = "Additional cases per 1000 \ntreated (95% CI); p-value.\n[X] indicates <100 cases. ") +
  ggplot2::scale_x_discrete(limits = drugs, position = "top", 
                   labels = function(x) str_wrap(levels(df$treat_ref), width = 22)) +
  ggplot2::scale_y_discrete(limits = rev(drugs),
                   labels = function(x) str_wrap(rev(levels(df$treat_ref)), width = 22)) +
  ggplot2::theme_bw() +
  ggplot2::theme(plot.title = ggplot2::element_text(size=t, hjust=0),
        panel.grid.major = ggplot2::element_blank(),
        axis.text = ggplot2::element_text(size=t),
        axis.title = ggplot2::element_text(size=t),
        legend.position = "bottom",
        legend.text = ggplot2::element_text(size=t),
        legend.title = ggplot2::element_text(size=t),
        panel.grid.minor = ggplot2::element_blank(),
        strip.text = ggplot2::element_text(size=t),
        strip.background = ggplot2::element_rect(fill="white")) +
  ggplot2::geom_tile(aes(fill = coef_di), colour = "white", size = 1.05) +
  ggplot2::geom_text(size = 0.36*t) +
  ggplot2::scale_fill_distiller(palette = "Spectral", guide = guide_colorbar(barwidth = 20), 
                       limits = c(-l,l), na.value = NA)


ggplot2::ggsave("output/figure_refclasses.jpeg", 
       height = 100, width = 210, unit = "mm", 
       dpi = 600, scale = 1.8)