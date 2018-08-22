#delimit;

/* Plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

* Announce decomposition components for chained_table.do;
global components age covariance earnings;
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
gen	earnings_effect =  sumvar;
drop sumterms sumvar;

* Component associated with age share;
tsset agecat year;
gen 	sumterms = L.mearn_jt_t*D.popsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen	age_effect = sumvar;
drop sumterms sumvar;

* Covariance term;
tsset agecat year;
gen 	sumterms = D.mearn_jt_t*D.popsharejt;
replace sumterms = 0 if year == 1976;
bysort agecat (year): gen sumvar = sum(sumterms);
gen covariance_effect = sumvar;
drop sumterms sumvar;

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
	graph twoway	line earnings_effect year if (agecat==`i'), $line4  ||
					line covariance_effect year if (agecat==`i'), $line3  ||
					line age_effect year if (agecat==`i'), $line2  ||
					line zeroed_uearnshare year if (agecat==`i'), $line1 ||,
		legend(order(
			1 "Mean Earnings Component" 
			2 "Covariance Component"
			3 "Age Shares Component"
			4 "Unadjusted Shares")) 
		${plot_options};

	cd ${basedir}/stats/output/alt_agedecomp;
	graph export alt_agedecomp`i'_${gender}.png, replace;
};

* export data for plotting elsewhere;
sort year agecat;
keep year agecat earnings_effect age_effect covariance_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using alt_agedecomp_${gender}.csv, comma replace;
