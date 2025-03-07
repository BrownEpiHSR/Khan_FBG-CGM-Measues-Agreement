/**	
	PROGRAM NAME:		Fingerstick_macro
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		December 2024

	GENERAL PURPOSE:	
		1)Create a macro that will create day level and day-interval level fingersticks dataset for each person
		in cohort 2
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Import file containing CGM data;
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

run;


*Check the unique number of datetime values during which CGM readings generated;
proc freq data=person&num._fs_1;
	tables date;
	title "Person &num";
run;


*Check the unique values of date-related variables;
proc freq data=person&num._fs_1;
	tables day_fs month_fs year_fs;
	title "Person &num";
run;

proc format;
	value anynull .="Missing"
		          Other="Not missing";
run;

proc freq data=person&num._fs_1;
	tables day_fs month_fs year_fs hour_fs minute_fs glucose_num_fs;
	format day_fs month_fs year_fs hour_fs minute_fs glucose_num_fs anynull.;
run;


*Check the unique values of glucose;
proc freq data=person&num._fs_1;
	tables Glucose_num_fs;
	title "Person &num";
run;

*Create indicator for each day when there was CGM value <70;
proc sql;
	create table person&num._fs_2 as
	select  *,
		min(Glucose_num_fs) as min_glucose_day_fs, case when  calculated min_glucose_day_fs<70 then 1 else 0 end as hypoglycemia_day_ind_fs
		from person&num._fs_1 
	group by day_fs;
quit;

proc freq data=person&num._fs_2;
	tables hypoglycemia_day_ind_fs;
	title "Person &num";
run;

*Create a dataset with the unit of glucose value;
proc sql;
	create table cgm.unit_fs_&num as
	select distinct glucose_unit_fs, &num as id
	from person&num._fs_1;
quit;

*Create indicator for each person-day-interval when there was CGM value <70;
proc sql;
	create table person&num._fs_3 as
	select *,
		case when 0<=hour_fs<=7 then 1 when 8<=hour_fs<=15 then 2 when 16<=hour_fs<=23 then 3   end as interval_fs,
		min(Glucose_num_fs) as min_glucose_interval_fs, case when  calculated min_glucose_interval_fs<70 then 1 else 0 end as hypoglycemia_interval_ind_fs
		from person&num._fs_2
	group by day_fs, interval_fs;
quit;

*Bring dataset to day-interval level for the person;
proc sql;
	create table cgm.person&num._fs_intervallevel as
	select distinct id_connect_fs, date_num_fs, day_fs, month_fs, year_fs, interval_fs,
		 min_glucose_interval_fs,  hypoglycemia_interval_ind_fs
		from person&num._fs_3; 
quit;

*Bring dataset to day level for the person;
proc sql;
	create table cgm.person&num._fs_daylevel as
	select distinct id_connect_fs, date_num_fs, day_fs, month_fs, year_fs,
		 min_glucose_day_fs,  hypoglycemia_day_ind_fs
		from person&num._fs_3; 
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


