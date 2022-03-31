capture log close 
cd "[USER FILE PATH]"
log using "USER FILE NAME.smcl", replace
/*=====================================================================================
Program Author: Madelihne Pheasant 
Start Date: 	May 12, 2020
Last Updated: 	May 12, 2020 (MP)

Program Description: 	GBMTM
						Create Dual Indicators   

Objective: 	The objective of this file is to run the dual model in order to create
	group indicators in analytic data. 

See bottom of the file for update log & description of next steps.
=====================================================================================*/
	set more off
	clear all

/*=======================================================================================
						Run Dual Models and Create Group Indicators  
-----------------------------------------------------------------------------------------			
This section will run the final dual model solution in order to create post-estimation 
	group indicators in order to run group comparions. 
	
Steps:
	(1) Run Dual and save Estimates
	(3) Save File 
=========================================================================================*/	

/*=======================================================================================
								Run Final Dual Solution
=========================================================================================*/
	/* This section will run the dual solution in M_Final Models.do. These start values 
		are taken from the completed dual solution. */
*** Run Dual Model with Start Values 
	use "Analytic Data\Subsamples\analytic(24 month final).dta", clear
		#d
		matrix dual=(0.13253, 4.77976, -6.31394, -71.57329,
					-1.47227, -0.23411, -11.61153, 90.42403, 
					-5.53073, -1.41286, 29.21350, -17.27361, 
					-4.26484, -42.32665, 90.28387, 901.90889, 
					0.93557, -24.26739, -70.14462, 508.60668, 
					3.01241, 0.23509, -44.16686, 19.77010, 
					6.49133, 15.50391, 64.51452, 4.75865, 2.48610, 5.24549, 
					-1.81770, -10.60246, -53.59056, 
					-6.84143, 3.40939, 34.51725, 
					-2.48330, 22.40688, -70.70549, 
					-1.28152, 48.40407, -661.69655, 
					-0.62384, -0.01168, 8.15848, 
					1.11879, -2.11638, -20.61224, 
					8.67302, 75.67301, 8.93037, 4.76166, 1.96194, 0.00000, 
					9.93278, 67.60896, 10.03478, 7.72391, 3.81116, 0.88841, 
					11.22830, 59.26156, 14.47019, 8.57578, 5.63650, 0.82767, 
					8.90246, 62.37840, 17.33018, 6.47139, 4.91757, 0.00000, 
					9.91738, 59.09038, 13.78853, 14.52709, 2.67662, 0.00000, 
					4.19968, 77.71484, 10.41037, 4.62694, 3.04816, 0.00000) ; 
		#d cr
		local misc = "c_misc_monthspre1-c_misc_monthspre24"
		local visits = "visits_monthspre1-visits_monthspre24"
	traj, start(dual) model(logit) var(`visits') indep(z24m*) order(3 3 3 3 3 3) ///
			model2(zip) var2(`misc') indep2(z24m*) order2(2 2 2 2 2 2) detail

*** View Dual Indicators 
	local visitsgroups _traj_Group _traj_ProbG1 _traj_ProbG2 _traj_ProbG3 ///
							_traj_ProbG4 _traj_ProbG5 _traj_ProbG6 
	local miscgroups _traj_Model2_Group _traj_Model2_ProbG1 _traj_Model2_ProbG2 ///
						_traj_Model2_ProbG3 _traj_Model2_ProbG4 _traj_Model2_ProbG5 ///
						_traj_Model2_ProbG6
	summ `visitsgroups', sep(0)
		tab _traj_Group 
	summ `miscgroups', sep(0)
		tab _traj_Model2_Group 

*** Create Dual Group Indicators for each Trajectory
	tab _traj_Group, gen(dual_visitsg) // Creates indicator from highest pp
		summ dual_visitsg*, sep(0) // Summarizes the indicators - should be equal to sizes
		gen dualgroup_visits=(_traj_Group) // Creates categorical group indicator 
		
	tab _traj_Model2_Group, gen(dual_miscg)
		summ dual_miscg*, sep(0)
		gen dualgroup_misc=(_traj_Model2_Group)
		
*** Create Dual Joint Indicators 
	/* The previous section made indicators for each group estimated in the single
		trajectories for the dual model. This section will create a series of 
		indicators for the joint group assignment. */
	foreach i of numlist 1/6 {
		foreach x of numlist 1/6 {
			di "Joint Group Visits G`i' and Misconduct G`x'"
			gen dualgroup_v`i'm`x'=(dualgroup_visits==`i' & dualgroup_misc==`x')
				tab dualgroup_v`i'm`x', m  
			}
		}

*** Quickly Summarize All Created Indicators 
	/* There should be 36 joint group indicators. */
	fsum dualgroup_v*
				
*** Save File           
	save "Analytic Data\Subsamples\analytic(dual groups).dta", replace 

/*NEXT STEPS: 
	- Create Indicators from Post Estimation 
		- Re-arrange indicators, or create new ones to match excel file. 

/*================ Update Log ================
03/18/20 - MP 	- Began the .do file  
 
*/ */ 
log close 




/*=======================================================================================
								LOCAL SCRATCH PAD
=========================================================================================


