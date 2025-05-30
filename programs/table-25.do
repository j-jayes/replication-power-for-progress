* Table 25

clear
cd "$project_path"
use "data/table-28-1.dta"
eststo clear

label variable western_line_parish_dweller "Lives in Western Line Parish"

acreg log_income western_line_parish_dweller age schooling_above_primary ///
	railway_in_current_parish ///
	 hisclass_2_share hisclass_3_share hisclass_4_share hisclass_5_share hisclass_6_share ///
	 hisclass_7_share ///
	, spatial latitude(latitude) longitude(longitude) dist(100)
eststo Model1
estadd local age "X"
estadd local schooling_rail "X"
estadd local hisclass "X"


** Second we use western_line_parish, the variable for if the individual is born in the western line parish

use "data/table-28-2.dta", clear

label variable western_line_parish "Born in Western Line Parish"

acreg log_income western_line_parish age schooling_above_primary ///
	railway_in_birth_parish ///
	 hisclass_2_share hisclass_3_share hisclass_4_share hisclass_5_share hisclass_6_share ///
	 hisclass_7_share ///
	, spatial latitude(latitude) longitude(longitude) dist(100)
eststo Model2
estadd local age "X"
estadd local schooling_rail "X"
estadd local hisclass "X"



esttab Model1 Model2 using $output_dir/table-28-test.tex, label replace ///
  keep(western_line_parish_dweller western_line_parish) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  stats(age schooling_rail hisclass r2 N, fmt(1 1 1 2 %9.0fc)  labels("Age" "Schooling above Primary and Railway in Parish" "HISCLASS shares" "R-squared" "Observations" "F-stat")) ///
  cells(b(star fmt(3)) se(par fmt(2))) collabels(none)
  


  
  
  
  
  
  
  
  
  
  
  
  
  
** First we use western_line_parish_dweller, the variable for if the individual lives in the western line parish in 1930
collapse (mean) western_line_parish_dweller log_income age age_2 female marital schooling hisco_code_2_d railway_in_current_parish, by(current_parish_ref_code)

* tablulate to create dummy. 

save "data/table-5-test.dta", replace

import delimited "data/swedish_parish_1930_points.csv", clear

merge 1:1 current_parish_ref_code using "data/table-5-test.dta", keep(3)




acreg log_income western_line_parish_dweller age age_2 female railway_in_current_parish, spatial latitude(latitude) longitude(longitude) dist(100)
eststo Model1
estadd local age_gender "X"
estadd local marital_status_schooling_rail "X"


** no contorls
acreg log_income western_line_parish_dweller, spatial latitude(latitude) longitude(longitude) dist(100)
eststo Model1
estadd local age_gender "X"
estadd local marital_status_schooling_rail "X"


* factor variables
acreg log_income western_line_parish_dweller age age_2 female marital schooling hisco_code_2_d railway_in_current_parish, spatial latitude(latitude) longitude(longitude) dist(100)
eststo Model1
estadd local age_gender "X"
estadd local marital_status_schooling_rail "X"
