#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* SAMPLE SELECTION;
drop if age < 18;
drop if incwage == 0 | incwage == .;
keep if year == 1976 | year == 2017;
* drop if uhrsworkly == 0 | uhrsworkly == .;
////////////////////////////////////////////////////////////////////////////////
* ADJUSTED LABOR INCOME SHARE;
* Labor income shares by year (incshare);
bysort year agecbroad college: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

* Adjustment variable (asecwt for population, asecwt*uhrsworkly*50 for hours);
gen adjustment = asecwt;

* Population share by year (popshare);
bysort year agecbroad college: egen popgroup = sum(adjustment);
by year: egen popyear = sum(adjustment);
gen popshare = popgroup/popyear;
label variable popshare "Population Share";

* Adjusted labor income share by year (adj_incshare);
gen dpopshare2017 = popshare if year == 2017;
egen popshare2017 = max(dpopshare2017);
drop dpopshare2017;
bysort year agecbroad college: egen adj_incgroup = sum(asecwt*incwage*popshare2017/popshare);
by year: egen adj_incyear = sum(asecwt*incwage*popshare2017/popshare);
gen adj_incshare = adj_incgroup/adj_incyear;
label variable adj_incshare "Share of Total Labor Income, Adjusted";

////////////////////////////////////////////////////////////////////////////////
* CREATE TABLE;
duplicates drop year agecbroad college, force;
keep year agecbroad college adj_incshare;
drop if agecbroad==0 | agecbroad==55;

gen COLLEGESTR = "EDUC" if college == 1;
replace COLLEGESTR = "UNED" if college == 0;
drop college;
					
reshape wide adj_incshare, i(year agecbroad) j(COLLEGESTR) string;
foreach var of varlist adj* {;
	rename `var' `var'y;
};
reshape wide adj*, i(year) j(agecbroad);

li adj_incshare????y25, clean noobs ab(30);
li adj_incshare????y65, clean noobs ab(30);
li adj_incshare????y75, clean noobs ab(30);
