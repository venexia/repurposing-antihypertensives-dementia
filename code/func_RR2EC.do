// Function to calculate excess cases from relative risk
// Compares antihypertensive of interest against all other antihypertensives for the outcome 'any dementia'
// Reference: https://bestpractice.bmj.com/info/toolkit/learn-ebm/how-to-calculate-risk/

cap prog drop RR2EC
prog def RR2EC
args drug RR LCI UCI

	use "$data/analysis.dta", clear

	// Calculate ARC for all other antihypertensives

	qui count if index_drug!="`drug'" & diagnosis_dem>0
	local x = r(N)

	qui count if index_drug!="`drug'"
	local y = r(N)

	local ARC = `x' / `y'

	// Calculate NNT 

	local NNT = 1 / ((1-`RR')*`ARC')
	local NNT_LCI = 1 / ((1-`LCI')*`ARC')
	local NNT_UCI = 1 / ((1-`UCI')*`ARC')

	// Calculate additional cases per 1000 treated

	local add_cases = round(-1 * (1000/`NNT'),1)
	local add_cases_LCI = round(-1 * (1000/`NNT_LCI'),1)
	local add_cases_UCI = round(-1 * (1000/`NNT_UCI'),1)

	// State results

	di "A relative risk of `RR' (95% CI: `LCI' to `UCI') corresponds to `add_cases' (95% CI: `add_cases_LCI' to `add_cases_UCI') additional cases per 1000 treated."


end
