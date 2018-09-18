#delimit;

/* Computes unadjusted shares based on the desired sample (men/women/pooled)
and computes mean earnings by group--called by decomp1_main */;

if "$gender"=="women" {;
	keep if male==0;
};
else if "$gender"=="men" {;
	keep if male==1;
};

drop if ${agevar}==.;

////////////////////////////////////////////////////////////////////////////////
* UNADJUSTED  SHARES AND IMPORTANT STATISTICS;
* Population shares;
bysort ${timevar} ${agevar}: 	egen popjt = sum(asecwt);
by ${timevar}: 				egen popt = sum(asecwt);
gen popsharejt = popjt/popt;
bysort ${agevar} (${timevar}): 	gen popshare_1976 = popsharejt[1];

* Unadjusted earnings share for 1976;
bysort ${timevar} ${agevar}: 	egen earnjt = sum(asecwt*incwage);
by ${timevar}: 				egen earnt = sum(asecwt*incwage);
gen uearnshare = earnjt/earnt;
bysort ${agevar} (${timevar}): 	gen earnshare_1976 = uearnshare[1];

* Shift adusted earnings share to zero for 1976;
gen zeroed_uearnshare = uearnshare - earnshare_1976;

* Ratio of mean group earnings to mean population earnings;
gen mearnjt	= earnjt/popjt;
gen	mearnt = earnt/popt;
