#delimit;

/* Plots income share adjusted by population shares for each age group
over the years 1976-2017, using a chain-weighted decomposition */;

* Announce decomposition components for chained_table.do;
global components struct comp;
* Declare that this is OB decomp (alt=2);
global alt 2;

duplicates drop agecat year, force;

////////////////////////////////////////////////////////////////////////////////
* CHAIN-WEIGHTED DECOMP;
tsset agecat year;
gen counterfactual_mearnshare = popsharejt*L.mearnjt;
bysort year: egen counterfactual_mearnt = sum(counterfactual_mearnshare);
gen counterfactual_share = counterfactual_mearnshare/counterfactual_mearnt;

* Structural component (unexplained);
gen structural = uearnshare - counterfactual_share;

* Compositional component (explained);
tsset agecat year;
gen compositional = counterfactual_share - L.uearnshare;

* Levels, zeroed at 1976;
replace structural = 0 if year == 1976;
replace compositional = 0 if year == 1976;
bysort agecat (year): gen struct_effect = sum(structural);
by agecat: gen comp_effect = sum(compositional);

////////////////////////////////////////////////////////////////////////////////
* PLOTS FOR DECOMPOSITION;
* Loop over age groups;
foreach i in 18 25 35 45 55 65 {;	
	graph twoway 	line struct_effect year if (agecat==`i'), $line3 ||
					line comp_effect year if (agecat==`i'), $line2 ||
					line zeroed_uearnshare year if (agecat==`i'), $line1 ||,
		legend(order(
			1 "Structural Component" 
			2 "Compositional Component"
			3 "Unadjusted Shares")) 
		${plot_options};

	cd ${basedir}/stats/output/Oaxaca_Blinder;
	graph export agedecomp`i'_${gender}.png, replace;
};

* export data for plotting elsewhere;
sort year agecat;
keep year agecat struct_effect comp_effect zeroed_uearnshare uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using OB_agedecomp_${gender}.csv, comma replace;
