cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant and Sydney Jaw
Start Date: 	March 13, 2020
Last Updated: 	July 10, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Descriptive Statistics for all samples. 

Objective: Create summary statistics table for the full sample, 12 month subsample,
			24 months subsample by the assigned group. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all


/*=======================================================================================
					Create Group Assignments with Full Sample 
-----------------------------------------------------------------------------------------			
The following code will run the GBMTM in order to then create the appopriate group 
	indicators. After creating the indicators, we will make the apporpriate cuts in order 
	to get the descpritives. 
	
Steps: 
	(1) Use the full data and run the model 
		a) Create the group indicators 
	(2) Run the Descriptives by Group 
	
NOTE: We should consider creating another sample dataset with the group assignments in 
	them. 
=========================================================================================*/

	

/*=======================================================================================
						Run Descriptives by Loop (3 Group and 6 Group)
=========================================================================================*/
use "Analytic Data\Subsamples\analytic(24 month final).dta", clear

	
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop25 dem_prop50 dem_prop75 dem_proptotal dem_propsent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind24m visits_eventcount24m visits_count24m misc_ind24m misc_count24m misc_max24m  misc_a24m  misc_acount24m"
foreach g of numlist 6 {
	forval i=1/`g' {
		preserve 
			keep if group_`g'group==`i'
			di "group_`g'group==`i'"
			***Demographics Table 
				summ `dems', sep(0)
				order `dems', after(mov_cnt_num) 
				outreg2 `dems' using "..\Tables and Figures\outreg2\GBMTM Descriptives_24 Months `g'G_Group `i'.xls", replace sum(log) keep(`dems')	
		restore 
		}
	}
	
	
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop25 dem_prop50 dem_prop75 dem_proptotal dem_propsent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind24m visits_eventcount24m visits_count24m misc_ind24m misc_count24m misc_max24m  misc_a24m  misc_acount24m"
local tabs "dem_offensetype dem_offensecat dem_offenseclass"
foreach g of numlist 6 {
	forval i=1/`g' {
		preserve 
			keep if group_`g'group==`i'
			di "group_`g'group==`i'"
			***Demographics Table 
				summ `dems', sep(0)
					foreach i of local tabs  {
						tab `i', m 
						}
				order `dems', after(mov_cnt_num) 
				*outreg2 `dems' using "..\Tables and Figures\outreg2\GBMTM Descriptives_24 Months `g'G_Group `i'.xls", replace sum(log) keep(`dems')
		restore 
		}
	}

