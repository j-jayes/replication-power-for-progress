* Table 7

clear
cd "$project_path"
use "data/table-7-jan-25.dta"
eststo clear

label var western_line_parish_dweller "Western Line Parish Dweller in 1930"
label var western_line_parish "Born in a Western Line Parish"


* Regression 1 is baseline from table 5

reg log_income western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)
eststo Model1

* regression 2 is stayeys in table 7-jan-25
reg log_income western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish if stayer_in_birth_parish == 1, vce(cluster birth_parish_ref_code)
eststo Model2


* Regression 3 is western_line_parish_dwellers
reg log_income western_line_parish_dweller age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)
eststo Model3 


esttab Model1 Model2 Model3 using $output_dir/table-7-jan-25.tex, label replace ///
  keep(western_line_parish western_line_parish_dweller) ///
  mtitles("Baseline" "Lives in Parish of Birth" "Location in 1930") ///
  stats(r2 N, fmt(2 %9.0fc) labels("R-squared" "Observations")) ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
  
