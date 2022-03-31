cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date:		July 25, 2020
Last Updated: 	July 25, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Cleaning the offense history data  

Objective: Clean and create arrest count and type to later merge with analytic sample.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all
	
/*=======================================================================================
					Clean Arrest Count
=========================================================================================*/
*** Clean offense code 
	use "Raw Data/8-Offense Codes Table MOST CURRENT.dta", clear
	gen arrest_code=strtrim(code)
		save "Raw Data/Offense Codes.dta", replace
	
*** Import and clean criminal history 
	import excel "Data/Raw Data/ICSA and Criminal History.xlsx", sheet("ICSA and criminal hist") firstrow case(lower) clear
	
	destring control_number, gen(mov_cnt_num)
	
	gen arrest_code=strtrim(arrestcharge_cd)
	
*** Create arrest date variable 
	egen adate=concat(arrest_mo arrest_day arrest_yr), punct(-)
	gen date_arrestdate=date(adate, "MDY")
		format date_arrestdate %td

*** Merge with offense code 
	merge m:1 arrest_code using "Raw Data/Offense Codes.dta"
	/* Result                           # of obs.
    -----------------------------------------
    not matched                        15,587
        from master                    15,417  (_merge==1)
        from using                        170  (_merge==2)

    matched                           222,576  (_merge==3)
    ----------------------------------------- 
	
	NOTE: 35% of unmatched (_merge==1) are missings. I randomly checked 10 different 
	unmatched codes (_merge==1), all were not in the offense code file (not a problem
	of spacing, or coding, etc.). The unmatched codes (_merge==2) were not in the 
	master file either. */
		drop if _merge==2
		drop _merge
		
	save "Raw Data/ICSA and Criminal History.dta", replace 
	
/*=======================================================================================
					Merge with full sample data
=========================================================================================*/
*** Merge with full sample data 
	use "Analytic Data/Subsamples/analytic(full_mixed).dta", clear 
		keep mov_cnt_num lastname date_admitdate date_deletedate 
	merge 1:m mov_cnt_num using "Raw Data/ICSA and Criminal History.dta"

	/*
	Result                           # of obs.
    -----------------------------------------
    not matched                         2,516
        from master                        90  (_merge==1) // 90 individuals 
        from using                      2,426  (_merge==2) // 90 individuals 

    matched                           235,567  (_merge==3)
    -----------------------------------------

	*/
	
	codebook mov_cnt_num if _merge==2
	codebook mov_cnt_num if _merge==1
	
	/* checked the unmatched (_merge==2) is not in the initial move records either, 
		will drop those unmatched obs in the final sample
		to preserve the same sample across all summary */
	drop if _merge==2
	codebook mov_cnt_num
		sort mov_cnt_num

*** Create Prior arrest count 
	gen tag_arrest=0
		replace tag_arrest=1 if date_arrestdate<=date_admitdate
		replace tag_arrest=. if date_arrestdate==.
		tab tag_arrest, m
		
	bysort mov_cnt_num: egen priorarrcount=total(tag_arrest), m
		tab priorarrcount, m
		tab tag_arrest if priorarrcount==0 // need to double check, there's 102 obs with 0 prior arrest 
		
*** Create Arrest type variable 
	tab category, m
/* Violent Arrest: aggrevated assault, murder, murder 1, 2, 3, rape, robbery, voluntary manslaughter*/
	gen violent=0
		replace violent=1 if category=="Aggravated Assault"
		replace violent=1 if category=="Murder (Other)"
		replace violent=1 if category=="Murder 1"
		replace violent=1 if category=="Murder 2"
		replace violent=1 if category=="Murder 3"
		replace violent=1 if category=="Rape"
		replace violent=1 if category=="Robbery"
		replace violent=1 if category=="Voluntary Manslaughter"
		replace violent=. if category==""
	
	gen prior_violent=0 
		replace prior_violent=1 if violent==1 & tag_arrest==1 
		replace prior_violent=. if violent==. & tag_arrest==1 
	
	bysort mov_cnt_num: egen arrest_violent=total(prior_violent) //total prior violent arrest 
		tab arrest_violent, m
	
	bysort mov_cnt_num: egen arrestprop_violent=max(prior_violent) // proportion of violent arrest
		tab arrestprop_violent, m
	
/* Property Arrest: Arson, burglary, theft*/
	gen property=0
		replace property=1 if category=="Arson"
		replace property=1 if category=="Burglary"
		replace property=1 if category=="Theft"
		replace property=. if category==""

	gen prior_property=0
		replace prior_property=1 if property==1 & tag_arrest==1
		replace prior_property=. if property==. & tag_arrest==1
		
	bysort mov_cnt_num: egen arrest_property=total(prior_property) //totoal prior property arrest 
		tab arrest_property, m 
	
	bysort mov_cnt_num: egen arrestprop_property=max(prior_property) // proportion of property arrest
		tab arrestprop_property, m
	
/* Drug Arrest: DUI, drugs */
	gen drug=0
		replace drug=1 if category=="DUI"
		replace drug=1 if category=="Drugs"
		replace drug=. if category==""
	
	gen prior_drug=0
		replace prior_drug=1 if drug==1 & tag_arrest==1
		replace prior_drug=. if drug==. & tag_arrest==1
		
	bysort mov_cnt_num: egen arrest_drug=total(prior_drug) //total prior drug arrest 
		tab arrest_drug, m 

	bysort mov_cnt_num: egen arrestprop_drug=max(prior_drug) // proportion of drug arrest
		tab arrestprop_drug, m


/* Other Arrests: forgery, fraud, homicide by vehicle, (by watercraft), involuntary manslaughter,
	kidnapping, other assault, other sexual crimes, prison breach, receiving stolen property,
	statutory rape, weapons. */
	gen other=0
		replace other=1 if category=="Forgery"
		replace other=1 if category=="Fraud"
		replace other=1 if category=="Homicide By Vehicle" | category=="Homicide by Vehicle"
		replace other=1 if category=="Involuntary Manslaughter"
		replace other=1 if category=="Kidnapping"
		replace other=1 if category=="Other Assault"
		replace other=1 if category=="Other Sexual Crimes"
		replace other=1 if category=="Prison Breach"
		replace other=1 if category=="Receiving Stolen Property"
		replace other=1 if category=="Statutory Rape"
		replace other=1 if category=="Weapons"
		replace other=. if category==""
	
	gen prior_other=0
		replace prior_other=1 if other==1 & tag_arrest==1
		replace prior_other=. if other==. & tag_arrest==1
	
	bysort mov_cnt_num: egen arrest_other=total(prior_other) // total prior other arrest
		tab arrest_other, m 

	bysort mov_cnt_num: egen arrestprop_other=max(prior_other) // proportion of other arrest
		tab arrestprop_other, m


/*=======================================================================================
						Keep Arrest Vairables 
=========================================================================================*/
/* NOTE: collapse the prior arrest variables by individuals. */
*** Keep Necessary Variables
	local arrestvars "priorarrcount arrestprop_violent arrestprop_property arrestprop_drug arrestprop_other arrest_violent arrest_property arrest_drug arrest_other"
	keep mov_cnt_num lastname `arrestvars'
		summ `arrestvars'
	collapse `arrestvars', by(mov_cnt_num)
	
	save "Cleaned Data/cleaned(offense history).dta", replace
	
	
/*================ Update Log ================
08/22/20 - SJ		- Finished arrest types
07/25/20 - SJ 		- Finished the arrest count   
 
*/
log close 
	
