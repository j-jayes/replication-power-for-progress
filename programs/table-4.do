* Table 4

clear
set more off 

use "data/table-4.dta"

eststo clear


reg employed western_line_parish, vce(cluster birth_parish_ref_code)
eststo Model1


reg employed western_line_parish age age_2 female, vce(cluster birth_parish_ref_code)
eststo Model2


reg employed western_line_parish age age_2 female i.marital i.schooling, vce(cluster birth_parish_ref_code)
eststo Model3


esttab Model1 Model2 Model3 using $output_dir/table-4.tex, label replace ///
  keep(western_line_parish) ///
  stats(r2 N F mean_depvar, fmt(2 %9.0fc 2 2) labels("R-squared" "Observations" "F-stat" "Mean Dependent Var")) ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
