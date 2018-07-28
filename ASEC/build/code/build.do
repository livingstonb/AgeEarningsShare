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
replace uhrsworkly = . if inlist(uhrsworkly,999);
replace race = . if race == 999;

////////////////////////////////////////////////////////////////////////////////
* GENERATE NEW VARIABLES;
egen agecat = cut(age), at(18,25,35,45,55,65);
replace agecat = 65 if age >=65;

label define agecatlabel 18 "18-25 year olds" 25 "25-34 year olds"
	35 "35-44 year olds" 45 "45-54 year olds" 55 "55-64 year olds"
	65 "65+";
label values agecat;

gen agecatbroad = 25 if age>=25 & age<=54;
replace agecatbroad = 65 if age>=65 & age<=74;
replace agecatbroad = 75 if age>=75 & age<.;

gen male = 1 if sex == 1;
replace male = 0 if sex == 2;

gen nonwhite = 1 if race!=100 & race!=.;
replace nonwhite = 0 if race==100;

save ${basedir}/build/output/ASEC.dta, replace;
