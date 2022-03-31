cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date: 	July 27, 2020
Last Updated: 	July 27, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Cleaning the work assignment data  

Objective: Clean and create work assignment variable to later merge with analytic sample.

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all
	
/*=======================================================================================
					Clean Work Assignment
=========================================================================================*/
	import excel "/Users/sydneyjaw/Dropbox/PA Visits/Data/Raw Data/Work Assignment.xlsx", sheet("Work assignment") firstrow case(lower) clear	
	/* Use stateid, inmatenum, and lastname to merge, because there's no mov_cnt_num */
	
*** Change date format  
	codebook wrkasgnmtstrt_dt wrkasgnmtend_dt // start of work and end of work
		format wrkasgnmtstrt_dt %td
		format wrkasgnmtend_dt %td		
	codebook lastname stateid inmatenum

	save "Raw Data/Work Assignment.dta", replace 
		
*** Merge with full sample data 
	use "Analytic Data/Subsamples/analytic(full_mixed).dta", clear 
		keep mov_cnt_num stateid inmatenum lastname date_releasedate date_admitdate
			codebook stateid inmatenum // use inmate number to merge
			/* NOTE: tried to merge using stateid, inmatenum, lastname, and combinations
				of the three. Inmate number provides the most matched (unmatched are
				the same individuals). Will double check in future. */
	merge 1:m inmatenum using "Raw Data/Work Assignment.dta"

	/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             5
        from master                         5  (_merge==1)
        from using                          0  (_merge==2)

    matched                           177,741  (_merge==3)
    -----------------------------------------
	*/
	
	codebook mov_cnt_num if _merge==1
	
	list lastname if _merge==1
	*list mov_cnt_num if _merge==2
	codebook mov_cnt_num
		sort mov_cnt_num

*** Create tag for within inc period: 
	gen tag_inc=0
		replace tag_inc=1 if wrkasgnmtstrt_dt>=date_admitdate & wrkasgnmtend_dt<=date_releasedate
		replace tag_inc=. if wrkasgnmtstrt_dt==. | wrkasgnmtend_dt==.
			tab tag_inc, m 

*** Create Work Counts 
	bysort mov_cnt_num: egen work_count=total(tag_inc)
		tab work_count, m

*** Create Work Assignment Types
/* Maintenance, janitorial, construction */
	gen maint=0
		replace maint=1 if job_nm=="LAUNDRY"
		replace maint=1 if job_nm=="MAINTENANCE  -  CONSTRUCTION"
		replace maint=1 if job_nm=="MAINTENANCE AND CONSTRUCTION"
		replace maint=1 if job_nm=="UTILITIES"
		replace maint=1 if job_nm=="CI - LAUNDRY OPERATIONS"
		
	gen inc_maint=0
		replace inc_maint=1 if maint==1 & tag_inc==1
		
	bysort mov_cnt_num: egen work_maint=total(inc_maint) // maintenance job count
		tab work_maint, m
		
	bysort mov_cnt_num: egen workprop_maint=max(inc_maint) // job proportion
		tab workprop_maint, m

/* Food service */
	gen food=0
		replace food=1 if job_nm=="FOOD SERVICES"
		
	gen inc_food=0
		replace inc_food=1 if food==1 & tag_inc==1
		
	bysort mov_cnt_num: egen work_food=total(inc_food)
		tab work_food, m

	bysort mov_cnt_num: egen workprop_food=max(inc_food) // job proportion 
		tab workprop_food, m

