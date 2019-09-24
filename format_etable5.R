library(reshape2)
library(dplyr)

# Load data ===================================================================

df <- read.csv("output/analysis_reg.csv", 
               stringsAsFactors = FALSE)

# Prepare data using common file ==============================================

source("code/plot_prepare.R")

# Reformat data ===============================================================

df <- df[df$cohort==1 & df$outcome=="Any dementia" & df$analysis=="iv" & df$include==1,c(4:5,52:83)]
df <- melt(df,id=c("treat_int","treat_ref"))
df$Z <- as.numeric(substr(df$variable,2,2))
df$XY <- substr(df$variable,3,6)
df$variable <- NULL
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

# Save as supplementary file

write.csv(df,"output/eTable5.csv",row.names = FALSE)