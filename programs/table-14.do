/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-14.do
* Purpose:      Replicates Table 14: A cross-tabulation of movers and stayers
* by Western Line vs. Control group status.
*
*
* Last-updated: 12 June 2025
*
*******************************************************************************/

*===============================================================================
* SETUP
*===============================================================================

clear
cd "$project_path"

* This script assumes the data file contains the distance between birth
* and current parish (`dist_bp_to_cp_km`).
use "data/table-14.dta", clear


*===============================================================================
* DATA PREPARATION
*===============================================================================

* Generate the 'mover' variable based on distance between parishes.
* Mover = 0 (Stayer) if the distance is zero.
* Mover = 1 (Mover) if the distance is greater than zero.
gen mover = (dist_bp_to_cp_km > 0) if dist_bp_to_cp_km != .
label var mover "Moved from Parish of Birth"
label define mover_lbl 0 "Stayer" 1 "Mover"
label values mover mover_lbl


*===============================================================================
* ANALYSIS AND EXPORT
*===============================================================================

* Use `estpost tabulate` to store the results of the cross-tabulation.
* We specify that we want both the frequency count (freq) and the
* column percentages (colpct).
estpost tabulate mover western_line_parish, cells("freq colpct")

* Use `esttab` to format the stored results into a clean LaTeX table.
* The `unstack` option creates the desired layout, and we customize the
* headers and formatting to match the paper.
esttab using "$output_dir/table-14.tex", replace booktabs noobs ///
    unstack nototals nonumber ///
    cells("0(fmt(%9.0gc)) 1(fmt(%9.0gc)) total(fmt(%9.0gc))") ///
    collabels("Control" "Western Line" "Total")
