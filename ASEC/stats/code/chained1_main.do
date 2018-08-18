#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output/unadjusted;
cap mkdir ${basedir}/stats/output/agedecomp;
cap mkdir ${basedir}/stats/output/chained_adjustments;
cap mkdir ${basedir}/stats/output/chained_adjustments/college;
cap mkdir ${basedir}/stats/output/chained_adjustments/hours;
cap mkdir ${basedir}/stats/output/chained_adjustments/nonwhite;
cap mkdir ${basedir}/stats/output/chained_adjustments/male;
cap mkdir ${basedir}/stats/output/chained_adjustments/married;
cap mkdir ${basedir}/stats/output/chained_adjustments/industry;
cap mkdir ${basedir}/stats/output/chained_adjustments/ehrmi;


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
* UNADJUSTED  SHARES AND IMPORTANT STATISTICS;
* Population shares;
bysort year agecat male: 	egen popjt = sum(asecwt);
by year: 					egen popt = sum(asecwt);
gen popsharejt = popjt/popt;
bysort agecat male (year): 	gen popshare_1976 = popsharejt[1];

* Unadjusted earnings share for 1976;
bysort year agecat male: 	egen earnjt = sum(asecwt*incwage);
by year: 					egen earnt = sum(asecwt*incwage);
gen uearnshare = earnjt/earnt;
bysort agecat male (year): 	gen earnshare_1976 = uearnshare[1];

* Ratio of mean group earnings to mean population earnings;
gen mearnjt	= earnjt/popjt;
gen	mearnt = earnt/popt;
gen	mearnsharejt = mearnjt/mearnt;
assert 0;

* Plot unadjusted earnings shares;
preserve;
do ${basedir}/stats/code/chained2_plotunadjusted.do;
restore;

////////////////////////////////////////////////////////////////////////////////
* DECOMPOSE BY AGE GROUP ONLY;
preserve;
do ${basedir}/stats/code/chained3_agedecomp.do;
restore;

////////////////////////////////////////////////////////////////////////////////
* COMPUTE AND PLOT OTHER DECOMPOSITIONS;
* Adjusted by only population shares;
local genders men women;
foreach gend of local genders {;
	global gender `gend';

	* Adjusted by population shares and education;
	preserve;
	global adjustvar college;
	global adjustlabel Education;
	do ${basedir}/stats/code/chained4_decomp.do;
	restore;

	* Adjusted by population shares and weekly hours worked last year;
	preserve;
	global adjustvar hours;
	global adjustlabel Hours;
	do ${basedir}/stats/code/chained4_decomp.do;
	restore;

	* Adjusted by population shares and race;
	preserve;
	global adjustvar nonwhite;
	global adjustlabel Race;
	do ${basedir}/stats/code/chained4_decomp.do;
	restore;

	* Adjusted by population shares and marital status;
	preserve;
	global adjustvar married;
	global adjustlabel "Marital Status";
	do ${basedir}/stats/code/chained4_decomp.do;
	restore;

	* Adjusted by population shares and industry;
	preserve;
	global adjustvar industry;
	global adjustlabel Industry;
	do ${basedir}/stats/code/chained4_decomp.do;
	restore;

	* Decomposition by age and education/hours/race/marital status/industry;
	preserve;
	egen ehrmi = group(college hours nonwhite married industry);
	global adjustvar ehrmi;
	global adjustlabel "Educ/Hours/Race/Married/Industry";
	do ${basedir}/stats/code/chained4_decomp.do;
	restore;
};	

* Adjusted by population shares and gender;
global gender both;
preserve;
global adjustvar male;
global adjustlabel Gender;
do ${basedir}/stats/code/chained4_decomp.do;
restore;
