cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant 
Start Date: 	Februrary 7, 2020
Last Updated:	February 7, 2020 (BP)

Program Description: 	PA Visits 
						Build Dataset for Group Based Multi Trajectory Models 

Objective: 	Build the datset for the GBMTM paper from visits and misconducts. 
				The underlying logic is that we want to build a dataset in which 
				we can run trajectory models on the outcomes of visits and misconducts
				among the sample of inmates. We need to clean and collapse the visit 
				file and misconduct file seperately (using the same temporal bounds) 
				and then merge them together with a list of inmates. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all

/*=======================================================================================
						Establish Baseline Date Files 
-----------------------------------------------------------------------------------------			
The following code will use the move files in order to recode and retrieve the admit and 
	delete dates and then put them in a wide format to then be merged to the tblsearch 
	data. From here, we can use these variables to calculate dates/times/etc. 
	
Steps: 
	(1) Open and view file  
	(2) Only keep the admits (A series) and D series 
	(3) Create and keep only most recent incarceration period. 
=========================================================================================*/
use "Raw Data\1-movrec.dta", clear 
	describe 
	order dbo_movrec_mov_move_code dbo_movrec_mov_move_date, after(mov_cnt_num) //Sort to easily view history. 
	sort mov_cnt_num dbo_movrec_mov_move_date //Organize inmate history. 

***Figure Out Variables to Keep 
local keeplist "mov_cnt_num dbo_movrec_mov_move_code dbo_movrec_mov_move_date original_mov_move_code original_mov_move_date mov_seq_num mov_sig_date"
	keep `keeplist'

*** Rename Variables 
rename dbo_movrec_mov_move_code move_code
rename dbo_movrec_mov_move_date move_date
	
/*=======================================================================================
							Create and Finalize Dates
=========================================================================================*/	

*** Remove the Move Changes - to keep adds/drops (str4)
drop if move_code=="PLC " | move_code=="RTT " | move_code=="SC  " | move_code=="STT " | move_code=="TFM " | move_code=="TRN " | move_code=="TTM " | move_code=="XPT "
	tab move_code 

*** Drop additional move changes not in codebook 
	/*  These account for 0.03% of the moves. */
drop if move_code=="RTN " | move_code=="X   "
	tab move_code, m 

*** Drop Cases of Adminsitrative Admit/Delete 
	/* In these cases there was some sort of admin change in the system but the 
		individual was not released or was not admitted. We can verify this by the 
		drop and add being one the same day. The AA precedes the DA. */
drop if move_code=="AA  " | move_code=="DA  "
	tab move_code, m //Only true adds/drops are left. 

*** Only keep the most recent delete - should coincide with the og vars
replace original_mov_move_code="D   " if original_mov_move_code=="D"
	//This makes the og move code variable str4 in order to use conditions. 
drop if move_code==original_mov_move_code & move_date!=original_mov_move_date
	/* This drops those obs that are deletes, BUT are not the most release date that 
		was pulled for the release cohort. For example, this series of code will drop 
		both deletes that occured before the delete that was pulled for the release cohort
		as well as subsequent deletes that individuals had for APVs or new offenses. */
	codebook mov_cnt_num //N=9,962
	
*** Drop any move_code's that are D
	/* We can drop these D's becuase they are duplicated in the og_variable sections. */
drop if move_code=="D   "
	codebook mov_cnt_num //N=9,962
	
*** Keep only most recent admit 
***** Step 1: Only Keep Admit's with the date that is before the movedate (og_date) 
gen varcheck=(move_date<original_mov_move_date) //ind for move before delete 
	egen datecheck=max(varcheck), by(mov_cnt_num) //ind that there is a admit before delete. All obs should be 1. 
		preserve 
			collapse (max) datecheck, by(mov_cnt_num) 
			tab datecheck, m 
			list mov_cnt_num if datecheck!=1 //238061, 287602
		restore 
			/* This is to check and see who does not have moves that are before 
				the release date/delete date. 
				*/ 
keep if move_date<original_mov_move_date
	codebook mov_cnt_num //N=9,960 (2 obs dropped)
	
***** Step 2: Create max indicator 
egen countmax=max(mov_seq_num), by(mov_cnt_num)

***** Step 3: Keep the most recent admits 
drop if mov_seq_num!=countmax //Keeps the most recent admit 
	codebook mov_cnt_num
	
***** Step 4: Take care of duplicates 
duplicates tag, gen(dupcheck)
		gsort - dupcheck mov_cnt_num //Shows that 12 obs are duplicated. 
	bysort _all: gen duplicate=cond(_N==1,0,_n)
		tab duplicate, m 
	drop if duplicate==2 
		codebook mov_cnt_num //N=9,960. Confirmed for sample. 
	
*** Create Date Variables 
foreach i of varlist move_date original_mov_move_date {
	tostring `i', replace 
		gen ay=substr(`i',1,4)
		gen am=substr(`i',5,2)
		gen ad=substr(`i',7,.)
			foreach x of varlist ay am ad {
				tab `x', m
				}
		egen adate=concat(am ad ay), punct(-)
		gen re_`i'=date(adate, "MDY")
			format re_`i' %td
		drop ay am ad adate `i'
		rename re_`i' `i'
	}	
	
