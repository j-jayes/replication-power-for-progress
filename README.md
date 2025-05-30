
# Replication package for Power for progress: The impact of electricity on individual labor market outcomes

By Jonathan Jayes, Kerstin Enflo and Jakob Molinder

## Overview

This replication package includes the data and code used in 'Power for progress: The impact of electricity on individual labor market outcomes.' The provided code constructs the analysis dataset from various historical data sources and generates all tables and figures used in the paper. The package is designed to be run in R and Stata, and includes the necessary scripts to reproduce the analysis. It should take 10 minutes in total to reproduce the results.

## Data Availability and Provenance Statements

- [X] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript.

### Summary of Availability

- [ ] All data **are** publicly available.
- [X] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.
- [ ] Confidential data used in this paper and not provided as part of the public replication package will be preserved for \_\_\_ years after publication, in accordance with journal policies.

### Details on each Data Source

| Data.Name                                  | Data.Files                             | Location   | Provided | Citation                              |
| ------------------------------------------ | -------------------------------------- | ---------- | -------- | ------------------------------------- |
| "Swedish Census 1930"                      | power-for-progress-1930-census_raw.dta | raw_data/  | FALSE    | Riksarkivet (2022)                    |
| “Map Data on Electricity Lines”          | figure-3.rds                           | data/      | TRUE     | Hjulström (1940)                     |
| "Location Data on Power Plants"            | table-2.dta & table-3.dta              | data/      | TRUE     |                                       |
| "Swedish Censuses 1880-1900"               | table-1.dta                          | data/           | TRUE    | Ruggles, et al (2024)                 |
| "Occupation coding lookup"                 | hisco_1930.dta                         | codebooks/ | TRUE     |                                       |
| "Indirect Electricity Jobs Classification" | indirect_electricity_jobs_1930.dta     | codebooks/ | TRUE     |                                       |
| "Parishes included in 1930 census"         | parishes_1930.dta                      | codebooks/ | TRUE     |                                       |
| "Union Density by Parish"                  | union_density_1930.dta                 | codebooks/ | FALSE    | Lundkvist, S., & Andrae, C.-G. (1998) |

### Public use data collected by the authors

Data on the location of power plants and electricity lines were collected by the authors from historical maps and reports. The data are provided in the replication package, in the `data/` directory, figure 3 and tables 2 and 3.

### Public use data with required registration and provided extract

Census data from Ruggles, et al (2024) and Union Membership data from Lundkvist and Andrae (1998) are not provided in this replication package as they do not allow for redistribution. The data are available from the original sources. See the `codebooks/` directory for a description of the variables used in the analysis.

### Confidential data

The Swedish census data from 1930 is provided to us by Riksarkivet (2022) and is not publicly available. To replicate this analysis, researchers must obtain the data from Riksarkivet. We were provided with a sample of the data which had been transcribed at the time, containing approximately 30% of the total number of parishes in Sweden in 1930. In order to allow replication when the full census is digitized, we include a list of parishes used in our analysis in the `codebooks/` directory.

## Dataset list

| Data file                             | Source      | Notes                                                                        | Provided |
| ------------------------------------- | ----------- | ---------------------------------------------------------------------------- | -------- |
| `data/raw/lbd.dta`                  | LBD         | Confidential                                                                 | No       |
| `data/raw/terra.dta`                | IPUMS Terra | As per terms of use                                                          | Yes      |
| `data/derived/regression_input.dta` | All listed  | Combines multiple data sources, serves as input for Table 2, 3 and Figure 5. | Yes      |
## Key Variable Descriptions

For a complete list and more details, please refer to `/codebooks/codebook.qmd`. The primary individual-level dataset from the 1930 Swedish Census (restricted access) is represented in files like `table-5.dta`, which contains approximately 523,849 observations and around 35 variables.

### Variables from the 1930 Swedish Census (Restricted Access - based on `table-5.dta` structure)

