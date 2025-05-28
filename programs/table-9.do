*** Table 9

clear

use "data/table-9.dta"

reg included_1930 shc2 shc3 shc4 shc5 shc6 shc7 log_llabforce, robust
eststo Model1

esttab Model1 using $output_dir/table-9.tex, label replace ///
	cells(b(star fmt(3)) se(par fmt(2))) 
