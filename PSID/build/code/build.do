#delimit;
clear*;
set maxvar 30000;
set more 1;

/* Appends family datasets by year and performs basic data cleaning */;

////////////////////////////////////////////////////////////////////////////////
* 1971;
cd $basedir/build/input;
use fam1971er/fam1971er.dta, clear;
gen year = 1971;

* Income;
rename V1892 hwage;
rename V1897 htotlabor;

* Other variables;
rename V2321 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1971er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1973;
cd $basedir/build/input;
use fam1973er/fam1973er.dta, clear;
gen year = 1973;

* Income;
rename V3046 hwage;
rename V3051 htotlabor;

* Other variables;
rename V3301 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1973er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1975;
cd $basedir/build/input;
use fam1975er/fam1975er.dta, clear;
gen year = 1975;

* Income;
rename V3858 hwage;
rename V3863 htotlabor;

* Other variables;
rename V4224 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1975er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1977;
cd $basedir/build/input;
use fam1977er/fam1977er.dta, clear;
gen year = 1977;

* Income;
rename V5283 hwage;
rename V5627 htotlabor;

* Other variables;
rename V5665 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1977er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1979;
cd $basedir/build/input;
use fam1979er/fam1979er.dta, clear;
gen year = 1979;

* Income;
rename V6391 hwage;
rename V6767 htotlabor;

* Other variables;
rename V6805 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1979er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1981;
cd $basedir/build/input;
use fam1981er/fam1981er.dta, clear;
gen year = 1981;

* Income;
rename V7573 hwage;
rename V8066 htotlabor;

* Other variables;
rename V8103 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1981er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1983;
cd $basedir/build/input;
use fam1983er/fam1983er.dta, clear;
gen year = 1983;

* Income;
rename V8873 hwage;
rename V9376 htotlabor;

* Other variables;
rename V9433 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1983er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1985;
cd $basedir/build/input;
use fam1985er/fam1985er.dta, clear;
gen year = 1985;

* Income;
rename V11397 hwage;
rename V12372 htotlabor;

* Other variables;
rename V12446 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1985er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1987;
cd $basedir/build/input;
use fam1987er/fam1987er.dta, clear;
gen year = 1987;

* Income;
rename V13898 hwage;
rename V14671 htotlabor;

* Other variables;
rename V14737 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1987er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1989;
cd $basedir/build/input;
use fam1989er/fam1989er.dta, clear;
gen year = 1989;

* Income;
rename V16413 hwage;
rename V17534 htotlabor;

* Other variables;
rename V17612 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1989er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1991;
cd $basedir/build/input;
use fam1991er/fam1991er.dta, clear;
gen year = 1991;

* Income;
rename V19129 hwage;
rename V20178 htotlabor;

* Other variables;
rename V20245 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1991er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1993;
cd $basedir/build/input;
use fam1993er/fam1993er.dta, clear;
gen year = 1993;

* Income;
rename V21739 hwage;
rename V22817 wwage; /* Need to convert from hourly */;
rename V23323 htotlabor;

* Other variables;
rename V23363 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1993er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1995;
cd $basedir/build/input;
use fam1995er/fam1995er.dta, clear;
gen year = 1995;

* Income;
rename ER6962 hwage;
rename ER6480 wwage; /* Need to convert from hourly */;
rename ER6980 htotlabor;

* Other variables;
rename ER7000B wgt;

drop ER*;
cd $basedir/build/temp;
save fam1995er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1997;
cd $basedir/build/input;
use fam1997er/fam1997er.dta, clear;
gen year = 1997;

* Income;
rename ER12196 hwage;
rename ER11491 wwage;
rename ER12080 htotlabor;

* Other variables;
rename ER12084 wgt;

drop ER*;
cd $basedir/build/temp;
save fam1997er_temp, replace;
////////////////////////////////////////////////////////////////////////////////
* 1999;
cd $basedir/build/input;
use fam1999er/fam1999er.dta, clear;
gen year = 1999;

* Income;
rename ER16462 y;
rename ER16493 hwage;
rename ER14757 wwage;
rename ER16463 htotlabor;

* Other variables;
rename ER16518 wgt;
rename ER16516 headeduc;
rename ER16517 speduc;
rename ER13004 stateres;
rename ER15928 headrace1;
rename ER15836 sprace1;
rename ER13010 headage;
rename ER13012 spage;

* Wealth variables;
rename ER15002 bus;

