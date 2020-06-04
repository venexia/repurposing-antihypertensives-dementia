* Create empty results matrix --------------------------------------------------

clear
set obs 0
gen analysis = ""
save "$data/bias.dta", replace

foreach j in $ht_paper {

	* Load master data ---------------------------------------------------------

	use "$data/data-cohort1-dementia-`j'.dta", replace

	* Add smoking and drinking summary variables -----------------------------------

	gen never_smoke = cond(smoking==3,1,0)
	replace never_smoke = . if smoking == .
		
	gen never_drink = cond(alcohol==3,1,0)
	replace never_drink = . if alcohol == .
	
	* Restrict to relevant variables -------------------------------------------

	keep patid index_staff instrument exposure male index_age_start cad cbs cvd bmi charlson imd2010 cons_rate never_smoke never_drink pres_year_*
	
	* Perform multiple imputation ----------------------------------------------

	mi set mlong
	order never_smoke never_drink bmi imd2010
	ice instrument exposure male index_age_start cad cbs cvd charlson cons_rate pres_year_* o.never_smoke o.never_drink bmi o.imd2010, saving($data/bias-cohort1-dementia-`j'_imputed_1, replace) m(20) seed(12345) 

 	* Descrbe imputed dataset --------------------------------------------------

	use "$data/bias-cohort1-dementia-`j'_imputed_1.dta", clear
	mi unset
	mi import ice, automatic clear 
	mi register regular patid instrument exposure male index_age_start cad cbs cvd charlson cons_rate pres_year_*
	mi describe

	* Save imputed dataset -----------------------------------------------------

	save "$data/bias-cohort1-dementia-`j'_imputed.dta",replace

	* Use imputed dataset ------------------------------------------------------

	use "$data/bias-cohort1-dementia-`j'_imputed.dta", clear

	* Perform analysis using imputed dataset -----------------------------------
	
	local cov_bin "male cad cbs cvd never_smoke never_drink"
	local cov_con "index_age_start bmi charlson imd2010 cons_rate"	

	foreach x in `cov_bin' `cov_con' {
		mi estimate : reg `x' exposure pres_year_*, cluster(index_staff)
		regsave using "$data/bias.dta", pval ci addlabel(analysis, "lin", cov, "`x'", exposure, "`j'", outcome, "dementia") append
		mi estimate : reg `x' instrument pres_year_*, cluster(index_staff)
		regsave using "$data/bias.dta", pval ci addlabel(analysis, "iv", cov, "`x'", exposure, "`j'", outcome, "dementia") append

	}		

}

use "$data/bias.dta",clear
keep if var=="exposure" | var=="instrument"
keep exposure outcome cov coef ci_lower ci_upper analysis
outsheet using "$output/bias_scatter.csv", comma replace
