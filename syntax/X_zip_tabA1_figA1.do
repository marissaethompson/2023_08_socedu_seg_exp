
*** load district shapefile .dbf [one row for every district]
import delimited "${data}/raw/edge_19/tl_2019_us_sdu.csv", clear 

keep aland geoid name
rename geoid leaid 
rename aland district_area

*** leaid to string
gen str_leaid = string(leaid,"%07.0f")
drop leaid
rename str_leaid leaid

label data "Total Land of Each Geographic School District in 2019"

save "${dir}/data/clean/district_area_clean.dta", replace 

***************************************************************************
*** COMBINE & CLEAN DISTRICT PARENT POPULATION COUNTS VIA INVERSE VARIANCE WEIGHTING
***************************************************************************

*** load ACS parents of children 5-17 population counts for 2009-2013 [one row for every district]
use "${data}/raw/edge_parents_09-13/PDP05_202_USSchoolDistrictAll_119174520887.dta", clear

keep geoid leaid year pdp05_1est pdp05_1moe
rename pdp05_1est parent_09_13

*** generate inverse variance weights
gen iv_parent_09_13 = 1/(pdp05_1moe/1.645)^2

*** hold data
tempfile hold
save `hold', replace

*** load ACS parents of children 5-17 population counts for 2014-2018 [one row for every district]
use "${data}/raw/edge_parents_14-18/PDP05_202_USSchoolDistrictAll_11917242922.dta"

keep geoid leaid year pdp05_1est pdp05_1moe
rename pdp05_1est parent_14_19

*** generate inverse variance weights
gen iv_parent_14_19 = 1/(pdp05_1moe/1.645)^2

*** merge 2009-2013 with 2014-2018 data
merge 1:1 leaid geoid using `hold', keep(1 3) nogenerate

*** combine 2009-2013 with 2014-2018 into a single variable via inverse variance weighting
gen parent=parent_09_13*(iv_parent_09_13/(iv_parent_09_13+iv_parent_14_19))+parent_14_19*(iv_parent_14_19/(iv_parent_09_13+iv_parent_14_19))
replace parent=parent_14_19 if parent==.
replace parent=parent_09_13 if parent==.

keep leaid parent

*** leaid to string
gen str_leaid = string(leaid,"%07.0f")
drop leaid
rename str_leaid leaid

label data "Total Number of Parents in Each Geographic School District in 2019"

save "${data}/clean/district_parent_count_clean.dta", replace

***************************************************************************
*** GENERATE PARENT POPULATION DENSITY
***************************************************************************

*** load ACS parents of children 5-17 population counts [one row for every district]
use "${data}/clean/district_parent_count_clean.dta", clear

*** merge with district land area file [one row for every district]
merge 1:1 leaid using "${data}/clean/district_area_clean.dta", keep(1 3) nogenerate

***convert from square meters to square miles
replace district_area=district_area/2590000

*** generate parents population density variable
gen parent_density = parent/district_area

*** impute parental desnity for observations missing district area (and make flag)
sum district_area, detail
replace parent_density = parent/`r(p50)' if parent_density==.
gen impute_parent_density_flag = district_area==.

keep leaid district_area parent_density

label data "Parent Density in Each Geographic School District in 2019"

save "${data}/clean/district_parent_density_clean.dta", replace

***************************************************************************
*** CLEAN ZCTA LAND AREA FILE
***************************************************************************

*** load ZCTA shapefile .dbf [one row for every ZCTA]
import delimited "${data}/raw/zcta_19/tl_2019_us_zcta510.csv", clear 

keep aland zcta5ce10
rename zcta5ce10 zip
rename aland zip_area

gen str_zip = string(zip,"%05.0f")
drop zip
rename str_zip zip

***convert from square meters to square miles
replace zip_area=zip_area/2590000

label data "Total Land of Each Zip Code Tabulation Area in 2019"

save "${dir}/data/clean/zcta_area_clean.dta", replace 

***************************************************************************
*** CLEAN ZCTA -> DISTRICT CROSSWALK DATA & MERGE PARENT DENSITY
***************************************************************************

*** load ZCTA - district geographic relationship file [one row for every ZCTA - district intersection]
use "${data}/raw/edge_grf_19/grf19_lea_zcta5ce10.dta", clear

rename *, lower
keep leaid name_lea19 zcta5ce10 landarea
rename zcta5ce10 zip
rename landarea intersect_area

*** merge on parent density
merge m:1 leaid using "${dir}/data/clean/district_parent_density_clean.dta", keep(3) nogenerate

*** merge on ZCTA land area
merge m:1 zip using "${dir}/data/clean/zcta_area_clean.dta", keep(3) nogenerate

order zip leaid name_lea19 intersect_area zip_area district_area parent_density

***calculate fraction of area of ZCTA that each ZCTA - district intersection comprises
gen intersect_zip_area=round(intersect_area/zip_area, .0001)

*** calculate (estimated) number of parents in each ZCTA - district intersection 
gen intersect_parent=parent_density*intersect_area

***calculate total number of parents in ZCTA
egen zip_parent = total(intersect_parent), by(zip)
replace zip_parent = 1 if zip_parent==0

***calculate fraction of parents in ZCTA in each ZCTA - district intersection
gen double intersect_zip_parent=intersect_parent/zip_parent

label data "*INTERSECTION* Between Zip Code Tabulation Area & Geographic School District in 2019"

save "${dir}/data/clean/zcta-district_grf_clean.dta", replace

***************************************************************************
*** CALCULATE FRACTION OF PARENTS IN ASSIGNED DISTRICT
***************************************************************************

use "${dir}/data/clean/zcta-district_grf_clean.dta", clear

*** drop zip - district intersections with <2% of the parent population
keep if intersect_zip_parent>.02

*** round number of parents in a zip for use as fweight
replace zip_parent=round(zip_parent, 1)

*** save out tabulation of number of districts in each zip
preserve
egen districts = count(leaid), by(zip)
keep zip zip_parent districts 
duplicates drop
*tab2xl districts [fweight=zip_parent] using "${table}\zip_dist_tab", replace row(1) col(1)
*tab districts
restore

*** keep on the preferred zip - district combination (i.e. the one with the highest fraction of parents)
egen double max_intersect_zip_parent = max(intersect_zip_parent), by(zip)
keep if max_intersect_zip_parent == intersect_zip_parent
isid zip

*** create histogram of estimated fraction of parents in the assigned zip - district intersection 
twoway hist intersect_zip_parent, yaxis(1) frac bin(50) barwidth(.013) color(${color1}%50) || ///
	   hist intersect_zip_parent, yaxis(2) freq bin(50) barwidth(.013) color(none) ///
			ylabel(,format(%9.0g) axis(2)) ///
			xlabel(0(.2)1) ///
			title("A)") ///			
			xtitle("Estimated Fraction of Parents Living in Assigned District") ///
			ytitle("Fraction of" "Zip Codes", axis(1) size(small) orientation(horizontal)) ///
			ytitle("Number of" "Zip Codes", axis(2) size(small) orientation(horizontal)) ///
			saving("${figure}/temp/zip_frac_parents_hist", replace) ///
			legend(off)

*** calculate estimated proportion of parents in assigned district
sum intersect_zip_parent [fweight=zip_parent], det
display `r(mean)'

