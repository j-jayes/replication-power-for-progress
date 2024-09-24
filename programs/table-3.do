* Table 1

clear all
set more off 

use "data/table-3.dta"


* Clear stored estimates
eststo clear


quietly summarize log_total_connections if distance_to_line < $distance_cutoff
local mean1 = round(r(mean), 0.01)
reg log_total_connections western_line_parish area population_1900 latitude longitude if distance_to_line < $distance_cutoff
eststo Model1
estadd scalar mean_depvar = `mean1'

quietly summarize log_num_connections_transmitted if distance_to_line < $distance_cutoff
local mean2 = round(r(mean), 0.01)
reg log_num_connections_transmitted western_line_parish area population_1900 latitude longitude if distance_to_line < $distance_cutoff
eststo Model2
estadd scalar mean_depvar = `mean2'

quietly summarize log_num_connections_generated if distance_to_line < $distance_cutoff
local mean3 = round(r(mean), 0.01)
reg log_num_connections_generated western_line_parish area population_1900 latitude longitude if distance_to_line < $distance_cutoff
eststo Model3
estadd scalar mean_depvar = `mean3'

esttab Model1 Model2 Model3 using $output_dir/table-3.tex, label replace ///
  keep(western_line_parish) ///
  stats(r2 N F mean_depvar, fmt(2 0 3 2) labels("R-squared" "Observations" "F-stat" "Mean Dependent Var")) ///
  mlabels("log(Total connections)" "log(N. transformers)" "log(N. generators) (water, steam, diesel)") ///
  cells(b(star fmt(3)) se(par fmt(2)))