/*=======================================================================================
							Finalize Dataset 
=========================================================================================*/	
*** Only Keep Necessary Variables (for dates)
	local keeplist "mov_cnt_num move_code move_date original_mov_move_code original_mov_move_date"
		keep `keeplist' 
	
*** Rename Variables 
	rename move_code move_admitcode
	rename original_mov_move_code move_releasecode
	rename move_date move_admitdate
	rename original_mov_move_date move_releasedate

*** Check Specificiations and Save 
	codebook mov_cnt_num
	sort mov_cnt_num
		save "Cleaned Data\cleaned(wide_moves).dta", replace 
		
		
/*=======================================================================================
						Establish Baseline Demographic File 
-----------------------------------------------------------------------------------------			
The following code will clean and create a database that has the basic demographic 
	information needed for all the inmates in the sample. We want the i=individual here. 
	We will use the 2-tblsearch file, which according to --- is the file that has 
	more detailed information on the inmate. 
	
Steps: 
	(1) Open File and Clean appropriately 
	(2) Collapse to i=individual 
=========================================================================================*/
use "Raw Data\2-tblsearchInmateInfo.dta", clear
	describe 

sort mov_cnt_num
	codebook mov_cnt_num //9,962 unique values; 16,559 obs
	duplicates report //seeing duplicate observations. 
	
*** Double Check the Unique Identification 	
* Take care of duplicates 
duplicates tag, gen(dup_flag) //Creates indicator for duplicates of obs on all vars. 
	tab dup_flag, m
	bysort _all: gen dup=cond(_N==1,0,_n)
	drop if dup==2
	codebook mov_cnt_num //9,962 unique values

*** Create Indicatior for Number of Occurances in Data 
bysort mov_cnt_num: gen count=_n
	order count, after(mov_cnt_num)
	tab count, m 
		/* In these data the majority only have one observation/row. Only 15% of 
			the data have >2 charges, and the maximum number of charges is 10. */

/*=======================================================================================
					Clean: Keep, Rename, and Restructure 
=========================================================================================*/
*** Keep only variables that are necessary 
local varkeep "mov_cnt_num count mov_cur_inmt_num mov_move_code mov_move_date state_id_num event_date delete_date reception_date date_of_birth race_code sex_type commit_cnty marital_status_code sent_date min_expir_date max_expir_date regular_date offense sentence_status lst_nm currloc_cd move_add rcptpn_regular_date offense_code"
	keep `varkeep'
	
