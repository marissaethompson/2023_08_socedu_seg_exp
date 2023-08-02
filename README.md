# 2023_08_socedu_seg_exp

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

1. ~MAIN.do
	* Input: lucid_segregation_survey.dta
	* Output: (runs all other do files, produces all tables and figures) 

2. A___pca_tabA2.do 
	* Input: lucid_segregation_survey.dta
	* Data Output: data_analytic_${date}.dta, data_full_${date}.dta
	* Table Output:	tabA2.csv

3. B___sumstat_tab1.do
	* Input: data_analytic_${date}.dta
	* Output: tab1.xlsx

4. C___desc_tab2_tab3
	* Input: data_analytic_${date}.dta
	* Output: tab2.csv, tab3.csv

5. D___effects_tab4_tab5_tabA6_tabA7_tabA8
	* Input: data_analytic_${date}.dta, data_full_${date}.dta
	* Output: tab4.csv, tab5.csv, tabA6.csv, tabA7.csv, tabA8.csv 
?

 


4. C_coefficient_plots.do
	* Input: survey_clean_$date.dta
	* Output: dist_segdiff_coefplot_$date.png (Figure 3)

5. D_histograms.do
	* Input: survey_clean_$date.dta
	* Output: double_hist_$date.png (Figure 4); diff_hist_full_$date.png (Appendix Figure); quad_hist_$date.png (Appendix Figure)

6. E_bar_graphs.do
	* Input: survey_clean_$date.dta
	* Output: bar_$date.png (Figure 5)

7. F_regressions.do
	* Input: survey_clean_$date.dta
	* Output: control_attitudes_$date (Table 2); reg_guess_$date.csv (Table 3); treatment_effects_$date (Table 4); hetero_treatment_separate_$date.csv (Table 5); treatment_effects_fullsample_$date.csv (Appendix Table); policy_item_treatment_effects_$date (Appendix Table)

8. G_appendix.do
	* Input: survey_clean_$date.dta
	* Output: demo_table_$date.csv" (Appendix Table)

