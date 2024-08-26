-- FIRSTLY I HAVE CREATED THE ALL TABELS AND LOAD THE DATA INTO EACH OF THEM

CREATE TABLE Pizzas (
    pizza_id VARCHAR(50) ,
    pizza_type_id VARCHAR(50),
    size VARCHAR(10),
    price FLOAT
);

copy Pizzas from 'C:\Program Files\PostgreSQL\16\Pizza Database files\pizzas.csv' DELIMITER ',' CSV HEADER;
select * from Pizzas;

CREATE TABLE Pizza_types ( 
    pizza_type_id VARCHAR(50),
	name VARCHAR(50),
    category VARCHAR(50),
    ingredients VARCHAR(100)
);

copy Pizza_types from 'C:\Program Files\PostgreSQL\16\Pizza Database files\pizza_types.csv' DELIMITER ',' CSV HEADER;
select * from Pizza_types;

Create TABLE orders (
	order_id INTEGER NOT NULL PRIMARY KEY,
	order_date DATE NOT NULL,
	order_time time NOT NULL
);

copy orders from 'C:\Program Files\PostgreSQL\16\Pizza Database files\orders.csv' DELIMITER ',' CSV HEADER;
select * from orders;

Create TABLE order_details (
	order_details_id INTEGER NOT NULL PRIMARY KEY,
	order_id INTEGER NOT NULL,
	pizza_id VARCHAR NOT NULL,
	quantity INTEGER NOT NULL
);

copy order_details from 'C:\Program Files\PostgreSQL\16\Pizza Database files\order_details.csv' DELIMITER ',' CSV HEADER;
select * from order_details;




-- QUESTIONS SOLUTIONS STARTS HERE

--1 Retrieve the total number of orders placed.

select
	count(order_id) as Total_number_of_orders
	from orders; 

--2 Calculate the total revenue generated from pizza sales.

select 
sum(order_details.quantity * pizzas.price) as Toal_Revenue_Generated
from order_details join pizzas on
pizzas.pizza_id = order_details.pizza_id;

--3 Identify the highest-priced pizza.

select 
pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

--4 Identify the most common pizza size ordered.

select 
pizzas.size, count(order_details.order_details_id) as No_of_pizza
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by No_of_pizza desc;

--5 List the top 5 most ordered pizza types along with their quantities.

select
pizza_types.name,  
sum(order_details.quantity) as quantities
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantities desc limit 5;

--6 Join the necessary tables to find the total quantity of each pizza category ordered.

select 
pizza_types.category,
sum(order_details.quantity) as quantities
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantities desc;


--7 Determine the distribution of orders by hour of the day.

SELECT
EXTRACT(HOUR FROM order_time) AS hour, count(order_id) as count
FROM orders group by hour
order by count desc;

--8 Join relevant tables to find the category-wise distribution of pizzas.

select category, count(category) from pizza_types
	group by category;

--9 Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(total_quantity),0) as avg_pizza_ordered_per_day from 
(select orders.order_date,
sum(order_details.quantity) as total_quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;

--10 Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by revenue desc limit 3;


--11 Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
(sum(order_details.quantity * pizzas.price)/ (select 
sum(order_details.quantity * pizzas.price) as Toal_Revenue_Generated
from order_details join pizzas on
pizzas.pizza_id = order_details.pizza_id)) * 100 as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue;

--12 Analyze the cumulative revenue generated over time.

select order_date, 
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id
join orders on
orders.order_id = order_details.order_id
group by orders.order_date) as sales;

--13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name, revenue from
(select category,name,revenue,
rank()over(partition by category order by revenue desc) as rn
	from
(select pizza_types.category, pizza_types.name, 
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join
pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as revenue_table) as total_revenue_rank_table 
	where rn <= 3;