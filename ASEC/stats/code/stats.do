#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* SAMPLE SELECTION;
drop if age < 18;
drop if incwage == 0 | incwage == .;
drop if uhrsworkly == 0 | uhrsworkly == .;
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
gen adj_incshare = incshare*popshare2017/popshare;
label variable adj_incshare "Share of Total Labor Income, Adjusted";

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Overlaid plots;
scalar plots1 = 1;
if plots1==1 {;
	preserve;
    duplicates drop year agecat, force;
	* collapse (mean) incshare popshare adj_incshare, by(year agecat);
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
		graphregion(color(white)) xlabel(1976(5)2017) ylab(0(0.1)0.3)
		xtitle("") xlabel(1976(5)2017)
		legend(region(lcolor(white)));
	graph export income_shares.png, replace;
	graph twoway `popplots', legend(order(`ages')) 
		graphregion(color(white)) xlabel(1976(5)2017) ylab(0(0.1)0.3)
		xtitle("") xlabel(1976(5)2017)
		legend(region(lcolor(white)));
	graph export pop_shares.png, replace;
	graph twoway `aincplots', legend(order(`ages')) 
		graphregion(color(white)) xlabel(1976(5)2017) ylab(0(0.1)0.3)
		xtitle("") 
		legend(region(lcolor(white)));
	graph export adj_income_shares.png, replace;
	restore;
};
////////////////////////////////////////////////////////////////////////////////
* Bar charts;
* Group by year range and have separate bars for age groups;
scalar plots2 = 1;
if plots2==1 {;
	gen yearcat = 1 if year>=1976 & year<=1981;
	replace yearcat = 2 if year>=2012 & year<=2017;
	drop if yearcat==.;
	label define yearcatlabel 1 "1976-1981" 2 "2012-2017";
	label values yearcat yearcatlabel;

	keep yearcat agecat adj_incshare;
	duplicates drop yearcat agecat, force;
	reshape wide adj_incshare, i(yearcat) j(agecat);
	graph bar adj_incshare55 adj_incshare65, over(yearcat) graphregion(color(white))
		legend(label(1 "Ages 55-64") label(2 "Ages 65+"))
		ytitle("Adjusted Share of Earnings");
	cd ${basedir}/stats/output;
	graph export bar.png, replace;
};
////////////////////////////////////////////////////////////////////////////////
* REGRESSION;
scalar reg1 = 0;
if reg1==1 {;
	gen married = 1 if marst==1 | marst==2;
	replace married = 0 if inlist(marst,3,4,5,6,7);
	bysort age year: egen marriedm = mean(married);
	gen sexd = 1 if sex == 1;
	replace sexd = 0 if sex == 2;
	by age year: egen sexdm = mean(sexd);
	gen white = 0;
	replace white = 1 if race == 100;
	by age year: egen whitem = mean(white);
	gen agesq = age^2;
	duplicates drop age year, force;
	gen college = educ >= 110 & educ < .;
	by age year: egen collegem = mean(college);
	gen ageXyear = age*year;
	reg incshare marriedm sexdm whitem collegem year age agesq ageXyear [aw=asecwt];
};
