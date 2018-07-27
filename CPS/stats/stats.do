#delimit;
set more 1;
cap mkdir ${basedir}/stats/output;

global basedir /Users/Brian/Documents/GitHub/AgeEarningsShare/CPS;

////////////////////////////////////////////////////////////////////////////////
use ${basedir}/build/output/cps_yearly.dta, clear;

reshape wide laborforce bachelors uhrsworkt, i(date) j(agecat);

foreach val of numlist 25 65 75 {;
	reg laborforce`val' i.month;
	predict labadjusted`val', resid;
	matrix coeffs`val' = e(b);
	replace labadjusted`val' = labadjusted`val' + coeffs[1,13];
};

twoway line labadjusted25 labadjusted65 labadjusted75 date, graphregion(color(white)) 
	ytitle("Labor Force Participation Rate") xtitle("Date")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	aspectratio(1);
graph export ${basedir}/stats/output/LFPR.png, replace;

twoway line uhrsworkt25 uhrsworkt65 uhrsworkt75 date
	if date >= monthly("1994 M1","YM"), graphregion(color(white)) 
	ytitle("Average Weekly Hours Usually Worked") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	tlabel(1994m1(60)2018m5)
	aspectratio(1);
graph export ${basedir}/stats/output/hrsworked.png, replace;
window manage close graph;

twoway line bachelors25 bachelors65 bachelors75 date
	if date >= monthly("1994 M1","YM"), graphregion(color(white)) 
	ytitle("Fraction Having Completed 4 Years of College") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1);
graph export ${basedir}/stats/output/college.png, replace;
