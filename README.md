# Lab 1

Проєкт для очищення, об’єднання та базового EDA даних шкіл за 2021–2025 роки.

## Структура

- `core/clean_base.R` — очищення вихідних CSV, об’єднання в `united_df`, базові перевірки якості.
- `core/EDA.R` — факторизація та підготовка `eda_df`.
- `core/analys_base.R` — порівняння колонок і типів між наборами даних.
- `core/test.R` — розширений EDA-чеклист і виведення результатів у консоль.
- `data/` — вихідні CSV.
- `data/clean/` — очищені та похідні файли.

## Вимоги

- R 4.5+ (або сумісна версія).
- Пакети: `readr`, `dplyr`, `tidyr`.

Встановлення пакетів (один раз):

```r
install.packages(c("readr", "dplyr", "tidyr"))
```

## Як запускати

З кореня проєкту:

```r
source("core/clean_base.R")   # очищення та united_df
source("core/EDA.R")          # факторизація та eda_df
source("core/analys_base.R")  # порівняння структури/типів
source("core/test.R")         # EDA-перевірки та зведення
```

Або з термінала:

```bash
Rscript core/clean_base.R
Rscript core/EDA.R
Rscript core/analys_base.R
Rscript core/test.R
```

## Основні вихідні файли

- `data/clean/SchoolSites21-22_clean.csv`
- `data/clean/SchoolSites22-23_clean.csv`
- `data/clean/SchoolSites23-24_clean.csv`
- `data/clean/SchoolSites24-25_clean.csv`
- `data/clean/SchoolSites_all_clean.csv`
- `data/clean/SchoolSites_all_EDA.csv`
- `data/clean/SchoolSites_all_EDA.rds`

## Що перевіряє `core/test.R`

- дублікати шкіл (`School Name + City + Address/Street`);
- пропуски по колонках і топ «брудних» полів;
- поведінку відсоткових колонок (`(%)`) і значення поза діапазоном `[0, 100]`;
- зв’язки ознак (`School Level x locale_type`, `Charter x School Type`);
- динаміку за роками (`Academic Year` і середній `Enroll Total`);
- розподіл шкіл за `locale_type`;
- логічні перевірки за рівнями класів;
- баланс класів `School Level`.
