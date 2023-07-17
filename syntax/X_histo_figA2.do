******************************************************************************** 
* Create bar graphs

* Edit History
* File Initiatied - 03/31/2021
********************************************************************************

******************************
* Load Data
******************************

use "${dir}/data/clean/data_analytic_${date}.dta" , clear

********************************************************************************
* 
********************************************************************************

twoway hist attitude_std ///
	   , frac ///
	   color(${color1}%50) ///   
	   title("A) Attitude Index", position(12)) ///  
	   xtitle("Standard Deviations") ///
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/attitude", replace)

twoway hist policy_std ///
	   , frac ///
	   color(${color2}%50) ///
	   title("B) Policy Index", position(12)) ///
	   xtitle("Standard Deviations") ///
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/policy", replace)

********************** TAX & MINUTE INCREASES 

sum tax, detail
twoway hist tax if inrange(tax, 0, `r(p95)') ///
	   , frac ///
	   color(${color3}%50) ///
	   title("C) Tax Increase", position(12)) /// 
	   xtitle("Dollars") ///
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/tax" , replace)
	   
sum minutes_additional, detail
twoway hist minutes_additional if inrange(minutes_additional, `r(p5)', `r(p95)') ///
	   , frac ///
	   color(${color4}%50) ///   
	   title("D) Additional Travel Time", position(12)) ///
	   xtitle("Minutes") ///	   
	   ytitle(" ") ///	   	   
	   saving("${figure}/temp/min", replace)
	
graph combine ///
	  "${figure}/temp/attitude" ///
	  "${figure}/temp/policy" ///
	  "${figure}/temp/tax" ///
	  "${figure}/temp/min", ///
	  cols(2) ///
	  graphregion(margin(zero)) ///
      l1title("Fraction of" "Parents", orientation(horizontal))

 graph export "${figure}/quad_hist_$date.png", height(2550) width(3900) replace
