/**	
	PROGRAM NAME:		CGM_macro_allevents
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1) Create a macro that will process excel sheets containing CGM data of residents and create sas datasets;
		2) There will be an indicator for hypoglycemia for every CGM record per resident

	CREATES DATASETS: cgm.person&num._cgm_allrec 
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
	set person&num ;

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
	day_cgm=day(date);
	month_cgm=month(date);
	year_cgm=year(date);
	hour_cgm=hour(time);
	minute_cgm=minute(time);

	*Set a simpler, numeric person_id value;
	id_connect="&num";
	rename date=date_cgm time=time_cgm;

	format date date9. time time8.;
run;

*Create indicator for record when any CGM value <70-to indicate hypoglycemia;
proc sql;
	create table cgm.person&num._cgm_allrec as
	select id, id_connect, hour_cgm, minute_cgm,time_cgm, glucose, date_cgm, day_cgm, month_cgm, year_cgm, 
		 case when .< glucose<70 then 1 else 0 end as hypoglycemia_ind_cgm
		from person&num._1 ;
quit;

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
