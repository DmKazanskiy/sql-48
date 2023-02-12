# Домашнее задание по теме «Работа с PostgreSQL» (часть 1)


**Преподаватель:** Алексей Кузьмин, Николай Хащанов, Екатерина Волочаева, Александр Сумовский

Все работы мы проверяем на антиплагиат, поэтому важно выполнять их самостоятельно. Работам, которые не пройдут проверку, преподаватель поставит незачёт.

Если вы сталкиваетесь со сложностями, задавайте вопросы нашим экспертам и аспирантам, они с удовольствием вам помогут. Успехов в решении заданий!

## **Модуль 5. Домашнее задание по теме «Работа с PostgreSQL» (часть 1)**

**Цель домашнего задания:**  
закрепить навыки работы с оконными функциями, табличными выражениями и подзапросами.

**Перечень заданий**

## **Основная часть**  
Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:

-   Пронумеруйте все платежи от 1 до N по дате
-   Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
-   Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
-   Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.  
    Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.  
    Ожидаемый результат запроса: [letsdocode.ru...in/5-1.png](https://letsdocode.ru/sql-main/5-1.png)
```sql
select 	payment_id, customer_id, amount, payment_date
		,row_number () 	over(partition by 1 order by date(payment_date) asc) as pmnt_date_inc
		,row_number () 	over(partition by customer_id order by date(payment_date) asc) as pmnt_date_customer
		,row_number () 	over(partition by customer_id order by date(payment_date) asc) as pmnt_date_customer
		,sum(amount) 	over(partition by customer_id order by date(payment_date) asc, amount asc) as pmnt_total_customer
		,dense_rank () 	over(partition by customer_id order by amount desc) as pmnt_amount_rank_customer
from payment p
;

```

Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.  
Ожидаемый результат запроса: [letsdocode.ru...in/5-2.png](https://letsdocode.ru/sql-main/5-2.png)
```sql
select 	customer_id
		,coalesce (lag(amount,1) over(partition by customer_id order by date(payment_date)),0.00) as amount_before
		,amount
		,date(payment_date)
from payment p
;

```

Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.  
Ожидаемый результат запроса: [letsdocode.ru...in/5-3.png](https://letsdocode.ru/sql-main/5-3.png)
```sql
with t as (
select 	customer_id
		,payment_date
		,amount
		,lead(amount,1) over(partition by customer_id order by date(payment_date)) as nextp
		,-amount + lead(amount,1) over(partition by customer_id order by date(payment_date)) as compr
		,date(payment_date)
from payment p
)
select 	customer_id
		,date(payment_date)
		,amount
		,nextp
		,case 
			when nextp is null then 'нет платежа'
			when compr > 0 then 'больше на'
			when compr < 0 then 'меньше на'
			else '-'
		end as "следующий платеж"
		,compr
from t
;

```

Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.  
Ожидаемый результат запроса: [letsdocode.ru...in/5-4.png](https://letsdocode.ru/sql-main/5-4.png)
```sql
select r.customer_id, r.payment_id, r.payment_date, r.amount
from (
select 	customer_id, payment_id, payment_date, amount
		,first_value (payment_date) over (partition by customer_id order by payment_date desc) as pmnt_date_customer
		,row_number () over (partition by customer_id order by date(payment_date) desc) as rownum
from payment p
) as r
where rownum = 1
;

```

## **Дополнительная часть**

Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.  
Ожидаемый результат запроса: [letsdocode.ru...in/5-5.png](https://letsdocode.ru/sql-main/5-5.png)
```sql
select *
		,sum(sum_dt) over(partition by staff_id order by dt asc) as sum_dt_total
from (
	select 	staff_id, date(payment_date) dt, sum(amount) sum_dt
	from (
		select *
		from payment p 
		where date_trunc('month',payment_date) = date('2005-08-01 00:00:00.000')
	) aug
	group by staff_id, dt
) staff_aug
;

```

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.  
Ожидаемый результат запроса: [letsdocode.ru...in/5-6.png](https://letsdocode.ru/sql-main/5-6.png)
```sql
select *
	from (
		select customer_id , payment_date
				,row_number () 	over(partition by date(payment_date) order by payment_date asc) as pmnt_number
		from payment p 
		where date(payment_date) = date('2005-08-20 00:00:00.000')
	) as aug20
where pmnt_number%100 = 0
;
```

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:  
· покупатель, арендовавший наибольшее количество фильмов;  
· покупатель, арендовавший фильмов на самую большую сумму;  
· покупатель, который последним арендовал фильм.  
Ожидаемый результат запроса: [letsdocode.ru...in/5-7.png](https://letsdocode.ru/sql-main/5-7.png)
```sql

```

**Результат домашнего задания**  
Заполните ответами шаблон для сдачи ДЗ в формате .sql.

**Критерии оценки**  
Для зачета необходимо правильно выполнить все задания из основной части.

_Преподаватель вправе предложить дополнительные задачи в рамках задания, чтобы подтвердить, что студент разобрался в теме.  
Преподаватель вправе поставить незачет без права пересдачи текущего задания, если студент прислал на проверку результат чужой работы и отказался делать дополнительное задание._