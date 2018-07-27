#delimit;
set more 1;
cap mkdir ${basedir}/build/output;

global basedir /Users/Brian/Documents/GitHub/AgeEarningsShare/CPS;

////////////////////////////////////////////////////////////////////////////////
* CLEAN DATA;
* Read IPUMS data;
use ${basedir}/build/input/cps.dta, clear;

* Code missing values;
replace educ = .	if educ == 999;
replace	uhrsworkt = . if inlist(uhrsworkt,997,999);
drop if age < 16;

////////////////////////////////////////////////////////////////////////////////
* GENERATE NEW VARIABLES;
egen agecat = cut(age), at(18,25,65,75);
replace agecat = 75 if age >=75;

label define agecatlabel 18 "18-25 year olds" 25 "25-54 year olds"
	65 "65-74" 75 "75+";
label values agecat agecatlabel;

gen laborforce = 1 if labforce == 2;
replace laborforce = 0 if labforce == 1;

gen bachelors = 1 if (educ>=110) & (educ<.);
replace bachelors = 0 if (educ>=2) & (educ<110);

gen yyyym = string(year) + " m" + string(month);
gen date = monthly(yyyym,"YM");
format date %tm;
 

////////////////////////////////////////////////////////////////////////////////
* COLLAPSE TO YEAR;
collapse (mean) laborforce bachelors uhrsworkt month, by(date agecat);
reg laborforce i.month;
predict labadjusted, resid;
matrix coeffs = e(b);
replace labadjusted = labadjusted + coeffs[1,13];

reshape laborforce bachelors uhrsworkt, i(date) j(agecat);

twoway line labadjusted65 date, graphregion(color(white)) 
	ytitle("Labor Force Participation Rate") xtitle("Year-Month");

save ${basedir}/build/output/cps_yearly.dta, replace;
