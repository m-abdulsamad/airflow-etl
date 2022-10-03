create table if not exists customer (
	customer_id SERIAL PRIMARY KEY,
	document_number text not null unique,
	full_name text not null,
	date_of_birth date,
	username text not null,
	city text not null,
	country text not null
);

create table if not exists company (
	company_id SERIAL PRIMARY KEY,
	cuit_number text not null unique,
	name text not null 
);

create table if not exists supplier (
	supplier_id SERIAL PRIMARY KEY,
	suit_number text not null unique,
	name text not null 
);

create table if not exists product (
	product_id SERIAL PRIMARY KEY,
	upc text not null, -- unique id of the product across the globe, one product can have multiple suppliers
	type text,
	price float not null,
	name text not null,
	supplier_id int not null,
	
	unique(upc, supplier_id, price),	
	foreign key (supplier_id) references supplier(supplier_id)
);

create table if not exists price_catalog (
	price_catalog_id SERIAL PRIMARY KEY,
	company_id int not null,
	product_id int not null,
	price float not null,
	
	unique(company_id, product_id, price),
	foreign key (company_id) references company(company_id),
	foreign key (product_id) references product(product_id)
);

create table if not exists orders (
	order_id SERIAL PRIMARY KEY,
	customer_id int not null,
	created_at timestamp not null,
	
	unique(customer_id, created_at),
	foreign key (customer_id) references customer(customer_id)
);

create table if not exists order_details (
	id SERIAL PRIMARY KEY,
	order_id int not null,
	price_catalog_id int not null,
	
	unique(order_id, price_catalog_id),
	foreign key (order_id) references orders(order_id),
	foreign key (price_catalog_id) references price_catalog(price_catalog_id)
);

create table if not exists logs (
	id SERIAL PRIMARY KEY,
	ip text not null,
	username text not null,
	time timestamp not null,
	device text not null,
	user_agent text not null
);