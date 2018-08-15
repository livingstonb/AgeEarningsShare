#delimit;

/* This do-file plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

////////////////////////////////////////////////////////////////////////////////
* ADJUSTING FOR CHANGES IN AGE SHARE;
duplicates drop agecat year, force;

* Ratio of mean group earnings to mean population earnings;
gen mearnjt	= earnjt/popjt;
gen	mearnt = earnt/popt;
gen	mearnsharejt = mearnjt/mearnt;

gen earnshare_popadj = popshare_1976*mearnsharejt;

////////////////////////////////////////////////////////////////////////////////
* CHAIN-WEIGHTED DECOMP;
* Component associated with mean earnings;
tsset agecat year;
gen 	sumterms = L.popsharejt*D.mearnsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen	decomp_earnings = earnshare_1976 + sumvar;
drop sumterms sumvar;

* Component associated with age share;
tsset agecat year;
gen 	sumterms = D.popsharejt*mearnsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen	decomp_age = earnshare_1976 + sumvar;

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR AGE SHARE ADJUSTMENT;
* Plot syntax;
foreach i in 18 25 35 45 55 65 {;
	local adjplots_population `adjplots_population' 
		line earnshare_popadj year if agecat == `i' ||;
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
graph export populationadj_${gender}.png, replace;

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;

foreach i in 18 25 35 45 55 65 {;
	local decompageplot line decomp_age year if agecat==`i' ||;
	local decompearningsplot line decomp_earnings year if agecat==`i' ||;
	local unadjplot line unadj_earnshare year if agecat==`i' ||;
	
	graph twoway `decompageplot' `decompearningsplot' `unadjplot', 
		legend(order(1 "Age Share Component" 2 "Mean Earnings Component"
			3 "Unadjusted Shares")) 
		legend(cols(1))
		graphregion(color(white)) xlabel(1976(10)2017)
		xtitle("") ytitle("")
		legend(region(lcolor(white)))
		bgcolor(white)
		legend(span)
		xsize(3.5)
		ysize(3)
		scale(1.5);

	cd ${basedir}/stats/output/agedecomp;
	graph export agedecomp`i'_${gender}.png, replace;
};

