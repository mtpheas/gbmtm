cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date:   	February 19, 2021
Last Updated:	February 19, 2021 (MP)

Program Description: 	GBMTM Paper 
						Single and Dual Models and Sample Creation    

Objective: 	The objective of this file is to run the final trajectory models 
	(single, dual, and potentially multi) in order to get a accessible log file
	with the final coefficients and diagnostic statistics. Additionally, we will
	use the dual model to re-classify the sample into joint probability groups. 

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
							Single Trajectory Models 
-----------------------------------------------------------------------------------------                       
This section will run the final single trajectory models for misconducts and visits. 
	Each model will be run (1) without start values [in order to try and recover previous
	estimates], and (2) with the start values from the previous solutions. We will 
	then report these values and export them in order to create the graphs in Excel. 
	
Steps: 
	(1) Estimate Six Group Solution Visits Logit Single Trajectory Model 
	(2) Estimate Six Group Solution Misconduct ZIP Single Trajectory Model 
=========================================================================================*/ 	
/*=======================================================================================
				(1) 6G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/
*** Without Start Values 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
	traj, model(logit) var(visits_monthspre1-visits_monthspre24) indep(z24m*) ///
			order(3 3 3 3 3 3) detail 
		trajplot, xtitle("Time Periods (t)") ytitle("P(Visits)") ci
			graph export "${S_tabfig}b24b1_6G_l333333", as(png) replace
		trajfit 6
	
*** With Start Values from Previous Estimation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		matrix start=(-5.40249, -2.26915, 30.48595, -1.75262, -1.37864, 1.24586, -13.59047, 78.35357, 0.47671, -1.43649, -22.0582, 45.03312, -4.0368, -0.88007, -0.30112, 53.36866, -2.98128, -32.73003, 50.86524, 618.41382, 3.18117, 1.04181, -45.39213, -7.79266, 64.55836, 16.27863, 6.4837, 5.06543, 2.40300, 5.19821)
	traj, start(start) model(logit) var(visits_monthspre1-visits_monthspre24) indep(z24m*) ///
			order(3 3 3 3 3 3) detail 
		trajplot, xtitle("Time Periods (t)") ytitle("P(Visits)") ci
			graph export "${S_tabfig}b24b1_6G_l333333_sv", as(png) replace
		trajfit 6

/*=======================================================================================
				(2)	6G [Band:24, Bin:1] Zip (222222) Subsample(24m)
=========================================================================================*/	
*** Without Start Values, Without Inflation Order 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
	traj, model(zip) var(c_misc_monthspre1-c_misc_monthspre24) indep(z24m*) ///
			order(2 2 2 2 2 2) detail 
		trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci
			graph export "${S_tabfig}b24b1_6G_z222222", as(png) replace
		trajfit 6
	
*** Without Start Values, With Inflation Order
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
	traj, model(zip) var(c_misc_monthspre1-c_misc_monthspre24) indep(z24m*) ///
			order(2 2 2 2 2 2) io(2 2 2 2 2 2) detail 
		trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci
			graph export "${S_tabfig}b24b1_6G_z222222_io222222", as(png) replace
		trajfit 6				

*** With Start Values from Previous Estimation, Without Inflation Order  
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		matrix start=(0.7993, 0.53792, -6.66293, 0.72475, 0.30505, 1.68758, 0.78755, 0.27263, -1.92664, 1.16169, -0.46166, -4.56024, 0.90672, 0.99032, -10.54277, 0.76499, 0.24916, 0.06458, 9.6, 61.7, 8.4, 11.7, 7.6, 1.0)
	traj, model(zip) var(c_misc_monthspre1-c_misc_monthspre24) indep(z24m*) ///
			order(2 2 2 2 2 2) detail 
		trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci
			graph export "${S_tabfig}b24b1_6G_z222222_sv", as(png) replace
		trajfit 6

