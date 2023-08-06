**************************************************************************
* PRINCIPAL COMPONENT GENERATION
***************************************************************************

******************************
* Load Data
******************************

use "${dir}/data/lucid_segregation_survey.dta" , clear

***************************************************************************	 

tempfile hold
save `hold', replace	  

***** Now drop observations that won't be used for figures/analyses 
quietly reg seg_diff i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party ///
			i.region frl_expdiff_frlnfrl perfrl ppexp_tot log_enrl ncharters pprev_tot ///
			sesavgall 
gen analytic_sample = e(sample)==1
keep if analytic_sample==1 

append using `hold'
replace analytic_sample = 0 if analytic_sample==.

***************************************************************************	 

* General Attitudes (First Group of Variables)
**********************************************

*pwcorr attitude_1 attitude_2 attitude_3 attitude_4, sig 
pca attitude_1 attitude_2 attitude_3 attitude_4 if analytic_sample
predict attitude_pc, score
label variable attitude_pc "Attitude Index"

preserve
	label var attitude_1 "Important Issue" 
	label var attitude_2 "Support Reducing" 
	label var attitude_3 "Positive/Negative" 
	label var attitude_4 "Problem" 

	forval i = 1/4 {
		estadd local var`i' = round(e(Ev)[1,`i']/4, .01)
		display "e(Ev)[`i',1]/4"
	}

	esttab using "${table}/tabA2.csv", ///
		   label plain replace ///
		   cells("L[Comp1](t fmt(2)) L[Comp2](t) L[Comp3](t) L[Comp4](t)") ///	
		   mtitle("Attitude Index") ///
		   collabels("Component 1" "Component 2" "Component 3" "Component 4") ///
		   postfoot(" " "Variance Explained: , `e(var1)', `e(var2)', `e(var3)', `e(var4)'" " ") 
restore

* Specific Policies (Second Group of Variables)
***********************************************

*pwcorr policy_attendance policy_newschool policy_magnet policy_budget policy_govt , sig 
pca policy_attendance policy_newschool policy_magnet policy_budget policy_govt if analytic_sample
predict policy_pc, score
label variable policy_pc "Policy Index"

preserve
	forval i = 1/5 {
		estadd local var`i' = round(e(Ev)[1,`i']/5, .01)
		display "e(Ev)[`i',1]/4"
	}

	esttab using "${table}/tabA2.csv", ///
		   label plain append ///
		   cells("L[Comp1](t fmt(2)) L[Comp2](t) L[Comp3](t) L[Comp4](t) L[Comp5](t)") ///	
		   mtitle("Policy Index") ///
		   collabels("Component 1" "Component 2" "Component 3" "Component 4" "Component 5") ///
		   postfoot(" " "Fraction of Variance Explained: , `e(var1)', `e(var2)', `e(var3)', `e(var4)', `e(var5)' ") 
restore

* Standardize PCs
*****************

*** Standardize using mean/sd of control group 

foreach var in attitude_pc policy_pc {
	quietly sum `var' if treat==0 & analytic_sample==1
	replace `var' = (`var' - `r(mean)')/`r(sd)'
}

rename *_pc *_std

***************************************************************************
***************************************************************************
* SAVE OUT CLEAN ANALYTIC SAMPLE AND FULL SAMPLE DATA FILES
***************************************************************************
***************************************************************************	 

preserve
	keep if analytic_sample==0
	save "${dir}/data/data_analytic_${date}.dta", replace 
restore

preserve
	keep if analytic_sample==1
	save "${dir}/data/data_full_${date}.dta", replace 
restore

