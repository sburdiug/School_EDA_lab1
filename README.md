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

## Що було зроблено в ході роботи

- уніфіковано структуру даних за 4 навчальні роки (2021–22, 2022–23, 2023–24, 2024–25);
- нормалізовано службові та категоріальні поля (зокрема `Locale`, Y/N-ознаки, `Virtual`);
- зібрано єдиний очищений набір `united_df` та підготовлено факторизований `eda_df`;
- додано перевірки якості даних: пропуски, дублікати, відсотки поза діапазоном `[0, 100]`;
- реалізовано логічні перевірки для класів (`Grade Low`, `Grade High`) і виявлення аномалій;
- підготовлено аналітичні зведення за роками, типами шкіл і географією (`locale_type`);

## EDA: детальніше про факторизацію

У `core/EDA.R` формується `eda_df`, де ключові категоріальні поля переводяться у `factor`.

Факторизовані колонки:

- `Academic Year` — впорядкований фактор за навчальними роками;
- `School Level` — категорії рівня школи;
- `School Type` — впорядкований фактор типів шкіл;
- `Status` — статус школи;
- `Assistance Status ESSA` — статуси ESSA;
- `locale_type` — `City`, `Suburban`, `Town`, `Rural`;
- `locale_size` — `Large`, `Midsize`, `Small`, `Fringe`, `Distant`, `Remote`;
- `Virtual` — `Not virtual`, `Primarily classroom`, `Primarily virtual`, `Fully virtual`.

Для чого це потрібно:

- правильний порядок категорій у таблицях і графіках;
- стабільні групування для `count`, `table`, `group_by`;
- менше помилок через неоднорідні текстові значення;
- коректна підготовка ознак для подальшого аналізу/моделей.

Важливо: при збереженні в `RDS` (`SchoolSites_all_EDA.rds`) фактори, їхні рівні та порядок зберігаються без втрат.
