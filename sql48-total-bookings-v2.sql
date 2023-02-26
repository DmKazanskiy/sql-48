/*
 * 20230226: update
 */
show search_path;
SET search_path to bookings,public;

-- 1 
--- Какие самолеты имеют более 50 посадочных мест?
--- 20230222_ДХ: 10
---
/* 20230226: update none
 */
select *
from(
	select 	 aircraft_code , count(seat_no) 
	from 	 seats s 
	group by aircraft_code  
) cnt
join aircrafts a using (aircraft_code)
where count > 50
;

-- 2 
--- В каких аэропортах есть рейсы, в рамках которых можно добраться бизнес - классом дешевле, чем эконом - классом?
--- CTE
--- 20230222_ДХ: 0
---
/* 20230226: update:
 * Добавил ответ на Вопрос 2:
 * Рейс = flight_id (Пояснения к Итоговому заданию)
 */
with flight_params as (
	select distinct flight_id, coalesce(min(Business),0) amnt_business, coalesce(max(Economy),0) amnt_economy
	from (
	select flight_id
			, case when fare_conditions = 'Business' then amount end Business
			, case when fare_conditions = 'Economy' then amount end Economy
	from ticket_flights tf 
	) d
	group by flight_id
)
select f.departure_airport, f.flight_no, f.scheduled_departure, fp.flight_id, fp.amnt_business, fp.amnt_economy
from flight_params fp
join flights f using(flight_id)
where amnt_business < amnt_economy and  amnt_business <> 0
order by fp.flight_id
;

/* 20230226: update
 * Добавил альтернативное решение, которое, как я считаю, более подходит для ответа на вопрос.
 * Рейс = flight_no (ИМХО)
 */
with flight_params as (
	select distinct flight_no, departure_airport, coalesce(min(Business),0) amnt_business, coalesce(max(Economy),0) amnt_economy
	from (
		select   case when fare_conditions = 'Business' then amount end Business
				, case when fare_conditions = 'Economy' then amount end Economy
				, f.flight_no
				, f.departure_airport
		from ticket_flights tf 
		join flights f using(flight_id)
	) fn
	group by flight_no, departure_airport
)
select fp.departure_airport, fp.flight_no, fp.amnt_business, fp.amnt_economy
from flight_params fp
where amnt_business < amnt_economy and  amnt_business <> 0
order by fp.flight_no
;

-- 3
---Есть ли самолеты, не имеющие бизнес - класса?
--- array_agg
--- 20230222_ДХ: 15
---
/* 20230226: update none
 */

select 	 aircraft_code , array_agg(fare_conditions) stat
	from (
	select distinct fare_conditions, aircraft_code
	from seats s2 
	group by fare_conditions, aircraft_code  
	order by aircraft_code
	) s 
	group by aircraft_code
 having not 'Business' = any(array_agg(fare_conditions))
;

-- 4
---Найдите количество занятых мест для каждого рейса, процентное отношение количества занятых мест к общему количеству мест в самолете, добавьте накопительный итог вывезенных пассажиров по каждому аэропорту на каждый день.
--- Оконная функция
--- Подзапрос
-- 20230222_ДХ: 5. Отсутствует накопительный итог согласно условия задания.
--
/* 20230226: update
 * Исправил скрипт, добавил вывод накопительного итога согласно условиям задания
 *  
 */
with t as (
	select flight_id , max(boarding_no) passengers_cnt
	from boarding_passes bp 
	group by flight_id
),
aircraft_seats as (
	select aircraft_code, count(seat_no) aircraft_seats_total
	from seats
	group by aircraft_code 
),
r as (
	select *
	from (
		select t.flight_id, f.flight_no,f.aircraft_code, t.passengers_cnt, ac.aircraft_seats_total, f.departure_airport, coalesce (date(f.actual_departure), date(scheduled_departure)) departure_dt, f.status
		from t
		join flights f on t.flight_id = f.flight_id
		join aircraft_seats ac on f.aircraft_code = ac.aircraft_code
		order by departure_dt
	) nc
)
select *, sum(passengers_cnt)  over (partition by departure_airport order by departure_dt)
from (
	select r.flight_no, r.departure_dt, r.passengers_cnt, round(r.passengers_cnt::numeric/r.aircraft_seats_total*100,2) occupied_prcnt,r.departure_airport
	from r
) a
;


-- 5
-- Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
-- Выведите в результат названия аэропортов и процентное отношение.
--- Оконная функция
--- Оператор ROUND
--- 20230222_ДХ: 0. Сумма процентов должна быть равна 100, чему равна у Вас? Разберитесь отношение чего нужно найти.
---
/* 20230226: update
 * Статус рейса (status) может принимать одно из следующих значений:
 *  Scheduled - Рейс доступен для бронирования;
 *  On Time - Рейс доступен для регистрации (за сутки до плановой даты вылета) и не задержан;
 *  Delayed - Рейс доступен для регистрации (за сутки до плановой даты вылета), но задержан;
 *  Departed - Самолет уже вылетел и находится в воздухе;
 *  Arrived - Самолет прибыл в пункт назначения;
 *  Cancelled - Рейс отменен.
 */

with flights_not_cancelled as (
	select flight_id, flight_no, departure_airport, arrival_airport
	from flights
	where status <> ('Cancelled')
),
airports_flight_by_total as (
	select  distinct t.departure_airport, t.arrival_airport
			,count(*) over (partition by t.departure_airport, t.arrival_airport)::numeric
			*100
			/count(*) over () as flights_by_total_prc
	from flights_not_cancelled t
)
select 'Total' departure_airport,' ' arrival_airport ,sum(flights_by_total_prc) flights_by_total_prc
from airports_flight_by_total
union all
(select departure_airport, arrival_airport, round(flights_by_total_prc,2)
from airports_flight_by_total
order by departure_airport desc, arrival_airport)
;

