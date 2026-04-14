library(readr)
library(dplyr)

# Спочатку формуємо/оновлюємо очищені CSV
source("core/clean_base.R")

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

# Порівняння однієї школи між роками за кодом School Code
target_school_code <- "0130401"
target_digits <- gsub("[^0-9]", "", target_school_code)
target_digits_no_leading_zero <- sub("^0+", "", target_digits)

find_school_by_code <- function(df, code_digits, code_digits_no_zero) {
  school_code_digits <- gsub("[^0-9]", "", as.character(df[["School Code"]]))
  cds_code_digits <- gsub("[^0-9]", "", as.character(df[["CDS Code"]]))

  school_match <- school_code_digits == code_digits | school_code_digits == code_digits_no_zero
  cds_match <- grepl(paste0(code_digits, "$"), cds_code_digits)

  df[school_match | cds_match, , drop = FALSE]
}

school_rows <- list(
  "2021-22" = find_school_by_code(df1, target_digits, target_digits_no_leading_zero),
  "2022-23" = find_school_by_code(df2, target_digits, target_digits_no_leading_zero),
  "2023-24" = find_school_by_code(df3, target_digits, target_digits_no_leading_zero),
  "2024-25" = find_school_by_code(df4, target_digits, target_digits_no_leading_zero)
)

all_school_columns <- sort(unique(unlist(lapply(list(df1, df2, df3, df4), names), use.names = FALSE)))

school_comparison <- bind_rows(lapply(names(school_rows), function(year_label) {
  year_df <- school_rows[[year_label]]

  # Створюємо рядок з усіма колонками; відсутні значення залишаються NA
  row_values <- as.list(rep(NA_character_, length(all_school_columns)))
  names(row_values) <- all_school_columns
  found_flag <- 0L

  if (nrow(year_df) > 0) {
    first_row <- as.data.frame(year_df[1, , drop = FALSE], stringsAsFactors = FALSE)
    existing_fields <- intersect(names(first_row), all_school_columns)
    # Для надійного bind_rows приводимо значення до character
    row_values[existing_fields] <- lapply(first_row[1, existing_fields, drop = FALSE], as.character)
    found_flag <- 1L
  }

  output_row <- c(list(dataset_year = year_label, found = found_flag), row_values)
  as.data.frame(output_row, stringsAsFactors = FALSE, check.names = FALSE)
}))

print(school_comparison[, c("dataset_year", "found")], row.names = FALSE)
write_csv(school_comparison, file.path("data/clean", "school_0112607_comparison.csv"))
