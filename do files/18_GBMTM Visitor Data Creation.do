cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw 
Start Date: 	March 1, 2021
Last Updated:	March 2, 2021 (SJ)

Program Description: 	GBMTM Visit and Misconduct 
						Create and Merge Visitor Information Data  

Objective: 	The objective of this file is to clean the visitor information data 
			and visit events data, then merge with the analytic sample to assess 
			relationship of visitor with individuals.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all
	
/*=======================================================================================
							Open and Clean Visitor Relationship Data
-----------------------------------------------------------------------------------------			
The following code will open and clean the 4-13tblVstrLst.dta.
=========================================================================================*/		
*** Open relationship data  
	use "Raw Data\4-13tblVstrLst.dta", clear 
		describe 
		
*** Keep necessary variables
	keep vstr_num rltnshp_cd lstmod_dt
		rename vstr_num visitor_id
		rename rltnshp_cd visitor_relation
			codebook visitor_id //  560,433 unique

*** Generate date variable 
	split lstmod_dt, parse(/) gen(date)
		rename date1 m
		rename date2 d 
	split date3, parse("") gen(ndate)
		rename ndate1 y
		rename ndate2 time
		drop date3
			
*** Check for duplicates: mov_cnt_num and different visitor status
	duplicates tag, gen(dupcheck)
		gsort - dupcheck visitor_id //Shows that 14,987 obs are duplicated. 
	bysort _all: gen duplicate=cond(_N==1,0,_n)
		tab duplicate, m 
			/* We want to get rid of the observations that are >= 2. 0 indicates
				that there are no duplicates and 1 indicates that it is the 
				original in a duplicated pair. */
	drop if duplicate>=2 
		codebook visitor_id
	
	sort visitor_id y
	duplicates tag visitor_id visitor_relation, gen(dup)
		gsort - dup visitor_id y //Shows that 19,434 obs are duplicated.
	bysort visitor_id visitor_relation: gen dupdate=cond(_N==1,0,_n)
		tab dupdate, m 
			/* We want to get rid of the observations that are >= 2. 0 indicates
				that there are no duplicates and 1 indicates that it is the 
				original in a duplicated pair. */
	drop if dupdate>=2 

	sort visitor_id y
	by visitor_id: gen tag=_n
		gsort - tag visitor_id y 
	drop if tag>=2

	codebook visitor_id // each i is unique visitor
	
*** Types of relationships
	tab visitor_relation, m // 2 missings 
			
*** Save dataset
	drop m d y time lstmod_dt dupcheck duplicate dup dupdate tag 
	save "Cleaned Data\cleaned(visitor relationship).dta", replace

	
/*=======================================================================================
						Open and Clean Visitor Relationship HISTORY Data
-----------------------------------------------------------------------------------------			
The following code will open and clean the 4-10tblVstr_RltnshpHist.dta.
=========================================================================================*/		
*** Open relationship data  
	use "Raw Data\4-10tblVstr_RltnshpHist.dta", clear 
		codebook mov_cnt_num
		
*** Keep necessary variables
	keep mov_cnt_num vstr_num rltnshpcd
		rename vstr_num visitor_id
		rename rltnshpcd visitor_relation
	
***** Check for duplicates: mov_cnt_num and different visitor status
	duplicates tag, gen(dupcheck)
		gsort - dupcheck mov_cnt_num //Shows that 64 obs are duplicated. 
	bysort _all: gen duplicate=cond(_N==1,0,_n)
		tab duplicate, m 
			/* We want to get rid of the observations that are 2. 0 indicates
				that there are no duplicates and 1 indicates that it is the 
				original in a duplicated pair. */
	drop if duplicate==2 
		codebook mov_cnt_num //N=9,962. Confirmed for full sample. 
		codebook visitor_id
		
*** Types of relationships
	tab visitor_relation, m // missings are those without visitors 
		*tab visitor_relation if visitor_id!=., m 
	
