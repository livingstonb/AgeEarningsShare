#delimit;

/* This do-file plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

duplicates drop agecat year male, force;

////////////////////////////////////////////////////////////////////////////////
* CHAIN-WEIGHTED DECOMP;
egen panelvar = group(agecat male);

* Component associated with mean earnings;
tsset panelvar year;
gen 	sumterms = L.popsharejt*D.mearnsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat male (year): gen sumvar = sum(sumterms);
gen	decomp_earnings = earnshare_1976 + sumvar;
drop sumterms sumvar;

* Component associated with age share;
tsset panelvar year;
gen 	sumterms = D.popsharejt*mearnsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat male (year): gen sumvar = sum(sumterms);
gen	decomp_age = earnshare_1976 + sumvar;

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;
	* Loop over gender;
	forvalues gind = 0/1 {;
		local decompageplot line decomp_age year if (agecat==`i') & (male==`gind') ||;
		local decompearningsplot line decomp_earnings year if (agecat==`i') & (male==`gind') ||;
		local unadjplot line uearnshare year if (agecat==`i') & (male==`gind') ||;
		
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
		if `gind'==0 {;
			graph export agedecomp`i'_women.png, replace;
		};
		else if `gind'==1 {;
			graph export agedecomp`i'_men.png, replace;
		};
	};
};

