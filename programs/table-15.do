* Table 15
clear
cd "$project_path"
use "data/table-15.dta"


gen mover = .

replace mover = 0 if dist_bp_to_cp_km == 0

replace mover = 1 if dist_bp_to_cp_km > 0

 
label var mover "Moves from parish of birth"

tab mover western_line_parish, col
esttab 
