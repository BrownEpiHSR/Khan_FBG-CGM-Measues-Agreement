# Khan_FBG-CGM-Measues-Agreement
Khan et al-Agreement Between Fingerstick Blood Glucose and Continuous Glucose Monitor Measures Among Long-Term Care Facility Residents.

# Description
This repository contains data documentation and code for the analysis in the manuscript titled Agreement Between Fingerstick Blood Glucose and Continuous Glucose Monitor Measures Among Long-Term Care Facility Residents.
## Repository Contents
- `data_documentation/` - Contains files describing the data sources, and key variables
- `code/` - The programs used for data management and analysis.
- `LICENSE` - The license under which this repository is shared.
- `README.md` - This file, provides an overview of the repository.
## Data Documentation
The `data_documentation/` directory contains the following files:
Data_Documentation_CGM-FBG Agreement.xlsx <

## Code
The `code/` directory contains the following programs:
 1. CGM_macro_altered.sas - <Create day-level and day-interval level CGM datasets for each person>
 2. Fingerstick_macro_altered.sas - <Create day-level and day-interval level fingersticks datasets for all residents combined>
 3. Day-level and person-level analyses.sas - <Conduct day- and person-level analysis of CGM and fingerstick data>
 4. Interval-level analyses (Overall).sas <Conduct interval- level analysis of CGM and fingerstick data>
 5. CGM_macro_allevents.R <Create a macro that will process excel sheets containing CGM data of residents and create sas datasets, with an indicator for hypoglycemia for every CGM record>
 6. Fingerstick_macro_allevents.sas <Create a macro that will process excel sheets containing FBG data of residents and create sas datasets, with an indicator for hypoglycemia for every CGM record>
 7. Number of hypoglycemia events per person.sas <Calculate the number of hypoglycemia events per resident captured by CGM and FBG and create a scatter plot>
 8. Time of day stratified analysis.sas <
 9. Time difference_lowest FBG-nearest CGM_8hour overall.sas<>
 10. Time difference_lowest FBG-nearest CGM_day-level.sas <>
 11. Statistics on the number of CGM and FBG readings.sas <>
 12. Demographics_cohort 2 <>
 13. Phi correlations in R <>

Programs were run in sequence to produce the study findings.
<The analytic code for Cohort 2 has been made available on GitHub. While the analysis code for Cohort 1 is fundamentally the same, it has not been uploaded due to data privacy policies>
