#delimit;

////////////////////////////////////////////////////////////////////////////////

* COMPUTE STATISTICS FOR TABLE;
keep if year==1976 | year==2017;
keep agecat year uearnshare *effect;

bysort  agecat (year): gen period = _n;
egen panelvar = group(agecat);
tsset panelvar period;
gen change = D.uearnshare;
foreach comp of global components {;
	gen `comp'_contribution = D.`comp'_effect/D.uearnshare*100;
};
bysort agecat (year): gen eshare1976 = uearnshare[1];
bysort agecat (year): gen eshare2017 = uearnshare[2];

* Format table;
drop period panelvar;
drop if year == 1976;
drop year *effect uearnshare;
order agecat eshare1976 eshare2017 change *contribution;
sort agecat;
drop agecat;
xpose, clear varname;

* Rename columns after transpose;
local k = 1;
foreach i of numlist 18 25 35 45 55 65 {;
	rename v`k' ${gender}`i';
	local k = `k' + 1;
};
rename _varname quantity;
order quantity;

* Save table as .csv;
* Prefix for filename;
if $alt == 0 {;
	local prefix ;
};
else if $alt == 1 {;
	local prefix alt_;
};
else if $alt == 2{;
	local prefix OB_;
};
* Suffix for filename;
if "$gender"=="pooled" {;
	local suffix ;
};
else {;
	local suffix _${gender};
};
* Save location;
cd ${basedir}/stats/output/tables/`prefix'chained_adjustments;

if "$adjustvar"=="" {;
	outsheet using `prefix'changes_age`suffix'.csv, comma replace;
};
else if "${adjustvar}"=="male"{;
	outsheet using `prefix'changes_gender`suffix'.csv, comma replace;
};
else {;
	outsheet using `prefix'changes_${adjustvar}`suffix'.csv, comma replace;
};

