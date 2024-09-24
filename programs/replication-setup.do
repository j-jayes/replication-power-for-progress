
clear
cd "/Users/jonathanjayes/Documents/PhD/replication-power-for-progress"

global output_dir "output/"
cap mkdir $output_dir

global distance_threshold 300


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
