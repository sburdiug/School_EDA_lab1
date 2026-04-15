library(readr)
library(dplyr)

# Працюємо з уже очищеним датафреймом:
# 1) спочатку пробуємо CSV, 2) якщо його немає — RDS
clean_csv_path <- "data/clean/SchoolSites_all_clean.csv"
clean_rds_path <- "data/clean/SchoolSites_all_clean.rds"

if (file.exists(clean_csv_path)) {
  united_df <- readr::read_csv(clean_csv_path, show_col_types = FALSE)
} else if (file.exists(clean_rds_path)) {
  united_df <- readRDS(clean_rds_path)
} else {
  stop("Не знайдено очищені дані: очікується data/clean/SchoolSites_all_clean.csv або data/clean/SchoolSites_all_clean.rds")
}

parse_school_date <- function(x) {
  as.Date(as.POSIXct(x, format = "%m/%d/%Y %I:%M:%S %p", tz = "UTC"))
}

academic_year_levels <- unique(as.character(united_df[["Academic Year"]]))
academic_year_levels <- academic_year_levels[!is.na(academic_year_levels)]
academic_year_levels <- academic_year_levels[order(as.integer(substr(academic_year_levels, 1, 4)))]

school_level_levels <- sort(unique(as.character(united_df[["School Level"]])))
school_level_levels <- school_level_levels[!is.na(school_level_levels)]

school_type_levels <- sort(unique(as.character(united_df[["School Type"]])))
school_type_levels <- school_type_levels[!is.na(school_type_levels)]

status_levels <- sort(unique(as.character(united_df[["Status"]])))
status_levels <- status_levels[!is.na(status_levels)]

assistance_status_essa_levels <- sort(unique(as.character(united_df[["Assistance Status ESSA"]])))
assistance_status_essa_levels <- assistance_status_essa_levels[!is.na(assistance_status_essa_levels)]

eda_df <- united_df |>
  mutate(
    `Academic Year` = factor(
      `Academic Year`,
      levels = academic_year_levels,
      ordered = TRUE
    ),
    `School Level` = factor(
      `School Level`,
      levels = school_level_levels
    ),
    `School Type` = factor(
      `School Type`,
      levels = school_type_levels,
      ordered = TRUE
    ),
    Status = factor(
      Status,
      levels = status_levels
    ),
    `Assistance Status ESSA` = factor(
      `Assistance Status ESSA`,
      levels = assistance_status_essa_levels
    ),
    locale_type = factor(
      locale_type,
      levels = c("City", "Suburban", "Town", "Rural")
    ),
    locale_size = factor(
      locale_size,
      levels = c("Large", "Midsize", "Small", "Fringe", "Distant", "Remote")
    ),
    Virtual = factor(
      Virtual,
      levels = c(
        "Not virtual",
        "Primarily classroom",
        "Primarily virtual",
        "Fully virtual"
      )
    ),
    `Open Date` = parse_school_date(`Open Date`)
  )

write_csv(eda_df, "data/clean/clean_data.csv")
saveRDS(eda_df, "data/clean/clean_data.rds")
