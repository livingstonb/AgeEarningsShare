#delimit;

/* This do-file plots income shares adjusted by the age distribution and adjusted
by the variable $adjustvar within age groups, over the years 1976-2017 using a 
chain-weighted decomposition */;

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort year agecat $adjustvar: egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popjt;

* Ratio of mean group earnings to mean population earnings;
bysort year agecat $adjustvar: egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;
gen	mearnt = earnt/popt;
gen	mearnsharejkt = mearnjkt/mearnt;

duplicates drop agecat year $adjustvar, force;

* Compute separate components of decomposition;

gen panelvar = agecat + $adjustvar*100;
tsset panelvar year;
gen innersumterms_age			= popsharejkt*mearnsharejkt;
gen innersumterms_$adjustvar 	= D.popsharejkt*mearnsharejkt;
gen innersumterms_earnings 		= L.popsharejkt*D.mearnsharejkt;
* Sum over values of $adjustvar;
bysort year agecat: egen innersums_age 			= sum(innersumterms_age);
bysort year agecat: egen innersums_$adjustvar 	= sum(innersumterms_$adjustvar);
bysort year agecat: egen innersums_earnings 	= sum(innersumterms_earnings);

duplicates drop year agecat, force;
tsset agecat year;
gen outersumterms_age			= D.popsharejt*innersums_age;
gen outersumterms_$adjustvar	= L.popsharejt*innersums_$adjustvar;
gen outersumterms_earnings 		= L.popsharejt*innersums_earnings;
local components age $adjustvar earnings;
foreach comp of local components {;
	replace outersumterms_`comp' = 0 if year == 1976;
	* Sum from t0+1 to year of observation;
	bysort agecat (year): gen sumvar_`comp' = sum(outersumterms_`comp');
	* Component's isolated effect on earnings shares;
	gen `comp'effect = earnshare_1976 + sumvar_`comp';
};

* Plots;
foreach i in 18 25 35 45 55 65 {;
	local adjplots_age `adjplots_age' line ageeffect year if agecat == `i' ||;
	local adjplots_$adjustvar `adjplots_$adjustvar' line ${adjustvar}effect year if agecat == `i' ||;
	local adjplots_earnings `adjplots_earnings' line earningseffect year if agecat == `i' ||;
};

* Legend labels;
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

* Income share plots, adjusted;
foreach comp of local components {;
	graph twoway `adjplots_`comp'', legend(order(`ages')) 
		graphregion(color(white)) xlabel(1976(5)2017)
		xtitle("") ytitle("")
		yscale(range(0(0.05)0.35))
		ylabel(0(0.1)0.3)
		legend(region(lcolor(white)))
		bgcolor(white)
		legend(span)
		aspectratio(1)
		xsize(3.5);
		
	cd ${basedir}/stats/output/chained_adjustments/${adjustvar};
	if "$gender"=="men" {;
		graph export ${adjustvar}_`comp'effect_men.png, replace;
	};
	else if "$gender"=="women" {;
		graph export ${adjustvar}_`comp'effect_women.png, replace;
	};
	else if "$gender"=="both" {;
		graph export ${adjustvar}_`comp'effect_pooled.png, replace;
	};
};
