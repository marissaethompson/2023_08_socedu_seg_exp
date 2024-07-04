# 2023_08_socedu_seg_exp

[![DOI](https://zenodo.org/badge/667588840.svg)](https://zenodo.org/doi/10.5281/zenodo.12646562)

Authors: Marissa Thompson &amp; Sam Trejo

Title: My school district isn't segregated: Experimental evidence on the effect of information on parental preferences regarding school segregation

Journal: Sociology of Education

Date: 2023

ReadMe Version: 01 

----------------------------------------------------------------------------------

This replication package contains data and code to reproduce the analysis, tables, 
and figures included in the paper. 

Instructions: Executing the master script (_MAIN.do) will run the analysis and generate all figures and tables. 
Prior to running the file, users will need to change the global macros at the top of the 
Master script. Details on each of the file inputs and outputs can be found below. All analyses were run using Stata 17. 

----------------------------------------------------------------------------------

Description of do files: 

0. ~MAIN.do
	* Input: lucid_segregation_survey.dta
	* Output: (runs all other do files, produces all tables and figures) 

1.  A___pca_tabA2.do 
	* Input: lucid_segregation_survey.dta
	* Data Output: data_analytic_${date}.dta, data_full_${date}.dta
	* Table Output:	tabA2.csv

2.  B___sumstat_tab1.do
	* Input: data_analytic_${date}.dta
	* Output: tab1.xlsx

3.  C___desc_tab2_tab3
	* Input: data_analytic_${date}.dta
	* Output: tab2.csv, tab3.csv

4.  D___effects_tab4_tab5_tabA6_tabA7_tabA8
	* Input: data_analytic_${date}.dta, data_full_${date}.dta
	* Output: tab4.csv, tab5.csv, tabA6.csv, tabA7.csv, tabA8.csv 

5.  E___coefficient_plots.do
	* Input: data_analytic_${date}.dta
	* Output: fig3.png, figA3.png, figA5.png

6.  F___vbar_fig4_figA4.do
	* Input: data_analytic_${date}.dta
	* Output: fig4.png, figA4.png

7.  G___hbar_fig5.do
	* Input: data_analytic_${date}.dta
	* Output: fig5.png

8.  H___zip_tabA1_figA1
	* Input: tl_2019_us_sdu.dta, PDP05_202_USSchoolDistrictAll_119174520887.dta, PDP05_202_USSchoolDistrictAll_11917242922.dta, tl_2019_us_zcta510, grf19_lea_zcta5ce10
	* Output: tabA1.xlsx, figA1.png

9.  I___demo_tabA4
	* Input: data_analytic_${date}.dta
	* Output: tabA4.csv

10. J___hist_figA2
	* Input: data_analytic_${date}.dta
	* Output: figA2.png

