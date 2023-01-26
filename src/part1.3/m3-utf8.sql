--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select concat_ws(' ', c.first_name, c.last_name) "Customer name", concat_ws(' ', a.address, a.address2) "address", c2.city, c3.country  
from customer c
inner join address a on c.address_id = a.address_id
inner join city c2 on a.city_id = c2.city_id 
inner join country c3 on c2.country_id = c3.country_id 
;


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select s.store_id "ID магазина", count(distinct c.customer_id) "Количество покупателей"
from store s 
inner join customer c on s.store_id = c.store_id 
group by s.store_id 
;

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select s.store_id "ID магазина", count(distinct c.customer_id) "Количество покупателей"
from store s 
inner join customer c on s.store_id = c.store_id 
group by s.store_id
having count(distinct c.customer_id)>300
;


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select s.store_id "ID магазина", count(distinct c.customer_id) "Количество покупателей", c2.city "Город", concat_ws(' ', s2.last_name, s2.first_name) "Имя сотрудника" 
from store s 
inner join customer c on s.store_id = c.store_id
inner join staff s2 on c.store_id = s2.store_id
inner join address a on s.address_id = a.address_id 
inner join city c2 on a.city_id = c2.city_id 
group by s.store_id, c2.city, s2.last_name, s2.first_name
having count(distinct c.customer_id)>300
;


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat_ws(' ', c.last_name, c.first_name) "Фамилия и имя покупателя" , count(r.inventory_id)
from rental r
join customer c using (customer_id)
group by r.customer_id, c.last_name, c.first_name
order by count(r.inventory_id) desc
limit 5
;


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select concat_ws(' ', c.last_name, c.first_name) "Фамилия и имя покупателя" , count(i.film_id) , round(sum(p.amount),0), min(p.amount), max(p.amount) 
from rental r 
join customer c using (customer_id)
join payment p using (rental_id)
join inventory i using (inventory_id) 
group by r.customer_id, c.last_name, c.first_name
;




--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 select c.city, c2.city
 from city c
 cross join (select city from city) c2
 where c.city <> c2.city
 ;


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
select r.customer_id as "ID покупателя", round(avg(r.return_date::date - r.rental_date::date),2) as "Срeднee кoличeствo днeй на вoзврат"
from rental r 
group by r.customer_id 
;

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select  f.title "Название фильма", f.rating "Рейтинг", f.special_features "Жанр", f.release_year "Год выпуска", l."name" "Язык", count(i.film_id) as "Количество аренд", sum(coalesce(p.amount,0)) as "Общая стоимость аренды"
from film f 
join "language" l using (language_id)
left join inventory i using (film_id) 
left join rental r using (inventory_id)  
left join payment p using (rental_id)
group by f.film_id, l."name"
order by f.title
;

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
--select  f.film_id, f.title
select  f.title "Название фильма", f.rating "Рейтинг", f.special_features "Жанр", f.release_year "Год выпуска", l."name" "Язык", count(i.film_id) as "Количество аренд", sum(coalesce(p.amount,0)) as "Общая стоимость аренды"
from film f 
join "language" l using (language_id)
left join inventory i using (film_id) 
left join rental r using (inventory_id)  
left join payment p using (rental_id)
where i.inventory_id is null
group by f.film_id, l."name"
order by f.title
;


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select r.staff_id, concat_ws(' ', c.first_name, c.last_name) "продавец", count(r.rental_id) "количество продаж",
    case when count(r.staff_id)>7300 then 'Да'
         when count(r.staff_id)<=7300 then 'Нет'
    end "Премия"
from rental r
join staff c using (staff_id)
group by r.staff_id, c.first_name, c.last_name
;




