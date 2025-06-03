/**	
	PROGRAM NAME:		7. Number of hypoglycemia events per resident
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1)Calculate the number of hypoglycemia events per resident captured by CGM and FBG and 
			create a scatter plot
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Stack day all CGM data for the residents;
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

*Stack day all FS data for the residents;
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

*Summarize number of hypoglycemia events per day-CGM;
proc sql;
	create table cgm_day_events as
	select distinct id_connect, date_cgm, sum(hypoglycemia_ind_cgm) as events_day_cgm
	from stacked_allrec_cgm
	group by id_connect, date_cgm;
quit;

*Summarize number of hypoglycemia events per day-FBG;
proc sql;
	create table fbg_day_events as
	select distinct id_connect_fs, date_num_fs, sum(hypoglycemia_ind_fs) as events_day_fs
	from stacked_allrec_fs2
	group by id_connect_fs, date_num_fs;
quit;

*Merge the date level FBG and CGM datasets by inner join to keep records when both readings were available;
proc sql;
	create table cgm.merged_cgm_fbg as 
	select *
	from cgm_day_events as a
	inner join fbg_day_events as b
	on a.id_connect=b.id_connect_fs and a.date_cgm=b.date_num_fs;
quit;

*Calculate the total number of hypoglycemia events per person (according to CGM and FBG)
across all days when both CGM and DBG readings were available;
proc sql;
	create table num_hypo_cgm_fbg as
	select distinct id_connect, sum(events_day_fs) as hypoglycemia_fs, sum(events_day_cgm) as hypoglycemia_cgm
	from cgm.merged_cgm_fbg
	group by id_connect;
quit;

*Check the distribution of hypoglycemmia events per person;
proc means data=num_hypo_cgm_fbg;
	var hypoglycemia_fs hypoglycemia_cgm;
run;

*Generate scatter plot of hypoglycemia events per FBG vs per CGM;
title;
options nodate nonumber;
ods pdf file="P:\gsa1z\mak\Output\Figure 1.pdf" dpi=300;
proc sgplot data=num_hypo_cgm_fbg noborder;
    scatter x=hypoglycemia_cgm y=hypoglycemia_fs / markerattrs=(symbol=circlefilled size=16 color="#5e3c99") ;
/*            size=event_count datalabel=event_count;*/
/*	lineparm x=0 y=0 slope=1 / lineattrs=(pattern=shortdash color=gray thickness=1);*/
/*    title "Scatter Plot of Hypoglycemia Event Counts Per Resident During Follow-up";*/
    xaxis label="Number of CGM-identified hypoglycemia events" VALUEATTRS=(Family='Arial' size=14) LABELATTRS=(family="Arial" size=14 ) ;
    yaxis label="Number of FBG-identified hypoglycemia events" values=(0 1,2)VALUEATTRS=(Family='Arial' size=14 ) LABELATTRS=(family="Arial" size=14 ) ;
run;
ods pdf close;



