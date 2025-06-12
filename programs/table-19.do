/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-19.do
* Purpose:      Replicates Table 19, testing for interaction effects between
* electrification and industrial specialization (urban parish)
* or railway connectivity.
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
use "data/table-19.dta", clear


*===============================================================================
* PREPARATION
*===============================================================================

* Generate squared age term
gen age_2 = age^2

* Add descriptive labels for a clean table output
label var western_line_parish "Western Line Parish"
label var urban_parish_1910 "Parish has more non-farming households than avg in 1910"
label var railway_in_birth_parish "Railway in Birth Parish"


*===============================================================================
* REGRESSION MODELS
*===============================================================================

* --- Model 1: Baseline ---
* This is the main income regression, for comparison.
eststo Model1: reg log_income i.western_line_parish age age_2 female i.marital ///
    i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)


* --- Model 2: Interaction with Urban Parish Status in 1910 ---
* The ## operator includes main effects of both variables and their interaction.
eststo Model2: reg log_income i.western_line_parish##i.urban_parish_1910 age age_2 ///
    female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, ///
    vce(cluster birth_parish_ref_code)


* --- Model 3: Interaction with Railway Access in 1900 ---
eststo Model3: reg log_income i.western_line_parish##i.railway_in_birth_parish ///
    age age_2 female i.marital i.schooling i.hisco_code_2_d, ///
    vce(cluster birth_parish_ref_code)


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

* Define the coefficients to keep for the final table
local keep_vars "1.western_line_parish 1.urban_parish_1910 1.western_line_parish#1.urban_parish_1910 ///
                 1.railway_in_birth_parish 1.western_line_parish#1.railway_in_birth_parish"

* Export the three models into a single, formatted table
esttab Model* using "$output_dir/table-19.tex", replace booktabs nonumbers ///
    mtitles("Baseline" "Urban Parish 1910" "Railway in Parish 1900") ///
    order(`keep_vars') keep(`keep_vars') drop(_cons) ///
    label star(* 0.10 ** 0.05 *** 0.01) b(3) se(2) ///
    indicate("Controls" = age age_2 female *.marital *.schooling *.hisco_code_2_d, labels("X")) ///
    stats(r2 N, fmt(2 %9.0fc) labels("R-squared" "Observations"))
