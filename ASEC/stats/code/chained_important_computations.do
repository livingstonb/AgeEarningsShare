#delimit;

/* Computes unadjusted shares based on the desired sample (men/women/pooled)
and computes mean earnings by group */;

if "$gender"=="women" {;
	keep if male==0;
};
else if "$gender"=="men" {;
	keep if male==1;
};

////////////////////////////////////////////////////////////////////////////////
* UNADJUSTED  SHARES AND IMPORTANT STATISTICS;
* Population shares;
bysort year agecat: 	egen popjt = sum(asecwt);
by year: 				egen popt = sum(asecwt);
gen popsharejt = popjt/popt;
bysort agecat (year): 	gen popshare_1976 = popsharejt[1];

* Unadjusted earnings share for 1976;
bysort year agecat: 	egen earnjt = sum(asecwt*incwage);
by year: 				egen earnt = sum(asecwt*incwage);
gen uearnshare = earnjt/earnt;
bysort agecat (year): 	gen earnshare_1976 = uearnshare[1];

* Ratio of mean group earnings to mean population earnings;
gen mearnjt	= earnjt/popjt;
gen	mearnt = earnt/popt;
gen	mearn_jt_t = mearnjt/mearnt;
