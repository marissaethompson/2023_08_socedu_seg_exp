******************************************************************************** 
* Main Do File 


* Title: Experimental Evidence on Parental Preferences Regarding School Segregation
* Authors: Marissa Thompson & Sam Trejo 
* ReadMe file: _readme.txt
* 
* February 2023
********************************************************************************


***********************************************************************************
*** SETUP
***********************************************************************************

version 17

clear all
set more off
set matsize 5000
pause on

set scheme burd

*set trace on
*capture log close

***********************************************************************************
*** SET DIRECTORY GLOBALS
***********************************************************************************

***set home folder
if "`c(username)'"=="trejo" {
	glob dir "C:\Users\trejo\Dropbox (Princeton)\seg_exp"
	graph set window fontface "Calibri Light" 
}

if "`c(username)'"=="marissathompson" {
	global dir "/Users/marissathompson/Dropbox/_Research/segregation_experiment"
	graph set window fontface "Calibri-Light" 
}

***set files path globals
global data "${dir}/data"
global dofile "${dir}/dofiles"
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

do "$dofile/~data_clean.do" // our file that does initial cleaning (delete before posting)

*** Create PCA Tables 
	* Input: lucid_segregation_survey.dta
	* Data Output: data_analytic_${date}.dta, data_full_${date}.dta
	* Table Output:	pca_$date.csv (Table A2)			

do "$dofile/A___pca_tabA2.do"

*** Produce Table 1 
	* Input: data_analytic_${date}.dta
	* Output: table1_summarystatistics_$date (Table 1)	
do "$dofile/B___sumstat_tab1.do"

*** Regression Results Tables 2 & 3
	* Input: data_analytic_${date}.dta
	* Output: control_attitudes_$date (Table 2); reg_guess_$date.csv (Table 3); do "$dofile/D_desc.do"

*do "$dofile/C___desc_tab2_tab3.do"
	
*** Regression Results Tables 4 & 5
	* Input: data_analytic_${date}.dta, data_full_${date}.dta
	* Output: treatment_effects_$date (Table 4); hetero_treatment_separate_$date.csv (Table 5); treatment_effects_fullsample_$date.csv (Table A4); policy_item_treatment_effects_$date (Table A5)

do "$dofile/D___effects_tab4_tab5_tabA4_tabA5.do"

*** Produce Figure 3 (Coefficient Plots)
	* Input: data_analytic_${date}.dta
	* Output: dist_segdiff_coefplot_$date.png (Figure 3)
do "$dofile/E___coefplot_fig3_figA3_figA5.do" 

*** Produce Figure 4 (Side-by-side Histograms)
	* Input: survey_clean_$date.dta
	* Output: double_hist_$date.png (Figure 4); diff_hist_full_$date.png (Appendix Figure); quad_hist_$date.png (Appendix Figure)
do "$dofile/F___vbar_fig4_figA4.do"

*** Produce Figure 5 (Bar Chart)
	* Input: survey_clean_$date.dta
	* Output: bar_$date.png (Figure 5)
do "$dofile/G___hbar_fig5.do"

?

*** Produce Additional Appendix Tables
	* Input: survey_clean_$date.dta
	* Output: demo_table_$date.csv" (Appendix Table)
do "$dofile/G_appendix.do"

