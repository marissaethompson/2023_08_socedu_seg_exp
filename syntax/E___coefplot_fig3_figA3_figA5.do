
******************************
* Load Analytic Sample
******************************

use "${dir}/data/clean/data_analytic_${date}.dta" , clear

********************************************************************************
* Coefplot figure 3 
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

	graph export "${figure}/fig3_$date.png", height(3300) width(2550) replace			   
restore		

********************************************************************************
* Coefplot appendix
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
			 
	graph export "${figure}/figA3_$date.png", height(2550) width(3300) replace			   
restore


********************************************************************************
* Coefplot appendix
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

graph export "${figure}/figA5_$date.png", height(2550) width(3300) replace			   

/*

*graph save "${figure}/temp/dist_coefplot1", replace
*graph save "${figure}/temp/dist_coefplot2", replace 


			 coeflabels(frl_expdiff_frlnfrl = " " ///
					    perfrl = " " ///
					    log_enrl = " " ///	
					    ncharters = " " ///
					    ppexp_tot = " " ///
					    pprev_tot = " " ///
					    sesavgall = " " ///
					    , labsize(small)) ///	

	
	graph combine ///
	  "${figure}/temp/dist_coefplot1" ///
	  "${figure}/temp/dist_coefplot2" ///
	  , cols(2) xcommon ///
	  graphregion(margin(zero))						
						
********************************************************************************
* Coefplot figure 5 
********************************************************************************

estimates clear

foreach x in female race hispanic_cat age_median ///
			 hhi_median ed_cat party region {
	quietly eststo m_`x': reg seg_diff i.`x', robust		 
}	

coefplot (m_*, ///
		  mcolor(${color3}) mfcolor(${color3}%50)  ///
		  msymbol(O) msize(vsmall) ///
		  ciopts(recast(rcap) color(${color3}%50)) ///
		  drop(_cons)) ///
		 , base ///
		 xline(0, lcolor(black)) ///
		 /// plotlabels("Actual - Perceived Segregation") /// 
		 headings(0.female ="{bf:Gender}" ///
				  0.race = "{bf:Race}" ///
				  0.hispanic_cat = "{bf:Ethnicity}" ///		  
                  0.age_median = "{bf:Age}" ///
                  0.hhi_median = "{bf:Household Income}" ///
                  0.ed_cat = "{bf:Education}" ///
                  1.party = "{bf:Political Party}" ///
                  1.region = "{bf:Region}", ///
				  labsize(small)) ///
		 xtitle("Difference Between" "Perceived & Actual Segregration" ///
		        , size(small)) ///		  
		 ylabel(,labsize(small)) ///
         ysize(11) xsize(8.5) 

graph export "${figure}/percieved_actual_coefplot_$date.png", height(3300) width(2550) replace