drop ER*;
cd $basedir/build/temp;
save fam1999er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2001;
cd $basedir/build/input;
use fam2001er/fam2001er.dta, clear;
gen year = 2001;

* Income;
rename ER20456 y;
rename ER20425 hwage;
rename ER18930 wwage;
rename ER20443 htotlabor;

* Other variables;
rename ER20394 wgt;
rename ER20457 headeduc;
rename ER20458 speduc;
rename ER17004 stateres;
rename ER19989 headrace1;
rename ER19897 sprace1;
rename ER17013 headage;
rename ER17015 spage;
rename ER17002 intid;
rename ER17022 famnum;

* Wealth variables;
rename ER19198 bus;

drop ER*;
cd $basedir/build/temp;
save fam2001er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2003;
cd $basedir/build/input;
use fam2003er/fam2003er.dta, clear;
gen year = 2003;

* Income;
rename ER24099 y;
rename ER24117 hwage;
rename ER22300 wwage;
rename ER24116 htotlabor;

* Other variables;
rename ER24179 wgt;
rename ER24148 headeduc;
rename ER24149 speduc;
rename ER21003 stateres;
rename ER23426 headrace1;
rename ER23334 sprace1;
rename ER21017 headage;
rename ER21019 spage;
rename ER21002 intid;
rename ER21009 famnum;

* Wealth variables;
rename ER22563 bus;

drop ER*;
cd $basedir/build/temp;
save fam2003er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2005;
cd $basedir/build/input;
use fam2005er/fam2005er.dta, clear;
gen year = 2005;

* Income;
rename ER28037 y;
rename ER27913 hwage;
rename ER26281 wwage;
rename ER27931 htotlabor;

* Other variables;
rename ER28078 wgt;
rename ER28047 headeduc;
rename ER28048 speduc;
rename ER25003 stateres;
rename ER27393 headrace1;
rename ER27297 sprace1;
rename ER25017 headage;
rename ER25019 spage;
rename ER25002 intid;
rename ER25009 famnum;

* Wealth variables;
rename ER26544 bus;

drop ER*;
cd $basedir/build/temp;
save fam2005er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2007;
cd $basedir/build/input;
use fam2007er/fam2007er.dta, clear;
gen year = 2007;

* Income;
rename ER41027 y;
rename ER40903 hwage;
rename ER37299 wwage;
rename ER40921 htotlabor;

* Other variables;
rename ER41069 wgt;
rename ER41037 headeduc;
rename ER41038 speduc;
rename ER36003 stateres;
rename ER40565 headrace1;
rename ER40472 sprace1;
rename ER36017 headage;
rename ER36019 spage;
rename ER36002 intid;
rename ER36009 famnum;

* Wealth variables;
rename ER37562 bus;

drop ER*;
cd $basedir/build/temp;
save fam2007er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2009;
cd $basedir/build/input;
use fam2009er/fam2009er.dta, clear;
gen year = 2009;

* Income;
rename ER46935 y;
rename ER46811 hwage;
rename ER43290 wwage;
rename ER46829 htotlabor;

* Other variables;
rename ER47012 wgt;
rename ER46981 headeduc;
rename ER46982 speduc;
rename ER42003 stateres;
rename ER46543 headrace1;
rename ER46449 sprace1;
rename ER42017 headage;
rename ER42019 spage;
rename ER42002 intid;
rename ER42009 famnum;

