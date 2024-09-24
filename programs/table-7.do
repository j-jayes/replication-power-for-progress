* Table 7

clear
set more off 

use "data/table-7.dta"

eststo clear

eststo iv_controls_stage_2: ivreg2 log_income age age_2 female i.marital i.schooling i.hisclass (western_line_parish_dweller = western_line_parish), cluster (birth_parish_ref_code) 

eststo iv_controls_stage_1: reg western_line_parish_dweller western_line_parish age age_2 female i.marital i.schooling i.hisclass, vce(cluster birth_parish_ref_code)


eststo OLS_controls: reg log_income western_line_parish_dweller age age_2 female i.marital i.schooling i.hisclass, vce(cluster birth_parish_ref_code)
	
eststo iv_no_controls_stage_2: ivreg2 log_income (western_line_parish_dweller = western_line_parish), cluster (birth_parish_ref_code) 

eststo iv_no_controls_stage_1: reg western_line_parish_dweller western_line_parish, vce(cluster birth_parish_ref_code)

eststo OLS_no_controls: reg log_income western_line_parish_dweller, vce(cluster birth_parish_ref_code)

#delimit ;

esttab OLS_no_controls OLS_controls iv_no_controls_stage_1 iv_controls_stage_1 iv_no_controls_stage_2 iv_controls_stage_2   using $output_dir/table-5.tex,
	replace
	label 
	se(3)
	b(4)
	
	title("Iv Regression" \label{columns})
	mgroups
	(
	"OLS" "First Stage" "2SLS", pattern(1 0 1 0 1 0)
		prefix(\multicolumn{@span}{c}{)
		suffix(})
		span
		erepeat(\cmidrule(lr){@span})
	)
	mtitles("Log Income" "Log Income" "Current Parish (Treated)"  "Current Parish (Treated)" "Log Income" "Log Income")

    keep(western_line_parish_dweller western_line_parish)

	coeflabels(
	western_line_parish_dweller "Current parish (Western Line)"
	western_line_parish "Birth parish Western Line")
	stats(N ,fmt(%9.0fc))

	
;

	
#delimit cr;
