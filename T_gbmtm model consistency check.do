capture log close 
cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
	global S_data "Data\" 
	global S_tabfig "Tables and Figures\"
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date:		November 28, 2021
Last Updated:	November 30, 2021 (MP)

Program Description: 	GBMTM Paper
						Run all series of trajectories using consistent estimation 

Objective: 	The objective of this file is to re-run the full series of trajectories 
	(i.e., single visits, single misconduct, dual, and multi) using a logit model, 
	poisson model, and then zip model on the analytic sample. Ideally, we want a 
	series of models that is consistent in type. 
				
See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all
	
/*=======================================================================================
						Run Series of Logit Trajectory Models   
-----------------------------------------------------------------------------------------			
This section will open the analytic 24month data in order to run a series of logit single, 
	dual, and multi trajectory models. We will first run the single trajectory values with 
	no start values - then rerun with the solution start values. Then we will use those 
	start values throughout the rest of the models. 

Steps:
	(1) Run initial single trajectories to obtain start values 
	(2) Run single trajectories with start values from (1) 
	(3) Run dual trajectories using start values 
	(4) Run multi trajectory using start values 
=========================================================================================*/		
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear 
	global visits visits_monthspre1-visits_monthspre24
	global misc   misc_monthspre1-misc_monthspre24
	
	#d 
/*=======================================================================================
					(1)	Run Single Logistic Trajectories for Start Values 
=========================================================================================*/	
*** Run Misconduct Cubic Logit and Save Start Values 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, model(logit) var($misc) indep(z24m*) order(3 3 3 3 3 3)  detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;

