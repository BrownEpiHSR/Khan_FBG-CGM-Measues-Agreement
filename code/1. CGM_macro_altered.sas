/**	
	PROGRAM NAME:		1. CGM_macro_altered
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1)Create day-level and day-interval level CGM datasets for each person

	CREATEs DATASETS: cgm.person&num._day_cgm_alt, cgm.person&num._interval_cgm_alt
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

	*Set date of birth as a numeric variable;
/*	if event_type="DateOfBirth" then dob=patient_info;*/
	if event_type="FirstName" then ID=patient_info;

	*remove rows where the date variable is missing so that we can start the new dataset from the row
	with CGM glucose value;
	if date~=.;

/*	date=datepart(&datetime);*/
/*	time=timepart(&datetime);*/

	*Extract date and time from numeric date variable into distinct new variables;
	day=day(date);
	month=month(date);
	year=year(date);
	hour=hour(time);
	minute=minute(time);

	*Set a simpler, numeric person_id value;
	id_connect="&num";

	format date date9. time time8.;
run;


*Create indicator for each day when there was min CGM value <70;
proc sql;
	create table person&num._2 as
	select id, id_connect, hour, minute,time, glucose, date, day, month, year, 
		min(glucose) as min_glucose_day, case when .< calculated min_glucose_day<70 then 1 else 0 end as hypoglycemia_day_ind
		from person&num._1 
	group by day
	order by  day, glucose,  time;
quit;
*this dataset is still at the person-datetime level, not person-day level;

proc sort data=person&num._2 out=cgm.person&num._day_cgm_alt nodupkey;
	by day ;
run;

*Create indicator for hypoglycemia for each day-interval when there was CGM value <70;
proc sql;
	create table person&num._3 as
	select *,
		case when 0<=hour<=7 then 1 when 8<=hour<=15 then 2 when 16<=hour<=23 then 3   end as interval,
		min(glucose) as min_glucose_interval, case when calculated min_glucose_interval<70 then 1 else 0 end as hypoglycemia_interval_ind
		from person&num._2
	group by day, interval
	order by  day, interval, glucose,  time ;
quit;
*this dataset is still at the person-datetime level, not person-day-interval level;

*Bring dataset to day-interval level for person;
proc sort data=person&num._3 out=cgm.person&num._interval_cgm_alt nodupkey;
	by day interval;
run;

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


