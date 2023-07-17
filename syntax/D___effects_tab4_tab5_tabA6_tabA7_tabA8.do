
use "${dir}/data/data_analytic_${date}.dta" , clear

***********************************************
* Overall Treatment Effects (Analytic Sample)
***********************************************

eststo clear 
eststo: reg attitude_std i.treat, robust 
eststo: reg attitude_std i.treat i.female i.race i.hispanic_cat age log_inc ///
						 i.ed_cat i.party i.region frl_expdiff_frlnfrl perfrl ///
						 log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
						 robust 

eststo: reg policy_std i.treat, robust 
eststo: reg policy_std i.treat i.female i.race i.hispanic_cat age log_inc ///
						 i.ed_cat i.party i.region frl_expdiff_frlnfrl perfrl ///
						 log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
						 robust 
 
eststo: reg minutes_additional i.treat, robust 
eststo: reg minutes_additional i.treat i.female i.race i.hispanic_cat age log_inc ///
						 i.ed_cat i.party i.region frl_expdiff_frlnfrl perfrl ///
						 log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
						 robust 

eststo: reg tax i.treat, robust 
eststo: reg tax i.treat i.female i.race i.hispanic_cat age log_inc ///
						 i.ed_cat i.party i.region frl_expdiff_frlnfrl perfrl ///
						 log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
						 robust 

esttab using "${table}/tab4.csv", nobaselevels obslast ar2 se nogaps label noomitted replace compress star(* 0.05 ** 0.01 *** 0.001) b(%9.2f)  keep(1.treat)

********************************************************************************
* Overall Treatment Effects (Full Sample)
********************************************************************************
 
preserve
	use "${dir}/data/data_full_$date.dta", clear 

	***** Treatment effects on full sample (for appendix) 

	eststo clear 
	eststo: reg attitude_std i.treat ///
							 i.female i.race i.hispanic_cat age ///
							 log_inc i.ed_cat i.party i.region /// 
							 , robust 
	eststo: reg policy_std i.treat ///
							 i.female i.race i.hispanic_cat age ///
							 log_inc i.ed_cat i.party i.region /// 
							 , robust 
							 
	eststo: reg minutes_additional i.treat ///
							 i.female i.race i.hispanic_cat age ///
							 log_inc i.ed_cat i.party i.region /// 
							 , robust 
							 
	eststo: reg tax i.treat i.treat ///
							 i.female i.race i.hispanic_cat age ///
							 log_inc i.ed_cat i.party i.region /// 
							 , robust 

	esttab using "${table}/tabA6.csv", nobaselevels obslast ar2 se nogaps label noomitted replace compress star(* 0.05 ** 0.01 *** 0.001) b(%9.2f) keep(1.treat)
restore

***********************************************
* Overall Treatment Effects (Dichotmous Travel Time & Tax Increase )
***********************************************

eststo clear 
 
eststo: reg dich_minutes_additional i.treat i.female i.race i.hispanic_cat age log_inc ///
						 i.ed_cat i.party i.region frl_expdiff_frlnfrl perfrl ///
						 log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
						 robust 

eststo: reg dich_tax i.treat i.female i.race i.hispanic_cat age log_inc ///
						 i.ed_cat i.party i.region frl_expdiff_frlnfrl perfrl ///
						 log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
						 robust 

esttab using "${table}/tabA8.csv", nobaselevels obslast ar2 se nogaps label noomitted replace compress star(* 0.05 ** 0.01 *** 0.001) b(%9.2f) keep(1.treat)

***********************************************
* Treatment Effects on Individual Policy Index Items
***********************************************

estimates clear 

