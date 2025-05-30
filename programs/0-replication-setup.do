* Replication setup
clear
global project_path "/Users/jonathanjayes/Documents/PhD/paper-3-analysis/replication_jan_25"
*global project_path "/Users/jakobmolinder/Dropbox/Ekonomisk historia/Arbete/Projekt/Electrification/replication"

cd "$project_path"

global output_dir "output/"
cap mkdir "$output_dir"

global distance_threshold 300

// ssc install estout
net install oaxaca, replace from(https://raw.githubusercontent.com/benjann/oaxaca/main/)


* Create the data for table-4
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold

save "data/table-4.dta", replace


* Create the data for table-5
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0

save "data/table-5.dta", replace


* Create the data for table-6
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0

tabulate marital, generate(marital_) // 5
tabulate schooling, generate(schooling_) // 4
tabulate hisclass, generate(hisclass_) // 7
tabulate hisco_code_2_d, generate(hisco_code_2_d_) // ?

save "data/table-6.dta", replace

* Create the data for table-7
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0

save "data/table-7.dta", replace

* Create the data for table-8
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold

save "data/table-8.dta", replace

* Create the data for table-15
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0

save "data/table-15.dta", replace


* Create the data for table-20
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0

save "data/table-20.dta", replace

* Create the data for table-21
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0

save "data/table-21.dta", replace

* Create the data for table-25
* Here we want to collapse the individual level to parish level

use "raw_data/power-for-progress-1930-census_raw.dta"

drop if current_parish_distance_to_line > $distance_threshold
	
tabulate hisclass, generate(hisclass_)

collapse (sum) hisclass_*, by(current_parish_ref_code)

generate total_labor_force = hisclass_1 + hisclass_2 + hisclass_3 + hisclass_4 + hisclass_5 + hisclass_6 + hisclass_7

forvalues i = 1/7 {
    generate hisclass_`i'_share = hisclass_`i' / total_labor_force
}

* drop 
drop total_labor_force

* drop absolute values
forvalues i = 1/7 {
    drop  hisclass_`i'
}

save "raw_data/hisclass_shares_current_parish_ref_code.dta", replace
 
use "raw_data/power-for-progress-1930-census_raw.dta"
	
collapse (mean) western_line_parish_dweller log_income age schooling_above_primary railway_in_current_parish, by(current_parish_ref_code)

merge 1:1 current_parish_ref_code using "raw_data/hisclass_shares_current_parish_ref_code.dta"

drop _merge

save "raw_data/log_income_hisclass_shares_current_parish_ref_code.dta", replace


import delimited "data/swedish_parish_1930_points.csv", clear

merge 1:1 current_parish_ref_code using "raw_data/log_income_hisclass_shares_current_parish_ref_code.dta", keep(3)

save "data/table-25-1.dta", replace


********* now doing this for the birth_parish_ref_code

use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
	
tabulate hisclass, generate(hisclass_)

collapse (sum) hisclass_*, by(birth_parish_ref_code)

generate total_labor_force = hisclass_1 + hisclass_2 + hisclass_3 + hisclass_4 + hisclass_5 + hisclass_6 + hisclass_7

forvalues i = 1/7 {
    generate hisclass_`i'_share = hisclass_`i' / total_labor_force
}

* drop 
drop total_labor_force

* drop absolute values
forvalues i = 1/7 {
    drop  hisclass_`i'
}

save "raw_data/hisclass_shares_birth_parish_ref_code.dta", replace
 
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
	
collapse (mean) western_line_parish log_income age schooling_above_primary railway_in_birth_parish, by(birth_parish_ref_code)

merge 1:1 birth_parish_ref_code using "raw_data/hisclass_shares_birth_parish_ref_code.dta"

drop _merge

save "raw_data/log_income_hisclass_shares_birth_parish_ref_code.dta", replace


import delimited "data/swedish_parish_1930_points.csv", clear

rename current_parish_ref_code birth_parish_ref_code

merge 1:1 birth_parish_ref_code using "raw_data/log_income_hisclass_shares_birth_parish_ref_code.dta", keep(3)

save "data/table-25-2.dta", replace


* Create the data for table-28
use "raw_data/power-for-progress-1930-census_raw.dta"

drop if birth_parish_distance_to_line > $distance_threshold
drop if employed == 0

save "data/table-28.dta", replace

