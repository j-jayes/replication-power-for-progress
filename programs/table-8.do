* Table 8

clear
cd "$project_path"
use "data/table-8.dta"

eststo clear

gen income = exp(log_income)

* Clear previous estimates
eststo clear 

* Electricity job direct
estpost ttest income if electricity_job_direct == 1, by(western_line_parish)
eststo Table1
estadd local category "Electricity job direct"

* Electricity job indirect
estpost ttest income if electricity_job_indirect == 1, by(western_line_parish)
eststo Table2
estadd local category "Electricity job indirect"

* Other jobs (Neither direct nor indirect electricity jobs)
estpost ttest income if electricity_job_direct == 0 & electricity_job_indirect == 0, by(western_line_parish)
eststo Table3
estadd local category "Other jobs"

* All jobs
estpost ttest income, by(western_line_parish)
eststo Table4
estadd local category "Average for all jobs"


esttab Table1 Table2 Table3 Table4 using $output_dir/table-8.tex, ///
    cells("category mu_1(fmt(4)) mu_2(fmt(4)) b(fmt(4)) p(fmt(4))") ///
    collabels("Category" "Mean (Group 0)" "Mean (Group 1)" "Difference" "p-value") ///
    label replace nonumbers compress









tabstat income if electricity_job_direct == 1, by(western_line_parish)
ttest income if electricity_job_direct == 1, by(western_line_parish)

estpost ttest income if electricity_job_direct == 1, by(western_line_parish)

esttab using $output_dir/table-8.tex, ///
    cells("mu_1(fmt(4)) mu_2(fmt(4)) b(fmt(4)) p(fmt(4))") ///
    collabels("Mean (Group 0)" "Mean (Group 1)" "Difference" "p-value") ///
    label replace




tabstat income if electricity_job_indirect == 1, by(western_line_parish)

tabstat income if electricity_job_direct == 0 & electricity_job_indirect == 0, by(western_line_parish)

tabstat income, by(western_line_parish)
