#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file plots income share and adjusted income share for each age group
over the years 1976-2017 */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;
drop if age < 18;
drop if incwage < 0 | incwage == .;
drop if topcode == 1;

egen agecat = cut(age), at(18,25,35,45,55,65);
replace agecat = 65 if age >=65;

label define agecatlabel 18 "18-25 year olds" 25 "25-34 year olds"
	35 "35-44 year olds" 45 "45-54 year olds" 55 "55-64 year olds"
	65 "65+";
label values agecat;

////////////////////////////////////////////////////////////////////////////////
* Unadjusted labor income shares by year (incshare);
bysort year agecat: egen incgroup = sum(asecwt*incwage);
by year: egen incyear = sum(asecwt*incwage);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

* Population share by year;
bysort year agecat: egen popgroup = sum(asecwt);
by year: egen popyear = sum(asecwt);
gen popshare = popgroup/popyear;

* Adjustment variables;
gen population 	= asecwt;
gen workers		= asecwt if incwage > 0;
gen hoursly		= asecwt*uhrsworkly;
local adjustments population workers hoursly;
foreach adjustment of local adjustments {;

	* Adjustment factor;
	bysort year agecat: egen groupsum = sum(`adjustment');
	by year: egen yearsum = sum(`adjustment');
	gen groupshare = groupsum/yearsum;
	drop groupsum yearsum;

	* Adjusted labor income share by year (incshare_`adjustment');
	bysort agecat: gen tempshare1976 = groupshare if year == 1976;
	by agecat: egen share1976 = max(tempshare1976);
	bysort year agecat: egen adj_incgroup = 
		sum(asecwt*incwage*share1976/groupshare);
	by year: egen adj_incyear = sum(asecwt*incwage*share1976/groupshare);
	gen incshare_`adjustment' = adj_incgroup/adj_incyear;
	label variable incshare_`adjustment' "Share of Total Labor Income, Adjusted";
	drop tempshare1976 adj_incgroup adj_incyear groupshare share1976;
	
};

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Overlaid plots;
duplicates drop year agecat, force;
foreach i in 18 25 35 45 55 65 {;
	local incplots `incplots' line incshare year if agecat == `i' ||;
	local popplots `popplots' line popshare year if agecat == `i' ||;
	foreach adjustment of local adjustments {;
		local adjplots_`adjustment' `adjplots_`adjustment'' line incshare_`adjustment' year if agecat == `i' ||;
	};
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

* Income share plot, adjusted for population;
graph twoway `adjplots_population', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017)
	xtitle("") ytitle("Earnings Shares, Adjusted by Population")
	legend(region(lcolor(white)));
graph export adjincome_shares_population.png, replace;

* Income share plot, adjusted for working population;
graph twoway `adjplots_workers', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017)
	xtitle("") ytitle("Earnings Shares, Adjusted by Number of Workers")
	legend(region(lcolor(white)));
graph export adjincome_shares_workers.png, replace;

* Income share plot, adjusted for hours worked the previous year;
graph twoway `adjplots_hoursly', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017)
	xtitle("") ytitle("Earnings Shares, Adjusted by Hours Worked")
	legend(region(lcolor(white)));
graph export adjincome_shares_hours.png, replace;