***Rename Variables Systematically 
*mov_cnt_num - keep name for merges/etc 
rename mov_cur_inmt_num inmatenum
rename mov_move_code code_movecode
rename mov_move_date date_releasedate
rename state_id_num stateid
rename event_date date_eventdate
rename delete_date date_deletedate
rename reception_date date_receptiondate2
	*drop reception_date
rename date_of_birth date_dob
rename race_code race 
rename sex_type sex 
rename commit_cnty commitcounty
rename marital_status_code maritalstat
rename sent_date date_sentencedate
rename min_expir_date date_minrelease
rename max_expir_date date_maxrelease
rename regular_date date_regdate
rename sentence_status sentstat
rename lst_nm lastname
rename currloc_cd currlocation
rename move_add code_admitcode
rename rcptpn_regular_date date_receptiondate
rename offense_code offensecode

local dems "race sex commitcounty maritalstat offense offensecode sentstat currlocation"
	foreach i of local dems {
		rename `i' dem_`i'
		}
		
***Restructure Data 
	/* We want the most workable data, but I want IDs in the front. */
aorder 
order mov_cnt_num count lastname, first  

*** Get i=individual 
sort mov_cnt_num date_regdate 
	/* It appears that regdate is the most proximal dynamic date next to the 
		static date_releasedate. We can sort my regdate and then keep the 
		most recent one to keep all the information for that admit. */
bysort mov_cnt_num: gen recentcnt=_n 
	tab recentcnt, m 
	order recentcnt, after(count)
	bysort mov_cnt_num: egen maxcnt=max(recentcnt)
		order maxcnt, after(recentcnt)
	keep if recentcnt==maxcnt //Only keeps the observation with the most recent releaes to save info 
		drop count recentcnt 
		
*** Clean Date/Time Formatting 
local dates "date_receptiondate"
foreach i of local dates {
	gen double recode`i'=clock(`i',"MDYhms")
		format recode`i' %td
	gen recode`i'2 = dofc(recode`i')
		format recode`i'2 %td 
	drop `i' recode`i'
		rename recode`i'2 `i'
	}
	
