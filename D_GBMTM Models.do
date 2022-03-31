cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date: 	March 3, 2020
Last Updated: 	March 3, 2020 (BP)

Program Description: 	PA Visits 
						Run GBMTM Models 

Objective: 	The objective is to use the dataset that we created in the in order
				to run GBMTM models along with other trajectory models. 

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
								Single Trajectory Models 
-----------------------------------------------------------------------------------------			
The following code will run a series of single trajectories in an attempt to best specify 
	the models. Later .do files will do the necessary tests in order to specify both 
	the models and the start matrices that will be used. 
	
Steps: 
=========================================================================================*/	
	
/*=======================================================================================
						3G [Band:24, Bin:1] Zip (333) Subsample(24m)
=========================================================================================*/	
*** Misconduct [Band:24, Bin:1] (3 3 3)
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc24 = "c_misc_monthspre1-c_misc_monthspre24" 
		local 333 = "3 3 3"
		ziptraj `misc24' z24m* "`333'" zip_misc_band24_bin1_333 "Misconduct" 3
			/* Differs based on the sample. Also now terrible fit.  */

	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc24 = "c_misc_monthspre1-c_misc_monthspre24" 
		local 333 = "3 3 3"
		ziptraj `misc24' x24m* "`333'" zip_misc_band24_bin1_333_x "Misconduct" 3
			/* Differs based on the sample. Also now terrible fit.  */
			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc24 = "c_misc_monthspre1-c_misc_monthspre24" 
		local 333 = "3 3 3"
		#d
		traj, model(zip) var(`misc24') indep(z24m*) order(`333') detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_333_z.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 3 ;
		#d cr 
			/* Differs based on the sample. Also now terrible fit.  */		
	
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc24 = "c_misc_monthspre1-c_misc_monthspre24" 
		#d
		traj, model(zip) var(`misc24') indep(z24m*) order(2 2 2) iorder(2 2 2) detail ;
			trajplot, xtitle("Time Periods (t)") ytitle("Misconducts") ci ;
			graph export "Tables and Figures/Single Traj Models/zip_misc_band24_bin1_222_io222.png", as(png) replace ;
			tab _traj_Group, m ; //Looks at Assigned Probabilities 
			trajfit 3 ;
		#d cr 
	
/*=======================================================================================
								GBMTM Models
-----------------------------------------------------------------------------------------			
The following code will run a series of GBMTM models. We will try to get the best fit on 
	multiple models. 
	
Steps: 
=========================================================================================*/	

*** Two Group 	
	
/*=======================================================================================
				2G [Band:24, Bin:1] Mixed L(3 3) Z(3 3) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 2 `visits' z24m* "3 3" "logit" `misc' z24m* "3 3" "zip" "Visits" "Misconducts" "b24b1_2G_l33_z33" "." 
			trajfit 2


/*=======================================================================================
				2G [Band:24, Bin:1] Mixed L(3 3) Z(3 3) io(3 3) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 2 `visits' z24m* "3 3" "logit" `misc' z24m* "3 3" "zip" "Visits" "Misconducts" "b24b1_2G_l33_z33_io33" "3 3" 
			trajfit 2
			
	
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(333) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "2 2 2" "logit" `misc' z24m* "2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l222_z222" "." 
			trajfit 3 
			
			
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(333) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z333" "." 
			trajfit 3 

	
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(333) io(222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z333_io222" "2 2 2" 
			trajfit 3 

	*** Export Estimates Into an Excel File 
	matrix list e(b)
		matrix fill=e(b)
		matrix parameters=e(b)'
		matrix para=fill[1,1..4] \ fill[1,5..8] \ fill[1,9..12] \ fill[1,13..16]  \ fill[1,17..20] \ fill[1,21..24]
		matrix alphapara=fill[1,25..27] \ fill[1,28..30] \ fill[1,31..33]
		matrix list para
			matrix ests=para'
				matrix list ests
			matrix ests2=alphapara'
				matrix list ests2
		
	#d 
	putexcel set "Tables and Figures\Excel Files\GBMTM_b24b1_mix_333_333_io222.xlsx", sheet("GBMTM") replace ;
		putexcel A1=("GBMTM 3G [Band:24, Bin:1] Mixed L(333) Z(333) Subsample(24m)") ;
		putexcel B2=("V Group 1") ; putexcel C2=("V Group 2") ; putexcel D2=("V Group 3") ;
		putexcel E2=("M Group 1") ; putexcel F2=("M Group 2") ; putexcel G2=("M Group 3") ;
		putexcel H2=("M Alpha 1") ; putexcel I2=("M Alpha 2") ; putexcel J2=("M Alpha 3") ;
		putexcel A3=("Intercept") ; putexcel A4=("Linear") ; putexcel A5=("Quadratic") ; putexcel A6=("Cubic") ;
		putexcel B3=matrix(ests) ; putexcel H3=matrix(ests2) ;
	#d cr
	
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(222) io(222) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z222_io222" "2 2 2" 
			trajfit 3 
			
			
	*** Export Estimates Into an Excel File 
	matrix list e(b)
		matrix fill=e(b)
		matrix parameters=e(b)'
		matrix para=fill[1,1..4] \ fill[1,5..8] \ fill[1,9..12] 
		matrix zippara=fill[1,13..15]  \ fill[1,16..18] \ fill[1,19..21]
		matrix alphapara=fill[1,22..24] \ fill[1,25..27] \ fill[1,28..30]
		matrix list para
			matrix ests=para'
				matrix list ests
			matrix ests2=zippara'
				matrix list ests2
			matrix ests3=alphapara'
				matrix list ests3
		
	#d 
	putexcel set "Tables and Figures\Excel Files\GBMTM_b24b1_mix_333_222_io222.xlsx", sheet("GBMTM") replace ;
		putexcel A1=("GBMTM 3G [Band:24, Bin:1] Mixed L(333) Z(333) Subsample(24m)") ;
		putexcel B2=("V Group 1") ; putexcel C2=("V Group 2") ; putexcel D2=("V Group 3") ;
		putexcel E2=("M Group 1") ; putexcel F2=("M Group 2") ; putexcel G2=("M Group 3") ;
		putexcel H2=("M Alpha 1") ; putexcel I2=("M Alpha 2") ; putexcel J2=("M Alpha 3") ;
		putexcel A3=("Intercept") ; putexcel A4=("Linear") ; putexcel A5=("Quadratic") ; putexcel A6=("Cubic") ;
		putexcel B3=matrix(ests) ; putexcel E3=matrix(ests2) ; putexcel H3=matrix(ests3) ;
	#d cr
	
*** Re-estimate with altered points of support 
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
			local max=(12*.08)-.04
			makepos2 w24vals `max' 24 w24m 	
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
	gbmtm 3 `visits' w24m* "3 3 3" "logit" `misc' w24m* "2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z222_io222_w24" "2 2 2" 
		trajfit 3 
	
		*** Export Estimates Into an Excel File 
	matrix list e(b)
		matrix fill=e(b)
		matrix parameters=e(b)'
		matrix para=fill[1,1..4] \ fill[1,5..8] \ fill[1,9..12] 
		matrix zippara=fill[1,13..15]  \ fill[1,16..18] \ fill[1,19..21]
		matrix alphapara=fill[1,22..24] \ fill[1,25..27] \ fill[1,28..30]
		matrix list para
			matrix ests=para'
				matrix list ests
			matrix ests2=zippara'
				matrix list ests2
			matrix ests3=alphapara'
				matrix list ests3
				
	#d 
	putexcel set "Tables and Figures\Excel Files\GBMTM_b24b1_mix_333_222_io222_w24.xlsx", sheet("GBMTM") replace ;
		putexcel A1=("GBMTM 3G [Band:24, Bin:1] Mixed L(333) Z(333) io(222) Subsample(24m)") ;
		putexcel B2=("V Group 1") ; putexcel C2=("V Group 2") ; putexcel D2=("V Group 3") ;
		putexcel E2=("M Group 1") ; putexcel F2=("M Group 2") ; putexcel G2=("M Group 3") ;
		putexcel H2=("M Alpha 1") ; putexcel I2=("M Alpha 2") ; putexcel J2=("M Alpha 3") ;
		putexcel A3=("Intercept") ; putexcel A4=("Linear") ; putexcel A5=("Quadratic") ; putexcel A6=("Cubic") ;
		putexcel B3=matrix(ests) ; putexcel E3=matrix(ests2) ; putexcel H3=matrix(ests3) ;
	#d cr
			
/*=======================================================================================
				3G [Band:24, Bin:1] Mixed L(333) Z(333) io(333) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 3 `visits' z24m* "3 3 3" "logit" `misc' z24m* "3 3 3" "zip" "Visits" "Misconducts" "b24b1_3G_l333_z333_io333" "3 3 3" 
			trajfit 3 	
			
/*=======================================================================================
				6G [Band:24, Bin:1] Mixed L(333333) Z(222222) io(-) Subsample(24m)
=========================================================================================*/			
	use "Analytic Data\Subsamples\analytic(24 month mixed).dta", clear 
		local misc = "c_misc_monthspre1-c_misc_monthspre24" 
		local visits = "visits_monthspre1-visits_monthspre24"
		gbmtm 6 `visits' z24m* "3 3 3 3 3 3" "logit" `misc' z24m* "2 2 2 2 2 2" "zip" "Visits" "Misconducts" "b24b1_3G_l333333_z222222" "." 
			trajfit 6
		
/*NEXT STEPS: 
	- Figure out fit statistics for the gbmtm 
	- We need to estimate the indivdual specifications of the single trajecoty models and then estimate them 
		within the GBMTM approach. 

/*================ Update Log ================
02/27/20 - MP 	- Began the .do file  
 
*/ */ 
log close 




/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================		


*/