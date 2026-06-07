-- ============================================================
--   ASSIGNMENT 05 — INDEXES, VIEWS & WINDOW FUNCTIONS
--   Database  : BikeStores
--   Topics    : Indexes (Clustered & Non-Clustered)
--               Views
--               ROW_NUMBER / RANK / DENSE_RANK
--               LAG / LEAD
--               COALESCE
-- ============================================================


-- ============================================================
--  SECTION A — INDEXES
-- ============================================================

-- Q1.
-- The marketing team frequently runs campaigns filtered by brand.
-- They search products like this:
--
--   SELECT product_id, product_name, list_price
--   FROM production.products
--   WHERE brand_id = 3;
--
-- This query is slow. Create an appropriate index to fix it.
-- Then run the query to confirm it returns results correctly.

Create nonclustered index brand_ind1x on production.products (brand_id)

Select product_id,  product_name, List_price
From production.products
where brand_id = 3

-- Q2.
-- The finance team runs a monthly report that filters orders
-- by a date range, for example:
--
--   SELECT order_id, customer_id, order_date
--   FROM sales.orders
--   WHERE order_date BETWEEN '2018-01-01' AND '2018-06-30';
--
-- Create an index to make this query more efficient.

Create nonclustered index date_indx on sales.orders(order_date)

select order_id, customer_id, order_date
From sales.orders
where order_date between '2018-01-01' And '2018-06-30'



-- ============================================================
--  SECTION B — VIEWS
-- ============================================================

-- Q3.
-- The customer support team needs a daily list of all
-- pending and processing orders so they can follow up.
-- Create a view that shows:
--   order_id, customer full name, phone, email,
--   order_date, and order status as a readable label
--   (not a number — use 1=Pending, 2=Processing).
-- After creating it, query the view to see today's workload.

create view order_detail
as
	Select order_id, first_name+'_'+last_name as full_name, phone , email, o.order_date , 

	case when o.order_status = 1 then 'pending'
		when o.order_status = 2 then'processing'

		end sts
		From sales.customers c
		inner join sales.orders o
		on c.customer_id = o.customer_id
		where o.order_status in (1,2)

Select * from order_detail


		

	


-- Q4.
-- The inventory manager wants a single view to monitor stock
-- across all stores without writing complex joins every time.
-- Create a view that shows:
--   store_name, product_name, brand_name, category_name, quantity
-- After creating it, query the view to find all products
-- that have fewer than 3 units remaining in any store.

create view stock_monitor 
as
	Select s.store_name , st.quantity, p.product_name , b.brand_name, c.category_name
	From sales.stores s
	left join production.stocks st
	on s.store_id = st.store_id
	inner join production.products p
	on st.product_id = p.product_id
	left join production.brands b
	on  p.brand_id = b.brand_id
	left join production.categories c
	on p.category_id = c.category_id



select  * from stock_monitor
where quantity <=3


-- ============================================================
--  SECTION C — ROW_NUMBER, RANK & DENSE_RANK
-- ============================================================

-- Q5.
-- The sales director wants to see the top 2 best-selling products
-- per store based on total quantity sold.
-- Show store_id, product_id, total_quantity, and their rank within the store.
-- Return only rank 1 and rank 2 for each store.

with store_total as(

	Select o.store_id, oi.product_id ,  sum(oi.quantity) as product_count 

	From sales.orders o
	inner join sales.order_items oi
	on o.order_id = oi.order_id
	group by o.store_id, oi.product_id ),

ranked as (
	 Select store_id, product_id ,   product_count ,
	 Rank () over (partition by store_id order by product_count desc) as rn
	 From store_total )

Select store_id, product_id, product_count ,rn
from ranked
where rn<=2
order by store_id
	 






-- Q6.
-- The pricing team wants to find the 2nd most expensive product
-- in each category.
-- Show category_id, product_name, list_price, and their price rank
-- within the category.
-- Return only the products ranked 2nd in their category.
select * from (
	Select  category_id, product_name, list_price,
	Dense_rank () over(partition by category_id order by list_price desc) as rn
	From production.products ) as ranked
	where rn = 2


-- Q7.
-- The data team suspects there are duplicate customer records.
-- Use the test table below (already has duplicates built in).
-- Write a query to identify the duplicate rows
-- (same first_name, last_name, and phone).
-- Return only the duplicates — not the original/first occurrence.
--
-- Run this setup first:
--
 CREATE TABLE test_customers (
     customer_id  INT,
     first_name   VARCHAR(50),
     last_name    VARCHAR(50),
     phone        VARCHAR(20),
     city         VARCHAR(50)
 );
--
 INSERT INTO test_customers VALUES
     (1,  'Ali',    'Khan',    '0300-1111111', 'Karachi'),
     (2,  'Sara',   'Ahmed',   '0321-2222222', 'Lahore'),
     (3,  'Ali',    'Khan',    '0300-1111111', 'Karachi'),   -- duplicate of 1
     (4,  'Usman',  'Malik',   '0333-3333333', 'Islamabad'),
     (5,  'Sara',   'Ahmed',   '0321-2222222', 'Lahore'),   -- duplicate of 2
     (6,  'Sara',   'Ahmed',   '0321-2222222', 'Lahore'),   -- 3rd copy of 2
     (7,  'Hina',   'Raza',    '0312-4444444', 'Peshawar');

-- Now write your query to find the duplicate rows.
Select * from (
	Select customer_id,first_name, last_name, phone , 
		ROW_NUMBER () over (partition by first_name, last_name, phone order by customer_id ) as rw
	From test_customers
) as dp
where rw >=2
order by rw


-- ============================================================
--  SECTION D — LAG, LEAD & COALESCE
-- ============================================================

-- Q8.
-- The finance team wants a month-by-month revenue report for 2017.
-- For each month, show total net sales and how much it grew or
-- dropped compared to the previous month.
-- Show month, net_sales, previous_month_sales, and the difference.
-- Net sales = SUM( quantity * list_price * (1 - discount) )


select 
	months, net_sales,
	lag(net_sales,1) over (order by months) as previous_month_sales,
	net_Sales-lag(net_sales,1) over (order by months) as diffrence

	
	from (
		Select month(o.order_date) as months, sum(oi.quantity * oi.list_price * (1 - oi.discount)) as net_Sales
		from sales.orders o
		inner join sales.order_items oi
		on o.order_id = oi.order_id  
		where year(order_date) = '2017'
		group by month(order_date )) as result



 

-- Q9.
-- The product team wants to see each product's price compared to
-- the next cheaper product in the same category.
-- Show product_name, list_price, and the next lower price
-- in the same category.
-- Sort by category_id and list_price descending.


select category_id, product_name, list_price,
	lead(list_price,1) over (partition by category_id order by list_price desc) as next_lower_price
from production.products
order by category_id, list_price desc





-- Q10.
-- The CRM team is cleaning up customer records.
-- Some customers have no phone number on file.
-- Show each customer's full name, phone, and email.
-- Replace any missing phone with their email address instead.
-- If both are missing, show 'No Contact Info'.
-- Sort by last_name, first_name.

select 
	first_name + ' ' + last_name as full_name,
    phone,
    email,
	case 
	when phone is null and email is null then 'No Contact Info'
	when  phone is null then email
	else phone
	end as new_phone
	from sales.customers
	order by last_name, first_name



-- ============================================================
--  END OF ASSIGNMENT 05
-- ============================================================
