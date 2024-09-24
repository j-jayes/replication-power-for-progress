* Table 6

clear
set more off 

use "data/table-6.dta"

eststo clear


oaxaca log_income age age_2 female marital_1 marital_2 marital_3 marital_5 ///
 schooling_2 schooling_3 schooling_4 ///
 hisclass_1 hisclass_2 hisclass_3 hisclass_5 hisclass_6 hisclass_7 ///
 , by(western_line_parish) pooled vce(cluster birth_parish_ref_code) swap
 
eststo Model1

esttab Model1 using $output_dir/table-6.tex, label replace ///
  stats(N, fmt(%9.0fc) labels("Observations")) ///
  cells(b(star fmt(3)) se(par fmt(2)))
