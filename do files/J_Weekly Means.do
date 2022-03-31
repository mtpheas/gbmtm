cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date:  	October 15, 2020
Last Updated: 	October 19, 2020 (BP)

Program Description: 	PA Visits 
						Weekly Trends   

Objective: 	The objective is to plot visit and misconduct weekly rather than 
	monthly. This will breakdown by outcome and by group. 


See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all

/*=======================================================================================
							Monthly Probability Output 
-----------------------------------------------------------------------------------------                       
The following code will output the weekly probabilites of misconduct and visits for the 
	full (24m) sample, and for each of the classified groups based on the AvePP. 
    
 Steps:
         (1) Monthly Visits and Misconduct Probability 
		 (2) Monthly Visit and Misconduct Count  
=========================================================================================*/ 
*** Open Analytic 24M Data 
	use "Analytic Data/Subsamples/analytic(24 month final).dta", clear
		/* This is the finalized dataset for the 24 month sample that includes 
			the group assignemnts based on the AvePP. */ 

/*=======================================================================================
						(1) Weekly Visit and Misconduct Probability 
=========================================================================================*/
*** Full Sample Prbability 
	foreach i in "visits" "misc" {
		summ `i'_weekspre1-`i'_weekspre109, sep(0)
		outreg2 `i'_weekspre1-`i'_weekspre109 using "..\Tables and Figures\outreg2\GBMTM_Weekly Mean Full Sample.xls", replace sum(log) keep(`i'_weekspre1-`i'_weekspre109)
		}
	
*** 24M Sample Probability 
	use "Analytic Data/Subsamples/analytic(24 month final).dta", clear
	foreach i in "visits" "misc" {
		summ `i'_weekspre1-`i'_weekspre109, sep(0)
		outreg2 `i'_weekspre1-`i'_weekspre109 using "..\Tables and Figures\outreg2\GBMTM_Weekly Mean 24m.xls", replace sum(log) keep(`i'_weekspre1-`i'_weekspre109)
		}
		
*** Weekly Probability by Group 
	use "Analytic Data/Subsamples/analytic(24 month final).dta", clear
	foreach x of numlist 1/6 {
		preserve 
			keep if groupind_24m6g==`x'
					foreach i in "visits" "misc" {
						summ `i'_weekspre1-`i'_weekspre109, sep(0)
							outreg2 `i'_weekspre1-`i'_weekspre109 using "..\Tables and Figures\outreg2\GBMTM_Weekly Mean 24m Group `x'.xls", replace sum(log) keep(`i'_weekspre1-`i'_weekspre109)
						}
		restore 
		}
	
/*=======================================================================================
						(2) Weekly Visit and Misconduct Count
=========================================================================================*/
*** Full Sample Count 
	foreach i in "visits" "misc" {
		summ c_`i'_weekspre1-c_`i'_weekspre109, sep(0)
		outreg2 c_`i'_weekspre1-c_`i'_weekspre109 using "..\Tables and Figures\outreg2\GBMTM_Weekly Mean Count Full Sample.xls", replace sum(log) keep(c_`i'_weekspre1-c_`i'_weekspre109)
		}
	
*** 24M Sample Count 
	use "Analytic Data/Subsamples/analytic(24 month final).dta", clear
	foreach i in "visits" "misc" {
		summ c_`i'_weekspre1-c_`i'_weekspre109, sep(0)
		outreg2 c_`i'_weekspre1-c_`i'_weekspre109 using "..\Tables and Figures\outreg2\GBMTM_Weekly Mean Count 24m.xls", replace sum(log) keep(c_`i'_weekspre1-c_`i'_weekspre109)
		}
		
*** Weekly Count by Group 
	use "Analytic Data/Subsamples/analytic(24 month final).dta", clear
	foreach x of numlist 1/6 {
		preserve 
			keep if groupind_24m6g==`x'
					foreach i in "visits" "misc" {
						summ c_`i'_weekspre1-c_`i'_weekspre109, sep(0)
							outreg2 c_`i'_weekspre1-c_`i'_weekspre109 using "..\Tables and Figures\outreg2\GBMTM_Weekly Mean Count 24m Group `x'.xls", replace sum(log) keep(c_`i'_weekspre1-c_`i'_weekspre109)
						}
		restore 
		}


/*================ Update Log ================
10/15/20 - MP 	- Began the .do file  
 
*/
log close 

/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================		
