/**	
	PROGRAM NAME:		3. Day-level and person-level analyses
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1) Calculate diagnostic measures at the day- and person-levels
		2) Calculate difference in time between pairs of CGM-FBG measures at the day-level
		3) Calculate day- and person-level prevalence of hypoglycemia according to CGM and FBG

	CREATES DATASETS: 
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Stack all day-level CGM data for the residents;
proc sql noprint;
select cats("cgm.", memname)
into :cgm_day_alt
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "DAY_CGM_ALT" 
;
quit;

%put &cgm_day_alt;

data stacked_day_cgm;
	length id $20;
	set &cgm_day_alt;
	datetime_cgm=dhms(date, 0,0,time);
	format datetime_cgm datetime20.;
run;

*Merge CGM data with FBG data on id and date and calculate the difference in time
between pairs of the lowest CGM and FBG values per day;
*cgm.day_fs_updated was created in program 2;
proc sql;
	create table merged_data as 
	select *,abs(a.datetime_cgm-b.datetime_num)/60 as time_diff_day
	from stacked_day_cgm as a
	inner join cgm.day_fs_updated as b
	on a.id_connect=b.id_connect_fs and a.date=b.date_num_fs;
quit;

*Plot the distribution of the difference in time between pairs of the lowest CGM and FBG values per day;
title;
ods noproctitle;
proc univariate data=merged_data;
	histogram time_diff_day;
	inset N mean std min max/format=8.1 position=ne;
run;

proc format;
	value yno 1="1. Yes" 0="2. No";
run;

*Asseess diagnostic measures at the day level;
proc freq data=merged_data order=formatted;
	tables hypoglycemia_day_ind_fs*hypoglycemia_day_ind;
	format hypoglycemia_day_ind hypoglycemia_day_ind_fs yno.;
	label block_hypo_fs="Fingerstick hypoglycemia" block_hypo_cgm="Continuous glucose monitor hypoglycemia";
	title "Characteristics of Fingerstick Measures of Hypoglycemia versus Continuous Glucose Monitor Measures, Day-level.";
run;

*Prevalence of hypoglycemia at the day level in cohort 2, measured by FBG and CGM;
*FS;
proc freq data=merged_data;
	tables hypoglycemia_day_ind_fs;
run;

proc freq data=merged_data;
	tables hypoglycemia_day_ind;
run;

*******************************************************************************************************************************;
*Calculate person-level prevalence using day-level data;
proc sql;
	create table person_prev as 
	select distinct id_connect, max(hypoglycemia_day_ind) as person_cgm, max(hypoglycemia_day_ind_fs) as person_fbg
	from merged_data
	group by id_connect;
quit;

*Person-level prevalence of hypoglycemia using CGM and FBG measures;
proc freq data=person_prev;
	tables person_cgm person_fbg;
run;

*Person-level diagnostic measures;
proc freq data=person_prev order=formatted;
	tables  person_fbg*person_cgm;
	format person_cgm person_fbg yno.;
run;

********************************************************************************************************************************;
