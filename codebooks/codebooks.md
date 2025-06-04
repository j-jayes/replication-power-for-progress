# Codebooks

## Purpose

This markdown document contains codebooks for the variables constructed
from raw variables in the 1930 census. The codebooks provide a
description of the variables, their values, and the construction
process. Should you wish to replicate the analysis or use the variables
in your own analysis, the codebooks will guide you through the process.

## Variables constructed from the 1930 Swedish census

### Marital Status

The 1930 Swedish census contains a variable `civ` that captures the
civil status of individuals. The variable `civ` is a string, containing
values “O”, “G”, “E”, “X”, and other values. The variable `civ` is
recoded into a new variable `marital_status` that captures the marital
status in a more interpretable format. The recoding is done as follows:

``` stata
* Load your dataset
use "your_dataset.dta", clear

* Generate the new variable marital_status
gen marital_status = ""

* Assign values to marital_status based on civ
replace marital_status = "Unmarried" if civ == "O"
replace marital_status = "Married" if civ == "G"
replace marital_status = "Widow/Widower" if civ == "E"
replace marital_status = "Divorced" if civ == "X"
replace marital_status = "Other" if !inlist(civ, "O", "G", "E", "X")

* Verify the changes
list civ marital_status
```

### Schooling

The 1930 Swedish census contains a variable `skola` that captures the
level of schooling of individuals. The variable `skola` is a string,
containing values from 0 to 9, as well as “X”. The variable `skola` is
recoded into a new variable `schooling_abbreviated` that captures the
level of schooling in a more interpretable format. The recoding is done
as follows:

``` stata
* Load your dataset
use "your_dataset.dta", clear

* Generate the new variable schooling_abbreviated
gen schooling_abbreviated = ""

* Assign values to schooling_abbreviated based on schooling_raw
replace schooling_abbreviated = "Post-secondary and university" if inlist(schooling_raw, 8, 9)
replace schooling_abbreviated = "Post primary schooling" if inlist(schooling_raw, 4, 5, 6, 7)
replace schooling_abbreviated = "Primary school" if schooling_raw == 3
replace schooling_abbreviated = "Literate" if inlist(schooling_raw, 1, 2)
replace schooling_abbreviated = "NA" if schooling_raw == 0

* Verify the changes
list schooling_raw schooling_abbreviated
```

### HISCLASS

Occupations in 1930 have been coded into an abbreviated HISCLASS scheme
in order to analyze the social class of individuals. The HISCLASS scheme
is based on the HISCO classification system, which is a historical
international standard classification of occupations. The HISCLASS
scheme divides occupations into twelve social classes, ranging from “1.
Higher managers” to “12. Unskilled farmworkers”. Our abbreviated version
creates seven groups from these 12 classes.

| Number | Title                                             | Number | Title                  |
|--------|---------------------------------------------------|--------|------------------------|
| 1      | Higher managers                                   | 1      | Elite                  |
| 2      | Higher professionals                              |        |                        |
| 3      | Lower managers                                    | 2      | White collar           |
| 4      | Lower professionals, clerical and sales personnel |        |                        |
| 5      | Lower clerical and sales personnel                |        |                        |
| 6      | Foremen                                           | 3      | Foremen                |
| 7      | Medium-skilled workers                            | 4      | Medium-skilled workers |
| 8      | Farmers and fishermen                             | 5      | Farmers and fishermen  |
| 9      | Low-skilled workers                               | 6      | Low-skilled workers    |
| 10     | Low-skilled farm workers                          |        |                        |
| 11     | Unskilled workers                                 | 7      | Unskilled workers      |
| 12     | Unskilled farm workers                            |        |                        |

Because the 1930 census lacked hisco codes associated with the
occupational titles when we got access to it, we used the hisco codes
from the 1900 and 1910 censuses from IPUMS to assign hisco codes to the
1930 census. The hisco codes were then used to assign the HISCLASS
groups to the 1930 census. For the common occupational titles that were
included in the 1930 census but did not exist in the 1900 and 1910
censuses, we hand coded the hisco codes and assigned the HISCLASS
groups. The complete list of occupational titles and their associated
HISCO codes and HISCLASS groups can be found in the dataset
`hisco_1930.dta`, in the codebooks folder.

The dataset `hisco_1930.dta` contains the following variables:

