# Setup =======================================================================

setwd("")
rm(list=ls())
graphics.off()
library(tidyverse)

### Note: the following files will call "code/plot_prepare.R"

# Plot main analysis results ==================================================

source("code/plot_analysis.R")

# Plot bias scatter ===========================================================

source("code/plot_bias_scatter.R")

# Plot adjusted analysis results ==============================================

source("code/plot_analysis_adj.R")

# Plot instrument frequency ===================================================

source("code/plot_ins_freq.R")

# Format eTable 5 (Bonet's instrumental variable inequality tests) ============

source("code/format_etable5.R")