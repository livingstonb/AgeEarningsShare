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
* Plot income shares by age group and year;
do ${basedir}/stats/code/incshare_plots.do;

* Plot demographic trends;
do ${basedir}/stats/code/demographic_plots.do;

* Compare 1976 and 2017 income shares;
do ${basedir}/stats/code/changes_table.do;
