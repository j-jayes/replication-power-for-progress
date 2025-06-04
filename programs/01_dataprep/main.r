# ---
# Title: R Translation of Census Data Processing Notebook
# Author: Jonathan Jayes
# Date: 04-06-2025
# Description: This script does the cleaning and merging of the main census dataset for 'Power for progress: The impact of electricity on individual labor market outcomes.'
# Input Files:
#   - data/census/00-raw-census-data.parquet
#   - data/first-stage/01-parish-power-station-data.xlsx
#   - data/union-data/02-union-density-by-parish.csv
#   - data/balance-tests/03-control-parishes-to-drop.xlsx
#   - data/census/04-merged-census-data-intermediate.parquet (intermediate, written and read by this script)
# Output Files:
#   - data/temp/sample-check-20rows-merged-census.xlsx (sample Excel output)
#   - data/census/04-merged-census-data-intermediate.parquet (intermediate output)
#   - data/census/05-merged-census-data-filtered-unbalanced.parquet (intermediate output)
#   - data/census/06-final-regression-dataset-for-stata.dta (final Stata output)
# ---

# Load necessary libraries
library(arrow)    # For Parquet files
library(readxl)   # For Excel files
library(dplyr)    # For data manipulation
library(stringr)  # For string operations
library(tidyr)    # For data tidying (e.g., replace_na)
library(haven)    # For Stata files
library(fs)       # For path manipulation
# library(openxlsx) # Alternative for writing Excel files, if writexl is not preferred
library(writexl)  # For writing Excel files

# --- Setup ---
# Define the root directory (parent of the current working directory)
root <- fs::path_dir(getwd()) 
# If using RStudio Projects, `here::here()` could be an alternative for robust path management.
# root <- here::here() 

# --- 1. Join First Stage Data to Birth Place Information ---
cat("Starting: 1. Join First Stage Data to Birth Place Information\n")

# Read in census data
df_census_1930 <- arrow::read_parquet(fs::path(root, "data/census/00-raw-census-data.parquet"))

# Rename columns
df_census_1930 <- df_census_1930 %>%
  rename(
    name = arkbild,
    ref_code_current_parish = scbkod,
    ref_code_birth_parish = fscbkod
  )

# Remove whitespace from ref_code_birth_parish
df_census_1930$ref_code_birth_parish <- str_trim(df_census_1930$ref_code_birth_parish)

# Convert to numeric, coercing errors to NA (similar to pd.to_numeric with errors='coerce')
# Ensure it's character first if it's a factor
df_census_1930$ref_code_birth_parish <- as.numeric(as.character(df_census_1930$ref_code_birth_parish))

# If ref_code_birth_parish is NA, fill it with ref_code_current_parish
df_census_1930 <- df_census_1930 %>%
  mutate(
    ref_code_birth_parish = ifelse(is.na(ref_code_birth_parish), ref_code_current_parish, ref_code_birth_parish)
  )

# Read in first stage data
first_stage_data_path <- fs::path(root, "data/first-stage/01-parish-power-station-data.xlsx")
first_stage_data_raw <- readxl::read_excel(first_stage_data_path)

# Keep specified columns and drop duplicates
first_stage_data <- first_stage_data_raw %>%
  select(ref_code, parish, area, geom_id, treated, touching_treated, `touching_treated.1`, distance_to_line) %>%
  distinct()

# Prepend "birth_parish_" to each column name
colnames(first_stage_data) <- paste0("birth_parish_", colnames(first_stage_data))

# Generate ref_code_birth_parish from birth_parish_ref_code
first_stage_data <- first_stage_data %>%
  mutate(
    ref_code_birth_parish = str_replace(birth_parish_ref_code, "SE/", ""),
    # Replace missing values with 0 (ensure it's character first for substr)
    ref_code_birth_parish = ifelse(is.na(ref_code_birth_parish), "0", ref_code_birth_parish),
    # Remove the last three characters
    ref_code_birth_parish = substr(as.character(ref_code_birth_parish), 1, nchar(as.character(ref_code_birth_parish)) - 3),
    # Convert to integer
    ref_code_birth_parish = as.integer(ref_code_birth_parish)
  ) %>%
  # Replace NA from conversion with 0, if any (original code fills NA with 0 before substr)
  mutate(ref_code_birth_parish = replace_na(ref_code_birth_parish, 0))


