* Setup ------------------------------------------------------------------------

global path ""
global project ""
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

* Run reg analysis -------------------------------------------------------------

run "$dofiles/analysis.do"

* Generate Table 1 -------------------------------------------------------------

run "$dofiles/table1.do"

* Generate bias plot -----------------------------------------------------------

run "$dofiles/bias_scatter.do"

* Save analysis dataset --------------------------------------------------------

use "$data/analysis.dta", clear
outsheet using "$output/analysisdta.csv", comma replace

* Adjust based on bias scatter -------------------------------------------------

run "$dofiles/analysis_adj.do"

* Format eTables ---------------------------------------------------------------

run "$dofiles/etables_preparedata.do"
run "$dofiles/etables_preparedata_adj.do"
run "$dofiles/etables_excelexport.do"

* Convert relative risks to expected cases as described in eText 5 -------------

run "$dofiles/func_RR2EC.do"
RR2EC "ht_arb" 0.55 0.49 0.62
RR2EC "ht_ccb" 0.81 0.75 0.87
