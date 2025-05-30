* Table 21

clear
cd "$project_path"
eststo clear

use "data/table-21.dta"

reg log_income western_line_parish##i.schooling age age_2 female i.marital  i.hisco_code_2_d, vce(cluster birth_parish_ref_code)
eststo Model1

* Tabulate the regression results and save them in TeX format
esttab Model1 using $output_dir/table-21.tex, replace label ///
  order(4.schooling 2.schooling 3.schooling 1.western_line_parish#4.schooling 1.western_line_parish#2.schooling 1.western_line_parish#3.schooling) ///
  keep(4.schooling 2.schooling 3.schooling 1.western_line_parish#4.schooling 1.western_line_parish#2.schooling 1.western_line_parish#3.schooling) ///
  stats(r2 N F, fmt(2 %9.0fc 0) labels("R-squared" "Observations" "F-stat")) ///
  cells(b(star fmt(3)) se(par fmt(2)))
