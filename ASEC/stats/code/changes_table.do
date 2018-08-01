#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file computes income shares in 1976 and 2017 for comparison */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* SAMPLE SELECTION;
drop if age < 18;
drop if incwage == 0 | incwage == .;
keep if year == 1976 | year == 2017;

////////////////////////////////////////////////////////////////////////////////
* EDUCATION TABLE;
preserve;
* Labor income shares by year and education group (incshare);
bysort year agecbroad college: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

duplicates drop year agecbroad college, force;
keep year agecbroad college incshare;
drop if agecbroad==0 | agecbroad==55;

gen COLLEGESTR = "EDUC" if college == 1;
replace COLLEGESTR = "UNED" if college == 0;
drop college;
					
reshape wide incshare, i(year agecbroad) j(COLLEGESTR) string;
foreach var of varlist incshare* {;
	rename `var' `var'y;
};
reshape wide incshare*, i(year) j(agecbroad);

save ${basedir}/stats/output/education_table.dta, replace;
restore;

////////////////////////////////////////////////////////////////////////////////
* GENDER TABLE;
preserve;
* Labor income shares by year and gender (incshare);
bysort year agecbroad male: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

duplicates drop year agecbroad male, force;
keep year agecbroad male incshare;
drop if agecbroad==0 | agecbroad==55;

gen MALESTR = "MALE" if male == 1;
replace MALESTR = "FEML" if male == 0;
drop male;

reshape wide incshare, i(year agecbroad) j(MALESTR) string;
foreach var of varlist incshare* {;
	rename `var' `var'y;
};
reshape wide incshare*, i(year) j(agecbroad);

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
