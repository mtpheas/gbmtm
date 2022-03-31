cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date:		May 12, 2020
Last Updated: 	May 12, 2020 (BP)

Program Description: 	PA Visits 
						Create GBMTM Tables  

Objective: 	The objective of this file is to create the final GBMTM file with 
				the final model chosen. This file is needed to get the assigned 
				group variables. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all


/*=======================================================================================
						Create Local Programs used for Coding
=========================================================================================*/
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
			#d ;
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
						24 Month Sample - Six Group GBMTM Model 
-----------------------------------------------------------------------------------------			
The following code will run a multitraj in order to get the estiamted and assigned group 
	probabilities for the six group model on the 24 month sample. We will then run a dual
	trajectory in order to get the assigned visit probability, and the highest conditional
	probability in order for later comparison. We can then keep only the variables necessary
	in order to decrease the size of the file. 
	
Steps:
	(1) Run GBMTM and save Estimates
	(2) Run Dual Model and save Probabilities 
	(3) Save File 
=========================================================================================*/	

/*=======================================================================================
			Run 6G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(222222) Subsample(24m)
=========================================================================================*/	
*** Run Model		
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		matrix start=(-5.40249, -2.26915, 30.48595, -1.75262, -1.37864, 1.24586, -13.59047, 78.35357, 0.47671, -1.43649, -22.0582, 45.03312, -4.0368, -0.88007, -0.30112, 53.36866, -2.98128, -32.73003, 50.86524, 618.41382, 3.18117, 1.04181, -45.39213, -7.79266, 0.7993, 0.53792, -6.66293, 0.72475, 0.30505, 1.68758, 0.78755, 0.27263, -1.92664, 1.16169, -0.46166, -4.56024, 0.90672, 0.99032, -10.54277, 0.76499, 0.24916, 0.06458, 3.54441, -3.45215, 8.21109, 3.63844, -2.74014, 12.3467, 3.62172, -2.16346, 1.09245, 0.91059, 0.59804, -2.13315, 3.44415, -3.65475, -0.73096, 4.16897, -3.80797, -4.63231, 61.21, 15.56, 8.01, 4.69, 5.63, 4.9)
			/* Start values taken from Excel file that took parameters from the original model fit */
		#d 
			traj, multgroups(6) start(start) var1(`visits') indep1(z24m*) order1(3 3 3 3 3 3) model1(logit) 
								var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) iorder2(2 2 2 2 2 2) model2(zip) ;
				  multtrajplot, xtitle("Months Before Release") ytitle1("P(Visits)") ytitle2("Misconducts") ci	;
		#d cr
				
*** Create GBMTM Group Categories 
	tab _traj_Group, m 
		tab _traj_Group, gen(group_24m6g_)
			summ group_24m6g_*, sep(0)
		gen groupind_24m6g=_traj_Group 
		
*** Complete Trajfit and Clear Data 
	trajfit 6
		
		
*** Save File           
	save "Analytic Data\Subsamples\analytic(24 month final).dta", replace 

/*=======================================================================================
                            12 Month Sample - Five Group GBMTM Model 
-----------------------------------------------------------------------------------------                       
 The following code will run a multitraj in order to get the estiamted and assigned group 
         probabilities for the five group model on the 12 month sample. We will then run a dual
         trajectory in order to get the assigned visit probability, and the highest conditional
         probability in order for later comparison. We can then keep only the variables necessary
         in order to decrease the size of the file. 
         
 Steps:
         (1) Run GBMTM and save Estimates
         (2) Run Dual Model and save Probabilities 
         (3) Save File 
=========================================================================================*/  
		
*** Run Model 
	use "Analytic Data\Subsamples\analytic(12 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre12" 
		local visits = "visits_monthspre1-visits_monthspre12"
		matrix start=(-4.47904, 0.72963, 40.80747, 145.86126, -0.55243, 5.44255, -79.69543, 267.5794, -1.57833, -60.34982, 47.98002, 4641.8123, -3.77303, 3.24641, 19.74487, -555.67806, 2.42581, -3.64937, -198.6767, 815.35059, 0.70234, -0.24541, -18.16303, 0.74147, 2.43001, -26.8324, 0.78471, -3.14393, 2.26912, 1.17946, 0.45448, -5.40054, 0.72642, 1.14064, -23.68848, 4.14276, -4.14447, -33.51588, 4.01054, 1.75076, -18.36951, 4.28284, -4.62253, -13.19635, 0.55933, 2.10001, 32.50206, 4.33948, -2.41748, -5.66998, 67.89, 14.59, 4.55, 3.44, 9.53)
	#d 
		traj, multgroups(5) start(start) var1(`visits') indep1(z12m*) order1(3 3 3 3 3) model1(logit) 
                          var2(`misc') indep2(z12m*) order2(2 2 2 2 2) iorder2(2 2 2 2 2) model2(zip) ;
			  multtrajplot, xtitle("Months Before Release") ytitle1("P(Visits)") ytitle2("Misconducts") ci  ;
	#d cr 
	
*** Create GBMTM Group Categories 
	tab _traj_Group, m 
		tab _traj_Group, gen(group_12m5g_)
			summ group_12m5g_*, sep(0)
		gen groupind_12m5g=_traj_Group 
		
*** Complete Trajfit and Clear Data 
	trajfit 5	


*** Save File 
	save "Analytic Data\Subsamples\analytic(12 month final).dta", replace 

/*NEXT STEPS: 
	- This file will need to appended in order to include all of the GBMTM models
		and thier respective probabilites in one file. In this way we can then 
		look at group assignments across various bandwidths, and estimate the 
		conditional group probabilities. 

/*================ Update Log ================
03/18/20 - MP 	- Began the .do file  
 
*/ */ 
log close 



/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================

/*=======================================================================================
									Run Dual Model
=========================================================================================*/