* Wealth variables;
rename ER46942 checking;
rename ER46950 othrealestate;
gen    othrealestatedebt = 0;
rename ER46954 stocks;
rename ER46956 vehic;
rename ER46960 othassets;
rename ER46964 ira;
gen	   ccdebt = 0;
local zerovars studentdebt medicaldebt legaldebt famdebt;
foreach zerovar of local zerovars {;
	gen `zerovar' = 0;
};
rename ER46946 othdebt;
rename ER46966 homeequity;
rename ER46970 networth;
rename ER46968 networthnohomeequity;
rename ER43553 bus;

drop ER*;
cd $basedir/build/temp;
save fam2009er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2011;
cd $basedir/build/input;
use fam2011er/fam2011er.dta, clear;
gen year = 2011;

* Income;
rename ER52343 y;
rename ER52219 hwage;
rename ER48615 wwage;
rename ER52237 htotlabor;

* Other variables;
rename ER52436 wgt;
rename ER52405 headeduc;
rename ER52406 speduc;
rename ER47303 stateres;
rename ER51904 headrace1;
rename ER51810 sprace1;
rename ER47317 headage;
rename ER47319 spage;
rename ER47302 intid;
rename ER47309 famnum;

* Wealth variables;
rename ER52350 checking;
rename ER52354 othrealestate;
gen    othrealestatedebt = 0;
rename ER52358 stocks;
rename ER52360 vehic;
rename ER52364 othassets;
rename ER52368 ira;
rename ER52372 ccdebt;
rename ER52376 studentdebt;
rename ER52380 medicaldebt;
rename ER52384 legaldebt;
rename ER52388 famdebt;
gen    othdebt = 0;
rename ER52390 homeequity;
rename ER52394 networth;
rename ER52392 networthnohomeequity;
rename ER48878 bus;

drop ER*;
cd $basedir/build/temp;
save fam2011er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2013;
cd $basedir/build/input;
use fam2013er/fam2013er.dta, clear;
gen year = 2013;

* Income;
rename ER58152 y;
rename ER58020 hwage;
rename ER54309 wwage;
rename ER58038 htotlabor;

* Other variables;
rename ER58257 wgt;
rename ER58223 headeduc;
rename ER58224 speduc;
rename ER53003 stateres;
rename ER57659 headrace1;
rename ER57549 sprace1;
rename ER53017 headage;
rename ER53019 spage;
rename ER53002 intid;
rename ER53009 famnum;

* Wealth variables;
rename ER58161 checking;
rename ER58165 othrealestate;
rename ER58167 othrealestatedebt;
rename ER58171 stocks;
rename ER58173 vehic;
rename ER58177 othassets;
rename ER58181 ira;
rename ER58185 ccdebt;
rename ER58189 studentdebt;
rename ER58193 medicaldebt;
rename ER58197 legaldebt;
rename ER58201 famdebt;
rename ER58205 othdebt;
rename ER58207 homeequity;
rename ER58211 networth;
rename ER58209 networthnohomeequity;
rename ER54625 bus;
replace bus = bus - ER54629;

drop ER*;
cd $basedir/build/temp;
save fam2013er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* 2015;
cd $basedir/build/input;
use fam2015er/fam2015er.dta, clear;
gen year = 2015;

* Income;
rename ER65349 y;
rename ER65200 hwage;
rename ER61349 wwage;
rename ER65216 htotlabor;

* Other variables;
rename ER65492 wgt;
rename ER65459 headeduc;
rename ER65460 speduc;
rename ER60003 stateres;
rename ER64810 headrace1;
rename ER64671 sprace1;
rename ER60017 headage;
rename ER60019 spage;
rename ER60002 intid;
rename ER60009 famnum;

* Wealth variables;
rename ER65358 checking;
rename ER65362 othrealestate;
rename ER65364 othrealestatedebt;
rename ER65368 stocks;
rename ER65370 vehic;
rename ER65374 othassets;
rename ER65378 ira;
rename ER65382 ccdebt;
rename ER65386 studentdebt;
rename ER65390 medicaldebt;
rename ER65394 legaldebt;
rename ER65398 famdebt;
rename ER65402 othdebt;
rename ER65404 homeequity;
rename ER65408 networth;
rename ER65406 networthnohomeequity;
rename ER61736 bus;
rename ER61740 busdebt;

drop ER*;
cd $basedir/build/temp;
save fam2015er_temp, replace;

////////////////////////////////////////////////////////////////////////////////
* DEFLATE BY CPI-U-RS;

local lagvars	;

local deflatevars	;

////////////////////////////////////////////////////////////////////////////////
* APPEND YEARS;
cd $basedir/build/temp;
use fam1999er_temp, clear;
forvalues yrind = 2001(2)2015 {;
	append using fam`yrind'er_temp.dta;
};

////////////////////////////////////////////////////////////////////////////////
* CLEANING;
replace othrealestatedebt 	= 0 if year <= 2011;
replace ccdebt 				= 0 if year <= 2009;
replace studentdebt 		= 0 if year <= 2009;
replace medicaldebt 		= 0 if year <= 2009;
replace legaldebt 			= 0 if year <= 2009;

gen trunchwage = 1 if inlist(hwage,999999,9999999);

rename headage 	age;
rename spage 	agew;
rename stateres state;

////////////////////////////////////////////////////////////////////////////////
* SAVE;
cd $basedir/build/temp;
save PSID_wealth1.dta, replace;

