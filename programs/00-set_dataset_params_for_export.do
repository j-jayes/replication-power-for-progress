** This file reads in the census data and prepares it for export to this folder

*---------------------------------------------------*
* Stata Dofile: Data Preparation for Power for Progress*
*---------------------------------------------------*

clear all
set more off 

* Setting the working directory

cd "/Users/jonathanjayes/Documents/PhD/paper-3-analysis/"

*---------------------------------------------------*
* Initial Data Import
*---------------------------------------------------*

* Load the dataset for the 1930 census
use "data/census/1930_census_regression_dataset_excl_unbalanced_controls.dta"

*---------------------------------------------------*
* Encoding and Variable Creation
*---------------------------------------------------*

* Encoding the abbreviated schooling and marital status variables
egen schooling = group(schooling_abb), label
egen marital = group(marital_status), label
egen hisclass = group(hisclass_group_abb), 
egen hisco_code_2_d = group(hisco_code_2_digit)

* Drop the original abbreviated columns as they are no longer needed
drop schooling_abb
drop marital_status
drop hisclass_group_abb
drop hisco_code_2_digit

*---------------------------------------------------*
* Parameter and Label Settings
*---------------------------------------------------*

* Set local parameters for data trimming
* local distance_cutoff = 300
local age_low = 15
local age_high = 100

* Assign labels to variables for clarity in tables and models
label var id "ID"
label var log_income "Log Income"
label var log_wealth "Log Wealth"
label var employed "Occupation listed"
label var occ_title_without_income "Has occupational title but no income"
label var electricity_job_direct "Electricity in Job (Direct)"
label var electricity_job_indirect "Electricity in Job (Indirect)"
label var age "Age"
label var age_2 "Age Squared"
label var female "Female (1 = Yes 0 = No)"
label var marital "Marital Status"
label var hisclass "Hisclass Group Abbreviation"
label var schooling "Schooling Abbreviation"
label var birth_parish_treated "Birth Parish (Treated)"
label var current_parish_treated "Current Parish (Treated)"
label var birth_parish_distance_to_line "Birth Parish Distance to Line"
label var current_parish_distance_to_line "Current Parish Distance to Line"
label var birth_parish_touching_treated "Birth Parish Touching Treated"
label var current_parish_touching_treated "Current Parish Touching Treated"
label var dist_bp_to_cp_km "Distance from birth parish to current parish"
label var hisco_code_2_d "HISCO code two digit"
label var railway_in_birth_parish "Railway in Birth Parish"
label var railway_in_current_parish "Railway in Current Parish"
label var schooling_above_primary "Schooling above primary"
label var mean_farm_hh_in_parish_1910 "Mean farming households in parish in 1910"
label var urban_parish_1910 "Parish has more non-farming households than avg in 1910"
// label var inc_score_1930 "Income score in 1930"
// label var log_inc_score_1930 "Log income score in 1930"

*---------------------------------------------------*
* Data Cleaning and Trimming
*---------------------------------------------------*

* Drop observations based on distance and age parameters
* drop if birth_parish_distance_to_line > `distance_cutoff'
drop if `age_low' > age | `age_high' < age

* List all variables in the dataset
ds

* Store a list of variables excluding certain ones
local varlist = r(varlist)
local varlist: subinstr local varlist "log_wealth" "", all
local varlist: subinstr local varlist "hisclass" "", all
local varlist: subinstr local varlist "log_income" "", all
local varlist: subinstr local varlist "occ_title_without_income" "", all
local varlist: subinstr local varlist "union_density_1890" "", all
local varlist: subinstr local varlist "union_density_1900" "", all
local varlist: subinstr local varlist "union_density_1910" "", all
local varlist: subinstr local varlist "union_density_1930" "", all
local varlist: subinstr local varlist "hisco_code_2_d" "", all
local varlist: subinstr local varlist "railway_in_birth_parish" "", all
local varlist: subinstr local varlist "railway_in_current_parish" "", all


local varlist: subinstr local varlist "schooling_above_primary" "", all
local varlist: subinstr local varlist "mean_farm_hh_in_parish_1910" "", all
local varlist: subinstr local varlist "urban_parish_1910" "", all

// local varlist: subinstr local varlist "inc_score_1930" "", all
// local varlist: subinstr local varlist "log_inc_score_1930" "", all


* Create an indicator for any missing value across all variables
egen anymissing = rmiss(`varlist')

* Drop observations with any missing value
drop if anymissing != 0

* Remove the temporary missing indicator variable
drop anymissing


// * Step 1: List all variables
// ds
// local allvars `r(varlist)'
//
// * Step 2: Define variables to exclude
// local exclude log_wealth hisclass log_income occ_title_without_income ///
//     union_density_1890 union_density_1900 union_density_1910 union_density_1930 ///
//     hisco_code_2_d railway_in_birth_parish railway_in_current_parish ///
//     schooling_above_primary mean_farm_hh_in_parish_1910 urban_parish_1910 ///
//     inc_score_1930 log_inc_score_1930
//
// * Step 3: Create list of vars to keep (i.e., those NOT in exclude list)
// local varlist
// foreach var of local allvars {
//     if !strpos(" `exclude' ", " `var' ") {
//         local varlist `varlist' `var'
//     }
// }
//
// * Step 4: Create a missingness indicator and drop incomplete rows
// egen anymissing = rmiss(`varlist')
// drop if anymissing != 0
// drop anymissing


*---------------------------------------------------*
* Rename and relabel
*---------------------------------------------------*

rename birth_parish_treated western_line_parish

label var western_line_parish "Western Line Parish"

rename current_parish_treated western_line_parish_dweller

label var western_line_parish_dweller "Western Line Parish Dweller"

*---------------------------------------------------*
* Final Data Save
*---------------------------------------------------*

* Save the cleaned dataset with parameters set
* save "C:\Users\User\Documents\Recon\paper-3-analysis\data\census\1930_census_regression_dataset_params_set.dta", replace
save "/Users/jonathanjayes/Documents/PhD/paper-3-analysis/replication_jan_25/raw_data/power-for-progress-1930-census_raw.dta", replace