*** Run Visit Cubic Logit and Save Start Values 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, model(logit) var($visits) indep(z24m*) order(3 3 3 3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("P(Visit)") ci ;
			tab _traj_Group, m ;
			trajfit 6 ;	
			
*** Define matrices 		
		matrix misclogit=(-1.98435, -4.90590, 0.25663, -34.31691,
						  -3.30252, 7.96147, -9.96881, -127.71253,
						  -4.68821, 5.74003, -109.92431, -786.91988, 
						  -1.58576, 7.68306, 7.74752, -146.03268,
						  -0.46319, -6.69700, -2.91720, 177.49530,
						  1.53527, -8.44869, -52.14691, 289.38051, 
						  3.25490, 43.19295, 48.98190, 3.11929, 1.19817, 0.25279) ; 
			
		matrix visitlogit=(-5.52413, -1.42037, 29.06107, -14.75497, 
						   -1.45428, -0.14597, -13.33086, 97.31471, 
						   0.12427, 4.67224, -5.72691, -69.82540, 
						   -4.05898, -40.50556, 85.83138, 862.54091,
						   1.09824,  -23.60367, -76.18652,  485.08390,
						   3.01415, 0.42968, -42.90174, 19.29342, 
						   64.55958, 16.27985, 6.49822, 5.06287, 2.40021, 5.19928) ;		
		
/*=======================================================================================
				(2) Run Single Trajectories with Logit Models and Start Values 
=========================================================================================*/	
*** Run Misconduct Cubic Logit and Export 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, start(`misclogit') model(logit) var($misc) indep(z24m*) order(3 3 3 3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("P(Misconduct)") ci ;
			graph export "${S_tabfig}Model Check\single_misc_logit_band24_bin1_333333.png", 
				as(png) replace ; 
			tab _traj_Group, m ; 
			trajfit 6 ;

*** Run Visits Cubic Logit and Export 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, start(`visitlogit') model(logit) var($visits) indep(z24m*) order(3 3 3 3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("P(Visit)") ci ;
			graph export "${S_tabfig}Model Check\single_visits_logit_band24_bin1_333333.png", 
				as(png) replace ; 
			tab _traj_Group, m ; 
			trajfit 6 ;	
		
/*=======================================================================================
				(3) Run Dual Trajectory with Logit Models 
=========================================================================================*/			
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		matrix dual=(-5.52413, -1.42037, 29.06107, -14.75497, 
					-1.45428, -0.14597, -13.33086, 97.31471, 
					 0.12427, 4.67224, -5.72691, -69.82540, 
					-4.05898, -40.50556, 85.83138, 862.54091,
					1.09824,  -23.60367, -76.18652,  485.08390,
					3.01415, 0.42968, -42.90174, 19.29342, 
					64.55958, 16.27985, 6.49822, 5.06287, 2.40021, 5.19928,
					-1.98435, -4.90590, 0.25663, -34.31691,
					-3.30252, 7.96147, -9.96881, -127.71253,
					-4.68821, 5.74003, -109.92431, -786.91988, 
					-1.58576, 7.68306, 7.74752, -146.03268,
					-0.46319, -6.69700, -2.91720, 177.49530,
					1.53527, -8.44869, -52.14691, 289.38051, 
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66) ;
		traj, start(dual) model(logit) var($visits) indep(z24m*) order(3 3 3 3 3 3)
						  model2(logit) var2($misc) indep2(z24m*) order2(3 3 3 3 3 3) ; 
						  
/*=======================================================================================
				(4) Run Multi Trajectory with Logit Models 
=========================================================================================*/		
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear 			;	
	traj, multgroups(6) var1($visits) indep1(z24m*) order1(3 3 3 3 3 3) model1(logit) 
						  var2($misc) indep2(z24m*) order2(3 3 3 3 3 3) model2(logit) 		;
		multtrajplot, xtitle("Months Before Release") 
					  ytitle1("P(Visit)") ytitle2("P(Misconduct)") ci 						; 
		graph export "${S_tabfig}Model Check\multi_b24b1_visitslogit333333_misclogit333333",
			as(png) replace 																; 
		trajfit 6 																			; 
	#d cr 		
		
/*=======================================================================================
			Run Series of Visit Logit and Misconduct Poisson Trajectory Models   
-----------------------------------------------------------------------------------------			
This section will open the analytic 24month data in order to run a series of models with 
	logit for visits and poisson for misconduct. We will run single, dual, and multi 
	trajectory models. We will first run the single trajectory values with 
	no start values - then rerun with the solution start values. Then we will use those 
	start values throughout the rest of the models. 

Steps:
	(1) Run initial single trajectories to obtain start values 
	(2) Run single trajectories with start values from (1) 
	(3) Run dual trajectories using start values 
	(4) Run multi trajectory using start values 
=========================================================================================*/		
	global visits visits_monthspre1-visits_monthspre24
	global misc   c_misc_monthspre1-c_misc_monthspre24
	
	#d 
/*=======================================================================================
					(1)	Run Single Poisson Trajectory for Start Values 
=========================================================================================*/	
*** Run Misconduct Quadratic Poisson and Save Start Values 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, model(zip) var($misc) indep(z24m*) order(2 2 2 2 2 2)  detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;

*** Define matrices 		
		matrix miscpoisson=(-1.81770, -10.60246, -53.59056, 
						-6.84143, 3.40939, 34.51725, 
						-2.48330, 22.40688, -70.70549, 
						-1.28152, 48.40407, -661.69655, 
						-0.62384, -0.01168, 8.15848, 
						1.11879, -2.11638, -20.61224,
						9.63, 61.48, 8.61, 11.69, 7.58, 1.00) ; 	
		
/*=======================================================================================
				(2) Run Single Trajectories with Logit Models and Start Values 
=========================================================================================*/	
*** Run Misconduct Cubic Logit and Export 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, start(`misclogit') model(zip) var($misc) indep(z24m*) order(2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconduct") ci ;
			graph export "${S_tabfig}Model Check\single_misc_poisson_band24_bin1_222222.png", 
				as(png) replace ; 
			tab _traj_Group, m ; 
			trajfit 6 ;

/*=======================================================================================
				(3) Run Dual Trajectory with Logit Models 
=========================================================================================*/			
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		matrix dual=(-5.52413, -1.42037, 29.06107, -14.75497, 
					-1.45428, -0.14597, -13.33086, 97.31471, 
					 0.12427, 4.67224, -5.72691, -69.82540, 
					-4.05898, -40.50556, 85.83138, 862.54091,
					1.09824,  -23.60367, -76.18652,  485.08390,
					3.01415, 0.42968, -42.90174, 19.29342, 
					64.55958, 16.27985, 6.49822, 5.06287, 2.40021, 5.19928,
					-1.81770, -10.60246, -53.59056, 
						-6.84143, 3.40939, 34.51725, 
						-2.48330, 22.40688, -70.70549, 
						-1.28152, 48.40407, -661.69655, 
						-0.62384, -0.01168, 8.15848, 
						1.11879, -2.11638, -20.61224, 
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66,
					16.66, 16.66, 16.66, 16.66, 16.66, 16.66) ;
		traj, start(dual) model(logit) var($visits) indep(z24m*) order(3 3 3 3 3 3)
						  model2(zip) var2($misc) indep2(z24m*) order2(2 2 2 2 2 2) ; 

*** Run Dual Model with original zip conditional probability (misc|visit) solution for transition matrix 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		matrix dual=(-5.52413, -1.42037, 29.06107, -14.75497, 
					-1.45428, -0.14597, -13.33086, 97.31471, 
					 0.12427, 4.67224, -5.72691, -69.82540, 
					-4.05898, -40.50556, 85.83138, 862.54091,
					1.09824,  -23.60367, -76.18652,  485.08390,
					3.01415, 0.42968, -42.90174, 19.29342, 
					64.55958, 16.27985, 6.49822, 5.06287, 2.40021, 5.19928,
					-1.81770, -10.60246, -53.59056, 
						-6.84143, 3.40939, 34.51725, 
						-2.48330, 22.40688, -70.70549, 
						-1.28152, 48.40407, -661.69655, 
						-0.62384, -0.01168, 8.15848, 
						1.11879, -2.11638, -20.61224, 
					59.26, 14.47, 11.23, 8.58, 5.64, 0.83, 
					67.61, 10.03, 9.93, 7.72, 3.81, 0.89, 
					75.67, 8.93, 8.67, 4.76, 1.96, 0.00, 
					59.09, 13.79, 9.92, 14.53, 2.68, 0.00, 
					62.38, 17.33, 8.90, 6.47, 4.92, 0.00, 
					77.72, 10.41, 4.20, 4.63, 3.05, 0.00) ; 
		traj, start(dual) model(logit) var($visits) indep(z24m*) order(3 3 3 3 3 3)
						  model2(zip) var2($misc) indep2(z24m*) order2(2 2 2 2 2 2) ; 
						  
/*=======================================================================================
				(4) Run Multi Trajectory with Logit Models 
=========================================================================================*/		
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear 			;	
	traj, multgroups(6) var1($visits) indep1(z24m*) order1(3 3 3 3 3 3) model1(logit) 
						  var2($misc) indep2(z24m*) order2(2 2 2 2 2 2) model2(zip) 		;

		multtrajplot, xtitle("Months Before Release") 
					  ytitle1("P(Visit)") ytitle2("Misconduct") ci 						; 
		graph export "${S_tabfig}Model Check\multi_b24b1_visitslogit333333_miscpoisson222222.png",
			as(png) replace 																; 
		trajfit 6 																			; 		
	#d cr 
	
/*=======================================================================================
			Run Series of Visit Logit and Misconduct ZIP Trajectory Models   
-----------------------------------------------------------------------------------------			
This section will open the analytic 24month data in order to run a series of models with 
	logit for visits and ZIP for misconduct. We will run single, dual, and multi 
	trajectory models. We will first run the single trajectory values with 
	no start values - then rerun with the solution start values. Then we will use those 
	start values throughout the rest of the models. 

Steps:
	(1) Run initial single trajectories to obtain start values 
	(2) Run single trajectories with start values from (1) 
	(3) Run dual trajectories using start values 
	(4) Run multi trajectory using start values 
=========================================================================================*/		
	global visits visits_monthspre1-visits_monthspre24
	global misc   c_misc_monthspre1-c_misc_monthspre24
	
	#d 
/*=======================================================================================
					(1)	Run Single ZIP Trajectory for Start Values 
=========================================================================================*/	
*** Run Misconduct Quadratic Poisson and Save Start Values 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, model(zip) var($misc) indep(z24m*) order(2 2 2 2 2 2) io(2 2 2 2 2 2)  detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;

*** Define matrices 			
		
/*=======================================================================================
				(2) Run Single Trajectories with Logit Models and Start Values 
=========================================================================================*/	
*** Run Misconduct Cubic Logit and Export 
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, /*start(`misclogit')*/ model(zip) var($misc) indep(z24m*) order(2 2 2 2 2 2) io(2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconduct") ci ;
			graph export "${S_tabfig}Model Check\single_misc_zip_band24_bin1_222222.png", 
				as(png) replace ; 
			tab _traj_Group, m ; 
			trajfit 6 ;

/*=======================================================================================
				(3) Run Dual Trajectory with Logit Models 
=========================================================================================*/			
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear ;
		traj, model(logit) var($visits) indep(z24m*) order(3 3 3 3 3 3)
			  model2(zip) var2($misc) indep2(z24m*) order2(2 2 2 2 2 2) iorder2(2 2 2 2 2 2) ; 
						  
/*=======================================================================================
				(4) Run Multi Trajectory with Logit Models 
=========================================================================================*/		
	use "${S_data}Analytic Data\Subsamples\analytic(24 month final).dta", clear 			;	
	traj, multgroups(6) var1($visits) indep1(z24m*) order1(3 3 3 3 3 3) model1(logit) 
			var2($misc) indep2(z24m*) order2(2 2 2 2 2 2) iorder2(2 2 2 2 2 2) model2(zip) 	;
		multtrajplot, xtitle("Months Before Release") 
					  ytitle1("P(Visit)") ytitle2("Misconduct") ci 						; 
		graph export "${S_tabfig}Model Check\multi_b24b1_visitslogit333333_miscpoisson222222.png",
			as(png) replace 																; 
		trajfit 6 																			; 	
		
	#d cr 
	
/*NEXT STEPS:
	- 

/*================ Update Log ================
11/30/21 - MP	- Updated the trajectories using start files 
11/28/21 - MP	- Created file
 
*/ */ 
log close 

	
/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================	
