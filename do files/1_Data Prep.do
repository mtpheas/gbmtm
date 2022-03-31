cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Sydney Jaw
Start Date: 	November 19, 2019
Last Updated:	November 24, 2019 (SJ)

Program Description: 	PA Visits 
						Converting text files from PADOC  

Objective: 	Rename and convert the data for the PA Visit paper. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
set more off
clear all

/*=======================================================================================
						Open and Rename PA Files
-----------------------------------------------------------------------------------------								
The following code will import all of the PA files, convert them to .dta, and rename them accordingly.  
X	1) Open and resave all the files. 
=========================================================================================*/
*** 1-movrec
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\1-movrec.txt", delimiter("!") clear
	save "Raw Data\1-movrec.dta", replace 
	
*** 2-tblsearchInmateInfo
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\2-tblsearchInmateInfo.txt", delimiter("!") clear 
	save "Raw Data\2-tblsearchInmateInfo.dta", replace 
	
*** 3-1tblInmTestScoreHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\3-1tblInmTestScoreHist.txt", delimiter("!") clear 
	save "Raw Data\3-1tblInmTestScoreHist.dta", replace 

*** 3-tblInmTestScore
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\3-tblInmTestScore.txt", delimiter("!") clear
	save "Raw Data\3-tblInmTestScore.dta", replace 
	
*** 4-1tblVst_Detail
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-1tblVst_Detail.txt", delimiter("!") clear  
	save "Raw Data\4-1tblVst_Detail.dta", replace 
	
*** 4-2tblVst_DetailHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-2tblVst_DetailHist.txt", delimiter("!") clear
	save "Raw Data\4-2tblVst_DetailHist.dta", replace 
	
*** 4-3tblVst_EvntHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-3tblVst_EvntHist.txt", delimiter("!") clear 
	save "Raw Data\4-3tblVst_EvntHist.dta", replace 
	
*** 4-5tblVstEvnt_Cls
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-5tblVstEvnt_Cls.txt", delimiter("!") clear 
	save "Raw Data\4-5tblVstEvnt_Cls.dta", replace 
	
*** 4-6tblVstEvnt_Tp
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-6tblVstEvnt_Tp.txt", delimiter("!") clear 
	save "Raw Data\4-6tblVstEvnt_Tp.dta", replace 
	
*** 4-7tblVstr
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-7tblVstr.txt", delimiter("!") varnames(1) clear //Problem importing: "Unmatched quote while processing"
	save "Raw Data\4-7tblVstr.dta", replace 
	
*** 4-8tblVstr_CdHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-8tblVstr_CdHist.txt", delimiter("!") clear
	save "Raw Data\4-8tblVstr_CdHist.dta", replace 
	
*** 4-9tblVstr_CdHistHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-9tblVstr_CdHistHist.txt", delimiter("!") clear 
	save "Raw Data\4-9tblVstr_CdHistHist.dta", replace 
	
*** 4-10tblVstr_RltnshpHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-10tblVstr_RltnshpHist.txt", delimiter("!") clear
	save "Raw Data\4-10tblVstr_RltnshpHist.dta", replace 
	
*** 4-12tblVstrHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-12tblVstrHist.txt", delimiter("!") varnames(1) clear //Problem importing: "Unmatched quote while processing"
	save "Raw Data\4-12tblVstrHist.dta", replace 
	
*** 4-13tblVstrLst
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-13tblVstrLst.txt", delimiter("!") clear
	save "Raw Data\4-13tblVstrLst.dta", replace 
	
*** 4-14tblVstrLstHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-14tblVstrLstHist.txt", delimiter("!") clear 
	save "Raw Data\4-14tblVstrLstHist.dta", replace 

*** 4-15tblVstrRltnshp
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-15tblVstrRltnshp.txt", delimiter("!") clear 
	save "Raw Data\4-15tblVstrRltnshp.dta", replace 	

*** 4-16tblVstrStatus
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-16tblVstrStatus.txt", delimiter("!") clear 
	save "Raw Data\4-16tblVstrStatus.dta", replace 	
	
*** 4-17tblVstrTp
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\4-17tblVstrTp.txt", delimiter("!") clear 
	save "Raw Data\4-17tblVstrTp.dta", replace 	
	
*** 5-perrec
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\5-perrec.txt", delimiter("!") clear 
	save "Raw Data\5-perrec.dta", replace 	

*** 6-1Misapp
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\6-1Misapp.txt", delimiter("!") clear 
	save "Raw Data\6-1Misapp.dta", replace 		
	
*** 6-2Misasa
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\6-2Misasa.txt", delimiter("!") clear 
	save "Raw Data\6-2Misasa.dta", replace 		
	
*** 6-3Mischg
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\6-3Mischg.txt", delimiter("!") clear 
	save "Raw Data\6-3Mischg.dta", replace 		
	
*** 6-4Miscon
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\6-4Miscon.txt", delimiter("!") clear //Problem importing: "Unmatched quote while processing"
	save "Raw Data\6-4Miscon.dta", replace 		
	
*** 6-5Mishea
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\6-5Mishea.txt", delimiter("!") clear 
	save "Raw Data\6-5Mishea.dta", replace 		

*** 7-vwCCISAllInmate
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\7-vwCCISAllInmate.txt", delimiter("|") clear  //Problem importing: "Unmatched quote while processing"
	save "Raw Data\7-vwCCISAllInmate.dta", replace 		

*** 7-vwCCISAllMvmt
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\7-vwCCISAllMvmt.txt", delimiter("|") clear  //Problem importing: "Unmatched quote while processing"
	save "Raw Data\7-vwCCISAllMvmt.dta", replace 				

*** 7-vwCCISAllProgDtls
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\7-vwCCISAllProgDtls.txt", delimiter("|") clear 
	save "Raw Data\7-vwCCISAllProgDtls.dta", replace 		
	
*** 8-Offense Codes Table MOST CURRENT
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\8-Offense Codes Table MOST CURRENT.txt", delimiter("!") varnames(1) clear 
	save "Raw Data\8-Offense Codes Table MOST CURRENT.dta", replace 		
	
*** 9-Classification history
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\9-Classification history.txt", delimiter("!") varnames(1) clear 
	save "Raw Data\9-Classification history.dta", replace 		

*** 10-1tblRecmdPrgm
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\10-1tblRecmdPrgm.txt", delimiter("!") clear 
	save "Raw Data\10-1tblRecmdPrgm.dta", replace 	
	
*** 10-2tblRecmdPrgmCatgry
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\10-2tblRecmdPrgmCatgry.txt", delimiter("!") clear
	save "Raw Data\10-2tblRecmdPrgmCatgry.dta", replace 	
	
*** 10-3dbo_tblRecmdPrgmCatgryHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\10-3dbo_tblRecmdPrgmCatgryHist.txt", delimiter("!") clear
	save "Raw Data\10-3dbo_tblRecmdPrgmCatgryHist.dta", replace 	
	
*** 10-4dbo_tblRecmdPrgmHist
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\10-4dbo_tblRecmdPrgmHist.txt", delimiter("!") clear
	save "Raw Data\10-4dbo_tblRecmdPrgmHist.dta", replace 	
	
*** 12-tbl_CountyClass
import delimited "C:\Users\hjaw\Dropbox\PA Visits\Data\PA Files_11182019\12-tbl_CountyClass.txt", delimiter("!") clear 
	save "Raw Data\12-tbl_CountyClass.dta", replace 	
	

/* ================ Update Log ==================================
11/24 - SJ	- Finish .do file
11/19 - SJ	- Import until 4-7   
*/
log close