-- 6
---Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7
--- 20230222_ДХ: 15
---
/* 20230226: update none
 */

with cell_users as (
	select ticket_no
		,case when substring(contact_data ->> 'phone' from 1 for 2) like '+7' then substring(contact_data ->>'phone'::varchar from 3 for 3)  
			  else null
		end phone
	from tickets t
),
cell_stat as (
	select 	phone, count(phone)
	from 	cell_users
	group by phone
)
select *
from cell_stat
union all
select 'Total by cell', sum(count)
from cell_stat
union all
select 'Total by user', count(phone)
from cell_users
;

--7
--- Между какими городами не существует перелетов?
--- Декартово произведение
--- Оператор EXCEPT
--- 20230222_ДХ: 0. Так как есть города в которых по несколько аэропортов, то изначальная работа с аэропортами приводит к ложным данным. 
--- То есть в airports_pair_city ложные пары городов. 
--- flights_pair - лишний шаг, так как в flights_pair_city делаете тоже самое.
---
/* 20230226: update
 * изменил скрипт
 */
select distinct a.city src, a2.city dst 	-- формируем возможные пары городов: город отправления(src) - город назначения(dst)
from airports a
cross join (select distinct city from airports) a2
where a.city <> a2.city 					-- ... и исключаем пары с одноименными городами
except 										-- из возможных пар городов вычитаем фактические пары городов
select distinct 							-- формируем фактические пары городов: город отправления(src) - город назначения(dst)
		departure_city src
		,arrival_city dst
from routes r 
;

--8
---Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
---До 50 млн - low
---От 50 млн включительно до 150 млн - middle
---От 150 млн включительно - high
---Выведите в результат количество маршрутов в каждом классе.
--- Оператор CASE
--- 20230222_ДХ: 0. 
--- В условии теряете данные. Поиск подстроки в строке - заведомо ложная работа с данными.
--- Нет ответа на вопрос, где должно быть количество маршрутов в получившихся классах.
---
/* 20230226: update
 * изменил скрипт
 * Пояснения:	
 * Рейс, перелет - это flight_id, разовый перелет между двумя аэропортами
 * Маршрут - это все перелеты между двумя аэропортами..
 * ...при выяснении физического смысла понятия "Маршрут" остановился на гипотезе:
 * < Маршрут это список рейсов выполняющих перелеты из "departure_airport" в "arrival_airport" > 
 */
with fin_by_routes as (
	select distinct 
	flight_no, departure_airport, arrival_airport, sum(amount) amount
	from (
		select 	f.flight_no, tf.flight_id, tf.amount, f.departure_airport, f.arrival_airport 
		from	ticket_flights tf
		join flights f using(flight_id)
	) flights_group
	group by flight_no, departure_airport, arrival_airport
)
select distinct 
	departure_airport, arrival_airport
	,case 
		when sum(amount) < 5E7 then 'low'
		when sum(amount) >= 5E6 and sum(amount) < 15E7 then 'middle'
		when sum(amount) >= 15E7 then 'high'
		else null
	end "level"
	,count(flight_no)	
from fin_by_routes
group by departure_airport, arrival_airport
order by count desc
;

---9
--- Выведите пары городов между которыми расстояние более 5000 км
--- Оператор RADIANS или использование sind/cosd
--	L = acos(sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b))*earth()
--	где 
-- 	latitude_a и latitude_b — широты пункта А и Б (радианы)
-- 	longitude_a, longitude_b — долготы пункта А и Б(радианы)
---
--- 20230222_ДХ: 35 
--- В airports_l уже есть все данные, соответственно coordinates, coordinates_pair и airports_city_pairs 
--- - это все лишние действия, которое созданы для дополнительной нагрузки и не более.
/* 20230226: update none
 */

with airports_l(airport_src,airport_dst) as (
	select a.airport_code airport_src, a2.airport_code airport_dst
	from airports a
	cross join (select airport_code from airports) a2
	where a.airport_code > a2.airport_code
),
coordinates as (
	select a.airport_code acode, radians(a.latitude) latd, radians(a.longitude) long
	from airports a
),
coordinates_pair as (
	select l.*, src.long longitude_a, src.latd latitude_a, dst.long longitude_b, dst.latd latitude_b
	from airports_l l
	join coordinates src on src.acode = l.airport_src
	join coordinates dst on dst.acode = l.airport_dst
),
airports_pair (src,dst,distance) as (
	select a.airport_src src, a.airport_dst dst, round(distance) distance
	from (
		select 	
			airport_src
			,airport_dst
			,acos(sin(latitude_a)*sin(latitude_b) + cos(latitude_a)*cos(latitude_b)*cos(longitude_a - longitude_b))*6371::int as distance		
		from coordinates_pair
	) a
	where distance >= 5000
),
airports_city_pairs as ( 
	select distinct pair, src_city, dst_city
	from (
		select 	a.*, src.city src_city, dst.city dst_city, concat(src.city, dst.city) pair
		from 	airports_pair a
		join airports src on src.airport_code = a.src
		join airports dst on dst.airport_code = a.dst
	) acp
	group by pair, src_city, dst_city
)
select src_city, dst_city
from airports_city_pairs
;




