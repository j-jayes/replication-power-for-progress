* Table 20 pt 1
 
clear
cd "$project_path"
eststo clear

use "data/table-20.dta"

global x age age_2 female i.marital i.schooling i.hisclass railway_in_birth_parish

* Run quantile regressions for each quantile and store the results
foreach q in 15 25 35 45 55 65 75 85 {
    local quantile = `q' / 100
    rqr log_income western_line_parish, quantile(`quantile') controls($x)
    eststo Model`q'
}

* Create custom column labels for the quantiles
local mtitle "15th" "25th" "35th" "45th" "55th" "65th" "75th" "85th"

* Display the results in columns
esttab Model15 Model25 Model35 Model45 Model55 Model65 Model75 Model85 using $output_dir/table-20_1.tex, label replace ///
  keep(western_line_parish) ///
  stats(r2 N F, fmt(2 %9.0fc 2) labels("R-squared" "Observations" "F-stat")) ///
  cells(b(star fmt(3)) se(par fmt(2))) mtitle(`mtitle') eqlabels(none) collabels(none) ///
  title(Residualized Quantile Regression)


* Table 20 pt 2

global x age age_2 female i.marital i.schooling i.hisclass railway_in_birth_parish
  
* Run quantile regressions for each quantile and store the results
foreach q in 15 25 35 45 55 65 75 85 {
    local quantile = `q' / 100
    qreg2 log_income western_line_parish $x, quantile(`quantile')
    eststo Model`q'
}

local mtitle "15th" "25th" "35th" "45th" "55th" "65th" "75th" "85th"

* Display the results in columns
esttab Model15 Model25 Model35 Model45 Model55 Model65 Model75 Model85 using $output_dir/table-20_2.tex, label replace ///
  keep(western_line_parish) ///
  stats(r2 N F, fmt(2 %9.0fc 2) labels("R-squared" "Observations" "F-stat")) ///
  cells(b(star fmt(3)) se(par fmt(2))) mtitle(`mtitle') eqlabels(none) collabels(none) ///
  title(Conditional Quantile Regression)

