# Домашнее задание по теме "Работа с базами данных"

> **Преподаватель:** Алексей Кузьмин, Николай Хащанов, Екатерина Волочаева, Александр Сумовский

> Все работы мы проверяем на антиплагиат, поэтому важно выполнять их самостоятельно. Работам, которые не пройдут проверку, преподаватель поставит незачёт.

> Если вы сталкиваетесь со сложностями, задавайте вопросы нашим экспертам и аспирантам, они с удовольствием вам помогут. Успехов в решении заданий!

## **Модуль 2. Домашнее задание по теме «Работа с базами данных»**
> **Результат домашнего задания** :
[Ответ в формате "Шаблон для сдачи ДЗ в формате sql"](m2-utf8.sql)


**Цели домашнего задания:**

-   научиться явно указывать колонки в SELECT и задавать названия колонкам;
-   закрепить навыки фильтрации и сортировки строк в таблицах с использованием основных операторов языка SQL;
-   научиться выполнять преобразования текстовых, числовых значений и дат с помощью функций языка SQL по работе со строками, датами и числами.

### **Основная часть:**  

**Задание 1. Выведите уникальные названия городов из таблицы городов.**  
Ожидаемый результат запроса: [letsdocode.ru...in/2-1.png](https://letsdocode.ru/sql-main/2-1.png)
```sql
SELECT DISTINCT city 
FROM            city
;
```
**Результат:**
| n |city|
| --- |----|
|1|Southport|
|2|Taguig|
|3|Tokat|
|4|Atlixco|
|5|Mukateve|

---

**Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.**  
Ожидаемый результат запроса: [letsdocode.ru...in/2-2.png](https://letsdocode.ru/sql-main/2-2.png)
```sql
SELECT 
	DISTINCT city 
from		 city
WHERE 		 city LIKE 'L%a' 
AND 		 city NOT LIKE '% %'
;
```
**Результат:**

| N | city   |
| --- | --- |
| 1 | Loja  |
| 2 | Luzinia |
| 3 | Lima     |
| 4 | Liepaja |

---

**Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и стоимость которых превышает 1.00.**
Платежи нужно отсортировать по дате платежа.  
Ожидаемый результат запроса: [letsdocode.ru...in/2-3.png](https://letsdocode.ru/sql-main/2-3.png)
```sql
SELECT 		*
FROM 		payment
WHERE 		payment_date BETWEEN '2005-06-17'::timestamp AND '2005-06-19 23:59:59.999'::timestamp 
AND 		amount < 1.00
ORDER BY 	payment_date
;
```
**Результат:**
|payment_id|customer_id|staff_id|rental_id|amount|payment_date|
|----------|-----------|--------|---------|------|------------|
|11399|422|1|1846|0.99|2005-06-17 00:02:44.000|
|14140|526|2|1848|0.99|2005-06-17 00:07:07.000|
|12164|451|1|1851|0.99|2005-06-17 00:32:26.000|
|8170|301|1|1853|0.99|2005-06-17 00:39:54.000|
|14344|533|1|1859|0.99|2005-06-17 01:13:38.000|

---

**Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.**  
Ожидаемый результат запроса: [letsdocode.ru...in/2-4.png](https://letsdocode.ru/sql-main/2-4.png)
```sql
SELECT 		*
FROM 		payment
ORDER BY 	payment_date DESC
LIMIT 		10
;
```
**Результат:**
|payment_id|customer_id|staff_id|rental_id|amount|payment_date|
|----------|-----------|--------|---------|------|------------|
|630|23|2|15532|2.99|2006-02-14 15:16:03.000|
|302|11|1|11646|0.99|2006-02-14 15:16:03.000|
|600|22|1|12222|4.99|2006-02-14 15:16:03.000|
|417|15|2|13968|0.00|2006-02-14 15:16:03.000|
|253|9|1|15813|4.99|2006-02-14 15:16:03.000|
|145|5|2|13209|0.99|2006-02-14 15:16:03.000|
|416|15|1|13798|3.98|2006-02-14 15:16:03.000|
|578|21|1|14933|2.99|2006-02-14 15:16:03.000|
|385|14|1|13780|4.99|2006-02-14 15:16:03.000|
|781|28|2|12938|2.99|2006-02-14 15:16:03.000|

---

**Задание 5. Выведите следующую информацию по покупателям:**

1.  Фамилия и имя (в одной колонке через пробел)
2.  Электронная почта
3.  Длину значения поля email
4.  Дату последнего обновления записи о покупателе (без времени)  
    Каждой колонке задайте наименование на русском языке.  
    Ожидаемый результат запроса: [letsdocode.ru...in/2-5.png](https://letsdocode.ru/sql-main/2-5.png)
```sql
SELECT 	last_name || ' ' || first_name AS "Фамилия Имя", 
		email AS "Электронная почта", 
		character_length(email) AS "Длина поля 'Электронная почта'", 
		last_update::date AS "Запись о покупателе обновлена"
FROM 	customer
;
```
**Результат:**
|Фамилия Имя|Электронная почта|Длина поля 'Электронная почта'|Запись о покупателе обновлена|
|-----------|-----------------|------------------------------|-----------------------------|
|SMITH MARY|MARY.SMITH@sakilacustomer.org|29|2006-02-15|
|JOHNSON PATRICIA|PATRICIA.JOHNSON@sakilacustomer.org|35|2006-02-15|
|WILLIAMS LINDA|LINDA.WILLIAMS@sakilacustomer.org|33|2006-02-15|
|JONES BARBARA|BARBARA.JONES@sakilacustomer.org|32|2006-02-15|
|BROWN ELIZABETH|ELIZABETH.BROWN@sakilacustomer.org|34|2006-02-15|

---

**Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. **
Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.  
Ожидаемый результат запроса: [letsdocode.ru...in/2-6.png](https://letsdocode.ru/sql-main/2-6.png)
```sql
SELECT 	customer_id,
		store_id,
		LOWER(first_name),
		LOWER(last_name),
		email,
		address_id,
		activebool,
		create_date,
		last_update,
		active
FROM 	customer
WHERE 	first_name in ('KELLY', 'WILLIE')
AND		active = 1
;
```
**Результат:**
|customer_id|store_id|lower|lower|email|address_id|activebool|create_date|last_update|active|
|-----------|--------|-----|-----|-----|----------|----------|-----------|-----------|------|
|67|1|kelly|torres|KELLY.TORRES@sakilacustomer.org|71|true|2006-02-14|2006-02-15 04:57:20.000|1|
|219|2|willie|howell|WILLIE.HOWELL@sakilacustomer.org|223|true|2006-02-14|2006-02-15 04:57:20.000|1|
|359|2|willie|markham|WILLIE.MARKHAM@sakilacustomer.org|364|true|2006-02-14|2006-02-15 04:57:20.000|1|
|546|1|kelly|knott|KELLY.KNOTT@sakilacustomer.org|552|true|2006-02-14|2006-02-15 04:57:20.000|1|

---

### **Дополнительная часть:**

**Задание 1.Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00. **

Ожидаемый результат запроса: [letsdocode.ru...in/2-7.png](https://letsdocode.ru/sql-main/2-7.png)
```sql

```
**Результат:**
|film_id|title|description|release_year|language_id|original_language_id|rental_duration|rental_rate|length|replacement_cost|rating|last_update|special_features|fulltext|
|-------|-----|-----------|------------|-----------|--------------------|---------------|-----------|------|----------------|------|-----------|----------------|--------|
|7|AIRPLANE SIERRA|A Touching Saga of a Hunter And a Butler who must Discover a Butler in A Jet Boat|2006|1||6|4.99|62|28.99|PG-13|2006-02-15 05:03:42.000|{Trailers,"Deleted Scenes"}|'airplan':1 'boat':20 'butler':11,16 'discov':14 'hunter':8 'jet':19 'must':13 'saga':5 'sierra':2 'touch':4|
|17|ALONE TRIP|A Fast-Paced Character Study of a Composer And a Dog who must Outgun a Boat in An Abandoned Fun House|2006|1||3|0.99|82|14.99|R|2006-02-15 05:03:42.000|{Trailers,"Behind the Scenes"}|'abandon':22 'alon':1 'boat':19 'charact':7 'compos':11 'dog':14 'fast':5 'fast-pac':4 'fun':23 'hous':24 'must':16 'outgun':17 'pace':6 'studi':8 'trip':2|
|23|ANACONDA CONFESSIONS|A Lacklusture Display of a Dentist And a Dentist who must Fight a Girl in Australia|2006|1||3|0.99|92|9.99|R|2006-02-15 05:03:42.000|{Trailers,"Deleted Scenes"}|'anaconda':1 'australia':18 'confess':2 'dentist':8,11 'display':5 'fight':14 'girl':16 'lacklustur':4 'must':13|
|24|ANALYZE HOOSIERS|A Thoughtful Display of a Explorer And a Pastry Chef who must Overcome a Feminist in The Sahara Desert|2006|1||6|2.99|181|19.99|R|2006-02-15 05:03:42.000|{Trailers,"Behind the Scenes"}|'analyz':1 'chef':12 'desert':21 'display':5 'explor':8 'feminist':17 'hoosier':2 'must':14 'overcom':15 'pastri':11 'sahara':20 'thought':4|

---

**Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма. ** 
Ожидаемый результат запроса: [letsdocode.ru...in/2-8.png](https://letsdocode.ru/sql-main/2-8.png)
```sql
SELECT 		*
FROM 		film
ORDER BY 	CHARACTER_LENGTH(description) DESC 
LIMIT 		3
;
```
**Результат:**
|film_id|title|description|release_year|language_id|original_language_id|rental_duration|rental_rate|length|replacement_cost|rating|last_update|special_features|fulltext|
|-------|-----|-----------|------------|-----------|--------------------|---------------|-----------|------|----------------|------|-----------|----------------|--------|
|217|DAZED PUNK|A Action-Packed Story of a Pioneer And a Technical Writer who must Discover a Forensic Psychologist in An Abandoned Amusement Park|2006|1||6|4.99|120|20.99|G|2006-02-15 05:03:42.000|{Commentaries,"Deleted Scenes"}|'abandon':23 'action':5 'action-pack':4 'amus':24 'daze':1 'discov':17 'forens':19 'must':16 'pack':6 'park':25 'pioneer':10 'psychologist':20 'punk':2 'stori':7 'technic':13 'writer':14|
|116|CANDIDATE PERDITION|A Brilliant Epistle of a Composer And a Database Administrator who must Vanquish a Mad Scientist in The First Manned Space Station|2006|1||4|2.99|70|10.99|R|2006-02-15 05:03:42.000|{"Deleted Scenes","Behind the Scenes"}|'administr':12 'brilliant':4 'candid':1 'compos':8 'databas':11 'epistl':5 'first':21 'mad':17 'man':22 'must':14 'perdit':2 'scientist':18 'space':23 'station':24 'vanquish':15|
|274|EGG IGBY|A Beautiful Documentary of a Boat And a Sumo Wrestler who must Succumb a Database Administrator in The First Manned Space Station|2006|1||4|2.99|67|20.99|PG|2006-02-15 05:03:42.000|{Commentaries,"Behind the Scenes"}|'administr':18 'beauti':4 'boat':8 'databas':17 'documentari':5 'egg':1 'first':21 'igbi':2 'man':22 'must':14 'space':23 'station':24 'succumb':15 'sumo':11 'wrestler':12|

---

**Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:**

-   в первой колонке должно быть значение, указанное до @,
-   во второй колонке должно быть значение, указанное после @.  
    Ожидаемый результат запроса: [letsdocode.ru...in/2-9.png](https://letsdocode.ru/sql-main/2-9.png)

```sql
SELECT 	SUBSTRING(email FROM 1 FOR STRPOS(email, '@')-1) AS PREFIX, 
		SUBSTRING(email FROM STRPOS(email, '@')+1 FOR CHARACTER_LENGTH(email)-STRPOS(email, '@') ) AS DOMEN
FROM 	customer
;
```
**Результат:**
|prefix|domen|
|------|-----|
|MARY.SMITH|sakilacustomer.org|
|PATRICIA.JOHNSON|sakilacustomer.org|
|LINDA.WILLIAMS|sakilacustomer.org|
|BARBARA.JONES|sakilacustomer.org|
|ELIZABETH.BROWN|sakilacustomer.org|

---

**Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными. **

Ожидаемый результат запроса: [letsdocode.ru...n/2-10.png](https://letsdocode.ru/sql-main/2-10.png)
```sql
SELECT 	UPPER(SUBSTRING(email FROM 1 for 1)) || LOWER(SUBSTRING(email FROM 2 FOR STRPOS(email, '@')-2)) AS PREFIX, 
		UPPER(SUBSTRING(email FROM STRPOS(email, '@')+1 FOR 1)) || (SUBSTRING(email FROM STRPOS(email, '@')+2 FOR CHARACTER_LENGTH(email)-STRPOS(email, '@'))) AS DOMEN
FROM 	customer
;
```

**Результат**:
|prefix|domen|
|------|-----|
|Mary.smith|Sakilacustomer.org|
|Patricia.johnson|Sakilacustomer.org|
|Linda.williams|Sakilacustomer.org|
|Barbara.jones|Sakilacustomer.org|
|Elizabeth.brown|Sakilacustomer.org|
|Jennifer.davis|Sakilacustomer.org|

---
### **Результат домашнего задания**  
[Ответ в формате "Шаблон для сдачи ДЗ в формате sql"](m2-utf8.sql)

**Критерии оценки**  
Для зачета домашнего задания необходимо правильно выполнить все задания из основной части.

*Преподаватель вправе предложить дополнительные задачи в рамках задания, чтобы подтвердить, что студент разобрался в теме.  
Преподаватель вправе поставить незачет без права пересдачи текущего задания, если студент прислал на проверку результат чужой работы и отказался делать дополнительное задание.  
*