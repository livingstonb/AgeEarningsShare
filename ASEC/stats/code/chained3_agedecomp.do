#delimit;

/* Plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

* Announce decomposition components for chained_table.do;
global components age earnings;
* Declare that this is NOT the alternate decomposition;
global alt 0;

duplicates drop agecat year, force;

////////////////////////////////////////////////////////////////////////////////
* CHAIN-WEIGHTED DECOMP;
* Component associated with mean earnings;
tsset agecat year;
gen 	sumterms = L.popsharejt*D.mearn_jt_t;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen	earnings_effect = earnshare_1976 + sumvar;
drop sumterms sumvar;

* Component associated with age share;
tsset agecat year;
gen 	sumterms = D.popsharejt*mearn_jt_t;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen	age_effect = earnshare_1976 + sumvar;

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
	graph twoway 	line age_effect year if (agecat==`i') ||
					line earnings_effect year if (agecat==`i') ||
					line uearnshare year if (agecat==`i') ||,
		legend(order(
			1 "Age Share Component" 
			2 "Mean Earnings Component"
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
