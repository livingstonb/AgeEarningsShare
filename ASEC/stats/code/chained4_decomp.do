#delimit;

/* This do-file plots income shares adjusted by the age distribution and adjusted
by the variable $adjustvar within age groups, over the years 1976-2017 using a 
chain-weighted decomposition */;

global components age $adjustvar earnings;
global alt 0;

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort year agecat $adjustvar: egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popjt;

* Ratio of mean group earnings to mean population earnings;
bysort year agecat $adjustvar: egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;
gen	mearn_jkt_t = mearnjkt/mearnt;

duplicates drop agecat year $adjustvar, force;

* Compute separate components of decomposition;

egen panelvar = group(agecat $adjustvar);
tsset panelvar year;
gen innersumterms_age			= popsharejkt*mearn_jkt_t;
gen innersumterms_$adjustvar 	= D.popsharejkt*mearn_jkt_t;
gen innersumterms_earnings 		= L.popsharejkt*D.mearn_jkt_t;
* Sum over values of $adjustvar;
bysort year agecat: egen innersums_age 		= sum(innersumterms_age);
bysort year agecat: egen innersums_$adjustvar 	= sum(innersumterms_$adjustvar);
bysort year agecat: egen innersums_earnings 	= sum(innersumterms_earnings);

duplicates drop year agecat, force;
drop panelvar;
egen panelvar = group(agecat);
tsset panelvar year;
gen outersumterms_age			= D.popsharejt*innersums_age;
gen outersumterms_$adjustvar	= L.popsharejt*innersums_$adjustvar;
gen outersumterms_earnings 		= L.popsharejt*innersums_earnings;

foreach comp of global components {;
	replace outersumterms_`comp' = 0 if year == 1976;
	* Sum from t0+1 to year of observation;
	bysort agecat(year): gen sumvar_`comp' = sum(outersumterms_`comp');
	* Component's isolated effect on earnings shares;
	gen `comp'_effect = earnshare_1976 + sumvar_`comp';
};

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Legend labels;
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

foreach i in 18 25 35 45 55 65 {;
	graph twoway 
		line age_effect year if (agecat == `i') ||
		line ${adjustvar}_effect year if (agecat == `i') ||
		line earnings_effect year if (agecat == `i') ||
		line uearnshare year if (agecat == `i') ||,
		legend(order(
			1 "Age Share Component" 
			2 "${adjustlabel}"
			3 "Mean Earnings Component" 
			4 "Unadjusted Shares")) 
		legend(cols(1))
		graphregion(color(white)) xlabel(1976(10)2017)
		xtitle("") ytitle("")
		legend(region(lcolor(white)))
		bgcolor(white)
		legend(span)
		xsize(3.5)
		ysize(3)
		scale(1.6);
	* 		yscale(range(0(0.05)0.35)) to scale y-axis ;
	
	cd ${basedir}/stats/output/chained_adjustments/${adjustvar};
	graph export ${adjustvar}`i'_${gender}.png, replace;
};


