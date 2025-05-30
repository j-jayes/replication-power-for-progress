* Table 4

clear
cd "$project_path"
use "data/table-4.dta"

eststo clear


reg employed western_line_parish, vce(cluster birth_parish_ref_code)
eststo Model1

reg employed western_line_parish age age_2 female i.marital i.schooling railway_in_birth_parish, vce(cluster birth_parish_ref_code)
eststo Model2
estadd local controls "X"


esttab Model1 Model2 using $output_dir/table-4-two-step-controls.tex, label replace ///
  keep(western_line_parish) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  stats(controls r2 N F, fmt(1 2 %9.0fc 2) labels("Controls" "R-squared" "Observations" "F-stat")) ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
