library(dplyr)



source("core/EDA.R")

if (!exists("united_df")) {
  stop("Об'єкт united_df не знайдено після source('core/EDA.R').")
}

if (!exists("eda_df")) {
  stop("Об'єкт eda_df не знайдено після source('core/EDA.R').")
}

df <- eda_df

pick_col <- function(data, candidates) {
  nm <- names(data)
  low <- tolower(nm)
  for (cand in candidates) {
    idx <- which(low == tolower(cand))
    if (length(idx) == 1) {
      return(nm[idx])
    }
  }
  NULL
}

grade_order_issues <- df |>
  filter(grade_high_num < grade_low_num) |>
  select(`School Level`, `Grade Low`, `Grade High`, grade_low_num, grade_high_num)

message("Кількість записів з Grade High < Grade Low: ", nrow(grade_order_issues))
if (nrow(grade_order_issues) > 0) {
  print(grade_order_issues, n = nrow(grade_order_issues))
}


message("=== 0) Загальний summary(df) ===")
print(summary(df))

message("=== 1) Дублікати шкіл (School Name + City + Address/Street) ===")
address_col <- pick_col(united_df, c("Address", "Street"))
if (is.null(address_col)) {
  message("Колонка Address/Street не знайдена, пропускаю перевірку дублікатів за адресою.")
} else {
  duplicates_school <- united_df |>
    count(`School Name`, City, .data[[address_col]]) |>
    filter(n > 4)
  print(duplicates_school, n = nrow(duplicates_school))
}

message("=== 2) Пропуски по колонках ===")
na_counts <- colSums(is.na(united_df))
print(sort(na_counts, decreasing = TRUE))

na_share <- tibble::tibble(
  column_name = names(na_counts),
  na_count = as.integer(na_counts),
  na_share = as.numeric(na_counts) / nrow(united_df)
) |>
  arrange(desc(na_share))

message("Найбрудніші колонки (top 10 за часткою NA):")
print(head(na_share, 10), n = 10)

message("=== 3) Перевірка відсоткових колонок ===")
print(summary(united_df |> select(ends_with("(%)"))))

percent_summary <- united_df |>
  select(ends_with("(%)")) |>
  summarise(across(everything(), list(
    min = ~min(., na.rm = TRUE),
    max = ~max(., na.rm = TRUE),
    mean = ~mean(., na.rm = TRUE)
  )))
print(percent_summary, width = Inf)

percent_out_of_range <- united_df |>
  select(ends_with("(%)")) |>
  summarise(across(everything(), ~sum(. < 0 | . > 100, na.rm = TRUE))) |>
  tidyr::pivot_longer(everything(), names_to = "column_name", values_to = "out_of_range_count") |>
  filter(out_of_range_count > 0) |>
  arrange(desc(out_of_range_count))

message("Колонки з відсотками поза [0, 100]: ", nrow(percent_out_of_range))
if (nrow(percent_out_of_range) > 0) {
  print(percent_out_of_range, n = nrow(percent_out_of_range))
}

message("=== 4) Зв'язок School Level x locale_type ===")
school_level_locale <- table(united_df$`School Level`, united_df$locale_type, useNA = "ifany")
print(school_level_locale)

if ("Elementary" %in% rownames(school_level_locale)) {
  elem_city <- if ("City" %in% colnames(school_level_locale)) school_level_locale["Elementary", "City"] else NA
  elem_rural <- if ("Rural" %in% colnames(school_level_locale)) school_level_locale["Elementary", "Rural"] else NA
  message("Elementary: City = ", elem_city, ", Rural = ", elem_rural)
}

message("=== 5) Charter x School Type ===")
charter_school_type <- table(united_df$Charter, united_df$`School Type`, useNA = "ifany")
print(charter_school_type)

message("=== 6) Динаміка по роках (середній Enroll Total) ===")
avg_students_by_year <- united_df |>
  group_by(`Academic Year`) |>
  summarise(avg_students = mean(`Enroll Total`, na.rm = TRUE), .groups = "drop")
print(avg_students_by_year, n = nrow(avg_students_by_year))

message("=== 7) Географія: кількість шкіл за locale_type ===")
schools_by_locale <- united_df |>
  group_by(locale_type) |>
  summarise(count = n(), .groups = "drop") |>
  arrange(desc(count))
print(schools_by_locale, n = nrow(schools_by_locale))

message("=== 8) Логічна перевірка: High з grade_low_num < 6 ===")
unrealistic_high <- united_df |>
  filter(`School Level` == "High", grade_low_num < 6) |>
  select(`School Name`, City, `School Level`, `Grade Low`, `Grade High`, grade_low_num, grade_high_num)

message("Кількість підозрілих High-шкіл: ", nrow(unrealistic_high))
if (nrow(unrealistic_high) > 0) {
  print(unrealistic_high, n = nrow(unrealistic_high))
}

message("=== 9) Баланс класів School Level ===")
school_level_balance <- table(united_df$`School Level`, useNA = "ifany")
print(school_level_balance)
