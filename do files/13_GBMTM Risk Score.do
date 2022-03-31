cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date: 	July 26, 2020
Last Updated: 	July 26, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Cleaning the offense history data  

Objective: Clean and create arrest count and type to later merge with analytic sample.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all

	
/*=======================================================================================
					Clean Release Type 
=========================================================================================*/
	import excel "Data/Raw Data/Criminal Risk Score .xlsx", sheet("Criminal risk score") firstrow case(lower) clear
	destring control_number, gen(mov_cnt_num)
	codebook mov_cnt_num
	
*** Create test date variable 
	codebook test_dt	
		format test_dt %td

	save "Raw Data/Risk Score.dta", replace 
	
	
*** Merge with full sample data 
	use "Analytic Data/Subsamples/analytic(full_mixed).dta", clear 
		keep mov_cnt_num lastname date_admitdate date_releasedate 
	merge 1:m mov_cnt_num using "Raw Data/Risk Score.dta"

	/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           982
        from master                        90  (_merge==1) // 90 ind
        from using                        892  (_merge==2) // 90 ind

    matched                            72,301  (_merge==3)
    -----------------------------------------
	*/
	
	codebook mov_cnt_num if _merge==2
	codebook mov_cnt_num if _merge==1
	
	/* checked the unmatched (_merge==2) is not in the initial move records either, 
		will drop those unmatched obs in the final sample
		to preserve the same sample across all summary (7/26) */
	drop if _merge==2
	codebook mov_cnt_num
		sort mov_cnt_num

*** Create indicator of test type
	tab test_desc, gen(x)
		rename x1 test_lsir
		rename x2 test_rst 
		
*** Create risk score (for two test types)
	codebook date_releasedate

	gen tag_risk=0 // tag if risk assessment was done within our inc period
		replace tag_risk=1 if test_dt>=date_admitdate & test_dt<=date_releasedate
		replace tag_risk=. if test_dt==. | date_admitdate==. | date_releasedate==.
			tab tag_risk, m
			codebook mov_cnt_num if tag_risk==1
	
	/* NOTE: It probably makes most sense to use the earliest risk score? Since the latter ones
		will partially be based upon the earlier scores. 
		Check with Sarah to see which test type to use, and which test to use (timewise). */
	/* Check how many have taken LSI-R or RST tets */
	codebook mov_cnt_num if test_lsir==1 & tag_risk==1
	codebook mov_cnt_num if test_rst==1 & tag_risk==1

	sort mov_cnt_num test_dt
	bysort mov_cnt_num tag_risk: gen test_count=_N // number of tests taken
		tab test_count, m
		replace test_count=. if tag_risk!=1
	
	/* Create two separate data for lsir and rst tests to identify the first test taken, and then 
		merge the data back together using mov_cnt_num and test_dt */
*** LSI-R 
	preserve 
		keep if test_lsir==1 & tag_risk==1 // 13,769 obs
			drop _merge
		sort mov_cnt_num test_dt 
			bysort mov_cnt_num: gen lsir_count=_n
		save "Raw Data/Risk Score_lsir.dta", replace
	restore	
	
*** RST 	
	preserve 
		keep if test_rst==1 & tag_risk==1 // 25,284 obs
			drop _merge
		sort mov_cnt_num test_dt 
			bysort mov_cnt_num: gen rst_count=_n
		save "Raw Data/Risk Score_rst.dta", replace
	restore	
	
*** Merge together 
		drop _merge
	merge m:1 mov_cnt_num test_dt using "Raw Data/Risk Score_lsir.dta"
		drop _merge
	merge m:m mov_cnt_num test_dt using "Raw Data/Risk Score_rst.dta"
		drop _merge 
	
*** Create first test scores variables for lsir and rst
	gen lsir1=test_score if lsir_count==1 
	bysort mov_cnt_num: egen lsir_score=max(lsir1)
	
	gen rst1=test_score if rst_count==1 
	bysort mov_cnt_num: egen rst_score=max(rst1)
		
/*=======================================================================================
						Keep Release Type Vairables 
=========================================================================================*/
/* NOTE: collapse the release type variable by individuals. */
*** Keep Necessary Variables
	keep mov_cnt_num test_count lsir_score rst_score
		summ test_count lsir_score rst_score
		collapse test_count lsir_score rst_score, by(mov_cnt_num)
	save "Cleaned Data/cleaned(risk score).dta", replace
	
	
/*================ Update Log ================
08/21/20 - SJ		_ finished the do
07/25/20 - SJ 		- started the risk score variable   
 
*/
log close 
	