- `occupation_title`: The title of the occupation.
- `hisco_code`: The HISCO code associated with the occupation.
- `hisclass_group`: The HISCLASS group assigned to the occupation.

An excerpt of the dataset is shown below:

``` r
hisco_1930 <- read_dta("hisco_1930.dta")

hisco_1930 %>% head()
```

    # A tibble: 6 × 3
      occupation_title   hisco_code hisclass_group
      <chr>                   <dbl> <chr>         
    1 Kemist f. d.             1100 Elite         
    2 Kemist                   1100 Elite         
    3 Kemist v. järnbruk       1100 Elite         
    4 Kemistbiträde            1100 Elite         
    5 Kemist f.d.              1100 Elite         
    6 Kemist S.K.F.            1100 Elite         

### Electricity job (direct)

We define a new variable `electricity_job_direct` that captures whether
an individual has a job directly related to electricity. The variable
`electricity_job_direct` is a binary variable, taking the value 1 if the
individual has a job directly related to electricity and 0 otherwise.
The variable `electricity_job_direct` is constructed based on the
variable `yrke`, which contains the occupation of the individual. The
variable `electricity_job_direct` is constructed as follows:

``` stata
* Load your dataset
use "your_dataset.dta", clear

* Generate the new variable electricity_job_direct
gen electricity_job_direct = 0

* Assign values to electricity_job_direct based on yrke
replace electricity_job_direct = 1 if regexm(yrke, "elektr", "i")
replace electricity_job_direct = 1 if yrke == "Elmontör"
replace electricity_job_direct = 1 if yrke == "Linjearbetare"
replace electricity_job_direct = 1 if yrke == "Kraftverksarbetare"

* Verify the changes
list yrke electricity_job_direct
```

### Electricity job (indirect)

Similarly, we create a variable called `electricity_job_indirect` that
captures whether an individual has a job indirectly related to
electricity. The variable `electricity_job_indirect` is a binary
variable, taking the value 1 if the individual has a job indirectly
related to electricity and 0 otherwise. The variable
`electricity_job_indirect` is constructed based on the variable `yrke`,
which contains the occupation of the individual. The variable
`electricity_job_indirect` is hand coded from a list of common
occupations in the 1930 census that are indirectly related to
electricity.

The list of indirect electricity jobs is located at
`indirect_electricity_jobs_1930.dta`, in the codebooks folder. The
dataset `indirect_electricity_jobs_1930.dta` contains the following
variables:

- `occupation`: The occupation that is indirectly related to
  electricity.

An excerpt of the dataset is shown below:

``` r
indirect_electricity_jobs_1930 <- read_dta("indirect_electricity_jobs_1930.dta")

indirect_electricity_jobs_1930 %>% head()
```

    # A tibble: 6 × 1
      occupation                 
      <chr>                      
    1 Ackumulatorsfabriksarbetare
    2 Appretörarbetare           
    3 Arbetare å Kalmar Bobin    
    4 Armaturarbetare            
    5 Avsynare                   
    6 Bageriarbetare             

To code this up in Stata, you can use the following code:

``` stata
* Load the list of indirect electricity jobs
use "codebooks/indirect_electricity_jobs_1930.dta", clear

* Create a local macro with the list of occupations
local occupations
levelsof occupation, local(occupations)

* Load your main dataset again
use "your_dataset.dta", clear

* Generate the new variable indirect_electricity_job
gen indirect_electricity_job = 0

* Assign values to indirect_electricity_job based on yrke
foreach occ in `occupations' {
    replace indirect_electricity_job = 1 if yrke == "`occ'"
}

* Verify the changes
list yrke indirect_electricity_job
```

### Employed

The variable `employed` is a binary variable, taking the value 1 if the
individual is employed and 0 otherwise. The variable `employed` is
constructed based on the variable `hisclass_group`, which contains the
HISCLASS group of the individual. The variable `employed` is constructed
as follows:

``` stata
* Load your dataset
use "your_dataset.dta", clear

* Generate the new variable employed
gen employed = 0

* Assign value 1 to employed if hisclass_group is not missing
replace employed = 1 if !missing(hisclass_group)

* Verify the changes
list hisclass_group employed
```

### Union Membership

``` stata
* Load the data from the Excel file
use "union_density_1930.dta", clear