# Sort first_stage_data by ref_code_birth_parish
first_stage_data_sorted <- first_stage_data %>%
  arrange(ref_code_birth_parish)

# Ensure unique sorted keys for the lookup if there are duplicates in first_stage_data_sorted$ref_code_birth_parish
lookup_keys_birth <- first_stage_data_sorted$ref_code_birth_parish

idx_py_equivalent_birth <- sapply(df_census_1930$ref_code_birth_parish, function(target_val) {
  if (is.na(target_val)) return(NA_integer_)

  # This is the count of elements strictly less than target_val
  sum(lookup_keys_birth < target_val, na.rm = TRUE) 
})

# Clip indices to be valid 0-based indices for `lookup_keys_birth`
# (mimicking potential `iloc` behavior with out-of-bounds `searchsorted` results)
idx_clipped_birth <- pmin(idx_py_equivalent_birth, length(lookup_keys_birth) - 1)
idx_clipped_birth <- pmax(idx_clipped_birth, 0) # Ensure it's not negative

# Convert to 1-based for R indexing and handle NAs in idx_clipped_birth
df_census_1930$closest_ref_code_birth_parish <- NA_integer_
valid_indices_birth <- !is.na(idx_clipped_birth)
df_census_1930$closest_ref_code_birth_parish[valid_indices_birth] <- lookup_keys_birth[idx_clipped_birth[valid_indices_birth] + 1]

# Merge df_census_1930 with first_stage_data
# Suffixes will be added by dplyr if there are overlapping column names not in the join key.
merged_data_birth <- df_census_1930 %>%
  left_join(first_stage_data, 
            by = c("closest_ref_code_birth_parish" = "ref_code_birth_parish"),
            suffix = c("", ".fs_birth")) # Suffix for non-join columns from first_stage_data

df_census_1930 <- merged_data_birth
cat("Completed: 1. Join with birth parish data\n")


# --- 2. Now Join to Current Parish Data ---
cat("Starting: 2. Join to Current Parish Data\n")

# Read in first stage data again (or use the previously read raw version)
first_stage_data_current_raw <- readxl::read_excel(first_stage_data_path) # Or use first_stage_data_raw

# Keep specified columns and drop duplicates
first_stage_data_current <- first_stage_data_current_raw %>%
  select(ref_code, parish, area, geom_id, treated, touching_treated, `touching_treated.1`, distance_to_line) %>%
  distinct()

# Prepend "current_parish_" to each column name
colnames(first_stage_data_current) <- paste0("current_parish_", colnames(first_stage_data_current))

# Generate ref_code_current_parish from current_parish_ref_code
first_stage_data_current <- first_stage_data_current %>%
  mutate(
    ref_code_current_parish = str_replace(current_parish_ref_code, "SE/", ""),
    ref_code_current_parish = ifelse(is.na(ref_code_current_parish), "0", ref_code_current_parish),
    ref_code_current_parish = substr(as.character(ref_code_current_parish), 1, nchar(as.character(ref_code_current_parish)) - 3),
    ref_code_current_parish = as.integer(ref_code_current_parish)
  ) %>%
  mutate(ref_code_current_parish = replace_na(ref_code_current_parish, 0))

# Sort first_stage_data_current by ref_code_current_parish
first_stage_data_current_sorted <- first_stage_data_current %>%
  arrange(ref_code_current_parish)

# --- Nearest Match Logic for Current Parish ---
lookup_keys_current <- first_stage_data_current_sorted$ref_code_current_parish

idx_py_equivalent_current <- sapply(df_census_1930$ref_code_current_parish, function(target_val) {
  if (is.na(target_val)) return(NA_integer_)
  sum(lookup_keys_current < target_val, na.rm = TRUE)
})

idx_clipped_current <- pmin(idx_py_equivalent_current, length(lookup_keys_current) - 1)
idx_clipped_current <- pmax(idx_clipped_current, 0)

