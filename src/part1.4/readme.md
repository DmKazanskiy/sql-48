# Домашнее задание по теме "Углубление в SQL"

## Задание

Вопросы по заданию

**Преподаватель:** Алексей Кузьмин, Николай Хащанов, Екатерина Волочаева, Александр Сумовский

Все работы мы проверяем на антиплагиат, поэтому важно выполнять их самостоятельно. Работам, которые не пройдут проверку, преподаватель поставит незачёт.

Если вы сталкиваетесь со сложностями, задавайте вопросы нашим экспертам и аспирантам, они с удовольствием вам помогут. Успехов в решении заданий!

## **Модуль 4. Домашнее задание по теме «Углубление в SQL»**

**Цели домашнего задания:**

-   научиться проектировать архитектуру таблиц базы данных, работать с ограничениями и атрибутами полей, заполнять таблицы данными;
-   закрепить навыки работы с первичными и внешними ключами;
-   продемонстрировать знания по модификации таблиц баз данных.

**Перечень заданий**

### **Основная часть**  
База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете в этой новой схеме, если подключение к локальному серверу, то создаёте новую схему и в ней создаёте таблицы.

```sql
create schema if not exists dkazanskiy_lecture_4 authorization CURRENT_USER
;
SET search_path TO dkazanskiy_lecture_4
;

```

Задание 1. Спроектируйте базу данных, содержащую три справочника:  
· язык (английский, французский и т. п.);  
· народность (славяне, англосаксы и т. п.);  
· страны (Россия, Германия и т. п.).  
Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.  
Требования к таблицам-справочникам:  
· наличие ограничений первичных ключей.  
· идентификатору сущности должен присваиваться автоинкрементом;  
· наименования сущностей не должны содержать null-значения, не должны допускаться дубликаты в названиях сущностей.  
Требования к таблицам со связями:  
· наличие ограничений первичных и внешних ключей.

В качестве ответа на задание пришлите запросы создания таблиц и запросы по добавлению в каждую таблицу по 5 строк с данными.

```sql
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table "language" (
 	lang_id serial primary key,
  	lang_name varchar (100) not null
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
insert into "language" (lang_name)
values	('английский'),
		('французский'),
		('немецкий'),
		('японский'),
		('швецкий')
;
select * from "language";

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
create table "nationality" (
 	nationality_id serial primary key,
 	nationality_name varchar (100) not null
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
insert into "nationality" (nationality_name)
values	('славяне'),
		('англосаксы'),
		('французы'),
		('индусы'),
		('немцы')
;

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table "country" (
 	country_id serial primary key,
 	country_name varchar (100) not null
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
insert into "country" (country_name)
values	('Россия'),
		('Германия'),
		('Франция'),
		('Индия'),
		('Великобритания')
;

```

```sql
--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table "language_nationality" (
	lang_id int2 NOT NULL,
	nationality_id int2 NOT NULL,
	CONSTRAINT language_nationality_pkey PRIMARY KEY (lang_id, nationality_id),
	CONSTRAINT language_nationality_lang_id_fkey FOREIGN KEY (lang_id) REFERENCES "language"(lang_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT language_nationality_nationality_id_fkey FOREIGN KEY (nationality_id) REFERENCES "nationality"(nationality_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into "language_nationality" (lang_id, nationality_id)
select l.lang_id, n.nationality_id
from "language" l 
cross join nationality n
where l.lang_id <> n.nationality_id
;

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nationality_country (
	nationality_id serial NOT NULL,
	country_id serial NOT NULL,
	CONSTRAINT nationality_country_pkey PRIMARY KEY (nationality_id, country_id),
	CONSTRAINT nationality_country_country_id_fkey FOREIGN KEY (country_id) REFERENCES "country"(country_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT nationality_country_nationality_id_fkey FOREIGN KEY (nationality_id) REFERENCES "nationality"(nationality_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into nationality_country (nationality_id, country_id)
select n.nationality_id, c.country_id
from nationality n 
cross join country c
where n.nationality_id <> c.country_id
;

```


### **Дополнительная часть**

Задание 1. Создайте новую таблицу film_new со следующими полями:  
· film_name — название фильма — тип данных varchar(255) и ограничение not null;  
· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;  
· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;  
· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, что значение должно быть больше 0.  
Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.
```sql
create table dkazanskiy_lecture_4.film_new (
	film_name varchar(255) not null,
	film_year int check (film_year > 0),
	film_rental_rate numeric(4,2) default (0.99),
	film_duration int not null check (film_duration > 0)
);
comment on column dkazanskiy_lecture_4.film_new.film_name is 'название фильма - тип данных varchar(255) и ограничение not null';
comment on column dkazanskiy_lecture_4.film_new.film_year is 'год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0';
comment on column dkazanskiy_lecture_4.film_new.film_rental_rate is 'стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99';
comment on column dkazanskiy_lecture_4.film_new.film_duration is 'длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0';

```


Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:  
· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler’s List];  
· film_year — array[1994, 1999, 1985, 1994, 1993];  
· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];  
· film_duration — array[142, 189, 116, 142, 195].
```sql
insert into dkazanskiy_lecture_4.film_new(
values (
	UNNEST(ARRAY['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']),
	UNNEST(ARRAY[1994, 1999, 1985, 1994, 1993]),
	UNNEST(array[2.99, 0.99, 1.99, 2.99, 3.99]),
	UNNEST(array[142, 189, 116, 142, 195])
	)
)
;

```


Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, что стоимость аренды всех фильмов поднялась на 1.41.
```sql
update dkazanskiy_lecture_4.film_new
set film_rental_rate = 1.41*film_rental_rate
;

```


Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом из таблицы film_new.
```sql
delete from dkazanskiy_lecture_4.film_new f
where 		f.film_name in ('Back to the Future')
;

```


Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.
```sql
insert into dkazanskiy_lecture_4.film_new(
values ('some one bla-bla', '2200', 18.99, 34)
)
;

```


Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую вычисляемую колонку «длительность фильма в часах», округлённую до десятых.
```sql
select *, round(f.film_duration/60::numeric ,1) as "длительность фильма в часах"
from dkazanskiy_lecture_4.film_new f
;

```


Задание 7. Удалите таблицу film_new.
```sql
drop table if exists dkazanskiy_lecture_4.film_new
;
--drop schema if exists dkazanskiy_lecture_4 CASCADE
--;
```


**Результат домашнего задания**  
Заполните ответами шаблон для сдачи ДЗ в формате .sql.

**Критерии оценки**  
Для зачета необходимо правильно выполнить все задания из основной части.

_Преподаватель вправе предложить дополнительные задачи в рамках задания, чтобы подтвердить, что студент разобрался в теме.  
Преподаватель вправе поставить незачет без права пересдачи текущего задания, если студент прислал на проверку результат чужой работы и отказался делать дополнительное задание._