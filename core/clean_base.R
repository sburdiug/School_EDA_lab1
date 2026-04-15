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

# Нормалізує поле Locale: розкодовує двозначний числовий код у два факторних
# стовпці — locale_type (тип населеного пункту) та locale_size (розмір)
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

  df %>%
    mutate(
      # Витягуємо лише цифри з поля Locale (прибираємо літери та пробіли)
      .code = gsub("[^0-9]", "", as.character(Locale)),
      # Перша цифра → тип; упорядкований фактор від міського до сільського
      locale_type = factor(
        type_labels[substr(.code, 1, 1)],
        levels = c("City", "Suburban", "Town", "Rural")
      ),
      # Перші дві цифри → розмір; рівні впорядковані від найбільшого до найменшого
      locale_size = factor(
        size_labels[substr(.code, 1, 2)],
        levels = c("Large", "Midsize", "Small", "Fringe", "Distant", "Remote")
      )
    ) %>%
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



# Сохраняем очищенные таблицы отдельно, не перезаписывая исходные файлы
output_dir <- "data/clean"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

write_csv(df1, file.path(output_dir, "SchoolSites21-22_clean.csv"))
write_csv(df2, file.path(output_dir, "SchoolSites22-23_clean.csv"))
write_csv(df3, file.path(output_dir, "SchoolSites23-24_clean.csv"))
write_csv(df4, file.path(output_dir, "SchoolSites24-25_clean.csv"))

# Об'єднуємо всі очищені таблиці в один датафрейм і зберігаємо
to_character_df <- function(df) {
  df %>% mutate(across(everything(), as.character))
}

united_df <- bind_rows(
  "2021-22" = to_character_df(df1),
  "2022-23" = to_character_df(df2),
  "2023-24" = to_character_df(df3),
  "2024-25" = to_character_df(df4)
)

united_df <- united_df %>% select(-any_of("OBJECTID"))

write_csv(united_df, file.path(output_dir, "SchoolSites_all_clean.csv"))
