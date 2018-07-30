#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file plots income share and adjusted income share for each age group
over the years 1976-2017 */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* SAMPLE SELECTION;
drop if age < 18;
drop if incwage == 0 | incwage == .;

////////////////////////////////////////////////////////////////////////////////
* ADJUSTED LABOR INCOME SHARE;
* Labor income shares by year (incshare);
bysort year agecat: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

* Adjustment variable (asecwt for population, asecwt*uhrsworkly*50 for hours);
gen adjustment = asecwt;

* Population share by year (popshare);
bysort year agecat: egen popgroup = sum(adjustment);
by year: egen popyear = sum(adjustment);
gen popshare = popgroup/popyear;
label variable popshare "Population Share";

* Adjusted labor income share by year (adj_incshare);
gen dpopshare2017 = popshare if year == 2017;
egen popshare2017 = max(dpopshare2017);
drop dpopshare2017;
bysort year agecat: egen adj_incgroup = sum(asecwt*incwage*popshare2017/popshare);
by year: egen adj_incyear = sum(asecwt*incwage*popshare2017/popshare);
gen adj_incshare = adj_incgroup/adj_incyear;
label variable adj_incshare "Share of Total Labor Income, Adjusted";

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Overlaid plots;
duplicates drop year agecat, force;
foreach i in 18 25 35 45 55 65 {;
	local incplots `incplots' line incshare year if agecat == `i' ||;
	local popplots `popplots' line popshare year if agecat == `i' ||;
	local aincplots `aincplots' line adj_incshare year if agecat == `i' ||;
};

local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

* Plots;
sort year;
cd ${basedir}/stats/output;
* Income share plot;
graph twoway `incplots', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017) ylab(0(0.1)0.3)
	xtitle("") xlabel(1976(5)2017)
	legend(region(lcolor(white)));
graph export income_shares.png, replace;

* Population share plot;
graph twoway `popplots', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017) ylab(0(0.1)0.3)
	xtitle("") xlabel(1976(5)2017)
	legend(region(lcolor(white)));
graph export pop_shares.png, replace;

* Adjusted income share plot;
graph twoway `aincplots', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017)
	xtitle("") 
	legend(region(lcolor(white)));
graph export adj_income_shares.png, replace;
