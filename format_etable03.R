library(reshape2)
library(dplyr)

# Load data ===================================================================

df <- read.csv("output/analysis_reg.csv", 
               stringsAsFactors = FALSE)

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

# Reformat data ===============================================================

df <- df[df$cohort==1 & df$outcome=="Any dementia" & df$analysis=="iv",c(4:5,54:85)]
df <- melt(df,id=c("treat_int","treat_ref"))
df$variable <- as.character(df$variable)
df$Z <- as.numeric(substr(df$variable,2,2))
df$XY <- substr(df$variable,3,6)
df$variable <- NULL
df <- df[df$XY %in% c("X0Y0","X1Y0","X0Y1","X1Y1"),]
df <- dcast(df, treat_int + treat_ref + Z ~ XY)

# Calculate percentages =======================================================

df$N <- df$X0Y0 + df$X0Y1 + df$X1Y0 + df$X1Y1
df$X0Y0_pc <- df$X0Y0/df$N
df$X0Y1_pc <- df$X0Y1/df$N
df$X1Y0_pc <- df$X1Y0/df$N
df$X1Y1_pc <- df$X1Y1/df$N

# Calculate components of the inequalities ====================================

df <- df %>% 
  group_by(treat_ref,treat_int) %>% 
  mutate(ineq1_lhs = max(X0Y1_pc),
         ineq1_rhs = min(1 - X1Y1_pc),
         ineq2_lhs = max(X1Y1_pc),
         ineq2_rhs = min(1 - X0Y1_pc),
         ineq3_lhs = max(X0Y1_pc + X1Y1_pc) + max(X0Y1_pc + X1Y0_pc) + max(X0Y0_pc)) %>% 
  ungroup()

# Test inequalities ===========================================================

df$ineq1 <- ifelse(df$ineq1_lhs <= df$ineq1_rhs, TRUE, FALSE)
df$ineq2 <- ifelse(df$ineq2_lhs <= df$ineq2_rhs, TRUE, FALSE)
df$ineq3 <- ifelse(df$ineq3_lhs <= 2, TRUE, FALSE)

# Save as supplementary file ==================================================

write.csv(df,"output/eTable03.csv",row.names = FALSE)