df_census_1930$closest_ref_code_current_parish <- NA_integer_
valid_indices_current <- !is.na(idx_clipped_current)
df_census_1930$closest_ref_code_current_parish[valid_indices_current] <- lookup_keys_current[idx_clipped_current[valid_indices_current] + 1]

# Merge df_census_1930 with first_stage_data_current
merged_data_current <- df_census_1930 %>%
  left_join(first_stage_data_current, 
            by = c("closest_ref_code_current_parish" = "ref_code_current_parish"),
            suffix = c("", ".fs_current")) # Suffix to avoid clashes

df_census_1930 <- merged_data_current
cat("Completed: 2. Join with current parish data\n")


# --- 3. Save a Sample to Excel ---
cat("Starting: 3. Save a small sample to Excel for checking\n")
temp_excel_path <- fs::path(root, "data/temp/sample-check-20rows-merged-census.xlsx")
if (nrow(df_census_1930) >= 20) {
  df_sample_20 <- df_census_1930 %>% sample_n(20)
  writexl::write_xlsx(df_sample_20, temp_excel_path)
  cat(paste("Saved sample to:", temp_excel_path, "\n"))
} else {
  cat("Skipping 20-row sample export, not enough rows.\n")
}


# --- 4. Create Outcome and Control Variables ---
cat("Starting: 4. Create outcome and control variables\n")

# Log income and wealth
df_census_1930 <- df_census_1930 %>%
  mutate(
    log_income = log(income_incl_zero + 1), # Ensure 'income_incl_zero' column exists
    log_wealth = log(formogh + 1)          # Ensure 'formogh' column exists
  )

# Define function for direct electricity job
direct_electricity_job_r <- function(yrke_x_col) {
  sapply(yrke_x_col, function(yrke_x) {
    if (is.na(yrke_x)) return(0)
    if (str_detect(yrke_x, regex("elektr", ignore_case = TRUE)) ||
        yrke_x == "Elmontör" ||
        str_detect(yrke_x, "Linjearbetare") || # In R, this checks if the pattern is IN the string
        str_detect(yrke_x, "Kraftverksarbetare")) {
      return(1)
    } else {
      return(0)
    }
  })
}
# Use backticks if the name contains a dot and is accessed with $.
df_census_1930$electricity_job_direct <- direct_electricity_job_r(df_census_1930$`yrke.x`)


