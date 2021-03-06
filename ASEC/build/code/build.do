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
replace industry = -1 if empstat>=20;

* service industry;
gen services = .;
replace services = 1 if (industry>=5) & (industry<.);
* agriculture, forestry, and fisheries, mining, construction, manufacturing;
replace services = 0 if (industry>=1) & (industry<5);
* unemployed workers;
replace services = -1 if industry == -1;

gen totalhours = uhrsworkly*wkswork1;
gen weeklyhours = totalhours/52;

////////////////////////////////////////////////////////////////////////////////
* MORE CLEANING;

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


* Create variables;
egen ems = group(college married services);
* Variable of 1's, to do age-only decomposition;
gen ones = 1;

foreach var of varlist college hours ems {;
	drop if `var' == .;
};

save ${basedir}/build/output/ASEC.dta, replace;
