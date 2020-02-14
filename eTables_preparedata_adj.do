* Load analysis data

use "$data/regresults_adj.dta", clear

* Restrict to main effects

keep if var=="exposure" | var=="outcome:exposure" | var=="instrument" 

* Exponeniate coefficents

replace coef = cond(var=="outcome:exposure",exp(coef),coef)
replace ci_lower = cond(var=="outcome:exposure",exp(ci_lower),ci_lower)
replace ci_upper = cond(var=="outcome:exposure",exp(ci_upper),ci_upper)

* Tidy dataset

keep adj exposure outcome N coef stderr pval Fstat endog endogp
order adj exposure outcome N coef stderr pval Fstat endog endogp
rename N sample_size
rename adj adjustment
replace adjustment = subinstr(adjustment, " ", "", .)

* Recode adjustments

replace adjustment = "Age at index" if adjustment == "index_age_start"
replace adjustment = "Alcohol status" if adjustment == "alcohol"
replace adjustment = "Annual consultation rate" if adjustment == "cons_rate" 
replace adjustment = "Body mass index" if adjustment == "bmi"
replace adjustment = "Cardiovascular disease" if adjustment == "cvd" 
replace adjustment = "Chronic disease" if adjustment == "charlson"
replace adjustment = "Coronary artery disease" if adjustment == "cad"
replace adjustment = "Coronary bypass surgery" if adjustment == "cbs"
replace adjustment = "Sex" if adjustment == "male"
replace adjustment = "Smoking status" if adjustment == "smoking"
replace adjustment = "Socioeconomic position" if adjustment == "imd2010"

* Recode outcomes

replace outcome = "Dementia" if outcome == "dementia"

* Recode treatments of interest

replace exposure = "Alpha-adrenoceptor blockers" if exposure == "ht_aab"
replace exposure = "Angiotensin-converting enzyme inhibitors" if exposure == "ht_ace"
replace exposure = "Angiotensin-II receptor blockers" if exposure == "ht_arb"
replace exposure = "Beta-adrenoceptor blockers" if exposure == "ht_bab"
replace exposure = "Calcium channel blockers" if exposure ==  "ht_ccb"
replace exposure = "Diuretics" if exposure == "ht_diu"
replace exposure = "Vasodilator antihypertensives" if exposure == "ht_vad"

save "$data/etable_adj.dta", replace
