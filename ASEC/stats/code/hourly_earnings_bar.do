#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file computes income shares in 1994 and 2017 for comparison */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;
drop if age < 18;
drop if incwage <= 0 | incwage == .;
keep if year == 1994 | year == 2017;
drop if topcode == 1;

egen agecat = cut(age), at(18,25,55,65);
replace agecat = 65 if age >=65;

label define agecatlabel 18 "18-24 year olds" 25 "25-54 year olds"
	55 "55-64 year olds" 65 "65+";
label values agecat;

drop if uhrsworkt < 10;

////////////////////////////////////////////////////////////////////////////////
gen hourly_earnings = incwage/(50*uhrsworkt);

* CPI-U;
scalar CPI1994 = 147.2;
scalar CPI2017 = 243.801;

gen rhourly_earnings = hourly_earnings;
replace rhourly_earnings = hourly_earnings*CPI2017/CPI1994 if year == 1994;

collapse (median) rhourly_earnings, by(agecat year);
reshape wide rhourly_earnings, i(agecat) j(year);
graph bar rhourly_earnings1994 rhourly_earnings2017, 
	over(agecat,relabel(1 "18-24" 2 "25-54" 3 "55-64" 4 "65+"))
	legend(label(1 "1994") label(2 "2017"))
	ytitle("Median Real Hourly Earnings, 2017 Dollars")
	graphregion(color(white));
graph export ${basedir}/stats/output/hourly_earnings.png, replace;

