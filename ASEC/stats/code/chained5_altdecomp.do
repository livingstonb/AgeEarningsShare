#delimit;

/* Plots income shares decomposed by the age distribution and adjusted and the 
variable $adjustvar within age groups, over the years 1976-2017 using an
alternate chain-weighted decomposition */;

* Announce decomposition components for chained_table.do;
global components age ${adjustvar}1 ${adjustvar}2 earnings;
* Declare that this IS the alternate decomposition;
global alt 1;

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
gen outersumterms_age = D.popsharejt*innersum1;
gen outersumterms_${adjustvar}1 = L.popsharejt*innersum2;
gen outersumterms_${adjustvar}2 = L.popsharejt*innersum3;
gen outersumterms_earnings = L.popsharejt*innersum4;

foreach comp of global components {;
	replace outersumterms_`comp' = 0 if year == 1976;
	* Sum from t0+1 to year of observation;
	bysort agecat (year): gen term_`comp' = sum(outersumterms_`comp');
	* Component's isolated effect on earnings shares;
	gen `comp'_effect = earnshare_1976 + term_`comp';
};

////////////////////////////////////////////////////////////////////////////////
* PLOTS;

* Legend labels;
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

foreach i in 18 25 35 45 55 65 {;
		local paths;
		foreach comp of global components {;
			local paths `paths' line `comp'_effect year if agecat==`i' ||;
		};

		graph twoway `paths' || 
			line uearnshare year if agecat==`i',
			legend(order(
				1 "Age Share Component" 
				2 "${adjustlabel} (Overall)"
				3 "${adjustlabel} (Cond'l)"
				4 "Mean Earnings Component" 
				5 "Unadjusted Shares"))
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
		graph export ${adjustvar}`i'_${gender}.png, replace;
};
