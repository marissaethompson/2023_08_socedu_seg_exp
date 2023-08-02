
use "${dir}/data/data_analytic_${date}.dta", clear

******************************
* 
******************************

local i = -1

*** loop over bar categories
foreach group in female race hispanic_cat age_median hhi_median ed_cat party region {
	preserve
		*** collapse data by category for bar graph
		display "`group'"
		collapse (mean) mn_seg_diff=seg_diff ///
				 (sd) sd_seg_diff=seg_diff ///
				 (count) n_seg_diff=seg_diff ///
				 , by(`group')
		
		*** generate confidence interval variables
		generate hi_mn_seg_diff = mn_seg_diff + invttail(n-1,0.025)*(sd_seg_diff / sqrt(n_seg_diff))
		generate lo_mn_seg_diff = mn_seg_diff - invttail(n-1,0.025)*(sd_seg_diff / sqrt(n_seg_diff))
		
		*** loop over each subcategory		
		local i = `i' + 2 
		levelsof `group', local(levels) 
		gen cat = .
		foreach x of local levels {
			display "`x'"
			local i = `i' + 1
			replace cat = `i' if `group'==`x'
		}

		tempfile `group'
		save ``group'', replace		
	restore
}

******************************
* 
******************************

***append all categories together
use `female', clear
foreach group in race hispanic_cat age_median hhi_median ed_cat party region {
	append using ``group''
}

***bar graph y-axis labels
label define lbl_bar ///
		1 "{bf:Gender}" ///		
		2 "Male" ///
		3 "{bf:*} Female"  ///
		4 " " ///
		5 "{bf:Race}" ///		
		6 "White" ///
		7 "Black" ///
		8 "American Indian" ///
		9 "Asian" ///
		10 "Other" ///
		11 " " ///
		12 "{bf:Ethnicity}" ///
		13 "Non-Hispanic" ///
		14 "Hispanic" ///
		15 " " ///
		16 "{bf:Age}" ///
		17 "Below Median" ///
		18 "Above Median" ///
		19 " " ///		
		20 "{bf:Household Income}" ///
		21 "Below Median" ///
		22 "{bf:*} Above Median" ///		
		23 " " ///		
		24 "{bf:Education}" ///
		25 "Less than High School" ///
		26 "High School" ///
		27 "2-Year Degree" ///
		28 "4-Year Degree" ///
		29 "{bf:*} Graduate Degree or More" ///
		30 " " ///		
		31 "{bf:Political Party}" ///		
		32 "Democrat" ///
		33 "Republican" ///
		34 "{bf:*} Independent" ///
		35 " " ///
		36 "{bf:Region}" ///
		37 "Northeast" ///
		38 "{bf:*} Midwest" ///
		39 "South" ///
		40 "West" 
label values cat lbl_bar
		
******************************
* 
******************************

*** top/bottom code confidence intervals because American Indian is very imprecise		
replace hi_mn_seg_diff = .8 if hi_mn_seg_diff >.8 & hi_mn_seg_diff !=.	
replace lo_mn_seg_diff = -.8 if lo_mn_seg_diff <-.8 & lo_mn_seg_diff !=.
		
***produce bar graph	
twoway bar mn_seg_diff cat ///
		   , horizontal ///
		   lcolor(${color3}%63) fcolor(${color3}%32) ///
		   barwidth(.9) ///
		   ylabel(1/40, valuelabels ang(horizontal) labsize(vsmall) notick)  ///
	   || ///
	   rcap hi_mn_seg_diff lo_mn_seg_diff cat ///
	        , horizontal ///
			lcolor(black%50)  ///
			xscale(range(-.5 .5)) ///
			msize(small) ///
		    xtitle(" " "Difference Between Perceived & Actual Segregration" ///
			       , size(small)) ///		  
			ytitle(" ") ///
			xline(0, lcolor(black)) ///
			yscale(reverse) ///
			legend(off) 
			
graph export "${figure}/fig5.png" ///
			 , replace ///
			 height(3300) ///
			 width(3000) 



