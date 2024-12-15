-- A. Explore data
SELECT * FROM production.brands
SELECT * FROM production.categories
SELECT * FROM production.products
SELECT * FROM production.stocks

SELECT * FROM sales.customers
SELECT * FROM sales.order_items
SELECT * FROM sales.orders
SELECT * FROM sales.staffs
SELECT * FROM sales.stores

-- B. Questions
--1) Which bike is most expensive? What could be the motive behind pricing this bike at the high price? 
SELECT top 1
	product_name,
	list_price
FROM production.products
order by list_price desc;

--2)How many total customers does BikeStore have? 
select
	count(distinct customer_id) AS '#customer'
from sales.customers
--Would you considerpeople with order status 3 as customers substantiate your answer? 
select 
	count(distinct customer_id) AS customers_with_status_3
from sales.orders
where order_status = 3

--3)How many stores does BikeStore have? 
SELECT 
	count(store_id) AS '#stores'
FROM sales.stores

--4) What is the total price spent per order? 
SELECT
	order_id,
	sum(list_price * quantity *(1 - discount)) AS Total_Price
FROM sales.order_items
group by order_id

--5) What’s the sales/revenue per store? 
SELECT 
	s.store_name,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS Total_Revenue
FROM 
	sales.stores s JOIN sales.orders so 
ON s.store_id = so.store_id
				   JOIN sales.order_items oi 
ON so.order_id = oi.order_id
GROUP BY s.store_name;

--6) Which category is most sold? 
SELECT Top 1
	c.category_name,
	sum(oi.quantity) AS Total_sold
FROM
	production.categories c JOIN production.products p
ON c.category_id = p.category_id
							JOIN sales.order_items oi
ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY Total_sold desc

--7) Which category rejected more orders? 
SELECT TOP 1
	c.category_name, 
    COUNT(o.order_status) AS Rejected_Orders
FROM 
	production.categories c JOIN production.products p 
ON c.category_id = p.category_id
							JOIN sales.order_items oi 
ON p.product_id = oi.product_id
							JOIN sales.orders o
ON oi.order_id = o.order_id
WHERE o.order_status = 3
GROUP BY c.category_name
ORDER BY Rejected_Orders DESC;

--8) Which bike is the least sold? 
SELECT TOP 1
	p.product_name,
	sum(distinct ps.quantity) AS total_quantity
FROM 
	production.products p JOIN production.stocks ps
ON p.product_id = ps.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity ASC

--9) What’s the full name of a customer with ID 259? 
SELECT
	first_name + ' ' + last_name AS FULL_NAME 
FROM sales.customers
WHERE customer_id = 259

--10) What did the customer on question 9 buy and when? What’s the status of this order?
SELECT 
	c.first_name + ' ' + last_name AS FULL_NAME ,
    p.product_name,
    o.order_date,
    o.order_status,
    oi.quantity
FROM 
	sales.customers c INNER JOIN sales.orders o 
ON c.customer_id = o.customer_id
					  INNER JOIN sales.order_items oi 
ON o.order_id = oi.order_id
					  INNER JOIN production.products p 
ON oi.product_id = p.product_id
WHERE c.customer_id = 259
ORDER BY o.order_date

--11) Which staff processed the order of customer 259? And from which store? 
SELECT 
	s.first_name + ' '+s.last_name AS Full_Name,
    st.store_name
FROM 
	sales.orders o JOIN sales.staffs s
ON o.staff_id = s.staff_id
				   JOIN sales.stores st
ON s.store_id = st.store_id
WHERE o.customer_id = 259

--12) How many staff does BikeStore have? Who seems to be the lead Staff at BikeStore? 
SELECT 
	COUNT(staff_id) #OfStaff

FROM 
	sales.staffs
-- lead staff
SELECT * 
From sales.staffs
Where manager_id IS NULL

--13) Which brand is the most liked? 
SELECT TOP 1
	b.brand_name,
	sum(oi.quantity) AS total_quantity_sold
FROM
	production.brands b JOIN production.products p
ON b.brand_id = p.brand_id
						JOIN sales.order_items oi
ON p.product_id = oi.product_id
GROUP BY b.brand_name
ORDER BY total_quantity_sold DESC

--14) How many categories does BikeStore have, and which one is the least liked? 
--Step 1: Count the Total Number of Categories

SELECT 
	COUNT(distinct category_id) AS #ofCategories
FROM production.categories
--Step 2: Find the Least-Liked Category
SELECT 
    TOP 1 pc.category_name,
    SUM(oi.quantity) AS TotalQuantitySold
FROM 
    sales.order_items oi JOIN production.products p
ON oi.product_id = p.product_id
						 JOIN   production.categories pc
ON p.category_id = pc.category_id
GROUP BY pc.category_name
ORDER BY TotalQuantitySold ASC

-- 15) Which store still have more products of the most liked brand?

-- 16) Which state is doing better in terms of sales?
SELECT TOP 1
    st.state,
    SUM(oi.quantity * oi.list_price) AS total_revenue
FROM
	sales.stores st JOIN sales.orders o
ON st.store_id = o.store_id
					JOIN sales.order_items oi 
ON o.order_id = oi.order_id
GROUP BY st.state
ORDER BY total_revenue DESC

-- 17) What’s the discounted price of product id 259?
SELECT
	product_id,
	discount
FROM sales.order_items
WHERE product_id = 259

--18) What’s the product name, quantity, price, category, model year and brand name of product number 44?
SELECT  
	P.product_id,
	p.product_name,
	oi.quantity,
	oi.list_price AS PRICE,
	pc.category_name,
	p.model_year,
	b.brand_name
FROM 
	production.products p INNER JOIN production.brands b
ON p.brand_id = b.brand_id
						  INNER JOIN production.categories pc
ON P.category_id = PC.category_id
						  INNER JOIN sales.order_items oi
ON p.product_id = oi.product_id
WHERE P.product_id = 44

--19) What’s the zip code of CA?
SELECT 
	zip_code,
	state
FROM sales.stores
where state = 'CA'

-- 20) How many states does BikeStore operate in?
select
	COUNT(state) AS '#ofStates'
from sales.stores

-- 21) How many bikes under the children category were sold in the last 8 months?
SELECT 
    SUM(oi.quantity) AS total_bikes_sold
FROM 
	production.products p JOIN production.categories c 
ON p.category_id = c.category_id
						  JOIN sales.order_items oi 
ON p.product_id = oi.product_id
						  JOIN sales.orders o 
ON oi.order_id = o.order_id
WHERE c.category_name = 'Children Bicycles'  
AND o.order_date >= DATEADD(MONTH, -8, GETDATE()) 

-- 22) What’s the shipped date for the order from customer 523
SELECT order_id, shipped_date
FROM sales.orders
WHERE customer_id = 523;

-- 23) How many orders are still pending?
SELECT COUNT(*) AS PendingOrders
FROM sales.orders
WHERE order_status = 1;

-- 24) What’s the names of category and brand does "Electra white water 3i -2018" fall under?
SELECT 
    c.category_name,
    b.brand_name
FROM 
    production.products p JOIN production.categories c 
ON p.category_id = c.category_id
						  JOIN production.brands b 
ON p.brand_id = b.brand_id
WHERE p.product_name = 'Electra white water 3i - 2018'