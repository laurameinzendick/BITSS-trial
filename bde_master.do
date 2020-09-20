********************************************************************************
*** Title: bde_master.do
*** Created by: Laura Meinzen-Dick
***	Created on: 4 June 2019
*** Last modified on: 28 August 2020
*** Last modified by: Laura Meinzen-Dick
*** Purpose: Organize do-files to do all analysis 
***	Outline:
***		1. Setup
***		2. Data Import and Clean:
**			Outcomes
**			Treatment Status
**			Covariates
***		3. Merge Datasets
***		4. Clean and Create Variables
***		5. Balance Tables
***		6. Placebos
***		7. Regressions
***		8. Graphs

*** Edits:

***	To-do:
***		1. Ethnicity data
********************************************************************************

capture log close master
clear all
macro drop _all
set more off
set linesize 80
local date `c(current_date)'
set seed 54301

***	1. Setup
**		a. Installing packages:
*ssc install outreg2
*ssc install outreg

cd "C:\Users\ilove\Dropbox\Burkina decentralization"

** 		b. Start log file
log using "log\master\bde_master_`date'", text replace name(master)

********************************************************************************
**************************** Data Import and Clean *****************************
********************************************************************************

*********************************** Outcomes ***********************************

***		a. Import and Clean CENI election data

do "do\build\outcomes\bde_outcome01-ceni_v3.do"
* edited on 10/16 to include ranking parties to get max and second max vote/seat share
* edited on 10/28 to include 2006 data
*	creates dta/clean/outcomes/bde_ceni_v3.dta

***		b. Import and clean Afrobarometer data

do "do\build\outcomes\bde_outcome02-afrobarometer_v1.do"
*	creates dta\clean\outcomes\bde_afrobarometer_v2.dta

***		c. Import SUPERMUN Scorecard data

do "do\build\outcomes\bde_outcome03-scorecard_v1.do"
*	creates dta\clean\outcomes\bde_scorecard_v1.dta which has 2014 - 2017 scorecards



******************************* Treatment Status *******************************

***		a. Data clean MCC treatment status data

do "do\build\treatment\bde_treat01-mcc_v2.do"
*	creates dta\clean\treatment\bde_mcc_v2.dta


********************************** Covariates **********************************

***		a. Data clean FAO livestock production systems datasets

do "do\build\covariates\bde_covar01-fao_v1.do"
*	creates dta\clean\covariates\bde_fao_v1.dta


***		b. Import Murdock ethnicity data
*	needs to run "do\build\fetch\BurkinaFasoMap.R" to create csvs from .shp files
*	infinite thanks to Matt Gammans

do "do\build\covariates\bde_covar02-murdock_v1.do"
*	creates dta\clean\covariates\bde_murdock_v1.dta which is long - each observation is a municipality-ethnicity pair (add up to 1 within a municipality)


***		c. Import and clean geocoded aiddata

do "do\build\covariates\bde_covar03-aiddata_v1.do"
*	creates dta\clean\covariates\bde_aiddata_v1.dta 


***		d. Import and clean Spatially interpolated data on ethnicity
*	 needs to run "do\build\fetch\SIDEMAP.R" to create csvs from spatial data

do "do\build\covariates\bde_covar04-side_v1.do"

***		e. Import and clean IPUMS data

do "do\build\covariates\bde_covar05-ipums_v1.do"


********************************************************************************
******************************** Merge Datasets ********************************
********************************************************************************

***		a. CENI election data + Treatment Status + Covariates

do "do\build\merge\bde_merge01-ceni_v1.do"
*	creates dta\clean\merged\bde_ceni-mcc_v1.dta - election results, treatment status, FAO, SIDE, and Aiddata

***		b. Afrobarometer + Treatment Status + Covariates

do "do\build\merge\bde_merge02-afrobarometer_v1.do"
*	creates dta\clean\merged\bde_afrobarometer-mcc_v1.dta - merged with only treatment status

***		c. SUPERMUN Scorecard data + Treatment Status + Covariates

do "do\build\merge\bde_merge03-scorecard_v1.do"
*	creates dta\clean\merged\bde_scorecard-mcc_v1.dta - merged with only treatment status


***		d. Murdock data - different format (not one observation for each commune)
*do "do\build\merge\bde_data08-merge_murdock_v1.do"
*	creates dta\clean\bde_murdock-mcc-ceni_v1.dta - merged with election results

***		e. Map of treatment locations over time

do "do\build\merge\bde_merge04-map_v2.do"
*	creates dta\clean\bde_



********************************************************************************
************************** Create and Clean Variables **************************
********************************************************************************

***		a. Ceni data

do "do\build\clean\bde_clean01-ceni_v1.do"
*	creates dta\clean\bde_ceni-mcc_v2.dta

***		b. Afrobarometer data

do "do\build\clean\bde_clean02-afrobarometer_v1.do"
*	creates dta\clean\bde_afrobarometer-mcc_v2.dta



********************************************************************************
******************************** Balance Tables ********************************
********************************************************************************

***		a. CENI data

do "do\learn\balance\bde_bal01-ceni_v1.do"
*	creates balance tables - phase I is bad control, phase II is pretty good

***		b. Afrobarometer data 

do "do\learn\balance\bde_bal02-barometer_v1.do"
*	creates 


********************************************************************************
*********************************** Placebos ***********************************
********************************************************************************

***		a. CENI data

do "do\learn\placebo\bde_placebo01-ceni_v1.do"
*	creates placebo tables: all specifications + "ceni-placebos" in appendix

***		b. Afrobarometer data 

do "do\learn\placebo\bde_placebo02-barometer_v1.do"
*	creates placebo tables: public-goods, public-goods-well, and national-politics in appendix

********************************************************************************
********************************** Regressions *********************************
********************************************************************************

***		a. CENI data

do "do\learn\reg\bde_reg01-ceni-parties_v1.do"
*	creates parties_contest & competition tables for main paper
*	creates competititve_alt & cdp tables for appendix

do "do\learn\reg\bde_reg02-ceni-voters_v1.do"
*	creates turnout for main paper

do "do\learn\reg\bde_reg03-ceni-parties-het_v1.do"
*	creates past_contest & learning for main paper
*	creates far_contest & far+past_contest for main paper

do "do\learn\reg\bde_reg04-ceni-voters-het_v1.do"
* 	creates incumb for main paper
*	creates turnout_het for appendix


***		b. Afrobarometer data

do "do\learn\reg\bde_reg05-barometer_v1.do"
*	creates corrupt, coup, engage, voting, efficacy, vote-bribe for main paper
*	creates president, officials and local for appendix [many other appendix tables with robustness to different specifications if needed]

********************************************************************************
************************************ Graphs ************************************
********************************************************************************

***		a. CENI data 

do "do\learn\graph\bde_graph01-ceni-parties_v1.do"
* creates seats_cont (placebo), parties_contest, parties_hist, cdp_contest, 10perc, no_seats, & past_parties graphs using coef plot

do "do\learn\graph\bde_graph02-ceni-voters_v1.do"
* creates turnout using coef plot

***		b. Afrobarometer data 

do "do\learn\graph\bde_graph03-afrobarometer_v1.do"
* creates corrupt using coef plot



***		c. Map

do "do\learn\graph\bde_graph04-map_v2.do"
* creates maps of treatment municipalities using grmap

/*


***		26. Murdock ethnic groups heterogeneity

do "do\learn\bde_reg26-parties-murdock-did_v1.do"
*	creates regression tables for responses by parties, interacted with single ethnic group dominant and measures of institutional hierarchy

*/
log close master
exit
