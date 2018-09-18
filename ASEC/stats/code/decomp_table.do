#delimit;

/* After performing decomposition, produces decomposition table and saves as 
csv */;

////////////////////////////////////////////////////////////////////////////////
* COMPUTE STATISTICS FOR TABLE;
if "${timevar}"=="year" {;	
	keep if ${timevar}==1976 | ${timevar}==2017;
};
else {;
	keep if ${timevar}==1 | ${timevar}==9;
};
keep agecat ${timevar} uearnshare *effect;

bysort  agecat (${timevar}): gen period = _n;
egen panelvar = group(agecat);
tsset panelvar period;

* Change in unadjusted earnings share;
gen change = D.uearnshare;
* Components of decomposition;
foreach comp of global components {;
	gen `comp'_contribution = D.`comp'_effect/D.uearnshare*100;
};
* 1976 and 2016/2017 earnings shares;
	bysort agecat (${timevar}): gen eshare1976 = uearnshare[1];
	bysort agecat (${timevar}): gen eshare2017 = uearnshare[2];

* Format table;
drop period panelvar;
if "${timevar}"=="year" {;
	drop if ${timevar} == 1976;
};
else {;
	drop if ${timevar} == 9;
};
drop ${timevar} *effect uearnshare;
order agecat eshare1976 eshare2017 change *contribution;
sort agecat;
drop agecat;
xpose, clear varname;

local k = 1;
foreach i of numlist 18 25 35 45 55 65 {;
	rename v`k' ${gender}`i';
	local k = `k' + 1;
};
rename _varname quantity;
order quantity;

* Save table as .csv;
* Save location;
cd ${basedir}/stats/output/tables/${adjustvar};

if "$adjustvar"=="male"{;
	outsheet using gender.csv, comma replace;
};
else {;
	outsheet using ${adjustvar}_${gender}.csv, comma replace;
};

