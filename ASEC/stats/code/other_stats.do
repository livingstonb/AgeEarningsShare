#delimit;
set more 1;

use ${basedir}/build/output/ASEC.dta, clear;

keep if (year==1976) | (year==2017);
scalar cpi1976 = 56.933;
scalar cpi2017 = 245.139;

gen rincwage2017 = incwage;
replace rincwage2017 = incwage*cpi2017/cpi1976 if year == 1976;
bysort year: egen ryearly_earnings = sum(rincwage*asecwt);

duplicates drop year, force;

gen rearnings_growth = (ryearly_earnings[2] - ryearly_earnings[1])
	/ryearly_earnings[1] if year==2017;
keep year ryearly_earnings rearnings_growth;
