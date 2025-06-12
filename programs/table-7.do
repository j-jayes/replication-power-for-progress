/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual 
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-7.do
* Purpose:      Replicates Table 7: Mean incomes by job type and birth parish.
* This table compares the mean income for individuals in the
* Western Line vs. control parishes, broken down by job category.
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

* This script assumes the data file contains flags for job categories.
use "data/table-7.dta", clear


*===============================================================================
* PREPARATION & ANALYSIS
*===============================================================================

* Create income variable from log_income
gen income = exp(log_income)

* The script runs a t-test for four different job categories and stores
* the results using eststo.

* --- 1. Electricity job, direct ---
eststo Direct: estpost ttest income if electricity_job_direct == 1, by(western_line_parish)
estadd local category "Electricity Job Direct"

* --- 2. Electricity job, indirect ---
eststo Indirect: estpost ttest income if electricity_job_indirect == 1, by(western_line_parish)
estadd local category "Electricity Job Indirect"

* --- 3. Other jobs (non-electricity related) ---
eststo Other: estpost ttest income if electricity_job_direct == 0 & electricity_job_indirect == 0, by(western_line_parish)
estadd local category "Other Jobs"

* --- 4. All jobs (overall average) ---
eststo All: estpost ttest income, by(western_line_parish)
estadd local category "All Jobs"


*===============================================================================
* EXPORT TABLE TO LATEX
*===============================================================================

* `esttab` is used to combine the four stored estimates into a single table.
* The `stats()` option is customized to display the job category, means for
* each group, the difference, the p-value, and the observation count.

esttab Direct Indirect Other All using "$output_dir/table-7.tex", replace ///
    label nonumbers star(* 0.10 ** 0.05 *** 0.01) ///
    stats(category mu_1 mu_2 b p N, ///
    fmt(1 2 2 2 4 %9.0gc) ///
    labels("Job Category" "Control Parish (mean)" "Western Line (mean)" "Difference" "p-value" "Observations"))
