#delimit;

/* This do-file plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

////////////////////////////////////////////////////////////////////////////////
* ADJUSTING FOR CHANGES IN POPULATION SHARE, CHAINED;
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

* Plot syntax;
foreach i in 18 25 35 45 55 65 {;
	local adjplots_population `adjplots_population' 
		line adjearnshare_population year if agecat == `i' ||;
};

* Legend labels;
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 
	5 "Ages 55-64" 6 "Ages 65+";

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
if "$gender"=="men" {;
	graph export populationadj_men.png, replace;
};
else if "$gender"=="women" {;
	graph export populationadj_women.png, replace;
};
else if "$gender"=="both" {;
	graph export populationadj_pooled.png, replace;
};
