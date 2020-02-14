* Load analysis data

use "$data/regresults.dta", clear

* Restrict to main effects

keep if var=="exposure" | var=="outcome:exposure" | var=="instrument" 

* Exponeniate coefficents

replace coef = cond(var=="outcome:exposure",exp(coef),coef)
replace ci_lower = cond(var=="outcome:exposure",exp(ci_lower),ci_lower)
replace ci_upper = cond(var=="outcome:exposure",exp(ci_upper),ci_upper)

* Tidy dataset

keep cohort analysis exposure outcome cohort sample_size coef stderr pval Fstat endog endogp Hansen Hansenp
order cohort analysis exposure outcome sample_size coef stderr pval Fstat endog endogp Hansen Hansenp

* Prepare data for reshape

replace Fstat = . if analysis=="ins_exp"
replace analysis = cond(analysis=="ins_exp","first",analysis)

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

save "$data/etable.dta", replace
