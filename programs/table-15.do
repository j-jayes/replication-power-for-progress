/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-15.do
* Purpose:      Replicates Table 15: Share of Parishes with Union Membership Data.
* This table documents the data completeness of the union
* membership records for the main analysis sample of parishes
* across key census years.
*
*
* Last-updated: 12 June 2025
*
*******************************************************************************/

*===============================================================================
* SETUP
*===============================================================================

clear
eststo clear
cd "$project_path"


*===============================================================================
* STEP 1: PREPARE DATA
*===============================================================================

* --- Part A: Create a master list of the 1,314 study parishes ---
* We use one of the main analysis files to get a unique list of all parishes
* included in the study's regressions.
use "data/table-5.dta", clear
keep birth_parish_ref_code
duplicates drop
tempfile master_parish_list
save `master_parish_list'

* --- Part B: Load and prepare the union membership data ---
* NOTE: The Folkrörelsearkivet data is provided as 25 separate files, one
* per county (län). This script assumes they have been appended into a
* single file named 'union_membership_1881-1950.dta'.
use "raw_data/union_membership_1881-1950.dta", clear

* Reshape data from wide to long format
* This creates a dataset with one observation per parish-year
rename GEOKOD birth_parish_ref_code
reshape long MEDLEM, i(birth_parish_ref_code) j(year)

* Keep only observations where there are union members
drop if MEDLEM == 0 | MEDLEM == .

* Collapse to parish-year level. Any parish with data will be kept.
collapse (count) MEDLEM, by(birth_parish_ref_code year)
tempfile union_data_long
save `union_data_long'


*===============================================================================
* STEP 2: CALCULATE COMPLETENESS FOR EACH YEAR
*===============================================================================

* Use postfile to build the final summary table row by row
postfile table15 year data_present data_missing share_complete total_parishes ///
    using "data/table-15-data.dta", replace

foreach y of numlist 1880 1890 1900 1910 1930 {
    use `master_parish_list', clear
    local total = _N

    * Merge with union data for the specific year `y'
    merge 1:1 birth_parish_ref_code using `union_data_long' if year == `y', nogen

    * Count parishes with data present
    count if _merge == 3
    local present = r(N)

    * Calculate missing and share
    local missing = `total' - `present'
    local share = (`present' / `total') * 100

    * Post the results for year `y' to the new dataset
    post table15 (`y') (`present') (`missing') (`share') (`total')
}
postclose table15


*===============================================================================
* STEP 3: FORMAT AND EXPORT FINAL TABLE
*===============================================================================

* Load the newly created summary dataset
use "data/table-15-data.dta", clear

* Format variables for a clean display
format data_present data_missing total_parishes %12.0gc
format share_complete %4.2f

* Export the final table to LaTeX using esttab
esttab . using "$output_dir/table-15.tex", replace booktabs noobs nonumbers ///
    cells("year data_present data_missing share_complete total_parishes") ///
    title("Share of Parishes with Union Membership Data") ///
    collabels("Year" "Data Present" "Data Missing" "Share Complete" "Total number of Parishes") ///
    postfoot("\bottomrule") ///
    substitute("\%" "\\%")
