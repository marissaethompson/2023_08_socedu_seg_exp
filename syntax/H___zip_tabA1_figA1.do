
*** load district shapefile .dbf [one row for every district]
use "${data}/census/tl_2019_us_sdu.dta", clear 

keep aland geoid name
rename geoid leaid 
rename aland district_area

*** leaid to string
gen str_leaid = string(leaid,"%07.0f")
drop leaid
rename str_leaid leaid

label data "Total Land of Each Geographic School District in 2019"
tempfile district_area
save `district_area', replace 

***************************************************************************
*** COMBINE & CLEAN DISTRICT PARENT POPULATION COUNTS VIA INVERSE VARIANCE WEIGHTING
***************************************************************************

*** load ACS parents of children 5-17 population counts for 2009-2013 [one row for every district]
use "${data}/census/PDP05_202_USSchoolDistrictAll_119174520887.dta", clear

keep geoid leaid year pdp05_1est pdp05_1moe
rename pdp05_1est parent_09_13

*** generate inverse variance weights
gen iv_parent_09_13 = 1/(pdp05_1moe/1.645)^2

*** hold data
tempfile hold
save `hold', replace

*** load ACS parents of children 5-17 population counts for 2014-2018 [one row for every district]
use "${data}/census/PDP05_202_USSchoolDistrictAll_11917242922.dta"

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

tempfile parent_count 

***  ACS parents of children 5-17 population counts [one row for every district]
save `parent_count', replace

***************************************************************************
*** GENERATE PARENT POPULATION DENSITY
***************************************************************************

*** merge with district land area file [one row for every district]
merge 1:1 leaid using `district_area', keep(1 3) nogenerate

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

tempfile parent_density
save `parent_density', replace

***************************************************************************
*** CLEAN ZCTA LAND AREA FILE
***************************************************************************

*** load ZCTA shapefile .dbf [one row for every ZCTA]
use "${data}/census/tl_2019_us_zcta510.dta", clear 

keep aland zcta5ce10
rename zcta5ce10 zip
rename aland zip_area

gen str_zip = string(zip,"%05.0f")
drop zip
rename str_zip zip

***convert from square meters to square miles
replace zip_area=zip_area/2590000

label data "Total Land of Each Zip Code Tabulation Area in 2019"

tempfile zcta_area
save `zcta_area', replace 

***************************************************************************
*** CLEAN ZCTA -> DISTRICT CROSSWALK DATA & MERGE PARENT DENSITY
***************************************************************************

*** load ZCTA - district geographic relationship file [one row for every ZCTA - district intersection]
use "${data}/census/grf19_lea_zcta5ce10.dta", clear

rename *, lower
keep leaid name_lea19 zcta5ce10 landarea
rename zcta5ce10 zip
rename landarea intersect_area

*** merge on parent density
merge m:1 leaid using `parent_density', keep(3) nogenerate

*** merge on ZCTA land area
merge m:1 zip using `zcta_area', keep(3) nogenerate

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

***************************************************************************
*** CALCULATE FRACTION OF PARENTS IN ASSIGNED DISTRICT
***************************************************************************

*** drop zip - district intersections with <2% of the parent population
keep if intersect_zip_parent>.02

*** round number of parents in a zip for use as fweight
replace zip_parent=round(zip_parent, 1)

*** save out tabulation of number of districts in each zip
preserve
	egen districts = count(leaid), by(zip)
	keep zip zip_parent districts 
	duplicates drop
	tab2xl districts [fweight=zip_parent] using "${table}\tabA1", replace row(1) col(1)
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
			legend(off)

graph export "${figure}/figA1.png", height(1650) width(2550) replace
			
*** calculate estimated proportion of parents in assigned district
sum intersect_zip_parent [fweight=zip_parent], det
display `r(mean)'
