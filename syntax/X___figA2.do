******************************************************************************** 
* Create histograms of four outcomes variables.
********************************************************************************

********************** TAX & MINUTE INCREASES 
use "${dir}/data/clean/lucid_segregation_survey.dta" , clear

********************** GENERAL ATTITUDE INDEX
twoway hist attitude_std ///
	   , frac ///
	   color(${color1}%50) ///   
	   title("A) Attitude Index", position(12)) ///  
	   xtitle("Standard Deviations") ///
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/attitude", replace)

********************** POLICY PREFERENCE INDEX
twoway hist policy_std ///
	   , frac ///
	   color(${color2}%50) ///
	   title("B) Policy Index", position(12)) ///
	   xtitle("Standard Deviations") ///
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/policy", replace)

********************** TAX INCREASES 
sum tax, detail
twoway hist tax if inrange(tax, 0, `r(p95)') ///
	   , frac ///
	   color(${color3}%50) ///
	   title("C) Tax Increase", position(12)) /// 
	   xtitle("Dollars") ///
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/tax" , replace)
	   
********************** ADDITIONAL TRAVEL TIME 	   
sum minutes_additional, detail
twoway hist minutes_additional if inrange(minutes_additional, `r(p5)', `r(p95)') ///
	   , frac ///
	   color(${color4}%50) ///   
	   title("D) Additional Travel Time", position(12)) ///
	   xtitle("Minutes") ///	   
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/min", replace)

********************** ADDITIONAL TRAVEL TIME 	   	   
graph combine ///
	  "${figure}/temp/attitude" ///
	  "${figure}/temp/policy" ///
	  "${figure}/temp/tax" ///
	  "${figure}/temp/min", ///
	  cols(2) ///
	  graphregion(margin(zero)) ///
      l1title("Fraction of" "Parents", orientation(horizontal))

 graph export "${figure}/quad_hist_$date.png", height(2550) width(3900) replace
