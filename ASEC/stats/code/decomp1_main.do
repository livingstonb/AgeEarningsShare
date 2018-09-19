#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output/tables;
cap mkdir ${basedir}/stats/output/plot_data;
cap mkdir ${basedir}/stats/output/stata_plots;
cap mkdir ${basedir}/stats/output/empty_cats;

/* This do-file calls decomp2,decomp3,... to compute and plot income share
decompositions over the years 1976-2017 */;

use ${basedir}/build/output/ASEC.dta;

local EXPORT_PYTHON = 0;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;

drop if age < 18;
drop if incwage < 0 | incwage == .;
drop if topcode == 1;

* 6 age categories;
egen agecat = cut(age), at(18,25,35,45,55,65);
replace agecat = 65 if age >=65;
label define agecatlabel 18 "18-25 year olds" 25 "25-34 year olds"
	35 "35-44 year olds" 45 "45-54 year olds" 55 "55-64 year olds"
	65 "65+";
label values agecat agecatlabel;

* 2 age categories;
gen agec2 = 25 if (age>=25) & (age<=54);
replace agec2 = 55 if (age>=55) & (age<.);
label define agecatl2 25 "25-54 year olds" 55 "55+";
label values agec2 agecatl2;

* hours worked;
gen hours = 0 if weeklyhours==0;
replace hours = 1 if weeklyhours>0 & weeklyhours<=10;
replace hours = 2 if weeklyhours>10 & weeklyhours<=35;
replace hours = 3 if weeklyhours>35 & weeklyhours<=45;
replace hours = 4 if weeklyhours>45 & weeklyhours<=.;

* year pooling;
gen yr5 = .;
local icount = 1;
forvalues i = 1976(5)2016 {;
	replace yr5 = `icount' if (year>=`i') &(year<`i'+5);
	local icount = `icount' + 1;
};

if `EXPORT_PYTHON'==1 {;
keep year agecat age incwage hours sex college married services nonwhite asecwt
	industry;
outsheet using ${basedir}/build/output/ASEC.csv, comma nolabel replace;
assert 0;
};

* Create variables;
egen ems = group(college married services);
* Variable of 1's, to do age-only decomposition;
gen ones = 1;

foreach var of varlist college hours ems {;
	drop if `var' == .;
};

////////////////////////////////////////////////////////////////////////////////
* SET PLOT FORMAT;
global plot_options 
		legend(cols(1))
		graphregion(color(white)) xlabel(1976(10)2017)
		xtitle("") ytitle("")
		legend(region(lcolor(white)))
		bgcolor(white)
		legend(span)
		xsize(3)
		ysize(3.5)
		scale(1.4);

global linethickness thick;
global line1 lwidth(${linethickness}) lpattern(solid);
global line2 lwidth(${linethickness}) lpattern(longdash);
global line3 lwidth(${linethickness}) lpattern(dash);
global line4 lwidth(${linethickness}) lpattern("-#-#");
global line5 lwidth(${linethickness}) lpattern("-####-####");
global line6 lwidth(${linethickness}) lpattern(shortdash);

////////////////////////////////////////////////////////////////////////////////
* Plot unadjusted earnings shares;
if 0 {;
global timevar year;
global agevar agecat;
local genders women men;
foreach gend of local genders {;
	* Set gender for computations;
	global gender `gend';
	
	preserve;
	* Compute unadjusted shares and mean earnings;
	do ${basedir}/stats/code/decomp_important_computations.do;
	* Make plots;
	do ${basedir}/stats/code/decomp2_plotunadjusted.do;
	restore;
};
};
////////////////////////////////////////////////////////////////////////////////
* COMPUTE AND PLOT OTHER DECOMPOSITIONS;
* Declare time variable and age category variable;
global timevar year;
global agevar agecat;
* Reset xlabel for plots if necessary;
if "$timevar"=="yr5" {;
global plot_options 
		legend(cols(1))
		graphregion(color(white)) xlabel(1(1)9)
		xtitle("") ytitle("")
		legend(region(lcolor(white)))
		bgcolor(white)
		legend(span)
		xsize(3)
		ysize(3.5)
		scale(1.4);
};

* Z-variables (to decompose by in addition to age shares of population);
local adjustvars 
	ones
	college
	hours
	ems;
local adjustlabels
	Age
	Education
	Hours
	Educ/Mar/Services;
	
* Initialize matrices to store sample sizes;
matrix empty_cats = .\.;
matrix samplesize= .;

* Loop over Z-variables;
forvalues k=1/4 {;
	global adjustvar : word `k' of `adjustvars';
	global adjustlabel : word `k' of `adjustlabels';

	cap mkdir ${basedir}/stats/output/stata_plots/${adjustvar};
	cap mkdir ${basedir}/stats/output/tables/${adjustvar};
	
	* If adjusting by gender, pool male and female observations;
	if "$adjustvar"=="male" {;
		local genders pooled;
	};
	else {;
		local genders women men;
	};
	
	* Loop over men and women;
	foreach gend of local genders {;
		* Select gender;
		global gender `gend';
			
		preserve;
		* Compute unadjusted shares and mean earnings;
		do ${basedir}/stats/code/decomp_important_computations.do;
		* Compute other variables and perform decomposition;
		do ${basedir}/stats/code/decomp3_Zvar.do;
		* Save decomposition as a spreadsheet;
		do ${basedir}/stats/code/decomp_table.do;
		restore;
			
			
	};
	
};	

* Export matrix of # of empty categories per Z-variable;
clear;

local collabels blank;
foreach adjustvar of local adjustvars {;
	local collabels `collabels' `adjustvar'_women `adjustvar'_men ; 
};

matrix colnames empty_cats = `collabels';
matrix colnames samplesize = `collabels';

svmat empty_cats, names(col);
drop blank;
gen quantity = "Num empty" if _n==1;
replace quantity = "Num total" if _n==2;
order quantity;
outsheet using ${basedir}/stats/output/empty_cats.csv, comma replace;

clear;
svmat samplesize, names(col);
drop blank;
gen quantity = "N";
order quantity;
outsheet using ${basedir}/stats/output/samplesize.csv, comma replace;