| Variable Name (from Stata)    | Description (from Stata Variable Label or paper)                               | Origin of the Variable                                     |
| ----------------------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| `id`                          | Unique identifier for each individual                                          | 1930 Census                                                |
| `log_income`                  | Log Income                                                                     | 1930 Census (from tax registers, gross income) |
| `log_wealth`                  | Log Wealth                                                                     | 1930 Census                                                |
| `employed`                    | Occupation listed (binary indicator)                                           | 1930 Census                                                |
| `occ_title_without_income`    | Has occupational title but no income                                           | 1930 Census                                                |
| `electricity_job_direct`      | Electricity in Job (Direct): Job directly related to electricity (e.g., electrician) | Hand-coded from 1930 Census occupational titles |
| `electricity_job_indirect`    | Electricity in Job (Indirect): Job indirectly affected by electricity (e.g., machinery operator) | Hand-coded from 1930 Census occupational titles |
| `union_density_1890`          | Union density in the (birth) parish in 1890 (joined historical data)         | Andrae and Lundqvist (1998), joined to 1930 Census data  |
| `union_density_1900`          | Union density in the (birth) parish in 1900 (joined historical data)         | Andrae and Lundqvist (1998), joined to 1930 Census data  |
| `union_density_1910`          | Union density in the (birth) parish in 1910 (joined historical data)         | Andrae and Lundqvist (1998), joined to 1930 Census data  |
| `union_density_1930`          | Union density in the (birth) parish in 1930 (joined historical data)         | Andrae and Lundqvist (1998), joined to 1930 Census data  |
| `age`                         | Age of individual in 1930                                                      | 1930 Census                                                |
| `age_2`                       | Age Squared                                                                    | Derived from `age` variable from 1930 Census             |
| `female`                      | Female (1 = Yes, 0 = No)                                                       | 1930 Census                                                |
| `schooling_above_primary`     | Schooling above primary level                                                  | Derived from 1930 Census `schooling` variable            |
| `western_line_parish`         | Born in a Western Line Parish                                                  | Geographic location of birth parish & Western Line definition |
| `western_line_parish_dweller` | Resides in a Western Line Parish in 1930                                       | Geographic location of current parish & Western Line definition |
| `birth_parish_distance_to_line` | Birth Parish Distance to Western Line (km)                                     | Calculated from geographic data                            |
| `current_parish_distance_to_line`| Current Parish Distance to Western Line (km)                                   | Calculated from geographic data                            |
| `birth_parish_touching_treated`| Birth Parish Touching Treated (near Western Line)                              | Treatment variable based on proximity                      |
| `current_parish_touching_treated`| Current Parish Touching Treated (near Western Line)                            | Treatment variable based on proximity                      |
| `birth_parish_ref_code`       | Reference code for the birth parish                                            | 1930 Census                                                |
| `birth_parish_parish`         | Name of the birth parish                                                       | 1930 Census                                                |
| `current_parish_ref_code`     | Reference code for the current parish                                          | 1930 Census                                                |
| `current_parish_parish`       | Name of the current parish                                                     | 1930 Census                                                |
| `dist_bp_to_cp_km`            | Distance from birth parish to current parish (km)                              | Calculated from geographic data                            |
| `railway_in_birth_parish`     | Railway in Birth Parish (indicator)                                            | Historical railway data joined to 1930 Census            |
| `railway_in_current_parish`   | Railway in Current Parish (indicator)                                          | Historical railway data joined to 1930 Census            |
| `mean_farm_share_1910`        | Mean share of farming households in birth parish in 1910 (control)             | 1910 Census data, joined to 1930 Census                  |
| `urban_parish_1910`           | Birth parish has more non-farming households than average in 1910 (control)    | 1910 Census data, joined to 1930 Census                  |
| `schooling`                   | Schooling Abbreviation (categorical: less than primary, primary, secondary, tertiary) | 1930 Census, coded as per paper [cite: 110, 111]           |
| `marital`                     | Marital Status (categorical)                                                   | 1930 Census                                                |
| `hisclass`                    | HISCLASS Group Abbreviation (social class scheme)                              | Coded from 1930 Census occupational data via HISCO [cite: 94, 99] |
| `hisco_code_2_digit`          | HISCO code two digit (occupational classification)                             | Coded from 1930 Census occupational data [cite: 94, 97]  |


### Power stations and transformers in 1926 at the Parish level

