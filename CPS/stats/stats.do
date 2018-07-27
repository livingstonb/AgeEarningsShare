#delimit;
set more 1;
cap mkdir ${basedir}/stats/output;

global basedir /Users/Brian/Documents/GitHub/AgeEarningsShare/CPS;

////////////////////////////////////////////////////////////////////////////////
use ${basedir}/build/output/cps_yearly.dta, clear;
gen male = 1 - female;
drop female;

reshape wide laborforce bachelors uhrsworkt male nonwhite, i(date) j(agecat);

foreach val of numlist 25 65 75 {;
	local adjustvars laborforce uhrsworkt bachelors male nonwhite;
	foreach adjustvar of local adjustvars  {;
		reg `adjustvar'`val' i.month;
		matrix coeffs = e(b);
		predict `adjustvar'`val'_adj, resid;
		replace `adjustvar'`val'_adj = `adjustvar'`val'_adj + coeffs[1,13];
		matrix drop coeffs;
	};
};

twoway line laborforce25_adj laborforce65_adj laborforce75_adj date, graphregion(color(white)) 
	ytitle("Labor Force Participation Rate") xtitle("Date")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1);
graph export ${basedir}/stats/output/LFPR.png, replace;

twoway line uhrsworkt25_adj uhrsworkt65_adj uhrsworkt75_adj date
	if date >= monthly("1994 M1","YM"), graphregion(color(white)) 
	ytitle("Average Weekly Hours Usually Worked") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	tlabel(1994m1(60)2018m5)
	aspectratio(1);
graph export ${basedir}/stats/output/hrsworked.png, replace;
window manage close graph;

twoway line bachelors25_adj bachelors65_adj bachelors75_adj date, graphregion(color(white)) 
	ytitle("Fraction Having Completed 4 Years of College") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1);
graph export ${basedir}/stats/output/college.png, replace;

twoway line male25_adj male65_adj male75_adj date, graphregion(color(white)) 
	ytitle("Fraction of Group that are Men") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1);
graph export ${basedir}/stats/output/male.png, replace;

twoway line nonwhite25_adj nonwhite65_adj nonwhite75_adj date, graphregion(color(white)) 
	ytitle("Fraction of Group that are Non-White") xtitle("")
	legend(label(1 "25-54 year olds") label(2 "65-74 year olds")
		label(3 "75+ year olds"))
	legend(span)
	aspectratio(1);
graph export ${basedir}/stats/output/nonwhite.png, replace;
