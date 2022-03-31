/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date: 	March 18, 2020
Last Updated: 	March 18, 2020 (MP)

Program Description: 	PA Visits 
						Create GBMTM Tables  

Objective: 	The objective of this file is to create GBMTM tables that mimic
				Tables 2 and 3 from Hickert et al. (2018). 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all



/*=======================================================================================
							Misconduct ZIP Models: Quadratic 
-----------------------------------------------------------------------------------------			
The following code will run a series of trajectory models both with and without zip. They 
	will range from two groups up to seven groups. 

=========================================================================================*/			
				
/*=======================================================================================
					(1)	2G [Band:24, Bin:1] Zip (22) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2) iorder(2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_22_io22.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 2 ;
		#d cr 
	
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_22.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 2 ;
		#d cr 
		
/*=======================================================================================
					(2)	3G [Band:24, Bin:1] Logit (222) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2) iorder(2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_222_io222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 3 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 3 ;
		#d cr 
	
/*=======================================================================================
					(2)	4G [Band:24, Bin:1] Logit (2222) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2) iorder(2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_2222_io2222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 4 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "ables and Figures/Single Traj Models/zip_misc_band24_bin1_2222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 4 ;
		#d cr 
	
/*=======================================================================================
					(2)	5G [Band:24, Bin:1] Zip (22222) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2 2) iorder(2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_22222_io22222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 5 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_22222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 5 ;
		#d cr 

/*=======================================================================================
					(2)	6G [Band:24, Bin:1] Zip (222222) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2 2 2) iorder(2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_222222_io222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;
		#d cr 

/*=======================================================================================
					(2)	7G [Band:24, Bin:1] Zip (2222222) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2 2 2 2) iorder(2 2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_2222222_io222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 7 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_2222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 7 ;
		#d cr 				
		

/*=======================================================================================
							Misconduct ZIP Models: Cubic 
-----------------------------------------------------------------------------------------			
The following code will run a series of trajectory models both with and without zip. They 
	will range from two groups up to seven groups. 

=========================================================================================*/			
				
/*=======================================================================================
					(1)	2G [Band:24, Bin:1] Zip (22) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3) iorder(2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_33_io22.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 2 ;
		#d cr 
	
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "CTables and Figures/Single Traj Models/zip_misc_band24_bin1_33.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 2 ;
		#d cr 
		
/*=======================================================================================
					(2)	3G [Band:24, Bin:1] Zip (333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3) iorder(2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_333_io222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 3 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_333.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 3 ;
		#d cr 
	
/*=======================================================================================
					(2)	4G [Band:24, Bin:1] Zip (3333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3) iorder(2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_3333_io2222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 4 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_3333.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 4 ;
		#d cr 
	
/*=======================================================================================
					(2)	5G [Band:24, Bin:1] Zip (33333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3) iorder(2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_33333_io22222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 5 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_33333.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 5 ;
		#d cr 

/*=======================================================================================
					(2)	6G [Band:24, Bin:1] Zip (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3 3) iorder(2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_333333_io222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_333333.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;
		#d cr 

/*=======================================================================================
					(2)	7G [Band:24, Bin:1] Zip (3333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3 3 3) iorder(2 2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_3333333_io222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 7 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_3333333.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 7 ;
		#d cr
		
/*=======================================================================================
					(2)	8G [Band:24, Bin:1] Zip (3333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3 3 3 3) iorder(2 2 2 2 2 2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_33333333_io2222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 8 ;
		#d cr 
		
*** No Inflation 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(3 3 3 3 3 3 3 3) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_33333333.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 8 ;
		#d cr
		
/*=======================================================================================
						GBMTM Models: Quadratic ZIP No Inflation Ordering
-----------------------------------------------------------------------------------------			
The following code will run a series of GBMTM models. These models will utilize quadratic
	ZIP models and no inflation ordering. THey will go through the series of models from 
	two groups to six groups. After six the model fit for the single is off. 

=========================================================================================*/		

/*=======================================================================================
				2G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 2 `visits' z24m* "3 3" "logit" `misc' z24m* "2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l33_z22" "." 
			trajfit 2
			
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z222" "." 
			trajfit 3
			
/*=======================================================================================
				4G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 4 `visits' z24m* "3 3 3 3" "logit" `misc' z24m* "2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l3333_z2222" "." 
			trajfit 4
			
/*=======================================================================================
				5G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 5 `visits' z24m* "3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l33333_z22222" "." 
			trajfit 5
			
/*=======================================================================================
				6G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 6 `visits' z24m* "3 3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333333_z222222" "." 
			trajfit 6	
	

/*=======================================================================================
						GBMTM Models: Cubic ZIP No Inflation Ordering
-----------------------------------------------------------------------------------------			
The following code will run a series of GBMTM models. These models will utilize cubic
	ZIP models and no inflation ordering. THey will go through the series of models from 
	two groups to six groups. After six the model fit for the single is off. 

=========================================================================================*/		