| Name                            | Label                                   | Description                                                        | Origin of the Variable                                | Script | Source          |
| ------------------------------- | --------------------------------------- | ------------------------------------------------------------------ | ----------------------------------------------------- | ------ | --------------- |
| area                            | Parish area in square kilometers        | Area of the parish measured in square kilometers                   | Geographic data                                       |        | Junkka (2015))  |
| western_line_parish             | Western Line Parish                     | Indicates if the parish is along the Western Line                  | Geographic location of parishes                       |        |                 |
| population_1900                 | Parish population in 1900               | Number of inhabitants in the parish in 1900                        | 1900 Census                                           |        | Ruggles (2018)) |
| distance_to_line                | distance_to_line                        | Distance from the parish to the Western Line in kilometers         | Geographic data                                       |        |                 |
| latitude                        | Latitude                                | Latitude coordinate of the parish                                  | Geographic data                                       |        |                 |
| longitude                       | Longitude                               | Longitude coordinate of the parish                                 | Geographic data                                       |        |                 |
| log_total_power                 | Log Total Power Capacity               | Log-transformed total power installed in the parish                | Digitized data from Electrification Committee Reports |        |                 |
| log_total_power_transmitted     | Log Total Power Capacity Transmitted    | Log-transformed total power transmission capacity to the parish   | Digitized data from Electrification Committee Reports |        |                 |
| log_total_power_generated       | Log Total Power Capacity Generated      | Log-transformed total power generation capacity within the parish | Digitized data from Electrification Committee Reports |        |                 |
| log_total_connections           | Log Total Power Connections             | Log-transformed number of connections installed in the parish      | Digitized data from Electrification Committee Reports |        |                 |
| log_num_connections_transmitted | Log Total Power Connections Transmitted | Log-transformed number of transformers in the parish               | Digitized data from Electrification Committee Reports |        |                 |
| log_num_connections_generated   | Log Total Power Connections Generated   | Log-transformed number of generators in the parish                | Digitized data from Electrification Committee Reports |        |                 |

## Computational requirements

### Replication of figures

The figures are produced using R and the `ggplot2` package. The code is written in R and requires the following packages:

- `tidyverse` for data manipulation and visualization.
- `showtext` to enable custom fonts in plots.
- `ggtext` for enhanced text rendering in ggplot2.
- `sf` for handling and visualizing spatial data.
- `here` to simplify file paths.
- `gghighlight` to highlight data in plots.
- `magick` for combining and manipulating images.
- `glue` for string interpolation in plot labels.

To install these in the same versions as used in the original analysis, run the following code:

```r

# Setting the date for CRAN package versions (Posit Package Manager)
ppm.date <- "2024-09-01"
options(repos = paste0("https://packagemanager.posit.co/cran/", ppm.date, "/"))

# Function to check and install missing packages
pkgTest <- function(x, y = "") {
  if (!require(x, character.only = TRUE)) {
    if (y == "") {
      install.packages(x, dep = TRUE)
    } else {
      remotes::install_version(x, y)
    }
    if (!require(x, character.only = TRUE)) stop("Package not found")
  }
  return("OK")
}

# Global libraries required for this replication package
global.libraries <- c(
  "tidyverse",   # Data manipulation and visualization
  "showtext",    # Custom fonts for plots
  "ggtext",      # Enhanced text rendering in ggplot2
  "sf",          # Spatial data handling and visualization
  "here",        # File path management
  "gghighlight", # Highlighting data in ggplot2
  "magick",      # Image manipulation
  "glue"         # String interpolation
)

# Install and load necessary libraries
results <- sapply(as.list(global.libraries), pkgTest)

# Print results of package loading
print(results)
```

### Software Requirements

- [X] The replication package contains one or more programs to install all dependencies and set up the necessary directory structure.

- Stata (code was last run with version 18)

  - `estout` (as of 2024-09-01)
  - `oaxaca` (as of 2024-09-01)
  - `rqr` (as of 2024-09-01)
  - the program "`0-replication-setup.do`" will install all dependencies locally, and should be run once.
- R 4.3.1

  - `tidyverse` (2.0.0)
  - `showtext` (0.9-7)
  - `ggtext` (0.1.2)
  - `sf` (1.0-17)
  - `here` (1.0.1)
  - `gghighlight` (0.4.1)
  - `magick` (2.8.5)
  - `glue` (1.8.0)
  - the file "`figures.qmd`" will install all dependencies (latest version), and should be run once prior to running other programs.

### Memory, Runtime, Storage Requirements

#### Summary

Approximate time needed to reproduce the analyses on a standard (CURRENT YEAR) desktop machine:

- [ ] <10 minutes
- [X] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ]

Approximate storage space needed:

- [ ] < 25 MBytes
- [X] 25 MB - 250 MB
- [ ] 250 MB - 2 GB
- [ ] 2 GB - 25 GB
- [ ] 25 GB - 250 GB
- [ ]
- [ ] Not feasible to run on a desktop machine, as described below.

#### Details

The code was last run on a **M2 MacBook Pro laptop with MacOS version 14.6.1 with 50GB of free space and 16BG of RAM**.

## Description of programs/code