/* Prison industry */
	gen prison=0
		replace prison=1 if job_nm=="CI - CANNERY"
		replace prison=1 if job_nm=="CI - CHAIRS"
		replace prison=1 if job_nm=="CI - COMMISSARY BAGGING OPERATIONS"
		replace prison=1 if job_nm=="CI - Commissary for Inmate Employment"
		replace prison=1 if job_nm=="CI - GARMENT"
		replace prison=1 if job_nm=="CI - GARMENTS"
		replace prison=1 if job_nm=="CI - MAHANOY - PRECISION METAL SHOP"
		replace prison=1 if job_nm=="CI - MAHANOY COMMISSARY"
		replace prison=1 if job_nm=="CI - MATTRESS"
		replace prison=1 if job_nm=="CI - MEAT PROCESSING"
		replace prison=1 if job_nm=="CI - METAL PRODUCTION"
		replace prison=1 if job_nm=="CI - MODULAR SYSTEMS"
		replace prison=1 if job_nm=="CI - PLASTIC BAGS"
		replace prison=1 if job_nm=="CI - PRINTING"
		replace prison=1 if job_nm=="CI - ROCKVIEW - WOOD PRODUCTS"
		replace prison=1 if job_nm=="CI - SHOES"
		replace prison=1 if job_nm=="CI - TAGS AND SIGNS"
		replace prison=1 if job_nm=="CI - TEXTILES"
		replace prison=1 if job_nm=="CI - TRANSPORTATION - FREIGHT DIVISION"
		replace prison=1 if job_nm=="CI - TRANSPORTATION AND FREIGHT"
		replace prison=1 if job_nm=="CI - UNDERWEAR"
		replace prison=1 if job_nm=="CI - VEHICLE RESTORATION"
		replace prison=1 if job_nm=="CI - WOOD FURNITURE"
		replace prison=1 if job_nm=="CI - WOOD FURNITURE/ENGRAVING"
		replace prison=1 if job_nm=="CI COAL TOWNSHIP - WOOD PRODUCTS"
		replace prison=1 if job_nm=="CI GREENE - GARMENT"
		replace prison=1 if job_nm=="CI HUNTINGDON - SOAP  -  DETERGENT"
		replace prison=1 if job_nm=="CI PHOENIX HOSIERY"
		replace prison=1 if job_nm=="CI PHOENIX SHOES"
		replace prison=1 if job_nm=="CI PHOENIX UNDERWEAR"
		
	gen inc_prison=0
		replace inc_prison=1 if prison==1 & tag_inc==1
		
	bysort mov_cnt_num: egen work_prison=total(inc_prison)
		tab work_prison, m 
		
	bysort mov_cnt_num: egen workprop_prison=max(inc_prison) // job proportion 
		tab workprop_prison, m

		
/* Clerical, administrative */
	gen admin=0
		replace admin=1 if job_nm=="BUSINESS OFFICE"
		replace admin=1 if job_nm=="CI - ADMINISTRATION"
		replace admin=1 if job_nm=="CI - FAYETTE CI-ADMINISTRATION"

	gen inc_admin=0 
		replace inc_admin=1 if admin==1 & tag_inc==1
		
	bysort mov_cnt_num: egen work_admin=total(inc_admin)
		tab work_admin, m
		
	bysort mov_cnt_num: egen workprop_admin=max(inc_admin) // job proportion 
		tab workprop_admin, m

		
/* Security */
	gen secure=0
		replace secure=1 if job_nm=="SECURITY"

	gen inc_secure=0
		replace inc_secure=1 if secure==1 & tag_inc==1
		
	bysort mov_cnt_num: egen work_secure=total(inc_secure)
		tab work_secure, m
		
	bysort mov_cnt_num: egen workprop_secure=max(inc_secure) // job proportion 
		tab workprop_secure, m

/* Education service */
	gen educ=0
		replace educ=1 if job_nm=="EDUCATION SERVICES"
		
	gen inc_educ=0
		replace inc_educ=1 if educ==1 & tag_inc==1
		
	bysort mov_cnt_num: egen work_educ=total(inc_educ)
		tab work_educ, m 
		
	bysort mov_cnt_num: egen workprop_educ=max(inc_educ) // job proportion 
		tab workprop_educ, m

		
/* Other Types */
	gen other=0
		replace other=1 if maint==0 & food==0 & prison==0 & admin==0 & secure==0 & educ==0
		foreach i of varlist maint food prison admin secure educ {
			tab other `i', m	
			}
	
	gen inc_other=0
		replace inc_other=1 if other==1 & tag_inc==1
		
	bysort mov_cnt_num: egen work_other=total(inc_other)
		tab work_other, m 
		
	bysort mov_cnt_num: egen workprop_other=max(inc_other) // job proportion 
		tab workprop_other, m

		
	
/*=======================================================================================
						Keep Release Type Vairables 
=========================================================================================*/
/* NOTE: collapse the release type variable by individuals. */
*** Keep Necessary Variables
	local workvars "work_count workprop_maint workprop_food workprop_prison workprop_admin  workprop_secure workprop_educ workprop_other work_maint work_food work_prison work_admin work_secure work_educ work_other"
	keep mov_cnt_num lastname `workvars'
		summ `workvars'
		collapse `workvars', by(mov_cnt_num)
	save "Cleaned Data/cleaned(work assignment).dta", replace
	
	
/*=======================================================================================
							SCRATCH PAD
=========================================================================================
	*/
	
	
/*================ Update Log ================
08/21/20 - SJ 		- Finished work count and type variables
07/27/20 - SJ 		- Started do   

*/
log close 
	
