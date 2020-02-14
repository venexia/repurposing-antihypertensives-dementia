* Load analysis data

use "$data/regresults_cohorts.dta", clear

* Restrict to main effects

keep if var=="exposure" | var=="outcome:exposure" | var=="instrument" 

* Exponeniate coefficents

replace coef = cond(var=="outcome:exposure",exp(coef),coef)
replace ci_lower = cond(var=="outcome:exposure",exp(ci_lower),ci_lower)
replace ci_upper = cond(var=="outcome:exposure",exp(ci_upper),ci_upper)

* Tidy dataset

keep cohort analysis exposure outcome cohort sample_size coef stderr pval Fstat endog endogp
order cohort analysis exposure outcome sample_size coef stderr pval Fstat endog endogp

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

* Add other results and annotate sensitivity analyses

gen sensitivity = ""
replace sensitivity = "Analysis excluding individuals with anxiety" if cohort==3 & analysis=="iv"
replace sensitivity = "Analysis excluding individuals on low doses" if cohort==4 & analysis=="iv"
replace sensitivity = "Analysis excluding individuals less than 55 years old" if cohort==5 & analysis=="iv"
replace sensitivity = "Main analysis" if cohort==1 & analysis=="iv"

append using "data/etable.dta"
replace sensitivity = "Analyis adjusted for age and socioeconomic position" if cohort==1 & analysis=="iv_adj"
replace sensitivity = "Analysis with fixed effects" if cohort==1 & analysis=="iv_fe"

* Save

save "$data/etable_cohorts.dta", replace
