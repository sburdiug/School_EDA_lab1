library(readr)
library(dplyr)

# Тихе читання CSV без parsing warnings у консолі
read_csv_quiet <- function(path) {
  suppressWarnings(read_csv(path, show_col_types = FALSE))
}

# Читаємо 4 вихідні таблиці
df1 <- read_csv_quiet("data/SchoolSites21-22.csv")
df2 <- read_csv_quiet("data/SchoolSites22-23.csv")
df3 <- read_csv_quiet("data/SchoolSites23-24.csv")
df4 <- read_csv_quiet("data/SchoolSites24-25.csv")

# Для першої таблиці приводимо назву колонки до спільного формату
if ("Year" %in% names(df1)) {
  names(df1)[names(df1) == "Year"] <- "Academic Year"
}

rename_map_df4 <- c(
  "CongUSGeo" = "US Congress District",
  "SenateCAGeo" = "CA Senate District",
  "AssemblyCAGeo" = "CA Assembly District"
)

for (old_name in names(rename_map_df4)) {
  if (old_name %in% names(df4)) {
    names(df4)[names(df4) == old_name] <- rename_map_df4[[old_name]]
  }
}
# Нормалізує поле Locale: розкодовує двозначний числовий код у два стовпці
# locale_type (тип населеного пункту) та locale_size (розмір)
# Структура коду: перша цифра — тип (1=City, 2=Suburban, 3=Town, 4=Rural) друга цифра — розмір у межах типу
normalize_locale <- function(df) {
  # Видаляємо застарілі або дублюючі locale-колонки, якщо вони вже є
  df <- df %>% select(-any_of(c("locale_type", "locale_size", "Locale Four")))

  # Таблиця підстановки: перша цифра коду → тип населеного пункту
  type_labels <- c("1" = "City", "2" = "Suburban", "3" = "Town", "4" = "Rural")

  # Будує іменований вектор "код типу + код розміру" → назва розміру
  make_size_labels <- function(type_codes, size_map) {
    setNames(
      rep(unname(size_map), length(type_codes)),
      paste0(rep(type_codes, each = length(size_map)), names(size_map))
    )
  }

  # Типи 1–2 (міські) і 3–4 (сільські) мають різні назви розмірів
  size_labels <- c(
    make_size_labels(c("1", "2"), c("1" = "Large",  "2" = "Midsize", "3" = "Small")),
    make_size_labels(c("3", "4"), c("1" = "Fringe", "2" = "Distant", "3" = "Remote"))
  )

  df |>
    mutate(
      # Витягуємо лише цифри з поля Locale (прибираємо літери та пробіли)
      .code = gsub("[^0-9]", "", as.character(Locale)),
      # Перша цифра → тип
      locale_type = type_labels[substr(.code, 1, 1)],
      # Перші дві цифри → розмір
      locale_size = size_labels[substr(.code, 1, 2)]
    ) |>
    # Видаляємо вихідне поле та службову змінну
    select(-Locale, -.code)
}

df1 <- normalize_locale(df1)
df2 <- normalize_locale(df2)
df3 <- normalize_locale(df3)
df4 <- normalize_locale(df4)

# Видаляємо School Website
df4 <- df4[, names(df4) != "School Website"]

df4 <- df4 %>%
  select(-matches("^Grade (TK|KG|[0-9]+)$"))


df3 <- df3 %>%
  select(-ORIG_FID)



# Зберігаємо очищені таблиці окремо, не перезаписуючи вихідні файли
output_dir <- "data/clean"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

write_csv(df1, file.path(output_dir, "SchoolSites21-22_clean.csv"))
write_csv(df2, file.path(output_dir, "SchoolSites22-23_clean.csv"))
write_csv(df3, file.path(output_dir, "SchoolSites23-24_clean.csv"))
write_csv(df4, file.path(output_dir, "SchoolSites24-25_clean.csv"))

