# Домашнее задание по теме "Работа с PostgreSQL(часть 2)"


**Преподаватель:** Алексей Кузьмин, Николай Хащанов, Екатерина Волочаева, Александр Сумовский

Все работы мы проверяем на антиплагиат, поэтому важно выполнять их самостоятельно. Работам, которые не пройдут проверку, преподаватель поставит незачёт.

Если вы сталкиваетесь со сложностями, задавайте вопросы нашим экспертам и аспирантам, они с удовольствием вам помогут. Успехов в решении заданий!

## **Модуль 6. Домашнее задание по теме « Работа с PostgreSQL (часть 2)»**

### **Цели домашнего задания:**

-   закрепить навыки использования функций и операторов языка SQL по поиску значений в массиве;
-   продемонстрировать работу с материализованными представлениями;
-   научиться строить и анализировать план выполнения запросов.

### **Перечень заданий**

#### **Основная часть**

Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом “Behind the Scenes”.  
Ожидаемый результат запроса: [letsdocode.ru...in/6-1.png](https://letsdocode.ru/sql-main/6-1.png)

```sql
SELECT *
FROM film
where array['Behind the Scenes'] && array[special_features]
;
```

Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL для поиска значения в массиве.  
Ожидаемый результат запроса: [letsdocode.ru...in/6-2.png](https://letsdocode.ru/sql-main/6-2.png)

```sql
SELECT *
FROM film
where array['Behind the Scenes'] <@ array[special_features]
;

SELECT *
FROM film
where 'Behind the Scenes' = any(special_features)
;
```

Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.  
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.  
Ожидаемый результат запроса: [letsdocode.ru...in/6-3.png](https://letsdocode.ru/sql-main/6-3.png)

```sql
with t_attr as (
	SELECT film_id
	FROM film f
	where array['Behind the Scenes'] && array[special_features]
)
select 	r.customer_id, count(rt.inventory_id)
from 	rental r
join 	inventory rt using (inventory_id)
where 	film_id in (
			select * 
			from t_attr
		)
group by r.customer_id
order by r.customer_id
;

```

Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.  
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать для решения задания.  
Ожидаемый результат запроса: [letsdocode.ru...in/6-4.png](https://letsdocode.ru/sql-main/6-4.png)

```sql
select 	r.customer_id, count(rt.inventory_id)
from 	rental r
join 	inventory rt using (inventory_id)
where 	film_id in (
			SELECT film_id
			FROM film f
			where array['Behind the Scenes'] && array[special_features]
		)
group by r.customer_id
order by r.customer_id
;
```

Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос для обновления материализованного представления.

```sql
create materialized view
behind_the_series
as 
	select 	r.customer_id, count(rt.inventory_id)
	from 	rental r
	join 	inventory rt using (inventory_id)
	where 	film_id in (
				SELECT film_id
				FROM film f
				where array['Behind the Scenes'] && array[special_features]
			)
	group by r.customer_id
	order by r.customer_id
with no data
;
-- Обновление набора данных
refresh materialized view
behind_the_series
;

```

Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:  
 - с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее: 
 > поиск значения в массиве происходит быстрее для оператора "=" и функции "any";
 > 

- какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса:
> вариант вычислений с использованием подзапроса работает быстрее
> 

> Результат анализа скорости выполнения запроса:
> explain analyze --Задание #: cost/time
> 
```sql
explain analyze --Задание 1: 67.50/0.453
SELECT *
FROM film
where array['Behind the Scenes'] && array[special_features]
;

explain analyze --Задание 2.1: 67.50/0.471
SELECT *
FROM film
where array['Behind the Scenes'] <@ array[special_features]
;


explain analyze --Задание 2.2: 77.50/0.339
SELECT *
FROM film
where 'Behind the Scenes' = any(special_features)
;


explain analyze --Задание 3: 167.85/20.757
with t_attr as (
	SELECT film_id
	FROM film f
	where array['Behind the Scenes'] && array[special_features]
)
select 	r.customer_id, count(rt.inventory_id)
from 	rental r
join 	inventory rt using (inventory_id)
where 	film_id in (
			select * 
			from t_attr
		)
group by r.customer_id
order by r.customer_id
;


explain analyze --Задание 4: 165.77/12.292
select 	r.customer_id, count(rt.inventory_id)
from 	rental r
join 	inventory rt using (inventory_id)
where 	film_id in (
			SELECT film_id
			FROM film f
			where array['Behind the Scenes'] && array[special_features]
		)
group by r.customer_id
order by r.customer_id
;

```

#### **Дополнительная часть**

Задание 1. Откройте [по ссылке](https://letsdocode.ru/sql-hw5.sql) SQL-запрос.

-   Сделайте explain analyze этого запроса.
-   Основываясь на описании запроса, найдите узкие места и опишите их.
-   Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
-   Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. Описание строк в explain можно посмотреть [по ссылке](https://use-the-index-luke.com/sql/explain-plan/postgresql/operations).

```sql
explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc
;
```

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.  
Ожидаемый результат запроса: [letsdocode.ru...in/6-5.png](https://letsdocode.ru/sql-main/6-5.png)

```sql
with t as (
	select  *
			,row_number () over (partition by staff_id order by payment_date) as rownum
	from payment p
),
s as (
	select * from t
	where rownum = 1
)
select *
from s
join customer using(customer_id)
join rental r using(rental_id)
join inventory i using(inventory_id)
join film f using(film_id)
;

```

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:

-   день, в который арендовали больше всего фильмов (в формате год-месяц-день);
-   количество фильмов, взятых в аренду в этот день;
-   день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
-   сумму продажи в этот день.  
    Ожидаемый результат запроса: [letsdocode.ru...in/6-6.png](https://letsdocode.ru/sql-main/6-6.png)

```sql
with 
	t1 as (
		select store_id, date(rental_date) as "rent_dt", count(r.rental_id), max(count(r.rental_id)) over(partition by store_id) cnt_max--, sum(amount) 
		from rental r 
		join inventory i on r.inventory_id = i.inventory_id 
		join payment p on r.rental_id = p.payment_id 
		group by date(rental_date),store_id
	),
	t2 as (
		select store_id, date(payment_date) as "pmnt_dt", sum(amount), min(sum(amount)) over(partition by i.store_id) amnt_min --store_id, date(rental_date) as "rent_dt", count(film_id)--, sum(amount) 
		from payment p
		join rental r on r.rental_id = p.payment_id
		join inventory i on r.inventory_id = i.inventory_id 
		group by date(payment_date),store_id
	)
select 	t1.store_id "ID магазина"
		, rent_dt "День,больше всего фильмов"
		, count "Количество фильмов за день"
		, pmnt_dt "День, наименьшая сумма продаж"
		, amnt_min "Сумма продаж за день"
from t1
join t2 on t1.store_id = t2.store_id
where count = cnt_max and sum = amnt_min
;
```

**Результат домашнего задания**  
Заполните ответами шаблон для сдачи ДЗ в формате .sql.

**Критерии оценки**  
Для зачёта необходимо правильно выполнить все задания из основной части.

_Преподаватель вправе предложить дополнительные задачи в рамках задания, чтобы подтвердить, что студент разобрался в теме.  
Преподаватель вправе поставить незачет без права пересдачи текущего задания, если студент прислал на проверку результат чужой работы и отказался делать дополнительное задание._