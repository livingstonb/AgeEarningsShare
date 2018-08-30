#delimit;

/* Plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

* Announce decomposition components for chained_table.do;
global components age earnings;
* Declare that this is OB decomp (alt=2);
global alt 2;

duplicates drop agecat year, force;

////////////////////////////////////////////////////////////////////////////////
* CHAIN-WEIGHTED DECOMP;
tsset agecat year;
gen denom_terms = L.popsharejt*mearnjt;
bysort year: egen denominator = sum(denom_terms);

tsset agecat year;
gen counterfactual_share = L.popsharejt*mearnjt/denominator;

* Compositional component (explained);
tsset agecat year;
gen compositional = uearnshare - counterfactual_share;

* Structural component (unexplained);
gen structural = counterfactual_share - L.uearnshare;

* Levels, zeroed at 1976;
replace structural = 0 if year == 1976;
replace compositional = 0 if year == 1976;
bysort agecat (year): gen earnings_effect = sum(structural);
by agecat: gen age_effect = sum(compositional);

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
	graph twoway 	line earnings_effect year if (agecat==`i'), $line3 ||
					line age_effect year if (agecat==`i'), $line2 ||
					line zeroed_uearnshare year if (agecat==`i'), $line1 ||,
		legend(order(
			1 "Structural Component" 
			2 "Compositional Component"
			3 "Unadjusted Shares")) 
		${plot_options};

	cd ${basedir}/stats/output/Oaxaca_Blinder;
	graph export OB_agedecomp`i'_${gender}.png, replace;
};

* export data for plotting elsewhere;
sort year agecat;
keep year agecat age_effect earnings_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using OB_agedecomp_${gender}.csv, comma replace;
