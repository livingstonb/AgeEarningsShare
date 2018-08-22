#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output/unadjusted;
cap mkdir ${basedir}/stats/output/agedecomp;
cap mkdir ${basedir}/stats/output/alt_agedecomp;
cap mkdir ${basedir}/stats/output/chained_adjustments;
cap mkdir ${basedir}/stats/output/alt_chained_adjustments;
cap mkdir ${basedir}/stats/output/tables;
cap mkdir ${basedir}/stats/output/tables/chained_adjustments;
cap mkdir ${basedir}/stats/output/tables/alt_chained_adjustments;
cap mkdir ${basedir}/stats/output/plot_data;

/* This do-file calls chained2,chained3,... to compute and plot income share
decompositions over the years 1976-2017 */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;
drop if age < 18;
drop if incwage < 0 | incwage == .;
drop if topcode == 1;

egen agecat = cut(age), at(18,25,35,45,55,65);
replace agecat = 65 if age >=65;

label define agecatlabel 18 "18-25 year olds" 25 "25-34 year olds"
	35 "35-44 year olds" 45 "45-54 year olds" 55 "55-64 year olds"
	65 "65+";
label values agecat agecatlabel;

gen hours = 0 if weeklyhours==0;
replace hours = 1 if weeklyhours>0 & weeklyhours<=10;
replace hours = 2 if weeklyhours>10 & weeklyhours<=35;
replace hours = 3 if weeklyhours>35 & weeklyhours<=45;
replace hours = 4 if weeklyhours>45 & weeklyhours<=60;
replace hours = 5 if weeklyhours>60 & weeklyhours<.;

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
local genders women men;
foreach gend of local genders {;

	* Set gender for computations;
	global gender `gend';
	
	preserve;
	do ${basedir}/stats/code/chained_important_computations.do;
	do ${basedir}/stats/code/chained2_plotunadjusted.do;
	restore;
};


////////////////////////////////////////////////////////////////////////////////
* DECOMPOSE BY AGE GROUP ONLY;
local genders women men;
foreach gend of local genders {;
	global gender `gend';
	global adjustvar ;
	
	preserve;
	do ${basedir}/stats/code/chained_important_computations.do;
	do ${basedir}/stats/code/chained3_agedecomp.do;
	do ${basedir}/stats/code/chained_table.do;
	restore;
	
	preserve;
	do ${basedir}/stats/code/chained_important_computations.do;
	do ${basedir}/stats/code/chained4_altagedecomp.do;
	do ${basedir}/stats/code/chained_table.do;
	restore;
};

////////////////////////////////////////////////////////////////////////////////
* COMPUTE AND PLOT OTHER DECOMPOSITIONS;
* Adjusted by only population shares;
* ehrmi = education/hours/race/married/industry;
* erms = education/race/married/service sector;

local adjustvars 	
	college		
	hours 	
	nonwhite	
	married		
	industry 
	ehrmi
	services
	erms
	male;
local adjustlabels	
	College		
	Hours	
	Race		
	Married		
	Industry	
	Ed/Hr/Race/Mar/Ind
	Services
	Educ/Race/Mar/Serv
	Gender;
	
egen ehrmi = group(college hours nonwhite married industry);
egen erms = group(college nonwhite married services);

forvalues k=1/7 {;
	global adjustvar : word `k' of `adjustvars';
	global adjustlabel : word `k' of `adjustlabels';

	cap mkdir ${basedir}/stats/output/chained_adjustments/${adjustvar};
	cap mkdir ${basedir}/stats/output/alt_chained_adjustments/${adjustvar};
	
	if "$adjustvar"=="male" {;
		local genders pooled;
	};
	else {;
		local genders women men;
	};
	
	* Loop over men and women unless decomposing by gender (in which case, pool);
	foreach gend of local genders {;
			global gender `gend';
			
			* 3-component decomposition;
			preserve;
			do ${basedir}/stats/code/chained_important_computations.do;
			do ${basedir}/stats/code/chained5_decomp.do;
			do ${basedir}/stats/code/chained_table.do;
			restore;
			
			* alternate, 4-component decomposition;
			preserve;
			do ${basedir}/stats/code/chained_important_computations.do;
			do ${basedir}/stats/code/chained6_altdecomp.do;
			do ${basedir}/stats/code/chained_table.do;
			restore;
	};
	
};	

