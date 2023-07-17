******************************************************************************** 
* Robustness Check - Metro Level Segregation 
********************************************************************************



********************************************************************************
* Clean Metro Segregation 
********************************************************************************

****** Start with SEDA Metro file
use "${dir}/data/raw/seda/seda_cov_metro_pool_4.0.dta", clear 
keep sedametro rsflnfl
duplicates drop 

tempfile metro 
save `metro', replace

****** Crosswalk to sedalea
use "${dir}/data/raw/seda/seda_crosswalk_4.0.dta", clear 
keep if geodef==1 
keep sedametro sedalea sedametroname sedaleanm
drop if sedametro==. 
drop if sedalea==. 
gen leaid_parents = string(sedalea,"%07.0f")
duplicates drop 

merge m:1 sedametro using `metro'
keep if _merge==3
drop _merge


tempfile metro_seg 
keep leaid_parents rsflnfl
duplicates drop 


***** Drop districts that merge to 2 metro areas (<352% of districts)
bys leaid_parents: drop if _N>1 
save `metro_seg', replace


******************************
* Load Data Survey 
******************************

use "${dir}/data/clean/survey_clean_$date.dta" , clear

merge m:1 leaid_parents using `metro_seg'
keep if _merge ==3 | _merge==1 


******************************
* Generate Metro Bins
******************************

rename rsflnfl metro_seg
** Label Metro Segregation & differentiate from district-level 
label variable metro_seg "Economic School Segregation (Metro)"
label variable frl_expdiff_frlnfrl "Economic School Segregation (District)"



foreach var in metro_seg {
	gen `var'_cat=.
	replace `var'_cat=1 if inrange(`var', 0, (0.028/2)) 
	replace `var'_cat=2 if inrange(`var', (0.028/2), ((0.028+0.111)/2))
	replace `var'_cat=3 if inrange(`var', ((0.028+0.111)/2), ((0.111+0.25)/2))
	replace `var'_cat=4 if inrange(`var', ((0.111+0.25)/2), ((0.25+0.444)/2))
	replace `var'_cat=5 if inrange(`var', ((0.25+0.444)/2),((0.444+0.694)/2))
	replace `var'_cat=6 if `var'> ((0.444+0.694)/2) & `var'!=. 
}


*** How correlated are metro bins and district bins? 

pwcorr metro_seg_cat seg_actual 
tab metro_seg_cat seg_actual 


******************************
* How much does metro segregation explain guesses? 
******************************
eststo clear 

eststo: estpost corr seg_guess frl_expdiff_frlnfrl metro_seg if metro_seg!=. 

eststo: estpost corr seg_diff frl_expdiff_frlnfrl metro_seg if metro_seg!=. 
esttab using "${table}/metro_seg_corr_$date.csv", unstack replace label compress star(* 0.05 ** 0.01 *** 0.001) b(%9.2f)



eststo clear 

// eststo: reg seg_guess i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region metro_seg, robust
eststo: reg seg_guess i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region metro_seg  i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, robust 


// eststo: reg seg_diff i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region metro_seg, robust
eststo: reg seg_diff i.female i.race i.hispanic_cat age log_inc i.ed_cat i.party i.region metro_seg  i.region perfrl log_enrl ncharters ppexp_tot pprev_tot sesavgall, robust 


esttab using "${table}/metro_seg_diff_$date.csv", nobaselevels obslast ar2 se nogaps label noomitted replace compress star(* 0.05 ** 0.01 *** 0.001) b(%9.2f)
