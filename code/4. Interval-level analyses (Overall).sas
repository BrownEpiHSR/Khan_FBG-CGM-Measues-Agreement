/**	
	PROGRAM NAME:		4. Interval-level analyses (Overall)
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025
	GENERAL PURPOSE:	
		1) Calculate diagnostic measures
		2) Calculate difference in time between pairs of CGM-FBG measures
		3) Calculate prevalence of hypoglycemia
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Stack all INTERVAL-level CGM data for the residents;
proc sql noprint;
select cats("cgm.", memname)
into :cgm_interval_alt
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "INTERVAL_CGM_ALT" 
;
quit;

%put &cgm_interval_alt;

data stacked_interval_cgm;
	length id $20;
	set &cgm_interval_alt;
	datetime_cgm=dhms(date, 0,0,time);
	format datetime_cgm datetime20.;
run;

*Connect the CGM and FBG data (interval level) and calculate the difference in time (minutes) between
CGM-FBG pairs;
proc sql;
	create table merged_data as 
	select *,abs(a.datetime_cgm-b.datetime_num)/60 as time_diff_int
	from stacked_INTERVAL_cgm as a
	inner join cgm.interval_fs_updated as b
	on a.id_connect=b.id_connect_fs and a.date=b.date_num_fs and a.interval=b.interval_fs;
quit;

*Plot a distribution of the difference in time (minutes) between corresponding
CGM-FBG pairs within 8-hour intervals;
proc univariate data=merged_data;
	histogram time_diff_int;
	inset N mean std min max/format=8.1 position=ne;
run;

proc format;
	value yno 1="1. Yes" 0="2. No";
run;

*Calculate diagnositic measures at the interval level (Overall);
ods excel file="P:\gsa1z\mak\Output\Interval level CGM and Fingerstick Analysis_stratified.xlsx" options(embedded_titles='yes');

proc freq data=merged_data order=formatted;
	tables hypoglycemia_interval_ind_fs*hypoglycemia_interval_ind;
	format hypoglycemia_interval_ind hypoglycemia_interval_ind_fs yno.;
/*	label block_hypo_fs="Fingerstick hypoglycemia" block_hypo_cgm="Continuous glucose monitor hypoglycemia";*/
	title "Characteristics of Fingerstick Measures of Hypoglycemia versus Continuous Glucose Monitor Measures, Interval-level.";
run;
title;
ods excel close;

*Calculate the prevalence of hypoglycemia at the 8-hour interval level;
*FS;
proc freq data=merged_data;
	tables hypoglycemia_interval_ind_fs;
run;

*CGM;
proc freq data=merged_data;
	tables hypoglycemia_interval_ind;
run;
