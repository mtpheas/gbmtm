cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date: 	July 26, 2020
Last Updated: 	July 27, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Cleaning the program participation data  

Objective: Clean and create program variable to later merge with analytic sample.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all

*** Convert program code excel into dta 
	import excel "Data/PA Files_11182019/Program Codebook.xlsx", sheet("dbo_tblPrgm") firstrow case(lower)
	save "PA Files_11182019/Program Codebook.dta", replace
	
/*=======================================================================================
					Clean Program Participation
=========================================================================================*/
	import excel "Data/Raw Data/Program Participation.xlsx", sheet("Program participation") firstrow case(lower) clear	
	destring control_number, gen(mov_cnt_num)
	codebook mov_cnt_num
	
*** Change date format  
	codebook inm_strdt inm_enddt // start of program and end of program
		format inm_strdt %td
		format inm_enddt %td

*** Merge with program code file (for categories)
	merge m:1 prgm_cd using "PA Files_11182019/Program Codebook.dta"
	/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           882
        from master                       832  (_merge==1) // missings
        from using                         50  (_merge==2) 

    matched                            33,755  (_merge==3)
    -----------------------------------------
		*/
		tab prgm_cd if _merge==1, m
		tab prgm_cd if _merge==2, m // drop these unmatched
			drop if _merge==2
			drop _merge

	save "Raw Data/Program Participation.dta", replace 
	
	
*** Merge with full sample data 
	use "Analytic Data/Subsamples/analytic(full_mixed).dta", clear 
		keep mov_cnt_num lastname date_releasedate date_admitdate
	merge 1:m mov_cnt_num using "Raw Data/Program Participation.dta"

	/*
	Result                           # of obs.
    -----------------------------------------
    not matched                           317
        from master                        90  (_merge==1) // 90 inds
        from using                        227  (_merge==2) // 90 inds

    matched                            34,360  (_merge==3)
    -----------------------------------------
	*/
	
	codebook mov_cnt_num if _merge==2
	codebook mov_cnt_num if _merge==1
	
	*list mov_cnt_num if _merge==2
	/* checked the unmatched (_merge==2) is not in the initial move records either, 
		will drop those unmatched obs in the final sample
		to preserve the same sample across all summary (7/26) */
	drop if _merge==2
	codebook mov_cnt_num
		sort mov_cnt_num

*** Create tag for within inc period
	gen tag_inc=0
		replace tag_inc=1 if inm_strdt>=date_admitdate // did not include "& inm_enddt<=date_releasedate" since some end date are after one had already been released
		replace tag_inc=. if inm_strdt==. | inm_enddt==.
			tab tag_inc, m 
	tab prgm_cd if tag_inc==1		
	tab prgm_catgrycd if tag_inc==1 // 30 categories
	/* 30 categories is not super useful for summary purposes, will ask Sarah about making our own categories */
	
*** Create number of programs within inc period
	bysort mov_cnt_num: egen prog_count=total(tag_inc), m
		tab prog_count, m

*** Create Program Categories
	/* NOTE: from the excel program categories provided by Bob, I made broader categories (can change later):
		- Vocational/Educational: ACAED, VOCED
		- Drug and Alcohol Related: AODE, AODOUT, CRNAOD
		- Cognitive Restructuring: CRNCRT, CRNOR, CRNSO
		- Violence Prevention: CRNVA
		*/
	gen progcat="other"
		replace progcat="vocedu" if prgm_catgrycd=="ACAED" | prgm_catgrycd=="VOCED"
		replace progcat="aod" if prgm_catgrycd=="AODE" | prgm_catgrycd=="AODOUT" | prgm_catgrycd=="CRNAOD"
		replace progcat="crt" if prgm_catgrycd=="CRNCRT" | prgm_catgrycd=="CRNOR" | prgm_catgrycd=="CRNSO"
		replace progcat="violence" if prgm_catgrycd=="CRNVA"
		replace progcat="" if prgm_catgrycd=="" & prgm_cd==""
			tab progcat, m
			tab progcat if tag_inc==1, m
	
	tab progcat, gen(x)
		rename x1 aod
		rename x2 crt
		rename x3 other
		rename x4 violence
		rename x5 voceduc
			tab aod, m 
	
	foreach i in "aod" "crt" "other" "violence" "voceduc" {
		gen inc_`i'=`i'
			replace inc_`i'=. if tag_inc==0 // missing if outside of inc period
				tab inc_`i', m
		}
	
*** Create max program categories within inc period for individuals
	foreach i in "aod" "crt" "other" "violence" "voceduc" {
		bysort mov_cnt_num: egen progcat_`i'=max(inc_`i')
			tab progcat_`i', m
		}

		
/*=======================================================================================
						Keep Release Type Vairables 
=========================================================================================*/
/* NOTE: collapse the release type variable by individuals. */
*** Keep Necessary Variables
	keep mov_cnt_num lastname prog_count progcat_aod progcat_crt progcat_violence progcat_voceduc progcat_other
	collapse prog_count progcat_aod progcat_crt progcat_violence progcat_voceduc progcat_other, by(mov_cnt_num)
		summ prog_count progcat_aod progcat_crt progcat_violence progcat_voceduc progcat_other
	save "Cleaned Data/cleaned(program participation).dta", replace
	
	
/*=======================================================================================
							SCRATCH PAD
=========================================================================================

	*/
	
	
/*================ Update Log ================
07/27/20 - SJ 		- Finished the program variable   
07/26/20 - SJ 		- Started do

*/
log close 
	
