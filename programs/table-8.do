* Table 8

clear
set more off 

use "data/table-8.dta"

eststo clear

tabstat log_income electricity_job_direct electricity_job_indirect, by(western_line_parish)

gen income = exp(log_income)

tabstat income, by(western_line_parish)

tabstat income, by(western_line_parish)
