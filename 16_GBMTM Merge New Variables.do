cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date: 	July 27, 2020
Last Updated: 	July 27, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Merge new variables from Bob to the analytic  

Objective: Merge new variables from Bob with analytic sample to later run descriptives.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all
	
/*=======================================================================================
					Merge Cleaned files to analytic
=========================================================================================*/
*** Merge with full sample data
	use "Analytic Data/Subsamples/analytic(full_mixed).dta", clear 
		rename _merge prior_merge
	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(offense history).dta" // all matched
		rename _merge offense_merge
		
	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(release type).dta" // all matched
		rename _merge release_merge
	
	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(program participation).dta" // all matched
		rename _merge program_merge
		
	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(work assignment).dta" // all matched
		rename _merge work_merge

	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(risk score).dta" // all matched
		rename _merge risk_merge
		
	save "Analytic Data/Subsamples/analytic(full_new vars).dta", replace 

	
*** Merge with 12M sample data
	use "Analytic Data/Subsamples/analytic(24 month final).dta", clear 
		rename _merge prior_merge
	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(offense history).dta" 
		drop if _merge==2 // 5,120 not in the 24M sample
		rename _merge offense_merge
		
	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(release type).dta" 
		drop if _merge==2 // 5,120 not in the 24M sample
		rename _merge release_merge
	
	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(program participation).dta" 
		drop if _merge==2 // 5,120 not in the 24M sample
		rename _merge program_merge

	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(work assignment).dta" 
		drop if _merge==2 // 5,120 not in the 24M sample
		rename _merge work_merge

	merge 1:1 mov_cnt_num using "Cleaned Data/cleaned(risk score).dta"
		drop if _merge==2 // 5,120 not in the 24M sample
		rename _merge risk_merge
		
	save "Analytic Data/Subsamples/analytic(24m_new vars).dta", replace 

	
/*================================================================================
							SCRATCH PAD
==================================================================================

		
	*/
	
/*================ Update Log ================
08/21/20 - SJ		- Finished work and risk score merge for 12m and 24m
07/27/20 - SJ 		- Finished the merge for arrest count and release type

*/
log close 
	
