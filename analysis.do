* Create empty results matrix --------------------------------------------------

clear
set obs 0
gen analysis = ""
save "$data/regresults.dta", replace

* Define cases and controls for all outcomes -----------------------------------

forval k  = 1/4 {
	local case`k' = "diagnosis_dem==`k'"
	local cont`k' = "diagnosis_dem==0"
	local out`k' = "`: word `k' of $dem_diag'"
}

local case5 = "diagnosis_dem>0"
local cont5 = "diagnosis_dem==0"
local out5 = "dem_any"

/*
local case6 = "!missing(deathdate)"
local cont6 = "missing(deathdate)"
local out6 = "death"


   local j = 6
   foreach k in lice uti scabies {
   local j = `j' + 1
   local case`j' = "!missing(cont_`k'_date)"
   local cont`j' = "missing(cont_`k'_date)"
   local out`j' = "`k'"
   }
*/

* Conduct analysis -------------------------------------------------------------

local c = 0

forval x = 1/5 {

	forval y = 1/5 {
	
		foreach i in $ht_paper {

			foreach j in $ht_paper {
						
				if "`i'" != "`j'" {

				local c = `c' + 1

				noi di "$S_TIME : Starting analysis `c' of 1050" // x*y*length(ht_paper)*((length(ht_paper)-1) = 1050

				qui {
				
					* Load master data -----------------------------------------

					use "$data/analysis.dta", clear
					
					keep if cohort`x' == 1

					local ex_start = _N

					* Define exposed-unexposed ---------------------------------

					keep if inlist(index_drug,"`i'","`j'")

					local ex_drug = _N

					gen exposure = cond(index_drug == "`j'",1,0)
					label define exposure 1 "int" 0 "ref"
					label values exposure exposure
					gen treat_int = "`j'"
					gen treat_ref = "`i'"

					* Define case-control --------------------------------------

					if `y'<5 {
						keep if `case`y'' | `cont`y''
					}
					gen outcome = cond(`case`y'',1,0)
					label define outcome 1 "case" 0 "control"
					label values outcome outcome

					local ex_diag = _N

					* Tidy data ------------------------------------------------

					keep patid pracid gender region data_* outcome exposure index_* pres_year_* $ht_cov

					* Remove staffid = 0 ---------------------------------------

					drop if index_staff==0

					local ex_staff0 = _N

					* Add instrument -------------------------------------------

					sort index_staff index_date index_consid
					forval k = 1/7 {
						by index_staff : gen inst_`k' = exposure[_n-`k']
						by index_staff : gen imd2010_`k' = imd2010[_n-`k']
						by index_staff : gen age_`k' = index_age_start[_n-`k']
					}
					by index_staff: egen staffseq = seq()
					drop if staffseq<8
					egen instrument = rowtotal(inst_*)
					egen instrument_imd = rowmean(imd2010_*)
					egen instrument_age = rowmean(age_*)
					drop inst_* imd2010_* age_* staffseq
					gen instrument_bin = cond(instrument<2,0,1)

					save "$data/analysis/data-cohort`x'-`out`y''-`i'-`j'.dta", replace

					local sample_size = _N
					
					count if exposure == 0 & outcome == 0
					local X0Y0 = r(N)			
					count if exposure == 1 & outcome == 0
					local X1Y0 = r(N)
					count if exposure == 0 & outcome == 1
					local X0Y1 = r(N)
					count if exposure == 1 & outcome == 1
					local X1Y1 = r(N)

						forval z = 0/7 {
						
							count if exposure == 0 & instrument == `z'
							local Z`z'X0 = r(N)
							count if exposure == 1 & instrument == `z'
							local Z`z'X1 = r(N)
							count if outcome == 0 & instrument == `z'
							local Z`z'Y0 = r(N)
							count if outcome == 1 & instrument == `z'
							local Z`z'Y1 = r(N)
							
							count if exposure == 0 & outcome==0 & instrument == `z'
							local Z`z'X0Y0 = r(N)
							count if exposure == 0 & outcome==1 & instrument == `z'
							local Z`z'X0Y1 = r(N)
							count if exposure == 1 & outcome == 0 & instrument == `z'
							local Z`z'X1Y0 = r(N)
							count if exposure == 1 & outcome == 1 & instrument == `z'
							local Z`z'X1Y1 = r(N)
							
						}					

					* Perform IV analysis --------------------------------------

					ivreg2 outcome (exposure=instrument) pres_year_*, robust ffirst cluster(index_staff) partial(pres_year_*) endog(exposure)

					local endog = e(estat)
					local endogp = e(estatp)
					local Fstat = e(cdf) // Cragg-Donald Wald F statistic

					#delimit ;
					regsave using "$data/regresults.dta", 
					pval ci addlabel(analysis, "iv", Fstat, `Fstat', endog, `endog', endogp, `endogp', 
					outcome, `out`y'', treat_int, `j', treat_ref, `i', cohort,`x', 
					ex_start, `ex_start', ex_drug, `ex_drug', ex_diag, `ex_diag', ex_staff0, `ex_staff0',
					X0Y0, `X0Y0', X1Y0, `X1Y0', X0Y1, `X0Y1', X1Y1, `X1Y1',
					Z0X0, `Z0X0', Z1X0, `Z1X0', Z2X0, `Z2X0', Z3X0, `Z3X0', Z4X0, `Z4X0', Z5X0, `Z5X0', Z6X0, `Z6X0', Z7X0, `Z7X0',
					Z0X1, `Z0X1', Z1X1, `Z1X1', Z2X1, `Z2X1', Z3X1, `Z3X1', Z4X1, `Z4X1', Z5X1, `Z5X1', Z6X1, `Z6X1', Z7X1, `Z7X1',
					Z0Y0, `Z0Y0', Z1Y0, `Z1Y0', Z2Y0, `Z2Y0', Z3Y0, `Z3Y0', Z4Y0, `Z4Y0', Z5Y0, `Z5Y0', Z6Y0, `Z6Y0', Z7Y0, `Z7Y0',
					Z0Y1, `Z0Y1', Z1Y1, `Z1Y1', Z2Y1, `Z2Y1', Z3Y1, `Z3Y1', Z4Y1, `Z4Y1', Z5Y1, `Z5Y1', Z6Y1, `Z6Y1', Z7Y1, `Z7Y1',
					Z0X0Y0, `Z0X0Y0', Z1X0Y0, `Z1X0Y0', Z2X0Y0, `Z2X0Y0', Z3X0Y0, `Z3X0Y0', Z4X0Y0, `Z4X0Y0', Z5X0Y0, `Z5X0Y0', Z6X0Y0, `Z6X0Y0', Z7X0Y0, `Z7X0Y0',
					Z0X0Y1, `Z0X0Y1', Z1X0Y1, `Z1X0Y1', Z2X0Y1, `Z2X0Y1', Z3X0Y1, `Z3X0Y1', Z4X0Y1, `Z4X0Y1', Z5X0Y1, `Z5X0Y1', Z6X0Y1, `Z6X0Y1', Z7X0Y1, `Z7X0Y1',
					Z0X1Y0, `Z0X1Y0', Z1X1Y0, `Z1X1Y0', Z2X1Y0, `Z2X1Y0', Z3X1Y0, `Z3X1Y0', Z4X1Y0, `Z4X1Y0', Z5X1Y0, `Z5X1Y0', Z6X1Y0, `Z6X1Y0', Z7X1Y0, `Z7X1Y0',
					Z0X1Y1, `Z0X1Y1', Z1X1Y1, `Z1X1Y1', Z2X1Y1, `Z2X1Y1', Z3X1Y1, `Z3X1Y1', Z4X1Y1, `Z4X1Y1', Z5X1Y1, `Z5X1Y1', Z6X1Y1, `Z6X1Y1', Z7X1Y1, `Z7X1Y1',
					sample_size, `sample_size'
					) append;
					#delimit cr	
					
					* Perform IV analysis with adjustments ---------------------
					
					ivreg2 outcome (exposure=instrument) pres_year_* instrument_age instrument_imd, robust ffirst cluster(index_staff) partial(pres_year_*) endog(exposure)

					local endog = e(estat)
					local endogp = e(estatp)
					local Fstat = e(cdf) // Cragg-Donald Wald F statistic

					#delimit ;
					regsave using "$data/regresults.dta", 
					pval ci addlabel(analysis, "iv_adj", Fstat, `Fstat', endog, `endog', endogp, `endogp', 
					outcome, `out`y'', treat_int, `j', treat_ref, `i', cohort,`x', 
					ex_start, `ex_start', ex_drug, `ex_drug', ex_diag, `ex_diag', ex_staff0, `ex_staff0',
					X0Y0, `X0Y0', X1Y0, `X1Y0', X0Y1, `X0Y1', X1Y1, `X1Y1', 
					Z0X0, `Z0X0', Z1X0, `Z1X0', Z2X0, `Z2X0', Z3X0, `Z3X0', Z4X0, `Z4X0', Z5X0, `Z5X0', Z6X0, `Z6X0', Z7X0, `Z7X0',
					Z0X1, `Z0X1', Z1X1, `Z1X1', Z2X1, `Z2X1', Z3X1, `Z3X1', Z4X1, `Z4X1', Z5X1, `Z5X1', Z6X1, `Z6X1', Z7X1, `Z7X1',
					Z0Y0, `Z0Y0', Z1Y0, `Z1Y0', Z2Y0, `Z2Y0', Z3Y0, `Z3Y0', Z4Y0, `Z4Y0', Z5Y0, `Z5Y0', Z6Y0, `Z6Y0', Z7Y0, `Z7Y0',
					Z0Y1, `Z0Y1', Z1Y1, `Z1Y1', Z2Y1, `Z2Y1', Z3Y1, `Z3Y1', Z4Y1, `Z4Y1', Z5Y1, `Z5Y1', Z6Y1, `Z6Y1', Z7Y1, `Z7Y1',
					Z0X0Y0, `Z0X0Y0', Z1X0Y0, `Z1X0Y0', Z2X0Y0, `Z2X0Y0', Z3X0Y0, `Z3X0Y0', Z4X0Y0, `Z4X0Y0', Z5X0Y0, `Z5X0Y0', Z6X0Y0, `Z6X0Y0', Z7X0Y0, `Z7X0Y0',
					Z0X0Y1, `Z0X0Y1', Z1X0Y1, `Z1X0Y1', Z2X0Y1, `Z2X0Y1', Z3X0Y1, `Z3X0Y1', Z4X0Y1, `Z4X0Y1', Z5X0Y1, `Z5X0Y1', Z6X0Y1, `Z6X0Y1', Z7X0Y1, `Z7X0Y1',
					Z0X1Y0, `Z0X1Y0', Z1X1Y0, `Z1X1Y0', Z2X1Y0, `Z2X1Y0', Z3X1Y0, `Z3X1Y0', Z4X1Y0, `Z4X1Y0', Z5X1Y0, `Z5X1Y0', Z6X1Y0, `Z6X1Y0', Z7X1Y0, `Z7X1Y0',
					Z0X1Y1, `Z0X1Y1', Z1X1Y1, `Z1X1Y1', Z2X1Y1, `Z2X1Y1', Z3X1Y1, `Z3X1Y1', Z4X1Y1, `Z4X1Y1', Z5X1Y1, `Z5X1Y1', Z6X1Y1, `Z6X1Y1', Z7X1Y1, `Z7X1Y1',
					sample_size, `sample_size'
					) append;
					#delimit cr	


					* Perform IV analysis with binary instrument ---------------
					
					tab instrument_bin
					local ins_bin_lev = r(r)
					
					if `ins_bin_lev'>1 {
					
					ivreg2 outcome (exposure=instrument_bin) pres_year_*, robust ffirst cluster(index_staff) partial(pres_year_*) endog(exposure)

					local endog = e(estat)
					local endogp = e(estatp)
					local Fstat = e(cdf) // Cragg-Donald Wald F statistic

					#delimit ;
					regsave using "$data/regresults.dta", 
					pval ci addlabel(analysis, "iv_bin", Fstat, `Fstat', endog, `endog', endogp, `endogp', 
					outcome, `out`y'', treat_int, `j', treat_ref, `i', cohort,`x', 
					ex_start, `ex_start', ex_drug, `ex_drug', ex_diag, `ex_diag', ex_staff0, `ex_staff0',
					X0Y0, `X0Y0', X1Y0, `X1Y0', X0Y1, `X0Y1', X1Y1, `X1Y1', 
					Z0X0, `Z0X0', Z1X0, `Z1X0', Z2X0, `Z2X0', Z3X0, `Z3X0', Z4X0, `Z4X0', Z5X0, `Z5X0', Z6X0, `Z6X0', Z7X0, `Z7X0',
					Z0X1, `Z0X1', Z1X1, `Z1X1', Z2X1, `Z2X1', Z3X1, `Z3X1', Z4X1, `Z4X1', Z5X1, `Z5X1', Z6X1, `Z6X1', Z7X1, `Z7X1',
					Z0Y0, `Z0Y0', Z1Y0, `Z1Y0', Z2Y0, `Z2Y0', Z3Y0, `Z3Y0', Z4Y0, `Z4Y0', Z5Y0, `Z5Y0', Z6Y0, `Z6Y0', Z7Y0, `Z7Y0',
					Z0Y1, `Z0Y1', Z1Y1, `Z1Y1', Z2Y1, `Z2Y1', Z3Y1, `Z3Y1', Z4Y1, `Z4Y1', Z5Y1, `Z5Y1', Z6Y1, `Z6Y1', Z7Y1, `Z7Y1',
					Z0X0Y0, `Z0X0Y0', Z1X0Y0, `Z1X0Y0', Z2X0Y0, `Z2X0Y0', Z3X0Y0, `Z3X0Y0', Z4X0Y0, `Z4X0Y0', Z5X0Y0, `Z5X0Y0', Z6X0Y0, `Z6X0Y0', Z7X0Y0, `Z7X0Y0',
					Z0X0Y1, `Z0X0Y1', Z1X0Y1, `Z1X0Y1', Z2X0Y1, `Z2X0Y1', Z3X0Y1, `Z3X0Y1', Z4X0Y1, `Z4X0Y1', Z5X0Y1, `Z5X0Y1', Z6X0Y1, `Z6X0Y1', Z7X0Y1, `Z7X0Y1',
					Z0X1Y0, `Z0X1Y0', Z1X1Y0, `Z1X1Y0', Z2X1Y0, `Z2X1Y0', Z3X1Y0, `Z3X1Y0', Z4X1Y0, `Z4X1Y0', Z5X1Y0, `Z5X1Y0', Z6X1Y0, `Z6X1Y0', Z7X1Y0, `Z7X1Y0',
					Z0X1Y1, `Z0X1Y1', Z1X1Y1, `Z1X1Y1', Z2X1Y1, `Z2X1Y1', Z3X1Y1, `Z3X1Y1', Z4X1Y1, `Z4X1Y1', Z5X1Y1, `Z5X1Y1', Z6X1Y1, `Z6X1Y1', Z7X1Y1, `Z7X1Y1',
					sample_size, `sample_size'
					) append;
					#delimit cr	
					
					}
					

					* Calculate instrument-exposure association ----------------
					
					regress exposure instrument pres_year_*, cluster(index_staff)

					local endog = .
					local endogp = .
					local Fstat = e(F)
						
					#delimit ;
					regsave using "$data/regresults.dta", 
					pval ci addlabel(analysis, "first", Fstat, `Fstat', endog, `endog', endogp, `endogp', 
					outcome, `out`y'', treat_int, `j', treat_ref, `i', cohort,`x', 
					ex_start, `ex_start', ex_drug, `ex_drug', ex_diag, `ex_diag', ex_staff0, `ex_staff0',
					X0Y0, `X0Y0', X1Y0, `X1Y0', X0Y1, `X0Y1', X1Y1, `X1Y1',
					Z0X0, `Z0X0', Z1X0, `Z1X0', Z2X0, `Z2X0', Z3X0, `Z3X0', Z4X0, `Z4X0', Z5X0, `Z5X0', Z6X0, `Z6X0', Z7X0, `Z7X0',
					Z0X1, `Z0X1', Z1X1, `Z1X1', Z2X1, `Z2X1', Z3X1, `Z3X1', Z4X1, `Z4X1', Z5X1, `Z5X1', Z6X1, `Z6X1', Z7X1, `Z7X1',
					Z0Y0, `Z0Y0', Z1Y0, `Z1Y0', Z2Y0, `Z2Y0', Z3Y0, `Z3Y0', Z4Y0, `Z4Y0', Z5Y0, `Z5Y0', Z6Y0, `Z6Y0', Z7Y0, `Z7Y0',
					Z0Y1, `Z0Y1', Z1Y1, `Z1Y1', Z2Y1, `Z2Y1', Z3Y1, `Z3Y1', Z4Y1, `Z4Y1', Z5Y1, `Z5Y1', Z6Y1, `Z6Y1', Z7Y1, `Z7Y1',
					Z0X0Y0, `Z0X0Y0', Z1X0Y0, `Z1X0Y0', Z2X0Y0, `Z2X0Y0', Z3X0Y0, `Z3X0Y0', Z4X0Y0, `Z4X0Y0', Z5X0Y0, `Z5X0Y0', Z6X0Y0, `Z6X0Y0', Z7X0Y0, `Z7X0Y0',
					Z0X0Y1, `Z0X0Y1', Z1X0Y1, `Z1X0Y1', Z2X0Y1, `Z2X0Y1', Z3X0Y1, `Z3X0Y1', Z4X0Y1, `Z4X0Y1', Z5X0Y1, `Z5X0Y1', Z6X0Y1, `Z6X0Y1', Z7X0Y1, `Z7X0Y1',
					Z0X1Y0, `Z0X1Y0', Z1X1Y0, `Z1X1Y0', Z2X1Y0, `Z2X1Y0', Z3X1Y0, `Z3X1Y0', Z4X1Y0, `Z4X1Y0', Z5X1Y0, `Z5X1Y0', Z6X1Y0, `Z6X1Y0', Z7X1Y0, `Z7X1Y0',
					Z0X1Y1, `Z0X1Y1', Z1X1Y1, `Z1X1Y1', Z2X1Y1, `Z2X1Y1', Z3X1Y1, `Z3X1Y1', Z4X1Y1, `Z4X1Y1', Z5X1Y1, `Z5X1Y1', Z6X1Y1, `Z6X1Y1', Z7X1Y1, `Z7X1Y1',
					sample_size, `sample_size'
					) append;
					#delimit cr
				
					
					* Perform linear regression --------------------------------

					if `x'==2 {
						
						logit outcome exposure $ht_cov pres_year_*, cluster(index_staff)

						local endog = .
						local endogp = .
						local Fstat = e(F)

						#delimit ;
						regsave using "$data/regresults.dta", 
						pval ci addlabel(analysis, "logit", Fstat, `Fstat', endog, `endog', endogp, `endogp', 
						outcome, `out`y'', treat_int, `j', treat_ref, `i', cohort,`x', 
						ex_start, `ex_start', ex_drug, `ex_drug', ex_diag, `ex_diag', ex_staff0, `ex_staff0',
						X0Y0, `X0Y0', X1Y0, `X1Y0', X0Y1, `X0Y1', X1Y1, `X1Y1',
						Z0X0, `Z0X0', Z1X0, `Z1X0', Z2X0, `Z2X0', Z3X0, `Z3X0', Z4X0, `Z4X0', Z5X0, `Z5X0', Z6X0, `Z6X0', Z7X0, `Z7X0',
						Z0X1, `Z0X1', Z1X1, `Z1X1', Z2X1, `Z2X1', Z3X1, `Z3X1', Z4X1, `Z4X1', Z5X1, `Z5X1', Z6X1, `Z6X1', Z7X1, `Z7X1',
						Z0Y0, `Z0Y0', Z1Y0, `Z1Y0', Z2Y0, `Z2Y0', Z3Y0, `Z3Y0', Z4Y0, `Z4Y0', Z5Y0, `Z5Y0', Z6Y0, `Z6Y0', Z7Y0, `Z7Y0',
						Z0Y1, `Z0Y1', Z1Y1, `Z1Y1', Z2Y1, `Z2Y1', Z3Y1, `Z3Y1', Z4Y1, `Z4Y1', Z5Y1, `Z5Y1', Z6Y1, `Z6Y1', Z7Y1, `Z7Y1',
						Z0X0Y0, `Z0X0Y0', Z1X0Y0, `Z1X0Y0', Z2X0Y0, `Z2X0Y0', Z3X0Y0, `Z3X0Y0', Z4X0Y0, `Z4X0Y0', Z5X0Y0, `Z5X0Y0', Z6X0Y0, `Z6X0Y0', Z7X0Y0, `Z7X0Y0',
						Z0X0Y1, `Z0X0Y1', Z1X0Y1, `Z1X0Y1', Z2X0Y1, `Z2X0Y1', Z3X0Y1, `Z3X0Y1', Z4X0Y1, `Z4X0Y1', Z5X0Y1, `Z5X0Y1', Z6X0Y1, `Z6X0Y1', Z7X0Y1, `Z7X0Y1',
						Z0X1Y0, `Z0X1Y0', Z1X1Y0, `Z1X1Y0', Z2X1Y0, `Z2X1Y0', Z3X1Y0, `Z3X1Y0', Z4X1Y0, `Z4X1Y0', Z5X1Y0, `Z5X1Y0', Z6X1Y0, `Z6X1Y0', Z7X1Y0, `Z7X1Y0',
						Z0X1Y1, `Z0X1Y1', Z1X1Y1, `Z1X1Y1', Z2X1Y1, `Z2X1Y1', Z3X1Y1, `Z3X1Y1', Z4X1Y1, `Z4X1Y1', Z5X1Y1, `Z5X1Y1', Z6X1Y1, `Z6X1Y1', Z7X1Y1, `Z7X1Y1',
						sample_size, `sample_size'
						) append;
						#delimit cr

					}
					
					* Perform provider fixed effects analysis ------------------
					
					xtset pracid
					xtivreg outcome (exposure=instrument) pres_year_*, fe vce(robust) small
					
					local endog = .
					local endogp = .
					local Fstat = e(F)

					#delimit ;
					regsave using "$data/regresults.dta", 
					pval ci addlabel(analysis, "iv_fe", Fstat, `Fstat', endog, `endog', endogp, `endogp', 
					outcome, `out`y'',  treat_int, `j', treat_ref, `i', cohort,`x', 
					ex_start, `ex_start', ex_drug, `ex_drug', ex_diag, `ex_diag', ex_staff0, `ex_staff0',
					X0Y0, `X0Y0', X1Y0, `X1Y0', X0Y1, `X0Y1', X1Y1, `X1Y1',
					Z0X0, `Z0X0', Z1X0, `Z1X0', Z2X0, `Z2X0', Z3X0, `Z3X0', Z4X0, `Z4X0', Z5X0, `Z5X0', Z6X0, `Z6X0', Z7X0, `Z7X0',
					Z0X1, `Z0X1', Z1X1, `Z1X1', Z2X1, `Z2X1', Z3X1, `Z3X1', Z4X1, `Z4X1', Z5X1, `Z5X1', Z6X1, `Z6X1', Z7X1, `Z7X1',
					Z0Y0, `Z0Y0', Z1Y0, `Z1Y0', Z2Y0, `Z2Y0', Z3Y0, `Z3Y0', Z4Y0, `Z4Y0', Z5Y0, `Z5Y0', Z6Y0, `Z6Y0', Z7Y0, `Z7Y0',
					Z0Y1, `Z0Y1', Z1Y1, `Z1Y1', Z2Y1, `Z2Y1', Z3Y1, `Z3Y1', Z4Y1, `Z4Y1', Z5Y1, `Z5Y1', Z6Y1, `Z6Y1', Z7Y1, `Z7Y1',
					Z0X0Y0, `Z0X0Y0', Z1X0Y0, `Z1X0Y0', Z2X0Y0, `Z2X0Y0', Z3X0Y0, `Z3X0Y0', Z4X0Y0, `Z4X0Y0', Z5X0Y0, `Z5X0Y0', Z6X0Y0, `Z6X0Y0', Z7X0Y0, `Z7X0Y0',
					Z0X0Y1, `Z0X0Y1', Z1X0Y1, `Z1X0Y1', Z2X0Y1, `Z2X0Y1', Z3X0Y1, `Z3X0Y1', Z4X0Y1, `Z4X0Y1', Z5X0Y1, `Z5X0Y1', Z6X0Y1, `Z6X0Y1', Z7X0Y1, `Z7X0Y1',
					Z0X1Y0, `Z0X1Y0', Z1X1Y0, `Z1X1Y0', Z2X1Y0, `Z2X1Y0', Z3X1Y0, `Z3X1Y0', Z4X1Y0, `Z4X1Y0', Z5X1Y0, `Z5X1Y0', Z6X1Y0, `Z6X1Y0', Z7X1Y0, `Z7X1Y0',
					Z0X1Y1, `Z0X1Y1', Z1X1Y1, `Z1X1Y1', Z2X1Y1, `Z2X1Y1', Z3X1Y1, `Z3X1Y1', Z4X1Y1, `Z4X1Y1', Z5X1Y1, `Z5X1Y1', Z6X1Y1, `Z6X1Y1', Z7X1Y1, `Z7X1Y1',
					sample_size, `sample_size'
					) append;
					#delimit cr


				}
			}
			}
		}
	}
}


use "$data/regresults.dta", clear
keep if var=="exposure" | var=="outcome:exposure" | var=="instrument"
replace coef = cond(var=="outcome:exposure",exp(coef),coef)
replace ci_lower = cond(var=="outcome:exposure",exp(ci_lower),ci_lower)
replace ci_upper = cond(var=="outcome:exposure",exp(ci_upper),ci_upper)
drop var ex_*
order cohort analysis outcome treat_int treat_ref coef stderr pval ci_lower ci_upper Fstat endog endogp sample_size
outsheet using "$output/analysis_reg.csv", comma replace