# Об'єднуємо всі очищені таблиці в один датафрейм.
# Приводимо до character лише ті колонки, де типи між роками конфліктують.
yearly_dfs <- list(
  "2021-22" = df1,
  "2022-23" = df2,
  "2023-24" = df3,
  "2024-25" = df4
)

get_primary_class <- function(col) class(col)[1]

all_cols <- sort(unique(unlist(lapply(yearly_dfs, names), use.names = FALSE)))

conflicting_cols <- all_cols[vapply(all_cols, function(col_name) {
  present_classes <- unique(unlist(lapply(yearly_dfs, function(df) {
    if (col_name %in% names(df)) get_primary_class(df[[col_name]]) else NULL
  }), use.names = FALSE))
  length(present_classes) > 1
}, logical(1))]

if (length(conflicting_cols) > 0) {
  yearly_dfs <- lapply(yearly_dfs, function(df) {
    cols_to_cast <- intersect(conflicting_cols, names(df))
    df %>% mutate(across(all_of(cols_to_cast), as.character))
  })
}

united_df <- bind_rows(yearly_dfs)

united_df <- united_df %>% select(-any_of("OBJECTID"))

united_df <- united_df %>%
  select(-any_of(c("x", "y"))) %>%
  select(-matches("Geo$", ignore.case = TRUE))

# У таблиці приводимо Y/N-колонки до логічного типу TRUE/FALSE, порожні комірки -> NA
normalize_yn_columns <- function(df, target_columns) {
  for (target_col in target_columns) {
    matched_col <- names(df)[tolower(names(df)) == tolower(target_col)]
    if (length(matched_col) != 1) {
      next
    }
    current_vals <- trimws(as.character(df[[matched_col]]))
    df[[matched_col]] <- case_when(
      is.na(current_vals) ~ NA,
      current_vals == "Y" ~ TRUE,
      current_vals == "N" ~ FALSE,
      TRUE ~ NA
    )
  }

  df
}

# Додавайте сюди будь-які потрібні колонки з Y/N
yn_to_bool_columns <- c("Magnet", "Title I", "DASS", "Charter" )
united_df <- normalize_yn_columns(united_df, yn_to_bool_columns)


united_df <- united_df |>
  mutate(
    Virtual = case_when(
      Virtual == "N" ~ "Not virtual",
      Virtual == "C" ~ "Primarily classroom",
      Virtual == "V" ~ "Primarily virtual",
      Virtual == "F" ~ "Fully virtual",
      TRUE ~ NA_character_
    )
  ) |>
  select(-any_of("Closed Date"))

united_df <- united_df |> select(-`Charter Num`)

percent_out_of_range_summary <- united_df |>
  select(ends_with("(%)")) |>
  summarise(across(everything(), ~sum(. < 0 | . > 100, na.rm = TRUE)))

united_df <- united_df |>
  mutate(
    grade_low_num = case_when(
      `Grade Low` == "PK" ~ -2,
      `Grade Low` == "KG" ~ -1,
      `Grade Low` %in% sprintf("%02d", 1:12) ~ as.numeric(`Grade Low`),
      TRUE ~ NA_real_
    ),
    grade_high_num = case_when(
      `Grade High` == "PK" ~ -2,
      `Grade High` == "KG" ~ -1,
      `Grade High` %in% c("OK", "0K") ~ 0,
      `Grade High` %in% sprintf("%02d", 1:12) ~ as.numeric(`Grade High`),
      TRUE ~ NA_real_
    )
  )

grade_order_issues <- united_df |>
  filter(grade_high_num < grade_low_num) |>
  select(`School Level`, `Grade Low`, `Grade High`, grade_low_num, grade_high_num)

message("Кількість записів з Grade High < Grade Low: ", nrow(grade_order_issues))
if (nrow(grade_order_issues) > 0) {
  print(grade_order_issues, n = nrow(grade_order_issues))
}

write_csv(grade_order_issues, file.path(output_dir, "grade_order_issues.csv"))



write_csv(united_df, file.path(output_dir, "SchoolSites_all_clean.csv"))
