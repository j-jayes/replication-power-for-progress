* Table 5

clear
set more off 

use "data/table-5.dta"

eststo clear

quietly summarize log_income
local mean1 = round(r(mean), 0.01)
reg log_income western_line_parish, vce(cluster birth_parish_ref_code)
eststo Model1
estadd scalar mean_depvar = `mean1'

quietly summarize log_income
local mean2 = round(r(mean), 0.01)
reg log_income western_line_parish age age_2 female, vce(cluster birth_parish_ref_code)
eststo Model2
estadd scalar mean_depvar = `mean2'

quietly summarize log_income
local mean3 = round(r(mean), 0.01)
reg log_income western_line_parish age age_2 female i.marital i.schooling i.hisclass, vce(cluster birth_parish_ref_code)
eststo Model3
estadd scalar mean_depvar = `mean3'


esttab Model1 Model2 Model3 using $output_dir/table-5.tex, label replace ///
  keep(western_line_parish) ///
  stats(r2 N F mean_depvar, fmt(2 %9.0fc 2 2) labels("R-squared" "Observations" "F-stat" "Mean Dependent Var")) ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
  
