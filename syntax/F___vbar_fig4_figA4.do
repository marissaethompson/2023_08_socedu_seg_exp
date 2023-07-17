******************************
* Load Data
******************************

use "${dir}/data/clean/data_analytic_${date}.dta" , clear

********************************************************************************
* FIGURE 4: DOUBLE BAR GRAPH 
********************************************************************************

***left panel
preserve

	twoway__histogram_gen seg_guess, gen(guess cat1) fraction discrete
	twoway__histogram_gen seg_actual, gen(actual cat2) fraction discrete

	replace actual = 0 if _n==6
	replace cat2 = 6 if _n==6

	replace cat1 = cat1 -.19
	replace cat2 = cat2 +.19

	twoway bar guess cat1, lcolor(black) fcolor(black) fintensity(100) lwidth(medthick) barwidth(.35)  ///
		   || ///
		   bar actual cat2, lcolor(black) fcolor(none) lwidth(medthick) barwidth(.35) ///
			   title(" " "A) Perceived & Actual", position(12)) ///
			   xtitle("{&larr} Less Segregated  			           More Segregated {&rarr}"  " " ///
					"Segregation Level", size(small)) ///		
			   ytitle("Fraction of" "Parents",orientation(horizontal)) ///	
			   xlabel(1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 6 "F") ///
			   ylabel(0(.1).4) ///			
			   legend(order(1 "Perceived" 2 "Actual") position(11)) ///
			   fxsize(100) fysize(100) ///
			   graphregion(margin(zero)) ///
			   saving("${figure}/temp/act_per_hist", replace) ///
		   || ///
		   scatter guess cat1, ///
				   mstyle(none) mlabel(guess) mlabpos(6) mlabsize(vsmall) ///
				   mlabcolor(white) mlabformat(%4.2f) ///
		   || ///
		   scatter actual cat2 if cat2<6, ///
		   mstyle(none) mlabel(actual) mlabpos(6) mlabsize(vsmall) ///
		   mlabcolor(black) mlabformat(%4.2f) ///
		   || ///
		   scatter actual cat2 if cat2>=6, ///
		   mstyle(none) mlabel(actual) mlabpos(12) mlabsize(vsmall) ///
		   mlabcolor(black) mlabformat(%4.2f)	   
		   
restore
	   
***right panel	
preserve	
		
	recode seg_diff (-3 -4 -5 = -3 "≤-3") (-2 = -2 "2") (3 4 5 = 3 "≥3"), generate(bin_seg_diff) label(new)

	twoway__histogram_gen bin_seg_diff, gen(diff cat) fraction discrete

	twoway bar diff cat, lcolor(none) fcolor(black) fintensity(50) lwidth(medthick)  barwidth(.7) ///
				title(" " "B) Difference Between Perceived & Actual", position(12)) ///
				xtitle("{&larr} Underestimators    	 	   			 	 Overestimators {&rarr}" " " ///
				"Difference in Segregation Level", size(small)) ///	
				xlabel(-3(1)3, valuelabel) ///
				ylabel(0(.1).4) ///			
				ytitle(" ") ///						
				legend(on order(1 "Perceived - Actual") position(11)) ///
				/// addlabels addlabopts(yvarformat(%4.2f) mlabposition(6) mlabcolor(green)) ///
				fxsize(100) fysize(100) ///
				graphregion(margin(zero)) ///
				saving("${figure}/temp/diff_hist", replace) ///
				|| ///
		  scatter diff cat, ///
				  mstyle(none) mlabel(diff) mlabpos(6) mlabsize(vsmall) ///
				  mlabcolor(white) mlabformat(%4.2f) 	
				  
restore

***	combine and export	
graph combine ///
	  "${figure}/temp/act_per_hist" ///
	  "${figure}/temp/diff_hist", ///
	  cols(2) ///
	  graphregion(margin(zero)) ysize(8.5) xsize(14)  ///
	  ycommon
  
graph export "${figure}/fig4_vbar_$date.png", height(2550) width(4200) replace

********************************************************************************
* FIGURE A5: DOUBLE BAR GRAPH 
********************************************************************************

***second histogram ALT
preserve

	twoway__histogram_gen seg_diff, gen(diff cat) fraction discrete

	twoway bar diff cat, lcolor(none) fcolor(black) fintensity(50) lwidth(medthick)  barwidth(.7) ///
				title("Difference Between Perceived & Actual", position(12)) ///
				xtitle("{&larr} Underestimators    	 	   			 	Overestimators {&rarr}" " " ///
				"Difference in Segregation Level", size(small)) ///	
				xlabel(-5(1)5, valuelabel) ///
				ylabel(0(.1).2) ///			
				ytitle(" ") ///						
				legend(on order(1 "Perceived - Actual") position(11)) ///
				/// addlabels addlabopts(yvarformat(%4.2f) mlabposition(6) mlabcolor(green)) ///
				fxsize(100) fysize(100) ///
				graphregion(margin(zero)) ///
				|| ///
		  scatter diff cat, ///
				  mstyle(none) mlabel(diff) mlabpos(6) mlabsize(tiny) ///
				  mlabcolor(white) mlabformat(%4.2f) 	
				  
	graph export "${figure}/figA4_vbar_$date.png", height(2550) width(3300) replace
	
restore

