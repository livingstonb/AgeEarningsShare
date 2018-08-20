#delimit;

////////////////////////////////////////////////////////////////////////////////

* COMPUTE STATISTICS FOR TABLE;
keep if year==1976 | year==2017;
keep agecat year uearnshare *effect;

bysort  agecat (year): gen period = _n;
egen panelvar = group(agecat);
tsset panelvar period;
gen change = D.uearnshare;
local components age $adjustvar earnings;
foreach comp of local components {;
	gen `comp'contribution = D.`comp'effect/D.uearnshare*100;
};
drop period panelvar;

bysort agecat (year): gen eshare1976 = uearnshare[1];
bysort agecat (year): gen eshare2017 = uearnshare[2];
drop if year == 1976;
drop year *effect uearnshare;
if "$adjustvar"=="" {;
	order agecat eshare1976 eshare2017 change agecontribution
		earningscontribution;
};
else {;
	order  agecat eshare1976 eshare2017 change agecontribution ${adjustvar}contribution
		earningscontribution;
};
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

if "$adjustvar"=="" {;
	cd ${basedir}/stats/output/agedecomp;
	outsheet using ${alt}changes_${gender}.csv, comma replace;
};
else {;
	cd ${basedir}/stats/output/${alt}chained_adjustments/${adjustvar};
	if "$gender"=="pooled" {;
		outsheet using ${alt}changes_${adjustvar}.csv, comma replace;
	};
	else {;
		outsheet using ${alt}changes_${adjustvar}_${gender}.csv, comma replace;
	};
};


