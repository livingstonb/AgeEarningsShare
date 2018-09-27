#delimit;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file plots demographic trends by age group from the CPS */;

use ${basedir}/build/output/ASEC.dta, clear;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;

cap drop agecat;
label drop agecatlabel;

* gen agecat = 25 if age>=25 & age<=54;
* replace agecat = 55 if age>=55 & age<.;
* label define agecatlabel 25 "25-54 year olds" 55 "55+";

egen agecat = cut(age), at(18,25,35,55,65);
replace agecat = 65 if age >=65 & age<.;
label define agecatlabel 18 "18-24 year olds" 25 "25-34 year olds"
	35 "35-54 year olds"
	55 "55-64 year olds" 65 "65+";
label values agecat;

drop if agecat == .;

////////////////////////////////////////////////////////////////////////////////
collapse (mean) weeklyhours male nonwhite [aw=asecwt], by(year agecat);
reshape wide weeklyhours male nonwhite, i(year) j(agecat);

* Hours worked;
twoway line weeklyhours25 weeklyhours35 weeklyhours55 weeklyhours65 year, 
	graphregion(color(white)) 
	ytitle("Average Weekly Hours Worked Last Year") xtitle("")
	legend(label(1 "25-34 year olds") 
		label(2 "35-54 year olds")
		label(3 "55-64 year olds")
		label(4 "65+ year olds"))
	legend(span)
	aspectratio(1)
	xsize(3.5)
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white))
	bgcolor(white);
graph export ${basedir}/stats/output/ASEChrsworked.png, replace;
window manage close graph;

* Male composition;
twoway line male25 male35 male55 male65 year, graphregion(color(white)) 
	ytitle("Fraction of Group that are Men") xtitle("")
	legend(label(1 "25-34 year olds") 
		label(2 "35-54 year olds")
		label(3 "55-64 year olds")
		label(4 "65+ year olds"))
	legend(span)
	aspectratio(1)
	xsize(3.5)
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/ASECmale.png, replace;

* Non-white composition;
twoway line nonwhite25 nonwhite35 nonwhite55 nonwhite65 year, graphregion(color(white)) 
	ytitle("Fraction of Group that are Non-White") xtitle("")
	legend(label(1 "25-34 year olds") 
		label(2 "35-54 year olds")
		label(3 "55-64 year olds")
		label(4 "65+ year olds"))
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/ASECnonwhite.png, replace;
