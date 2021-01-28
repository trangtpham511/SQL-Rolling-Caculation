/*Get number of monthly active customers.
Active users in the previous month.
Percentage change in the number of active customers.
Retained customers every month.*/
use sakila;
drop view if exists customer_activity; 
create or replace view customer_activity as
select customer_id, convert(rental_date, date) as Activity_date,
date_format(convert(rental_date,date), '%M') as Activity_Month,
date_format(convert(rental_date,date), '%m') as Activity_Month_number,
date_format(convert(rental_date,date), '%Y') as Activity_year
from sakila.rental;
select * from customer_activity;

create or replace view monthly_active_customer as
select count(distinct ca.customer_id) as total_active_cus, Activity_Month, Activity_Month_number from customer_activity ca
join customer c
on ca.customer_id = c.customer_id
where active ='1'
group by Activity_Month_number;
select * from monthly_active_customer;
-- 2 
select 
   Activity_month, Activity_Month_number,
   total_active_cus, 
   lag(total_active_cus,1) over (order by total_active_cus) as Last_month
from monthly_active_customer
order by Activity_Month_number;
-- 3 Percentage change in the number of active customers.
select 
   Activity_month, Activity_Month_number,
   total_active_cus, 
   lag(total_active_cus,1) over (order by total_active_cus) as Last_month,
   round((total_active_cus - lag(total_active_cus,1) over (order by total_active_cus))/total_active_cus*100,2)as percentage_change
from monthly_active_customer;
-- 4 Retained customers every month.*/
use sakila;
select distinct customer_id as customer_id, Activity_month, Activity_month_number from customer_activity;
create or replace view distinct_customers as
select distinct customer_id as customer_id, Activity_month, Activity_month_number from customer_activity;
create or replace view retained_customers as 
select 
   c1.Activity_month,
   c1.Activity_month_number,
   count(distinct c1.customer_id) as Retained_customers
   from distinct_customers as c1
join distinct_customers as c2
on c1.customer_id = c2.customer_id 
and c2.Activity_month_number = c1.Activity_month_number + 1
 group by c1.Activity_month_number
order by c1.Activity_month_number;
select * from retained_customers;
