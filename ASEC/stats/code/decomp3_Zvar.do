#delimit;

/* Plots income share adjusted by population shares and one other variable,
for each age group over the years 1976-2017 */;

* Announce decomposition components for chained_table.do;
global components composition struct interact;

////////////////////////////////////////////////////////////////////////////////
* Population share of $adustvar groups within age groups;
bysort ${timevar} ${agevar} $adjustvar: egen popjkt = sum(asecwt);
gen popsharejkt = popjkt/popt;

* Mean group earnings;
bysort ${timevar} ${agevar} $adjustvar: egen earnjkt = sum(asecwt*incwage);
gen mearnjkt	= earnjkt/popjkt;

duplicates drop ${agevar} ${timevar} $adjustvar, force;

* Create new rows where jk-group had no observations;
fillin ${agevar} ${timevar} ${adjustvar};
count if _fillin == 1;
matrix newcolumn = r(N)\_N;
if ${iter}==1 & "${gender}"=="women" {;
	matrix empty_cats = newcolumn;
};
else {;
	matrix empty_cats = empty_cats,newcolumn;
};

cd ${basedir}/stats/output/empty_cats;
sort ${agevar} $adjustvar ${timevar};
outsheet ${agevar} $adjustvar ${timevar} if _fillin==1 using ${adjustvar}_${gender}.csv, comma replace;
duplicates drop ${agevar} ${timevar} $adjustvar, force;

////////////////////////////////////////////////////////////////////////////////
* DECOMPOSITION;
egen panelvar = group(${agevar} $adjustvar);

/* Compute lagged earnings via formula to check for error against actual
lagged earnings -- will be exported to csv */;
tsset panelvar ${timevar};
gen num_terms = L.popsharejkt*L.mearnjkt;
bysort ${timevar} ${agevar}: egen numerator = sum(num_terms);
bysort ${timevar} ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
drop num_terms numerator denominator;
rename counterfactual_share Luearnshare;

* Compositional (explained) component, associated with A,Z;
tsset panelvar ${timevar};
gen num_terms = popsharejkt*L.mearnjkt;
bysort ${timevar} ${agevar}: egen numerator = sum(num_terms);
bysort ${timevar} ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
* Compute counterfactual;
tsset panelvar ${timevar};
gen compositional = counterfactual_share - L.uearnshare;
drop num_terms numerator denominator counterfactual_share; 

* Structural (unexplained) component, associated with y|A,Z;
tsset panelvar ${timevar};
gen num_terms = L.popsharejkt*mearnjkt;
bysort ${timevar} ${agevar}: egen numerator = sum(num_terms);
bysort ${timevar} ${adjustvar}: egen denominator = sum(numerator);
gen counterfactual_share = numerator/denominator;
* Compute counterfactual;
tsset panelvar ${timevar};
gen structural = counterfactual_share - L.uearnshare;
drop num_terms numerator denominator counterfactual_share; 

* Interaction component;
tsset panelvar ${timevar};
gen interactcomponent = D.uearnshare-compositional-structural;

duplicates drop ${agevar} ${timevar}, force;

* Find levels from changes, levels zeroed at 1976;
if "${timevar}"=="year" {;	
	replace compositional = 0 if ${timevar} == 1976;
	replace structural = 0 if ${timevar} == 1976;
	replace interactcomponent = 0 if ${timevar} == 1976;
};
else {;
	replace compositional = 0 if ${timevar} == 1;
	replace structural = 0 if ${timevar} == 1;
	replace interactcomponent = 0 if ${timevar} == 1;
};
bysort ${agevar} (${timevar}): gen composition_effect = sum(compositional);
by ${agevar}: gen struct_effect = sum(structural);
by ${agevar}: gen interact_effect = sum(interactcomponent);

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
set trace on;
set tracedepth 2;
* Loop over age groups;
levelsof ${agevar}, local(agelabels);
foreach i of local agelabels {;
					line composition_effect ${timevar} if (${agevar}==`i'), $line5 ||
					line struct_effect ${timevar} if (${agevar}==`i'), $line3 ||
					line interact_effect ${timevar} if (${agevar}==`i'), $line2 ||
					line zeroed_uearnshare ${timevar} if (${agevar}==`i'), $line1 ||,
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
outsheet ${agevar} ${timevar} Luearnshare uearnshare using ${adjustvar}_${gender}.csv, comma replace;

* export data for plotting elsewhere;
sort ${timevar} ${agevar};
keep ${timevar} ${agevar}  composition_effect struct_effect interact_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using ${adjustvar}_${gender}.csv, comma replace;
