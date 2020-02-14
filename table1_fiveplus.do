use "$data/analysis.dta", clear
save "$data/analysis_five.dta", replace

quietly foreach list in $ht_paper {
	use "$path/data/eventlists/eventlist_`list'.dta", clear
	keep patid staffid index_date
	bysort patid: egen first_date = min(index_date)
	format %td first_date
	gen date_five = first_date + (365.25*5)
	format %td date_five
	gen five = cond(index_date >= date_five,1,0)
	bysort patid: egen `list'_five = max(five)
	keep if first_date == index_date
	keep patid index_date `list'_five
	duplicates drop
	save "$data/five/five_`list'.dta", replace
	use "$data/analysis_five.dta", clear
	merge 1:1 patid using "$data/five/five_`list'.dta", keep(match master)
	drop _merge
	save "$data/analysis_five.dta", replace
}

* Summarize the drug variables into one variable -------------------------------

use "$data/analysis_five.dta", clear
keep patid index_drug *_five

gen five = .

quietly foreach list in $ht_paper {
	replace five = `list'_five if index_drug=="`list'"
}

keep patid index_drug five

* Tidy drug names --------------------------------------------------------------

replace index_drug = "Alpha-adrenoceptor blockers" if index_drug == "ht_aab"
replace index_drug = "Angiotensin-converting enzyme inhibitors" if index_drug == "ht_ace"
replace index_drug = "Angiotensin-II receptor blockers" if index_drug == "ht_arb"
replace index_drug = "Beta-adrenoceptor blockers" if index_drug == "ht_bab"
replace index_drug = "Calcium channel blockers" if index_drug ==  "ht_ccb"
replace index_drug = "Diuretics" if index_drug == "ht_diu"
replace index_drug = "Vasodilator antihypertensives" if index_drug == "ht_vad"

* Summarize information --------------------------------------------------------

bysort index_drug: egen total_five = total(five)
bysort index_drug: egen total_drug = count(index_drug)
keep index_drug total_*
duplicates drop

* Calculate percentage ---------------------------------------------------------

gen percentage = round(100*(total_five/total_drug))

* Save -------------------------------------------------------------------------

save "$data/analysis_five.dta", replace

