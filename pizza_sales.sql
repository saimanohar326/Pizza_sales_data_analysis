create database pizza_sales;
use pizza_sales;

create table orders (
order_id int primary key,
date text,
time text);

load data infile 'E:/MANU/sql/uploads/orders.csv'
into table orders
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

create table order_details (
order_details int primary key,
order_id int,
pizza_id text,
quantity int );

load data infile 'E:/MANU/sql/uploads/order_details.csv'
into table order_details
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

create view pizza_menu as
select p.pizza_id, p.pizza_type_id, pt.name,pt.category,p.size, p.price, pt.ingredients
from pizzas p
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id

select * from pizza_menu;

alter table orders
modify date DATE;

alter table orders
modify time TIME;

-- total revenue---
select round(sum(od.quantity * p.price),2) as Total_Revenue from order_details od
join pizza_menu p 
on p.pizza_id = od.pizza_id;

-- total number of pizzas sold ----
select sum(quantity) as Pizzas_Sold from order_details;

-- total orders --
-- select count(order_id) from orders;
select count(distinct(order_id)) as Total_Orders from order_details;

-- average order value: avg amount of money spent per order ---
select round(sum(od.quantity * p.price) / count(distinct(order_id)),2) as avg_order_value from order_details od
join pizza_menu p
on p.pizza_id = od.pizza_id;

-- average number of pizzas sold per order --
select round(sum(quantity) / count(distinct(order_id)),0) as avg_no_pizza_per_order
from order_details;

-- total revenue and number of orders per category --
select p.category,sum(od.quantity * p.price) as total_revenue, count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_menu p
on od.pizza_id = p.pizza_id
group by p.category;

-- total revenue and number of orders per size--
select p.size,sum(od.quantity * p.price) as total_revenue, count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_menu p
on od.pizza_id = p.pizza_id
group by p.size;

-- hourly,daily and monthly trend in orders and revenue of pizzas --
select case
        when hour(o.time) between 9 and 12 then 'Late Morning'
        when hour(o.time) between 12 and 15 then 'Lunch'
        when hour(o.time) between 15 and 18 then 'Mid afternoon'
        when hour(o.time) between 18 and 21 then 'Dinner'
        when hour(o.time) between 21 and 23 then 'Late Night'
        else 'others'
        end as meal_time, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o on o.order_id = od.order_id
group by meal_time
order by total_orders desc;
-- weekdays --
select dayname(o.date) as day_name, count(distinct(od.order_id)) as total_orders from order_details od
join orders o
on o.order_id = od.order_id
group by dayname(o.date)
order by total_orders desc;
-- month--
select monthname(o.date) as month_name, count(distinct(od.order_id)) as total_orders from order_details od
join orders o
on o.order_id = od.order_id
group by monthname(o.date)
order by total_orders desc;

-- most ordered pizza --
select p.name, p.size, count(od.order_id) as count_pizzas from order_details od
join pizza_menu p
on od.pizza_id = p.pizza_id
group by p.name, p.size
order by count_pizzas desc;

-- top 5 pizzas by revenue --
select p.name, sum(od.quantity * p.price) as total_revenue
from order_details od
join pizza_menu p
on od.pizza_id = p.pizza_id
group by p.name
order by total_revenue desc limit 5;

-- top 5 pizzas by sales ---
select p.name, sum(od.quantity) as pizzas_sold
from order_details od
join pizza_menu p
on od.pizza_id = p.pizza_id
group by p.name
order by pizzas_sold desc 
limit 5;

-- pizza analysis -----
select name, price from pizza_menu order by price desc limit 1;

-- top used ingredients ----
select * from pizza_menu

create temporary table numbers as (
      select 1 as n union all
      select 2 union all select 3 union all select 4 union all
	  select 5 union all select 6 union all select 7 union all
	  select 8 union all select 9 union all select 10
      );
      
select ingredient, count(ingredient) as ingredient_count
from (
      select SUBSTRING_INDEX(SUBSTRING_INDEX(ingredients, ',', n), ',' , -1) as ingredient
      from order_details
      join pizza_menu on pizza_menu.pizza_id = order_details.pizza_id
      join numbers on char_length(ingredients) - char_length(replace(ingredients, ',' , '')) >= n-1 ) as subquery
group by ingredient
order by ingredient_count desc;