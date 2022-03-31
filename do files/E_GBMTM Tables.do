cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
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
						Create Local Programs used for Coding
=========================================================================================*/
*** Define a Program to Automate the pos creation process 
	program define makepos2
		version 15.1
		args 1 2 3 4
			matrix `1'=[.]
				foreach i of numlist  -`2'(.08)-.04 .04(.08)`2' {	
					di `i'
					matrix `1'=[`1',`i']
					}
				matrix `1'=`1'[1,2...n]
				matrix list `1'
				foreach i of numlist 1/`3' {
					gen `4'`i'=`1'[1,`i']
					}
	end 
	
*** Define a Program to Automate Single Traj: Normal, No Detail, Start Values 
	program define trajstats 
		version 15.1
		args a b c d e 1
		traj, model(logit) var(`a') indep(`b') order(`c') detail
			trajplot, xtitle("Time Periods (t)") ytitle("P(`e')") ci
			graph export "Tables and Figures/Single Traj Models/`d'.png", as(png) replace 
			tab _traj_Group, m //Looks at Assigned Probabilities 
			trajfit `1'
	end

	program define trajstatsnod
		version 15.1
		args a b c d e 1
		traj, model(logit) var(`a') indep(`b') order(`c') 
			trajplot, xtitle("Time Periods (t)") ytitle("P(`e')") ci
			graph export "Tables and Figures/Single Traj Models/`d'.png", as(png) replace 
			tab _traj_Group, m //Looks at Assigned Probabilities 
			trajfit `1'
	end

	program define trajstatsstart
		version 15.1
		args a b c d e f 1
		traj, start(`e') model(logit) var(`a') indep(`b') order(`c') //detail
			trajplot, xtitle("Time Periods (t)") ytitle("P(`f')") ci
			graph export "Tables and Figures/Single Traj Models/`d'.png", as(png) replace 
			tab _traj_Group, m //Looks at Assigned Probabilities 
			trajfit `1'
	end

	program define ziptraj
		version 15.1
		args a b c d e 1
		traj, model(zip) var(`a') indep(`b') order(`c') iorder(`c') detail
			trajplot, xtitle("Time Periods (t)") ytitle("`e'") ci
			graph export "Tables and Figures/Single Traj Models/`d'.png", as(png) replace 
			tab _traj_Group, m //Looks at Assigned Probabilities 
			trajfit `1'
	end
	
*** Define a Program to Run Dual Trajectories 
	program define dualtraj 
		version 15.1
		args a b c d e f g h i 
			#d
				traj, start(`a') model(`b') var(`c') indep(`d') order(`e')
							  model2(`f') var2(`g') indep2(`h') order2(`i') ;
			#d cr 
	end
		/* Where: 
			a: Start Value Matrix				b: Model 1 Link Fxn 
			c: Model 1 DV						d: Model 1 IVs
			e: Model 1 Polynomial Ordering		f: Model 2 Link Fxn
			g: Model 2 DV						h: Model 2 IVs
			i: Model 2 Polynomial Ordering
		*/
	

*** Define a Program to Run GBMTM
	program define gbmtm 
		version 15.1
		args a b c d e f g h i j k l m
			if "`m'"=="." {
				#d 
					traj, multgroups(`a') var1(`b') indep1(`c') order1(`d') model1(`e') 
										var2(`f') indep2(`g') order2(`h') model2(`i') ;
				#d cr
					multtrajplot, xtitle("Months Before Release") ytitle1("P(`j')") ytitle2("P(`k')") ci
					graph export "Tables and Figures/GBMTM/`l'.png", as(png) replace 
				}
			if "`m'"!="." {
				#d 
					traj, multgroups(`a') var1(`b') indep1(`c') order1(`d') model1(`e') 
										var2(`f') indep2(`g') order2(`h') iorder2(`m') model2(`i') ;
				#d cr
					multtrajplot, xtitle("Months Before Release") ytitle1("P(`j')") ytitle2("`k'") ci
					graph export "Tables and Figures/GBMTM/`l'.png", as(png) replace 
				}
	end	
		/* Where: 
			a: Number of Groups					b: Model 1 DV
			c: Model 1 IVs						d: Model 1 Polynomial Ordering
			e: Model 1 Link Fxn 				f: Model 2 DV
			g: Model 2 IVs						h: Model 2 Polynomial Ordering
			i: Model 2 Link Fxn 				j: Model 1 Label 
			k: Model 2 Label					l: File png Name
			m: Model 2 Inflation Ordering
		*/

/*=======================================================================================
						Table 2 Replication: Model Selection 
-----------------------------------------------------------------------------------------			
The following code will run a series of gbmtm in order to replicate the second table. This
	table works it's way up from a two group solution to larger solutions. 
	
Steps:
	(1) Two Group 
	(2) Three Group
	(3) Four Group 
	(4) Five Group
=========================================================================================*/	

/*=======================================================================================
			(1) 2G [Band:24, Bin:1] Mixed L(3 3) Z(3 3) io(2 2) Subsample(24m)
=========================================================================================*/
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 2 `visits' z24m* "3 3" "logit" `misc' z24m* "3 3" "zip" "Visits" "Misconducts" "b24b1_2G_l33_z33_io22" "2 2" 
			trajfit 2
	
/*=======================================================================================
			(2) 2G [Band:24, Bin:1] Mixed L(3 3 3) Z(3 3 3) io(2 2 2) Subsample(24m)
=========================================================================================*/
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "3 3 3" "zip" "Visits" "Misconducts" "b24b1_2G_l333_z333_io222" "2 2 2" 
			trajfit 3
			
/*=======================================================================================
			(3) 2G [Band:24, Bin:1] Mixed L(3 3 3 3) Z(3 3 3 3) io(2 2 2 2) Subsample(24m)
=========================================================================================*/
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 4 `visits' z24m* "3 3 3 3" "logit" `misc' z24m* "3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_2G_l3333_z3333_io2222" "2 2 2 2" 
			trajfit 4
			
/*=======================================================================================
			(4) 2G [Band:24, Bin:1] Mixed L(3 3 3 3 3) Z(3 3 3 3 3) io(2 2 2 2 2) Subsample(24m)
=========================================================================================*/
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 5 `visits' z24m* "3 3 3 3 3" "logit" `misc' z24m* "3 3 3 3 3" "zip" "Visits" "Misconducts" "b24b1_2G_l33333_z33333_io22222" "2 2 2 2 2" 
			trajfit 5

			
/*=======================================================================================
						Table 2a Replication: Model Selection for Logit 
-----------------------------------------------------------------------------------------			
The following code will run a series of logits in order to replicate the model selection 
	statistics across total numbers of groupss. 
	
Steps:
	(1) Two Group 
	(2) Three Group
	(3) Four Group 
	(4) Five Group
=========================================================================================*/	
			
/*=======================================================================================
					(1)	2G [Band:24, Bin:1] Logit (33) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local visits24 = "visits_monthspre1-visits_monthspre24" 
		trajstats `visits24' z24m* "3 3" visit_band24_bin1_33 "Visit" 2
	
/*=======================================================================================
					(2)	3G [Band:24, Bin:1] Logit (333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local visits24 = "visits_monthspre1-visits_monthspre24" 
		trajstats `visits24' z24m* "3 3 3" visit_band24_bin1_333 "Visits" 3
	
/*=======================================================================================
					(2)	4G [Band:24, Bin:1] Logit (333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local visits24 = "visits_monthspre1-visits_monthspre24" 
		trajstats `visits24' z24m* "3 3 3 3" visit_band24_bin1_3333 "Visits" 4	
	
/*=======================================================================================
					(2)	5G [Band:24, Bin:1] Logit (333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local visits24 = "visits_monthspre1-visits_monthspre24" 
		trajstats `visits24' z24m* "3 3 3 3 3" visit_band24_bin1_33333 "Visits" 5	

/*=======================================================================================
					(2)	6G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local visits24 = "visits_monthspre1-visits_monthspre24" 
		trajstats `visits24' z24m* "3 3 3 3 3 3" visit_band24_bin1_333333 "Visits" 6
	
/*=======================================================================================
					(2)	7G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local visits24 = "visits_monthspre1-visits_monthspre24" 
		trajstats `visits24' z24m* "3 3 3 3 3 3 3" visit_band24_bin1_3333333 "Visits" 7
	
/*=======================================================================================
					(2)	8G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local visits24 = "visits_monthspre1-visits_monthspre24" 
		trajstats `visits24' z24m* "3 3 3 3 3 3 3 3" visit_band24_bin1_33333333 "Visits" 8
		
		
/*=======================================================================================
						Table 2b Replication: Model Selection for ZIP 
-----------------------------------------------------------------------------------------			
The following code will run a series of logits in order to replicate the model selection 
	statistics across total numbers of groups. 
	
Steps:
	(1) Two Group 
	(2) Three Group
	(3) Four Group 
	(4) Five Group
=========================================================================================*/	
			
/*=======================================================================================
					(1)	2G [Band:24, Bin:1] Logit (33) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "c_misc_monthspre1-c_misc_monthspre24"  
		#d
		traj, model(zip) var(`misc') indep(z24m*) order(2 2) iorder(2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_33_io22.png", as(png) replace ;
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
					(2)	3G [Band:24, Bin:1] Logit (333) Subsample(24m)
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
					(2)	4G [Band:24, Bin:1] Logit (333) Subsample(24m)
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
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_2222.png", as(png) replace ;
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
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_222222_io222222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 6 ;
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
					Table 2b Replication: Model Selection for Logit Misconduct 
-----------------------------------------------------------------------------------------			
The following code will run a series of logits in order to replicate the model selection 
	statistics across total numbers of groups. 
	
Steps:
	(1) Two Group 
	(2) Three Group
	(3) Four Group 
	(4) Five Group
	(5) Six Group 
=========================================================================================*/	
	
/*=======================================================================================
					(1)	2G [Band:24, Bin:1] Logit (33) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc' z24m* "3 3" misc_band24_bin1_33 "P(Misconduct)" 2
	
/*=======================================================================================
					(2)	3G [Band:24, Bin:1] Logit (333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc' z24m* "3 3 3" misc_band24_bin1_333 "P(Misconduct)" 3
	
/*=======================================================================================
					(2)	4G [Band:24, Bin:1] Logit (3333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc' z24m* "3 3 3 3" misc_band24_bin1_3333 "P(Misconduct)" 4
	
/*=======================================================================================
					(2)	5G [Band:24, Bin:1] Logit (33333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc' z24m* "3 3 3 3 3" misc_band24_bin1_3333 "P(Misconduct)" 5

/*=======================================================================================
					(2)	6G [Band:24, Bin:1] Logit (333333) Subsample(24m)
=========================================================================================*/				
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear
		local misc = "misc_monthspre1-misc_monthspre24" 
		trajstats `misc' z24m* "3 3 3 3 3 3" misc_band24_bin1_3333 "P(Misconduct)" 6

		
/*=======================================================================================
								Table XX Dual Models 
-----------------------------------------------------------------------------------------			
The following code will run a series of dual trajectory models in order to see the transition
	probabilites. 
	
Steps:
	(1) 6G Logit Visit: 6G Zip Misconduct  
	(2) 3G Logit Visit: 3G Logit Misconduct 
	(3) 3G Logit Visit: 3G ZIP Misconduct w/ iorder  
=========================================================================================*/	

/*=======================================================================================
					(1)	Dual: 6G Logit Visit: 6G Zip Misconduct 
=========================================================================================*/			
matrix dual=(-1.71518, -0.43479, 1.71338, 1.84124, -43.84431, 76.89131, 71.76577, -130.40234, -1.90609, 2.37260, -0.22123, -0.92249, -0.53796, -0.13640, -0.19532, 1.00637, 35.89854, 9.74464, 36.47239, 17.88443, -2.17114, -2.48908, -1.73046, 0.59602, -0.84301, 0.09609, -0.16831, -3.92858, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33, 33.33) 
traj, start(dual) model(logit) var(sixmospre2-sixmospre21) indep(t*) order(3 3 3 3) model2(logit) var2(sixmospost1-sixmospost12) indep2(z*) order2(1 2 2)		





/*NEXT STEPS: 
	- 

/*================ Update Log ================
03/18/20 - MP 	- Began the .do file  
 
*/ */ 
log close 




/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================