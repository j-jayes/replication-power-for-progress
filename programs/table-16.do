/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-16.do
* Purpose:      Replicates Table 16: Union Density by Parish Type.
* This table shows the average union density (union members as a
* percentage of the population) for Western Line and Control
* parishes in 1890, 1900, 1910, and 1930.
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
* STEP 1: PREPARE DATA COMPONENTS
*===============================================================================

* --- Part A: Create Western Line parish indicator ---
use "codebooks/western_line_parishes_1930.dta", clear
gen western_line = 1
rename parish_code birth_parish_ref_code
keep birth_parish_ref_code western_line
tempfile wl_indicator
save `wl_indicator', replace

* --- Part B: Create parish-level population panel (1890-1930) ---
use "raw_data/ipums_sweden_1880-1910.dta", clear
rename bplse2 birth_parish_ref_code
keep if inlist(year, 1890, 1900, 1910)
collapse (count) population = year, by(birth_parish_ref_code year)
tempfile pop_panel
save `pop_panel', replace

use "raw_data/power-for-progress-1930-census_raw.dta", clear
gen year = 1930
collapse (count) population = year, by(birth_parish_ref_code year)
append using `pop_panel'
save `pop_panel', replace

* --- Part C: Create parish-level union members panel ---
use "raw_data/union_membership_1881-1950.dta", clear
rename GEOKOD birth_parish_ref_code
reshape long MEDLEM, i(birth_parish_ref_code) j(year)
collapse (sum) union_members = MEDLEM, by(birth_parish_ref_code year)
tempfile union_totals
save `union_totals', replace


*===============================================================================
* STEP 2: MERGE DATA AND CALCULATE DENSITY
*===============================================================================

* Start with the population panel, which defines our universe of parishes and years
use `pop_panel', clear

* Merge the Western Line indicator
merge m:1 birth_parish_ref_code using `wl_indicator', nogen
replace western_line = 0 if western_line == .

* Merge the union membership totals
merge 1:1 birth_parish_ref_code year using `union_totals', nogen
replace union_members = 0 if union_members == .

* Calculate union density as a percentage
gen union_density = (union_members / population) * 100


*===============================================================================
* STEP 3: CALCULATE MEANS AND ASSEMBLE TABLE
*===============================================================================

* Use postfile to build the final summary table
postfile table16 year control_density wl_density using "data/table-16-data.dta", replace

    * For 1880, values are missing as per the table
    post table16 (1880) (.) (.)

    * Loop over the remaining years to calculate and post the means
    foreach y of numlist 1890 1900 1910 1930 {
        qui sum union_density if western_line == 0 & year == `y'
        local ctrl_mean = r(mean)
        qui sum union_density if western_line == 1 & year == `y'
        local wl_mean = r(mean)

        post table16 (`y') (`ctrl_mean') (`wl_mean')
    }
postclose table16


*===============================================================================
* STEP 4: FORMAT AND EXPORT FINAL TABLE
*===============================================================================

use "data/table-16-data.dta", clear

* Format the values as percentages with two decimal places
format %4.2f control_density wl_density

* Convert to string and replace missing with a dash for display
tostring control_density, replace format(%4.2f)
tostring wl_density, replace format(%4.2f)
replace control_density = "-" if control_density == "."
replace wl_density = "-" if wl_density == "."

* Add percentage signs
replace control_density = control_density + "\%" if control_density != "-"
replace wl_density = wl_density + "\%" if wl_density != "-"

* Export the final formatted table to LaTeX
esttab . using "$output_dir/table-16.tex", replace ///
    cells("year control_density wl_density") booktabs noobs nonumbers ///
    collabels("Year" "Control" "Western Line") ///
    postfoot("\bottomrule") ///
    substitute("\%" "\\%")
