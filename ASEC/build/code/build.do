#delimit;
clear;
set more 1;
cap mkdir ${basedir}/build/output;

global basedir /Users/Brian/Documents/GitHub/AgeEarningsShare/ASEC;

////////////////////////////////////////////////////////////////////////////////
* CLEAN DATA;
* Read IPUMS data;
use ${basedir}/build/input/cps.dta;

* Use only the ASEC data;
keep if asecflag == 1;

* Discard redesigned 3/8th survey data from 2014;
drop if hflag == 1;

* Code missing values;
replace incwage = . if incwage == 9999998 | incwage == 9999999;
replace educ = .	if educ == 999;
replace	uhrsworkt = . if inlist(uhrsworkt,997,999);

////////////////////////////////////////////////////////////////////////////////
* GENERATE NEW VARIABLES;
rename uhrsworkt hours;
egen agecat = cut(age), at(18,25,35,45,55,65);
replace agecat = 65 if age >=65;


save ${basedir}/build/output/ASEC.dta, replace;