# Define list for indirect electricity job
indirect_job_list <- c(
  "Maskinist", "Pappersbruksarbetare", "Verkstadsarbetare", "Metallarbetare", "Textilarbeterska",
  "Sömmerska s. e.", "Träarbetare", "Järnverksarbetare", "Montör", "Valsverksarbetare",
  "Sömmerska s.e.", "Bryggeriarbetare", "Gjuteriarbetare", "Rörverksarbetare", "Smidesarbetare",
  "Pappersfabriksarbetare", "Maskinarbetare", "Plåtslageriarbetare", "Filare", "Skofabriksarbetare",
  "Järnbruksarbetare", "Slakteriarbetare", "Svarvare", "Glasslipare", "Tegelarbetare",
  "Snickerifabriksarbetare", "Färgeriarbetare", "Järnsvarvare", "Mejeribiträde", "Sågverksarbetare",
  "Tegelfabriksarbetare", "Mejerist", "Fabriksarbeterska", "Smedsarbetare", "Träsliperiarbetare",
  "Sågare", "Mekaniker", "Tändsticksfabriksarbetare", "Telefonarbetare", "Skoarbetare",
  "Snickeriarbetare", "Trämassearbetare", "Maskinsnickare", "Textilarbetare Vävare",
  "Smedmästare", "Textilarbetare väv.", "Spinnerska", "Möbelsnickeriarbetare", "Tillskärare",
  "Pressare", "Mekanisk verkstadsarbetare", "Tandtekniker", "Varvsarbetare", "Martinarbetare",
  "Textilfabriksarbetare", "Järnvägsverkstadsarbetare", "Valsverksarbetare vid järnbruk",
  "Fabriksarbetare", "Smed s. e.", "Sulfitfabriksarbetare", "Tändsticksfabriksarbeterska",
  "Plåtverksarbetare", "Kopparslagare", "Lådfabriksarbetare", "Gjutare", "Pappersarbetare",
  "Smedslärling", "Bilmontör", "Ingenjör", "Fabrikör", "Spolerska", "Textilfabriksarbeterska",
  "Hyttarbetare", "Smältverksarbetare", "Möbelfabriksarbetare", "Tobaksarbetare", "Tråddragare",
  "Smed", "Konfektionssömmerska", "Bageriarbetare", "Slöjdare", "Kartongarbetare", "Verkmästare",
  "Modellsnickare", "Plåtslagare", "Spinnare", "Ritare", "Motorskötare", "Appretörarbetare",
  "Chokladarbetare", "Trikåfabriksarbetare", "Cellulosafabriksarbetare", "Slaktare s.e.",
  "Bleckslagare", "Sockerbruksarbetare", "Telefonreparatör", "Garvare", "Linnesömmerska",
  "Trämassefabriksarbetare", "Martins-arbetare vid järnbruk", "Spikfabriksarbetare",
  "Spinneriarbetare", "Svetsare", "Korsettarbetare", "Yllefabriksarbetare", "Masugnsarbetare",
  "Smörjare", "Cellulosafabriksarbetare ", "Tryckeriarbetare", "Slipmassefabriksarbetare",
  "Reparatör", "Tegelbruksarbetare", "Smedarbetare", "Mekanikerarbetare", "Glasverksarbetare",
  "Textilarbetare Väverska", "Pälssömmerska", "Kalkbruksarbetare", "Bleckslageriarbetare",
  "Polerare", "Sågverksägare", "Faktor", "Stålverksarbetare", "Textilarbetare Rullerska",
  "Jutefabriksarbeterska", "Verktygsarbetare", "Rullerska", "Armaturarbetare",
  "Cementfabriksarbetare", "Hyvlare", "Litografiarbeterska", "Sågarbetare", "Fräsare",
  "Textilarbetare väveri", "Sågmästare", "Fabrikssömmerska", "Sortererska vid pappersbruk",
  "Tricotstickerska", "Laboratoriebiträde", "Textilarbetare Spinnare", "Fabriksarbetare papp.",
  "Stickerska s.e.", "Hemsömmerska", "Maskinpassare vid pappersbruk",
  "Rördrageriarbetare vid järnbruk", "Emaljarbetare", "Tvinnerska", "Sågverksförman",
  "Trikåarbetare", "Kaolinbruksarbetare", "Fanerfabriksarbetare",
  "Textilarbetare Sömmerska", "Textilarbetare Spolerska", "Maskinstickerska",
  "Fabriksarbetare cellulosafabrik", "Typograflärling", "Kappsömmerska", "Sömmerska textil",
  "Jutefabriksarbetare", "Fabriksarbetare sulfatfabrik", "Fabriksarbeterska Väverska",
  "Möbelfabrikör", "Klensmed", "Maskinförare vid pappersbruk", "Plåtslageriarbetare M. V.",
  "Tillskärerska", "Maskinskötare", "Smidesmästare", "Margarinfabriksarbetare",
  "Gummifabriksarbetare", "Maskinförare", "Skomakeriarbetare", "Avsynare", "Läderarbetare",
  "Karamellfabriksarbetare", "Plåtarbetare", "Metallduksvävare", "Tråddrageriarbetare",
  "Sömmerska Hemmadotter", "Snickeriförman", "Kappfabrikssömmerska", "Borrare", "Tryckare",
  "Snickerifabrikör", "Svarvare Arbetare", "Valsare", "Mejerinna", "Smärglare", "Smältare",
  "Brädgårdsförman", "Kakelfabriksarbetare", "Varperska", "Konservfabriksarbetare",
  "Gjutmästare", "Järnsvarvare M. V.", "Kopparslageriarbetare", "Maskinsnickeriarbetare",
  "Karamellarbetare", "Kranmaskinist ", "Maskinmästare", "Smedsdräng", "Textilarbetare",
  "Snickare vid möbelfabrik", "Torvströfabriksarbetare", "Smedmästare ag.",
  "Guldlistarbetare", "Västsömmerska", "Sågverksarbetare f.", "Underofficer Maskinist",
  "Tråddrageriarbetare vid järnbruk", "Fabrikssnickare", "Tekniskt biträde",
  "Fabriksarbetare vid Kallvalsverk", "Spårvagnskonduktör", "Smedsgesäll", "Väveriarbetare",
  "Borstbinderiarbetare", "Textilförman", "Verkstadsförman", "Bobinfabriksarbetare",
  "Cykelarbetare", "Sågställare", "Plyserska", "Linderska",
  "Plåtslagare vid mekanisk verkstad", "Väverska textilfabrik", "Sorterare",
  "Galvaniseringsarbetare", "Industriarbetare", "Tricotsömmerska", "Beredningsarbetare",
  "Väverska", "Maskinsättare", "Väverska textil", "Syfabrikssömmerska", "Lokomotivförare",
  "Radiotelegrafist", "Tunnfabriksarbetare", "Linjearbetare", "Plåtslagare s. e.", "Sågägare",
  "Sågverksmaskinist", "Maskinmjölkare", "Kranförare", "Maskinformare", "Telefonföreståndare",
  "Plåtslagare s.e.", "Barkhusarbetare Pappersbruk", "Eldare vid pappersbruk",
  "Textilarbetare varp.", "Kullagerarbetare", "Gravör", "Kärnmakare", "Väverska s. e.",
  "Sliparbetare", "Glödgare", "Lokförare järnväg", "Radiomontör", "Linslagare",
  "Diversearbetare Pappersbruk", "Sockerfabriksarbetare", "Porslinsfabriksarbetare",
  "Sömmerska Skräddare", "Tobaksarbeterska", "Stålsynare vid järnbruk", "Chokladarbeterska",
  "Facitarbetare", "Stabbläggare", "Mejerska", "Stenarbetareänka", "Tricotarbetare",
  "Silverpolererska", "Träindustriarbetare", "Maskinarbetare vid snickerifabrik",
  "Tapetfabriksarbetare", "Stenkrossarbetare", "Kartongfabriksarbetare", "Brukstjänsteman",
  "Glaspackare", "Möbelfabrikssnickare", "Fabriksarbetare Ägare",
  "Järnarbetare mekanisk verkstad", "Verkstadsarbetare Filare", "Gummireparatör",
  "Diamantborrare", "Rorgängare", "Textilarbetare kamgarnspinneri", "Bänkarbetare",
  "Cellulosafabriksarbetare Diversearbetare", "Gjutare M. V.", "Övermaskinist", "Spiksmed",
  "Gummiarbetare", "Margarinarbetare", "Klädesfabriksarbetare", "Textilarbetare Appretör",
  "Ackumulatorsfabriksarbetare", "Lastare", "Bergsingenjör", "Porslinsarbetare",
  "Spinnare textil", "Urmakare", "Rensare", "Konfektionsarbetare", "Repslageriarbetare",
  "Sömmerska Konfektion", "Vävare yllefabrik", "Sömnadsarbetare", "Borstarbetare",
  "Lagersömmerska", "Verkstadsarbetare vid järnbruk", "Träullfabriksarbetare",
  "Järnarbetare Pappersbruk", "Synerska", "Konfektionspressare", "Stålvägare vid järnbruk",
  "Sömnadsarbeterska", "Glasarbetare", "aaaa", "Spolerska textil", "Glasskärare",
  "Rullerska textil", "Mek. arbetare", "Maskinreparatör", "Gödningsfabriksarbetare",
  "Reparatör vid pappersbruk", "Vävare textilfabrik", "Plåtslageriarbetare v. mek. verkst.",
  "Tvålfabriksarbetare", "Gårdfarihandlare", "Sömmerska fabrik", "Biografmaskinist",
  "Textilarbetare Spolare", "Manglerska", "Litograf", "Sågbladsarbetare vid järnbruk",
  "Textilarbetare Tvisterska", "Byxsömmerska", "Väverska yllefabrik", "Hattfabriksarbetare",
  "Dussinsömmerska", "Kragsömmerska", "Cellulosafabriksarbetare Reparatör",
  "Lagerbiträde textil", "Litografarbetare", "Filhuggare", "Rullare vid pappersbruk",
  "Skofabriksarbeterska", "Fabriksarbetare cellulosa", "Putsare Arbetare", "Kantsågare",
  "Galvanisör", "Ingeniör", "Elektriker Montör", "Bindgarnsarbetare", "Bruksarbetare Gjutare",
  "Lackerare", "Sömmerska duss.", "Sättare", "Sömmerskearbetare", "Mejerimaskinist",
  "Varvsplåtslagare", "Stålsynare", "Hyttarbetare Järnverk", "Makaroniarbetare",
  "Magasinarbetare", "Pappersbrukfabriksarbetare", "Väskfabriksarbetare",
  "Textilarbetare Varperska", "Marmeladarbeterska", "Klädsömmerska", "Textilsömmerska",
  "Fabriksarbetare vid järnbruk", "Torkare vid pappersbruk", "Spinnerska textilfabrik",
  "Sömmerska se.", "Fabriksförman", "Utearbetare vid sulfitfabrik", "Mjölkning",
  "Tyglagerska yllefabrik", "Stickerska textil", "Typograf Sättare", "Textilarbetare Färgare",
  "Sintringsarbetare", "Påsfabriksarbetare", "Järnarbetare Kockum", "Sömmerska trikåfabrik",
  "Färgeriarbetare textil", "Konfektionsfabrikssömmerska", "Fabriksarbetare pappersbruk",
  "Sågförman", "Grovarbetare vid järnbruk", "Förtennare", "Vaddfabriksarbetare",
  "Tricotstickare", "Pressare konfektion", "Presserska", "Instrumentmakare",
  "Reparatör Pappersbruk", "Segelsömmare", "Sömmerska vid fabrik", "Fabriksarbetare Eldare",
  "Torvfabriksarbetare", "Bindgarnsarbeterska", "Styckmästare", "Civilingenjör", "Vävare textil",
  "Stenslipare", "Tillskärare konfektion", "Maskinmontör", "Textilarbetare Solverska",
  "Maskinist vid sågverk", "Motorförare", "Hjälpmontör", "Väverska Holm. br.",
  "Revolversvarvare", "Varvsförman", "Järnarbetare vid pappersbruk", "Gjuteriarbetare M. V.",
  "Spisbrödsfabriksarbetare", "Sågverksarbetare Diversearbetare", "Cementgjuteriarbetare",
  "Verkstadsägare", "Verksarbetare", "Bryggeriägare", "Martins-arbetare", "Vällare",
  "Vattenfabriksarbetare", "Glasarbetare Slipare", "Järnarbetare Filare", "Gjuterihantlangare",
  "Manufakturarbetare", "Mejslare", "Trävaruarbetare", "Typograf Tryckare",
  "Telefonstationsföreståndarinna", "Sömmerska herrkonfektion", "Maskinförman",
  "Mejerist Föreståndare", "Resårfabriksarbetare", "Dessinatör", "Kärnmakare Arbetare",
  "Smed vid stenhuggeri", "Grovarbetare Pappersbruk", "Brädgårdsarbetare Stabbläggare",
  "Maskinslipare", "Sågverksarbetare Lägenhetsägare", "Snickeriarbetare Möbel",
  "Fabriksarbetare Pappersbruk", "Förman Pappersbruk", "Tändsticksfabriksförman",
  "Verkstadsarbetare vid mekanisk verkstad", "Bleckvarufabriksarbetare", "Linnearbetare",
  "Skräddarearbetare", "Ciselör", "Textilarbetare Diversearbetare",
  "Filare mekanisk verkstad", "Mekanisk verkstadslärling", "Verkstadsarbetare Plåtslagare",
  "Järnsvarvare vid stålpressningsverk", "Sågverksarbetare Smörjare", "Telefonväxelföreståndare",
  "Filare vid stålpressningsverk", "Fabriksarbetare Slipare", "Rullare å pappersbruk",
  "Maskinsnickare vid möbelfabrik", "Textilarbetare Tvinnerska", "Knivsmed", "Fräsare Arbetare",
  "Järnarbetare Kockums", "Sömmerska Lägenhetsägare", "Filare Mekanisk verkstad",
  "Sågverksarbetare Eldare", "Textilarbetare Spinneri", "Smed Arbetare",
  "Stenarbetare vid stenindustri", "Kontorist textil", "Järnvägsverkstadsförman",
  "Typograf Maskinsättare", "Mekaniker s. e.", "Vågfabriksarbetare", "Rörläggningsarbetare",
  "Rörläggare Arbetare", "Kabelarbetare", "Knivarbetare", "Verkmästare vid pappersbruk",
  "Textilarbetare Smörjare", "Verkstadsarbetare Svarvare", "Järnarbetare vid mekanisk verkstad",
  "Sågverksarbetare Chaufför", "Textilarbetare Holm. br.", "Arbetare å Kalmar Bobin",
  "Svarvarbetare", "Virapassare Pappersbruk", "Klensmed vid järnbruk", "Hjälprullare Pappersbruk",
  "Textilarbetare bom. väv.", "Valsarbetare", "Stärkelsefabriksarbetare",
  "Martinarbetare Järnverk", "Radiofabriksarbetare", "Toffelfabriksarbetare", "Maskinuppsättare",
  "Möbelsnickarearbetare", "Svarvare vid bobinfabrik", "Riktare", "Gelbgjutare", "Metalltryckare",
  "Fabriksarbetare Grovarbetare", "Linjeförman", "Sodabrännare vid pappersbruk",
  "Sågverksarbetare Kantare", "Verkmästare vid mekanisk verkstad",
  "Sågarbetare vid chokladfabrik", "Tråddragare järnbruk", "Slipare vid pappersbruk",
  "Cellulosafabriksarbetare Eldare", "Mekaniker s.e."
)