local tabs "dem_offensetype dem_offensecat dem_offenseclass"
	forval i=1/6 {
	preserve 
	keep if group_6group==`i'
	foreach x of local tabs  {
		tab `x', m
		}
	restore
	}
	
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop25 dem_prop50 dem_prop75 dem_proptotal dem_propsent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind12m visits_eventcount12m visits_count12m misc_ind12m misc_count12m misc_max12m  misc_a12m  misc_acount12m"
local tabs "dem_offensetype dem_offensecat dem_offenseclass"
	summ `dems', sep(0)
	order `dems', after(mov_cnt_num)
	outreg2 `dems' using "../Tables and Figures/outreg2/GBMTM Descriptives_24 Months Full.xls", replace sum(log) keep(`dems')
	foreach i of local tabs  {
		tab `i', m 
		}
	/* NOTE: Changed obs period to 12 months (SJ 7/10/20) */
	
*** ANOVA Test Across Each Variable  
use "Analytic Data\Subsamples\analytic(24 month final).dta", clear

local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop25 dem_prop50 dem_prop75 dem_proptotal dem_propsent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind24m visits_eventcount24m visits_count24m misc_ind24m misc_count24m misc_max24m  misc_a24m  misc_acount24m"
foreach i of local dems {
	anova `i' groupind_24m6g
		table groupind_24m6g, contents(mean `i')
	}

	tab dem_offensecat, g(offcat_)
		foreach i of varlist offcat_* {
			di "`i'"
			anova `i' groupind_24m6g
			}
			
	tab dem_offenseclass, g(offclass_)
		foreach i of varlist offclass_* {
			di "`i'"
			anova `i' groupind_24m6g
			}
			
/*=======================================================================================
					Run Descriptives by Loop 12 Month Sample - Five Group 
=========================================================================================*/
use  "Analytic Data\Subsamples\analytic(12 month final).dta", clear
	
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop12_25 dem_prop12_50 dem_prop12_75 dem_prop12total dem_prop12sent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind12m visits_eventcount12m visits_count12m misc_ind12m misc_count12m misc_max12m  misc_a12m  misc_acount12m"
foreach g of numlist 5 {
	forval i=1/`g' {
		preserve 
			keep if groupind_12m5g==`i' 
			di "groupind_12m5g==`i'"
			***Demographics Table 
				summ `dems', sep(0)
				order `dems', after(mov_cnt_num) 
				outreg2 `dems' using "../Tables and Figures/outreg2/GBMTM Descriptives_12 Months `g'G_Group `i'.xls", replace sum(log) keep(`dems')	
		restore 
		}
	}
	
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop12_25 dem_prop12_50 dem_prop12_75 dem_prop12total dem_prop12sent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind12m visits_eventcount12m visits_count12m misc_ind12m misc_count12m misc_max12m  misc_a12m  misc_acount12m"
local tabs "dem_offensetype dem_offensecat dem_offenseclass"
foreach g of numlist 5 {
	forval i=1/`g' {
		preserve 
			keep if groupind_12m5g==`i'
			di "groupind_12m5g==`i'"
			***Demographics Table 
				summ `dems', sep(0)
					foreach i of local tabs  {
						tab `i', m 
						}
				order `dems', after(mov_cnt_num) 
				*outreg2 `dems' using "..\Tables and Figures\outreg2\GBMTM Descriptives_12 Months `g'G_Group `i'.xls", replace sum(log) keep(`dems')
		restore 
		}
	}

local tabs "dem_offensetype dem_offensecat dem_offenseclass"
	forval i=1/5 {
	preserve 
	keep if groupind_12m5g==`i'
	foreach x of local tabs  {
		tab `x', m
		}
	restore
	}
	
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop12_25 dem_prop12_50 dem_prop12_75 dem_prop12total dem_prop12sent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind12m visits_eventcount12m visits_count12m misc_ind12m misc_count12m misc_max12m  misc_a12m  misc_acount12m"
local tabs "dem_offensetype dem_offensecat dem_offenseclass"
	summ `dems', sep(0)
	order `dems', after(mov_cnt_num)
	outreg2 `dems' using "../Tables and Figures/outreg2/GBMTM Descriptives_12 Months Full.xls", replace sum(log) keep(`dems')
	foreach i of local tabs  {
		tab `i', m 
		}
	/* NOTE: Changed obs period to 12 months (SJ 7/10/20) */
	
*** ANOVA Test Across Each Variable  
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop12_25 dem_prop12_50 dem_prop12_75 dem_prop12total dem_prop12sent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind12m visits_eventcount12m visits_count12m misc_ind12m misc_count12m misc_max12m  misc_a12m  misc_acount12m"
foreach i of local dems {
	anova `i' groupind_12m5g
		table groupind_12m5g, contents(mean `i')
	}

	tab dem_offensecat, g(offcat_)
		foreach i of varlist offcat_* {
			di "`i'"
			anova `i' groupind_12m5g
			}
			
	tab dem_offenseclass, g(offclass_)
		foreach i of varlist offclass_* {
			di "`i'"
			anova `i' groupind_12m5g
			}

	
/*=================== Update Log ===================
07/10/20 - SJ 		- Changed observation period from 24 months to 12 months in the 
						full, 12 month, and 24 month samples
03/02/20 - SJ 		- Created histograms
02/28/20 - MP 		- Started .do 

*/
log close
