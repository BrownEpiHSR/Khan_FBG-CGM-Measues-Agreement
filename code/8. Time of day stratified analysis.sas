/**	
	PROGRAM NAME:		8. Time of day stratified analyses
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1) Calculate diagnosistic measures and difference in time between CGM-FBG pairs stratified by times of day: 10:00 pm – 5:59 am, 6:00 am – 1:59 pm, and 2:00 pm – 9:59 pm
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Stack all CGM data for the residents;
proc sql noprint;
select cats("cgm.", memname)
into :cgm_allrec
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "CGM_ALLREC" 
;
quit;

%put &CGM_ALLREC;

data stacked_allrec_cgm;
	length id $20;
	set &CGM_ALLREC;
	datetime_cgm=dhms(date_cgm, 0,0,time_cgm);
	format datetime_cgm datetime20.;
run;

*Stack all FS data for the residents;
proc sql noprint;
select cats("cgm.", memname)
into :fs_allrec
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="CGM" and memname contains "FS_ALLREC" 
;
quit;

%put &FS_ALLREC;


data stacked_allrec_fs2 ;
	length id $20;
	set &FS_ALLREC ;
	if datetime_num=. then do;
			flag=1;
   			/* Remove all spaces */
		    Date_clean = compress(Date, ' ');

		    /* Insert a single space before the time part (assuming datetime is always of the form MM/DD/YYYYHH:MM) */
			date_char=substr(Date_clean, 1, 10);
			time_char=substr(Date_clean, 11, 5);
		    
			time_fs=input(time_char, time5.);
			date_num_fs=input(date_char, mmddyy10.);

			day_fs=day(date_num_fs);
			month_fs=month(date_num_fs);
			year_fs=year(date_num_fs);

			hour_fs=hour(time_fs);
			minute_fs=minute(time_fs);

			*you can use hour_fs, minite and second variables in the function below;
			datetime_num = dhms(date_num_fs, hour(time_fs), minute(time_fs), second(time_fs));
			format datetime_num datetime20.;

	end;
run;

*Create time blocks for fingerstick data;
data labeled_fs;
    set stacked_allrec_fs2;
    length time_block $20;
    if  hour_fs>=22 or hour_fs < 6 then time_block = "10pm–5:59am";
    else if 6 <= hour_fs < 14 then time_block = "6am–1:59pm";
    else if 14 <= hour_fs < 22 then time_block = "2pm–9:59pm";
run;

*Select minimum glucose value per interval (according to FBG), per resident;
proc sql;
    create table min_glucose as
    select distinct id_connect_fs,
           date_num_fs,
           time_block,
           glucose_num_fs , 
			time_fs, datetime_num
    from labeled_fs
    group by id_connect_fs, date_num_fs,time_block
    having glucose_num_fs = min(glucose_num_fs)
	order by id_connect_fs, date_num_fs,time_block, time_fs ;
quit;

*Keep one glucose value per interval, per resident on a given day: lowest value, earliest time;
proc sort data=min_glucose out=min_gluc_dist nodupkey dupout=dupcheck;
	by id_connect_fs date_num_fs time_block;
run;

*To each minimum FBG glucose value per interval, join all CGM data rows;
*Calculate difference in time between CGM and FBG values and keep rows where that value is less than or equal to
8 hours or 480 minutes;
proc sql;
    create table match_cgm as
    select a.id_connect_fs,
           a.date_num_fs,
		   a.glucose_num_fs,
           a.time_fs,
		   a.time_block,
		   a.datetime_num,
           b.glucose as glucose_cgm,
		   b.time_cgm,
		   b.datetime_cgm,
           (abs(a.datetime_num - b.datetime_cgm))/60 as time_diff_8int
    from min_gluc_dist as a
    left join stacked_allrec_cgm as b
    on a.id_connect_fs = b.id_connect
	where calculated time_diff_8int<=480
	order by id_connect_fs, date_num_fs, time_block, time_diff_8int, time_cgm
    ;
quit;

*Per interval and day, keep the lowest time difference, and earliest measure of CGM for corresponding FBG (achieved with the order by statement in the previous proc sql step;
proc sort data=match_cgm out=final nodupkey;
	by id_connect_fs date_num_fs time_block;
run;

*Check the time_block variable;
proc freq data=final;
	tables time_block;
run;

*Create indicator for hypoglycemia according to CGM and FBG;
data final1;
	set final;
	if glucose_num_fs<70 then block_hypo_fs=1; else block_hypo_fs=0;
	if glucose_cgm<70 then block_hypo_cgm=1; else block_hypo_cgm=0;
run;

proc sort data=final1;
	by time_block;
run;

proc format;
	value yno 1="1. Yes" 0="2. No";
run;

*Plot the distribution of the difference in time between pairs of CGM-FBG measures;
ods pdf file="P:\gsa1z\mak\Output\Time diff histogram_8int_May23.pdf" dpi=300;
title;
ods select histogram; 
proc univariate data=final1 noprint;
	by time_block;
	histogram time_diff_8int;
	inset N mean std min max/format=8.1 position=ne;
run;
ods pdf close;

*Calculate diagnostic measures;
proc freq data=final1 order=formatted;
	tables block_hypo_fs*block_hypo_cgm;
	by time_block;
	format block_hypo_fs block_hypo_cgm yno.;
	label block_hypo_fs="Fingerstick hypoglycemia" block_hypo_cgm="Continuous glucose monitor hypoglycemia";
	title "Characteristics of Fingerstick Measures of Hypoglycemia versus Continuous Glucose Monitor Measures, Stratified by time of day.";
run;