indirect_electricity_job_r <- function(yrke_x_col) {
  sapply(yrke_x_col, function(yrke_x) {
    if (is.na(yrke_x)) return(0)
    if (yrke_x %in% indirect_job_list) {
      return(1)
    } else {
      return(0)
    }
  })
}
df_census_1930$electricity_job_indirect <- indirect_electricity_job_r(df_census_1930$`yrke.x`)

# Marital status
df_census_1930 <- df_census_1930 %>%
  mutate(
    marital_status = case_when(
      civ == 'O' ~ 'Unmarried',
      civ == 'G' ~ 'Married',
      civ == 'E' ~ 'Widow/Widower',
      civ == 'X' ~ 'Divorced',
      TRUE ~ 'Other' # Handles NA and other unexpected values
    )
  )

# Age squared
df_census_1930 <- df_census_1930 %>%
  mutate(age_2 = age^2) # Ensure 'age' column exists

# Employed status
df_census_1930 <- df_census_1930 %>%
  mutate(employed = ifelse(is.na(hisclass_group_abb), 0, 1)) # Ensure 'hisclass_group_abb' exists

# Occupational title without income
df_census_1930 <- df_census_1930 %>%
  mutate(
    occ_title_without_income = case_when(
      !is.na(hisclass_group_abb) & (!is.na(log_income) & log_income != 0) ~ 0,
      !is.na(hisclass_group_abb) & (is.na(log_income) | log_income == 0) ~ 1,
      TRUE ~ NA_real_ # Default to NA (numeric NA)
    )
  )
