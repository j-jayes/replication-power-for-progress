/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual 
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      master_data_prep.do
* Purpose:      This is the master script to prepare all necessary data files
* for analysis from the raw 1930 census data.
* It should be run once before executing individual table/figure
* scripts.
*
*
* Last-updated: 12 June 2025
*
*******************************************************************************/

*===============================================================================
* SETUP
*===============================================================================

clear
global project_path "/Users/jonathanjayes/Documents/PhD/paper-3-analysis/replication_jan_25"

cd "$project_path"

global output_dir "output/"
cap mkdir "$output_dir"

global distance_threshold 300

* Install necessary community-contributed packages if not already present
ssc install estout, replace
net install oaxaca, replace from(https://raw.githubusercontent.com/benjann/oaxaca/main/)


*===============================================================================
* CREATE ANALYSIS-SPECIFIC DATASETS
*===============================================================================

* --- Create the data for Table 4 (Employment Regressions) ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
save "data/table-4.dta", replace


* --- Create the data for Table 5 (Income Regressions, Full Sample) ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0
save "data/table-5.dta", replace


* --- Create the data for Table 6 (Oaxaca Decomposition) ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0
save "data/table-6.dta", replace


* --- Create the data for Table 7 (Mean Incomes by Job Type) ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0
save "data/table-7.dta", replace


* --- Create the data for Table 8 (Education Interaction) ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
save "data/table-8.dta", replace


* --- Create the data for Table 15 (Union Density) ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0
save "data/table-15.dta", replace


* --- CREATE INCOME SCORE FILE (for Table 20) ---
* This block creates a separate file with the national median income
* for each occupation-gender group. This is the "income score".
use "raw_data/power-for-progress-1930-census_raw.dta", clear
* Keep only employed individuals with income to calculate the median
drop if employed == 0
drop if income_1930 == .
* Calculate the median income (p50) by occupation (hisco) and sex
collapse (p50) inc_score_1930 = income_1930, by(hisco sex)
* Save the cleaned income score file for use in table-20.do
compress
save "data/inc_score_1930_foranalysis.dta", replace


* --- Create the data for Table 21 (Quantile Regressions) ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0
save "data/table-21.dta", replace


* --- Create the data for Table 25 (Parish-Level Regressions) ---
* This section creates two parish-level datasets, one aggregated by
* parish of residence and one by parish of birth.

* Part A: Aggregate by Current Parish of Residence
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if current_parish_distance_to_line > $distance_threshold
tabulate hisclass, generate(hisclass_)
collapse (sum) hisclass_*, by(current_parish_ref_code)
gen total_labor_force = hisclass_1 + hisclass_2 + hisclass_3 + hisclass_4 + hisclass_5 + hisclass_6 + hisclass_7
forvalues i = 1/7 {
    gen hisclass_`i'_share = hisclass_`i' / total_labor_force
}
drop total_labor_force hisclass_*
save "raw_data/hisclass_shares_current_parish.dta", replace

use "raw_data/power-for-progress-1930-census_raw.dta", clear
collapse (mean) western_line_parish_dweller log_income age schooling_above_primary railway_in_current_parish, by(current_parish_ref_code)
merge 1:1 current_parish_ref_code using "raw_data/hisclass_shares_current_parish.dta"
drop _merge
save "raw_data/mean_vars_current_parish.dta", replace

import delimited "data/swedish_parish_1930_points.csv", clear
merge 1:1 current_parish_ref_code using "raw_data/mean_vars_current_parish.dta", keep(match) nogen
save "data/table-25-1.dta", replace


* Part B: Aggregate by Parish of Birth
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
tabulate hisclass, generate(hisclass_)
collapse (sum) hisclass_*, by(birth_parish_ref_code)
gen total_labor_force = hisclass_1 + hisclass_2 + hisclass_3 + hisclass_4 + hisclass_5 + hisclass_6 + hisclass_7
forvalues i = 1/7 {
    gen hisclass_`i'_share = hisclass_`i' / total_labor_force
}
drop total_labor_force hisclass_*
save "raw_data/hisclass_shares_birth_parish.dta", replace

use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
collapse (mean) western_line_parish log_income age schooling_above_primary railway_in_birth_parish, by(birth_parish_ref_code)
merge 1:1 birth_parish_ref_code using "raw_data/hisclass_shares_birth_parish.dta"
drop _merge
save "raw_data/mean_vars_birth_parish.dta", replace

import delimited "data/swedish_parish_1930_points.csv", clear
rename current_parish_ref_code birth_parish_ref_code
merge 1:1 birth_parish_ref_code using "raw_data/mean_vars_birth_parish.dta", keep(match) nogen
save "data/table-25-2.dta", replace


* --- Create the data for Table 28 ---
use "raw_data/power-for-progress-1930-census_raw.dta", clear
drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0
save "data/table-28.dta", replace
