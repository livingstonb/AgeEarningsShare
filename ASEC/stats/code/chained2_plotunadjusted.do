#delimit;
set more 1;

duplicates drop year agecat, force;
foreach i in 18 25 35 45 55 65 {;
	local incplots `incplots' line uearnshare year if (agecat==`i'), lwidth(${linethickness}) ||;
};
local ages 1 "Ages 18-24" 2 "Ages 25-34" 3 "Ages 35-44" 4 "Ages 45-54" 5 "Ages 55-64" 6 "Ages 65+";

graph twoway `incplots', legend(order(`ages')) 
	graphregion(color(white)) 
	xtitle("") ytitle("") xlabel(1976(5)2017)
	legend(region(lcolor(white)))
	bgcolor(white)
	legend(span)
	aspectratio(1)
	xsize(3.5)
	ysize(3.8);
cd ${basedir}/stats/output/unadjusted;
graph export uearnshare_${gender}.png, replace;