cat("Completed: 4. Variable creation\n")

# --- 5. Add in Union Density Data ---
cat("Starting: 5. Add in Union Density Data\n")
union_density_path <- fs::path(root, "data/union-data/02-union-density-by-parish.csv")
union_density <- readr::read_csv(union_density_path, col_types = readr::cols(.default = "c")) # Read all as char initially
# Coerce relevant columns to numeric after reading
numeric_cols_union <- colnames(union_density)[!colnames(union_density) %in% c("parish_code_short")] # Adjust if other non-numeric
union_density <- union_density %>%
    mutate(across(all_of(numeric_cols_union), as.numeric)) %>%
    mutate(parish_code_short = as.numeric(parish_code_short))


# Merge union density data with census data
df_merged_union <- df_census_1930 %>%
  left_join(union_density, by = c("ref_code_current_parish" = "parish_code_short"))

df_census_1930 <- df_merged_union
cat("Completed: 5. Union density data merged\n")


# --- 6. Export to Parquet (Intermediate) ---
cat("Starting: 6. Export intermediate full dataset to Parquet\n")
intermediate_parquet_path <- fs::path(root, "data/census/04-merged-census-data-intermediate.parquet")
arrow::write_parquet(df_census_1930, intermediate_parquet_path)
cat(paste("Saved intermediate Parquet to:", intermediate_parquet_path, "\n"))


