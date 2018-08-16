#delimit;
clear;
set more 1;
cap mkdir ${basedir}/build/output;

/* This is the main do-file for the ASEC age-earnings share project */;

////////////////////////////////////////////////////////////////////////////////
* CLEAN DATA;
* Read IPUMS data;
use ${basedir}/build/input/cps.dta;

* Use only the ASEC data;
keep if asecflag == 1;

* Drop armed forces;
drop if empstat == 1;

* Discard redesigned 3/8th survey data from 2014;
drop if hflag == 1;

* Code missing values;
replace incwage = . if incwage == 9999998 | incwage == 9999999;
replace educ = .	if inlist(educ,1,999);
replace	uhrsworkt = . if inlist(uhrsworkt,997,999);
replace uhrsworkly = 0 if wkswork1 == 0;
replace race = . if race == 999;
replace marst = . if marst == 9;

////////////////////////////////////////////////////////////////////////////////
* TOP-CODING;
gen topcode = 0;
replace topcode = 1 if (incwage==50000) & (year>=1968) & (year<=1981);
replace topcode = 1 if (incwage==75000) & (year>=1982) & (year<=1984);
replace topcode = 1 if (incwage==99999) & (year>=1985) & (year<=1987);
replace topcode = 1 if (incwage==199998) & (year>=1988) & (year<=1995);

////////////////////////////////////////////////////////////////////////////////
* GENERATE NEW VARIABLES;

gen male = 1 if sex == 1;
replace male = 0 if sex == 2;

gen nonwhite = 1 if race!=100 & race!=.;
replace nonwhite = 0 if race==100;

gen college = 1 if educ >= 110 & educ<.;
replace college = 0 if educ < 110;

gen married = 1 if inlist(marst,1,2);
replace married = 0 if inlist(marst,3,4,5,6,7);

gen industry = .;
replace industry = 1 if ind90ly>=10 & ind90ly<=32;
replace industry = 2 if ind90ly>=40 & ind90ly<=50;
replace industry = 3 if ind90ly==60;
replace industry = 4 if ind90ly>=100 & ind90ly<=392;
replace industry = 5 if ind90ly>=400 & ind90ly<=571;
replace industry = 6 if ind90ly>=580 & ind90ly<=691;
replace industry = 7 if ind90ly>=700 & ind90ly<=712;
replace industry = 8 if ind90ly>=721 & ind90ly<=760;
replace industry = 9 if ind90ly>=761 & ind90ly<=791;
replace industry = 10 if ind90ly>=800 & ind90ly<=810;
replace industry = 11 if ind90ly>=812 & ind90ly<=893;
replace industry = 12 if ind90ly>=900 & ind90ly<=932;
replace industry = 0 if industry == .; /* unemployed workers */;

gen totalhours = uhrsworkly*wkswork1;
gen weeklyhours = totalhours/52;

save ${basedir}/build/output/ASEC.dta, replace;
