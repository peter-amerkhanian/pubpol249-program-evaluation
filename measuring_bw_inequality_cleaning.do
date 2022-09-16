/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
This do-file creates a dataset on black-white earnings gaps over 1950-2019 at the median (and 90th percentile) controlling for age groups.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
STEPS:
	*0. Set directories.
	*1. Import census and ACS data, adjust for inflation.
	*2. Generate and prepare variables for analysis.
	*3. Perform quantile regression.
	*4. Save regression results as dataset.
	*5. Plot graphs.
	
*first created: 9/8/2022
*last updated:  9/8/2022
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
*TO DO BEFORE YOU START
	 *Please run "ssc install parmest" to install command parmest on your computer [this will be useful to store results from the qreg command]
	 *Please organize the folder in which you work (equivalent to my "ps2_q3_solutions" below) following this architecture
		* folder > data > raw	 	[this is where you should store the census and acs data ("usa_00053.dta") and inflation series ("cpi_acs.dta")]
		*				> output    [this is where you should store any intermediary datasets needed to plot the relevant figures]
		*		 > figures 			[this is where your figures will be outputted]
		*		 > pgm 				[this is where you can work with your .do file]

*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%	
*0. Set directories.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
clear all
global path "C:\Users\claire.montialoux\Dropbox\GSPP\Courses\Montialoux\Statistics\assignments\problem_sets\ps2\ps2_q3_solutions" // to be adpated to your folder
cd $path

*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%	
*1. Import census and ACS data, adjust for inflation.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
*code for limiting years if pulled an extract with too many years
	use "data/raw/usa_00053.dta", clear
	*tab year
	keep inlist(year,1950,1960,1970,1980,1990,2000,2007,2010,2014,2019)
	saveold "data/raw/usa_00053.dta", replace

*split dataset into 10 percent samples of each year to make processing manageable
	foreach yr in 1950 1960 1970 1980 1990 2000 2007 2010 2014 2019 {
		use "data/raw/usa_00053.dta", clear
		keep if year==`yr'
		sample 10
		tempfile cenacs`yr'
		save "`cenacs`yr''"
	}

*append 10-percent samples of each year into one master dataset
	use `cenacs1950', clear

	foreach yr in 1950 1960 1970 1980 1990 2000 2007 2010 2014 2019 {
		append using "`cenacs`yr''"
		}
	save "data/output/census_acs_1950_2019.dta", replace

*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%	
*2. Generate and prepare variables for analysis.
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
 *use "data/output/census_acs_1950_2019.dta", clear
	*Sampling criteria - limited to ages 25-54
		drop if age < 25 | age > 54

	*Adjust income variables given changing definitions over time 
	*Replace observations with inconsistent wage
		drop if incwage >= 999998
		*replace incbusfm = . if incbusfm == 99999
		replace incbusfm = 0 if incbusfm < 0
		*replace incbus = . if incbus == 999999
		replace incbus = 0 if incbus < 0
		*replace incfarm = . if incfarm == 999999
		replace incfarm = 0 if incfarm < 0
		*replace incbus00 = . if incbus00 == 999999
		replace incbus00 = 0 if incbus00 < 0

	*Adjust income variables given changing definitions over time 
	replace incwage = 1.2 * incwage if ind1950 == 105
	replace incbusfm = 1.4 * incbusfm if ind1950 == 105 & year <= 1960
	replace incbusfm = incbus + 1.4 * incfarm if year >= 1970 & year <= 1990
	replace incbusfm = incbus00 if year >= 2000
	replace incbusfm = 1.4 * incbus00 if year >= 2000 & ind1950 == 105

	*Sum up income
	gen inc = incwage + incbusfm 
	replace inc = incwage if inc == .

	*merge in inflation numbers
	merge m:1 year using "data/raw/cpi_acs.dta"
	keep if inlist(year,1950,1960,1970,1980,1990,2000,2007,2010,2014,2019)
	drop _m

	* adjust to real 2019 dollars
	gen real_earnings = inc * (376.5/CPI_1977)

	*create samples dummies for 3 different figures
		gen sample1=0
		gen sample2=0
		gen sample3=0

		replace sample1 = 1 if sex==1 & real_earnings>1 /*for working men only*/
		replace sample2 = 1 if sex==1 /*all men*/
		replace sample3 = 1 /*all men and women*/

	* log real earnings
	gen logrealearn = log(real_earnings + 1)

	* genrate age controls
		*gen ageg1 = age > 24 & age < 30* Baseline age group
		gen ageg2 = age > 29 & age < 35
		gen ageg3 = age > 34 & age < 40
		gen ageg4 = age > 39 & age < 45
		gen ageg5 = age > 44 & age < 50
		gen ageg6 = age > 49 & age < 55
		drop age

	* racial dummy variables
	gen black = race == 2 & hispan == 0
	gen white = race == 1 & hispan == 0
	gen other = black == 0 & white == 0

	* racial category variable
	gen 	race_string="Other"
	replace race_string="Black" if race==2
	replace race_string="White" if race==1

*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%	
*3. Perform quantile regressions to compute racial earnings level gaps at different percentiles and plot graphs
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%










