# Setup =======================================================================

setwd("")
rm(list=ls())
graphics.off()

# Ensure all necessary dependencies are installed =============================

# source("code/dependency.R")

# Plot main analysis results ==================================================

source("code/figure_main.R", echo = TRUE)

# Plot sensitivity analysis results ===========================================

source("code/figure_sensitivity.R", echo = TRUE)

# Plot adjusted results =======================================================

source("code/figure_adj.R", echo = TRUE)

# Plot subtypes analysis results ==============================================

source("code/figure_subtypes.R", echo = TRUE)

# Plot logit results ==========================================================

source("code/figure_logit.R", echo = TRUE)

# Plot heat map figures (not included in paper) ===============================

# source("code/figure_refclasses.R", echo = TRUE)

# Plot bias scatter ===========================================================

source("code/figure_biascomponent.R", echo = TRUE)

# Plot instrument frequency ===================================================

source("code/figure_insfreq.R", echo = TRUE)

# Format table containing Bonet's instrumental variable inequality tests) =====

source("code/table_bonet.R", echo = TRUE)

