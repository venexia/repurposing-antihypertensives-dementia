clear
set obs 0
gen analysis = ""
save "$data/bias.dta", replace

foreach j in $ht_paper {

	use "$data/analysis/data-cohort2-dementia-`j'.dta",clear

	* Add smoking and drinking summary variables -----------------------------------

	gen never_smoke = cond(smoking==3,1,0)
	gen never_drink = cond(alcohol==3,1,0)

	* Save estimates for each covariate --------------------------------------------

	local cov_bin "male cad cbs cvd never_smoke never_drink"
	local cov_con "index_age_start bmi charlson imd2010 cons_rate"	

	foreach x in `cov_bin' `cov_con' {
		reg `x' exposure pres_year_*, cluster(index_staff)
		regsave using "$data/bias.dta", pval ci addlabel(analysis, "lin", cov, "`x'", exposure, "`j'", outcome, "dementia") append
		ivreg2 `x' (exposure=instrument) pres_year_*, robust ffirst cluster(index_staff) partial(pres_year_*)
		regsave using "$data/bias.dta", pval ci addlabel(analysis, "iv", cov, "`x'", exposure, "`j'", outcome, "dementia") append
	}			
	
}

use "$data/bias.dta",clear
keep if var=="exposure"
keep exposure outcome cov coef ci_lower ci_upper analysis
outsheet using "$output/bias_scatter.csv", comma replace
