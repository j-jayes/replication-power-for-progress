* Table 2

clear
set more off 

use "data/table-2.dta"

eststo clear

quietly summarize log_total_power
local mean1 = round(r(mean), 0.01)
reg log_total_power western_line_parish area population_1900 latitude longitude 
eststo Model1
estadd scalar mean_depvar = `mean1'

quietly summarize log_total_power_transmitted
local mean2 = round(r(mean), 0.01)
reg log_total_power_transmitted western_line_parish area population_1900 latitude longitude
eststo Model2
estadd scalar mean_depvar = `mean2'

quietly summarize log_total_power_generated
local mean3 = round(r(mean), 0.01)
reg log_total_power_generated western_line_parish area population_1900 latitude longitude
eststo Model3
estadd scalar mean_depvar = `mean3'

esttab Model1 Model2 Model3 using $output_dir/table-2.tex, label replace ///
  keep(western_line_parish) ///
  stats(r2 N F mean_depvar, fmt(2 0 3 2) labels("R-squared" "Observations" "F-stat" "Mean Dependent Var")) ///
  mlabels("log(Total Power)" "log(Total Power Transmitted)" "log(Total Power Generated)") ///
  cells(b(star fmt(3)) se(par fmt(2)))
