******************************************************************************** 
* Main Do File 

* Title: My school district isn't segregated: Experimental evidence on the effect of information on parental preferences regarding school segregation
* Authors: Marissa Thompson & Sam Trejo 
* Journal: Sociology of Education
* Date: 2023
********************************************************************************

***********************************************************************************
*** SETUP
***********************************************************************************

version 17

clear all
set more off
set matsize 5000

*** CHECK FOR PACKAGES 
local packages estout tab2xl desctable center scheme-burd coefplot // These packages/schemes must be installed to run the code without errors 

foreach package in `packages' {
	capture : which `package'
	if (_rc) {
		display as result in smcl `"Please install user-written package `package' in order to run this syntax;"'
		exit 199
	}
}


*** SET GRAPHIC SCHEME 

set scheme burd
capture	graph set window fontface "Calibri Light" 


***********************************************************************************
*** SET DIRECTORY GLOBALS
***********************************************************************************

global dir ..
cd ${dir}
pwd
global dir "`c(pwd)'"

***set files path globals
global data "${dir}/data"
global dofile "${dir}/syntax"
global table "${dir}/tables"
global figure "${dir}/figures"

***set color globals for figures
global color1 ebblue
global color2 maroon
global color3 midgreen*1.35
global color4 lavender*1.5

***********************************************************************************
*** DATE GLOBAL
***********************************************************************************

*makes stata date in numeric year_month_day format
quietly {
	global date=c(current_date)

	***day
	if substr("$date",1,1)==" " {
		local val=substr("$date",2,1)
		global day=string(`val',"%02.0f")
	}
	else {
		global day=substr("$date",1,2)
	}

	***month
	if substr("$date",4,3)=="Jan" {
		global month="01"
	}
	if substr("$date",4,3)=="Feb" {
		global month="02"
	}
	if substr("$date",4,3)=="Mar" {
		global month="03"
	}
	if substr("$date",4,3)=="Apr" {
		global month="04"
	}
	if substr("$date",4,3)=="May" {
		global month="05"
	}
	if substr("$date",4,3)=="Jun" {
		global month="06"
	}
	if substr("$date",4,3)=="Jul" {
		global month="07"
	}
	if substr("$date",4,3)=="Aug" {
		global month="08"
	}
	if substr("$date",4,3)=="Sep" {
		global month="09"
	}
	if substr("$date",4,3)=="Oct" {
		global month="10"
	}
	if substr("$date",4,3)=="Nov" {
		global month="11"
	}
	if substr("$date",4,3)=="Dec" {
		global month="12"
	}

	***year
	global year=substr("$date",8,4)

	global date="$year"+"_"+"$month"+"_"+"$day"
}

dis "$date"

***********************************************************************************
*** RUN DOFILES
***********************************************************************************

*** Create PCA Variables; Table A2	
do "$dofile/A___pca_tabA2.do"

*** Summary Statistics; Table 1 
do "$dofile/B___sumstat_tab1.do"
	
*** Descriptive Regressions; Tables 2 & 3
do "$dofile/C___desc_tab2_tab3.do"
	
*** Treatment Effect Estimates; Tables 4, 5, A6, A7, & A8
do "$dofile/D___effects_tab4_tab5_tabA6_tabA7_tabA8.do"

*** Coefficient Plots; Figures 3, A3, & A5
do "$dofile/E___coefplot_fig3_figA3_figA5.do" 

*** Side-by-Side Vertical Bar Chart; Figures 4 & A4
do "$dofile/F___vbar_fig4_figA4.do"

*** Horizontal Bar Chart; Figure 5
do "$dofile/G___hbar_fig5.do"

*** Zip to District Robustness; Table A1, Figure A1
do "${dofile}/H___zip_tabA1_figA1"

*** Percieved vs. Actual by Demographics; Table A4
do "$dofile/I___demo_tabA4.do"

*** Histograms; Figure A2
do "$dofile/J___hist_figA2.do"



