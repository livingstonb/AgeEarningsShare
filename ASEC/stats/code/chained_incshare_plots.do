#delimit;
clear;
set more 1;
cap mkdir ${basedir}/stats/output/chained_adjustments;
cap mkdir ${basedir}/stats/output/chained_adjustments/college;

/* This do-file plots income share and adjusted income share for each age group
over the years 1976-2017, using chained years */;

use ${basedir}/build/output/ASEC.dta;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;
drop if age < 18;
drop if incwage < 0 | incwage == .;
drop if topcode == 1;

* Which gender (men/women/both);
local gender men;
if "`gender'"=="men" {;
	keep if male == 1;
};
else if "`gender'"=="women" {;
	keep if male == 0;
};

egen agecat = cut(age), at(18,25,35,45,55,65);
replace agecat = 65 if age >=65;

label define agecatlabel 18 "18-25 year olds" 25 "25-34 year olds"
	35 "35-44 year olds" 45 "45-54 year olds" 55 "55-64 year olds"
	65 "65+";
label values agecat;

////////////////////////////////////////////////////////////////////////////////
* COMPUTE POPULATION SHARES, AND UNADJUSTED STATISTICS;
* Population shares;
bysort year agecat: egen popjt = sum(asecwt);
by year: 			egen popt = sum(asecwt);
gen popsharejt 	= popjt/popt;

* Unadjusted earnings share for 1976;
bysort year agecat:	egen earnjt	= sum(asecwt*incwage);
by year: egen earnt = sum(asecwt*incwage);
gen unadj_earnshare = earnjt/earnt;
bysort agecat (year): gen earnshare_1976 = unadj_earnshare[1];

////////////////////////////////////////////////////////////////////////////////
* ADJUSTING FOR CHANGES IN POPULATION SHARE, CHAINED;
preserve;
duplicates drop agecat year, force;

* Ratio of mean group earnings to mean population earnings;
gen mearnjt	= earnjt/popjt;
gen	mearnt = earnt/popt;
gen	mearnsharejt = mearnjt/mearnt;

tsset agecat year;
gen 	sumterms = L.popsharejt*D.mearnsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen	adjearnshare_population = earnshare_1976 + sumvar;

* Plot;
* Overlaid plots;
foreach i in 18 25 35 45 55 65 {;
	local adjplots_population `adjplots_population' line adjearnshare_population year if agecat == `i' ||;
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
	
cd ${basedir}/stats/output/chained_adjustments;
if "`gender'"=="men" {;
	graph export population_men.png, replace;
};
else if "`gender'"=="women" {;
	graph export population_women.png, replace;
};
else if "`gender'"=="both" {;
	graph export population_pooled.png, replace;
};

restore;
////////////////////////////////////////////////////////////////////////////////
* ADJUSTING FOR CHANGING EDUCATION COMPOSITION BETWEEN AGE GROUPS;
* Population share of education groups within age groups;
bysort year agecat college: egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popjt;

* Ratio of mean group earnings to mean population earnings;
bysort year agecat college: egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;
gen	mearnt = earnt/popt;
gen	mearnsharejkt = mearnjkt/mearnt;

duplicates drop agecat year college, force;

* Compute all the components separately here;
* Component associated with changes in average earnings;
gen panelvar = agecat + college*100;
tsset panelvar year;
gen innersumterms = L.popsharejkt*D.mearnsharejkt;
bysort year agecat: egen innersums = sum(innersumterms);

duplicates drop year agecat, force;
tsset agecat year;
gen outersumterms = L.popsharejt*innersums;
replace outersumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(outersumterms);
gen	earningseffect_college = earnshare_1976 + sumvar;


* Plot;
* Overlaid plots;
foreach i in 18 25 35 45 55 65 {;
	local adjplots_college `adjplots_college' line earningseffect_college year if agecat == `i' ||;
};

local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

* Income share plot, adjusted for population and education;
graph twoway `adjplots_college', legend(order(`ages')) 
	graphregion(color(white)) xlabel(1976(5)2017)
	xtitle("") ytitle("Contribution of Mean Earnings Variation Within Age and Education Groups")
	legend(region(lcolor(white)))
	bgcolor(white)
	legend(span)
	aspectratio(1)
	xsize(3.5);
	
cd ${basedir}/stats/output/chained_adjustments/college;
if "`gender'"=="men" {;
	graph export earningseffect_men.png, replace;
};
else if "`gender'"=="women" {;
	graph export earningseffect_women.png, replace;
};
else if "`gender'"=="both" {;
	graph export earningseffect_pooled.png, replace;
};
