forval i = 1/5 {

	* Load analysis data

	use "$data/regresults.dta", clear

	* Restrict to main effects

	keep if var=="exposure" | var=="outcome:exposure" | var=="instrument" 

	* Exponeniate coefficents

	replace coef = cond(var=="outcome:exposure",exp(coef),coef)
	replace ci_lower = cond(var=="outcome:exposure",exp(ci_lower),ci_lower)
	replace ci_upper = cond(var=="outcome:exposure",exp(ci_upper),ci_upper)

	* Tidy dataset

	keep analysis outcome treat_int treat_ref cohort sample_size coef stderr pval Fstat endog endogp
	order analysis outcome treat_int treat_ref sample_size coef stderr pval Fstat endog endogp

	* Restrict to cohort of interest

	keep if cohort==`i' & outcome!="death"

	* Prepare data for reshape

	drop cohort
	replace Fstat = . if analysis=="ins_exp"
	replace analysis = cond(analysis=="ins_exp","first",analysis)

	foreach var of varlist coef stderr pval Fstat endog endogp {
		rename `var' `var'_
	}

	* Reshape data from long to wide

	reshape wide coef_ stderr_ pval_ Fstat_ endog_ endogp_, i(treat_int treat_ref outcome sample_size) j(analysis) string
	
	* Tidy new dataset

	rename endog_iv endog
	rename endogp_iv endogp
	
	drop endog_first endogp_first
	drop endog_iv_bin endogp_iv_bin
	drop endog_iv_fe endogp_iv_fe
	drop endog_iv_adj endogp_iv_adj
	
	order outcome treat_int treat_ref sample_size coef_iv stderr_iv pval_iv Fstat_iv endog endogp *_first *_bin *_adj *_fe
	
	if `i'==2 { 
		drop Fstat_logit endog_logit endogp_logit
		order outcome treat_int treat_ref sample_size coef_iv stderr_iv pval_iv Fstat_iv endog endogp *_logit *_first *_bin *_adj *_fe
	}

	* Recode outcomes
	
	replace outcome = "Probable Alzheimer's disease" if outcome == "dem_adprob"
	replace outcome = "Possible Alzheimer's disease" if outcome == "dem_adposs"
	replace outcome = "Vascular dementia" if outcome == "dem_vas"
	replace outcome = "Other dementias" if outcome == "dem_oth"
	replace outcome = "Any dementia" if outcome == "dem_any"
	
	* Recode treatments of interest
	
	replace treat_int = "Alpha-adrenoceptor blockers" if treat_int == "ht_aab"
    replace treat_int = "Angiotensin-converting enzyme inhibitors" if treat_int == "ht_ace"
    replace treat_int = "Angiotensin-II receptor blockers" if treat_int == "ht_arb"
    replace treat_int = "Beta-adrenoceptor blockers" if treat_int == "ht_bab"
    replace treat_int = "Calcium channel blockers" if treat_int ==  "ht_ccb"
    replace treat_int = "Diuretics" if treat_int == "ht_diu"
    replace treat_int = "Vasodilator antihypertensives" if treat_int == "ht_vad"

	* Recode treatments of interest
	
	replace treat_ref = "Alpha-adrenoceptor blockers" if treat_ref == "ht_aab"
    replace treat_ref = "Angiotensin-converting enzyme inhibitors" if treat_ref == "ht_ace"
    replace treat_ref = "Angiotensin-II receptor blockers" if treat_ref == "ht_arb"
    replace treat_ref = "Beta-adrenoceptor blockers" if treat_ref == "ht_bab"
    replace treat_ref = "Calcium channel blockers" if treat_ref == "ht_ccb"
    replace treat_ref = "Diuretics" if treat_ref == "ht_diu"
    replace treat_ref = "Vasodilator antihypertensives" if treat_ref == "ht_vad"

	* Save new supplementary table

	export excel using "$output/analysis_reg_newformat.xlsx", first(var) sheet("Cohort`i'",replace)
		
}