*** With Start Values from Previous Estimation, With Inflation Order
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		matrix start=(0.7993, 0.53792, -6.66293, 0.72475, 0.30505, 1.68758, 0.78755, 0.27263, -1.92664, 1.16169, -0.46166, -4.56024, 0.90672, 0.99032, -10.54277, 0.76499, 0.24916, 0.06458, 3.54441, -3.45215, 8.21109, 3.63844, -2.74014, 12.3467, 3.62172, -2.16346, 1.09245, 0.91059, 0.59804, -2.13315, 3.44415, -3.65475, -0.73096, 4.16897, -3.80797, -4.63231, 9.6, 61.7, 8.4, 11.7, 7.6, 1.0)
	traj, model(zip) var(c_misc_monthspre1-c_misc_monthspre24) indep(z24m*) ///
			order(2 2 2 2 2 2) io(2 2 2 2 2 2) detail 
		trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci
			graph export "${S_tabfig}b24b1_6G_z222222_io222222_sv", as(png) replace
		trajfit 6


/*=======================================================================================
							Dual Trajectory Models 
-----------------------------------------------------------------------------------------                       
This section will run the final dual trajectory models for the previous misconduct and 
	export them to plot the dual trajecotires. Additionally, we will create indicators 
	for the joint probabilities. 
	
Steps: 
	(1) Estimate Dual Model without Start Values 
	(2) Estimate Dual Model with Previous Solution Start Values 
	(3) Create Indicators Based on Joint Probabilities 
=========================================================================================*/ 
*** Without Start Values, no IO 
	use "Analytic Data/Subsamples/analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"
		local visits = "visits_monthspre1-visits_monthspre24"
	traj, model(logit) var(`visits') indep(z24m*) order(3 3 3 3 3 3) ///
			model2(zip) var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) 

*** Start Values from Previous Estimation, no IO
	use "Analytic Data/Subsamples/analytic(24 month mixed).dta", clear
		#d
		matrix dual=(0.13253, 4.77976, -6.31394, -71.57329,
					-1.47227, -0.23411, -11.61153, 90.42403, 
					-5.53073, -1.41286, 29.21350, -17.27361, 
					-4.26484, -42.32665, 90.28387, 901.90889, 
					0.93557, -24.26739, -70.14462, 508.60668, 
					3.01241, 0.23509, -44.16686, 19.77010, 
					6.49133, 15.50391, 64.51452, 4.75865, 2.48610, 5.24549, 
					-1.81770, -10.60246, -53.59056, 
					-6.84143, 3.40939, 34.51725, 
					-2.48330, 22.40688, -70.70549, 
					-1.28152, 48.40407, -661.69655, 
					-0.62384, -0.01168, 8.15848, 
					1.11879, -2.11638, -20.61224, 
					8.67302, 75.67301, 8.93037, 4.76166, 1.96194, 0.00000, 
					9.93278, 67.60896, 10.03478, 7.72391, 3.81116, 0.88841, 
					11.22830, 59.26156, 14.47019, 8.57578, 5.63650, 0.82767, 
					8.90246, 62.37840, 17.33018, 6.47139, 4.91757, 0.00000, 
					9.91738, 59.09038, 13.78853, 14.52709, 2.67662, 0.00000, 
					4.19968, 77.71484, 10.41037, 4.62694, 3.04816, 0.00000) ; 
		#d cr
		local misc = "c_misc_monthspre1-c_misc_monthspre24"
		local visits = "visits_monthspre1-visits_monthspre24"
	traj, start(dual) model(logit) var(`visits') indep(z24m*) order(3 3 3 3 3 3) ///
			model2(zip) var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) detail

