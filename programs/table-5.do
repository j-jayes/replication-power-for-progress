/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual 
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-5.do
* Purpose:      Replicates Table 5: Income regressions, Stayers and Movers.
* This table compares the income premium for three groups:
* 1. Baseline: Born in a Western Line parish.
* 2. Stayers: Born in and still live in their birth parish.
* 3. Dwellers: Live in a Western Line parish in 1930.
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

use "data/table-5.dta", clear


*===============================================================================
* PREPARATION
*===============================================================================

* Define variable labels for the final table
label var western_line_parish "Born in a Western Line Parish"
label var western_line_parish_dweller "Western Line Parish Dweller in 1930"


*===============================================================================
* REGRESSIONS
*===============================================================================

* --- Model 1 (Column 1: Baseline) ---
* Effect on individuals BORN in a Western Line parish (regardless of 1930 location)
eststo Model1: reg log_income western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)
estadd local controls "X"

* --- Model 2 (Column 2: Stayers) ---
* Effect on individuals who were BORN IN and STILL LIVE IN their birth parish
eststo Model2: reg log_income western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish if stayer_in_birth_parish == 1, vce(cluster birth_parish_ref_code)
estadd local controls "X"

* --- Model 3 (Column 3: Location in 1930 / Dwellers) ---
* Effect on individuals who LIVE IN a Western Line parish in 1930
eststo Model3: reg log_income western_line_parish_dweller age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)
estadd local controls "X"


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

esttab Model1 Model2 Model3 using "$output_dir/table-5.tex", label replace ///
    keep(western_line_parish western_line_parish_dweller) ///
    mtitles("Baseline" "Lives in Parish of Birth" "Location in 1930") ///
    stats(controls r2 N, fmt(1 2 %9.0fc) labels("Controls" "R-squared" "Observations")) ///
    cells(b(star fmt(3)) se(par fmt(2))) collabels(none) star(* 0.10 ** 0.05 *** 0.01)
