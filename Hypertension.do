* Setup ------------------------------------------------------------------------

global path "E:/Dementia_CPRD_v2"
global project "$path/projects/AntihypertensivesIV"
global dofiles "$project/code"
global output "$project/output"
global data "$project/data"
cd $project
run "$path/dofiles/codedict.do"

* Define covariates to be retained in all files --------------------------------

global ht_basic "patid pracid gender region yob frd crd uts tod lcd deathdate fup accept data_* diagnosis* index_* cont_*_date drug5 drug10 drug_fup male pres_year_*"
global ht_cov "male index_age_start cad cbs cvd bmi charlson imd2010 cons_rate smoking alcohol"

/*
* Generate missing patlists ---------------------------------------------

use "$path/data/eventlists/eventlist_ht_psd.dta", clear
append using "$path/data/eventlists/eventlist_ht_thi.dta"
save "$path/data/eventlists/eventlist_ht_diu.dta", replace
egen index_count = count(patid), by(patid)
egen min_date = min(index_date), by(patid)
format %td min_date
keep patid index_count min_date
rename min_date index_date
duplicates drop *, force
save "$path/data/patlists/patlist_`event'.dta", replace
*/

* Generate cohort --------------------------------------------------------------

run "$dofiles/cohort.do"

* Add covariates (Note: cov.do requires cov_*.do) ------------------------------

run "$dofiles/cov.do"

* Run analyses on outcome 'dementia' -------------------------------------------

run "$dofiles/analysis.do"

* Run analyses on cohorts (e.g. complete covariate, low dose, etc.) ------------

run "$dofiles/analysis_cohorts.do"

* Run analyses on dementia subtype outcomes ------------------------------------

run "$dofiles/analysis_subtypes.do"

* Run analyses of drug vs drug (not included in paper)  ------------------------

* run "$dofiles/analysis_refclasses.do"

* Run multiple imputation and repeat logistic regression analyses --------------

run "$dofiles/multiple_imputation.do"

* Generate Table 1 -------------------------------------------------------------

run "$dofiles/table1.do"
run "$dofiles/table1_fiveplus.do"

* Generate bias plot -----------------------------------------------------------

run "$dofiles/bias_component_plots.do"

* Save analysis dataset --------------------------------------------------------

use "$data/analysis.dta", clear
outsheet using "$output/analysisdta.csv", comma replace

* Adjust based on bias scatter -------------------------------------------------

run "$dofiles/analysis_adj_mi.do"

* Format eTables ---------------------------------------------------------------

run "$dofiles/eTables_preparedata.do"
run "$dofiles/eTables_preparedata_adj.do"
run "$dofiles/eTables_preparedata_cohorts.do"
run "$dofiles/eTables_preparedata_subtypes.do"
run "$dofiles/eTables_preparedata_imputed.do"
run "$dofiles/eTables_excelexport.do"

* Convert relative risks to expected cases as described in eText 5 -------------

run "$dofiles/func_RR2EC.do"
RR2EC "ht_arb" 0.55 0.49 0.62
RR2EC "ht_ccb" 0.81 0.75 0.87
