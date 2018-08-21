#delimit;

/* Plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

* Announce decomposition components for chained_table.do;
global components age earnings;
* Declare that this is the alternate decomposition;
global alt 1;

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
gen 	sumterms = L.mearn_jt_t*D.popsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen	age_effect = earnshare_1976 + sumvar;
drop sumterms sumvar;

* Covariance term;
tsset agecat year;
gen 	sumterms = D.mearn_jt_t*D.popsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen covariance_term = earnshare_1976 + sumvar;
drop sumterms sumvar;

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
	graph twoway 	line age_effect year if (agecat==`i') ||
					line earnings_effect year if (agecat==`i') ||
					line covariance_term year if (agecat==`i') ||
					line uearnshare year if (agecat==`i') ||,
		legend(order(
			1 "Age Share Component" 
			2 "Mean Earnings Component"
			3 "Covariance Term"
			4 "Unadjusted Shares")) 
		legend(cols(1))
		graphregion(color(white)) xlabel(1976(10)2017)
		xtitle("") ytitle("")
		legend(region(lcolor(white)))
		bgcolor(white)
		legend(span)
		xsize(3.5)
		ysize(3)
		scale(1.4);

	cd ${basedir}/stats/output/alt_agedecomp;
	graph export alt_agedecomp`i'_${gender}.png, replace;
};