* Group by 'parish_code' and 'type_of_organization' and sum the number of members for 1900, 1910, and 1930
collapse (sum) n_members_1900 n_members_1910 n_members_1930 ///
         (first) population_1900 population_1910 population_1930, ///
         by(parish_code type_of_organization)

* Calculate union density for 1900, 1910, and 1930
gen union_density_1900 = (n_members_1900 / population_1900) * 100
gen union_density_1910 = (n_members_1910 / population_1910) * 100
gen union_density_1930 = (n_members_1930 / population_1930) * 100

* Load the original data again to get 'western_line' and 'distance_to_line'
use "union_density_1930.dta"

* Merge the grouped data with the original data
merge 1:m parish_code using "data/parishes/union_membership_and_western_line_groups_merged.xlsx"

* Drop duplicates
duplicates drop

* Group parishes into 'western_line', 'control', and 'other' based on the conditions
gen group = "other"
replace group = "western_line" if western_line == 1
replace group = "control" if western_line == 0 & distance_to_line < 300

* Cap the union densities at 100% for all years
replace union_density_1900 = min(union_density_1900, 100)
replace union_density_1910 = min(union_density_1910, 100)
replace union_density_1930 = min(union_density_1930, 100)

* Pivot the data
reshape wide union_density_1900 union_density_1910 union_density_1930, i(parish_code) j(type_of_organization) string

* Replace missing values with zero
foreach var of varlist union_density_* {
    replace `var' = 0 if missing(`var')
}

* Verify the changes
list parish_code union_density_1900 union_density_1910 union_density_1930
```

## Information on parishes in the 1930 Swedish census

### Parish list

The digitization of the 1930 Swedish census was not complete when we got
access to it from the National Archives of Sweden. As a result, we
include a dataset `parishes_1930.dta` that contains the unique parish
names and reference codes from the 1930 census that we use in our
analysis. The dataset `parishes_1930.dta` contains the following
variables:

- `parish_name`: The name of the parish.
- `parish_code`: The reference code of the parish.

An excerpt of the dataset is shown below:

``` r
parishes_1930 <- read_dta("parishes_1930.dta")

parishes_1930 %>% head()
```

    # A tibble: 6 × 2
      parish_name              parish_code 
      <chr>                    <chr>       
    1 Vada församling          SE/011506000
    2 Roslags-Kulla församling SE/011704000
    3 Nämdö församling         SE/012004000
    4 Ingarö församling        SE/012005000
    5 Munsö församling         SE/012501000
    6 Adelsö församling        SE/012502000

### Western Line Parishes

We created a binary variable for if a parish lay on the `western_line`
between two large hydropower plants in Sweden. The variable
`western_line` is a binary variable, taking the value 1 if the parish is
on the western line and 0 otherwise. The variable `western_line` is
constructed based on the electricity lines that were built between the
hydropower plants in the early 20th century, and hand coded based on the
geographical location of the parishes which intersected the main
electricity line. The dataset we show below contains the names and
reference codes of the parishes that are on the Western Line for which
there is at least one individual born in that parish in the 1930 census.

The list of Western Line parishes is located at
`western_line_parishes_1930.dta`, in the codebooks folder. The dataset
`western_line_parishes_1930.dta` contains the following variables:

- `parish_code`: The reference code of the parish.
- `parish_name`: The name of the parish.

An excerpt of the dataset is shown below:

``` r
df <- read_dta("western_line_parishes_1930.dta")

df %>% head()
```

    # A tibble: 6 × 2
      parish_code  parish_name               
      <chr>        <chr>                     
    1 SE/198305000 Odensvi församling (U-län)
    2 SE/188404000 Nora Bergs församling     
    3 SE/196201000 Norbergs församling       
    4 SE/168121000 Norra Härene församling   
    5 SE/168001000 Mariestads församling     
    6 SE/208472000 Folkärna församling       

To code this up in Stata, you can join the dataset with the main dataset
using the `parish_code` variable:

``` stata
* Load the western line parishes dataset
use "western_line_parishes_1930.dta", clear

* Generate a variable to indicate that the parish is on the western line
gen western_line = 1

* Merge with the main dataset based on parish_code
merge 1:m parish_code using "your_dataset.dta"

* Verify the merge
list parish_code _merge

* Drop the _merge variable
drop _merge
```
