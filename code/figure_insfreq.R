# List unadjusted cohort 1 files with outcome 'any dementia' ------------------

files <- list.files(path = "data/", pattern = paste0("data-cohort1-dementia-*"))
files <- files[!grepl("-adj",files)==TRUE]
files <- files[!grepl("imputed",files)==TRUE]

# Create results data frame ---------------------------------------------------

df <- data.frame(exposure = character(),
                 ins0 = numeric(),
                 ins1 = numeric(),
                 ins2 = numeric(),
                 ins3 = numeric(),
                 ins4 = numeric(),
                 ins5 = numeric(),
                 ins6 = numeric(),
                 ins7 = numeric(),
                 stringsAsFactors = FALSE)

# Repeat extraction on each file ----------------------------------------------

for (i in files) {
  
  # Open each file ------------------------------------------------------------
  
  tmp <- haven::read_dta(paste0("data/",i))
  
  # Extract reference treatment and treament of interest ----------------------
  
  x <- gsub("data-cohort1-dementia-","",gsub(".dta","",i))
  
  # Append above to results data frame ----------------------------------------
  
  df[nrow(df)+1,] <- c(x,
                       nrow(tmp[tmp$instrument==0,]),
                       nrow(tmp[tmp$instrument==1,]),
                       nrow(tmp[tmp$instrument==2,]),
                       nrow(tmp[tmp$instrument==3,]),
                       nrow(tmp[tmp$instrument==4,]),
                       nrow(tmp[tmp$instrument==5,]),
                       nrow(tmp[tmp$instrument==6,]),
                       nrow(tmp[tmp$instrument==7,]))
  
}

# Reshape: wide to long --------------------------------------------------------

df <- tidyr::gather(df,ins,freq,ins0:ins7)
df$ins <- substr(df$ins,4,4)
df$ins <- as.numeric(df$ins)
df$freq <- as.numeric(df$freq)

# Clean variable names --------------------------------------------------------

df$exposure <- ifelse(df$exposure=="ht_aab","Alpha-adrenoceptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_ace","Angiotensin converting enzyme inhibitors",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_arb","Angiotensin-II receptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_bab","Beta-adrenoceptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_ccb","Calcium channel blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_diu","Diuretics",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_vad","Vasodilator antihypertensives",df$exposure)

# Calculate proportion --------------------------------------------------------

df$prop <- df$freq / (sum(df$freq)/length(unique(df$exposure)))

# Plot -------------------------------------------------------------------------

t = 8

ggplot2::ggplot(df, ggplot2::aes(x = ins, y = prop)) +
  ggplot2::geom_bar(stat='identity') +
  ggplot2::geom_hline(yintercept = 1/8, linetype = "dashed") +
  ggplot2::facet_wrap(exposure~.,ncol = 2) +
  ggplot2::scale_x_continuous(name = "Instrument value", breaks = seq(0,7,1)) +
  ggplot2::scale_y_continuous(name = "Proportion of patients with instrument value", lim = c(0,1), breaks = seq(0,1,0.2)) +
  ggplot2::theme_bw() +
  ggplot2::theme(plot.title = ggplot2::element_text(size=t, hjust=0),
                 panel.grid.major.x = ggplot2::element_blank(),
                 axis.text = ggplot2::element_text(size=t),
                 axis.title = ggplot2::element_text(size=t),
                 axis.ticks = ggplot2::element_blank(),
                 panel.grid.minor = ggplot2::element_blank(),
                 strip.text = ggplot2::element_text(size=t),
                 strip.background = ggplot2::element_blank()) 

ggplot2::ggsave("output/figure_insfreq.jpeg", 
                height = 297, width = 210, unit = "mm", 
                dpi = 600, scale = 1)