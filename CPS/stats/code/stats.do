#delimit;
set more 1;
cap mkdir ${basedir}/stats/output;

/* Plots demographic trends using data from the CPS Basic Survey */;

////////////////////////////////////////////////////////////////////////////////
use ${basedir}/build/output/cps_yearly.dta, clear;

reshape wide laborforce bachelors uhrsworkt male nonwhite, i(year) j(agecat);

* LFPR;
twoway line laborforce25 laborforce65 laborforce75 laborforce55 year, graphregion(color(white)) 
	ytitle("Labor Force Participation Rate") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds") label(4 "55-64"))
	legend(span)
	aspectratio(1)
	xsize(3.5)
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/LFPR.png, replace;

* Hours worked;
twoway line uhrsworkt25 uhrsworkt65 uhrsworkt75 year
	if year>=1994, graphregion(color(white)) 
	ytitle("Average Weekly Hours Usually Worked") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1)
	xsize(3.5)
	legend(region(lcolor(white)))
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/hrsworked.png, replace;
window manage close graph;

* Bachelor's degree or higher;
twoway line bachelors25 bachelors65 bachelors75 year, graphregion(color(white)) 
	ytitle("Fraction Having Completed 4 Years of College") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1)
	xsize(3.5)
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/college.png, replace;

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
graph export ${basedir}/stats/output/male.png, replace;

* Nonwhite composition;
twoway line nonwhite25 nonwhite65 nonwhite75 year, graphregion(color(white)) 
	ytitle("Fraction of Group that are Non-White") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(region(lcolor(white)))
	xlabel(1976(5)2017)
	graphregion(lcolor(white));
graph export ${basedir}/stats/output/nonwhite.png, replace;
