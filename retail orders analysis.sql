CREATE DATABASE ccdb;

USE orders;

CREATE TABLE df_orders(
order_id INT PRIMARY KEY,
order_date date,
ship_mode VARCHAR(20),
segment VARCHAR(20),
country VARCHAR(20),
city VARCHAR(20),
state VARCHAR(20),
postal_code VARCHAR(20),
region VARCHAR(20),
category VARCHAR(20),
sub_category VARCHAR(20),
product_id VARCHAR(50),
quantity INT,
discount DECIMAL(7,2),
sale_price DECIMAL(7,2),
profit DECIMAL(7,2)
);

SELECT* FROM df_orders;

#1FIND TOP 10 HIGHEST REVENUE GENERATING PRODUCTS:
SELECT product_id, sum(sale_price) as sales
FROM df_orders
GROUP BY product_id
ORDER BY sales desc LIMIT 10;


#2 FIND TOP 5 HIGHEST SELLING PRODUCTS IN EACH REGION:
with cte as(
SELECT region,product_id,sum(sale_price)as sales
FROM df_orders
GROUP BY region,product_id)
SELECT * FROM(
SELECT *,
row_number() over(partition by region order by sales desc) as row_num
FROM cte) a
WHERE row_num<=5;


#3 FIND MONTH-OVER-MONTH GROWTH COMPARISION FOR 2022 AND 2023 SALES eg: jan 2022 vs jan 2023
with cte as(
SELECT DISTINCT year(order_date) as order_year,month(order_date) as order_month,sum(sale_price) as sales
FROM df_orders
GROUP BY YEAR(order_date),MONTH(order_date)
)
SELECT order_month
,sum(CASE WHEN order_year=2022 THEN sales ELSE 0 END) as sales_2022
,sum(CASE WHEN order_year=2023 THEN sales ELSE 0 END) as sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


#4 FOR EACH CATEGORY WHICH MONTH HAD HIGHEST SALES:
with cte as(
SELECT category,date_format(order_date,"%Y-%m")as order_year_month,sum(sale_price)as sales
FROM df_orders
GROUP BY category,order_year_month
)
SELECT* FROM(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) as rn
FROM cte) a
WHERE rn=1;

#5 WHICH SUB-CATEGORY HAD HIGHEST GROWTH IN PROFIT IN 2023 COMPARED TO 2022:
with cte as(
SELECT sub_category, year(order_date) as order_year,sum(sale_price) as sales
FROM df_orders
GROUP BY sub_category, order_year
),
cte2 as (
SELECT sub_category
,sum(CASE WHEN order_year=2022 THEN sales ELSE 0 END) as sales_2022
,sum(CASE WHEN order_year=2023 THEN sales ELSE 0 END) as sales_2023
FROM cte
GROUP BY sub_category
)
SELECT*,
((sales_2023-sales_2022)/sales_2022)*100 as growth_rate
FROM cte2
ORDER BY growth_rate DESC
LIMIT 1;


