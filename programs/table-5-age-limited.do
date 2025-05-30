* Table 5

clear
cd "$project_path"
use "data/table-5.dta"

eststo clear

quietly summarize log_income  if age <= 25
local mean1 = round(r(mean), 0.01)
reg log_income western_line_parish if age <= 25, vce(cluster birth_parish_ref_code)
eststo Model1
estadd scalar mean_depvar = `mean1'

quietly summarize log_income  if age <= 25
local mean2 = round(r(mean), 0.01)
reg log_income western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish  if age <= 25, vce(cluster birth_parish_ref_code)
eststo Model2
estadd scalar mean_depvar = `mean2'
estadd local controls "X"


esttab Model1 Model2 using $output_dir/table-5-two-step-controls-age-limited.tex, label replace ///
  keep(western_line_parish) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  stats(controls r2 N F, fmt(1 2 %9.0fc 2)  labels("Controls" "R-squared" "Observations" "F-stat")) ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
  
