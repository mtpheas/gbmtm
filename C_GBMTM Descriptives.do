cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date:		Februrary 28, 2020
Last Updated: 	July 10, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Descriptive Statistics for 12 and 24 months subsamples 

Objective: Create summary statistics table for the full sample, 12 month subsample,
			24 months subsample.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all

/*=======================================================================================
						Create Demographic Variables in 12 Months Subsample
=========================================================================================*/
use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 

***Demographic Local 
***Demographic Local 
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop25 dem_prop50 dem_prop75 dem_proptotal dem_propsent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind24m visits_eventcount24m visits_count24m misc_ind24m misc_count24m misc_max24m  misc_a24m  misc_acount24m"
local tabs "dem_offensetype dem_offensecat dem_offenseclass"
	summ `dems', sep(0)
	order `dems', after(mov_cnt_num) 
	outreg2 `dems' using "..\Tables and Figures\outreg2\GBMTM Descriptives_12 Months.xls", replace sum(log) keep(`dems')
			foreach i of local tabs  {
		tab `i', m 
		}

/** Visit and Misconduct Histograms
tab visits_eventcount, m
	replace visits_eventcount=0 if visits_eventcount==. 
	tab visits_eventcount, m
tab misc_max, m
	gen misc_count=misc_max
		replace misc_count=0 if misc_max==.
		tab misc_count, m */

#d ; 
	hist visits_eventcount, percent
		title("Visit Count" "(12 months subsample)")
		xtitle("Visit Count")
		name("visitcount12m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcount12m.png", replace
	
#d ; 
	hist visits_count, percent
		title("Visit Count | Any Visit" "(12 months subsample)")
		xtitle("Visit Count")
		name("visitcount_visit12m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcount_visit12m.png", replace

	
#d ; 
	hist misc_count, percent
		title("Misconduct Count" "(12 months subsample)")
		xtitle("Misconduct Count")
		name("misccount12m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccount12m.png", replace
	
#d ; 
	hist misc_max, percent
		title("Misconduct Count | Any Misconduct" "(12 months subsample)")
		xtitle("Misconduct Count")
		name("misccount_misc12m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccount_misc12m.png", replace

/*=======================================================================================
						Create Demographic Variables in 24 Months Subsample
=========================================================================================*/
use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 

***Demographic Local 
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop50 dem_proptotal dem_propsent visits_ind visits_ind24m visits_count visits_count24m misc_ind misc_ind24m misc_count misc_count24m misc_amax misc_a24m"
	summ `dems', sep(0)
	order `dems', after(mov_cnt_num) 
	outreg2 `dems' using "..\Tables and Figures\outreg2\GBMTM Descriptives_24 Months.xls", replace sum(log) keep(`dems')

*** Visit and Misconduct Histograms

