#delimit;

/* This do-file plots income shares adjusted by the age distribution and adjusted
by the variable $adjustvar within age groups, over the years 1976-2017 using a 
chain-weighted decomposition */;

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort year agecat $adjustvar: egen popjkt = sum(asecwt);
bysort year $adjustvar: egen popkt = sum(asecwt);
gen popsharejkt = popjkt/popjt;
gen popsharekt = popkt/popt;
gen popsharejkt_kt = popsharejkt/popsharekt;

* Ratio of mean group earnings to mean population earnings;
bysort year agecat $adjustvar: egen earnjkt = sum(asecwt*incwage);
bysort year $adjustvar: egen earnkt = sum(asecwt*incwage);
gen earnsharekt = earnkt/earnt;
gen mearnjkt = earnjkt/popjkt;
gen mearnkt = earnkt/popkt;
gen	mearn_jkt_kt = mearnjkt/mearnkt;

duplicates drop agecat year $adjustvar, force;

* Compute separate components of decomposition;

egen panelvar = group(agecat $adjustvar);
tsset panelvar year;
gen innersumterms1		= earnsharekt*popsharejkt_kt*mearn_jkt_kt;
gen innersumterms2 		= D.earnsharekt*popsharejkt_kt*mearn_jkt_kt;
gen innersumterms3 		= L.earnsharekt*D.popsharejkt_kt*mearn_jkt_kt;
gen innersumterms4		= L.earnsharekt*L.popsharejkt_kt*D.mearn_jkt_kt;
* Sum over values of $adjustvar;
forvalues i=1/4 {;
	bysort year agecat: egen innersum`i' = sum(innersumterms`i');
};

duplicates drop year agecat, force;
drop panelvar;
egen panelvar = group(agecat);
tsset panelvar year;
gen outersumterms1 = D.popsharejt*innersum1;
gen outersumterms2 = L.popsharejt*innersum2;
gen outersumterms3 = L.popsharejt*innersum3;
gen outersumterms4 = L.popsharejt*innersum4;

forvalues i=1/4 {;
	replace outersumterms`i' = 0 if year == 1976;
	* Sum from t0+1 to year of observation;
	bysort agecat (year): gen component`i' = sum(outersumterms`i');
	* Component's isolated effect on earnings shares;
	gen path`i' = earnshare_1976 + component`i';
};

////////////////////////////////////////////////////////////////////////////////
* COMBINE COMPONENTS 2 AND 3;
gen ageeffect = earnshare_1976 + component1;
gen ${adjustvar}effect = earnshare_1976 + component2 + component3;
gen earningseffect = earnshare_1976 + component4;

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Legend labels;
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

foreach i in 18 25 35 45 55 65 {;
		local adjplots_age line ageeffect year if (agecat == `i') ||;
		local adjplots_$adjustvar line ${adjustvar}effect year if (agecat == `i') ||;
		local adjplots_earnings line earningseffect year if (agecat == `i') ||;
		local adjplots_unadjusted line uearnshare year if (agecat == `i') ||;

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
		
		cd ${basedir}/stats/output/alt_chained_adjustments/${adjustvar};
		if "$gender"=="pooled" {;
			graph export ${adjustvar}`i'.png, replace;
		};
		else {;
			graph export ${adjustvar}`i'_${gender}.png, replace;
		};
};
