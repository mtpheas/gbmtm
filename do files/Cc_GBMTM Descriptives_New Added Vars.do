cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant and Sydney Jaw
Start Date: 	July 27, 2020
Last Updated: 	July 27, 2020 (SJ)

Program Description: 	PA Visits / Group Based Multi Trajectory Models
						Descriptive Statistics for all samples. 

Objective: Create summary statistics table (new variables) for the full sample, 12 month subsample,
		 subsample by the assigned group. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all


/*=======================================================================================
					Run Descriptives Full Sample
=========================================================================================*/
	use  "Analytic Data/Subsamples/analytic(full_new vars).dta", clear
	
	local dems "priorarrcount arrestprop_violent arrestprop_property arrestprop_drug arrestprop_other release_max release_parole release_other test_count lsir_score rst_score prog_count progcat_aod progcat_crt progcat_violence progcat_voceduc progcat_other work_count workprop_maint workprop_food workprop_prison workprop_admin  workprop_secure workprop_educ workprop_other"
***Demographics Table 
	summ `dems', sep(0)
	outreg2 `dems' using "../Tables and Figures/outreg2/GBMTM Other Vars_Full.xls", replace sum(log) keep(`dems')	
	
/*=======================================================================================
					Run Descriptives 24 Month Sample
=========================================================================================*/
	use  "Analytic Data/Subsamples/analytic(24m_new vars).dta", clear
	
	local dems "priorarrcount arrestprop_violent arrestprop_property arrestprop_drug arrestprop_other release_max release_parole release_other test_count lsir_score rst_score prog_count progcat_aod progcat_crt progcat_violence progcat_voceduc progcat_other work_count workprop_maint workprop_food workprop_prison workprop_admin  workprop_secure workprop_educ workprop_other"
***Demographics Table 
	summ `dems', sep(0)
	outreg2 `dems' using "../Tables and Figures/outreg2/GBMTM Other Vars_24M.xls", replace sum(log) keep(`dems')	


/*=======================================================================================
					Run Descriptives by Loop 24 Month Sample - Six Group 
=========================================================================================*/
	use  "Analytic Data/Subsamples/analytic(24m_new vars).dta", clear
	
	local dems "priorarrcount arrestprop_violent arrestprop_property arrestprop_drug arrestprop_other release_max release_parole release_other test_count lsir_score rst_score prog_count progcat_aod progcat_crt progcat_violence progcat_voceduc progcat_other work_count workprop_maint workprop_food workprop_prison workprop_admin  workprop_secure workprop_educ workprop_other"
	foreach g of numlist 6 {
		forval i=1/`g' {
			preserve 
				keep if groupind_24m6g==`i' 
				di "groupind_24m6g==`i'"
				***Demographics Table 
					summ `dems', sep(0)
					order `dems', after(mov_cnt_num) 
					outreg2 `dems' using "../Tables and Figures/outreg2/GBMTM Other Vars_24 Months `g'G_Group `i'.xls", replace sum(log) keep(`dems')	
			restore 
			}
		}


	
	
/*=======================================================================================
							SCRATCH PAD
=========================================================================================

	*/
	
	
	
/*================ Update Log ================
08/21/20 - SJ 		- Finished all vars for full and 24m
07/27/20 - SJ 		- Finished running tables for arrest count and release type for full and 12m

*/
log close 




