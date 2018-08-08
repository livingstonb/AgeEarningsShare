#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output/chained_adjustments;
cap mkdir ${basedir}/stats/output/chained_adjustments/college;

/* This do-file plots income share and adjusted income share for each age group
over the years 1976-2017, using chained years */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;
drop if age < 18;
drop if incwage < 0 | incwage == .;
drop if topcode == 1;

* Which gender (men/women/both);
global gender = "men";
if "$gender"=="men" {;
	keep if male == 1;
};
else if "$gender"=="women" {;
	keep if male == 0;
};

egen agecat = cut(age), at(18,25,35,45,55,65);
replace agecat = 65 if age >=65;

label define agecatlabel 18 "18-25 year olds" 25 "25-34 year olds"
	35 "35-44 year olds" 45 "45-54 year olds" 55 "55-64 year olds"
	65 "65+";
label values agecat agecatlabel;

////////////////////////////////////////////////////////////////////////////////
* COMPUTE POPULATION SHARES, AND UNADJUSTED STATISTICS;
* Population shares;
bysort year agecat: egen popjt = sum(asecwt);
by year: 			egen popt = sum(asecwt);
gen popsharejt 	= popjt/popt;

* Unadjusted earnings share for 1976;
bysort year agecat:	egen earnjt	= sum(asecwt*incwage);
by year: egen earnt = sum(asecwt*incwage);
gen unadj_earnshare = earnjt/earnt;
bysort agecat (year): gen earnshare_1976 = unadj_earnshare[1];

////////////////////////////////////////////////////////////////////////////////
* COMPUTE AND PLOT ADJUSTED STATISTICS;
preserve;
do ${basedir}/stats/code/chained_incshares2.do;
restore;

preserve;
do ${basedir}/stats/code/chained_incshares3.do;
restore;
