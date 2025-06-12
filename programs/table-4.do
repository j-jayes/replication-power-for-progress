/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual 
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-4.do
* Purpose:      Replicates Table 4: Impact of Western Line Parish on Employment 
* and Income. This script combines regressions for all six
* columns of the table.
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
* PART 1: COLUMNS (1) & (2) - Dep. Var: Occupation Listed (Full Sample)
*===============================================================================

use "data/table-4.dta", clear

* --- Column (1): Unadjusted ---
eststo Model1: reg employed western_line_parish, vce(cluster birth_parish_ref_code)

* --- Column (2): With Controls ---
* Note: HISCO is not a control here as 'employed' is the outcome variable
eststo Model2: reg employed western_line_parish age c.age#c.age female i.marital i.schooling railway_in_birth_parish, vce(cluster birth_parish_ref_code)


*===============================================================================
* PART 2: COLUMNS (3) & (4) - Dep. Var: Log Income (Full Sample with Income)
*===============================================================================

use "data/table-5.dta", clear

* --- Column (3): Unadjusted ---
eststo Model3: reg log_income western_line_parish, vce(cluster birth_parish_ref_code)

* --- Column (4): With Controls ---
eststo Model4: reg log_income western_line_parish age c.age#c.age female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)


*===============================================================================
* PART 3: COLUMNS (5) & (6) - Dep. Var: Log Income (Sample: Children in 1921)
* This sample includes individuals aged 16 or younger in 1921, who would be 
* 25 or younger in the 1930 census.
*===============================================================================

* --- Column (5): Unadjusted ---
eststo Model5: reg log_income western_line_parish if age <= 25, vce(cluster birth_parish_ref_code)

* --- Column (6): With Controls ---
eststo Model6: reg log_income western_line_parish age c.age#c.age female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish if age <= 25, vce(cluster birth_parish_ref_code)


*===============================================================================
* GENERATE FINAL TABLE
*===============================================================================

* Add flags for controls to be displayed in the table
estadd local age_gender " " , pattern(1)
estadd local marital " " , pattern(1)
estadd local schooling " " , pattern(1)
estadd local railway " " , pattern(1)
estadd local hisco " " , pattern(1)

* For models with controls, mark with "X"
foreach i of numlist 2 4 6 {
    estadd local age_gender "X", replace: Model`i'
    estadd local marital "X", replace: Model`i'
    estadd local schooling "X", replace: Model`i'
    estadd local railway "X", replace: Model`i'
}

* HISCO is only in models 4 and 6
foreach i of numlist 4 6 {
	estadd local hisco "X", replace: Model`i'
}


* Export the final combined table to LaTeX
esttab Model1 Model2 Model3 Model4 Model5 Model6 using "$output_dir/table-4.tex", replace label ///
    keep(western_line_parish) order(western_line_parish) ///
    star(* 0.10 ** 0.05 *** 0.01) nonumbers mtitles ///
    stats(age_gender marital schooling railway hisco r2 N, ///
    fmt(0 0 0 0 0 2 %9.0fc) ///
    labels("Age, Gender" "Marital Status" "Schooling" "Railway in Parish of Birth" "HISCO (2-digit)" "R-squared" "Observations")) ///
    mlabels( "(1)" "(2)" "(3)" "(4)" "(5)" "(6)", none) ///
    cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
