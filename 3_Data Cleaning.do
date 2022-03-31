cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant & Sydney Jaw
Start Date: 	December 18, 2019
Last Updated: 	February 6, 2020 (MP)

Program Description: 	PA Visits 
						Merging Move Records and Inmate Information Files Together 

Objective: 	Rename and convert the data for the PA Visit paper. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all

*describe
/*=======================================================================================
							View and Reshape 1-moverec for Merging 
-----------------------------------------------------------------------------------------			
The following code will start to clean and reshape the 1_moverec file so that it may
	be merged with all the other information. Our goal is a long file with the UOA being 
	the individual. 
	
Need to check: Outcome and characteristics needed from each visit. 
=========================================================================================*/
use "Raw Data\1-movrec.dta", clear 

*** Sort Data for Visual Confirmation 
sort mov_cnt_num mov_seq_num
	order mov_seq_num mov_sig_date, after(mov_cnt_num)
	codebook mov_cnt_num //9,962 unique 
		duplicates report 
	*count if mov_cnt_num!=. & mov_seq_num==1 //9,979 values

*** Double Check the Unique Identification 
*Created a unique identifier for cases by charge date:
sort mov_cnt_num mov_seq_num
	capture: drop seq_check seq_flag 
bysort mov_cnt_num: gen seq_check=_n
	order seq_check, after(mov_seq_num)
gen seq_flag=1 if (mov_seq_num!=seq_check)
	tab seq_flag, m //1,443 differences
	/* The previous code creates a flag if the recorded mov_seq_num does not match
		the number of moves per cnt_num. This flag does not distinguish which move 
		to keep. */
	
* Take care of duplicates 
egen dup_flag=tag(mov_cnt_num mov_seq_num) // Creates indicator of duplicates  
	/* This command creates a tag on the fist instance of a unique combination 
		of mov_cnt_num and mov_seq_num such that every first instance will be 1
		and all repeated instances will be coded as 0. */
	tab dup_flag, m //731 flagged 
	drop if dup_flag==0 & seq_flag==1 //Only drops the unnecessary copies 
		/* This indicates that only obs in which the number of sequences do 
			not match AND is a superflous duplicate should be dropped. */
	capture: drop seq_check seq_flag dup_flag 	
		sort mov_cnt_num mov_seq_num
			bysort mov_cnt_num: gen seq_check=_n
				order seq_check, after(mov_seq_num)
			gen seq_flag=1 if (mov_seq_num!=seq_check)
				tab seq_flag, m //Check to ensure that duplicate check worked. 
	capture: drop seq_check seq_flag 
		/* When the recreated seq_flag==., it indicates that the duplication check
			was successful and there are only unique combinations. */

***Keeping the first move
codebook mov_cnt_num //9,961 unique 
keep if mov_seq_num==1 //Only keeping first move
	*codebook mov_cnt_num

*** Save Data 
save "Cleaned Data\1_Move Records.dta", replace  
	
/*=======================================================================================
							View and Reshape 2-tblsearchInmateInfo for Merging 
-----------------------------------------------------------------------------------------		
The following code will start to clean and reshape the 2-tblsearch file so that it may
be merged with all the other information. Our goal is a long file with the UOA being 
the individual. The unit for this data is the charge. Since this data provides the 
demographic information, we will check whether the key demographic information that we 
need stays the same between charges in the same individual. If so, then merging it to the
moves should not be much problem. 
	
=========================================================================================*/
use "Raw Data\2-tblsearchInmateInfo.dta", clear
	describe 

sort mov_cnt_num
	codebook mov_cnt_num //9,962 unique values
	duplicates report

*** Double Check the Unique Identification 	
* Take care of duplicates 
duplicates tag, gen(dup_flag) //Creates indicator for duplicates of obs on all vars. 
	tab dup_flag, m
	bysort _all: gen dup=cond(_N==1,0,_n)
		/* This code manually creates a sequential duplicate flag such that it is 
			numerically counting all the duplications. _N refers to the total observations
			in the by-group (all variables) and the _n is the within group observation. 
			*/
	drop if dup==2
	codebook mov_cnt_num //9,962 unique values

*** Create Indicatior for Number of Occurances in Data 
bysort mov_cnt_num: gen count=_n
	order count, after(mov_cnt_num)
	tab count, m 
		/* In these data the majority only have one observation/row. Only 15% of 
			the data have >2 charges, and the maximum number of charges is 10. */

