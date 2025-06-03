/**	
	PROGRAM NAME:		13. Statistics on the number of CGM and FBG readings
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1) Calculate statistics on the number of CGM and FBG readings per resident, and per resident per day.
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Stack all CGM data for the resdients;
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

*Summarize number of CGM readings per day;
proc sql;
	create table cgm_day_events as
	select distinct id_connect, date_cgm, count(glucose) as readings_perday_cgm
	from stacked_allrec_cgm
	group by id_connect, date_cgm;
quit;

*Summarize number of FBG readings per day;
proc sql;
	create table fbg_day_events as
	select distinct id_connect_fs, date_num_fs, count(glucose_num_fs) as readings_perday_fs
	from stacked_allrec_fs2
	group by id_connect_fs, date_num_fs;
quit;

*Merge the date level FBG and CGM datasets by inner join to keep records when both readings were available;
proc sql;
	create table merged_cgm_fbg_day as 
	select *
	from cgm_day_events as a
	inner join fbg_day_events as b
	on a.id_connect=b.id_connect_fs and a.date_cgm=b.date_num_fs;
quit;

*Average number of CGM and FBG readings per-resident, per-day;
proc means data=merged_cgm_fbg_day maxdec=1;
	var readings_perday_fs readings_perday_cgm;
run;

*Calculate the total number of fs readings per resident;
proc sql;
	create table perresident_stats as
	select distinct id_connect_fs, sum(readings_perday_fs) as resident_fs, sum(readings_perday_cgm) as resident_cgm
	from merged_cgm_fbg_day
	group by id_connect_fs;
quit;

*Average number of CGM and FBG readings per resident;
proc means data=perresident_stats maxdec=1;
	var resident_fs resident_cgm;
run;

