* Load analysis data

use "$data/regresults_imputed.dta", clear

* Restrict to main effects

keep if var=="outcome:exposure" 

* Convert beta to odds ratio

replace coef = exp(coef)

* Tidy dataset

keep exposure outcome sample_size coef stderr pval
order exposure outcome sample_size coef stderr pval 

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

save "$data/etable_imputed.dta", replace
