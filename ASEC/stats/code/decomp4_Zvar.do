#delimit;

/* Plots income share adjusted by population shares and one other variable,
for each age group over the years 1976-2017 */;

* Announce decomposition components for chained_table.do;
global components composition struct interact;

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort year agecat $adjustvar: egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popt;

* Mean group earnings;
bysort year agecat $adjustvar: egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;

duplicates drop agecat year $adjustvar, force;

////////////////////////////////////////////////////////////////////////////////
* DECOMPOSITION;
egen panelvar = group(agecat $adjustvar);

/* Compute lagged earnings via formula to check for error against actual
lagged earnings -- will be exported to csv */;
tsset panelvar year;
gen num_terms = L.popsharejkt*L.mearnjkt;
bysort year agecat: egen numerator = sum(num_terms);
bysort year ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
drop num_terms numerator denominator;
rename counterfactual_share Luearnshare;

* Compositional (explained) component, associated with A,Z;
tsset panelvar year;
gen num_terms = popsharejkt*L.mearnjkt;
bysort year agecat: egen numerator = sum(num_terms);
bysort year ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
* Compute counterfactual;
tsset panelvar year;
gen compositional = counterfactual_share - L.uearnshare;
drop num_terms numerator denominator counterfactual_share; 

* Structural (unexplained) component, associated with y|A,Z;
tsset panelvar year;
gen num_terms = L.popsharejkt*mearnjkt;
bysort year agecat: egen numerator = sum(num_terms);
bysort year ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
* Compute counterfactual;
tsset panelvar year;
gen structural = counterfactual_share - L.uearnshare;
drop num_terms numerator denominator counterfactual_share; 

* Interaction component;
tsset panelvar year;
gen interactcomponent = D.uearnshare-compositional-structural;

duplicates drop agecat year, force;

* Find levels from changes, levels zeroed at 1976;
replace compositional = 0 if year == 1976;
replace structural = 0 if year == 1976;
replace interactcomponent = 0 if year == 1976;
bysort agecat (year): gen composition_effect = sum(compositional);
by agecat: gen struct_effect = sum(structural);
by agecat: gen interact_effect = sum(interactcomponent);

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;

* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
					line composition_effect year if (agecat==`i'), $line5 ||
					line struct_effect year if (agecat==`i'), $line3 ||
					line interact_effect year if (agecat==`i'), $line2 ||
					line zeroed_uearnshare year if (agecat==`i'), $line1 ||,
		legend(order(
			1 "Compositional Effect" 
			2 "Structural Effect"
			3 "Interaction"
			4 "Unadjusted Shares")) 
		${plot_options};

	cd ${basedir}/stats/output/stata_plots/${adjustvar};
	graph export ${adjustvar}_`i'_${gender}.png, replace;
};

/* For checking error in unadjusted earnshare estimate, compare true unadjusted
shares with lagged shares computed with identity */;
cap mkdir ${basedir}/stats/output/error;
cd ${basedir}/stats/output/error;
outsheet agecat year Luearnshare uearnshare using ${adjustvar}_${gender}.csv, comma replace;

* export data for plotting elsewhere;
sort year agecat;
keep year agecat  composition_effect struct_effect interact_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using ${adjustvar}_${gender}.csv, comma replace;
