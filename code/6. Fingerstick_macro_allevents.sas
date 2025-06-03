/**	
	PROGRAM NAME:		6. Fingerstick_macro_allevents
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1) Create a macro that will process excel sheets containing FBG data of residents and create SAS datasets;
		2) There will be an indicator for hypoglycemia for every FBG record per resident
	
	CREATES DATASETS: cgm.person&num._FS_allrec 
		
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
	drop date_old;
/*	drop c d;*/
run;

*Create indicator for each record when glucose value was <70;
proc sql;
	create table cgm.person&num._fs_allrec as
	select  *,
		 case when glucose_num_fs<70 then 1 else 0 end as hypoglycemia_ind_fs
		from person&num._fs_1 ;
quit;

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