#d ; 
	hist visits_eventcount, percent
		title("Visit Count" "(24 months subsample)")
		xtitle("Visit Count")
		name("visitcount24m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcount24m.png", replace

#d ; 
	hist visits_count, percent
		title("Visit Count | Any Visit" "(24 months subsample)")
		xtitle("Visit Count")
		name("visitcount_visit24m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcount_visit24m.png", replace

#d ; 
	hist misc_count, percent
		title("Misconduct Count" "(24 months subsample)")
		xtitle("Misconduct Count")
		name("misccount24m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccount24m.png", replace

#d ; 
	hist misc_max, percent
		title("Misconduct Count | Any Misconduct" "(24 months subsample)")
		xtitle("Misconduct Count")
		name("misccount_misc24m", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccount_misc24m.png", replace


/*=======================================================================================
						Create Demographic Variables in Whole Sample
=========================================================================================*/
use "Analytic Data/Subsamples/analytic(full_mixed).dta", clear 

***Demographic Local 
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop25 dem_prop50 dem_prop75 dem_proptotal dem_propsent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind12m visits_eventcount12m visits_count12m misc_ind12m misc_count12m misc_max12m  misc_a12m  misc_acount12m"
local tabs "dem_offensetype dem_offensecat dem_offenseclass"
	summ `dems', sep(0)
	order `dems', after(mov_cnt_num) 
	outreg2 `dems' using "../Tables and Figures/outreg2/GBMTM Descriptives_All.xls", replace sum(log) keep(`dems')
		foreach i of local tabs  {
		tab `i', m 
		}
	/* NOTE: Changed obs period to 12 months (SJ 7/10/20) */
	
*** Visit and Misconduct Histograms

#d ; 
	hist visits_eventcount, percent
		title("Visit Count" "(Whole sample)")
		xtitle("Visit Count")
		name("visitcountall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcountall.png", replace

#d ; 
	hist visits_count, percent
		title("Visit Count | Any Visit" "(Whole sample)")
		xtitle("Visit Count")
		name("visitcount_visitall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcount_visitall.png", replace


#d ; 
	hist misc_count, percent
		title("Misconduct Count" "(Whole sample)")
		xtitle("Misconduct Count")
		name("misccountall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccountall.png", replace


#d ; 
	hist misc_max, percent
		title("Misconduct Count | Any Misconduct" "(Whole sample)")
		xtitle("Misconduct Count")
		name("misccount_miscall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccount_miscall.png", replace


/*=======================================================================================
						Create Demographic Variables by Additional Samples (5 & 10 Year)
=========================================================================================*/
foreach x of numlist 60 120 {
use "Analytic Data\Subsamples\analytic(full_mixed).dta", clear 
	preserve 
	keep if monthsserved>=`x'

***Demographic Local 
local dems "dem_black dem_white dem_hispanic dem_raceother dem_married dem_age_admit dem_age_release monthsserved dem_prop25 dem_prop50 dem_prop75 dem_proptotal dem_propsent visits_ind visits_eventcount visits_count misc_ind misc_count misc_max misc_amax misc_acount visits_ind24m visits_eventcount24m visits_count24m misc_ind24m misc_count24m misc_max24m  misc_a24m  misc_acount24m"
local tabs "dem_offensetype dem_offensecat dem_offenseclass"
	summ `dems', sep(0)
	order `dems', after(mov_cnt_num) 
	outreg2 `dems' using "..\Tables and Figures\outreg2\GBMTM Descriptives_`x' Months.xls", replace sum(log) keep(`dems')
		foreach i of local tabs  {
		tab `i', m 
		}
	
*** Visit and Misconduct Histograms

#d ; 
	hist visits_eventcount, percent
		title("Visit Count" "(`x' Month Subsample)")
		xtitle("Visit Count")
		name("visitcountall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcount`x'm.png", replace

#d ; 
	hist visits_count, percent
		title("Visit Count | Any Visit" "(`x' Month Subsample)")
		xtitle("Visit Count")
		name("visitcount_visitall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\visitcount_visit`x'm.png", replace


#d ; 
	hist misc_count, percent
		title("Misconduct Count" "(`x' Month Subsample)")
		xtitle("Misconduct Count")
		name("misccountall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccount`x'm.png", replace


#d ; 
	hist misc_max, percent
		title("Misconduct Count | Any Misconduct" "(`x' Month Subsample)")
		xtitle("Misconduct Count")
		name("misccount_miscall", replace);
	#d cr
	graph export "..\Tables and Figures\GBMTM\Figures\misccount_misc`x'm.png", replace	
	
	restore 
	}
	
	
/*=======================================================================================
						Monthly Visit and Misconduct Probability by Sample
=========================================================================================*/
foreach i in "visits" "misc" {
*** Full Sample
	use "Analytic Data\Subsamples\analytic(full_mixed).dta", clear 
	summ `i'_monthspre1-`i'_monthspre24, sep(0)
	outreg2 `i'_monthspre1-`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i'_Sample.xls", replace sum(log) keep(`i'_monthspre1-`i'_monthspre24)

*** 24 Months
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
	summ `i'_monthspre1-`i'_monthspre24, sep(0)
	outreg2 `i'_monthspre1-`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i'_Sample.xls", append sum(log) keep(`i'_monthspre1-`i'_monthspre24)
	
*** 12 Months
	use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 
	summ `i'_monthspre1-`i'_monthspre24, sep(0)
	outreg2 `i'_monthspre1-`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i'_Sample.xls", append sum(log) keep(`i'_monthspre1-`i'_monthspre24)
	
**** 5 Year and 10 Year Samples 
	foreach x of numlist 60 120 {
		use "Analytic Data\Subsamples\analytic(full_mixed).dta", clear 
			preserve 
				keep if monthsserved>=`x'
					summ `i'_monthspre1-`i'_monthspre24, sep(0)
					outreg2 `i'_monthspre1-`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i'_Sample.xls", append sum(log) keep(`i'_monthspre1-`i'_monthspre24)
			restore 
		}
	
	}
	
/*=======================================================================================
						Monthly Visit and Misconduct Count by Sample
=========================================================================================*/
foreach i in "visits" "misc" {
*** Full Sample
	use "Analytic Data\Subsamples\analytic(full_mixed).dta", clear 
	summ c_`i'_monthspre1-c_`i'_monthspre24, sep(0)
	outreg2 c_`i'_monthspre1-c_`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i' Count_Sample.xls", replace sum(log) keep(c_`i'_monthspre1-c_`i'_monthspre24)

*** 24 Months
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
	summ c_`i'_monthspre1-c_`i'_monthspre24, sep(0)
	outreg2 c_`i'_monthspre1-c_`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i' Count_Sample.xls", append sum(log) keep(c_`i'_monthspre1-c_`i'_monthspre24)
	
*** 12 Months
	use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 
	summ c_`i'_monthspre1-c_`i'_monthspre24, sep(0)
	outreg2 c_`i'_monthspre1-c_`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i' Count_Sample.xls", append sum(log) keep(c_`i'_monthspre1-c_`i'_monthspre24)

*** 5 Year and 10 Year Samples 
	foreach x of numlist 60 120 {
		use "Analytic Data\Subsamples\analytic(full_mixed).dta", clear 
			preserve 
				keep if monthsserved>=`x'
				summ c_`i'_monthspre1-c_`i'_monthspre24, sep(0)
				outreg2 c_`i'_monthspre1-c_`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i' Count_Sample.xls", append sum(log) keep(c_`i'_monthspre1-c_`i'_monthspre24)
			restore 
		}
	}
	
/*=======================================================================================
				Monthly Visit and Misconduct Probablity & Count for Full Sample
=========================================================================================*/
/* For this seciton, what we want to do is ensure that the individuals that are not in the 
	appropriate samples are treated as (.) rather than 0. If they are treated as 0 then they 
	will skew the means which are used for the trends. This is not an issue for the specific 
	sample cuts becuase in order to create each of their respective trend lines we only kept
	the individuals incarcerated during those periods. This is more of a problem for the 
	full sample becuase this is a composite. It should be noted that this IS a problem for the 
	12 months sample which we can address. */
	
*** Create Sample Indicators  
	use "Analytic Data\Subsamples\analytic(full_mixed).dta", clear
	capture drop ind_*
	foreach i of numlist 12 24 60 120 {
		gen ind_`i'm=(monthsserved<`i')
		tab ind_`i', m
		}
		/* This loop creates an indicator for individuals who served more than the 
			listed months (e.g., greater than a year, two years, etc.). We created this
			in order to be able to get sample cuts. What we need however, are the zeros. 
			What the zeros are are the individuals who are EXCLUSIVELY in the respective 
			sample. For example, if an individual has a zero for the ind_12m it would 
			mean that they are ONLY in the 12 month sample (or lower). While we could 
			not use this as a sample cutting indicator (i.e., becuase this would not 
			tell us who is in the sample during the respective periods, instead it will 
			only tell us who is NOT in the cumulative sample), we can use this as an
			indicator for those that are NOT in the months larger than the cut. From 
			this point, we can then recode all those individuals as missing for months 
			greater than their last month incarcerated. While this is not entirely 
			accurate (e.g., an individual who has less than a year will also be coded 
			as missing but only for values greater than a year), combined with the cuts
			it should give a good approximation of those who should be missing. */
	
**** Create Missing Variables 
	foreach x of numlist 13/120 {
		replace `i'_monthspre`x'=. if ind_24m!=1
		}
	foreach x of numlist 25/120 {
		replace `i'_monthspre`x'=. if ind_60m!=1
		}
	foreach x of numlist 61/120 {
		replace `i'_monthspre`x'=. if ind_120m!=1
		}

	foreach i in "visits" "misc" {
	* Probability 
		summ `i'_monthspre1-`i'_monthspre24, sep(0)
			outreg2 `i'_monthspre1-`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i'_Full Sample.xls", replace sum(log) keep(`i'_monthspre1-`i'_monthspre24
	* Count 
		summ c_`i'_monthspre1-c_`i'_monthspre24, sep(0)
			outreg2 c_`i'_monthspre1-c_`i'_monthspre24 using "..\Tables and Figures\outreg2\GBMTM Descriptives_Mean Monthly `i' Count_Full Sample.xls", replace sum(log) keep(c_`i'_monthspre1-c_`i'_monthspre24)
		}

/*=======================================================================================
				Create Cumulative Like Trend Graph 
=========================================================================================*/
	
/*=================== Update Log ===================
07/10/20 - SJ		- Changed observation period from 24 month to 12 month in full sample
03/02/20 - SJ 		- Created histograms
02/28/20 - SJ 		- Started .do 

*/
log close
