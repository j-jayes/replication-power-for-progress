/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-9.do
* Purpose:      Replicates Table 9: Share of individuals who are born in
* Western Line parishes by census year (1900, 1910, 1930).
* This is a balance test to check for demographic shifts
* over time.
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
* STEP 1: PREPARE WESTERN LINE INDICATOR
*===============================================================================
* Create a temporary file that flags all Western Line parishes. This will be
* merged with the main census datasets.

use "codebooks/western_line_parishes_1930.dta", clear
gen western_line = 1
rename parish_code birth_parish_ref_code
keep birth_parish_ref_code western_line
tempfile wl_indicator
save `wl_indicator'


*===============================================================================
* STEP 2: PROCESS IPUMS CENSUS DATA FOR 1900 & 1910
*===============================================================================
* NOTE: This assumes the IPUMS data has been converted from .dat to .dta format
* using the provided DDI/XML file, for example with Stata's `import ipumsddi`.
use "raw_data/ipums_sweden_1880-1910.dta", clear

* Prepare for merge by renaming the birth parish variable
rename bplse2 birth_parish_ref_code

* Merge with the Western Line indicator
merge m:1 birth_parish_ref_code using `wl_indicator', nogen
replace western_line = 0 if western_line == .

* Count individuals for 1900
count if year == 1900 & western_line == 0
local ctrl_1900 = r(N)
count if year == 1900 & western_line == 1
local wl_1900 = r(N)

* Count individuals for 1910
count if year == 1910 & western_line == 0
local ctrl_1910 = r(N)
count if year == 1910 & western_line == 1
local wl_1910 = r(N)


*===============================================================================
* STEP 3: PROCESS 1930 CENSUS DATA
*===============================================================================

use "raw_data/power-for-progress-1930-census_raw.dta", clear

* Merge with the Western Line indicator
merge m:1 birth_parish_ref_code using `wl_indicator', nogen
replace western_line = 0 if western_line == .

* Count individuals for 1930
count if western_line == 0
local ctrl_1930 = r(N)
count if western_line == 1
local wl_1930 = r(N)


*===============================================================================
* STEP 4: ASSEMBLE AND EXPORT FINAL TABLE
*===============================================================================

* Use postfile to create a new, clean dataset with the summary counts
clear
postfile table9 census_year control western_line using "data/table-9-data.dta", replace
    post table9 (1900) (`ctrl_1900') (`wl_1900')
    post table9 (1910) (`ctrl_1910') (`wl_1910')
    post table9 (1930) (`ctrl_1930') (`wl_1930')
postclose table9

* Load the newly created summary data
use "data/table-9-data.dta", clear

* Calculate the percentage column
gen percentage_western_line = (western_line / (control + western_line)) * 100

* Format the variables for a clean display
format control western_line %12.0gc
format percentage_western_line %4.2f

* Export the final table to LaTeX using esttab
esttab . using "$output_dir/table-9.tex", replace ///
    cells("census_year control western_line percentage_western_line") ///
    title("Share of Individuals Born in Western Line Parishes by Census") ///
    nonumbers booktabs noobs ///
    collabels("Census Year" "Control" "Western Line" "Percentage Western Line") ///
    postfoot("\bottomrule") ///
    substitute("\%" "\\%")
