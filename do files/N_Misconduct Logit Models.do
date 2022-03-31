capture log close 
cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date:   	February 21, 2021
Last Updated: 	February 21, 2021 (BP)

Program Description: 	GBMTM Paper 
						Misconduct Logit Single Trajectory Fitting   

Objective: 	The objective of this file is to run logit single trajectory models 
	for misconduct in order to try and estimate a dual later with two logit 
	models. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all

/*=======================================================================================
							Run Local Programs 
-----------------------------------------------------------------------------------------                       
This section will run the _localprograms.do file in order to pull in written programs 
	for trajectory estimation and coding efficiency. 
=========================================================================================*/ 
	run "..\Do Files\_localprograms.do" 

/*=======================================================================================
							Misconduct Logit Models
-----------------------------------------------------------------------------------------			
The following section will run logit trajectory models for misconduct in order to fit 
	the best logit solution. 
	
Steps:

=========================================================================================*/	
			
/*=======================================================================================
					(1)	2G [Band:24, Bin:1] Logit (33) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc24 = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc24' z24m* "3 3" misc_band24_bin1_l33 "Misconduct" 2
	
/*=======================================================================================
					(2)	3G [Band:24, Bin:1] Logit (333) Subsample(24m)
=========================================================================================*/	
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc24 = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc24' z24m* "3 3 3" misc_band24_bin1_l333 "Misconduct" 3
	
/*=======================================================================================
					(2)	4G [Band:24, Bin:1] Logit (333) Subsample(24m)
=========================================================================================*/	
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc24 = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc24' z24m* "3 3 3 3" misc_band24_bin1_l3333 "Misconduct" 4	
	
/*=======================================================================================
					(2)	5G [Band:24, Bin:1] Logit (333) Subsample(24m)
=========================================================================================*/	
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc24 = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc24' z24m* "3 3 3 3 3" misc_band24_bin1_l33333 "Misconduct" 5

/*=======================================================================================
					(2)	6G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc24 = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc24' z24m* "3 3 3 3 3 3" misc_band24_bin1_l333333 "Misconduct" 6
	
/*=======================================================================================
					(2)	7G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc24 = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc24' z24m* "3 3 3 3 3 3 3" misc_band24_bin1_l3333333 "Misconduct" 7
	
/*=======================================================================================
					(2)	8G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc24 = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc24' z24m* "3 3 3 3 3 3 3 3" misc_band24_bin1_l33333333 "Misconduct" 8	
		
		
/*NEXT STEPS: 
	- 
	
/*================ Update Log ================
02/21/21 - MP - Created the .do file  
 
*/ */ 
log close 


/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================		

	