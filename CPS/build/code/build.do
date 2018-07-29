#delimit;
set more 1;
cap mkdir ${basedir}/build/output;


////////////////////////////////////////////////////////////////////////////////
* CLEAN DATA;
* Read IPUMS data;
use ${basedir}/build/input/cps.dta, clear;

* Code missing values;
replace educ = .	if educ == 999;
replace	uhrsworkt = . if inlist(uhrsworkt,997,999);
replace race = . if race == 999;

////////////////////////////////////////////////////////////////////////////////
* DROP ARMED FORCES;
drop if classwkr == 26;

////////////////////////////////////////////////////////////////////////////////
* GENERATE NEW VARIABLES;
egen agecat = cut(age), at(18,25,55,65,75);
replace agecat = 75 if age >=75;
drop if agecat == .;

label define agecatlabel 18 "18-25 year olds" 25 "25-54 year olds"
	66 "55-64” 65 "65-74" 75 "75+";
label values agecat agecatlabel;

gen laborforce = 1 if labforce == 2;
replace laborforce = 0 if labforce == 1;

gen bachelors = 1 if (educ>=110) & (educ<.);
replace bachelors = 0 if (educ>=2) & (educ<110);

gen male = 1 if sex == 1;
replace male = 0 if sex == 2;

gen nonwhite = 1 if (race!=100) & (race!=.);
replace nonwhite = 0 if race==100;

////////////////////////////////////////////////////////////////////////////////
* COLLAPSE TO MONTH AND YEAR;

collapse (mean) laborforce bachelors uhrsworkt male nonwhite [aw=wtfinl], by(year agecat);
save ${basedir}/build/output/cps_yearly.dta, replace;

