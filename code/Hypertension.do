log using AntihypertensivesIV

********************************************************************************
************ PLEASE UPDATE THE GLOBAL PATHS BELOW PRIOR TO ANALYSIS ************
********************************************************************************

global raw "data/raw" // Path to directory containing raw CPRD data
global link "data/link" // Path to directory containing linked HES and ONS data
global covar "codelists/csv" // Path to directory containing raw codelists for covariates specific to this project
global patlists "data/patlists" // Path to directory containing patlists [previously processed raw data]
global eventlists "data/eventlists" // Path to directory containing eventlists [previously processed raw data]
global additional "data/additional" // Path to directory containing additional clinical details data with dates added [previously processed raw data]
global project "projects/AntihypertensivesIV" // Path to main project directory
global dofiles "$project/code" // Path to directory containg project code
global output "$project/output" // Path to directory containg project output
global data "$project/data" // Path to directory containg data derived for this project

********************************************************************************
*********************************** ANALYSIS ***********************************
********************************************************************************

* Deine covariates to be retained in all files --------------------------------

do "$dofiles/codedict.do"

/*
* Generate missing patlists ----------------------------------------------------

use "$eventlists/eventlist_ht_psd.dta", clear
append using "$eventlists/eventlist_ht_thi.dta"
save "$eventlists/eventlist_ht_diu.dta", replace
egen index_count = count(patid), by(patid)
egen min_date = min(index_date), by(patid)
format %td min_date
keep patid index_count min_date
rename min_date index_date
duplicates drop *, force
save "$patlists/patlist_`event'.dta", replace
*/

* Generate cohort --------------------------------------------------------------

do "$dofiles/cohort.do"

* Add covariates (Note: cov.do requires cov_*.do) ------------------------------

do "$dofiles/cov.do"

* Run analyses on outcome 'dementia' -------------------------------------------

do "$dofiles/analysis.do"

* Run analyses on cohorts (e.g. complete covariate, low dose, etc.) ------------

do "$dofiles/analysis_cohorts.do"

* Run analyses on dementia subtype outcomes ------------------------------------

do "$dofiles/analysis_subtypes.do"

* Run analyses of drug vs drug (not included in paper)  ------------------------

* do "$dofiles/analysis_refclasses.do"

* Run multiple imputation and repeat logistic regression analyses --------------

do "$dofiles/multiple_imputation.do"

* Generate Table 1 -------------------------------------------------------------

do "$dofiles/table1.do"
do "$dofiles/table1_fiveplus.do"

* Generate bias plot -----------------------------------------------------------

do "$dofiles/bias_component_plots.do"

* Save analysis dataset --------------------------------------------------------

use "$data/analysis.dta", clear
outsheet using "$output/analysisdta.csv", comma replace

* Adjust based on bias scatter -------------------------------------------------

do "$dofiles/analysis_adj_mi.do"

* Format eTables ---------------------------------------------------------------

do "$dofiles/eTables_preparedata.do"
do "$dofiles/eTables_preparedata_adj.do"
do "$dofiles/eTables_preparedata_cohorts.do"
do "$dofiles/eTables_preparedata_subtypes.do"
do "$dofiles/eTables_preparedata_imputed.do"
do "$dofiles/eTables_preparedata_completecase.do"
do "$dofiles/eTables_excelexport.do"

* Convert relative risks to expected cases as described in eText 5 -------------

do "$dofiles/func_RR2EC.do"
RR2EC "ht_arb" 0.55 0.49 0.62
RR2EC "ht_ccb" 0.81 0.75 0.87

log off
