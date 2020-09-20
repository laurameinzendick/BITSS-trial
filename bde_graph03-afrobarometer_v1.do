********************************************************************************
*** Title: bde_graph03-afrobarometer_v1.do
*** Created by: Laura Meinzen-Dick
***	Created on: 6 December 2019
*** Last modified on: 26 May 2020
*** Last modified by: Laura Meinzen-Dick
*** Purpose: Graphs for survey outcomes from Afrobarometer
***	Outline:
***		1. Setup
***		2. Load merged data 
***		3. Voter turnout

*** Edits:

***	To-do:

********************************************************************************

capture log close 
clear all
macro drop _all
set more off
set linesize 80
set scheme lycidas1
graph set window fontface cmr17
graph set eps fontfacesans cmr17
graph set eps fontfaceserif cmf17
graph set print logo off
local date `c(current_date)'

***	1. Setup
**		a. Installing packages:
*ssc install outreg2
*ssc install outreg
*ssc install coefplot


cd "C:\Users\ilove\Dropbox\Burkina decentralization"

local ver 1


** 		b. Start log file
log using "log\learn\graph\bde_graph03-afrobarometer_v`ver'-`date'", text replace


***	2. Load election + treatment data

use "dta\clean\bde_afrobarometer-mcc_v2.dta", clear


***	3. Perceptions of Corruption

mean corrupt_officials_yes if treat_group == 3, over(year) vce(cluster comp)
est store off1

mean corrupt_officials_yes if treat_group == 4, over(year) vce(cluster comp)
est store off2

mean corrupt_local_yes if treat_group == 3, over(year) vce(cluster comp)
est store local1

mean corrupt_local_yes if treat_group == 4, over(year) vce(cluster comp)
est store local2

mean corrupt_pres_yes if treat_group == 3, over(year) vce(cluster comp)
est store pres1

mean corrupt_pres_yes if treat_group == 4, over(year) vce(cluster comp)
est store pres2

coefplot	(pres1, label(Control) offset(-0.025)) (pres2, label(Treatment) offset(0.025)), bylabel(President's Office) rename(c.corrupt_pres_yes@2008.year=2008 c.corrupt_pres_yes@2012.year=2012 c.corrupt_pres_yes@2015.year=2015) ///
		||	(off1, 	label(Control) offset(-0.025)) (off2,  label(Treatment) offset(0.025)), bylabel(Government Officials) rename(c.corrupt_officials_yes@2008.year=2008 c.corrupt_officials_yes@2012.year=2012 c.corrupt_officials_yes@2015.year=2015) ///
		||	(local1, label(Control) offset(-0.025)) (local2, label(Treatment) offset(0.025)), bylabel(Local Government Council) /// 
		vertical level(90) rename(c.corrupt_local_yes@2008.year=2008 c.corrupt_local_yes@2012.year=2012 c.corrupt_local_yes@2015.year=2015) recast(connected) byopts(compact rows(1)) title("Corruption in") subtitle(,nobox) ytitle("Respond All or Most are Corrupt")

graph export "out/learn/graph/afrobarometer/corrupt.pdf", replace



log close
exit
