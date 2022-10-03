create table if not exists devices_used_for_logging (
	id serial primary key,
	device text not null,
	log_count int not null,
	db_insert_date date not null,
	
	unique(device, log_count, db_insert_date)
);

create table if not exists sales_per_month (
	id serial primary key,
	month text not null,
	month_num int not null,
	year int not null,
	sales int not null,
	db_insert_date date not null,
	
	unique(month, month_num, year, sales, db_insert_date)
);

create table if not exists popular_products_in_most_logged_in_country (
	id serial primary key,
	country text not null,
	product_name text not null,
	product_type text not null,
	count int not null,
	db_insert_date date not null,
	
	unique(country, product_name, product_type, count, db_insert_date)
);


