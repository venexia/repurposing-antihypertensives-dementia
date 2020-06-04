library(magrittr)

# Load data ===================================================================

df <- read.csv("output/analysis_reg.csv", 
               stringsAsFactors = FALSE)

# Format treatment of interest labels =========================================

df$exposure <- ifelse(df$exposure=="ht_aab","Alpha-adrenoceptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_ace","Angiotensin converting enzyme inhibitors",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_arb","Angiotensin-II receptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_bab","Beta-adrenoceptor blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_ccb","Calcium channel blockers",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_diu","Diuretics",df$exposure)
df$exposure <- ifelse(df$exposure=="ht_vad","Vasodilator antihypertensives",df$exposure)

# Reformat data ===============================================================

df <- df[df$cohort==1 & df$analysis=="iv",c(3,53:84)]
df <- reshape2::melt(df,id=c("exposure"))
df$variable <- as.character(df$variable)
df$Z <- as.numeric(substr(df$variable,2,2))
df$XY <- substr(df$variable,3,6)
df$variable <- NULL
df <- df[df$XY %in% c("X0Y0","X1Y0","X0Y1","X1Y1"),]
df <- reshape2::dcast(df, exposure + Z ~ XY)

# Calculate percentages =======================================================

df$N <- df$X0Y0 + df$X0Y1 + df$X1Y0 + df$X1Y1
df$X0Y0_pc <- ifelse(df$N>0,df$X0Y0/df$N,0)
df$X0Y1_pc <- ifelse(df$N>0,df$X0Y1/df$N,0)
df$X1Y0_pc <- ifelse(df$N>0,df$X1Y0/df$N,0)
df$X1Y1_pc <- ifelse(df$N>0,df$X1Y1/df$N,0)

# Calculate components of the inequalities ====================================

df <- df %>% 
  dplyr::group_by(exposure) %>% 
  dplyr::mutate(ineq1_lhs = max(X0Y1_pc),
         ineq1_rhs = min(1 - X1Y1_pc),
         ineq2_lhs = max(X1Y1_pc),
         ineq2_rhs = min(1 - X0Y1_pc),
         ineq3_lhs = max(X0Y1_pc + X1Y1_pc) + max(X0Y1_pc + X1Y0_pc) + max(X0Y0_pc)) %>% 
  dplyr::ungroup()

# Test inequalities ===========================================================

df$ineq1 <- ifelse(df$ineq1_lhs <= df$ineq1_rhs, TRUE, FALSE)
df$ineq2 <- ifelse(df$ineq2_lhs <= df$ineq2_rhs, TRUE, FALSE)
df$ineq3 <- ifelse(df$ineq3_lhs <= 2, TRUE, FALSE)

# Save as supplementary file ==================================================

write.csv(df,"output/eTable03.csv",row.names = FALSE)