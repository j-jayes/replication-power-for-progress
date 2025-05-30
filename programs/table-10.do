* Table 10
clear
cd $project_path
use "data/table-10.dta"

eststo clear
estpost tabstat control western_line percentage_western_line, by(census_year)

esttab . using $output_dir/table-10.tex, label replace noobs
