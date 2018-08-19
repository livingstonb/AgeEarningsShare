#delimit;

/* This do-file plots income shares adjusted by the age distribution and adjusted
by the variable $adjustvar within age groups, over the years 1976-2017 using a 
chain-weighted decomposition */;

if $pooled == 1{;
	* Do not group by gender, use empty local variable instead of male variable;
	local gendervar ;
	
	* Need to re-compute some statistics without grouping by male variable;
	drop popjt popsharejt popshare_1976 earnjt uearnshare earnshare_1976
		mearnjt mearnsharejt;
	* Population shares;
	bysort year agecat: 	egen popjt = sum(asecwt);
	gen popsharejt = popjt/popt;
	bysort agecat (year): 	gen popshare_1976 = popsharejt[1];

	* Unadjusted earnings share for 1976;
	bysort year agecat: 	egen earnjt = sum(asecwt*incwage);
	gen uearnshare = earnjt/earnt;
	bysort agecat (year): 	gen earnshare_1976 = uearnshare[1];

	* Ratio of mean group earnings to mean population earnings;
	gen mearnjt	= earnjt/popjt;
	gen	mearnsharejt = mearnjt/mearnt;
};
else {;
	local gendervar male;
};

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort year agecat $adjustvar `gendervar': egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popjt;

* Ratio of mean group earnings to mean population earnings;
bysort year agecat $adjustvar `gendervar': egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;
gen	mearnsharejkt = mearnjkt/mearnt;

duplicates drop agecat year $adjustvar `gendervar', force;

* Compute separate components of decomposition;

egen panelvar = group(agecat $adjustvar `gendervar');
tsset panelvar year;
gen innersumterms_age			= popsharejkt*mearnsharejkt;
gen innersumterms_$adjustvar 	= D.popsharejkt*mearnsharejkt;
gen innersumterms_earnings 		= L.popsharejkt*D.mearnsharejkt;
* Sum over values of $adjustvar;
bysort year agecat `gendervar': egen innersums_age 		= sum(innersumterms_age);
bysort year agecat `gendervar': egen innersums_$adjustvar 	= sum(innersumterms_$adjustvar);
bysort year agecat `gendervar': egen innersums_earnings 	= sum(innersumterms_earnings);

duplicates drop year agecat `gendervar', force;
drop panelvar;
egen panelvar = group(agecat `gendervar');
tsset panelvar year;
gen outersumterms_age			= D.popsharejt*innersums_age;
gen outersumterms_$adjustvar	= L.popsharejt*innersums_$adjustvar;
gen outersumterms_earnings 		= L.popsharejt*innersums_earnings;
local components age $adjustvar earnings;
foreach comp of local components {;
	replace outersumterms_`comp' = 0 if year == 1976;
	* Sum from t0+1 to year of observation;
	bysort agecat `gendervar' (year): gen sumvar_`comp' = sum(outersumterms_`comp');
	* Component's isolated effect on earnings shares;
	gen `comp'effect = earnshare_1976 + sumvar_`comp';
};

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Legend labels;
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

foreach i in 18 25 35 45 55 65 {;
	if $pooled == 1 {;
		* Do not condition on gender, use true local variable;
		local genderconditions 1;
	};
	else {;
		local genderconditions male==0 male==1;
	};
	foreach gcond of local genderconditions {;
		local adjplots_age line ageeffect year if (agecat == `i') & `gcond' ||;
		local adjplots_$adjustvar line ${adjustvar}effect year if (agecat == `i') & `gcond' ||;
		local adjplots_earnings line earningseffect year if (agecat == `i') & `gcond' ||;
		local adjplots_unadjusted line uearnshare year if (agecat == `i') & `gcond' ||;

		graph twoway `adjplots_age' `adjplots_${adjustvar}' `adjplots_earnings'
			`adjplots_unadjusted',
			legend(order(1 "Age Share Component" 2 "${adjustlabel}"
				3 "Mean Earnings Component" 4 "Unadjusted Shares")) 
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
		if "`gcond'"=="male==0" {;
			graph export ${adjustvar}`i'_women.png, replace;
		};
		else if "`gcond'"=="male==1"  {;
			graph export ${adjustvar}`i'_men.png, replace;
		};
		else if `gcond'==1 {;
			graph export ${adjustvar}`i'.png, replace;
		};
	};
};

////////////////////////////////////////////////////////////////////////////////
* COMPUTE STATISTICS FOR TABLE;
keep if year==1976 | year==2017;
sort `gendervar' agecat year uearnshare *effect;
keep `gendervar' agecat year uearnshare *effect;

bysort `gendervar' agecat (year): gen period = _n;
egen panelvar = group(`gendervar' agecat);
tsset panelvar period;
gen change = D.uearnshare;
foreach comp of local components {;
	gen `comp'contribution = D.`comp'effect/D.uearnshare*100;
};
drop period;

cd ${basedir}/stats/output/chained_adjustments/${adjustvar};
save ${adjustvar}_changes.dta, replace;
