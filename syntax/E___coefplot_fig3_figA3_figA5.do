
use "${dir}/data/data_analytic_${date}.dta", clear

********************************************************************************
* Attitudes & Preferences Coefficient Plot 
********************************************************************************

***Restrict to Control Group
preserve
	keep if treat==0

	estimates clear

	rename attitude_std att
	rename policy_std pol

	foreach y in att pol { 
		
		foreach x in female race hispanic_cat age_median ///
					 hhi_median ed_cat party region {
			quietly eststo m_`y'_`x': reg `y' i.`x', robust		 
		}
 
	} 

	coefplot (m_att*, ///
			  mcolor(${color1})  ///
			  msymbol(Oh) msize(vsmall) ///
			  ciopts(recast(rcap) color(${color1}%50)) ///
			  drop(_cons)) ///
			 (m_pol*, ///
			  mcolor(${color2}) mfcolor(${color2}) ///
			  msize(vsmall) msymbol(T) ///
			  ciopts(recast(rcap) color(${color2}%50)) ///
			  drop(_cons)) ///
			 , base ///
			 xline(0, lcolor(black)) ///
			 plotlabels("Attitude Index" "Policy Index") /// 
			 headings(0.female ="{bf:Gender}" ///
					  0.race = "{bf:Race}" ///
					  0.hispanic_cat = "{bf:Ethnicity}" ///		  
					  0.age_median = "{bf:Age}" ///
					  0.hhi_median = "{bf:Household Income}" ///
					  0.ed_cat = "{bf:Education}" ///
					  1.party = "{bf:Political Party}" ///
					  1.region = "{bf:Region}", ///
					  labsize(small)) ///
			 xtitle("Standard Deviations", size(small)) ///			  
			 ylabel(,labsize(small)) ///
			 ysize(11) xsize(8.5) 

	graph export "${figure}/fig3.png", height(3300) width(2550) replace			   
restore		

********************************************************************************
* Attitudes & Preferences Coefficient Plot II (Appendix)
********************************************************************************

rename attitude_std att
rename policy_std pol

foreach v of var * {
	local l`v' : variable label `v'
	if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

***Restrict to Control Group
preserve
	keep if treat==0

	estimates clear
	
	***
	foreach y in att pol { 	
		foreach x in frl_expdiff_frlnfrl perfrl log_enrl ///
					 ncharters ppexp_tot pprev_tot sesavgall {
		
			center `x', inplace standardize
			label var `x' `"`l`x''"'
			
			quietly eststo m_`y'_`x': reg `y' `x', robust		 			 
		} 	 
	} 		
		
	coefplot (m_att*, ///
			  mcolor(${color1}) ///
			  msymbol(Oh) msize(vsmall) ///
			  ciopts(recast(rcap) color(${color1}%50)) ///
			  drop(_cons)) ///
			 (m_pol*, ///
			  mcolor(${color2}) mfcolor(${color2}) ///
			  msize(vsmall) msymbol(T) ///
			  ciopts(recast(rcap) color(${color2}%50)) ///
			  drop(_cons)) ///
			 , base ///
		 	 headings(0.frl_expdiff_frlnfrl = " " ///
					  perfrl = " " ///
					  log_enrl = " " ///	
					  ncharters = " " ///
					  ppexp_tot = " " ///
					  pprev_tot = " " ///
					  sesavgall = " " ///
					  , labsize(small)) ///
			 xline(0, lcolor(black)) ///
			 plotlabels("Attitude Index" "Policy Index") /// 
			 xtitle("Standard Deviations", size(small)) ///			  
			 ylabel(,labsize(small))
			 
	graph export "${figure}/figA3.png", height(2550) width(3300) replace			   
restore


********************************************************************************
* Perceived & Actual Segregration Coefficient Plot (Appendix)
********************************************************************************

estimates clear

foreach y in att pol { 	
	foreach x in frl_expdiff_frlnfrl perfrl log_enrl ///
				 ncharters ppexp_tot pprev_tot sesavgall {
	
		center `x', inplace standardize
		label var `x' `"`l`x''"'
		
		quietly eststo m_s_`x': reg seg_diff `x', robust		 
	} 		
}		

coefplot (m_s_*, ///
			  mcolor(${color3}) ///
			  msymbol(Oh) msize(vsmall) ///
			  ciopts(recast(rcap) color(${color3}%50)) ///
			  drop(_cons)) ///
		 (m_s_*, ///
		  mcolor(none) mfcolor(none) ///
		  msize(vsmall) msymbol(O) ///
		  ciopts(recast(rcap) color(none)) ///
		  drop(_cons)) ///				  
		 , base ///		 
		 headings(frl_expdiff_frlnfrl = " " ///
				  perfrl = " " ///
				  log_enrl = " " ///	
				  ncharters = " " ///
				  ppexp_tot = " " ///
				  pprev_tot = " " ///
				  sesavgall = " " ///
				  , labsize(small)) ///
		 xline(0, lcolor(black)) ///
		 plotlabels(`"Difference Between Perceived & Actual Segregration"' " ") /// 
		 xtitle("Standard Deviations", size(small)) ///			  
		 ylabel(,labsize(small))

graph export "${figure}/figA5.png", height(2550) width(3300) replace			   