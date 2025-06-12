/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-13.do
* Purpose:      Replicates Table 13: Balance test of 1900 parish occupational
* shares before balancing.
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
* STEP 1: PREPARE DATA AT THE PARISH LEVEL FOR 1900 (UNBALANCED)
*===============================================================================

* --- Part A: Create Western Line parish indicator ---
use "codebooks/western_line_parishes_1930.dta", clear
gen western_line = 1
rename parish_code birth_parish_ref_code
keep birth_parish_ref_code western_line
tempfile wl_indicator
save `wl_indicator'

* --- Part B: Calculate 1900 occupational shares (Full Sample) ---
use "raw_data/ipums_sweden_1880-1910.dta", clear
keep if year == 1900
rename bplse2 birth_parish_ref_code
rename hisclass hisclass_7
tabulate hisclass_7, generate(shc)

* Collapse data to the parish level
collapse (mean) shc* (count) labour_force = year, by(birth_parish_ref_code)
foreach var of varlist shc* {
    replace `var' = `var' * 100
}

* Merge Western Line indicator back to parish-level data
merge 1:1 birth_parish_ref_code using `wl_indicator', nogen
replace western_line = 0 if western_line == .

* Label the variables for the final table
label var shc1 "Elite"
label var shc2 "White collar"
label var shc3 "Foremen"
label var shc4 "Medium-skilled workers"
label var shc5 "Farmers and fishermen"
label var shc6 "Low-skilled workers"
label var shc7 "Unskilled workers"
label var labour_force "Labour force"


*===============================================================================
* STEP 2: PERFORM T-TESTS AND EXPORT TABLE
*===============================================================================

eststo V1: estpost ttest shc1, by(western_line)
eststo V2: estpost ttest shc2, by(western_line)
eststo V3: estpost ttest shc3, by(western_line)
eststo V4: estpost ttest shc4, by(western_line)
eststo V5: estpost ttest shc5, by(western_line)
eststo V6: estpost ttest shc6, by(western_line)
eststo V7: estpost ttest shc7, by(western_line)
eststo V8: estpost ttest labour_force, by(western_line)

* Combine results and export to a LaTeX table
esttab V*, using "$output_dir/table-13.tex", replace booktabs noobs nonumbers ///
    cells("mu_2(fmt(2)) mu_1(fmt(2)) sd_2(fmt(2)) sd_1(fmt(2)) b(fmt(2)) p(fmt(2))") ///
    label ///
    collabels("Mean (Western Line)" "Mean (Control)" "Std (Western Line)" "Std (Control)" "Difference" "p-value")
