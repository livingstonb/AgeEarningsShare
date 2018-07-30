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
* ADJUSTED LABOR INCOME SHARE;
* Labor income shares by year (incshare);
bysort year agecbroad college: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

////////////////////////////////////////////////////////////////////////////////
* CREATE TABLE;
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

* Display in command window;
li incshare????y25, clean noobs ab(30);
li incshare????y65, clean noobs ab(30);
