#delimit;
set more 1;
cap mkdir ${basedir}/stats/output;

/* This do-file plots demographic trends by age group from the CPS */;

use ${basedir}/build/output/ASEC.dta, clear;

////////////////////////////////////////////////////////////////////////////////
* HOUSEKEEPING;
drop if age < 18;


egen agecat = cut(age), at(18,25,55,65,75);
replace agecat = 75 if age >=75;

label define agecatlabel 18 "18-24 year olds" 25 "25-54 year olds"
	55 "55-64 year olds" 65 "65-74 year olds" 75 "75+";
label values agecat;

////////////////////////////////////////////////////////////////////////////////
collapse (mean) uhrsworkly male nonwhite [aw=asecwt], by(year agecat);
reshape wide uhrsworkly male nonwhite, i(year) j(agecat);

* Hours worked;
twoway line uhrsworkly25 uhrsworkly65 uhrsworkly75 year, 
	graphregion(color(white)) 
	ytitle("Average Weekly Hours Worked Last Year") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1)
	xsize(3.5)
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/ASEChrsworked.png, replace;
window manage close graph;

* Male composition;
twoway line male25 male65 male75 year, graphregion(color(white)) 
	ytitle("Fraction of Group that are Men") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1)
	xsize(3.5)
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/ASECmale.png, replace;

* Non-white composition;
twoway line nonwhite25 nonwhite65 nonwhite75 year, graphregion(color(white)) 
	ytitle("Fraction of Group that are Non-White") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/ASECnonwhite.png, replace;
