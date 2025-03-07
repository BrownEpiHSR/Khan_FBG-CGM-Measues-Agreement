/**	
	PROGRAM NAME:		Day level analysis
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		December 2024

	GENERAL PURPOSE:	
		1)Conduct day level analysis of CGM and fingerstick data
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Stack day level CGM data;
proc sql noprint;
select cats("cgm.", memname)
into :daylevel_cgm
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "_CGM_DAYLEVEL" 
;
quit;

%put &daylevel_cgm;

data stacked_daylevel_cgm;
	length id $20;
	set &daylevel_cgm;
run;

*count the number of days of data per person;
proc sql;
	create table days_person_cgm as
	select id_connect, count(*) as days_person
	from stacked_daylevel_cgm
	group by id_connect;
quit;

proc sql;
	select id_connect, count(*) as days_person
	from stacked_daylevel_cgm
	group by id_connect;
quit;

*Check the distribution of the days of cgm data per person;
ods listing;
proc means data=days_person_cgm maxdec=1;
run;

ods listing;
proc means data=days_person_cgm maxdec=1 median q1 q3;
run;


*Stack day level fingerstick data;
proc sql noprint;
select cats("cgm.", memname)
into :daylevel_fs
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "_FS_DAYLEVEL" 
;
quit;

%put &daylevel_fs;

data stacked_daylevel_fs;
	set &daylevel_fs;
run;

*Calculate the number of fingerstick data per person;
proc sql;
	create table days_person_fs as
	select id_connect_fs, count(*) as days_person
	from stacked_daylevel_fs
	group by id_connect_fs;
quit;

proc sql;
	select id_connect_fs, count(*) as days_person
	from stacked_daylevel_fs
	group by id_connect_fs;
quit;

*Check the distribution of the days of fingerstick data per person;
proc means data=days_person_fs maxdec=1;
run;

*merge the fingerstick and cgm data by ID_connect and date;
proc sql;
	create table cgm.merged_daylevel as
	select *
	from stacked_daylevel_cgm as a
	inner join stacked_daylevel_fs as b
	on a.id_connect=b.id_connect_fs and a.date=b.date_num_fs;
quit;


proc format;
	value yno 1="1. Yes" 0="2. No";
run;

*Use proc frequency to generate output for day-level analysis- Table 2;
ods excel file="P:\gsa1z\mak\Output\Day level CGM and Fingerstick Analysis.xlsx" options(embedded_titles='yes');
proc freq data=cgm.merged_daylevel order=formatted;
	tables hypoglycemia_day_ind_fs*hypoglycemia_day_ind;
	format hypoglycemia_day_ind_fs hypoglycemia_day_ind yno.;
	label hypoglycemia_day_ind_fs="Fingerstick hypoglycemia" hypoglycemia_day_ind="Continuous glucose monitor hypoglycemia";
	title "Characteristics of Fingerstick Measures of Hypoglycemia versus Continuous Glucose Monitor Measures, Daily Measures (N=425).";
run;
ods excel close;
title;

*years of data in the study;
proc freq data=cgm.merged_daylevel;
	tables date;
	format date year4.;
run;

proc contents data=cgm.merged_daylevel ;
	run;

data 
