#delimit;

/* Plots income share adjusted by population shares and one other variable,
for each age group over the years 1976-2017 */;

* Announce decomposition components for chained_table.do;
global components age interact earnings ${adjustvar};
drop popsharejt;

////////////////////////////////////////////////////////////////////////////////
* Population share of $adjustvar;
bysort year ${adjustvar}: egen popkt = sum(asecwt);
gen popsharekt = popkt/popt;

* Population share of age groups within age $adjustvar group;
bysort year agecat $adjustvar: egen popkjt = sum(asecwt);
gen popsharekjt = popkjt/popkt;

* Mean group earnings;
bysort year agecat $adjustvar: egen earnkjt = sum(asecwt*incwage);
gen mearnkjt	= earnkjt/popkjt;

duplicates drop agecat year $adjustvar, force;

////////////////////////////////////////////////////////////////////////////////
egen panelvar = group(agecat $adjustvar);

* TRANSFORM VARIABLES TO ORIGINAL VARIABLE ORDER;

*** Lagged unadjusted;
tsset panelvar year;
gen temp_terms = L.popsharekt*L.popsharekjt;
bysort year agecat: egen popsharejt = sum(temp_terms);
tsset panelvar year;
gen popsharejkt = L.popsharekjt*L.popsharekt/popsharejt;
gen mearnjkt = L.mearnkjt;

do ${basedir}/stats/code/decomp_transformation;
rename counterfactual_share Luearnshare;


duplicates drop agecat year, force;

/* For checking error in unadjusted earnshare estimate, compare true unadjusted
shares with lagged shares computed with identity */;
sort agecat year;
cap mkdir ${basedir}/stats/output/error;
cd ${basedir}/stats/output/error;
outsheet agecat year Luearnshare uearnshare using ${adjustvar}_${gender}.csv, comma replace;

////////////////////////////////////////////////////////////////////////////////
* LEVELS;

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


* export data for plotting elsewhere;
sort year agecat;
keep year agecat earnings_effect age_effect ${adjustvar}_effect interact_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using ${adjustvar}_${gender}.csv, comma replace;