# --- 7. Drop Unbalanced Observations ---
cat("Starting: 7. Drop unbalanced observations\n")
# Read in the intermediate parquet file
df_census_1930 <- arrow::read_parquet(intermediate_parquet_path)

control_parishes_dropped_path <- fs::path(root, "data/balance-tests/03-control-parishes-to-drop.xlsx")
control_parishes_dropped <- readxl::read_excel(control_parishes_dropped_path)

cat(paste("Rows before filtering unbalanced controls:", nrow(df_census_1930), "\n"))

# Filter out the parishes listed in control_parishes_dropped
target_filter_column <- "ref_code_current_parish" 
if ("ref_code_current_parish_x" %in% colnames(df_census_1930)) { # Check if pandas-like _x suffix exists
    target_filter_column <- "ref_code_current_parish_x"
} else if (!("ref_code_current_parish" %in% colnames(df_census_1930))) {
    warning("Neither 'ref_code_current_parish' nor 'ref_code_current_parish_x' found for filtering. Check column names.")
}


df_census_1930 <- df_census_1930 %>%
  filter(! (get(target_filter_column) %in% control_parishes_dropped$parish_code_short) )

cat(paste("Rows after filtering unbalanced controls:", nrow(df_census_1930), "\n"))

# Export the filtered dataset
filtered_parquet_path <- fs::path(root, "data/census/05-merged-census-data-filtered-unbalanced.parquet")
arrow::write_parquet(df_census_1930, filtered_parquet_path)
cat(paste("Saved filtered Parquet to:", filtered_parquet_path, "\n"))
cat("Completed: 7. Dropped unbalanced observations\n")



