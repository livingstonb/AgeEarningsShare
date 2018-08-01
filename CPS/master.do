#delimit;
set more 1;
cap mkdir ${basedir}/build/output;

/* This is the main do-file for the CPS Basic Survey */;

global basedir /Users/brianlivingston/Documents/GitHub/AgeEarningsShare/CPS;

////////////////////////////////////////////////////////////////////////////////
* BUILD DIRECTORY;
do ${basedir}/build/code/build.do;

////////////////////////////////////////////////////////////////////////////////
* STATS DIRECTORY;
do ${basedir}/stats/code/stats.do;
