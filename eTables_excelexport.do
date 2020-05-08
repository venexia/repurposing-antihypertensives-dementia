* CREATE ETABLE01 - EXPOSURE BY AGE AND SEX ====================================

use "$data/analysis.dta", clear
keep patid index_age_start index_drug male
gen age_grp = floor(index_age_start/10)
replace age_grp = 10 if age_grp>9

bysort index_drug age_grp male: egen x = count(patid)
keep index_drug age_grp male x
duplicates drop
reshape wide x, i(index_drug male) j(age_grp)

replace index_drug = "Alpha-adrenoceptor blockers" if index_drug == "ht_aab"
replace index_drug = "Angiotensin-converting enzyme inhibitors" if index_drug == "ht_ace"
replace index_drug = "Angiotensin-II receptor blockers" if index_drug == "ht_arb"
replace index_drug = "Beta-adrenoceptor blockers" if index_drug == "ht_bab"
replace index_drug = "Calcium channel blockers" if index_drug ==  "ht_ccb"
replace index_drug = "Diuretics" if index_drug == "ht_diu"
replace index_drug = "Vasodilator antihypertensives" if index_drug == "ht_vad"

gen sex = cond(male==1,"Men","Women")
drop male

replace x10 = 0 if x10==.

rename x4 age_40_49
rename x5 age_50_59
rename x6 age_60_69
rename x7 age_70_79
rename x8 age_80_89
rename x9 age_90_99
rename x10 age_100_plus

order index_drug sex
export excel using "$output/etables.xlsx", first(var) sheet("eTable01",replace)

* CREATE ETABLE02 - INSTRUMENT_EXPOSURE ESTIMATES ==============================

use "$data/etable.dta", clear
keep if cohort==1 & analysis=="first"
keep exposure outcome sample_size coef stderr pval
export excel using "$output/etables.xlsx", first(var) sheet("eTable02",replace)

* CREATE ETABLE03 - BONETS IV INEQUALITIES =====================================

** Performed in R (see script 'table_bonet.R')

* CREATE ETABLE04 - MAIN RESULTS ===============================================

use "$data/etable.dta", clear
keep if cohort==1 & analysis=="iv"
keep exposure outcome sample_size coef stderr pval Fstat endog endogp
export excel using "$output/etables.xlsx", first(var) sheet("eTable04",replace)

* CREATE ETABLE05 - MULTIVARIABLE REGRESSION RESULTS ===========================

use "$data/etable_imputed.dta", clear
keep exposure outcome sample_size coef stderr pval
export excel using "$output/etables.xlsx", first(var) sheet("eTable05",replace)

// * CREATE ETABLEXX - COMPLETE CASE IV RESULTS ===================================
//
// use "$data/etable_cohorts.dta", clear
// keep if cohort==2 & analysis=="iv"
// keep exposure outcome sample_size coef stderr pval Fstat endog endogp
// export excel using "$output/etables.xlsx", first(var) sheet("eTableXX",replace)

* CREATE ETABLE06 - IV ADJUSTMENTS IN EFIGURE 8 ================================

use "$data/etable_adj.dta", clear
keep adjustment exposure outcome sample_size coef stderr
export excel using "$output/etables.xlsx", first(var) sheet("eTable06",replace)

* CREATE ETABLE07 - IV SUBTYPES IN EFIGURE 9 ===================================

use "$data/etable_subtypes.dta", clear
keep exposure outcome sample_size coef stderr pval Fstat endog endogp
export excel using "$output/etables.xlsx", first(var) sheet("eTable07",replace)

* CREATE ETABLE08 - IV SENSITIVITY ANALYSES ====================================

use "$data/etable_cohorts.dta", clear
drop if sensitivity==""
keep sensitivity exposure outcome sample_size coef stderr pval Fstat endog endogp
order sensitivity exposure outcome sample_size coef stderr pval Fstat endog endogp
export excel using "$output/etables.xlsx", first(var) sheet("eTable08",replace)

* Create ETABLE09 - SARGAN-HANSEN TEST RESULTS =================================

use "$data/etable.dta", clear
keep if cohort==1 & analysis=="iv_oi"
keep exposure outcome sample_size coef stderr pval Fstat endog endogp Hansen Hansenp
export excel using "$output/etables.xlsx", first(var) sheet("eTable09",replace)
