CREATE EXTENSION IF NOT EXISTS dblink;

insert into devices_used_for_logging (device, log_count, db_insert_date) 
select device, log_count, db_insert_date
from   dblink('dbname=source_db','select device, count(*) as log_count, current_date as db_insert_date
from logs group by 1')
as tbl(device text, log_count int, db_insert_date date)
ON CONFLICT(device, log_count, db_insert_date) DO NOTHING;


insert into sales_per_month (month, month_num, year, sales, db_insert_date) 
select month, month_num, year, sales, db_insert_date
from   dblink('dbname=source_db','select TO_CHAR(created_at, ''Month'') as month, 
EXTRACT(month from created_at) as month_num, 
EXTRACT(year from created_at) as year, 
count(order_id) as sales,
current_date as db_insert_date
from orders 
group by 1,2,3')
as tbl1(month text, month_num int, year int, sales int, db_insert_date date)
ON CONFLICT(month, month_num, year, sales, db_insert_date) DO NOTHING;

insert into popular_products_in_most_logged_in_country (country, product_name, product_type, count, db_insert_date) 
select country, product_name, product_type, count, db_insert_date
from   dblink('dbname=source_db','select country, product_name, product_type, count(*), current_date as db_insert_date from (
select c.country, pr.product_id, pr.name as product_name, pr.type as product_type from customer c
inner join orders o on c.customer_id = o.customer_id
inner join order_details od on od.order_id = o.order_id
inner join price_catalog pc on od.price_catalog_id = pc.price_catalog_id
inner join product pr on pc.product_id = pr.product_id
where c.country in (select country from customer where username in (select username from (
select username, count(*) from logs group by 1 order by 2 desc limit 1) q))
) q1 
group by 1,2,3 order by 2 desc')
as tbl2(country text, product_name text, product_type text, count int, db_insert_date date)
ON CONFLICT(country, product_name, product_type, count, db_insert_date) DO NOTHING;


select * from popular_products_in_most_logged_in_country