*** Create Date Variables 
foreach i of varlist date_releasedate {
	tostring `i', replace 
		gen ay=substr(`i',1,4)
		gen am=substr(`i',5,2)
		gen ad=substr(`i',7,.)
			foreach x of varlist ay am ad {
				tab `x', m
				}
		egen adate=concat(am ad ay), punct(-)
		gen re_`i'=date(adate, "MDY")
			format re_`i' %td
		drop ay am ad adate `i'
		rename re_`i' `i'
	}	
	
save "Cleaned Data\cleaned(inmatedem).dta", replace 

/*=======================================================================================
								Clean Variables 
=========================================================================================*/	

*** Merge Together with Move Data 
	merge 1:1 mov_cnt_num using "Cleaned Data\cleaned(wide_moves).dta"
		rename _merge move_merge 
		tab move_merge //Should see that 2 obs do not match. Confirmed. 

*** Time Incarcerated 
	gen monthsserved=(move_releasedate-move_admitdate)/30
		summ monthsserved, d
		gen yearsserved=(monthsserved/12)
			tab1 monthsserved yearsserved 
			summ monthsserved yearsserved 
			
*** Renaming 
	rename move_admitdate date_admitdate
		//Note that the release dates are the same. 
	
*** Save Data 
aorder 
	order mov_cnt_num lastname, first  

save "Cleaned Data\cleaned(inmatedata_wide).dta", replace 

/*=======================================================================================
							Establish Visit Files 
-----------------------------------------------------------------------------------------			
The following code will create a database of visits for each inmate. The eventual goal 
	is to make the dataset be wide, such that the unique id is the inmate. The first 
	step will be making a panel dataset of the apprpriate visits and then condensing it
	into appropriate time bins. 
	
Steps: 
	(1) Open File and Clean appropriately 
	(1b) Create a new workable database with only necessary variables 
	(2) Create temporal calculations from the release date and visit 
	(3) Bin the categories with dummy variables 
	(4) Prepare for merge into the uniquely identified data.
	
One thing to consider is that we need to ensure that the vists used are after this incarceration. 
As an aside, we can consider collapsing here and then doing a 1:1 merge, or doing a m:1 merge.   
=========================================================================================*/
use "Raw Data\4-3tblVst_EvntHist.dta", clear 
	describe 

***Keep only Necessary Variables 
local keepvars "mov_cnt_num mov_move_date hist_dt vstr_num vstevnt_dttm vstevnt_tp vstevnt_tmout fac_cd"
	keep `keepvars'

***Rename Variables Systematically 
rename mov_move_date date_releasedate
rename hist_dt date_release 
rename vstr_num visit_id
rename vstevnt_dttm visit_timein
rename vstevnt_tp visit_type
rename vstevnt_tmout visit_timeout
rename fac_cd visit_site

***Restructure Data 
aorder 
order mov_cnt_num, first 

save "Current Data\current(visits).dta", replace 

/*=======================================================================================
							Create Temporal Calculations 
=========================================================================================*/
use "Current Data\current(visits).dta", clear 
	codebook date_release visit_timein 
	inspect date_release visit_timein

			
*** Substring Portion of the Data/Time String Varaibles 
local dates "date_release visit_timein"
foreach i of local dates {
gen double recode`i'=clock(`i',"MDYhms")
	format recode`i' %td
gen recode`i'2 = dofc(recode`i')
	format recode`i'2 %td 
	}
	
capture drop date_releasedate recodedate_release recodevisit_timein //Gets rid of string date 
rename recodedate_release2 date_releasedate
rename recodevisit_timein2 date_visitdate

/*=======================================================================================
					Ensure Visits were During Most Recent Incarceration 
=========================================================================================*/
sort mov_cnt_num date_visitdate
	save "Cleaned Data\cleaned(visits).dta", replace 
	
use "Cleaned Data\cleaned(inmatedata_wide).dta", clear 
	capture drop date_releasedate // For merge 
	merge 1:m mov_cnt_num using "Cleaned Data\cleaned(visits).dta" 
		codebook mov_cnt_num //N=9,962
		
*** Sort on Visit Times 
sort mov_cnt_num date_visitdate

*** Only Keep Visits that were within the most recent incarceartion period
**** Generate Indicator of visit within recent incarceration 
gen ind_visitcurrentinc=0
	replace ind_visitcurrentinc=1 if date_visitdate>date_receptiondate
	
*** Visual Check 
sort mov_cnt_num date_visitdate 
	order date_visitdate date_receptiondate, last
	
*** Only Keep Observations whose visits are within the correct time frame
keep if ind_visitcurrentinc==1

*** Only keep variables from visit data 
local visitvars "mov_cnt_num date_releasedate date_visitdate date_release visit_id visit_timein visit_type visit_timeout visit_site date_admitdate"
keep `visitvars'

*** Organize Data
aorder 
	order mov_cnt_num, first 
sort mov_cnt_num date_visitdate
	
/*=======================================================================================
							Distribution of Visits Over Time 
=========================================================================================*/

	
*** Create Indicator for Visit outside of incarceration period
gen visit_inpd=0
	replace visit_inpd=1 if date_visitdate>date_admitdate & date_visitdate<date_releasedate
	replace visit_inpd=. if date_visitdate==. 
	tab visit_inpd, m 
		drop if visit_inpd==0
		codebook mov_cnt_num 
		
		
*** Calculate Time Before Release 
gen int months_before=(date_visitdate-date_releasedate)/30 
	summ months_before, d //Ensure that they are all negative. 
	
gen int weeks_before=(date_visitdate-date_releasedate)/7
	summ weeks_before, d 