/*=======================================================================================
				2G [Band:24, Bin:1] Mixed L(22) Z(33) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 2 `visits' z24m* "3 3" "logit" `misc' z24m* "3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l33_z33" "." 
			trajfit 2
			
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(333) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z333" "." 
			trajfit 3
			
/*=======================================================================================
				4G [Band:24, Bin:1] Mixed L(3333) Z(3333) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 4 `visits' z24m* "3 3 3 3" "logit" `misc' z24m* "3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l3333_z3333" "." 
			trajfit 4
			
/*=======================================================================================
				5G [Band:24, Bin:1] Mixed L(33333) Z(33333) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 5 `visits' z24m* "3 3 3 3 3" "logit" `misc' z24m* "3 3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l33333_z33333" "." 
			trajfit 5
			
/*=======================================================================================
				6G [Band:24, Bin:1] Mixed L(333333) Z(333333) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 6 `visits' z24m* "3 3 3 3 3 3" "logit" `misc' z24m* "3 3 3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l333333_z333333" "." 
			trajfit 6	
	
	
/*=======================================================================================
					GBMTM Models: Quadratic ZIP - Quadratic Inflation Ordering
-----------------------------------------------------------------------------------------			
The following code will run a series of GBMTM models. These models will utilize quadratic
	ZIP models and no inflation ordering. THey will go through the series of models from 
	two groups to six groups. After six the model fit for the single is off. 

=========================================================================================*/		

/*=======================================================================================
				2G [Band:24, Bin:1] Mixed L(33) Z(22) io(22) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 2 `visits' z24m* "3 3" "logit" `misc' z24m* "2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l33_z22_io22" "2 2" 
			trajfit 2
			
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(222) io(222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z222_io222" "2 2 2" 
			trajfit 3
			
/*=======================================================================================
				4G [Band:24, Bin:1] Mixed L(3333) Z(2222) io(2222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 4 `visits' z24m* "3 3 3 3" "logit" `misc' z24m* "2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l3333_z2222_io2222" "2 2 2 2" 
			trajfit 4
			
/*=======================================================================================
				5G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(22222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 5 `visits' z24m* "3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l33333_z22222_io22222" "2 2 2 2 2" 
			trajfit 5
			
/*=======================================================================================
				6G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(222222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 6 `visits' z24m* "3 3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333333_z222222_io222222" "2 2 2 2 2 2" 
			trajfit 6	

/*=======================================================================================
				7G [Band:24, Bin:1] Mixed L(3333333) Z(2222222) io(2222222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 7 `visits' z24m* "3 3 3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l3333333_z2222222_io2222222" "2 2 2 2 2 2 2" 
			trajfit 7	
			
/*=======================================================================================
				8G [Band:24, Bin:1] Mixed L(33333333) Z(22222222) io(22222222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 8 `visits' z24m* "3 3 3 3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l33333333_z22222222_io22222222" "2 2 2 2 2 2 2 2" 
			trajfit 8		

/*=======================================================================================
				9G [Band:24, Bin:1] Mixed L(33333333) Z(22222222) io(22222222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 9 `visits' z24m* "3 3 3 3 3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333333333_z222222222_io222222222" "2 2 2 2 2 2 2 2 2" 
			trajfit 9	
			
			
/*=======================================================================================
						GBMTM Models: Cubic ZIP - Quadratic Inflation Ordering
-----------------------------------------------------------------------------------------			
The following code will run a series of GBMTM models. These models will utilize cubic
	ZIP models and no inflation ordering. THey will go through the series of models from 
	two groups to six groups. After six the model fit for the single is off. 

=========================================================================================*/		

