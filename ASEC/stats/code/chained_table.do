#delimit;

////////////////////////////////////////////////////////////////////////////////
if $pooled == 1 {;
	local gendervar;
};
else {;
	local gendervar male;
};

* COMPUTE STATISTICS FOR TABLE;
keep if year==1976 | year==2017;
keep `gendervar' agecat year uearnshare *effect;

bysort `gendervar' agecat (year): gen period = _n;
egen panelvar = group(`gendervar' agecat);
tsset panelvar period;
gen change = D.uearnshare;
local components age $adjustvar earnings;
foreach comp of local components {;
	gen `comp'contribution = D.`comp'effect/D.uearnshare*100;
};
drop period panelvar;

bysort `gendervar' agecat (year): gen eshare1976 = uearnshare[1];
bysort `gendervar' agecat (year): gen eshare2017 = uearnshare[2];
drop if year == 1976;
drop year *effect uearnshare;
order `gendervar' agecat eshare1976 eshare2017 change agecontribution ${adjustvar}contribution
	earningscontribution;
sort `gendervar' agecat;
drop `gendervar' agecat;
xpose, clear varname;
if $pooled == 1 {;
	local genders pooled;
};
else {;
	local genders female male;
};
set varabbrev off;
local k = 1;
foreach gend of local genders {;
	foreach i of numlist 18 25 35 45 55 65 {;
		rename v`k' `gend'`i';
		local k = `k' + 1;
	};
};

rename _varname quantity;
order quantity;

cd ${basedir}/stats/output/${alt}chained_adjustments/${adjustvar};
save ${adjustvar}_changes.dta, replace;

