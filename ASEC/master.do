#delimit;
set more 1;
cap mkdir ${basedir}/build/output;

global basedir /Users/Brian/Documents/GitHub/AgeEarningsShare/ASEC;

////////////////////////////////////////////////////////////////////////////////
do ${basedir}/build/code/build.do;
do ${basedir}/stats/code/stats.do;
