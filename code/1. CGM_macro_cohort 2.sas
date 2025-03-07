/**	
	PROGRAM NAME:		CGM_macro
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		December 2024

	GENERAL PURPOSE:	
		1)Create a macro that will generate day level and day-interval level CGM dataset for each person 
			in cohort 2.
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

options mprint;

*Import file containing CGM data;
%macro cgm (num);
proc import datafile="P:\gsa1z\mak\Data\CGM analysis\LTC01-0&num CGM.xlsx"
        out=person&num
        dbms=xlsx
        replace;
run;

*Extract date, hour, minutes, day, month, year from the datetime variable;
data person&num._1;
	set person&num;

	*Set length of id_connect character variable to 3;
	length id_connect $3;

	*Retain values of original person_id across all rows;
	retain id;

	*Store patient information in ID variable;
	if event_type="FirstName" then ID=patient_info;

	*remove rows where the date variable is missing so that we can start the new dataset from the row
	with CGM glucose value;
	if date~=.;

	*Extract date and time components from numeric variables into distinct new variables;
	day=day(date);
	month=month(date);
	year=year(date);
	hour=hour(time);
	minute=minute(time);

	*Set a simpler, numeric person_id value;
	id_connect="&num";

	format date date9. time time8.;
run;

*Check the unique number of dates during which CGM readings generated;
proc freq data=person&num._1;
	tables date/missing;
	title "Person &num";
run;

*Check the unique values of other variables;
proc freq data=person&num._1;
	tables day month year/missing;
	title "Person &num";
run;


proc format;
	value anynull .="Missing"
		          Other="Not missing";
run;

proc freq data=person&num._1;
	tables hour minute glucose/missing;
	format hour minute glucose anynull.;
	title "Person &num";
run;


*Check the unique values of glucose;
proc freq data=person&num._1;
	tables glucose;
	title "Person &num";
run;

*Create indicator for each day when there was any CGM value <70;
proc sql;
	create table person&num._2 as
	select id, id_connect, hour, minute,time, glucose, date, day, month, year, 
		min(glucose) as min_glucose_day, case when .< calculated min_glucose_day<70 then 1 else 0 end as hypoglycemia_day_ind
		from person&num._1 
	group by day;
quit;
*this dataset is still at the person-datetime level, not person-day level;

proc freq data=person&num._2;
	tables hypoglycemia_day_ind/missing;
	title "Person &num";
run;

*Create indicator for hypoglycemia for each day-interval when there was CGM value <70;
proc sql;
	create table person&num._3 as
	select *,
		case when 0<=hour<=7 then 1 when 8<=hour<=15 then 2 when 16<=hour<=23 then 3   end as interval,
		min(glucose) as min_glucose_interval, case when calculated min_glucose_interval<70 then 1 else 0 end as hypoglycemia_interval_ind
		from person&num._2
	group by day, interval;
quit;
*this dataset is still at the person-datetime level, not person-day-interval level;

*Bring dataset to day-interval level for person;
proc sql;
	create table cgm.person&num._cgm_intervallevel as
	select distinct id, id_connect,   date, day, month, year, interval,
		 min_glucose_interval,  hypoglycemia_interval_ind
		from person&num._3; 
quit;


*Bring dataset to day level for person;
proc sql;
	create table cgm.person&num._cgm_daylevel as
	select distinct id, id_connect,   date, day, month, year,
		 min_glucose_day,  hypoglycemia_day_ind
		from person&num._3; 
quit;


title;
%mend;

%cgm (01);
%cgm (02);
%cgm (25);
%cgm (34);
%cgm (54);
%cgm (58);
%cgm (62);
%cgm (82);
%cgm (68);
%cgm (71);
%cgm (77);
%cgm (78);
%cgm (80);
%cgm (81);
%cgm (03);
%cgm (04);
%cgm (05);
%cgm (07);
%cgm (08);
%cgm (10);
%cgm (11);
%cgm (13);
%cgm (15);
%cgm (18);
%cgm (21);
%cgm (24);
%cgm (26);
%cgm (28);
%cgm (30);
%cgm (31);
%cgm (32);
%cgm (33);
%cgm (38);
%cgm (41);
%cgm (48);
%cgm (51);
%cgm (52);
%cgm (61);
%cgm (64);
%cgm (65);
%cgm (44);
%cgm (53);
%cgm (55);
%cgm (56);
%cgm (57);