foreach var in policy_attendance policy_newschool policy_magnet policy_budget policy_govt {
	eststo: reg `var' treat ///
				i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region ///
				frl_expdiff_frlnfrl perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall ///
				, robust	
}

esttab using "${table}/tabA7.csv" ///
	   , nobaselevels obslast ar2 se nogaps label noomitted replace compress ///
	   star(* 0.05 ** 0.01 *** 0.001) ///
	   b(%9.2f) ///
	   keep(treat)
	   
	   

***********************************************
* Heterogeneity of Treatment Effects (Percieved - Actual) 
***********************************************

eststo clear 

*** Generate dichotomous interaction variables
gen seg_over=abs(seg_under-1)
*tab seg_over seg_under

gen seg_over_treat = seg_over*treat
gen seg_under_treat = seg_under*treat

label variable seg_over_treat "Treatment X (Perceived - Actual ≥ 0)"
label variable seg_under_treat "Treatment X (Perceived - Actual < 0)"

*** Generate continuous interaction variables
gen seg_diff_treat=seg_diff*treat

label variable treat "Treatment"
label variable seg_diff "Perceived - Actual"
label variable seg_diff_treat "Treatment X (Perceived - Actual)"

***dichotomous over/under regressions
*eststo: reg attitude_std seg_over seg_under seg_over_treat seg_under_treat, noc robust
eststo: reg attitude_std seg_over seg_under seg_over_treat seg_under_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, noc robust

*eststo: reg policy_std seg_over seg_under seg_over_treat seg_under_treat, noc robust
eststo: reg policy_std seg_over seg_under seg_over_treat seg_under_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, noc robust

*eststo: reg minutes_additional seg_over seg_under seg_over_treat seg_under_treat, noc robust
eststo: reg minutes_additional seg_over seg_under seg_over_treat seg_under_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, noc robust

*eststo: reg tax seg_over seg_under seg_over_treat seg_under_treat, noc robust
eststo: reg tax seg_over seg_under seg_over_treat seg_under_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, noc robust

esttab using "${table}/tab5.csv", ///
		     nobaselevels noobs ar2 se nogaps label noomitted replace compress ///
			 star(* 0.05 ** 0.01 *** 0.001) ///
			 b(%9.2f) ///
			 keep(seg_over_treat seg_under_treat) ///
			 postfoot(" ")

***continuous over/under regressions

eststo clear

*eststo: reg attitude_std treat seg_diff seg_diff_treat, robust
eststo: reg attitude_std treat seg_diff seg_diff_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, robust

*eststo: reg policy_std treat seg_diff seg_diff_treat, robust
eststo: reg policy_std treat seg_diff seg_diff_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, robust

*eststo: reg minutes_additional treat seg_diff seg_diff_treat, robust
eststo: reg minutes_additional treat seg_diff seg_diff_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, robust

*eststo: reg tax treat seg_diff seg_diff_treat, robust
eststo: reg tax treat seg_diff seg_diff_treat i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, robust

esttab using "${table}/tab5.csv", ///
		     nobaselevels noobs ar2 se nogaps label noomitted nonumbers append compress ///
			 star(* 0.05 ** 0.01 *** 0.001) ///
			 b(%9.2f) ///
			 keep(treat seg_diff seg_diff_treat) ///
			 postfoot(" ")

***********************************************
* Heterogeneity of Treatment Effects (Percieved - Actual) 
***********************************************

eststo clear 

*** Generate dichotomous interaction variables
gen high_inc_treat = hhi_median*treat
gen low_inc = abs(hhi_median-1)
gen low_inc_treat = low_inc*treat
label variable high_inc_treat "Treatment X (Household Income > Median)"
label variable low_inc_treat "Treatment X (Household Income ≤ Median)"

*** Generate continuous interaction variables
gen log_inc_treat=log_inc*treat
label variable treat "Treatment"
label variable log_inc_treat "Treatment X ln(Household Income)"

***dichotomous over/under regressions
eststo: reg attitude_std hhi_median low_inc high_inc_treat low_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		noc robust

eststo: reg policy_std hhi_median low_inc high_inc_treat low_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		noc robust

eststo: reg minutes_additional hhi_median low_inc high_inc_treat low_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		noc robust
		
eststo: reg tax hhi_median low_inc high_inc_treat low_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		noc robust

esttab using "${table}/tab5.csv", ///
			 nobaselevels noobs ar2 se nogaps label noomitted nonumbers  append compress ///
			 star(* 0.05 ** 0.01 *** 0.001) ///
			 b(%9.2f) ///
			 keep(high_inc_treat low_inc_treat) ///
 			 postfoot(" ")

***continuous over/under regressions
eststo clear

eststo: reg attitude_std treat log_inc log_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		robust
		
eststo: reg policy_std treat log_inc log_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		robust
		
eststo: reg minutes_additional treat log_inc log_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		robust
		
eststo: reg tax treat log_inc log_inc_treat ///
	    i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, ///
		robust		

esttab using "${table}/tab5.csv" ///
			 , nobaselevels obslast ar2 se nogaps label noomitted nonumbers append compress ///
			 star(* 0.05 ** 0.01 *** 0.001) ///
			 b(%9.2f) ///
			 keep(treat log_inc log_inc_treat)
