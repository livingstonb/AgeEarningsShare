#delimit;

/* Plots income share adjusted by population shares and one other variable,
for each age group over the years 1976-2017 */;

* Announce decomposition components for chained_table.do;
global components age earnings ${adjustvar};

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort year agecat $adjustvar: egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popjt;

* Mean group earnings;
bysort year agecat $adjustvar: egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;

duplicates drop agecat year $adjustvar, force;

////////////////////////////////////////////////////////////////////////////////
* DECOMPOSITION;
egen panelvar = group(agecat $adjustvar);
tsset panelvar year;

/* Compute lagged earnings via formula to check for error against actual
lagged earnings */;
gen denom_terms = L.popsharejt*L.popsharejkt*L.mearnjkt;
gen num_terms = L.popsharejkt*L.mearnjkt;
bysort year: egen denominator = sum(denom_terms);
bysort year agecat: egen numerator = sum(num_terms);
tsset panelvar year;
* Lagged earnings (Luearnshare);
gen Luearnshare = L.popsharejt*numerator/denominator;
drop denom_terms num_terms denominator numerator num_terms;

* Population share component;
tsset panelvar year;
gen num_terms = L.popsharejkt*L.mearnjkt;
bysort year agecat: egen numerator = sum(num_terms);
tsset panelvar year;
replace numerator = popsharejt*numerator;
bysort year ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
tsset panelvar year;
gen popcomponent = counterfactual_share - L.uearnshare;
drop counterfactual_share numerator denominator num_terms;

* Z-variable component;
tsset panelvar year;
gen num_terms = popsharejkt*L.mearnjkt;
bysort year agecat: egen numerator = sum(num_terms);
tsset panelvar year;
replace numerator = L.popsharejt*numerator;
bysort year ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
tsset panelvar year;
gen zcomponent = counterfactual_share - L.uearnshare;
drop counterfactual_share numerator denominator num_terms;

* Mean earnings component;
tsset panelvar year;
gen num_terms = L.popsharejkt*mearnjkt;
bysort year agecat: egen numerator = sum(num_terms);
tsset panelvar year;
replace numerator = L.popsharejt*numerator;
bysort year ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
tsset panelvar year;
gen mearncomponent = counterfactual_share - L.uearnshare;
drop counterfactual_share numerator denominator num_terms;

duplicates drop agecat year, force;

* Interaction component;
gen interactcomponent = D.uearnshare-popcomponent-zcomponent-mearncomponent;

* Levels, zeroed at 1976;
replace popcomponent = 0 if year == 1976;
replace zcomponent = 0 if year == 1976;
replace mearncomponent = 0 if year == 1976;
replace interactcomponent = 0 if year == 1976;
bysort agecat (year): gen age_effect = sum(popcomponent);
by agecat: gen ${adjustvar}_effect = sum(zcomponent);
by agecat: gen earnings_effect = sum(mearncomponent);
by agecat: gen interact_effect = sum(interactcomponent);


////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
	graph twoway 	line earnings_effect year if (agecat==`i'), $line6 ||
					line age_effect year if (agecat==`i'), $line5 ||
					line ${adjustvar}_effect year if (agecat==`i'), $line3 ||
					line interact_effect year if (agecat==`i'), $line2 ||
					line zeroed_uearnshare year if (agecat==`i'), $line1 ||,
		legend(order(
			1 "Mean Earnings Component" 
			2 "Age Share Component" 
			3 "${adjustlabel}"
			4 "Interaction"
			5 "Unadjusted Shares")) 
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
keep year agecat earnings_effect age_effect ${adjustvar}_effect interact_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using ${adjustvar}_${gender}.csv, comma replace;
