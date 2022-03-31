cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date: 	Februrary 27, 2020
Last Updated: 	February 27, 2020 (MP)

Program Description: 	PA Visits 
						Run Preliminary Trajectory Models  

Objective: 	The objective is to use the ananlytic dataset in order to create a 
				series of samples that we can run trajectory models on. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all


/*=======================================================================================
						Create Local Programs used for Coding
=========================================================================================*/
*** Define a Program to Automate the pos creation process 
	program define makepos  
		version 15.1
		args 1 2 3 4
			matrix `1'=[.]
				foreach i of numlist  -`2'(.015)-.0075 .0075(.015)`2'  {	
					di `i'
					matrix `1'=[`1',`i']
					}
				matrix `1'=`1'[1,2...n]
				matrix list `1'
				foreach i of numlist 1/`3' {
					gen `4'`i'=`1'[1,`i']
					}
	end 

	
	
/*=======================================================================================
						Prepare to Run Trajectory Models 
-----------------------------------------------------------------------------------------			
The following code will use the data created from the 4_GBMTM Data Building.do file in 
	order to finalize the data to run trajectory models. The .dta file at the end of the 
	previous .do has all the appropriate binned variables (for the logit), however does 
	not include the appropriate x's or points of support that are needed to run the trajectory 
	models. Specifically, these are the series of independent variables needed. 
	
Steps: 
	(1) Open and view file  
	(2) Create the appropriate IV(pos) for the misconducts 
	(3) Create the appropriate IV (pos) for visits. 
=========================================================================================*/

/*=======================================================================================
							(1) Open and View Data  
=========================================================================================*/
use "Analytic Data\analytic(gbmtm_vismisc_wide).dta", clear 
	describe 
		/* These data include some basic descriptive (dem) information in addition to 
			the series of dummies for visits_month* and misc_month* */
	
*** Look at the Distribution of Sentence Length (month)
	summ monthsserved, d 
	summ yearsserved, d 
	
/*=======================================================================================
							(2/3) Create IV POS
=========================================================================================*/
*** POS - Band:24, Bin:1
	local max=(12*.015)-.0075
	makepos z24vals `max' 24 z24m 

*** POS - Band:24, Bin:2
	local max=(6*.015)-.0075
	makepos z12vals `max' 12 z12m 

/** POS - Band:24, Bin:1
	local max=(24*.015)-.0075
	makepos x24vals `max' 24 x24m 

*** POS - Band:24, Bin:2
	local max=(12*.015)-.0075
	makepos x12vals `max' 12 x12m  */
/*=======================================================================================
							Create Different Binwidth 
=========================================================================================*/
	/* This section of code should collapse the monthly intervals to make different bindwidths. */
*** Create Binwidth: 2 - Visits 
	foreach i of numlist 2(2)104 {
		local min1 = `i'-1
		local 2m "visits_monthspre`min1' - visits_monthspre`i'"
		egen visits_2mpre`min1'=rowmax(`2m')
		*egen count_t3m`min2'= rowtotal(t1m`min2' t1m`min1' t1m`i')
		}
	foreach i of numlist 3(2)103 {
		local x = (`i'+1)/2
		rename visits_2mpre`i' visits_2mpre`x'
		*rename count_t3m`i' count_t3m`x'
		}
	summ visits_2mpre*, sep(0)
	
*** Create Binwidth: 2 - Misconducts 
	foreach i of numlist 2(2)198 {
		local min1 = `i'-1
		local 2m "misc_monthspre`min1' - misc_monthspre`i'"
		egen misc_2mpre`min1'=rowmax(`2m')
		}
	foreach i of numlist 3(2)197 {
		local x = (`i'+1)/2
		rename misc_2mpre`i' misc_2mpre`x'
		}
	summ misc_2mpre*, sep(0)

/*=======================================================================================
							Cleaning Descriptives 
=========================================================================================*/
summ dem_*, sep(0) //Confirmation of String 

***Race: Black, White, Other Race  
tab dem_race, gen(race)
	summ race*, sep(0)
	rename race1 dem_asian 
	rename race2 dem_black
	rename race3 dem_hispanic 
	rename race4 dem_amerindian
	rename race5 dem_other
	rename race6 dem_white
	gen dem_raceother=0
		replace dem_raceother=1 if dem_asian==1 | dem_amerindian==1 | dem_other==1
	tab1 dem_black dem_hispanic dem_white dem_other 

***Married
tab dem_maritalstat, m
gen dem_married=0
	replace dem_married=1 if dem_maritalstat=="MAR"
	replace dem_married=. if dem_maritalstat=="" | dem_maritalstat=="   "
		tab dem_married, m

*** Offense Information 
	rename dem_offensecode code
	merge m:1 code using "Raw Data\Offense Codes.dta"
		drop if _merge==2 
			/* This drops all the offenses that are not in the data (i.e., these 
				are offenses that individuals have not committed).
				In addition, the majority of _merge==1 cases are missing offense 
					information (need to check initial coding) or offenses from 
					court. This information should be available and we need to 
					look into this. */
	rename code 		dem_offensecode
	rename category 	dem_offensetype
	rename grade 		dem_offenseclass
	rename ascacategory dem_offensecat
	rename mandatorymin dem_offensemm
	drop part offense act_gravity_score wi_gravity_score siprrrieligible note _merge


***Age at Admit and Release
codebook date_dob date_admitdate date_releasedate
tostring date_dob, replace 
	gen ay=substr(date_dob,1,4)
	gen am=substr(date_dob,5,2)
	gen ad=substr(date_dob,7,.)
		foreach x of varlist ay am ad {
			tab `x', m
			}
	egen adate=concat(am ad ay), punct(-)
	gen re_date_dob=date(adate, "MDY")
		format re_date_dob %td
	drop ay am ad adate date_dob
	rename re_date_dob date_dob

gen dem_age_admit=(date_admitdate-date_dob)
	replace dem_age_admit=(dem_age_admit/365)
	list date_admitdate date_dob dem_age_admit in 1/5

gen dem_age_release=(date_releasedate-date_dob)
	replace dem_age_release=(dem_age_release/365)
	list date_releasedate date_dob dem_age_release in 1/5
	
*** Proportion of Sentence Length 
	/* In order to caclulate the proportion of sentence length that was in the 
		study period we can use the total time served (monthsserved) variables. 
		Becuase we know that the dates are different for everyone, but the study 
		period is the past 24 months we can divide 24m. over the total number 
		of months served in order to get the percentages and then create the 
		variables accordingly.
		NOTE: This will be based on a 2 year sample, samples with different 
			study periods will have to be recalculated for proportion of sentence
			length. */
	gen dem_propsent=(24/monthsserved)
		summ dem_propsent
			/* By putting 24m in the numerator, this variable is the proportion 
				of the individuals sentence that is served in the study period. 
				After the sample restriction, we should have everyone that just
				has at least the total proportion incarcerated. */
				
*** Total Proportion of Sentence Length Served 
	/* Anything between 24 months and 24.1 months are considered full time in the
		study. Between .961 and 1. */
	gen dem_proptotal=0
		replace dem_proptotal=1 if dem_propsent<=1 & dem_propsent>.96
		tab dem_proptotal, m 
		
*** Proportion Indicators 
	gen dem_prop75=0
		replace dem_prop75=1 if dem_propsent<=1 & dem_propsent>=.75
	gen dem_prop50=0
		replace dem_prop50=1 if dem_propsent<=1 & dem_propsent>=.50
	gen dem_prop25=0
		replace dem_prop25=1 if dem_propsent<=1 & dem_propsent>=.25
	summ dem_proptotal dem_prop75 dem_prop50 dem_prop25
	
*** Proportion Indicators for 12 Month Sample - 
	gen dem_prop12sent=(12/monthsserved)
		summ dem_prop12sent 
		gen dem_prop12total=0
			replace dem_prop12total=1 if dem_prop12sent<=1 & dem_prop12sent>.96
				tab dem_prop12total, m 
		gen dem_prop12_75=0
			replace dem_prop12_75=1 if dem_prop12sent<=1 & dem_prop12sent>=.75
		gen dem_prop12_50=0
			replace dem_prop12_50=1 if dem_prop12sent<=1 & dem_prop12sent>=.50
		gen dem_prop12_25=0
			replace dem_prop12_25=1 if dem_prop12sent<=1 & dem_prop12sent>=.25
		summ dem_prop12*, sep(0)

***Visit Indicator 
tab visits_eventcount, m
gen visits_ind=1
	replace visits_ind=0 if visits_eventcount==0
	replace visits_ind=0 if visits_eventcount==.
		tab visits_ind, m
		*tab visits_eventcount, m

***Visit Count
replace visits_eventcount=0 if visits_eventcount==.
		tab visits_eventcount, m
		summ visits_eventcount, d
		*tab visits_eventcount, m 

***Visit Count | Getting Visited 
gen visits_count=visits_eventcount if visits_ind==1
		tab visits_count visits_ind, m
		summ visits_count, d
		
***Misconduct Indicator
gen misc_ind=0
	replace misc_ind=1 if misc_max!=.
		tab misc_ind, m
		*tab misc_max, m
		tab misc_max, m
	/* misc_max is the Miscounduct Count | Having Misconduct */

***Misconduct Count
gen misc_count=misc_max
	replace misc_count=0 if misc_max==.
		summ misc_count, d

*** Visit Indicator - 24 month 
gen visits_ind24m=1
	replace visits_ind24m=0 if visits_eventcount24m==0
	replace visits_ind24m=0 if visits_eventcount24m==.
		tab visits_ind24m, m
		*tab visits_eventcount, m 

***Visit Count
replace visits_eventcount24m=0 if visits_eventcount24m==.
		tab visits_eventcount24m, m
		summ visits_eventcount24m, d

***Visit Count - 24m | Getting Visted - 24 month
gen visits_count24m=visits_eventcount24m if visits_ind24m==1
		summ visits_count24m, d
		tab visits_count24m visits_ind24m, m
		*tab visits_eventcount24m, m 
		
***Misconduct Indicator - 24m 
gen misc_ind24m=0
	replace misc_ind24m=1 if misc_max24m!=.
		tab misc_ind24m, m
		*tab misc_max, m
		
***Misconduct Count
gen misc_count24m=misc_max24m
	replace misc_count24m=0 if misc_max24m==.
		summ misc_count24m, d
		*tab misc_max24m, m 
		/* misc_max is the Miscounduct Count | Having Misconduct */
	
***Misconduct A Count 
tab misc_amax, m
	replace misc_amax=0 if misc_amax==.
	summ misc_amax
tab misc_a24m, m
	replace misc_a24m=0 if misc_a24m==.
	summ misc_a24m

*** Misconduct A Count | Having Misconduct 
gen misc_acount=misc_amax if misc_amax!=0
	tab misc_acount, m
gen misc_acount24m=misc_a24m if misc_a24m!=0
	tab misc_acount24m, m

******* 12 Month Sample - Redo 
*** Visit Indicator - 12 month 
gen visits_ind12m=1
	replace visits_ind12m=0 if visits_eventcount12m==0
	replace visits_ind12m=0 if visits_eventcount12m==.
		tab visits_ind12m, m
		*tab visits_eventcount, m 

***Visit Count
replace visits_eventcount12m=0 if visits_eventcount12m==.
		tab visits_eventcount12m, m
		summ visits_eventcount12m, d

***Visit Count - 12m | Getting Visted - 12 month
gen visits_count12m=visits_eventcount12m if visits_ind12m==1
		summ visits_count12m, d
		tab visits_count12m visits_ind12m, m
		*tab visits_eventcount12m, m 
		
***Misconduct Indicator - 12m 
gen misc_ind12m=0
	replace misc_ind12m=1 if misc_max12m!=.
		tab misc_ind12m, m
		*tab misc_max, m
		
***Misconduct Count
gen misc_count12m=misc_max12m
	replace misc_count12m=0 if misc_max12m==.
		summ misc_count12m, d
		*tab misc_max12m, m 
		/* misc_max is the Miscounduct Count | Having Misconduct */
	
***Misconduct A Count 
tab misc_a12m, m
	replace misc_a12m=0 if misc_a12m==.
	summ misc_a12m

*** Misconduct A Count | Having Misconduct 
gen misc_acount12m=misc_a12m if misc_a12m!=0
	tab misc_acount12m, m
	
/*=======================================================================================
							Sampling Restrictions
=========================================================================================*/
*** Explore Sample Sizes 
	foreach i of numlist 12 24 36 48 60 72 84 96 108 120 {
		preserve 
			keep if monthsserved>=`i'
				codebook mov_cnt_num 
		restore 
		} 
		/* This section of code allows us to see the sample sizes from 1 year 
			to 10 years in order to make a decision on which sample sizes to 
			potentially use. */ 



*** Band:24 Sample - 2 Years 
	preserve 
		summ monthsserved 
			keep if monthsserved>=24 //N=4,482
				/* For the purpose of this example, we will only keep a two year lookback window. 
					What this means is that people with sentence lengths of shorter than two years will
					be excluded becuase they will have missing values. */	
				aorder 
				order mov_cnt_num lastname, first 
			save "Analytic Data\Subsamples\analytic(24 month).dta", replace 			
	restore 
	
*** Band:12 Sample - 1 Year
	preserve 
		summ monthsserved 
			keep if monthsserved>=12 //
				aorder 
				order mov_cnt_num lastname, first 
			save "Analytic Data\Subsamples\analytic(12 month).dta", replace 
	restore 
	 
*** Sensitivty Samples - Bands:48/78/116	 
	foreach i of numlist 48 79 116 60 120  {
		preserve 
			keep if monthsserved>=`i'
				aorder 
				order mov_cnt_num lastname, first
			save "Analytic Data\Subsamples\analytic(`i' month).dta", replace 
		restore
		}
	
*** Full 
	save "Analytic Data\Subsamples\analytic(full_dummy).dta", replace
	
*** De-identify data 
	use "Analytic Data\Subsamples\analytic(24 month).dta", clear 
		drop dem_* lastname stateid code_admit code_move date_* inmatenum
	save "Analytic Data\Subsamples\analytic(24 month_deidentified).dta", replace 
	
	

	
/*=======================================================================================
						Prepare to Run ZIP Trajectories 
-----------------------------------------------------------------------------------------			
The following code will use the data created from the 4_GBMTM Data Building.do file in 
	order to finalize the data to run trajectory models. The .dta file at the end of the 
	previous .do has all the appropriate binned variables (for the zip), however does 
	not include the appropriate x's or points of support that are needed to run the trajectory 
	models. Specifically, these are the series of independent variables needed. 
	
Steps: 
	(1) Open and view file  
	(2) Create the appropriate IV(pos) for the misconducts 
	(3) Create the appropriate IV (pos) for visits. 
=========================================================================================*/

/*=======================================================================================
							(1) Open and View Data  
=========================================================================================*/
use "Analytic Data\analytic(gbmtm_vmcount_wide).dta", clear 
	describe 
		/* These data include some basic descriptive (dem) information in addition to 
			the series of dummies for visits_month* and misc_month* */
	
*** Look at the Distribution of Sentence Length (month)
	summ monthsserved, d 
	summ yearsserved, d 
	
/*=======================================================================================
							(2/3) Create IV POS
=========================================================================================*/
*** POS - Band:24, Bin:1
	local max=(12*.015)-.0075
	makepos z24vals `max' 24 z24m 

*** POS - Band:24, Bin:2
	local max=(6*.015)-.0075
	makepos z12vals `max' 12 z12m  

*** POS - Band:24, Bin:1
	local max=(24*.015)-.0075
	makepos x24vals `max' 24 x24m 

*** POS - Band:24, Bin:2
	local max=(12*.015)-.0075
	makepos x12vals `max' 12 x12m  
/*=======================================================================================
							Create Different Binwidth 
=========================================================================================*/
	/* This section of code should collapse the monthly intervals to make different bindwidths. */
*** Create Binwidth: 2 - Visits 
	foreach i of numlist 2(2)104 {
		local min1 = `i'-1
		local 2m "visits_monthspre`min1' - visits_monthspre`i'"
		egen visits_2mpre`min1'=rowtotal(`2m')
		*egen count_t3m`min2'= rowtotal(t1m`min2' t1m`min1' t1m`i')
		}
	foreach i of numlist 3(2)103 {
		local x = (`i'+1)/2
		rename visits_2mpre`i' visits_2mpre`x'
		*rename count_t3m`i' count_t3m`x'
		}
	summ visits_2mpre*, sep(0)
	
*** Create Binwidth: 2 - Misconducts 
	foreach i of numlist 2(2)198 {
		local min1 = `i'-1
		local 2m "misc_monthspre`min1' - misc_monthspre`i'"
		egen misc_2mpre`min1'=rowtotal(`2m')
		}
	foreach i of numlist 3(2)197 {
		local x = (`i'+1)/2
		rename misc_2mpre`i' misc_2mpre`x'
		}
	summ misc_2mpre*, sep(0)
	
/*=======================================================================================
							Sampling Restrictions
=========================================================================================*/
*** Band:24 Sample - 2 Years 
	preserve 
		summ monthsserved 
			keep if monthsserved>=24 //N=4,482
				/* For the purpose of this example, we will only keep a two year lookback window. 
					What this means is that people with sentence lengths of shorter than two years will
					be excluded becuase they will have missing values. */	
			save "Analytic Data\Subsamples\analytic(count 24 month).dta", replace 			
	restore 
	
*** Band:12 Sample - 1 Year
	preserve 
		summ monthsserved 
			keep if monthsserved>=12 //
			save "Analytic Data\Subsamples\analytic(count 12 month).dta", replace 
	restore 
	
*** Sensitivity Samples - Bands:48/78/116	 
	foreach i of numlist 48 79 116 60 120  {
		preserve 
			keep if monthsserved>=`i'
			save "Analytic Data\Subsamples\analytic(count `i' month).dta", replace 
		restore
		}
		
*** Full 
	save "Analytic Data\Subsamples\analytic(full_count).dta", replace	
	
*** De-identify data 
	use "Analytic Data\Subsamples\analytic(count 24 month).dta", clear 
		drop dem_* lastname stateid code_admit code_move date_* inmatenum
	save "Analytic Data\Subsamples\analytic(24 month_deidentified count).dta", replace 
	
	
/*=======================================================================================
						Create MIX files 
-----------------------------------------------------------------------------------------			
The following code will use the previous datasets in order to create mix files that have 
	the capacity to run both logits and count models. 
	
Steps: 
=========================================================================================*/
/*=======================================================================================
							Create 24 Month Mix File 
=========================================================================================*/
*** Open Count File - drop and rename variables to merge with logit file 
	use "Analytic Data\Subsamples\analytic(count 24 month).dta", clear 
		local dropvars "lastname code_admitcode code_movecode date_admitdate date_deletedate date_dob date_eventdate date_maxrelease date_minrelease date_receptiondate date_receptiondate2 date_regdate date_releasedate date_sentencedate dem_commitcounty dem_currlocation dem_maritalstat dem_offense dem_race dem_sentstat dem_sex inmatenum maxcnt monthsserved move_admitcode move_merge move_releasecode move_releasedate stateid yearsserved misc_max misc_amax visits_max visits_eventcount"
		drop `dropvars' visits_monthspre26-visits_monthspre104 misc_monthspre26-misc_monthspre199 z24m* z12m* visits_2mpre14-visits_2mpre52 misc_2mpre14-misc_2mpre99 visits_weekspre110-visits_weekspre446 misc_weekspre110-misc_weekspre837 // Drops all those variables that are not needed 
			describe 
		foreach i of varlist _all {
			rename `i' c_`i'
			}
			rename c_mov_cnt_num mov_cnt_num 
		save "Analytic Data\Subsamples\sample(24month count).dta", replace 
		
*** Open Logit File 
	use "Analytic Data\Subsamples\analytic(24 month).dta", clear 
		drop  visits_monthspre26-visits_monthspre104 misc_monthspre26-misc_monthspre199 visits_2mpre14-visits_2mpre52 misc_2mpre14-misc_2mpre99 visits_weekspre110-visits_weekspre446 misc_weekspre110-misc_weekspre837 // Drops all those variables that are not needed 
			describe 
		save "Analytic Data\Subsamples\sample(24month dummy).dta", replace 
		
*** Merge Files 
	use "Analytic Data\Subsamples\sample(24month dummy).dta", clear 
		merge 1:1 mov_cnt_num using "Analytic Data\Subsamples\sample(24month count).dta"
			aorder 
			order mov_cnt_num lastname, first 
			order c_* _merge, last
		save "Analytic Data\Subsamples\analytic(24 month mixed).dta", replace 
	
/*=======================================================================================
							Create 12 Month Mix File 
=========================================================================================*/
*** Open Count File - drop and rename variables to merge with logit file 
	use "Analytic Data\Subsamples\analytic(count 12 month).dta", clear 
		local dropvars "lastname code_admitcode code_movecode date_admitdate date_deletedate date_dob date_eventdate date_maxrelease date_minrelease date_receptiondate date_receptiondate2 date_regdate date_releasedate date_sentencedate dem_commitcounty dem_currlocation dem_maritalstat dem_offense dem_race dem_sentstat dem_sex inmatenum maxcnt monthsserved move_admitcode move_merge move_releasecode move_releasedate stateid yearsserved misc_max misc_amax visits_max visits_eventcount"
		drop `dropvars' visits_monthspre26-visits_monthspre104 misc_monthspre26-misc_monthspre199 z24m* z12m* visits_2mpre14-visits_2mpre52 misc_2mpre14-misc_2mpre99 visits_weekspre110-visits_weekspre446 misc_weekspre110-misc_weekspre837 // Drops all those variables that are not needed 
			describe 
		foreach i of varlist _all {
			rename `i' c_`i'
			}
			rename c_mov_cnt_num mov_cnt_num 
		save "Analytic Data\Subsamples\sample(12month count).dta", replace 
		
*** Open Logit File 
	use "Analytic Data\Subsamples\analytic(12 month).dta", clear 
		drop  visits_monthspre26-visits_monthspre104 misc_monthspre26-misc_monthspre199 visits_2mpre14-visits_2mpre52 misc_2mpre14-misc_2mpre99 visits_weekspre110-visits_weekspre446 misc_weekspre110-misc_weekspre837 // Drops all those variables that are not needed 
			describe 
		save "Analytic Data\Subsamples\sample(12month dummy).dta", replace 
		
*** Merge Files 
	use "Analytic Data\Subsamples\sample(12month dummy).dta", clear 
		merge 1:1 mov_cnt_num using "Analytic Data\Subsamples\sample(12month count).dta"
			aorder 
			order mov_cnt_num lastname, first 
			order c_* _merge, last
		save "Analytic Data\Subsamples\analytic(12 month mixed).dta", replace 
		
/*=======================================================================================
							Create Master Mix File 
=========================================================================================*/
*** Open Count File - drop and rename variables to merge with logit file 
	use "Analytic Data\Subsamples\analytic(full_count).dta", clear 
		local dropvars "lastname code_admitcode code_movecode date_admitdate date_deletedate date_dob date_eventdate date_maxrelease date_minrelease date_receptiondate date_receptiondate2 date_regdate date_releasedate date_sentencedate dem_commitcounty dem_currlocation dem_maritalstat dem_offense dem_race dem_sentstat dem_sex inmatenum maxcnt monthsserved move_admitcode move_merge move_releasecode move_releasedate stateid yearsserved misc_max misc_amax visits_max visits_eventcount"
		drop `dropvars'  z24m* z12m*  // Drops all those variables that are not needed 
			describe 
		foreach i of varlist _all {
			rename `i' c_`i'
			}
			rename c_mov_cnt_num mov_cnt_num 
		save "Analytic Data\Subsamples\sample(full count).dta", replace 
		
*** Merge Files 
	use "Analytic Data\Subsamples\analytic(full_dummy).dta", clear 
		merge 1:1 mov_cnt_num using "Analytic Data\Subsamples\sample(full count).dta"
			aorder 
			order mov_cnt_num lastname, first 
			order c_* _merge, last
		save "Analytic Data\Subsamples\analytic(full_mixed).dta", replace 

*** Create POS for Bands (48/78/116)	
	foreach i of numlist 48 78 116 60 120 {
		local max=((`i'/2)*.015)-.0075
		makepos z`i'vals `max' `i' z`i'm
		}

	save "Analytic Data\Subsamples\analytic(full_mixed).dta", replace 

		
*** Create Inmate List for PA DOC Data Pulls
	local keeplist "stateid lastname inmatenum"
		keep `keeplist'
		order inmatenum lastname stateid, first 
	export excel using "Data\GBMTM_InmateList.xls", sheetreplace firstrow(variables)
		
/*NEXT STEPS: 
	- 
================ Update Log ================
10/19/20 - MP  - Updated to include weekly indicators 
02/27/20 - MP 	- Began the .do file  
 
*/
log close 




/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================
