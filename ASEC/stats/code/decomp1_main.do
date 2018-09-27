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

local collabels;
foreach adjustvar of local adjustvars {;
	local collabels `collabels' `adjustvar'_women `adjustvar'_men ; 
};

matrix colnames empty_cats = blank `collabels';
matrix colnames samplesize = blank `collabels';

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
