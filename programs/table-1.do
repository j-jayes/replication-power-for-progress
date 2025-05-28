clear

use "data/table-1.dta"

label var shc1 "Elite (\% change)"
label var shc2 "White collar (\% change)"
label var shc3 "Foremen (\% change)"
label var shc4 "Medium skilled (\% change)"
label var shc5 "Farmers (\% change)"
label var shc6 "Lower skilled (\% change)"
label var shc7 "Unskilled (\% change)"
label var llabforce "Change in Log (1 + Labour Force)"

* collapse (mean) shc1 shc2 shc3 shc4 shc5 shc6 shc7 llabforce, by(western_line_parish)

estpost tabstat shc1 shc2 shc3 shc4 shc5 shc6 shc7 llabforce, by(western_line_parish) statistics(mean)

esttab . using $output_dir/table-1.tex, label replace
