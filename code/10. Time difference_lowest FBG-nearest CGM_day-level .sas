/**	
	PROGRAM NAME:		10. Time difference_lowest FBG-nearest CGM_day-level
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1) Calculate difference in time between pairs of the CGM-FBG measures at the day-level,
			with the lowest glucose value and the nearest CGM measure in time (regardless of the glucose value, i.e., not necessarily the lowest)
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

			datetime_num = dhms(date_num_fs, hour(time_fs), minute(time_fs), second(time_fs));
			format datetime_num datetime20.;

	end;
run;

*Select minimum glucose value per interval (according to FBG), per resident;
proc sql;
    create table min_glucose as
    select distinct id_connect_fs,
           date_num_fs,
           glucose_num_fs , 
			time_fs, datetime_num
    from stacked_allrec_fs2
    group by id_connect_fs, date_num_fs
    having glucose_num_fs = min(glucose_num_fs)
	order by id_connect_fs, date_num_fs, time_fs ;
quit;

*Keep one glucose value per interval, per person on a given day: lowest value, earliest time;
proc sort data=min_glucose out=min_gluc_dist nodupkey dupout=dupcheck;
	by id_connect_fs date_num_fs ;
run;

*To each minimum FBG glucose value per interval, join all CGM data rows;
*Calculate difference in time between CGM and FBG values and keep rows where that value is less than or equal to 8 hours or 480 minutes;
proc sql;
    create table match_cgm as
    select a.id_connect_fs,
           a.date_num_fs,
		   a.glucose_num_fs,
           a.time_fs,
		  
		   a.datetime_num,
           b.glucose as glucose_cgm,
		   b.time_cgm,
		   b.datetime_cgm,
           (abs(a.datetime_num - b.datetime_cgm))/60 as time_diff_day
    from min_gluc_dist as a
    left join stacked_allrec_cgm as b
    on a.id_connect_fs = b.id_connect
	where calculated time_diff_day<=480
	/*	*/
	order by id_connect_fs, date_num_fs, time_diff_day, time_cgm
    ;
quit;

*Per day, keep the lowest time difference, and earliest measure of CGM for corresponding FBG (achieved with the order by statement in the previous proc sql step;
proc sort data=match_cgm out=final nodupkey;
	by id_connect_fs date_num_fs;
run;

*Create indicator for hypoglycemia according to CGM and FBG;
data final1;
	set final;
	if glucose_num_fs<70 then block_hypo_fs=1; else block_hypo_fs=0;
	if glucose_cgm<70 then block_hypo_cgm=1; else block_hypo_cgm=0;
run;

*Plot the distribution of the difference in time between pairs of CGM-FBG measures;
ods pdf file="P:\gsa1z\mak\Output\Time diff histogram_day_method2.pdf" dpi=300;
title;
ods select histogram;
proc univariate data=final1 noprint;
	histogram time_diff_day;
	inset N mean std min max/format=8.1 position=ne;
run;
ods pdf close;

