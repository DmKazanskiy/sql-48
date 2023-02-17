show search_path;
SET search_path to bookings,public;

-- 1 
--- Какие самолеты имеют более 50 посадочных мест?
select *
from(
	select 	 aircraft_code , count(seat_no) 
	from 	 seats s 
	group by aircraft_code  
) cnt
join aircrafts a using (aircraft_code)
where count > 50
;

--2 
--- В каких аэропортах есть рейсы, в рамках которых можно добраться бизнес - классом дешевле, чем эконом - классом?
--- CTE



--3
---Есть ли самолеты, не имеющие бизнес - класса?
--- array_agg

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

--4
---Найдите количество занятых мест для каждого рейса, процентное отношение количества занятых мест к общему количеству мест в самолете, добавьте накопительный итог вывезенных пассажиров по каждому аэропорту на каждый день.
--- Оконная функция
--- Подзапрос
--
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
--where nc.departure_dt is not null
)
select *, sum(passengers_cnt)  over (partition by flight_no order by departure_dt)
from (
select r.departure_airport, r.flight_no, r.departure_dt, r.passengers_cnt, round(r.passengers_cnt::numeric/r.aircraft_seats_total*100,2) occupied_prcnt
from r
) a
;

--5
---Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
---Выведите в результат названия аэропортов и процентное отношение.
--- Оконная функция
--- Оператор ROUND
with t as (
	select f.flight_no 
		   ,a1.airport_name airport_src
		   ,a2.airport_name airport_dst
	from flights f
	join airports a1 on f.departure_airport = a1.airport_code
	join airports a2 on f.arrival_airport = a2.airport_code
)
select *, round(count(flight_no)::numeric/count(flight_no) over()*100,2) flight_f_total_prc
from t
group by t.flight_no, t.airport_src, t.airport_dst
;


--6
---Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7
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
with airports_pair(airport_src,airport_dst) as ( -- count rows = 5356
	select a.airport_code airport_src, a2.airport_code airport_dst
	from airports a
	cross join (select airport_code from airports) a2
	where a.airport_code < a2.airport_code
),
airports_pair_city(paircode,airport_src,airport_dst) as (-- count rows = 5134
	select distinct (concat(a1.city, a2.city)), a1.city city_src, a2.city city_dst
	from airports_pair ap
	join airports a1 on ap.airport_src = a1.airport_code
	join airports a2 on ap.airport_dst = a2.airport_code	
),
flights_pair(paircode,airport_src,airport_dst) as ( -- count rows = 618
select distinct(concat(departure_airport , arrival_airport)) paircode, departure_airport airport_src, arrival_airport airport_dst
from flights f 
),
flights_pair_city(paircode,airport_src,airport_dst) as ( -- count rows = 516
	select distinct (concat(a1.city, a2.city)), a1.city city_src, a2.city city_dst
	from flights f 
	join airports a1 on f.departure_airport = a1.airport_code
	join airports a2 on f.arrival_airport = a2.airport_code	
)
-- count rows 4811
select airport_src,airport_dst 
from airports_pair_city a
except
select airport_src,airport_dst
from flights_pair_city f
;



--8
---Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
---До 50 млн - low
---От 50 млн включительно до 150 млн - middle
---От 150 млн включительно - high
---Выведите в результат количество маршрутов в каждом классе.
--- Оператор CASE

with routes_info(num,num_id,grade,amnt,stat) as (
	select f.flight_no num, tf.flight_id num_id , tf.fare_conditions grade, tf.amount amnt, f.status stat 
	from	ticket_flights tf
	join flights f using(flight_id)
	where f.status not like 'Cancelled%'
)
select 	num
		,case 
			when sum(amnt) < 5E7 then 'low'
			when sum(amnt) >= 5E6 and sum(amnt) < 15E7 then 'middle'
			when sum(amnt) >= 15E7 then 'high'
			else null
		end "level"
		,count(amnt) cnt_level
from routes_info
group by num
;

---9
--- Выведите пары городов между которыми расстояние более 5000 км
--- Оператор RADIANS или использование sind/cosd
--	L = acos(sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b))*earth()
--	где 
-- 	latitude_a и latitude_b — широты пункта А и Б (радианы)
-- 	longitude_a, longitude_b — долготы пункта А и Б(радианы)

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

