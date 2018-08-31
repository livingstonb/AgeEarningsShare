#delimit;
set more 1;
cap mkdir ${basedir}/build/output;

global basedir /Users/Brian/Documents/GitHub/AgeEarningsShare/ASEC;

/* This is the main do-file */;

////////////////////////////////////////////////////////////////////////////////
* BUILD DIRECTORY;
do ${basedir}/build/code/build.do;

////////////////////////////////////////////////////////////////////////////////
* STATS DIRECTORY;

* Plot chained-weighted decomp of income shares, adjusting by various factors;
do ${basedir}/stats/code/decomp1_main.do;

* Plot demographic trends;
do ${basedir}/stats/code/demographic_plots.do;

* Compare 1976 and 2017 income shares;
do ${basedir}/stats/code/changes_table.do;

* Compare median hourly earnings, 1994 and 2017;
do ${basedir}/stats/code/hourly_earnings_bar.do;

