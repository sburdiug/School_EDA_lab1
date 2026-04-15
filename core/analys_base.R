library(readr)
library(dplyr)

# Спочатку формуємо/оновлюємо очищені CSV
source("core/EDA.R")

# В аналізі беремо саме очищені файли з data/clean
dataset_files <- c(
  "y21_22" = "data/clean/SchoolSites21-22_clean.csv",
  "y22_23" = "data/clean/SchoolSites22-23_clean.csv",
  "y23_24" = "data/clean/SchoolSites23-24_clean.csv",
  "y24_25" = "data/clean/SchoolSites24-25_clean.csv"
)

# Читаємо лише заголовки, щоб порівняти назви колонок
dataset_columns <- lapply(dataset_files, function(file_path) {
  names(readr::read_csv(file_path, n_max = 0, show_col_types = FALSE))
})

# Єдиний список усіх унікальних стовпців
all_columns <- sort(unique(unlist(dataset_columns, use.names = FALSE)))

# Таблиця порівняння: рядки = стовпці, колонки = датасети (1/0)
comparison <- data.frame(column_name = all_columns, stringsAsFactors = FALSE)

for (dataset_name in names(dataset_columns)) {
  current_cols <- dataset_columns[[dataset_name]]
  comparison[[dataset_name]] <- ifelse(all_columns %in% current_cols, 1L, 0L)
}

# Зведені ознаки для кожного стовпця
in_cols <- names(dataset_columns)
comparison$datasets_with_column <- rowSums(comparison[in_cols])
comparison$present_in_all_4 <- comparison$datasets_with_column == length(dataset_columns)
comparison$pattern <- apply(comparison[in_cols], 1, paste0, collapse = "")

# Сортуємо: спочатку рідкі стовпці, потім за абеткою
comparison <- comparison[order(comparison$datasets_with_column, comparison$column_name), ]

# Компактний вивід у консоль
comparison_print <- comparison[c("column_name", "pattern", "datasets_with_column", "present_in_all_4")]
print(comparison_print, row.names = FALSE)

# Таблиця типів даних за колонками df4 (y24_25)
df4_data <- readr::read_csv(dataset_files[["y24_25"]], show_col_types = FALSE)
df4_types <- data.frame(
  column_name = names(df4_data),
  data_type = vapply(df4_data, function(col) class(col)[1], character(1)),
  stringsAsFactors = FALSE
)

print(df4_types, row.names = FALSE)
write_csv(df4_types, "data/df4_column_types.csv")

# Порівняння типів даних між df4 і united_df
if (!exists("united_df")) {
  united_df <- readr::read_csv("data/clean/clean_data.csv", show_col_types = FALSE)
}

united_types <- data.frame(
  column_name = names(united_df),
  united_df_type = vapply(united_df, function(col) class(col)[1], character(1)),
  stringsAsFactors = FALSE
)

if (file.exists("data/clean/clean_data.rds")) {
  eda_df <- readRDS("data/clean/clean_data.rds")
} else if (exists("eda_df")) {
  eda_df <- eda_df
} else {
  eda_df <- readr::read_csv("data/clean/clean_data.csv", show_col_types = FALSE)
}

eda_types <- data.frame(
  column_name = names(eda_df),
  eda_df_type = vapply(eda_df, function(col) class(col)[1], character(1)),
  stringsAsFactors = FALSE
)

df4_vs_united_types <- full_join(
  df4_types %>% rename(df4_type = data_type),
  united_types,
  by = "column_name"
) %>%
  full_join(eda_types, by = "column_name") %>%
  mutate(
    in_df4 = !is.na(df4_type),
    in_united_df = !is.na(united_df_type),
    in_eda_df = !is.na(eda_df_type),
    same_type_df4_united = ifelse(in_df4 & in_united_df, df4_type == united_df_type, NA),
    same_type_united_eda = ifelse(in_united_df & in_eda_df, united_df_type == eda_df_type, NA),
    same_type_df4_eda = ifelse(in_df4 & in_eda_df, df4_type == eda_df_type, NA)
  ) %>%
  arrange(desc(in_df4 & in_united_df), column_name) %>%
  select(
    column_name,
    df4_type, united_df_type, eda_df_type,
    in_df4, in_united_df, in_eda_df,
    same_type_df4_united, same_type_united_eda, same_type_df4_eda
  )


