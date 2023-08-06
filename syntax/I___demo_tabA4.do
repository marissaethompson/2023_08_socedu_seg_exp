use "${dir}/data/data_analytic_${date}.dta", clear

gen stat = seg_actual
gen type = "Actual"

append using "${dir}/data/data_analytic_${date}.dta" 

replace stat = seg_guess if stat == .
replace type = "Perceived" if type == ""

tabulate stat, generate(stat_)

label variable stat_1 "A"
label variable stat_2 "D"
label variable stat_3 "C"
label variable stat_4 "D"
label variable stat_5 "E"
label variable stat_6 "F"

***
decode race, generate(race_str)
replace race_str = "Native American" if race_str == "American Indian / Alaska Native"
replace race_str = "Asian" if race_str == "Asian / Pacific Islander"
replace race_str = "Other" if race_str == "Other / Prefer not to answer"
tab race_str

sort type
preserve
	keep if race_str == "White"

	estimates clear	
	
	bysort type: eststo: estpost ci stat_*
		
	esttab using "${table}\tabA4.csv", ///
	label nonumber nodepvar plain replace ///
	cells("b(fmt(2)) se(fmt(3) par({ }))") /// 
	collabels("Fraction of Parents" "Standard Error") ///
	title("White")
restore

foreach race in "Black" "American Indian" "Asian" "Other" {
	preserve
		keep if race_str == "`race'"
		
		estimates clear	
		
		bysort type: eststo: estpost ci stat_*
		esttab using "${table}\tabA4.csv", ///
		label nonumber nodepvar nomtitles plain append  ///
		cells("b(fmt(2)) se(fmt(3) par({ }))") /// 
		collabels(none) ///
		title("`race'")
	restore
}

***
decode hispanic_cat, generate(hispanic_str)

foreach ethnicity in "Non-Hispanic" "Hispanic" {
	preserve
		keep if hispanic_str == "`ethnicity'"
		
		estimates clear	
		
		bysort type: eststo: estpost ci stat_*
		esttab using "${table}\tabA4.csv", ///
		label nonumber nodepvar nomtitles plain append  ///
		cells("b(fmt(2)) se(fmt(3) par({ }))") /// 
		collabels(none) ///
		title("`ethnicity'")
	restore
}

***
decode party, generate(party_str)

foreach party in "Democrat" "Republican" "Independent" {
	preserve
		keep if party_str == "`party'"
		
		estimates clear	
		
		bysort type: eststo: estpost ci stat_*
		
		esttab using "${table}\tabA4.csv", ///
		label nonumber nodepvar nomtitles plain append  ///
		cells("b(fmt(2)) se(fmt(3) par({ }))") /// 
		collabels(none) ///
		title("`party'")
	restore
}

***
decode hhi_median, generate(hhi_median_str)

foreach income in "Below Median" "Above Median" {
	preserve
		keep if hhi_median_str == "`income'"
		
		estimates clear	
		
		bysort type: eststo: estpost ci stat_*
		
		esttab using "${table}\tabA4.csv", ///
		label nonumber nodepvar nomtitles plain append  ///
		cells("b(fmt(2)) se(fmt(3) par({ }))") /// 
		collabels(none) ///
		title("`income'")
	restore
}