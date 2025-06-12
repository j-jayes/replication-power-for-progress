/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-8.do
* Purpose:      Replicates Table 8: Regression for inclusion of parish in the
* 1930 census sample. This is a balance test to check for
* sample selection bias based on 1900 parish characteristics.
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
use "data/table-8.dta", clear


*===============================================================================
* PREPARATION
*===============================================================================

* Add descriptive labels to variables for a clean table output.
* 'shc1' (Elite) is the omitted base category in the regression.
label var included_1930 "Parish included in 1930 census"
label var shc2 "White collar (%) 1900"
label var shc3 "Foremen (%) 1900"
label var shc4 "Medium skilled (%) 1900"
label var shc5 "Farmers (%) 1900"
label var shc6 "Lower skilled (%) 1900"
label var shc7 "Unskilled (%) 1900"
label var log_llabforce "Log (1 + Labour Force) 1900"


*===============================================================================
* REGRESSION ANALYSIS
*===============================================================================

* Regress the 1930 inclusion dummy on 1900 parish characteristics
eststo Model1: reg included_1930 shc2 shc3 shc4 shc5 shc6 shc7 log_llabforce, robust


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

* Export the regression results to a LaTeX file
esttab Model1 using "$output_dir/table-8.tex", replace ///
    label booktabs nonumbers nodepvars ///
    title("Parish included in 1930 census") ///
    b(3) se(2) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels("Observations"))
