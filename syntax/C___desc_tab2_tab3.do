
******************************************************************************
* TABLE 2
******************************************************************************

***
use "${dir}/data/data_analytic_${date}.dta" , clear

keep if treat==0 

gen stat = attitude_std
gen type = "Attitude Index"

append using "${dir}/data/data_analytic_${date}.dta"

replace stat = policy_std if stat == .
replace type = "Policy Index" if type == ""

***gender
decode female, generate(female_str)

sort type
preserve
	keep if female_str == "Male"
	label var stat "Male"
	
	estimates clear	
	
	bysort type: eststo: estpost sum stat
		
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs plain replace ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels("Mean" "Standard Deviation" "N") ///
	title("Gender")
restore

preserve
	keep if female_str == "Female"
	label var stat "Female"

	estimates clear	
	
	bysort type: eststo: estpost sum stat
		
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***race
decode race, generate(race_str)
replace race_str = "Native American" if race_str == "American Indian / Alaska Native"
replace race_str = "Asian" if race_str == "Asian / Pacific Islander"
replace race_str = "Other" if race_str == "Other / Prefer not to answer"
tab race_str

sort type
preserve
	keep if race_str == "White"
	label var stat "White"	

	estimates clear	
	
	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Race")
restore

foreach race in "Black" "American Indian" "Asian" "Other" {
	preserve
		keep if race_str == "`race'"
		label var stat "`race'"	
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab2.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}

***ethnicity
decode hispanic_cat, generate(hispanic_str)

preserve
	keep if hispanic_str == "Non-Hispanic"
	label var stat "Non-Hispanic"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Ethnicity")
restore

preserve
	keep if hispanic_str == "Hispanic"
	label var stat "Hispanic"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***age
decode age_median, generate(age_median_str)

preserve
	keep if age_median_str == "Below Median"
	label var stat "Below Median"

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Age")
restore

preserve
	keep if age_median_str == "Above Median"
	label var stat "Above Median"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***income
decode hhi_median, generate(hhi_median_str)

preserve
	keep if hhi_median_str == "Below Median"
	label var stat "Below Median"

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Household Income")
restore

preserve
	keep if hhi_median_str == "Above Median"
	label var stat "Above Median"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***education
decode ed_cat, generate(ed_cat_str)

sort type
preserve
	keep if ed_cat_str== "Less than High School"
	label var stat "Less than High School"

	estimates clear	
	
	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Education")
restore

foreach edu in "High School" "2-Year Degree" "4-Year Degree" "Graduate Degree" {
	preserve
		keep if ed_cat_str == "`edu'"
		label var stat "`edu'"	
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab2.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}

***political party
decode party, generate(party_str)

preserve
	keep if party_str == "Democrat" 
	label var stat "Democrat" 

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Political Party")
restore

foreach party in "Republican" "Independent" {
	preserve
		keep if party_str == "`party'"
		label var stat "`party'"
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab2.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}

***region
decode region, generate(region_str)

sort type
preserve
	keep if region_str== "Northeast"
	label var stat "Northeast"

	estimates clear	
	
	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab2.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Region")
restore

foreach region in "Midwest" "South" "West" {
	preserve
		keep if region_str == "`region'"
		label var stat "`region'"	
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab2.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}

******************************************************************************
* TABLE 3
******************************************************************************

***
use "${dir}/data/data_analytic_${date}.dta" , clear


gen stat = seg_guess
gen type = 0

append using "${dir}/data/data_analytic_${date}.dta"

replace stat = seg_diff if stat == .
replace type = 1 if type == .

label define lbl_col ///
	  0 "Perceived Segregation Level" ///
	  1 "Difference Between Perceived & Actual Segregation"
label values type lbl_col 

***gender
decode female, generate(female_str)

gsort - type
preserve
	keep if female_str == "Male"
	label var stat "Male"
	
	estimates clear	
	
	bysort type: eststo: estpost sum stat
		
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs plain replace ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels("Mean" "Standard Deviation" "N") ///
	title("Gender")
restore

preserve
	keep if female_str == "Female"
	label var stat "Female"

	estimates clear	
	
	bysort type: eststo: estpost sum stat
		
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***race
decode race, generate(race_str)
replace race_str = "Native American" if race_str == "American Indian / Alaska Native"
replace race_str = "Asian" if race_str == "Asian / Pacific Islander"
replace race_str = "Other" if race_str == "Other / Prefer not to answer"
tab race_str

sort type
preserve
	keep if race_str == "White"
	label var stat "White"	

	estimates clear	
	
	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Race")
restore

foreach race in "Black" "American Indian" "Asian" "Other" {
	preserve
		keep if race_str == "`race'"
		label var stat "`race'"	
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab3.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}

***ethnicity
decode hispanic_cat, generate(hispanic_str)

preserve
	keep if hispanic_str == "Non-Hispanic"
	label var stat "Non-Hispanic"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Ethnicity")
restore

preserve
	keep if hispanic_str == "Hispanic"
	label var stat "Hispanic"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***age
decode age_median, generate(age_median_str)

preserve
	keep if age_median_str == "Below Median"
	label var stat "Below Median"

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Age")
restore

preserve
	keep if age_median_str == "Above Median"
	label var stat "Above Median"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***income
decode hhi_median, generate(hhi_median_str)

preserve
	keep if hhi_median_str == "Below Median"
	label var stat "Below Median"

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Household Income")
restore

preserve
	keep if hhi_median_str == "Above Median"
	label var stat "Above Median"	

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none)
restore

***education
decode ed_cat, generate(ed_cat_str)

sort type
preserve
	keep if ed_cat_str== "Less than High School"
	label var stat "Less than High School"

	estimates clear	
	
	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Education")
restore

foreach edu in "High School" "2-Year Degree" "4-Year Degree" "Graduate Degree" {
	preserve
		keep if ed_cat_str == "`edu'"
		label var stat "`edu'"	
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab3.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}

***political party
decode party, generate(party_str)

preserve
	keep if party_str == "Democrat" 
	label var stat "Democrat" 

	estimates clear	

	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Political Party")
restore

foreach party in "Republican" "Independent" {
	preserve
		keep if party_str == "`party'"
		label var stat "`party'"
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab3.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}

***region
decode region, generate(region_str)

sort type
preserve
	keep if region_str== "Northeast"
	label var stat "Northeast"

	estimates clear	
	
	bysort type: eststo: estpost sum stat
	esttab using "${table}\tab3.csv", ///
	label nonumber nodepvar noobs nomtitles plain append  ///
	cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
	collabels(none) ///
	title("Region")
restore

foreach region in "Midwest" "South" "West" {
	preserve
		keep if region_str == "`region'"
		label var stat "`region'"	
		
		estimates clear	
		
		bysort type: eststo: estpost sum stat
		esttab using "${table}\tab3.csv", ///
		label nonumber nodepvar noobs nomtitles plain append  ///
		cells("mean(fmt(2)) sd(fmt(3)) count(fmt(0))") ///
		collabels(none)
	restore
}
