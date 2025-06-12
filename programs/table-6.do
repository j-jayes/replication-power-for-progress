/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual 
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-6.do
* Purpose:      Replicates Table 6: Kitagawa-Oaxaca-Blinder Decomposition of
* the Income Differential between Western Line and Control parishes.
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
use "data/table-6.dta", clear


*===============================================================================
* PREPARATION
*===============================================================================

* Generate squared age term for use in the model
gen age_2 = age^2

*===============================================================================
* OAXACA DECOMPOSITION
*===============================================================================

* This command decomposes the difference in log_income between the two groups
* defined by `western_line_parish`.
*
* NOTE: We use factor variables (i.) for marital status, schooling, and
* HISCO codes. This is much cleaner than listing each dummy variable manually.

oaxaca log_income age age_2 female i.marital i.schooling i.hisco_code_2_d ///
    railway_in_birth_parish, by(western_line_parish) pooled ///
    vce(cluster birth_parish_ref_code) swap relax

* The `swap` option is used because the "control" group (western_line_parish=0)
* is group 1 by default, and we want to show the "Western Line" group first.


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

* The `esttab` command is customized to replicate the paper's table format.
* We specify which results to keep and how to label them.

esttab using "$output_dir/table-6.tex", replace ///
    cells("b(star fmt(3)) se(par fmt(2))") ///
    title("Kitagawa-Oaxaca-Blinder Decomposition of Income Differential") ///
    nonumbers nodepvars booktabs alignment(D{.}{.}{-1}) collabels(none) ///
    keep(group_2 group_1 difference explained unexplained) ///
    rename(group_2 "Western Line" group_1 "Control parish" ///
           difference "Difference" explained "Explained" unexplained "Unexplained") ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels("Observations")) ///
    postfoot("\hline \textbf{Percentage of Difference} & \\ ///
              Explained (\%) & @p_explained \% \\ ///
              Unexplained (\%) & @p_unexplained \% \\ \hline") ///
    substitute("\%" "\\%")
