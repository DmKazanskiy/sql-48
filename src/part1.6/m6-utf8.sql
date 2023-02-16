--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
SELECT *
FROM film
where array['Behind the Scenes'] && array[special_features]
;



--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
SELECT *
FROM film
where array['Behind the Scenes'] <@ array[special_features]
;

SELECT *
FROM film
where 'Behind the Scenes' = any(special_features)
;


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

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


--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

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


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

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
refresh materialized view
behind_the_series
;

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее:
-- Ответ: поиск значения в массиве происходит быстрее для оператора "=" и функции "any"

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
-- Ответ: вариант вычислений с использованием подзапроса работает быстрее: 

-- Результат анализа скорости выполнения запроса:
-- explain analyze --Задание #: cost/time

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





--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии
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

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
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


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

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
		,rent_dt "День,больше всего фильмов", count "Количество фильмов за день", pmnt_dt "День, наименьшая сумма продаж", amnt_min "Сумма продаж за день"
from t1
join t2 on t1.store_id = t2.store_id
where count = cnt_max and sum = amnt_min
;
