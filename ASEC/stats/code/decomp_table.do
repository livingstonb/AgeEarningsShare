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
keep ${agevar} ${timevar} uearnshare *effect;

bysort  ${agevar} (${timevar}): gen period = _n;
egen panelvar = group(${agevar});
tsset panelvar period;

* Change in unadjusted earnings share;
gen change = D.uearnshare;
* Components of decomposition;
foreach comp of global components {;
	gen `comp'_contribution = D.`comp'_effect/D.uearnshare*100;
};
* 1976 and 2016/2017 earnings shares;
	bysort ${agevar} (${timevar}): gen eshare1976 = uearnshare[1];
	bysort ${agevar} (${timevar}): gen eshare2017 = uearnshare[2];

* Format table;
drop period panelvar;
if "${timevar}"=="year" {;
	drop if ${timevar} == 1976;
};
else {;
	drop if ${timevar} == 9;
};
drop ${timevar} *effect uearnshare;
order ${agevar} eshare1976 eshare2017 change *contribution;
sort ${agevar};
levelsof ${agevar}, local(agelabels);
drop ${agevar};
xpose, clear varname;

local k = 1;
foreach i of local agelabels {;
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

