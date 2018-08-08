#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file plots income share and adjusted income share for each age group
over the years 1976-2017, using chained years */;

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
* ADJUSTING FOR CHANGES IN POPULATION SHARE, CHAINED;
* Population shares;
bysort year agecat: egen 	popjt 		= sum(asecwt);
by year:			egen 	popt		= sum(asecwt);
gen popsharejt 	= popjt/popt;

* Ratio of mean group earnings to mean population earnings;
by year agecat:		egen	earnjt		= sum(asecwt*incwage);
gen mearnjt	= earnjt/popjt;
by year:			egen	earnt		= sum(asecwt*incwage);
gen	mearnt = earnt/popt;
gen	mearnsharejt = mearnjt/mearnt;
* Unadjusted earnings share;
gen unadj_earnshare = earnjt/earnt;

duplicates drop agecat year, force;

* Adjusted earnings share for 1976 = unadjusted earnings share for 1976;
gen adjearnshare_population = unadj_earnshare if year == 1976;
bysort agecat (year): gen adjearnshare_p0 = adjearnshare_population[1];

tsset agecat year;
gen 	sumterms = L.popsharejt*D.mearnsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
replace	adjearnshare_population = adjearnshare_p0 + sumvar if year > 1976;

* Plot;
local adjustments population;
* Overlaid plots;
foreach i in 18 25 35 45 55 65 {;
	foreach adjustment of local adjustments {;
		local adjplots_`adjustment' `adjplots_`adjustment'' line adjearnshare_`adjustment' year if agecat == `i' ||;
	};
};

local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

* Income share plot, adjusted for population;
graph twoway `adjplots_population', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017)
	xtitle("") ytitle("Earnings Shares, Adjusted by Population")
	legend(region(lcolor(white)))
	bgcolor(white)
	legend(span)
	aspectratio(1)
	xsize(3.5);
cd ${basedir}/stats/output;
graph export adjincome_shares_population_chained.png, replace;
