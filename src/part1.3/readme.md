# Домашнее задание по теме "Основы SQL"

Вопросы по заданию

**Преподаватель:** Алексей Кузьмин, Николай Хащанов, Екатерина Волочаева, Александр Сумовский

Все работы мы проверяем на антиплагиат, поэтому важно выполнять их самостоятельно. Работам, которые не пройдут проверку, преподаватель поставит незачёт.

Если вы сталкиваетесь со сложностями, задавайте вопросы нашим экспертам и аспирантам, они с удовольствием вам помогут. Успехов в решении заданий!

**Модуль 3. Домашнее задание по теме «Основы SQL»**

**Цели домашнего задания:**

-   закрепить на практике знания по функциям агрегации и группировке строк;
-   научиться фильтровать сгруппированные строки;
-   закрепить навыки использования методов соединения таблиц с помощью разных вариаций JOIN.

**Перечень заданий**

**Основная часть**

Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.  
Ожидаемый результат запроса: [letsdocode.ru...in/3-1.png](https://letsdocode.ru/sql-main/3-1.png)
```sql
select  concat_ws(' ', c.first_name, c.last_name) "Customer name", 
		concat_ws(' ', a.address, a.address2) "address", 
		c2.city, 
		c3.country  
from customer c
inner join address a on c.address_id = a.address_id
inner join city c2 on a.city_id = c2.city_id 
inner join country c3 on c2.country_id = c3.country_id 
;
```

Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.  
Ожидаемый результат запроса: [letsdocode.ru.../3-2-1.png](https://letsdocode.ru/sql-main/3-2-1.png)  
```sql
select  s.store_id "ID магазина", 
		count(distinct c.customer_id) "Количество покупателей"
from store s 
inner join customer c on s.store_id = c.store_id 
group by s.store_id 
;
```
Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. Ожидаемый результат запроса: [letsdocode.ru.../3-2-2.png](https://letsdocode.ru/sql-main/3-2-2.png)  
```sql
select  s.store_id "ID магазина", 
		count(distinct c.customer_id) "Количество покупателей"
from store s 
inner join customer c on s.store_id = c.store_id 
group by s.store_id
having count(distinct c.customer_id)>300
;
```


Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём. Ожидаемый результат запроса: [letsdocode.ru.../3-2-3.png](https://letsdocode.ru/sql-main/3-2-3.png)
```sql
select  s.store_id "ID магазина", 
		count(distinct c.customer_id) "Количество покупателей", 
		c2.city "Город", concat_ws(' ', s2.last_name, s2.first_name) "Имя сотрудника" 
from store s 
inner join customer c on s.store_id = c.store_id
inner join staff s2 on c.store_id = s2.store_id
inner join address a on s.address_id = a.address_id 
inner join city c2 on a.city_id = c2.city_id 
group by s.store_id, c2.city, s2.last_name, s2.first_name
having count(distinct c.customer_id)>300
;
```


Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.  
Ожидаемый результат запроса: [letsdocode.ru...in/3-3.png](https://letsdocode.ru/sql-main/3-3.png)
```sql
select  concat_ws(' ', c.last_name, c.first_name) "Фамилия и имя покупателя",
		count(r.inventory_id)
from rental r
join customer c using (customer_id)
group by r.customer_id, c.last_name, c.first_name
order by count(r.inventory_id) desc
limit 5
;
```


Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:

-   количество взятых в аренду фильмов;
-   общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
-   минимальное значение платежа за аренду фильма;
-   максимальное значение платежа за аренду фильма.  
    Ожидаемый результат запроса: [letsdocode.ru...in/3-4.png](https://letsdocode.ru/sql-main/3-4.png)
```sql
select  concat_ws(' ', c.last_name, c.first_name) "Фамилия и имя покупателя",
		count(i.film_id) , 
		round(sum(p.amount),0), 
		min(p.amount), 
		max(p.amount) 
from rental r 
join customer c using (customer_id)
join payment p using (rental_id)
join inventory i using (inventory_id) 
group by r.customer_id, c.last_name, c.first_name
;
```

Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.  
Ожидаемый результат запроса: [letsdocode.ru...in/3-5.png](https://letsdocode.ru/sql-main/3-5.png)
```sql
select c.city, c2.city
from city c
cross join (select city from city) c2
where c.city <> c2.city
;
```

Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.  
Ожидаемый результат запроса: [letsdocode.ru...in/3-6.png](https://letsdocode.ru/sql-main/3-6.png)
```sql
select  r.customer_id as "ID покупателя", 
		round(avg(r.return_date::date - r.rental_date::date),2) as "Срeднee кoличeствo днeй на вoзврат"
from rental r 
group by r.customer_id 
;
```

**Дополнительная часть**

Задание 1. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.  
Ожидаемый результат запроса: [letsdocode.ru...in/3-7.png](https://letsdocode.ru/sql-main/3-7.png)
```sql
select  f.title "Название фильма", 
		f.rating "Рейтинг", 
		f.special_features "Жанр", 
		f.release_year "Год выпуска", 
		l."name" "Язык", 
		count(i.film_id) as "Количество аренд", 
		sum(coalesce(p.amount,0)) as "Общая стоимость аренды"
from film f 
join "language" l using (language_id)
left join inventory i using (film_id) 
left join rental r using (inventory_id)  
left join payment p using (rental_id)
group by f.film_id, l."name"
order by f.title
```

Задание 2. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.  
Ожидаемый результат запроса: [letsdocode.ru...in/3-8.png](https://letsdocode.ru/sql-main/3-8.png)
```sql
select  f.title "Название фильма", 
		f.rating "Рейтинг", 
		f.special_features "Жанр", 
		f.release_year "Год выпуска", 
		l."name" "Язык", 
		count(i.film_id) as "Количество аренд", 
		sum(coalesce(p.amount,0)) as "Общая стоимость аренды"
from film f 
join "language" l using (language_id)
left join inventory i using (film_id) 
left join rental r using (inventory_id)  
left join payment p using (rental_id)
where i.inventory_id is null
group by f.film_id, l."name"
order by f.title
;

```

Задание 3. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».  
Ожидаемый результат запроса: [letsdocode.ru...in/3-9.png](https://letsdocode.ru/sql-main/3-9.png)
```sql
select  r.staff_id, 
		concat_ws(' ', c.first_name, c.last_name) "продавец", 
		count(r.rental_id) "количество продаж",
		case when count(r.staff_id)>7300 then 'Да'
			 when count(r.staff_id)<=7300 then 'Нет'
		end "Премия"
from rental r
join staff c using (staff_id)
group by r.staff_id, c.first_name, c.last_name
;
```

**Результат домашнего задания**  
Заполните ответами шаблон для сдачи ДЗ в формате .sql.

**Критерии оценки**  
Для зачета необходимо правильно выполнить все задания из основной части.

_Преподаватель вправе предложить дополнительные задачи в рамках задания, чтобы подтвердить, что студент разобрался в теме.  
Преподаватель вправе поставить незачет без права пересдачи текущего задания, если студент прислал на проверку результат чужой работы и отказался делать дополнительное задание._