***Check Distribution of Visits 
bysort mov_cnt_num: gen visitcount=_n 
	bysort mov_cnt_num: egen visits_max=max(visitcount)
		replace visits_max=0 if months_before==. //Indicates that there were no visits. 
		replace visitcount=0 if months_before==.
	summ visits_max, d
		preserve
			collapse (max) visits_max, by(mov_cnt_num)
			tab visits_max, m 
				summ visits_max, d //M=30.45, Med=8 
			hist visits_max, d freq  //Distribution of Visits 
		restore 
		
*** Calculate Number of Visits by Visit Event (date rather than visitor like previous)
egen visiteventtag=tag(mov_cnt_num date_visitdate) //Generates a unique tag for every combo
	egen visits_eventcount=total(visiteventtag), by(mov_cnt_num) //Creates total number of unique tags per uid
		replace visits_eventcount=0 if months_before==. 
		replace visiteventtag=0 if months_before==. 
	summ visits_eventcount, d
		preserve 
			collapse (max) visits_eventcount, by(mov_cnt_num)
			tab visits_eventcount, m
				summ visits_eventcount, d
			hist visits_eventcount, d freq
		restore
		
*** Calculate Number of Visits in 24 month period 
egen visits_eventcount24m=total(visiteventtag) if months_before>-24 , by(mov_cnt_num)
	replace visits_eventcount24m=0 if months_before==. 
	summ visits_eventcount24m, d 
		preserve 
			collapse (max) visits_eventcount24m, by(mov_cnt_num)
			tab visits_eventcount24m, m
				summ visits_eventcount24m, d
			hist visits_eventcount24m, d freq
		restore
		
*** Calculate Number of Visits in 12 month period 
egen visits_eventcount12m=total(visiteventtag) if months_before>-12 , by(mov_cnt_num)
	replace visits_eventcount12m=0 if months_before==. 
	summ visits_eventcount12m, d 
		preserve 
			collapse (max) visits_eventcount12m, by(mov_cnt_num)
			tab visits_eventcount12m, m
				summ visits_eventcount12m, d
			hist visits_eventcount12m, d freq
		restore
		
save "Cleaned Data\cleaned(visits_long).dta", replace 

/*=======================================================================================
							Format Data for Trajectories (Wide) 
=========================================================================================*/
use "Cleaned Data\cleaned(visits_long).dta", clear 

*** Distribution of Visits Visually  
#d 
	hist months_before, d freq w(1) 
		title("Distribution of Visits Prior to Release")
		xtitle("Months Prior to Release")
		ytitle("Frequency of Inmates with a Visit") ;
#d cr		
	graph export "Tables and Figures\hist_visits_prerelease.png", as(png) replace

		
*** Create Binary Visit Indicators 
tab months_before, m
	replace months_before=(months_before*(-1)) //Inverts for ease 
	tab months_before, g(visits_monthspre) 
	
*** Create Binary Weekly Visit Indicators 
	tab weeks_before, m
		replace weeks_before=(weeks_before*(-1))
			tab weeks_before, g(visits_weekspre)
			
*** Collapse the Data into the Wide Format 
collapse (max) visits_monthspre* visits_weekspre* date_releasedate visits_max visits_eventcount visits_eventcount24m visits_eventcount12m, by(mov_cnt_num)

*** Replace the missing observations 
	/* Missing observations indicate that the inmate has recieve no visits during thier 
		incarceration period. Observations that are deleated indicate that inmates have 
		received visits in previous incarcerations but not in the current one. When these
		wide data are merged with the uniquely identified data, we can then recode all the 
		visit indiciators accordingly. */
foreach i of varlist visits_monthspre* visits_weekspre* {
	replace `i'=0 if `i'==.
	}
	

		