*** restrict variables
gen max_zip=zip
rename leaid max_leaid
keep zip max_leaid intersect_zip_area intersect_zip_parent max_zip
order zip max_leaid max_zip

save "${dir}/data/clean/zcta-district_crosswalk.dta", replace

***************************************************************************
*** PREPARE ONTO THE SEGREGATION VARIABLES 
***************************************************************************

*** load SEDA covariates [one row for every district]
use "${data}/raw/seda/district_covariates_from_acs_and_ccd_all_measures.dta", clear 
keep sedalea frl_expdiff_frlnfrl
gen leaid = string(sedalea,"%07.0f")
gen max_leaid = string(sedalea,"%07.0f")
gen seg = frl_expdiff_frlnfrl 
gen max_seg = frl_expdiff_frlnfrl

*** hold data
tempfile seg
save `seg', replace

***************************************************************************
*** MERGE SEGREGATION ON TO ZCTA - DISTRICT INTERSECTIONS
***************************************************************************

use "${dir}/data/clean/zcta-district_grf_clean.dta", clear

merge m:1 zip using "${dir}/data/clean/zcta-district_crosswalk.dta", keep(3) nogenerate

merge m:1 leaid using `seg', keep(3) nogenerate
drop max_seg
merge m:1 max_leaid using `seg', keep(3) nogenerate

/*
*** keep on the preferred zip - district combination (i.e. the one with the highest fraction of parents)
egen double max_intersect_zip_parent = max(intersect_zip_parent), by(zip)
keep if max_intersect_zip_parent == intersect_zip_parent
isid zip

*** calculate estimated proportion of parents in preferred zip
sum intersect_zip_parent [fweight=zip_parent], det
display `r(mean)'
*/

***************************************************************************
*** CALCULATE DIFFERENCE BETWEEN ACTUALLY AND ASSIGNED DISTRICT SEGREGATION
***************************************************************************

foreach var in seg max_seg {
	gen `var'_cat=.
	replace `var'_cat=1 if inrange(`var', 0, (0.028/2)) 
	replace `var'_cat=2 if inrange(`var', (0.028/2), ((0.028+0.111)/2))
	replace `var'_cat=3 if inrange(`var', ((0.028+0.111)/2), ((0.111+0.25)/2))
	replace `var'_cat=4 if inrange(`var', ((0.111+0.25)/2), ((0.25+0.444)/2))
	replace `var'_cat=5 if inrange(`var', ((0.25+0.444)/2),((0.444+0.694)/2))
	replace `var'_cat=6 if `var'> ((0.444+0.694)/2) & `var'!=. 
}

*** round number of parents in a zip for use as fweight
replace intersect_parent=round(intersect_parent, 1)

corr seg_cat max_seg_cat [fweight= intersect_parent]
display "`r(rho)'"

gen diff=seg_cat-max_seg_cat
gen abs_diff=abs(diff)

twoway hist abs_diff [fweight=intersect_parent], ///
			fraction discrete color(${color2}%50) barwidth(.9) ///
			title("B)") ///
			xtitle("Absolute Value of Difference Between Actual and Assigned Segregation Category") ///		
			ytitle("Fraction of" "Parents", orientation(horizontal) size(small)) ///
			saving("${figure}/temp/cat_error_hist", replace) 

graph combine ///
	  "${figure}/temp/zip_frac_parents_hist" ///
	  "${figure}/temp/cat_error_hist", ///
	  cols(1) ///
	  graphregion(margin(zero)) ///
	  ysize(11) xsize(8.5)

graph export "${figure}/zip_hists_$date.png", height(3300) width(2550) replace
			
tab abs_diff [fweight=intersect_parent]