#delimit;
set more 1;
cap mkdir ${basedir}/build/output;

global basedir /Users/Brian/Documents/GitHub/AgeEarningsShare/PSID;

/* This is the main do-file for the PSID directory */;

////////////////////////////////////////////////////////////////////////////////
* BUILD DIRECTORY;
do ${basedir}/build/code/build.do;

////////////////////////////////////////////////////////////////////////////////
* STATS DIRECTORY;
* Reproduce earnings share plots as in ASEC code;
do ${basedir}/stats/code/stats.do;
