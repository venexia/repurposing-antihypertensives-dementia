* Global variable containing all antihypertensives 
global ht_treat "ht_aab ht_ace ht_ace_ccb ht_ace_thi ht_anb ht_arb ht_arb_ccb ht_arb_ccb_thi ht_arb_thi ht_bab ht_bab_ccb ht_bab_ld ht_bab_ld_thi ht_bab_psd_thi ht_bab_thi ht_caa ht_ccb ht_ccb_thi ht_ld ht_ld_psd ht_psd ht_psd_thi ht_ren ht_thi ht_vad"

* Global variable containing all antihypertensives listed in protocol
global ht_proto "ht_bab ht_aab ht_ace ht_arb ht_caa ht_ccb ht_ld ht_psd ht_thi ht_vad"

* Global variable containing control antihypertensive from protocol 
global ht_base "ht_bab"

* Global variable containing all antihypertensives considered in present paper
global ht_paper "ht_aab ht_arb ht_ace ht_bab ht_ccb ht_diu ht_vad"

* Global variable containing basic variable set for analysis
global ht_basic "patid pracid gender region yob frd crd uts tod lcd deathdate fup accept data_* diagnosis* index_* drug5 drug10 drug_fup male pres_year_*"

* Global variable containing covariates for analysis
global ht_cov "male index_age_start cad cbs cvd bmi charlson imd2010 cons_rate smoking alcohol"

* Global variable containing dementia diagnoses
global dem_cond "dem_adposs dem_adprob dem_ns dem_oth dem_vas"

* Global variable containing dementia treatments
global dem_treat "dem_don dem_gal dem_mem dem_riv"

* Loop to create global variables with date, frequency, type and staff for global variables listed above
foreach z in date freq type staff {

	local event_global = "ht_treat ht_proto ht_paper dem_cond dem_treat"
	foreach y in `event_global' {
		local `y'_`z' = ""
		foreach x in $`y' {
			local `y'_`z' "``y'_`z'' `x'_`z'"
		}
		global `y'_`z' = "``y'_`z''"
	}
		
}