/*=======================================================================================
							Finalize and Save Data 
=========================================================================================*/
*** Only Keep Necessary Variables 
local dropvars "date_releasedate"
	drop `dropvars'
	
*** Save 
save "Cleaned Data\cleaned(visits_widelogit).dta", replace  






/*=======================================================================================
							Create Misconduct Files 
-----------------------------------------------------------------------------------------			
The following code will create a database of misconducts for each inmate. The eventual goal 
	is to make the dataset be wide, such that the unique id is the inmate. The first 
	step will be making a panel dataset of the apprpriate misconducts and then condensing it
	into appropriate time bins. 
	
Steps: 
	(1) Open File and Clean appropriately 
	(1b) Create a new workable database with only necessary variables 
	(2) Create temporal calculations from the release date and misconducts 
	(3) Bin the categories with dummy variables 
	(4) Prepare for merge into the uniquely identified data.
	
One thing to consider is that we need to ensure that the vists used are after this incarceration. 
As an aside, we can consider collapsing here and then doing a 1:1 merge, or doing a m:1 merge.   
=========================================================================================*/
use "Raw Data\6-3Mischg.dta", clear 
	describe 
	
***Keep only Necessary Variables 
local keepvars "mov_cnt_num mov_move_date miscndct_date2 miscndct_number category_charge sig_date chrg_description"
	keep `keepvars'

***Rename Variables Systematically 
rename miscndct_date2 date_miscdate
rename miscndct_number misc_number
rename category_charge misc_cat
rename chrg_description misc_charge
rename sig_date date_miscsigdate
rename mov_move_date date_deletedate

***Restructure Data 
aorder 
	order mov_cnt_num, first 
	sort mov_cnt_num date_miscdate
	
save "Current Data\current(misconduct charges).dta", replace 

/*=======================================================================================
							Create Temporal Calculations 
=========================================================================================*/
use "Current Data\current(misconduct charges).dta", clear 
	