*** Without Start Values, IO
	use "Analytic Data/Subsamples/analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"
		local visits = "visits_monthspre1-visits_monthspre24"
	traj, model(logit) var(`visits') indep(z24m*) order(3 3 3 3 3 3) ///
			model2(zip) var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) iorder2(2 2 2 2 2 2)
			
*** With Start Values from Previous Estimation with IO
	use "Analytic Data/Subsamples/analytic(24 month mixed).dta", clear
		#d 
		matrix dual=(-5.68864, -6.29457, -137.96342, -877.65608, 
					 -1.79430, -0.12689, -10.15610, 103.93151, 
					 -0.05226, 4.11694, -5.76791, -50.32414, 
					 -3.92403, -39.00985, 85.05475, 822.31922, 
					 1.07815, -23.49610, -78.25085, 478.26487, 
					 2.87591, 0.63525, -40.34808, 12.59576, 
					 60.59126, 18.85442, 7.67956, 5.01891, 2.40762, 5.44823, 
					 2.06269, -1.20988, -3.41814, 
					 1.44088, -0.43001, -14.15001, 
					 0.64230, -0.30230, 11.03107, 
					 1.22925, 3.41147, -4.70532, 
					 0.72047, 1.32846, -7.35698, 
					 0.80266, -0.15711, -4.47815, 
					 -0.95020, 2.53738, 4.31179, 
					 -0.25656, 2.96883, 25.83508, 
					 1.07543, 1.23538, -10.18182, 
					 2.52925, 6.34226, -1.11541, 
					 2.30098, -7.01982, 17.38174, 
					 4.15042, -3.46013, 17.25966, 
					 0.17051, 0.85418, 3.71786, 4.22777, 16.93814, 74.09154,
					 0.00000, 0.73837, 2.11238, 5.51151, 9.23706, 82.40068, 
					 0.00000, 0.63027, 1.89516, 0.00000, 4.48747, 92.98710, 
					 0.00001, 0.00000, 2.45225, 0.00000, 16.56612, 80.98162, 
					 0.00000, 0.00000, 0.00000, 0.00000, 24.98911, 75.01089, 
					 0.00001, 0.00000, 1.52608, 0.97997, 5.05305, 92.44089) ; 
		#d cr 
		local misc = "c_misc_monthspre1-c_misc_monthspre24"
		local visits = "visits_monthspre1-visits_monthspre24"
	traj, start(dual) model(logit) var(`visits') indep(z24m*) order(3 3 3 3 3 3) ///
			model2(zip) var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) iorder2(2 2 2 2 2 2) detail

*** With Start Values from GBMTM Solution, with IO
	use "Analytic Data/Subsamples/analytic(24 month mixed).dta", clear
	#d 
	matrix dual = (-5.40249, -2.26915, 30.48595, -1.75262, 
				-1.37864, 1.24586, -13.59047, 78.35357, 
				0.47671, -1.43649, -22.0582, 45.03312, 
				-4.0368, -0.88007, -0.30112, 53.36866, 
				-2.98128, -32.73003, 50.86524, 618.41382, 
				3.18117, 1.04181, -45.39213, -7.79266, 
				60.59126, 18.85442, 7.67956, 5.01891, 2.40762, 5.44823,
				0.7993, 0.53792, -6.66293, 
				0.72475, 0.30505, 1.68758, 
				0.78755, 0.27263, -1.92664, 
				1.16169, -0.46166, -4.56024, 
				0.90672, 0.99032, -10.54277, 
				0.76499, 0.24916, 0.06458, 
				3.544, -3.452, 8.211, 
				3.638, -2.740, 12.347, 
				3.622, -2.163, 1.092, 
				0.911, 0.598, -2.133, 
				3.444, -3.655, -0.731, 
				4.169, -3.808, -4.632, 
				16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 
				16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
				16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
				16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
				16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
				16.66, 16.66, 16.66, 16.66, 16.66, 16.66) ; 
		#d cr 
		local misc = "c_misc_monthspre1-c_misc_monthspre24"
		local visits = "visits_monthspre1-visits_monthspre24"
	traj, start(dual) model(logit) var(`visits') indep(z24m*) order(3 3 3 3 3 3) ///
			model2(zip) var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) iorder2(2 2 2 2 2 2) detail
			
			
			

	
		
		
/*NEXT STEPS: 
 
	
/*================ Update Log ================
02/19/21 - MP - Created the .do file  
 
*/ */ 
log close 



/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================		
