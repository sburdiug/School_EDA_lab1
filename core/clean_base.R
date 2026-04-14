library(readr)
library(dplyr)

# Тихое чтение CSV без parsing warnings в консоли
read_csv_quiet <- function(path) {
  suppressWarnings(read_csv(path, show_col_types = FALSE))
}

# Читаем 4 исходных таблицы
df1 <- read_csv_quiet("data/SchoolSites21-22.csv")
df2 <- read_csv_quiet("data/SchoolSites22-23.csv")
df3 <- read_csv_quiet("data/SchoolSites23-24.csv")
df4 <- read_csv_quiet("data/SchoolSites24-25.csv")

# Для первой таблицы приводим имя колонки к общему формату
if ("Year" %in% names(df1)) {
  names(df1)[names(df1) == "Year"] <- "Academic Year"
}

# Для четвертой таблицы приводим гео-колонки к формату первых трех таблиц
rename_map_df4 <- c(
  "CongUSGeo" = "US Congress District",
  "SenateCAGeo" = "CA Senate District",
  "AssemblyCAGeo" = "CA Assembly District",
  "CountyCodeGeo" = "County Code Geo",
  "CountyNameGeo" = "County Name Geo",
  "DistrictElemCodeGeo" = "District Elem Code Geo",
  "DistrictElemNameGeo" = "District Elem Name Geo",
  "DistrictHighCodeGeo" = "District High Code Geo",
  "DistrictHighNameGeo" = "District High Name Geo",
  "DistrictUnifiedCodeGeo" = "District Unified Code Geo",
  "DistrictUnifiedNameGeo" = "District Unified Name Geo"
)

for (old_name in names(rename_map_df4)) {
  if (old_name %in% names(df4)) {
    names(df4)[names(df4) == old_name] <- rename_map_df4[[old_name]]
  }
}

# Проста обробка locale-полів у всіх таблицях
normalize_locale <- function(df) {
  df <- df %>% select(-any_of(c("locale_type", "locale_size", "Locale Four")))

  if (!"Locale" %in% names(df)) {
    return(df)
  }

  df %>%
    mutate(
      locale_type = case_when(
        substr(Locale, 1, 1) == "1" ~ "City",
        substr(Locale, 1, 1) == "2" ~ "Suburban",
        substr(Locale, 1, 1) == "3" ~ "Town",
        substr(Locale, 1, 1) == "4" ~ "Rural",
        TRUE ~ NA_character_
      ),
      locale_size = case_when(
        substr(Locale, 2, 2) == "1" ~ "Large",
        substr(Locale, 2, 2) == "2" ~ "Mid",
        substr(Locale, 2, 2) == "3" ~ "Small",
        TRUE ~ NA_character_
      ),
      locale_type = factor(locale_type),
      locale_size = factor(locale_size)
    ) %>%
    select(-Locale)
}

df1 <- normalize_locale(df1)
df2 <- normalize_locale(df2)
df3 <- normalize_locale(df3)
df4 <- normalize_locale(df4)

# Удаляем колонку School Website
df4 <- df4[, names(df4) != "School Website"]

df4 <- df4 %>%
  select(-matches("^Grade (TK|KG|[0-9]+)$"))


df3 <- df3 %>%
  select(-ORIG_FID)



# Сохраняем очищенные таблицы отдельно, не перезаписывая исходные файлы
output_dir <- "data/clean"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

write_csv(df1, file.path(output_dir, "SchoolSites21-22_clean.csv"))
write_csv(df2, file.path(output_dir, "SchoolSites22-23_clean.csv"))
write_csv(df3, file.path(output_dir, "SchoolSites23-24_clean.csv"))
write_csv(df4, file.path(output_dir, "SchoolSites24-25_clean.csv"))
