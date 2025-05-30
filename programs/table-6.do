* Table 6

clear
cd "$project_path"
use "data/table-6.dta"
  
eststo clear

oaxaca log_income age age_2 female marital_1 marital_2 marital_3 marital_5 ///
 schooling_2 schooling_3 schooling_4 ///
 hisco_code_2_d_1 hisco_code_2_d_2 hisco_code_2_d_3 hisco_code_2_d_4 hisco_code_2_d_5 hisco_code_2_d_6 hisco_code_2_d_7 hisco_code_2_d_8 hisco_code_2_d_9 hisco_code_2_d_10 hisco_code_2_d_11 hisco_code_2_d_12 hisco_code_2_d_13 hisco_code_2_d_14 hisco_code_2_d_15 hisco_code_2_d_16 hisco_code_2_d_17 hisco_code_2_d_18 hisco_code_2_d_19 hisco_code_2_d_20 hisco_code_2_d_21 hisco_code_2_d_22 hisco_code_2_d_23 hisco_code_2_d_24 hisco_code_2_d_25 hisco_code_2_d_26 hisco_code_2_d_27 hisco_code_2_d_28 hisco_code_2_d_29 hisco_code_2_d_30 hisco_code_2_d_31 hisco_code_2_d_32 hisco_code_2_d_33 hisco_code_2_d_34 hisco_code_2_d_35 hisco_code_2_d_36 hisco_code_2_d_37 hisco_code_2_d_38 hisco_code_2_d_39 hisco_code_2_d_40 hisco_code_2_d_41 hisco_code_2_d_42 hisco_code_2_d_43 hisco_code_2_d_44 hisco_code_2_d_45 hisco_code_2_d_46 hisco_code_2_d_47 hisco_code_2_d_48 hisco_code_2_d_49 hisco_code_2_d_50 hisco_code_2_d_51 hisco_code_2_d_52 hisco_code_2_d_53 hisco_code_2_d_54 hisco_code_2_d_55 hisco_code_2_d_56 hisco_code_2_d_57 hisco_code_2_d_58 hisco_code_2_d_59 hisco_code_2_d_60 hisco_code_2_d_61 hisco_code_2_d_62 hisco_code_2_d_63 hisco_code_2_d_64 hisco_code_2_d_65 hisco_code_2_d_66 hisco_code_2_d_67 hisco_code_2_d_68 hisco_code_2_d_69 hisco_code_2_d_70 hisco_code_2_d_71 hisco_code_2_d_72 hisco_code_2_d_73 hisco_code_2_d_74 railway_in_birth_parish ///
 , by(western_line_parish) pooled vce(cluster birth_parish_ref_code) swap relax
 
eststo Model1
estadd local marital_status_schooling_rail "X"


esttab Model1 using $output_dir/table-6.tex, label replace ///
  keep(group_1  group_2 difference explained unexplained) ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  stats(N, fmt(%9.0fc) labels("Observations")) ///
  cells(b(star fmt(3)) se(par fmt(2)))
