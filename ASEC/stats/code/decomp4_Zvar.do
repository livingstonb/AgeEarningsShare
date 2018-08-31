#delimit;

/* Plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

* Announce decomposition components for chained_table.do;
global components age earnings ${adjustvar};
* Declare that this is OB decomp (alt=2);
global alt 2;

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort year agecat $adjustvar: egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popjt;

* Mean group earnings;
bysort year agecat $adjustvar: egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;

duplicates drop agecat year $adjustvar, force;

////////////////////////////////////////////////////////////////////////////////
* CHAIN-WEIGHTED DECOMP;
egen panelvar = group(agecat $adjustvar);
tsset panelvar year;

* Check lagged earnings share computation;
gen denom_terms = L.popsharejt*L.popsharejkt*L.mearnjkt;
gen num_terms = L.popsharejkt*L.mearnjkt;
bysort year: egen denominator = sum(denom_terms);
bysort year agecat: egen numerator = sum(num_terms);
tsset panelvar year;
gen Luearnshare = L.popsharejt*numerator/denominator;
drop denom_terms num_terms denominator numerator;

* First counterfactual earnings share;
gen denom_terms = L.popsharejt*popsharejkt*mearnjkt;
gen num_terms = popsharejkt*mearnjkt;
bysort year: egen denominator = sum(denom_terms);
bysort year agecat: egen numerator = sum(num_terms);
tsset panelvar year;
gen counterfactual_share1 = L.popsharejt*numerator/denominator;
drop denom_terms num_terms denominator numerator;

* Second counterfactual earnings share;
gen denom_terms = L.popsharejt*L.popsharejkt*mearnjkt;
gen num_terms = L.popsharejkt*mearnjkt;
bysort year: egen denominator = sum(denom_terms);
bysort year agecat: egen numerator = sum(num_terms);
tsset panelvar year;
gen counterfactual_share2 = L.popsharejt*numerator/denominator;
drop denom_terms num_terms denominator numerator;

duplicates drop agecat year, force;

* Population share component;
gen popcomponent = uearnshare - counterfactual_share1;

* Z-variable component;
gen zcomponent = counterfactual_share1 - counterfactual_share2;

* Mean earnings component;
tsset agecat year;
gen mearncomponent = counterfactual_share2 - L.uearnshare;

* Levels, zeroed at 1976;
replace popcomponent = 0 if year == 1976;
replace zcomponent = 0 if year == 1976;
replace mearncomponent = 0 if year == 1976;
bysort agecat (year): gen age_effect = sum(popcomponent);
by agecat: gen ${adjustvar}_effect = sum(zcomponent);
by agecat: gen earnings_effect = sum(mearncomponent);


////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
	graph twoway 	line earnings_effect year if (agecat==`i'), $line5 ||
					line age_effect year if (agecat==`i'), $line3 ||
					line ${adjustvar}_effect year if (agecat==`i'), $line2 ||
					line zeroed_uearnshare year if (agecat==`i'), $line1 ||,
		legend(order(
			1 "Mean Earnings Component" 
			2 "Age Share Component" 
			3 "${adjustlabel}"
			4 "Unadjusted Shares")) 
		${plot_options};

	cd ${basedir}/stats/output/stata_plots/${adjustvar};
	graph export ${adjustvar}_`i'_${gender}.png, replace;
};

/* For checking error in unadjusted earnshare estimate, compare true unadjusted
shares with lagged shares computed with identity */;
cap mkdir ${basedir}/stats/output/error;
cd ${basedir}/stats/output/error;
outsheet Luearnshare uearnshare using ${adjustvar}_${gender}.csv, comma replace;

* export data for plotting elsewhere;
sort year agecat;
keep year agecat earnings_effect age_effect ${adjustvar}_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using ${adjustvar}_${gender}.csv, comma replace;
