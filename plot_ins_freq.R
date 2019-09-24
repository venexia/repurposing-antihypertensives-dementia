# Load libraries --------------------------------------------------------------

library(haven)
library(tidyr)
library(ggplot2)
library(cowplot)

# Specify outcome -------------------------------------------------------------

outcome = "dem_any"

# List unadjusted cohort 1 files with outcome 'any dementia' ------------------

files <- list.files(path = "data/analysis", pattern = paste0("data-cohort1-",outcome,"-*"))
files <- files[!grepl("-adj",files)==TRUE]

# Create results data frame ---------------------------------------------------

df <- data.frame(treat_ref = character(),
                 treat_int = character(),
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
  
  tmp <- read_dta(paste0("data/analysis/",i))
  
  # Extract reference treatment and treament of interest ----------------------
  
  x <- strsplit(gsub(paste0("data-cohort1-",outcome,"-"),"",gsub(".dta","",i)),"-")[[1]]

  # Extract frequency of each instrument level --------------------------------
  
  y <- as.vector(table(tmp$instrument))
  
  # Append above to results data frame ----------------------------------------
  
  df[nrow(df)+1,] <- c(x,y)
  
}

# Reshape: wide to long --------------------------------------------------------

df <- gather(df,ins,freq,ins0:ins7)
df$ins <- substr(df$ins,4,4)
df$ins <- as.numeric(df$ins)
df$freq <- as.numeric(df$freq)

# Add blanks so x = y ----------------------------------------------------------

for (i in unique(df$treat_ref)) {

  tmp <- data.frame(treat_ref=i,
                    treat_int=i,
                    ins = seq(0,7),
                    freq = 0,
                    stringsAsFactors = FALSE)
  
  df <- rbind(df,tmp)

}

# Format outcome labels =======================================================

df$outcome <- ifelse(df$outcome=="dem_any","Any dementia",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_oth","Other dementias",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_vas","Vascular dementia",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_adposs","Possible AD",df$outcome)
df$outcome <- ifelse(df$outcome=="dem_adprob","Probable AD",df$outcome)

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

# Normalise --------------------------------------------------------------------

df$id <- paste0(df$treat_int,"_",df$treat_ref)

tmp <- aggregate(df$freq, by = list(df$treat_int,df$treat_ref), max)
colnames(tmp) <- c("treat_int","treat_ref","maxfreq")
df <- merge(df,tmp)

df$prop <- df$freq/df$maxfreq

# Plot -------------------------------------------------------------------------

t = 8

ggplot(df[df$include==1,], aes(x = ins, y = prop)) +
  geom_bar(stat='identity') +
  facet_grid(rows = vars(treat_int), cols=vars(treat_ref),
             labeller = labeller(treat_int = label_wrap_gen(20),
                                 treat_ref = label_wrap_gen(20))) +
  scale_x_continuous(name = "Instrument value\n \nReference drug class",breaks=seq(0,7,1)) +
  scale_y_continuous(name = "Drug class of interest\n \nProportion of patients with instrument value") +
  theme_bw() +
  theme(plot.title = element_text(size=t, hjust=0),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size=t),
        axis.title=element_text(size=t),
        axis.ticks = element_blank(),
        panel.grid.minor = element_blank(),
        strip.text = element_text(size=t),
        strip.background = element_blank()) 

ggsave("output/ins_freq.jpeg", 
       height = 10, width = 15, unit = "cm", 
       dpi = 600, scale = 2.5)