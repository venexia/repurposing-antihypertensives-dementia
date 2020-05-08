* Create empty results matrix --------------------------------------------------

clear
set obs 0
gen analysis = ""
save "$data/regresults_imputed.dta", replace

foreach j in $ht_paper {

	* Load master data ---------------------------------------------------------

	use "$data/analysis/data-cohort1-dementia-`j'.dta", replace

	* Restrict to relevant variables -------------------------------------------

	keep patid index_staff outcome exposure male instrument index_age_start cad cbs cvd bmi charlson imd2010 cons_rate smoking alcohol pres_year_*

	* Perform multiple imputation ----------------------------------------------

	mi set mlong
	order smoking alcohol bmi imd2010
	ice outcome exposure instrument male index_age_start cad cbs cvd charlson cons_rate pres_year_* o.smoking o.alcohol bmi o.imd2010, saving($data/mi/data-cohort1-dementia-`j'_imputed_1, replace) m(20) seed(12345) 

	* Descrbe imputed dataset --------------------------------------------------

	use "$data/mi/data-cohort1-dementia-`j'_imputed_1.dta", clear
	mi unset
	mi import ice, automatic clear 
	mi register regular patid outcome exposure instrument male index_age_start cad cbs cvd charlson cons_rate pres_year_*
	mi describe

	* Save imputed dataset -----------------------------------------------------

	save "$data/mi/data-cohort1-dementia-`j'_imputed.dta",replace

	* Use imputed dataset ------------------------------------------------------

	use "$data/mi/data-cohort1-dementia-`j'_imputed.dta", clear

	* Perform analysis using imputed dataset -----------------------------------

	mi estimate, or: logistic outcome exposure $ht_cov pres_year_*, cluster(index_staff)
	
	local N = e(N)
			
	#delimit ;
	regsave using "$data/regresults_imputed.dta", 
	pval ci addlabel(analysis, "logit_imputed", outcome, "dementia", exposure, "`j'", sample_size, "`N'"
	) append;
	#delimit cr

}




