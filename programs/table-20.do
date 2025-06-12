/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual 
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-20.do
* Purpose:      Replicates Table 20: Western Line Parish on Log Income Score. 
* This isolates occupational sorting from within-occupation wage
* effects by using a national median income score. 
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
* PREPARE AND MERGE INCOME SCORES
*===============================================================================

* --- Step 1: Load and preprocess income score data ---
* This file contains the national median income for each occupation (HISCO)
use "data/inc_score_1930_foranalysis.dta", clear

gen female = (sex == 2) // Recode sex to a binary female variable
rename hisco hisco_code // Rename for consistency
gen log_inc_score_1930 = log(inc_score_1930 + 1) // Generate log score

* Drop duplicates to ensure one observation per occupation-gender combination
duplicates drop hisco_code female, force

* Save the cleaned income score data to a temporary file
tempfile inc_scores
save `inc_scores'


* --- Step 2: Load main analysis data and merge ---
use "data/table-5.dta", clear

* Merge income scores onto the main dataset
merge m:1 hisco_code female using `inc_scores', keep(match) nogen


*===============================================================================
* REGRESSIONS
*===============================================================================

* Generate squared term for age
gen age_2 = age^2

* --- Model 1: Unadjusted regression ---
eststo Model1: reg log_inc_score_1930 western_line_parish, vce(cluster birth_parish_ref_code)

* --- Model 2: Regression with full controls ---
eststo Model2: reg log_inc_score_1930 western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

* Add a local macro to flag the model with controls
estadd local controls "X", replace: Model2

* Export the final table
esttab Model1 Model2 using "$output_dir/table-20.tex", label replace ///
    keep(western_line_parish) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(controls r2 N F, fmt(1 2 %9.0fc 2) labels("Controls" "R-squared" "Observations" "F-stat")) ///
    cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
