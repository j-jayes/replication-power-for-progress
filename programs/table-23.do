/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-23.do
* Purpose:      Replicates Table 23, which tests if being born in a Western
* Line parish affected educational attainment. It runs the
* regression on the full sample, as well as for adults and
* children (relative to the 1921 grid completion date).
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
use "data/table-23.dta", clear


*===============================================================================
* DATA PREPARATION
*===============================================================================

* Generate the binary dependent variable for schooling.
* Based on the paper's notes, this variable is 1 if the individual has more
* than primary schooling, and 0 otherwise.
* We assume the 'schooling' variable is coded: 1/2=Primary or less, 3/4=Post-primary or more.
gen schooling_above_primary = (schooling > 2) if schooling < .
label var schooling_above_primary "Has more than primary school education"

* Generate squared age term for use in regressions
gen age_2 = age^2


*===============================================================================
* REGRESSION MODELS
*===============================================================================

* Define the control variables for brevity
global controls age age_2 female i.marital i.hisco_code_2_d railway_in_birth_parish

* --- Model 1: Full Sample ---
eststo Model1: reg schooling_above_primary western_line_parish $controls, vce(cluster birth_parish_ref_code)

* --- Model 2: Adults in 1921 (age > 25 in 1930 census) ---
eststo Model2: reg schooling_above_primary western_line_parish $controls if age > 25, vce(cluster birth_parish_ref_code)

* --- Model 3: Children in 1921 (age <= 25 in 1930 census) ---
eststo Model3: reg schooling_above_primary western_line_parish $controls if age <= 25, vce(cluster birth_parish_ref_code)


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

esttab Model* using "$output_dir/table-23.tex", replace booktabs nonumbers ///
    mtitles("Full Sample" "Adults in 1921 (Above 16)" "Children in 1921") ///
    keep(western_line_parish) b(3) se(2) star(* 0.10 ** 0.05 *** 0.01) ///
    indicate("Controls" = $controls, labels("X")) ///
    stats(r2 N, fmt(2 %9.0fc) labels("R-squared" "Observations"))
