* Table 5

clear
cd "$project_path"


***************************** Prepapre income scores


* Step 1: Load and preprocess income score data
use "/Users/jonathanjayes/Documents/PhD/paper-3-analysis/replication_jan_25/data/inc_score_1930_foranalysis.dta", clear

* Recode sex to female (female = 1 if sex == 2, else 0)
gen female = (sex == 2)
drop sex

* Rename hisco to hisco_code
rename hisco hisco_code

* Create log_inc_score_1930 = log(inc_score_1930 + 1)
gen log_inc_score_1930 = log(inc_score_1930 + 1)

* Step 1b: Drop duplicates to ensure one row per hisco_code/female combo
duplicates drop hisco_code female, force

* Save the cleaned and deduplicated version
tempfile inc_cleaned
save `inc_cleaned'

* Step 2: Load the main dataset
cd "$project_path"
use "data/table-5.dta", clear

* Step 3: Merge on hisco_code and female — left join, keep all table-5 rows
merge m:1 hisco_code female using `inc_cleaned'

* Check results and drop merge helper
tab _merge
drop _merge


***************************** Regressions

* Clear stored estimates
eststo clear

* Step 1: Model 1 — Only western_line_parish
quietly summarize log_inc_score_1930
local mean1 = round(r(mean), 0.01)
reg log_inc_score_1930 western_line_parish, vce(cluster birth_parish_ref_code)
eststo Model1
estadd scalar mean_depvar = `mean1'

* Step 2: Model 2 — Add controls
quietly summarize log_inc_score_1930
local mean2 = round(r(mean), 0.01)
reg log_inc_score_1930 western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)
eststo Model2
estadd scalar mean_depvar = `mean2'
estadd local controls "X"

* Step 3: Export to LaTeX table
esttab Model1 Model2 using "$output_dir/table-5-two-step-controls-income-scores.tex", label replace ///
    keep(western_line_parish) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(controls r2 N F, fmt(1 2 %9.0fc 2) labels("Controls" "R-squared" "Observations" "F-stat")) ///
    cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
