-- ============================================================
--  ASSIGNMENT 03 — GROUP BY, HAVING & SUBQUERIES
--  Database : BikeStores
-- ============================================================


-- ============================================================
--  SECTION A — GROUP BY & AGGREGATE FUNCTIONS
-- ============================================================

-- ============================================================
--  Question 1
--  Count total number of orders placed by each customer.
--  Show customer_id and order_count.
--  Sort by order_count descending.
-- ============================================================

-- Write your query below:

Select customer_id, count(order_id) as order_count
From sales.orders
group by customer_id
order by order_count desc




-- ============================================================
--  Question 2
--  For each store find the total number of orders placed.
--  Show store_id and total_orders.
-- ============================================================

-- Write your query below:

Select store_id, count(order_id) as total_orders
From sales.orders
group by store_id




-- ============================================================
--  Question 3
--  Calculate the net revenue per order.
--  Formula : SUM( quantity * list_price * (1 - discount) )
--  Show order_id and net_revenue.
--  Sort by net_revenue descending.
--  Use sales.order_items.
-- ============================================================

-- Write your query below:

Select order_id, sum(quantity * list_price * (1 - discount)) as net_revenue
From sales.order_items
group by order_id
order by net_revenue desc




-- ============================================================
--  Question 4
--  Find the average list price of products in each category.
--  Show category_id and avg_price rounded to 2 decimal places.
--  Use production.products.
-- ============================================================

-- Write your query below:

Select category_id, round(avg(list_price), 2) as avg_price
From production.products
group by category_id




-- ============================================================
--  Question 5
--  Find total number of orders placed in each year.
--  Show order_year and total_orders.
--  Sort by order_year ascending.
--  Use sales.orders.
-- ============================================================

-- Write your query below:

Select year(order_date) as order_year, count(order_id) as total_orders
From sales.orders
group by year(order_date)
order by order_year




-- ============================================================
--  SECTION B — HAVING CLAUSE
-- ============================================================

-- ============================================================
--  Question 6
--  Find customers who placed MORE than 5 orders in total.
--  Show customer_id and order_count.
--  Use sales.orders.
-- ============================================================

-- Write your query below:

Select customer_id, count(order_id) as order_count
From sales.orders
group by customer_id
having count(order_id) > 5




-- ============================================================
--  Question 7
--  Find categories where average list price is above $1500.
--  Show category_id and avg_price.
--  Use production.products.
-- ============================================================

-- Write your query below:

Select category_id, round(avg(list_price), 2) as avg_price
From production.products
group by category_id
having avg(list_price) > 1500




-- ============================================================
--  Question 8
--  Find customers who placed at least 2 orders in year 2017.
--  Show customer_id, order_year, and order_count.
--  Use sales.orders.
-- ============================================================

-- Write your query below:

Select customer_id, year(order_date) as order_year, count(order_id) as order_count
From sales.orders
where year(order_date) = 2017
group by customer_id, year(order_date)
having count(order_id) >= 2




-- ============================================================
--  SECTION C — SUBQUERIES
-- ============================================================

-- ============================================================
--  Question 9
--  Find all orders placed by customers who live in Houston.
--  Use a subquery to get customer_ids first.
--  Show all columns from sales.orders.
--  Use sales.orders and sales.customers.
-- ============================================================

-- Write your query below:

Select *
From sales.orders
where customer_id in (
    Select customer_id
    From sales.customers
    where city = 'Houston'
)




-- ============================================================
--  Question 10
--  Find all products whose list_price is greater than
--  the average list_price of all products.
--  Show product_name and list_price.
--  Use production.products.
-- ============================================================

-- Write your query below:

Select product_name, list_price
From production.products
where list_price > (
    Select avg(list_price)
    From production.products
)




-- ============================================================
--  Question 11
--  Find all products that belong to Mountain Bikes
--  or Road Bikes category.
--  Use a subquery on production.categories.
--  Show product_name and list_price.
--  Use production.products and production.categories.
-- ============================================================

-- Write your query below:

Select product_name, list_price
From production.products
where category_id in (
    Select category_id
    From production.categories
    where category_name in ('Mountain Bikes', 'Road Bikes')
)




-- ============================================================
--  Question 12
--  Find all customers who have NEVER placed an order.
--  Show customer_id, first_name, and last_name.
--  Use sales.customers and sales.orders.
-- ============================================================

-- Write your query below:

Select customer_id, first_name, last_name
From sales.customers
where customer_id not in (
    Select customer_id
    From sales.orders
)




-- ============================================================
--  SECTION D — JOINS WITH GROUP BY
-- ============================================================

-- ============================================================
--  Question 13
--  Find total number of orders per city.
--  Show city and total_orders.
--  Sort by total_orders descending.
--  Use sales.orders and sales.customers.
-- ============================================================

-- Write your query below:

Select c.city, count(o.order_id) as total_orders
From sales.orders o
inner join sales.customers c
on o.customer_id = c.customer_id
group by c.city
order by total_orders desc




-- ============================================================
--  Question 14
--  For each staff member count how many orders they handled.
--  Show staff_name and order_count.
--  Sort by order_count descending.
--  Use sales.orders and sales.staffs.
-- ============================================================

-- Write your query below:

Select s.first_name + ' ' + s.last_name as staff_name, count(o.order_id) as order_count
From sales.orders o
inner join sales.staffs s
on o.staff_id = s.staff_id
group by s.first_name, s.last_name
order by order_count desc




-- ============================================================
--  Question 15  (BONUS)
--  Find customers who spent more than $10000 in total.
--  Show customer_name and total_spent.
--  Sort by total_spent descending.
--  Use sales.customers, sales.orders, sales.order_items.
-- ============================================================

-- Write your query below:

Select c.first_name + ' ' + c.last_name as customer_name,
       sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent
From sales.customers c
inner join sales.orders o
on c.customer_id = o.customer_id
inner join sales.order_items oi
on o.order_id = oi.order_id
group by c.first_name, c.last_name
having sum(oi.quantity * oi.list_price * (1 - oi.discount)) > 10000
order by total_spent desc