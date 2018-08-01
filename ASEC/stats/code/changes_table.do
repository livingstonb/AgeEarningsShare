#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file computes income shares in 1976 and 2017 for comparison */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;
drop if age < 18;
drop if incwage == 0 | incwage == .;
keep if year == 1976 | year == 2017;
drop if topcode == 1;

egen agecat = cut(age), at(18,25,55,65);
replace agecat = 65 if age >=65;

label define agecatlabel 18 "18-24 year olds" 25 "25-54 year olds"
	55 "55-64 year olds" 65 "65+";
label values agecat;


////////////////////////////////////////////////////////////////////////////////
* EDUCATION TABLE;
preserve;
* Labor income shares by year and education group (incshare);
bysort year agecat college: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

duplicates drop year agecat college, force;
keep year agecat college incshare;
drop if agecat==0 | agecat==55;

gen COLLEGESTR = "EDUC" if college == 1;
replace COLLEGESTR = "UNED" if college == 0;
drop college;
					
reshape wide incshare, i(year agecat) j(COLLEGESTR) string;
foreach var of varlist incshare* {;
	rename `var' `var'y;
};
reshape wide incshare*, i(year) j(agecat);

save ${basedir}/stats/output/education_table.dta, replace;
restore;

////////////////////////////////////////////////////////////////////////////////
* GENDER TABLE;
preserve;
* Labor income shares by year and gender (incshare);
bysort year agecat male: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

duplicates drop year agecat male, force;
keep year agecat male incshare;
drop if agecat==0 | agecat==55;

gen MALESTR = "MALE" if male == 1;
replace MALESTR = "FEML" if male == 0;
drop male;

reshape wide incshare, i(year agecat) j(MALESTR) string;
foreach var of varlist incshare* {;
	rename `var' `var'y;
};
reshape wide incshare*, i(year) j(agecat);

save ${basedir}/stats/output/gender_table.dta, replace;
restore;

////////////////////////////////////////////////////////////////////////////////
* DISPLAY IN COMMAND WINDOW;
use ${basedir}/stats/output/education_table, clear;
li incshare????y25, clean noobs ab(30);
li incshare????y65, clean noobs ab(30);

use ${basedir}/stats/output/gender_table, clear;
li incshare????y25, clean noobs ab(30);
li incshare????y65, clean noobs ab(30);
