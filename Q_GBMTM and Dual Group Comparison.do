capture log close 
cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date:	  March 1, 2021
Last Updated: March 1, 2021 (BP)

Program Description: 	GBMTM
						Dual and GBMTM Group Comparisons    

Objective: The objective of this file is to compare the group assignments from the 
	dual models to the group assignments of the multi-models. We want to do this 
	in order to be confident of the main take-aways. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all

/*=======================================================================================
							Compare the Assigned Indicators 
-----------------------------------------------------------------------------------------		This section will open the dataset that was created after runing the dual models in order
	to see how the assigned groups from the dual mix with the assigned groups from the 
	multi-model. 
	
Steps:
	(1) Use Data with Group Assingments from Both Models
	(2) Compare the Groups 
=========================================================================================*/	

/*=======================================================================================
								Compare Gropus 
=========================================================================================*/
*** Open Data with Dual/Multi Group Assignments 
	use "Analytic Data\Subsamples\analytic(dual groups).dta", clear 
		/* This file was created using the .do file O_. It takes the sample creation from 
			the multi model and estimates the dual model (with start values from solution). */

*** Multi-model Group Assignments  
	tab groupind_24m6g, m 
	
*** Dual Group Assignments 
	fsum dualgroup_*

/*=======================================================================================
						Comparison: Single Visits & Multi-Model 
=========================================================================================*/	
	tab dualgroup_visits groupind_24m6g, m 
		tab dualgroup_visits groupind_24m6g, nofreq row
		tab dualgroup_visits groupind_24m6g, nofreq col

/*=======================================================================================
						Comparison: Single Misconducts & Multi-Model 
=========================================================================================*/	
	tab dualgroup_misc groupind_24m6g, m 
		tab dualgroup_misc groupind_24m6g, nofreq row
		tab dualgroup_misc groupind_24m6g, nofreq col

/*=======================================================================================
						Comparison: Dual and Multi Model 
=========================================================================================*/	
/* In order to make it easier to see the composition of the dual and multi models, I 
	am going to create a categorical variable rather than individually look at each group 
	dummy tabulation.  */

*** Create Categorical Variable for Dual Groups
	rename dualgroup_visits dualgroupvisits // Change name for subsequent loop
	local x=1 // Set up value `seed' for categorical variable 
	gen dualgroupind=.
	foreach i of varlist dualgroup_v* {
		qui replace dualgroupind=`x' if `i'==1
		quietly {
			sum `i' if `i'==1
				local varn=r(N)
			tab dualgroupind if dualgroupind==`x'
				local newvarn=r(N)
			}
		di "dualgroupind=`x': `i' og: `varn' new: `newvarn' 
		local x=`x'+1
		}	
		
*** Compare Group Assignments 
	tab dualgroupind groupind_24m6g, m 
		tab dualgroupind groupind_24m6g, nofreq row 
		tab dualgroupind groupind_24m6g, nofreq col 
	
	
/*NEXT STEPS: 
	- 

/*================ Update Log ================
03/1/21 - MP 	- Began the .do file  
 
*/ */ 
log close 




/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================


