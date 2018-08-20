#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output/unadjusted;
cap mkdir ${basedir}/stats/output/agedecomp;
cap mkdir ${basedir}/stats/output/chained_adjustments;
cap mkdir ${basedir}/stats/output/alt_chained_adjustments;

/* This do-file plots income share and adjusted income share for each age group
over the years 1976-2017, using chained years */;

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
* Plot unadjusted earnings shares;
preserve;
do ${basedir}/stats/code/chained_important_computations.do;
do ${basedir}/stats/code/chained2_plotunadjusted.do;
restore;

////////////////////////////////////////////////////////////////////////////////
* DECOMPOSE BY AGE GROUP ONLY;
local genders women men;
foreach gend of local genders {;
	preserve;
	global gender `gend';
	if "$gender"=="women" {;
		keep if male==0;
	};
	else if "$gender"=="men" {;
		keep if male==1;
	};
	global adjustvar ;
	do ${basedir}/stats/code/chained_important_computations.do;
	do ${basedir}/stats/code/chained3_agedecomp.do;
	global alt ;
	do ${basedir}/stats/code/chained_table.do;
	restore;
};

////////////////////////////////////////////////////////////////////////////////
* COMPUTE AND PLOT OTHER DECOMPOSITIONS;
* Adjusted by only population shares;
global pooled 0;
local adjustvars 	
	college		
	hours 	
	nonwhite	
	married		
	industry 
	ehrmi
	male;
local adjustlabels	
	College		
	Hours	
	Race		
	Married		
	Industry	
	Educ/Hours/Race/Married/Industry
	Gender;
	
egen ehrmi = group(college hours nonwhite married industry);

forvalues k=1/7 {;
	global adjustvar : word `k' of `adjustvars';
	global adjustlabel : word `k' of `adjustlabels';
	cap mkdir ${basedir}/stats/output/chained_adjustments/${adjustvar};
	cap mkdir ${basedir}/stats/output/alt_chained_adjustments/${adjustvar};
	
	if "$adjustvar"=="gender" {;
		local genders pooled;
	};
	else {;
		local genders women men;
	};
		
	foreach gend of local genders {;
			global gender `gend';

			preserve;
			if "$gender"=="women" {;
				keep if male==0;
			};
			else if "$gender"=="men" {;
				keep if male==1;
			};
			do ${basedir}/stats/code/chained_important_computations.do;
			do ${basedir}/stats/code/chained4_decomp.do;
			global alt;
			do ${basedir}/stats/code/chained_table.do;
			restore;
			
			preserve;
			if "$gender"=="women" {;
				keep if male==0;
			};
			else if "$gender"=="men" {;
				keep if male==1;
			};
			do ${basedir}/stats/code/chained_important_computations.do;
			do ${basedir}/stats/code/chained5_altdecomp.do;
			global alt alt_;
			do ${basedir}/stats/code/chained_table.do;
			restore;
	};
	
};	

