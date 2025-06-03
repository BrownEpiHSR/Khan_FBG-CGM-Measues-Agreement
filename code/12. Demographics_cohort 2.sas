/**	
	PROGRAM NAME:		Demographics
	PRIMARY PROGRAMMER:	Marzan Khan

	LAST MODIFIED:		May 2025

	GENERAL PURPOSE:	
		1) Obtain demographic statisitics for the cohort
**/

*Library where datasets will be saved;
libname cgm "P:\gsa1z\mak\Data\CGM_output";

*Import the file containing demographic information for all of cohort 2;
proc import datafile="P:\gsa1z\mak\Data\CGM - Copy\FINAL_CGM in LTC_BrownData.xlsx"
        out=demog
        dbms=xlsx
        replace;
run;

*rename some variables;
data demog2 (rename=(var5=diabetes var6=gender var7=race));
	set demog;
run;

*Create a new table and keep records from the demog file that match ids in cgm.merged_daylevel (this dataset contains final cohort with CGM and
FBG on the same days;
*Note that merged_data was created in program 3;
proc sql;
	create table distinct_person as
	select *
	from demog2
	where id_connect in (select id_connect from merged_data);
quit;

*Check the distribution of age in cohort 2;
proc means data=distinct_person maxdec=1;
run;

proc freq data=distinct_person;
	tables gender race;
run;
