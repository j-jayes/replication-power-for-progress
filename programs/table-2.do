/*******************************************************************************
* Project:      Power for progress: The impact of electricity on individual 
* labor market outcomes
* Authors:      Jonathan Jayes, Jakob Molinder, and Kerstin Enflo
*
*
* Do-file:      table-2.do
* Purpose:      Replicates Table 2: Energy use in Western Line vs. Control parishes
*
*
* Last-updated: 12 June 2025
*
*******************************************************************************/

* Table 2

clear
cd "$project_path"
use "data/table-2.dta"

eststo clear

gen latitude_3 = latitude^3
gen longitude_3 = longitude^3

quietly summarize log_total_power
local mean1 = round(r(mean), 0.01)
reg log_total_power western_line_parish area population_1900 latitude ///
longitude latitude_3 longitude_3 railway_in_parish if distance_to_line < $distance_threshold
eststo Model1
estadd scalar mean_depvar = `mean1'
estadd local area "X"
estadd local pop "X"
estadd local rail "X"
estadd local lat "X"
estadd local lon "X"
estadd local lat3 "X"
estadd local lon3 "X"


quietly summarize log_total_power_transmitted
local mean2 = round(r(mean), 0.01)
reg log_total_power_transmitted western_line_parish area population_1900 latitude ///
longitude latitude_3 longitude_3 railway_in_parish if distance_to_line < $distance_threshold
eststo Model2
estadd scalar mean_depvar = `mean2'
estadd local area "X"
estadd local pop "X"
estadd local rail "X"
estadd local lat "X"
estadd local lon "X"
estadd local lat3 "X"
estadd local lon3 "X"

quietly summarize log_total_power_generated
local mean3 = round(r(mean), 0.01)
reg log_total_power_generated western_line_parish area population_1900 latitude ///
longitude latitude_3 longitude_3 railway_in_parish if distance_to_line < $distance_threshold
eststo Model3
estadd scalar mean_depvar = `mean3'
estadd local area "X"
estadd local pop "X"
estadd local rail "X"
estadd local lat "X"
estadd local lon "X"
estadd local lat3 "X"
estadd local lon3 "X"

esttab Model1 Model2 Model3 using $output_dir/table-2.tex, label replace ///
  keep(western_line_parish) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  stats(area pop rail lat lon lat3 lon3 r2 N F mean_depvar, fmt(1 1 1 1 1 1 1 2 %9.0fc 2 2) labels("Parish Area (km2)" "Parish Population (1900)" "Railway in Parish" "Latitude" "Longitude" "Latitude Cubed" "Longitude Cubed" "R-squared" "Observations" "F-stat" "Mean Dependent Var")) ///
  mlabels("log(Total Power)" "log(Total Power Transmitted)" "log(Total Power Generated)") ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
