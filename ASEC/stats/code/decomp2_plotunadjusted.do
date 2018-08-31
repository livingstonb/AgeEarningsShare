#delimit;
set more 1;

duplicates drop year agecat, force;
local k = 6;
foreach i in 18 25 35 45 55 65 {;
	local incplots `incplots' line uearnshare year if (agecat==`i'), ${line`k'} ||;
	local k = `k' - 1;
};
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

graph twoway `incplots', legend(order(`ages')) 
	graphregion(color(white)) 
	xtitle("") ytitle("") xlabel(1976(10)2017)
	legend(region(lcolor(white)))
	bgcolor(white)
	legend(span)
	aspectratio(1)
	xsize(3)
	ysize(3.5)
	scale(1.4);
cd ${basedir}/stats/output/stata_plots;
graph export uearnshare_${gender}.png, replace;

* export data for plotting elsewhere;
sort agecat year;
keep agecat year uearnshare;
cd ${basedir}/stats/output/plot_data;
outsheet using unadjusted_${gender}.csv, comma replace;
