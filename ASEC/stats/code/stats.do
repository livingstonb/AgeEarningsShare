#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* SAMPLE SELECTION;
* keep if educ>=111 & educ <.;
drop if age < 18;
* drop if incwage == 0 | incwage == .;
drop if hours == 0 | hours == .;
////////////////////////////////////////////////////////////////////////////////
* ADJUSTED LABOR INCOME SHARE;
* Labor income shares by year (incshare);
bysort year agecat: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

* Adjustment variable (asecwt for population, asecwt*hours*52 for hours);
gen adjustment = asecwt*hours*50;

* Population share by year (popshare);
bysort year agecat: egen popgroup = sum(adjustment) if incwage;
by year: egen popyear = sum(adjustment) if incwage;
gen popshare = popgroup/popyear if incwage;
label variable popshare "Population Share";

* Adjusted labor income share by year (adj_incshare);
gen dpopshare2017 = popshare if year == 2017;
egen popshare2017 = max(dpopshare2017);
drop dpopshare2017;
gen adj_incshare = incshare*popshare2017/popshare;
label variable adj_incshare "Share of Total Labor Income, Adjusted";

////////////////////////////////////////////////////////////////////////////////
* PLOTS;
* Overlaid plots;
collapse (mean) incshare popshare adj_incshare, by(year agecat);
foreach i in 18 25 35 45 55 65 {;
	local incplots `incplots' line incshare year if agecat == `i' ||;
	local popplots `popplots' line popshare year if agecat == `i' ||;
	local aincplots `aincplots' line adj_incshare year if agecat == `i' ||;
};

local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

* Plots;
sort year;
cd ${basedir}/stats/output;
graph twoway `incplots', legend(order(`ages')) 
	graphregion(color(white)) xlab(1980(10)2010) ylab(0(0.1)0.3);
graph export income_shares.png, replace;
graph twoway `popplots', legend(order(`ages')) 
	graphregion(color(white)) xlab(1980(10)2010) ylab(0(0.1)0.3);
graph export pop_shares.png, replace;
graph twoway `aincplots', legend(order(`ages')) 
	graphregion(color(white)) xlab(1980(10)2010) ylab(0(0.1)0.3);
graph export adj_income_shares.png, replace;

