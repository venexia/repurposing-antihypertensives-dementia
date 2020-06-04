// WHOLE SAMPLE

use "$data/analysis.dta", clear

keep patid index_date $ht_cov drug5

gen t1_exposed = _N

gen index_year = year(index_date)

egen t1_year = median(index_year)

egen t1_age = median(index_age_start)

egen t1_sex = total(male)

egen t1_cad = total(cad)

egen t1_cbs = total(cbs)
 
egen t1_cvd = total(cvd)

egen t1_bmi = mean(bmi)

egen t1_bmi_sd = sd(bmi)

gen charlson_ever = cond(charlson>0,1,0)

egen t1_charlson = total(charlson_ever)

egen t1_imd2010 = median(imd2010)

egen t1_cons_rate = mean(cons_rate)

egen t1_cons_rate_sd = sd(cons_rate)

gen smoking_ever = cond(smoking==3,0,1)

egen t1_smoking = total(smoking_ever)

gen alcohol_ever = cond(alcohol==3,0,1)

egen t1_alcohol = total(alcohol_ever)

egen t1_drug5 = total(drug5)

keep t1*

duplicates drop

gen index_drug = "Whole Sample"

save "$data/table1_wholesample.dta", replace

// BY INDEX DRUG

use "$data/analysis.dta", clear

keep patid index_date index_drug $ht_cov drug5

egen t1_exposed = count(index_drug), by(index_drug)

gen index_year = year(index_date)

egen t1_year = median(index_year), by(index_drug)

egen t1_age = median(index_age_start), by(index_drug)

egen t1_sex = total(male), by(index_drug)

egen t1_cad = total(cad), by(index_drug) 

egen t1_cbs = total(cbs), by(index_drug) 
 
egen t1_cvd = total(cvd), by(index_drug) 

egen t1_bmi = mean(bmi), by(index_drug)

egen t1_bmi_sd = sd(bmi), by(index_drug)

gen charlson_ever = cond(charlson>0,1,0)

egen t1_charlson = total(charlson_ever), by(index_drug)

egen t1_imd2010 = median(imd2010), by(index_drug)

egen t1_cons_rate = mean(cons_rate), by(index_drug)

egen t1_cons_rate_sd = sd(cons_rate), by(index_drug)

gen smoking_ever = cond(smoking==3,0,1)

egen t1_smoking = total(smoking_ever), by(index_drug) 

gen alcohol_ever = cond(alcohol==3,0,1)

egen t1_alcohol = total(alcohol_ever), by(index_drug)

egen t1_drug5 = total(drug5), by(index_drug)

keep index_drug t1*

duplicates drop

append using "$data/table1_wholesample.dta"

replace index_drug = "Alpha-adrenoceptor blockers" if index_drug=="ht_aab"
replace index_drug = "Angiotensin-converting enzyme inhibitors" if index_drug=="ht_ace"
replace index_drug = "Angiotensin-II receptor blockers" if index_drug=="ht_arb"
replace index_drug = "Beta-adrenoceptor blockers" if index_drug=="ht_bab"
replace index_drug = "Calcium channel blockers" if index_drug=="ht_ccb"
replace index_drug = "Diuretics" if index_drug=="ht_diu"
replace index_drug = "Vasodilator antihypertensives" if index_drug=="ht_vad"
sort index_drug

rename t1_exposed N

rename t1_year year

gen sex = string(round(100*(t1_sex/N),0.1),"%3.1f") + "% (" + string(t1_sex,"%3.0f") + ")"

rename t1_age age

gen cad = string(round(100*(t1_cad/N),0.1),"%3.1f") + "% (" + string(t1_cad,"%3.0f") + ")"

gen cbs = string(round(100*(t1_cbs/N),0.1),"%3.1f") + "% (" + string(t1_cbs,"%3.0f") + ")"

gen cvd = string(round(100*(t1_cvd/N),0.1),"%3.1f") + "% (" + string(t1_cvd,"%3.0f") + ")"

gen charlson = string(round(100*(t1_charlson/N),0.1),"%3.1f") + "% (" + string(t1_charlson,"%3.0f") + ")"

rename t1_imd2010 imd

gen cons_rate = string(round(t1_cons_rate,0.1),"%3.1f") + " (" + string(round(t1_cons_rate_sd,0.1),"%3.1f") + ")"

gen alcohol = string(round(100*(t1_alcohol/N),0.1),"%3.1f") + "% (" + string(t1_alcohol,"%3.0f") + ")"

gen smoking =string(round(100*(t1_smoking/N),0.1),"%3.1f") + "% (" + string(t1_smoking,"%3.0f") + ")"

gen bmi = string(round(t1_bmi,0.1),"%3.1f") + " (" + string(round(t1_bmi_sd,0.1),"%3.1f") + ")"

gen drug5 = string(round(100*(t1_drug5/N),0.1),"%3.1f") + "% (" + string(t1_drug5,"%3.0f") + ")"

drop t1_*

order index_drug N year sex age cad cbs cvd charlson imd cons_rate alcohol smoking bmi drug5

outsheet using "$output/table1.csv", comma replace
