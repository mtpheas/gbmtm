cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madeline Pheasant
Start Date: 	December 18, 2019
Last Updated: 	December 19, 2019 (SJ)

Program Description: 	PA Visits 
						Merging Files Together 

Objective: 	Rename and convert the data for the PA Visit paper. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all

/*=======================================================================================
						Open and Rename PA Files
-----------------------------------------------------------------------------------------								
The following code will begin to view all of the PA Visit Files, rename/label 
	accordingly and then merge these files together in order to have a comprehensive 
	database. The first step will be to describe each database and then see how they link 
	up. According to Brett the control number is the unique identifier. 
=========================================================================================*/

/*=======================================================================================
								Data Exploration 
=========================================================================================*/
use "Raw Data\1-movrec.dta", clear 
	codebook mov_cnt_num //N=245,123, i=9,962

use "Raw Data\2-tblsearchInmateInfo.dta", clear 
	codebook mov_cnt_num //N=16,559, i=9,962
	
use "Raw Data\3-1tblInmTestScoreHist.dta", clear 
	codebook mov_cnt_num //N=86,977, i=9,962
	
use "Raw Data\3-tblInmTestScore.dta", clear 
	codebook mov_cnt_num //N=46,387, i=9,962
 
use "Raw Data\4-1tblVst_Detail.dta", clear 
	codebook mov_cnt_num //N=9,988, i=9,962
 
use "Raw Data\4-2tblVst_DetailHist.dta", clear 
	codebook mov_cnt_num //N=10,074, i=9,962
	
use "Raw Data\4-3tblVst_EvntHist.dta", clear 
	codebook mov_cnt_num //N=306,253, i=9,962

use "Raw Data\4-5tblVstEvnt_Cls.dta", clear 
	*** No unique id,
	
use "Raw Data\4-6tblVstEvnt_Tp.dta", clear 
	*** No uid: Codebook for event type. 
	
use "Raw Data\4-7tblVstr.dta", clear 
	codebook vstr_num 
	*** Variable is not linked to scid. Instead it is for visiter. ~560,000 i's
	
use "Raw Data\4-8tblVstr_CdHist.dta", clear 
	codebook vstr_num //N=74,751, i=58,945
		*** Visitor Information. 
	
use "Raw Data\4-9tblVstr_CdHistHist.dta", clear 
	codebook vstr_num //N=241,313, i=177,166
		*** Visitor Information 
		
use "Raw Data\4-10tblVstr_RltnshpHist.dta", clear 
	codebook mov_cnt_num //N=10,672, i=9,962
	
use "Raw Data\4-12tblVstrHist.dta", clear 
	codebook vstr_num //N=1.8 million i=1.6 million
		*** Visitor Information 
		
use "Raw Data\4-13tblVstrLst.dta", clear 
	codebook vstr_num //N=588,725 i=560,433
		*** Visitor Information 
		
use "Raw Data\4-14tblVstrLstHist.dta", clear 
	codebook mov_cnt_num //N=121,447, i=9,962

use "Raw Data\4-15tblVstrRltnshp.dta", clear 	
	codebook mov_cnt_num //N=10,033, i=9,962

use "Raw Data\4-16tblVstrStatus.dta", clear 	
	*** Codebook for vstrsatus_cd
	
use "Raw Data\4-17tblVstrTp.dta", clear 	
	*** Codebook for vstrtp
	
use "Raw Data\5-perrec.dta", clear 	
	codebook mov_cnt_num //N=9,980, i=9,962

use "Raw Data\6-1Misapp.dta", clear 		
	codebook mov_cnt_num //N=18,895, i=9,962

use "Raw Data\6-2Misasa.dta", clear 		
 	codebook mov_cnt_num //N=57,144, i=9,962

use "Raw Data\6-3Mischg.dta", clear 		
	codebook mov_cnt_num //N=71,496, i=9,962

use "Raw Data\6-4Miscon.dta", clear 		
	codebook mov_cnt_num //N=48,475, i=9,962

use "Raw Data\6-5Mishea.dta", clear 		
	codebook mov_cnt_num //N=39,471, i=9,962

use "Raw Data\7-vwCCISAllInmate.dta", clear 		
	codebook control_number //N=129,732, i=129,461
	
use "Raw Data\7-vwCCISAllMvmt.dta", clear 				
	*** County level information
	
use "Raw Data\7-vwCCISAllProgDtls.dta", clear 		
	*** Unclear. Program infomration. UIDmvmt. 1.2 million obs
	
use "Raw Data\8-Offense Codes Table MOST CURRENT.dta", clear 		
	*** Offense Codes Codebook 
	
use "Raw Data\9-Classification history.dta", clear 		
	codebook mov_cnt_num //N=45,714, i=9,962

use "Raw Data\10-1tblRecmdPrgm.dta", clear 	
	codebook mov_cnt_num //N=10,357, i=9,962
	
use "Raw Data\10-2tblRecmdPrgmCatgry.dta", clear 	
	codebook mov_cnt_num //N=10,139, i=9,962
	
use "Raw Data\10-3dbo_tblRecmdPrgmCatgryHist.dta", clear 	
	codebook mov_cnt_num //N=12,120, i=9,962
	
use "Raw Data\10-4dbo_tblRecmdPrgmHist.dta", clear 	
	codebook mov_cnt_num //N=12,187, i=9,962
	
use "Raw Data\12-tbl_CountyClass.dta", clear 	
	**** County identifier. Code. 