- Programs in `programs/01_dataprep` will extract and reformat all datasets referenced above. The file `programs/01_dataprep/main.do` will run them all.
- Programs in `programs/02_analysis` generate all tables and figures in the main body of the article. The program `programs/02_analysis/main.do` will run them all. Each program called from `main.do` identifies the table or figure it creates (e.g., `05_table5.do`). Output files are called appropriate names (`table5.tex`, `figure12.png`) and should be easy to correlate with the manuscript.
- Programs in `programs/03_appendix` will generate all tables and figures in the online appendix. The program `programs/03_appendix/main-appendix.do` will run them all.
- Ado files have been stored in `programs/ado` and the `main.do` files set the ADO directories appropriately.
- The program `programs/00_setup.do` will populate the `programs/ado` directory with updated ado packages, but for purposes of exact reproduction, this is not needed. The file `programs/00_setup.log` identifies the versions as they were last updated.
- The program `programs/config.do` contains parameters used by all programs, including a random seed. Note that the random seed is set once for each of the two sequences (in `02_analysis` and `03_appendix`). If running in any order other than the one outlined below, your results may differ.

## Instructions to Replicators

<!-- > INSTRUCTIONS: The first two sections ensure that the data and software necessary to conduct the replication have been collected. This section then describes a human-readable instruction to conduct the replication. This may be simple, or may involve many complicated steps. It should be a simple list, no excess prose. Strict linear sequence. If more than 4-5 manual steps, please wrap a main program/Makefile around them, in logical sequences. Examples follow. -->

- Edit `programs/config.do` to adjust the default path
- Run `programs/00_setup.do` once on a new system to set up the working environment.
- Download the data files referenced above. Each should be stored in the prepared subdirectories of `data/`, in the format that you download them in. Do not unzip. Scripts are provided in each directory to download the public-use files. Confidential data files requested as part of your FSRDC project will appear in the `/data` folder. No further action is needed on the replicator's part.
- Run `programs/01_main.do` to run all steps in sequence.

### Details

- `programs/00_setup.do`: will create all output directories, install needed ado packages.
  - If wishing to update the ado packages used by this archive, change the parameter `update_ado` to `yes`. However, this is not needed to successfully reproduce the manuscript tables.
- `programs/01_dataprep`:
  - These programs were last run at various times in 2018.
  - Order does not matter, all programs can be run in parallel, if needed.
  - A `programs/01_dataprep/main.do` will run them all in sequence, which should take about 2 hours.
- `programs/02_analysis/main.do`.
  - If running programs individually, note that ORDER IS IMPORTANT.
  - The programs were last run top to bottom on July 4, 2019.
- `programs/03_appendix/main-appendix.do`. The programs were last run top to bottom on July 4, 2019.
- Figure 1: The figure can be reproduced using the data provided in the folder “2_data/data_map”, and ArcGIS Desktop (Version 10.7.1) by following these (manual) instructions:
  - Create a new map document in ArcGIS ArcMap, browse to the folder
    “2_data/data_map” in the “Catalog”, with files "provinceborders.shp", "lakes.shp", and "cities.shp".
  - Drop the files listed above onto the new map, creating three separate layers. Order them with "lakes" in the top layer and "cities" in the bottom layer.
  - Right-click on the cities file, in properties choose the variable "health"... (more details)

## List of tables and programs

<!-- > INSTRUCTIONS: Your programs should clearly identify the tables and figures as they appear in the manuscript, by number. Sometimes, this may be obvious, e.g. a program called "`table1.do`" generates a file called `table1.png`. Sometimes, mnemonics are used, and a mapping is necessary. In all circumstances, provide a list of tables and figures, identifying the program (and possibly the line number) where a figure is created.
>
> NOTE: If the public repository is incomplete, because not all data can be provided, as described in the data section, then the list of tables should clearly indicate which tables, figures, and in-text numbers can be reproduced with the public material provided. -->

The provided code reproduces:

- [ ] All numbers provided in text in the paper
- [ ] All tables and figures in the paper
- [X] Selected tables and figures in the paper, as explained and justified below.