*** Local: Key Demographic Variables
local demo frst_nm lst_nm mid_nm date_of_birth original_sex race_code marital_status_code
	/*NOTE: race_code and race & marital_status_code and marital_status matches*/

*** Check whether all demographic variables are consistent across charges
	/*Keeping only the key vars, I will reshape it to check whether demo info are consistent for each individual.*/
keep mov_cnt_num count `demo'
*save ".\2-InmateInfo_demographics.dta", replace
reshape wide `demo', i(mov_cnt_num) j(count)
 
	/* FIND A WAY TO SHOW VAR TYPE AND USE IF/ELSE*/
ds, has(type string) //to show the string variables 
ds, has(type numeric)
 ***String variables 
local string "frst_nm lst_nm mid_nm original_sex race_code marital_status_code"
foreach var in `string' {
	gen diff_`var'=0
	gen first_`var'=""
	}	
foreach var in `string' {
	foreach n of numlist 1/10 {
		replace first_`var'= `var'`n' if `var'`n'!="" & first_`var'==""
		replace diff_`var'= 1 if `var'`n'!="" & `var'`n'!= first_`var'
		} 
	tab diff_`var', m
	}

***Numeric variable
local numeric "date_of_birth"
foreach var in `numeric' {
	gen diff_`var'=0
	gen long first_`var'=.
	}
foreach var in `numeric' {
	foreach n of numlist 1/10 {
		replace first_`var'= `var'`n' if `var'`n'!=. & first_`var'==.
		replace diff_`var'=1 if `var'`n'!=. & `var'`n'!= first_`var'
		} 
	tab diff_`var', m
	}

*** Save data 
codebook first_* //first non-missing value for each individual
keep mov_cnt_num first_* 
save "Cleaned Data\2_Inmate Info.dta", replace
	

/*=======================================================================================
							Merging 2_Inmate Info to 1_Move Records
=========================================================================================*/
/*  */
use "Cleaned Data\1_Move Records.dta", clear
merge 1:1 mov_cnt_num using "Cleaned Data\2_Inmate Info.dta"
/*  Result                           # of obs.
    -----------------------------------------
    not matched                             8
        from master                         7  (_merge==1)
        from using                          1  (_merge==2)

    matched                             9,954  (_merge==3)
    -----------------------------------------
		*/


/*=======================================================================================
							Create Variable Lists and Locals
=========================================================================================*/
/* This section will create the locals and variables needed in order to update the data. It 
	will follow the format in the previous section where there will be the following locals: 
		(1) Variables that are not needed (and the inverse for brevity)
		(2) Used/Necessary static and dyanmic variables for data reshape. */
		
*** Short Keep Local 
local keeplist "mov_cnt_num count mov_move_date original_sex state_id_num location_permanent delete_date reception_date date_of_birth race_code commit_cnty marital_status_code offense sentence_status parole_status move_add"

*** Static 
local static "mov_cnt_num count mov_move_date original_sex state_id_num date_of_birth race_code marital_status_code   "

*** Dynamic  
local dynamic "location_permanent reception_date delete_date commit_cnty offense sentence_status parole_status move_add"

*** Identifers 
local id "mov_cnt_num count"
 
*** Keep Necessary Variables 
keep `keeplist' 

 
/*=======================================================================================
							SCRATCH PAD
=========================================================================================

NOTE: We should ask Brett whether there is an indicator for the type of move.
	For the purpose of time and convenience, I will assume for now that all moves are external.
*/

	
/*================ Update Log ================
02/06/20 - SJ		- Clean file 1 and file 2, tried merging. 
						NOTE: Need to double check "keep" step to ensure we kept all the uniques.
02/05/20 - SJ 		- Clean file 2, and check whether demographics are consistent within
						the same individual across charges (i).
02/04/20 - SJ 		- Did not need date variables (since we only want their demographic info). 
						NOTE: Need to check for missings in 1, and inconsistent numbers of 
						uniques after keeping mov_seq_num==1.
01/30/20 - SJ		- Figuring out date variables in 2.
01/07/20 - SJ 		- Tried to clean 2 to merge with 1. Need to figure out how the date 
						variables work, since we only want info within the dates of the 
						first move.
01/06/20 - MP 		- Started .do 
 
*/


