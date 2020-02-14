# Setup =======================================================================

setwd("")
rm(list=ls())
graphics.off()
library(tidyverse)
library(reshape2)
library(patchwork)
library(haven)
library(data.table)

# Plot main analysis results ==================================================

source("code/figure_main.R")

# Plot sensitivity analysis results ===========================================

source("code/figure_sensitivity.R")

# Plot adjusted results ===========================================

source("code/figure_adj.R")

# Plot subtypes analysis results ==============================================

source("code/figure_subtypes.R")

# Plot logit results ==========================================================

source("code/figure_logit.R")

# Plot heat map figures (not included in paper) ===============================

# source("code/figure_refclasses.R")

# Plot bias scatter ===========================================================

source("code/figure_biascomponent.R")

# Plot instrument frequency ===================================================

source("code/figure_insfreq.R")

# Format table containing Bonet's instrumental variable inequality tests) =====

source("code/table_bonet.R")