| Figure/Table # | Program              | Output file   | Note                                               |
| -------------- | -------------------- | ------------- | -------------------------------------------------- |
| Table 1        | programs/table-1.do  | table-1.tex   | Requires confidential data                         |
| Table 2        | programs/table-2.do  | table-2.tex   |                                                    |
| Table 3        | programs/table-3.do  | table-3.tex   |                                                    |
| Table 4        | programs/table-4.do  | table-4.tex   | Requires confidential data                         |
| Table 5        | programs/table-5.do  | table-5.tex   | Requires confidential data                         |
| Table 6        | programs/table-6.do  | table-6.tex   | Requires confidential data                         |
| Table 7        | programs/table-7.do  | table-7.tex   | Requires confidential data                         |
| Table 8        | programs/table-8.do  | table-8.tex   | Requires confidential data                         |
| Table 9        | programs/table-9.do  | table-9.tex   | Requires confidential data                         |
| Table 10       | programs/table-10.do | table-10.tex  | Requires confidential data                         |
| Table 11       | programs/table-11.do | table-11.tex  | Requires confidential data                         |
| Table 12       | programs/table-12.do | table-12.tex  | Requires confidential data                         |
| Table 13       | programs/table-13.do | table-13.tex  | Requires confidential data                         |
| Table 14       | programs/table-14.do | table-14.tex  | Requires confidential data                         |
| Table 15       | programs/table-15.do | table-15.tex  | Requires confidential data                         |
| Figure 1       | programs/figures.qmd | figure-1.png  | Source: Vattenfall (1948), Bengtsson et al. (2021) |
| Figure 2       | programs/figures.qmd | figure-2.png  | Source: Schön (2000)                              |
| Figure 3       | programs/figures.qmd | figure-3.png  | Source: Hjulström (1940), Junkka (2015)           |
| Figure 4       | programs/figures.qmd | figure-4.png  | Requires confidential data                         |
| Figure 4       | programs/figures.qmd | figure-4.png  | Requires confidential data                         |
| Figure 5       | programs/figures.qmd | figure-5.png  | Requires confidential data                         |
| Figure 6       | programs/figures.qmd | figure-6.png  | Requires confidential data                         |
| Figure 7       | programs/figures.qmd | figure-7.png  | Requires confidential data                         |
| Figure 8       | programs/figures.qmd | figure-8.png  | Requires confidential data                         |
| Figure 9       | programs/figures.qmd | figure-9.png  | Requires confidential data                         |
| Figure 12      | programs/figures.qmd | figure-12.png | Requires confidential data                         |
| Figure 13      | programs/figures.qmd | figure-13.png | Requires confidential data                         |
| Figure 14      | programs/figures.qmd | figure-14.png | Requires confidential data                         |
| Figure 15      | programs/figures.qmd | figure-15.png | Requires confidential data                         |

## References

Bengtsson, Erik, Jakob Molinder, and Svante Prado, “Incomes and Income Inequality in Stockholm, 1870–1950,” October 7–9, 2021. Presented at the Swedish Economic History Meeting, Session “Labour, wages and inequality”.

Hjulström, Filip, Sveriges elektrifiering: en ekonomisk-geografisk studie över den elektriska energiförsörjningens utveckling, Uppsala: Lundequistska Bokhandeln, 1940.

Junkka, Johan. (2015) 2024. ‘Swedish Historical Administrative Maps’. R. https://github.com/junkka/histmaps.

Lundkvist, S., & Andrae, C.-G. (1998). Popular movement archive 1881–1950 (1.0) [Data set]. Uppsala University. Available at: https://doi.org/10.5878/002531

Riksarkivet, “Sveriges befolkning 1930 [Swedish Population Census 1930],” 2023. Data provided by the Swedish National Archives (Riksarkivet) for the research project "Electricity, Societal Change and Labour Market Transformation."

Roine, J., & Waldenström, D. (2010). Top Incomes in Sweden over the Twentieth Century. In A. B. Atkinson & T. Piketty (Eds.), Top Incomes: A Global Perspective (pp. 285–348). Oxford University Press.

Ruggles, Steven, Lara Cleveland, Rodrigo Lovaton, Sula Sarkar, Matthew Sobek, Derek Burk, Dan Ehrlich, Quinn Heimann, and Jane Lee, “Integrated Public Use Microdata Series, International: Version 7.5 [dataset],” 2024.

Schön, Lennart, “Electricity, technological change and productivity in Swedish industry, 1890–1990,” European Review of Economic History, 2000, 4(2), 175–194.

Schön, L., & Krantz, O. (2012). The Swedish economy in the early modern period: constructing historical national accounts. European Review of Economic History, 16(4), 529–549.

Statistics Sweden. (2015, March 3). Urbanisering – från land till stad [Urbanisation – from country to city]. SCB. Retrieved from https://www.scb.se/hitta-statistik/artiklar/2015/Urbanisering--fran-land-till-stad/

The Swedish National Archives, Umeå University, and the Minnesota Population Center, National Sample of the 1890 Census of Sweden, Version 2.0, Minneapolis: Minnesota Population Center [distributor] 2011. https://www.nappdata.org/napp/.

The Swedish National Archives, Umeå University, and the Minnesota Population Center, National Sample of the 1900 Census of Sweden, Version 3.0, Minneapolis: Minnesota Population Center [distributor] 2011. https://www.nappdata.org/napp/.

van Leeuwen, M. H. D., & Maas, I. (2011). HISCLASS: A Historical International Social Class Scheme. Leuven: Leuven University Press.

Vattenfall, “Procentuellt antal elektrifierade hushåll,” 1948. Accessed: 2024-03-21.