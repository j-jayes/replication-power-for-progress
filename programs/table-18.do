/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-18.do
* Purpose:      Replicates Table 18: Robustness check of income effects by
* varying the control group distance threshold from the Western
* Line (100km to 500km).
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

* Load the raw data once to improve efficiency
use "raw_data/power-for-progress-1930-census_raw.dta", clear

* Generate squared age term
gen age_2 = age^2


*===============================================================================
* ANALYSIS LOOP
*===============================================================================

* Define the list of distance thresholds (in km) to loop through
local thresholds "100 150 200 250 300 350 400 450 500"

* Loop through each threshold, run the regression on the relevant subsample,
* and store the results.
foreach threshold of local thresholds {
    eststo Model`threshold': reg log_income western_line_parish age age_2 ///
        female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish ///
        if birth_parish_distance_to_line < `threshold', vce(cluster birth_parish_ref_code)
}


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

* Create a local macro to hold the titles for each model in the final table
local mtitle
foreach threshold of local thresholds {
    local mtitle `"`mtitle' `"`threshold'"'"'
}

* Use esttab to combine the 9 stored models into a single table
esttab Model* using "$output_dir/table-18.tex", replace label booktabs ///
    keep(western_line_parish) ///
    star(* 0.10 ** 0.05 *** 0.01) nonumbers ///
    stats(r2 N, fmt(2 %9.0fc) labels("R-squared" "Observations")) ///
    cells(b(star fmt(3)) se(par fmt(2))) ///
    mtitles(`mtitle') collabels(none) ///
    indicate("Controls" = age age_2 female *.marital *.schooling ///
             *.hisco_code_2_d railway_in_birth_parish, labels("X"))
