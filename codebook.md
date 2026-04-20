
Нижче наведено опис змінних очищеного та підготовленого до аналізу датасету. Типи даних вказані з урахуванням очищення в `clean_base.R` та подальшої підготовки до аналізу в `EDA.R`.

| Змінна                                | Тип даних           | Опис                                                                                             |
|---------------------------------------|---------------------|--------------------------------------------------------------------------------------------------|
| `Academic Year`                       | ordered factor      | Навчальний рік, до якого належить запис про школу.                                               |
| `Fed ID`                              | character           | Федеральний ідентифікатор школи.                                                                 |
| `CDS Code`                            | character           | Унікальний код школи в системі California Department of Education.                               |
| `District Code`                       | character           | Код шкільного округу.                                                                            |
| `School Code`                         | character           | Внутрішній код школи.                                                                            |
| `Region`                              | character           | Регіон розташування школи.                                                                       |
| `County Name`                         | character           | Назва округу (county), у якому розташована школа.                                                |
| `District Name`                       | character           | Назва шкільного округу.                                                                          |
| `School Name`                         | character           | Назва школи.                                                                                     |
| `School Type`                         | factor              | Тип школи                                                                                        |
| `Status`                              | factor              | Статус школи, наприклад активна або закрита.                                                     |
| `Open Date`                           | Date                | Дата відкриття школи.                                                                            |
| `School Level`                        | factor              | Освітній рівень школи.                                                                           |
| `Grade Low`                           | character           | Найнижчий клас, який охоплює школа, у початковому текстовому форматі.                            |
| `Grade High`                          | character           | Найвищий клас, який охоплює школа, у початковому текстовому форматі.                             |
| `Charter`                             | logical             | Ознака того, чи є школа чартерною (`TRUE` / `FALSE`).                                            |
| `Virtual`                             | factor              | Формат навчання: невіртуальний, переважно очний, переважно віртуальний або повністю віртуальний. |
| `Magnet`                              | logical             | Ознака того, чи належить школа до типу magnet school.                                            |
| `Title I`                             | logical             | Ознака участі школи в програмі Title I.                                                          |
| `DASS`                                | logical             | Ознака належності школи до категорії DASS.                                                       |
| `Assistance Status ESSA`              | factor              | Статус підтримки або класифікації школи за ESSA.                                                 |
| `Street`                              | character           | Вулиця та номер будівлі в адресі школи.                                                          |
| `City`                                | character           | Місто, у якому розташована школа.                                                                |
| `Zip`                                 | character           | Поштовий індекс.                                                                                 |
| `State`                               | character           | Штат.                                                                                            |
| `US Congress District`                | character / numeric | Номер або код виборчого округу до Палати представників США.                                      |
| `CA Senate District`                  | character / numeric | Номер або код сенатського округу штату Каліфорнія.                                               |
| `CA Assembly District`                | character / numeric | Номер або код округу асамблеї штату Каліфорнія.                                                  |
| `Latitude`                            | numeric             | Географічна широта школи.                                                                        |
| `Longitude`                           | numeric             | Географічна довгота школи.                                                                       |
| `Enroll Total`                        | numeric             | Загальна кількість учнів у школі.                                                                |
| `African American`                    | numeric             | Кількість учнів категорії African American.                                                      |
| `African American (%)`                | numeric             | Частка учнів категорії African American у відсотках.                                             |
| `American Indian`                     | numeric             | Кількість учнів категорії American Indian.                                                       |
| `American Indian Pct`                 | numeric             | Частка учнів категорії American Indian у відсотках.                                              |
| `Asian`                               | numeric             | Кількість учнів категорії Asian.                                                                 |
| `Asian (%)`                           | numeric             | Частка учнів категорії Asian у відсотках.                                                        |
| `Filipino`                            | numeric             | Кількість учнів категорії Filipino.                                                              |
| `Filipino (%)`                        | numeric             | Частка учнів категорії Filipino у відсотках.                                                     |
| `Hispanic`                            | numeric             | Кількість учнів категорії Hispanic.                                                              |
| `Hispanic (%)`                        | numeric             | Частка учнів категорії Hispanic у відсотках.                                                     |
| `Pacific Islander`                    | numeric             | Кількість учнів категорії Pacific Islander.                                                      |
| `Pacific Islander (%)`                | numeric             | Частка учнів категорії Pacific Islander у відсотках.                                             |
| `White`                               | numeric             | Кількість учнів категорії White.                                                                 |
| `White (%)`                           | numeric             | Частка учнів категорії White у відсотках.                                                        |
| `Two or More Races`                   | numeric             | Кількість учнів, віднесених до категорії двох або більше рас.                                    |
| `Two or More Races (%)`               | numeric             | Частка учнів категорії двох або більше рас у відсотках.                                          |
| `Not Reported`                        | numeric             | Кількість учнів, для яких расову категорію не вказано.                                           |
| `Not Reported (%)`                    | numeric             | Частка учнів без вказаної расової категорії у відсотках.                                         |
| `English Learner`                     | numeric             | Кількість учнів, які вивчають англійську як не рідну.                                            |
| `English Learner (%)`                 | numeric             | Частка учнів English Learner у відсотках.                                                        |
| `Foster`                              | numeric             | Кількість учнів, які перебувають у системі foster care.                                          |
| `Foster (%)`                          | numeric             | Частка таких учнів у відсотках.                                                                  |
| `Homeless`                            | numeric             | Кількість бездомних учнів.                                                                       |
| `Homeless (%)`                        | numeric             | Частка бездомних учнів у відсотках.                                                              |
| `Migrant`                             | numeric             | Кількість учнів-мігрантів.                                                                       |
| `Migrant (%)`                         | numeric             | Частка учнів-мігрантів у відсотках.                                                              |
| `Socioeconomically Disadvantaged`     | numeric             | Кількість соціально вразливих учнів.                                                             |
| `Socioeconomically Disadvantaged (%)` | numeric             | Частка соціально вразливих учнів у відсотках.                                                    |
| `Students with Disabilities`          | numeric             | Кількість учнів з інвалідністю.                                                                  |
| `Students with Disabilities (%)`      | numeric             | Частка учнів з інвалідністю у відсотках.                                                         |
| `Free/Reduced Meal Eligible`          | numeric             | Кількість учнів, які мають право на безкоштовне або пільгове харчування.                         |
| `Free/Reduced Meal Eligible (%)`      | numeric             | Частка учнів, які мають право на безкоштовне або пільгове харчування, у відсотках.               |
| `locale_type`                         | factor              | Тип території за змінною `Locale`: `City`, `Suburban`, `Town`, `Rural`.                          |
| `locale_size`                         | factor              | Уточнення типу території: `Large`, `Midsize`, `Small`, `Fringe`, `Distant`, `Remote`.            |
| `grade_low_num`                       | numeric             | Числове представлення змінної `Grade Low`, створене для зручності аналізу.                       |
| `grade_high_num`                      | numeric             | Числове представлення змінної `Grade High`, створене для зручності аналізу.                      |