/*=======================================================================================
				2G [Band:24, Bin:1] Mixed L(22) Z(33) io(22) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 2 `visits' z24m* "3 3" "logit" `misc' z24m* "3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l33_z33_io22" "2 2" 
			trajfit 2
			
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(333) io(222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z333_io222" "2 2 2" 
			trajfit 3
			
/*=======================================================================================
				4G [Band:24, Bin:1] Mixed L(3333) Z(3333) io(2222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 4 `visits' z24m* "3 3 3 3" "logit" `misc' z24m* "3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l3333_z3333_io2222" "2 2 2 2" 
			trajfit 4
			
/*=======================================================================================
				5G [Band:24, Bin:1] Mixed L(33333) Z(33333) io(22222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 5 `visits' z24m* "3 3 3 3 3" "logit" `misc' z24m* "3 3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l33333_z33333_io22222" "2 2 2 2 2" 
			trajfit 5
			
/*=======================================================================================
				6G [Band:24, Bin:1] Mixed L(333333) Z(333333) io(222222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 6 `visits' z24m* "3 3 3 3 3 3" "logit" `misc' z24m* "3 3 3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l333333_z333333_io222222" "2 2 2 2 2 2" 
			trajfit 6	
			
			
/*=======================================================================================
					Dual Trajectory Models: Cubic ZIP No Inflation Ordering
-----------------------------------------------------------------------------------------			
The following code will run a series of dual trajectory models in order to see the transition
	probabilites. 
	
Steps:
	(1) 6G Logit Visit: 6G Zip Misconduct  
	(2) 3G Logit Visit: 3G Logit Misconduct 
	(3) 3G Logit Visit: 3G ZIP Misconduct w/ iorder  
=========================================================================================*/		
/*=======================================================================================
					(1)	Dual: 6G Logit Visit: 6G Zip (2) Misconduct No io
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		matrix dual=(-5.52630, -1.37264, 29.13888, -16.79778, -1.45652, -0.14404, -13.34972, 97.30243, 0.11602, 4.67547, -5.21925, -68.26627, -4.05069, -40.42134, 85.57396, 859.54204, 1.09815, -23.37178, -76.24529, 474.99798, 3.01143, 0.42818, -42.82675, 19.68564, 64.54805, 16.29952, 6.47682, 5.06491, 2.40768, 5.20302, -1.89224, -15.00428, -81.69867, -7.43238, 1.14147, 52.64206, -9.96632, 141.55282, -526.66955, -1.49656, 35.72175, -362.37905, -1.00748, 1.86750, 13.06559, 0.90560, -2.32227, -18.80207, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66, 16.66)
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		#d 
		traj, start(dual) model(logit) var(`visits') indep(z24m*) order(3 3 3 3 3 3)
						  model2(zip) var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) ; 
		#d cr 


*** Run Model 
	use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 
		matrix dual=(-4.47904, 0.72963, 40.80747, 145.86126, -0.55243, 5.44255, -79.69543, 267.5794, -1.57833, -60.34982, 47.98002, 4641.8123, -3.77303, 3.24641, 19.74487, -555.67806, 2.42581, -3.64937, -198.6767, 815.35059, 0.70234, -0.24541, -18.16303, 0.74147, 2.43001, -26.8324, 0.78471, -3.14393, 2.26912, 1.17946, 0.45448, -5.40054, 0.72642, 1.14064, -23.68848, 4.14276, -4.14447, -33.51588, 4.01054, 1.75076, -18.36951, 4.28284, -4.62253, -13.19635, 0.55933, 2.10001, 32.50206, 4.33948, -2.41748, -5.66998, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00)
		local misc = "c_misc_monthspre1-c_misc_monthspre12" 
		local visits = "visits_monthspre1-visits_monthspre12"
		#d 
		traj, start(dual) model(logit) var(`visits') indep(z12m*) order(3 3 3 3 3)
						  model2(zip) var2(`misc') indep2(z12m*) order2(2 2 2 2 2) iorder2(2 2 2 2 2) ; 
		#d cr 
	
*** Run Model 
	use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 
		matrix dual=(-4.47904, 0.72963, 40.80747, 145.86126, -0.55243, 5.44255, -79.69543, 267.5794, -1.57833, -60.34982, 47.98002, 4641.8123, -3.77303, 3.24641, 19.74487, -555.67806, 2.42581, -3.64937, -198.6767, 815.35059,  55.29, 23.39, 4.10, 9.40, 7.81, 0.70234, -0.24541, -18.16303, 0.74147, 2.43001, -26.8324, 0.78471, -3.14393, 2.26912, 1.17946, 0.45448, -5.40054, 0.72642, 1.14064, -23.68848, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00, 20.00)
		local misc = "c_misc_monthspre1-c_misc_monthspre12" 
		local visits = "visits_monthspre1-visits_monthspre12"
		#d 
		traj, start(dual) model(logit) var(`visits') indep(z12m*) order(3 3 3 3 3)
						  model2(zip) var2(`misc') indep2(z12m*) order2(2 2 2 2 2) ; 
		#d cr

*** Run Model 
	use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre12" 
		local visits = "visits_monthspre1-visits_monthspre12"
		#d 
		traj, model(logit) var(`visits') indep(z12m*) order(3 3 3 3 3)
			  model2(zip) var2(`misc') indep2(z12m*) order2(2 2 2 2 2) ; 
		#d cr

*** Run Dual 4G: Band 12, Bind 1
	use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre12" 
		local visits = "visits_monthspre1-visits_monthspre12"
		#d 
		traj, model(logit) var(`visits') indep(z12m*) order(3 3 3 3)
			  model2(zip) var2(`misc') indep2(z12m*) order2(2 2 2 2) ; 
		#d cr
	



		
/*NEXT STEPS: 
	- 

/*================ Update Log ================
03/18/20 - MP 	- Began the .do file  
 
*/ */ 
log close 



/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================

matrix dual=(-1.71518, -0.43479, 1.71338, 1.84124, -43.84431, 76.89131, 71.76577, -130.40234, -1.90609, 2.37260, -0.22123, -0.92249, -0.53796, -0.13640, -0.19532, 1.00637, 35.89854, 9.74464, 36.47239, 17.88443, -2.17114, -2.48908, -1.73046, 0.59602, -0.84301, 0.09609, -0.16831, -3.92858, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33) 
traj, start(dual) model(logit) var(sixmospre2-sixmospre21) indep(t*) order(3 3 3 3) model2(logit) var2(sixmospost1-sixmospost12) indep2(z*) order2(1 2 2)	