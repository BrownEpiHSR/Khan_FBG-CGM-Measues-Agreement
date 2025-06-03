#  PROGRAM NAME:		13. Phi correlations in R
#  PRIMARY PROGRAMMER:	Marzan Khan

#  LAST MODIFIED:		June 2025

#  GENERAL PURPOSE:	
#  1)Calculate the phi correlations and associated confidence intervals for cohort 2; person, day and interval level analyses

#Install required packages
install.packages("statpsych")
library(statpsych)

#############################################
#resident level analysis for cohort 2
ci.phi(0.05, 4,0,16,20)

resident<-ci.phi(0.05,  4,0,16,20)
resident_rounded<-round(resident, 2)
print (resident_rounded)

#############################################
#day level analysis for cohort 2
ci.phi(0.05, 5,2, 35,383)

day<-ci.phi(0.05, 5,2, 35,383)
day_rounded<-round(day, 2)
print (day_rounded)

#############################################

#interval level analysis for cohort 2
ci.phi(0.05, 5,2,32,753)

interval<-ci.phi(0.05, 5,2,32,753)

interval_rounded<-round(interval, 2)
print(interval_rounded)

#############################################
#Cohort 2, 10 pm to 6 am
interval2_10_6<-ci.phi(0.05,  2,1,1,147)
interval2_10_6_rounded<-round(interval2_10_6, 2)
print (interval2_10_6_rounded)

#Cohort 2, 6 am to 1 pm
interval2_6_1<-ci.phi(0.05,  2,2,2,321)
interval2_6_1_rounded<-round(interval2_6_1, 2)
print (interval2_6_1_rounded)

#Cohort 2, 2 pm to 9 pm
interval2_2_9<-ci.phi(0.05,  0,0,2,339)
interval2_2_9_rounded<-round(interval2_2_9, 2)
print (interval2_2_9_rounded)

#############################################



