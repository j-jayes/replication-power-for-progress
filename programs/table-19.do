* Table 19

clear
cd "$project_path"
eststo clear


local thresholds 100 150 200 250 300 350 400 450 500

foreach threshold in `thresholds' {
    use "raw_data/power-for-progress-1930-census_raw.dta", clear

    drop if birth_parish_distance_to_line >= `threshold'

    reg log_income western_line_parish age age_2 female i.marital i.schooling i.hisco_code_2_d railway_in_birth_parish, vce(cluster birth_parish_ref_code)
    eststo Model`threshold'
}

local mtitle
foreach threshold in `thresholds' {
    local mtitle `mtitle' "`threshold'"
}


esttab Model100 Model150 Model200 Model250 Model300 Model350 Model400 Model450 Model500 using $output_dir/table-19.tex, label replace ///
  keep(western_line_parish) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  stats(r2 N, fmt(2 %9.0fc) labels("R-squared" "Observations")) ///
  cells(b(star fmt(3)) se(par fmt(2))) mtitle(`mtitle') eqlabels(none) collabels(none) ///
  indicate("Age = age age_2" "Gender = female" "Marital Status = *.marital" "Schooling = *.schooling" "HISCO 2 digit = *.hisco_code_2_d" "Railway in Parish = railway_in_birth_parish" "", labels("X")) 
