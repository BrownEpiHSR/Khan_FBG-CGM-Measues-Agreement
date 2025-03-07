/**	
	PROGRAM NAME:		Interval level analysis
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		December 2024

	GENERAL PURPOSE:	
		1)Conduct interval level analysis of CGM and fingerstick data
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Stack INTERVAL level CGM data;
proc sql noprint;
select cats("cgm.", memname)
into :INTERVALlevel_cgm
separated by ' ' 
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "_CGM_INTERVALLEVEL" 
;
quit;

%put &INTERVALlevel_cgm;

data stacked_INTERVALlevel_cgm;
	length id dob $20;
	set &INTERVALlevel_cgm;
run;

*Stack INTERVAL level fingerstick data;
proc sql noprint;
select cats("cgm.", memname)
into :INTERVALlevel_fs
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "_FS_INTERVALLEVEL" 
;
quit;

%put &INTERVALlevel_fs;

data stacked_INTERVALlevel_fs;
	set &INTERVALlevel_fs;
run;

*merge the fs and cgm data by ID_connect and date;
proc sql;
	create table cgm.merged_INTERVALlevel as
	select *
	from stacked_INTERVALlevel_cgm as a
	inner join stacked_INTERVALlevel_fs as b
	on a.id_connect=b.id_connect_fs and a.date=b.date_num_fs and a.interval=b.interval_fs;
quit;

*Count the distinct number of persons who connected from both datasets;
proc sql;
	select count(distinct id_connect_fs) as merged_n
	from cgm.merged_INTERVALlevel;
quit;

*Keep distinct ids in CGM data;
proc sql;
	create table CGM_all_int as
	select distinct id_connect
	from stacked_intervallevel_cgm;
quit;

proc format;
	value yno 1="1. Yes" 0="2. No";
run;

*Generate output for Table 4;
ods excel file="P:\gsa1z\mak\Output\Interval level CGM and Fingerstick Analysis.xlsx" options(embedded_titles='yes');
proc freq data=cgm.merged_intervallevel order=formatted;
	tables hypoglycemia_interval_ind_fs*hypoglycemia_interval_ind;
	format hypoglycemia_interval_ind_fs hypoglycemia_interval_ind yno.;
	label hypoglycemia_interval_ind_fs="Fingerstick hypoglycemia" hypoglycemia_interval_ind="Continuous glucose monitor hypoglycemia";
	title "Characteristics of Fingerstick Measures of Hypoglycemia versus Continuous Glucose Monitor Measures, Every 8-Hour Measures (N=790).";
run;
ods excel close;
title;

