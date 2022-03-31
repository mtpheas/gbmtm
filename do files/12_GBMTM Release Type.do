cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date: 	July 25, 2020
Last Updated: 	July 26, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Cleaning the release type data  

Objective: Clean and create release type variable to later merge with analytic sample.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all

	
/*=======================================================================================
					Clean Release Type 
=========================================================================================*/
	import excel "Data/Raw Data/Release Type.xlsx", sheet("Release type") firstrow case(lower) clear	
	destring control_number, gen(mov_cnt_num)
	codebook mov_cnt_num
	
*** Create release date variable 
	codebook releaseddate	
		format releaseddate %td

	save "Raw Data/Release Type.dta", replace 
	
	
*** Merge with full sample data 
	use "Analytic Data/Subsamples/analytic(full_mixed).dta", clear 
		keep mov_cnt_num lastname date_releasedate 
	merge 1:m mov_cnt_num using "Raw Data/Release Type.dta"

	/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           571
        from master                       388  (_merge==1) // 388 individuals
        from using                        183  (_merge==2) // 89 individuals 

    matched                            15,888  (_merge==3)
    -----------------------------------------
	*/
	
	codebook mov_cnt_num if _merge==2
	codebook mov_cnt_num if _merge==1
	
	*list mov_cnt_num if _merge==2
	/* checked the unmatched (_merge==2) is not in the initial move records either, 
		will drop those unmatched obs in the final sample
		to preserve the same sample across all summary (7/25) */
	drop if _merge==2
	codebook mov_cnt_num
		sort mov_cnt_num

*** Create release type  
	codebook date_releasedate releaseddate
	gen tag_rdate=0
		replace tag_rdate=1 if date_releasedate==releaseddate
		replace tag_rdate=. if date_releasedate==. | releaseddate==.
			tab tag_rdate, m
			
	/* will use the release information for the same release date */
	codebook typeofreleased
	gen release_type=typeofreleased if tag_rdate==1
		tab release_type, m
	tab release_type, gen(x)
		rename x1 max
		rename x2 other
		rename x3 parole
	bysort mov_cnt_num: egen release_max=max(max)
	bysort mov_cnt_num: egen release_parole=max(parole)
	bysort mov_cnt_num: egen release_other=max(other)
		
/*=======================================================================================
						Keep Release Type Vairables 
=========================================================================================*/
/* NOTE: collapse the release type variable by individuals. */
*** Keep Necessary Variables
	keep mov_cnt_num lastname date_releasedate release_max release_parole release_other
	collapse date_releasedate release_max release_parole release_other, by(mov_cnt_num)
		summ release_max release_parole release_other
	save "Cleaned Data/cleaned(release type).dta", replace
	
	
/*================ Update Log ================
07/26/20 - SJ 		- Finished the release type variable   
07/25/20 - SJ 		- Started do

*/
log close 
	
