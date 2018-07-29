#delimit;
set more 1;
cap mkdir ${basedir}/stats/output;


////////////////////////////////////////////////////////////////////////////////
use ${basedir}/build/output/PSID.dta, clear;

* Create new observations for spouses;
expand 2 if (agew<.) | (wwage>0 & wwage<.), gen(newobs);
gen labinc = hwage if newobs == 0;
replace labinc = wwage if newobs == 1;

////////////////////////////////////////////////////////////////////////////////
* SAMPLE SELECTION;
drop if age < 18 | agecat==.;
drop if labinc == 0 | labinc == .;

////////////////////////////////////////////////////////////////////////////////
* Labor income shares by year (incshare);
bysort year agecat: egen incgroup = sum(wgt*labinc);
by year: egen incyear = sum(wgt*labinc);
gen incshare = incgroup/incyear;
label variable incshare "Share of Total Labor Income";

* Adjustment variable;
gen adjustment = wgt;

* Population share by year (popshare);
bysort year agecat: egen popgroup = sum(adjustment);
by year: egen popyear = sum(adjustment);
gen popshare = popgroup/popyear;
label variable popshare "Population Share";

* Adjusted labor income share by year (adj_incshare);
gen dpopshare2015 = popshare if year == 2015;
egen popshare2015 = max(dpopshare2015);
drop dpopshare2015;
bysort year agecat: egen adj_incgroup = sum(wgt*labinc*popshare2015/popshare);
by year: egen adj_incyear = sum(wgt*labinc*popshare2015/popshare);
gen adj_incshare = adj_incgroup/adj_incyear;
label variable adj_incshare "Share of Total Labor Income, Adjusted";

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Overlaid plots;
scalar plots1 = 1;
if plots1==1 {;
	preserve;
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
		graphregion(color(white)) xlabel(1976(5)2017)
		xtitle("") 
		legend(region(lcolor(white)));
	graph export adj_income_shares.png, replace;
	restore;
};
