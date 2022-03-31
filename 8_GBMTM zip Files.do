cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date: 	March 3, 2020
Last Updated: 	March 3, 2020 (MP)

Program Description: 	PA Visits 
						Build Zip Dataset for Group Based Multi Trajectory Models 

Objective: 	Build the zip datset for the GBMTM paper from visits and misconducts. 
				We can use the files created from 4_* in order to collapse and 
				sum rather than max in order to get the count distribution rather 
				than a binary distribution. 
 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all

/*=======================================================================================
								Create the ZIP Files 
-----------------------------------------------------------------------------------------			
The following code will use the previously created files and collapse them in order to 
	create the count distrbutions. Then we will merge these together and create the 
	analytic zip files to run trajectories on. 
	
Steps: 
	(1) Create ZIP for visits 
	(2) Create ZIP for misconducts
	(3) Merge together zips
=========================================================================================*/

/*=======================================================================================
							(1) Create Visit Count Files 
=========================================================================================*/
*** Use Cleaned Data from 4_Data Building 
	use "Cleaned Data\cleaned(visits_long).dta", clear 
		/* These data have the temporal calculations and should be ready to collapse 
			and count rather than collapse and max. */
	
*** Create Binary Visit Indicator (Multiple per i)
	tab months_before, m
		replace months_before=(months_before*(-1)) //Inverts for ease 
		tab months_before, g(visits_monthspre) 
		
	tab weeks_before, m
		replace weeks_before=(weeks_before*(-1))
		tab weeks_before, g(visits_weekspre)

*** Collapse Data Wide - With Counts 
	collapse (sum) visits_monthspre* visits_weekspre* (max) date_releasedate visits_max visits_eventcount, by(mov_cnt_num)

*** View Count Distributions - VISITOR 
	summ visits_monthspre*, sep(0) //Should be noted that this is visitors NOT unique visits. 
	
*** Only Keep Necessary Variables 
	local dropvars "date_releasedate"
		drop `dropvars'

*** Save Data
	save "Cleaned Data\cleaned(visits_widecount).dta", replace 
	
/*=======================================================================================
						(2) Create Misconduct Count Files 
=========================================================================================*/	
*** Use Cleaned Data from 4_Data Building 
	use "Cleaned Data\cleaned(misconducts_long).dta", clear 
		/* These data have the temporal calculations and should be ready to collapse 
			and count rather than collapse and max. */
	
*** Create Binary Misconduct Indicator (Multiple per i)
	tab misc_monthsbefore, m
		replace misc_monthsbefore=(misc_monthsbefore*(-1)) //Inverts for ease 
		tab misc_monthsbefore, g(misc_monthspre) 
		
	tab misc_weeksbefore, m
		replace misc_weeksbefore=(misc_weeksbefore*(-1))
		tab misc_weeksbefore, g(misc_weekspre)

*** Collapse Data Wide - With Counts 
	collapse (sum) misc_monthspre* misc_weekspre* (max) date_deletedate misc_max misc_amax, by(mov_cnt_num)

*** View Count Distributions -  
	summ misc_monthspre*, sep(0) 
	summ misc_weekspre*, sep(0)
	
*** Only Keep Necessary Variables 
	local dropvars "date_deletedate"
		drop `dropvars'

*** Save Data
	save "Cleaned Data\cleaned(misconducts_widecount).dta", replace 
	
	
/*=======================================================================================
						(3) Create Analytic Count File 
=========================================================================================*/		
*** Open original file and bring in visits data 
	use "Cleaned Data\cleaned(inmatedata_wide).dta", clear 
		order mov_cnt_num, first 
		merge 1:1 mov_cnt_num using "Cleaned Data\cleaned(visits_widecount).dta"
	
*** Clean the Unmatched Observations to have Zeros for datapoints 
drop _merge //consider creating an indicator, however we have to consider the previous missing 
foreach i of varlist visits_monthspre* visits_weekspre* {
	replace `i'=0 if `i'==.
	}
	
*** Merge in Misconduct Data 
merge 1:1 mov_cnt_num using "Cleaned Data\cleaned(misconducts_widecount).dta"
	
*** Clean Unmatched Obs for Misconduct 
drop _merge 
foreach i of varlist misc_monthspre* misc_weekspre* {
	replace `i'=0 if `i'==.
	}
 
*** Save Data 
save "Analytic Data\analytic(gbmtm_vmcount_wide).dta", replace 

	
/*NEXT STEPS: 
	- Consider whether we want the count distribution to be based on visits or 
		visitors. Probably both for sensitivity. 


/*================ Update Log ================
10/19/20 - MP	- Updated to include weekly indicators 
03/02/20 - MP 	- Finished the visits and the misconduct portions  
 
*/ */
log close 




/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================