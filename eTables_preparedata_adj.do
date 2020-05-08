* Load analysis data

use "$data/regresults_adj_mi.dta", clear

* Restrict to main effects

keep if var=="exposure" 

* Tidy dataset

keep adj exposure outcome N coef stderr pval Fstat endog endogp
order adj exposure outcome N coef stderr pval Fstat endog endogp
rename N sample_size
rename adj adjustment
rename coef coef_imp
rename stderr stderr_imp
replace adjustment = subinstr(adjustment, " ", "", .)

* Pool estimates

bysort adj exposure outcome : egen coef = mean(coef_imp)
bysort adj exposure outcome : egen v_w = mean(stderr_imp^2)

gen v_b_tmp = (coef_imp - coef)^2

bysort adj exposure outcome : egen v_b = sum(v_b_tmp)

replace v_b = v_b/(20-1)

gen stderr = sqrt(v_w + v_b + (v_b/20))

keep adjustment exposure outcome sample_size coef stderr
order adjustment exposure outcome sample_size coef stderr

duplicates drop

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