*** Save dataset
	drop dupcheck duplicate 
	save "Cleaned Data\cleaned(visitor relationship history).dta", replace

	
/*=======================================================================================
						Open and Clean Visitor Relationship HISTORY Data
-----------------------------------------------------------------------------------------			
The following code will open and clean the 4-15tblVstrRltnshp.
=========================================================================================*/		
*** Open relationship data  
	use "Raw Data\4-15tblVstrRltnshp", clear 
		codebook mov_cnt_num
		
*** Keep necessary variables
	keep mov_cnt_num vstr_num rltnshp_cd
		rename vstr_num visitor_id
		rename rltnshp_cd visitor_relation
		codebook visitor_id		
	
***** Check for duplicates: mov_cnt_num and different visitor status
	duplicates tag, gen(dupcheck)
		gsort - dupcheck mov_cnt_num //Shows that 40 obs are duplicated. 
	bysort _all: gen duplicate=cond(_N==1,0,_n)
		tab duplicate, m 
			/* We want to get rid of the observations that are 2. 0 indicates
				that there are no duplicates and 1 indicates that it is the 
				original in a duplicated pair. */
	drop if duplicate==2 
		codebook mov_cnt_num //N=9,962. Confirmed for full sample. 
		codebook visitor_id
		
*** Types of relationships
	tab visitor_relation, m // missings are those without visitors 
		*tab visitor_relation if visitor_id!=., m 
	
*** Save dataset
	drop dupcheck duplicate 
	save "Cleaned Data\cleaned(visitor relationship2).dta", replace
	
/*=======================================================================================
				Merge Visit Event Data and Relationship Data and Clean
-----------------------------------------------------------------------------------------			
The following code will open the visit event data made by BP Cleaned Data\cleaned(visits_long).dta.
This long data was made from Raw Data/4-3tblVst_EvntHist.dta in 4_GBMTM Data Building UPDATE.do.

This data includes 
=========================================================================================*/		
*** Open visit event data 
	use "Cleaned Data\cleaned(visits_long).dta", clear 
		rename visit_id visitor_id
		codebook visitor_id
		
*** Merge Relationship data
	merge m:1 visitor_id using "Cleaned Data\cleaned(visitor relationship).dta"
		drop if _merge==2
		rename _merge rmerge
	
	merge m:m visitor_id using "Cleaned Data\cleaned(visitor relationship history).dta"
		drop if _merge==2
		rename _merge histmerge

	merge m:m visitor_id using "Cleaned Data\cleaned(visitor relationship2).dta"	
		drop if _merge==2 
		rename _merge r2merge
		
	gen ind_match=0
		replace ind_match=1 if rmerge==3 | histmerge==3 | r2merge==3
		tab ind_match, m // 14.75% matched 
			/* some indicated matched for those already missing visitor_id in using data,
				confirmed visually (3/2 SJ)
				sort ind_match visitor_id */
		tab ind_match if visitor_id!=.	// 9.38% matched 
		
*** Visually check that actually no merge from random sample 
	preserve
		sample 20 if visitor_id!=., count
	restore

	
*** Create Monthly Binary Visit Indicators 
	tab months_before, m
		replace months_before=(months_before*(-1)) //Inverts for ease 
	drop if months_before>24
		tab ind_match if visitor_id!=. // 8.87% matched in the analytic period 
		codebook visitor_id
	/* Only looking at the visit events within observation perios (2 year) still
		reveals most visitor information as missing. Given the large amount of
		missing, it does not make sense to continue with the visitor inquiry. */
	
	
/* NEXT STEPS:

		
	*/
	
/*================ Update Log ================
03/02/21 - SJ 	- Finished .do file 
03/01/21 - SJ 	- Began the .do file  
 
*/ 
log close 
	translate "..\Log Files\18_GBMTM Visitor Data Creation.smcl" "..\Log Files\18_GBMTM Visitor Data Creation.pdf"

/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================
		
			
			
