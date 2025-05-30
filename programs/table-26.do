* Table 2

clear
cd "$project_path"
use "data/table-26.dta"

eststo clear


acreg log_total_power western_line_parish area population_1900 railway_in_parish ///
	  if distance_to_line < 300, ///
      spatial ///
      latitude(latitude) longitude(longitude) dist(100) 

eststo Model1
estadd local area "X"
estadd local pop "X"
estadd local rail "X"



acreg log_total_power_transmitted western_line_parish area population_1900 railway_in_parish ///
	  if distance_to_line < 300, ///
      spatial ///
      latitude(latitude) longitude(longitude) dist(100) 

eststo Model2
estadd local area "X"
estadd local pop "X"
estadd local rail "X"

	  
acreg log_total_power_generated western_line_parish area population_1900 railway_in_parish ///
	  if distance_to_line < 300, ///
      spatial ///
      latitude(latitude) longitude(longitude) dist(100) 
	  
eststo Model3
estadd local area "X"
estadd local pop "X"
estadd local rail "X"



esttab Model1 Model2 Model3 using $output_dir/table-26.tex, label replace ///
  keep(western_line_parish) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  stats(area pop rail r2 N F, fmt(1 1 1 2 %9.0fc 2) labels("Parish Area (km2)" "Parish Population (1900)" "Railway in Parish" "R-squared" "Observations" "F-stat")) ///
  mlabels("log(Total Power)" "log(Total Power Transmitted)" "log(Total Power Generated)") ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)