# --- 8. Export the Final Dataset to Stata Format ---
cat("Starting: 8. Export final dataset to Stata\n")

columns_for_stata <- c(
  "id", "log_income", "log_wealth", "employed", "occ_title_without_income",
  "electricity_job_direct", "electricity_job_indirect",
  "union_density_1890", "union_density_1900", "union_density_1910", "union_density_1930",
  "age", "age_2", "female", "marital_status", "hisclass_group_abb", "schooling_abb",
  "birth_parish_treated", "current_parish_treated",
  "birth_parish_distance_to_line", "current_parish_distance_to_line",
  "birth_parish_touching_treated", "current_parish_touching_treated", 
  "birth_parish_ref_code", "birth_parish_parish",
  "current_parish_ref_code", "current_parish_parish",
  "dist_bp_to_cp_km"
)

# Check which columns are actually available
available_columns <- intersect(columns_for_stata, colnames(df_census_1930))
missing_columns <- setdiff(columns_for_stata, colnames(df_census_1930))

if (length(missing_columns) > 0) {
  warning(paste("The following columns specified for Stata export are missing from the R dataframe:", 
                paste(missing_columns, collapse=", ")))
  warning("The Stata file will only contain available columns.")
}

if (length(available_columns) > 0) {
  df_stata_export <- df_census_1930 %>% select(all_of(available_columns))

  # Define output path for Stata file
  stata_output_dir <- fs::path(root, "data/census")
  stata_filename <- "06-final-regression-dataset-for-stata.dta"
  stata_filepath <- fs::path(stata_output_dir, stata_filename)

  # Create directory if it doesn't exist
  if (!fs::dir_exists(stata_output_dir)) {
    fs::dir_create(stata_output_dir, recurse = TRUE)
  }

  haven::write_dta(df_stata_export, stata_filepath)
  cat(paste("Exported final dataset to Stata:", stata_filepath, "\n"))
} else {
  warning("No columns available for Stata export after selection. File not written.")
}

cat("--- Script Finished ---\n")

