******************************************************************************** 
* Descriptive Tables

* Edit History
* File Initiatied - 03/31/2021
********************************************************************************

******************************
* Load Data
******************************

use "${dir}/data/clean/data_analytic_${date}.dta" , clear

********************************************************************************
* Descriptive Statistics - Table Generation 
********************************************************************************

gen sample = 0

append using "${dir}/data/clean/data_analytic_${date}.dta"

replace sample = control + 1 if sample==.

label define samples ///
      0 "Full Sample" ///
      1 "Treatment Group" ///
	  2 "Control Group"
label values sample samples

sum sample if sample==0
local n_full = `r(N)'
sum sample if sample==1
local n_treat = `r(N)'
sum sample if sample==2
local n_control = `r(N)'

** files saved in ---> tables folder 
cd "${table}/"

desctable i.female age i.hispanic_cat i.race hhi_cont_1000 i.ed_cat i.party i.region ///
		  frl_expdiff_frlnfrl perfrl totenrl_1000 ncharters ppexp_tot_1000 pprev_tot_1000 ///
		  sesavgall seg_guess seg_diff attitude_std policy_std minutes_additional tax ///
		  , stats(mean sd) ///
		  group(sample) ///
		  filename("table1_descriptive_$date") ///
		  title(" ") ///
		  notes(Observations = `n_full', `n_treat', `n_control') ///
		  notesize(11)

********************************************************************************
* T-Tests
********************************************************************************

cls 
foreach var in  female age hispanic_cat hhi_cont frl_expdiff_frlnfrl perfrl totenrl ncharters ppexp_tot pprev_tot sesavgall {
	di "`var'"
	ttest `var', by(treat)
}

foreach var in race ed_cat party region {
	tabulate `var', generate(`var'_l) 
}

foreach var in race_l1 race_l2 race_l3 race_l4 race_l5 ed_cat_l1 ed_cat_l2 ed_cat_l3 ed_cat_l4 ed_cat_l5 party_l1 party_l2 party_l3 region_l1 region_l2 region_l3 region_l4 {
	di "`var'"
	ttest `var', by(treat)
}
