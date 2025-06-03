/**	
	PROGRAM NAME:		2. Fingerstick_macro_altered
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1)Create day-level and day-interval level fingersticks datasets for all residents combined

	CREATES DATASETS: cgm.day_fs_updated, cgm.interval_fs_updated, cgm.stacked_allrec_fs2
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Import file containing FBG data;
%macro fingerstick (num);

*Import fingerstick data;
proc import datafile="P:\gsa1z\mak\Data\CGM analysis\LTC01-0&num fingersticks.xlsx"
        out=person&num._fs
        dbms=xlsx
        replace;
run;

*Extract date, hour, minutes, day, month, year from the datetime variable;
data person&num._fs_1;
	set person&num._fs;

	length id_connect_fs $3 glucose_char_fs $5;
	if date=" " then delete;
	
	*Convert datetime character variable "date" to numeric datetime variable;
  	datetime_num = input(DATE, anydtdtm.);

	*Extract date and time components from datetime numeric variable;
	date_num_fs=datepart(datetime_num);
	time_fs=timepart(datetime_num);

	day_fs=day(date_num_fs);
	month_fs=month(date_num_fs);
	year_fs=year(date_num_fs);

	hour_fs=hour(time_fs);
	minute_fs=minute(time_fs);

	*Extract the unit of glucose value;
	glucose_unit_fs=substr(value, length(value) - 5);

	*Extract the glucose value;
	glucose_char_fs=substr(value, 1, length(value) - 5);

	*Convert the glucose value from numeric to character;
	glucose_num_fs=input(glucose_char_fs,  30.);

	*Create a simpler id variable;
	id_connect_fs="&num";
	format date_num_fs date9. time_fs time8.	datetime_num datetime20.;

	*Drop date_old otherwise there will be probelms with stacking;
	drop DATE_OLD;
run;

%mend;

%fingerstick (01);
%fingerstick (02);
%fingerstick (25);
%fingerstick (34);
%fingerstick (54);
%fingerstick (58);
%fingerstick (62);
%fingerstick (82);
%fingerstick (68);
%fingerstick (71);
%fingerstick (77);
%fingerstick (78);
%fingerstick (80);
%fingerstick (81);
%fingerstick (03);
%fingerstick (04);
%fingerstick (05);
%fingerstick (07);
%fingerstick (08);
%fingerstick (10);
%fingerstick (11);
%fingerstick (13);
%fingerstick (15);
%fingerstick (18);
%fingerstick (21);
%fingerstick (24);
%fingerstick (26);
%fingerstick (28);
%fingerstick (30);
%fingerstick (31);
%fingerstick (32);
%fingerstick (33);
%fingerstick (38);
%fingerstick (41);
%fingerstick (48);
%fingerstick (51);
%fingerstick (52);
%fingerstick (61);
%fingerstick (64);
%fingerstick (65);
%fingerstick (44);
%fingerstick (53);
%fingerstick (55);
%fingerstick (56);
%fingerstick (57);

*Stack all FS data for the residents;
proc sql noprint;
select cats("work.", memname)
into :fs_allrec
separated by ' '
from dictionary.tables
   
   /*libname and memname has to be in capital letters*/
   where libname="WORK" and memname contains "FS_" 
;
quit;

%put &FS_ALLREC;

data cgm.stacked_allrec_fs2 ;
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

*Create indicator for each day when there was FBG value <70 per-person;
proc sql;
	create table day_fs as
	select  *,
		min(Glucose_num_fs) as min_glucose_day_fs, case when  calculated min_glucose_day_fs<70 then 1 else 0 end as hypoglycemia_day_ind_fs
		from cgm.stacked_allrec_fs2
	group by id_connect_fs, day_fs
	order by id_connect_fs, day_fs, glucose_num_fs, time_fs;
quit;


*Bring dataset to day-level, keeping earliest time of minimum glucose per day;
proc sort data=day_fs out=cgm.day_fs_updated nodupkey;
	by id_connect_fs day_fs ;
run;

*Create indicator for each person-day-interval when there was FBG value <70;
proc sql;
	create table interval_fs as
	select *,
		case when 0<=hour_fs<=7 then 1 when 8<=hour_fs<=15 then 2 when 16<=hour_fs<=23 then 3   end as interval_fs,
		min(Glucose_num_fs) as min_glucose_interval_fs, case when  calculated min_glucose_interval_fs<70 then 1 else 0 end as hypoglycemia_interval_ind_fs
		from cgm.stacked_allrec_fs2 
	group by id_connect_fs, day_fs, interval_fs
	order by id_connect_fs, day_fs, interval_fs, glucose_num_fs,  time_fs ;
quit;


*Bring dataset to day-interval-level for person,  keeping earliest time of minimum glucose per interval;
proc sort data=interval_fs out=cgm.interval_fs_updated nodupkey;
	by id_connect_fs day_fs interval_fs;
run;
*1,885;
