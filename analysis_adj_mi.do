* Create empty results matrix --------------------------------------------------

clear
set obs 0
gen analysis = ""
save "$data/regresults_adj_mi.dta", replace

foreach j in $ht_paper {

	forvalues i = 1(1)20 {

		* Use imputed dataset --------------------------------------------------

		use "$data/mi/data-cohort1-dementia-`j'_imputed.dta", clear

		* Restrict to imputation dataset i ------------------------------------

		keep if _mi_m == `i'

		* Count exposure-outcome combinations ----------------------------------

		local N = _N
		count if exposure == 0 & outcome == 0
		local X0Y0 = r(N)			
		count if exposure == 1 & outcome == 0
		local X1Y0 = r(N)
		count if exposure == 0 & outcome == 1
		local X0Y1 = r(N)
		count if exposure == 1 & outcome == 1
		local X1Y1 = r(N)

		foreach z in $ht_cov {

			* Perform IV analysis ----------------------------------------------

			ivreg2 outcome (exposure=instrument) pres_year_* `z', robust ffirst cluster(index_staff) partial(pres_year_*) endog(exposure)

			* Save results -----------------------------------------------------
			
			local endog = e(estat)
			local endogp = e(estatp)
			local Fstat = e(cdf) // Cragg-Donald Wald F statistic

			#delimit ;
			regsave using "$data/regresults_adj_mi.dta", 
			pval ci addlabel(analysis, "iv", Fstat, `Fstat', endog, `endog', endogp, `endogp',
			outcome, "dementia", exposure, "`j'", cohort, "1", 
			ex_start, `ex_start', ex_drug, `ex_drug', ex_diag, `ex_diag', ex_staff0, `ex_staff0',
			X0Y0, `X0Y0', X1Y0, `X1Y0', X0Y1, `X0Y1', X1Y1, `X1Y1', adj, `z', imputation, `i'
			) append;
			#delimit cr	

		}

	}
}

use "$data/regresults_adj_mi.dta", clear
keep if var=="exposure"
keep imputation analysis outcome exposure cohort coef stderr pval ci_lower ci_upper Fstat endog endogp N X0Y0 X1Y0 X0Y1 X1Y1 adj
order imputation analysis outcome exposure adj coef stderr pval ci_lower ci_upper Fstat endog endogp N X0Y0 X1Y0 X0Y1 X1Y1 
outsheet using "$output/analysis_reg_adj_mi.csv", comma replace