*** Create Date Variables 
foreach i of varlist date_deletedate date_miscdate {
	tostring `i', replace 
		gen ay=substr(`i',1,4)
		gen am=substr(`i',5,2)
		gen ad=substr(`i',7,.)
			foreach x of varlist ay am ad {
				tab `x', m
				}
		egen adate=concat(am ad ay), punct(-)
		gen re_`i'=date(adate, "MDY")
			format re_`i' %td
		drop ay am ad adate 
	}
	
*** Get Rid of Extra Variables 
drop date_deletedate date_miscdate //These are both string versions 
	rename re_date_deletedate date_deletedate
	rename re_date_miscdate date_miscdate

/*=======================================================================================
					Ensure Misconducts were During Most Recent Incarceration 
=========================================================================================*/
sort mov_cnt_num date_miscdate
	save "Cleaned Data\cleaned(misconducts).dta", replace 
	
use "Cleaned Data\cleaned(inmatedata_wide).dta", clear 
	capture drop date_deletedate // For merge 
	merge 1:m mov_cnt_num using "Cleaned Data\cleaned(misconducts).dta" 
		codebook mov_cnt_num //N=9,962
		
*** Sort on Misconduct Times 
sort mov_cnt_num date_miscdate

*** Only Keep Misconducts that were within the most recent incarceartion period
**** Generate Indicator of misconducts within recent incarceration 
gen ind_misccurrentinc=0
	replace ind_misccurrentinc=1 if date_miscdate>date_admitdate & date_miscdate<date_deletedate 
	tab ind_misccurrentinc, m 
	
*** Visual Check 
sort mov_cnt_num date_miscdate 
	order date_miscdate date_receptiondate, last
	
*** Only Keep Observations whose misconducts are within the correct time frame
keep if ind_misccurrentinc==1
	/* Same logic as visits. Those inmates with missing have never recieved misconducts
		and those that are deleted or do not match with the next merge did not receive 
		misconducts during thier most recent incarceration. */
	codebook mov_cnt_num //N=
	
*** Only keep variables from misconduct data 
local visitvars "mov_cnt_num date_miscdate misc_number misc_cat misc_charge date_miscsigdate date_deletedate date_miscdate"
	keep `visitvars'

*** Organize Data
aorder 
	order mov_cnt_num, first 
sort mov_cnt_num date_miscdate
	
*** Can change for counts and for Misconduct A 

/*=======================================================================================
						Distribution of Misconduct Over Time 
=========================================================================================*/
*** Calculate Time Before Release 
gen int misc_monthsbefore=(date_miscdate-date_deletedate)/30 
	summ misc_monthsbefore, d 

*** Calulcuate Time Before Release (Weeks) 
	gen int misc_weeksbefore=(date_miscdate-date_deletedate)/7
		summ misc_weeksbefore, d 

***Check Distribution of Misconducts  
sort mov_cnt_num date_miscdate
bysort mov_cnt_num: gen misccount=_n 
	bysort mov_cnt_num: egen misc_max=max(misccount)
		replace misc_max=0 if date_miscdate==.
		replace misccount=0 if date_miscdate==.
	summ misc_max, d
		preserve
			collapse (max) misc_max, by(mov_cnt_num)
			*tab misc_max, m 
				summ misc_max, d //M=6.73, Med=2 
			hist misc_max, d freq  //Distribution of Misconducts  
		restore 
		
***Check Distribution of Misconduct A 
sort mov_cnt_num date_miscdate
	gen ind_misca=(misc_cat=="A")
	egen misc_amax=sum(ind_misca), by(mov_cnt_num)
		replace ind_misca=0 if date_miscdate==.
		replace misc_amax=0 if date_miscdate==.
	summ misc_amax, d
		preserve
			collapse (max) misc_amax, by(mov_cnt_num)
			tab misc_amax, m 
				summ misc_amax, d //
			hist misc_amax, d freq  //Distribution of Misconducts  
		restore 
		
*** Calculate Number of Visits in 24 month period 
egen misc_max24m=max(misccount) if misc_monthsbefore>-24 , by(mov_cnt_num)
	replace misc_max24m=0 if date_miscdate==. 
	summ misc_max24m, d
		preserve
			collapse (max) misc_max24m, by(mov_cnt_num)
			tab misc_max24m, m 
				summ misc_max24m, d  
			hist misc_max24m, d freq  
		restore 
		
*** Calculate Number of Visits in 24 month period 
egen misc_max12m=max(misccount) if misc_monthsbefore>-12 , by(mov_cnt_num)
	replace misc_max12m=0 if date_miscdate==. 
	summ misc_max12m, d
		preserve
			collapse (max) misc_max12m, by(mov_cnt_num)
			tab misc_max12m, m 
				summ misc_max12m, d  
			hist misc_max12m, d freq  
		restore 
		
*** Distribution of Misconduct A 
egen misc_a24m=total(ind_misca) if misc_monthsbefore>-24 , by(mov_cnt_num)
	replace misc_a24m=0 if date_miscdate==. 
	summ misc_a24m, d
		preserve
			collapse (max) misc_a24m, by(mov_cnt_num)
			tab misc_a24m, m 
				summ misc_a24m, d  
			hist misc_a24m, d freq  
		restore 
		
*** Distribution of Misconduct A 
egen misc_a12m=total(ind_misca) if misc_monthsbefore>-12 , by(mov_cnt_num)
	replace misc_a12m=0 if date_miscdate==. 
	summ misc_a12m, d
		preserve
			collapse (max) misc_a12m, by(mov_cnt_num)
			tab misc_a12m, m 
				summ misc_a12m, d  
			hist misc_a12m, d freq  
		restore 

save "Cleaned Data\cleaned(misconducts_long).dta", replace 

/*=======================================================================================
							Format Data for Trajectories (Wide) 
=========================================================================================*/
use "Cleaned Data\cleaned(misconducts_long).dta", clear 

*** Distribution of Visits Visually  
#d 
	hist misc_monthsbefore, d freq w(1) 
		title("Distribution of Misconducts Prior to Release")
		xtitle("Months Prior to Release")
		ytitle("Frequency of Inmates with a Misconduct") ;
#d cr
		graph export "C:\Users\bwpheas\Dropbox\PA Visits\Tables and Figures\hist_misconducts_prerelease.png", as(png) replace

		
*** Create Binary Visit Indicators 
tab misc_monthsbefore, m
	replace misc_monthsbefore=(misc_monthsbefore*(-1)) //Inverts for ease 
	tab misc_monthsbefore, g(misc_monthspre) 
	
tab misc_weeksbefore, m
	replace misc_weeksbefore=(misc_weeksbefore*(-1))
	tab misc_weeksbefore, g(misc_weekspre)
	
*** Collapse the Data into the Wide Format 
collapse (max) misc_monthspre* misc_weekspre* date_deletedate misc_max misc_amax misc_max24m misc_a24m misc_max12m misc_a12m, by(mov_cnt_num)

*** Replace the missing observations 
	/* Missing observations indicate that the inmate has recieve no misconducts during thier 
		incarceration period. Observations that are deleated indicate that inmates have 
		received visits in previous incarcerations but not in the current one. When these
		wide data are merged with the uniquely identified data, we can then recode all the 
		visit indiciators accordingly. */
foreach i of varlist misc_monthspre* misc_weekspre* {
	replace `i'=0 if `i'==.
	}
	

/*=======================================================================================
							Finalize and Save Data 
=========================================================================================*/
*** Only Keep Necessary Variables 
local dropvars "date_deletedate"
	drop `dropvars'
	
*** Save 
save "Cleaned Data\cleaned(misconducts_widelogit).dta", replace  
	
		
/*=======================================================================================
						Finalize Wide Dataset for Trajectory Models
-----------------------------------------------------------------------------------------			
The following code will create the final analytic datset that can be used to estimate 
	the trajectory models for both visits and misconducts. There will be some work that 
	needs to be done to ensure temporal consistency, however this is the rough data. 
	
Steps: 
	(1) Open the original file with demographic information 
	(2) Merge in the visits wide 
	(3) replace the obs that didn't match with 0's 
	(4) Repeat 2/3 for the misconduct data 
	(5) Keep releveant variables.    
=========================================================================================*/		

*** Open original file and bring in visits data 
use "Cleaned Data\cleaned(inmatedata_wide).dta", clear 
	order mov_cnt_num, first 
	merge 1:1 mov_cnt_num using "Cleaned Data\cleaned(visits_widelogit).dta"
	
*** Clean the Unmatched Observations to have Zeros for datapoints 
drop _merge //consider creating an indicator, however we have to consider the previous missing 
foreach i of varlist visits_monthspre* visits_weekspre* {
	replace `i'=0 if `i'==.
	}
	
*** Merge in Misconduct Data 
merge 1:1 mov_cnt_num using "Cleaned Data\cleaned(misconducts_widelogit).dta"
	
*** Clean Unmatched Obs for Misconduct 
drop _merge 
foreach i of varlist misc_monthspre* misc_weekspre* {
	replace `i'=0 if `i'==.
	}
 
*** Save Data 
save "Analytic Data\analytic(gbmtm_vismisc_wide).dta", replace 


**** Descriptives on Sample 
*** Distribution of Visits Visually  
#d 
	hist monthsserved, d percent w(1) 
		title("Distribution of Months Served")
		xtitle("Months")
		ytitle("Percentage of Inmates with a Misconduct") ;
#d cr

*** Distribution of Visits Visually  
#d 
	hist yearsserved, d percent w(1) 
		title("Distribution of Years Served")
		xtitle("Years")
		ytitle("Percentage of Inmates with a Misconduct") ;
#d cr

summ monthsserved yearsserved visits_max visits_eventcount misc_max misc_amax, sep(0)

/*NEXT STEPS: 
	- 


/*================ Update Log ================
10/19/20 - MP   - Updated to Include Weekly Visit and Misconduct Indicators 
02/10/20 - MP 	- Finished the visits and the misconduct portions  

 
*/ */
log close 





/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================

*/
