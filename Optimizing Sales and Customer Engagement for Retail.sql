CREATE DATABASE optimizing_Sales_custmr_engagement;
USE optimizing_sales_custmr_engagement;
SELECT 
    *
FROM
    retail_price;
    
#QUESTIONS
#1) What is the total revenue generated for each product category?

SELECT 
    product_category_name, Round(SUM(total_price),2) AS total_revenue
FROM
    retail_price
GROUP BY product_category_name;

#2) Which products have the highest sales (quantity-wise) in the last 12 months?
SELECT 
    product_id, SUM(qty) AS total_qty
FROM
    retail_price
WHERE
    year = '2018'
GROUP BY product_id
ORDER BY total_qty;

#3) How do sales differ between holidays and non-holidays?
SELECT 
    holiday,
    SUM(qty) AS total_qty,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM
    retail_price
GROUP BY holiday
ORDER BY holiday ASC;

#4) What is the average number of customers visiting on weekends versus weekdays?

SELECT 
    AVG(CASE 
            WHEN DAYOFWEEK(STR_TO_DATE(month_year, '%d-%m-%Y')) IN (2, 3, 4, 5, 6) 
            THEN customers 
            ELSE NULL 
        END) AS avg_weekday_customers,
    AVG(CASE 
            WHEN DAYOFWEEK(STR_TO_DATE(month_year, '%d-%m-%Y')) IN (1, 7) 
            THEN customers 
            ELSE NULL 
        END) AS avg_weekend_customers
FROM 
    retail_price;
    
#5) Which month generates the most revenue across all years?

SELECT 
    month, ROUND(SUM(total_price), 2) AS total_revenue
FROM
    retail_price
GROUP BY month
ORDER BY total_revenue DESC;

#6) Which products have the highest average freight price, and how does it affect sales?

SELECT 
    product_id, 
    Round(AVG(freight_price),2) AS avg_freight_price, 
    Round(AVG(total_price / qty),2) AS avg_price_per_unit, 
    Round(SUM(total_price),2) AS total_revenue 
FROM 
    retail_price 
GROUP BY 
    product_id 
ORDER BY 
    avg_freight_price DESC;

#7) What is the profit margin for each product category?
SELECT 
    product_category_name,
    round(avg(unit_price - freight_price),2) AS avg_profit_margin
FROM
    retail_price
GROUP BY product_category_name;

#8) Which products fail to meet a minimum sales threshold of 5 units in at least one month?
SELECT 
    product_id, COUNT(DISTINCT month) AS months_below_threshold
FROM
    retail_price
WHERE
    qty < 5
GROUP BY product_id
HAVING months_below_threshold > 0;


#9) What is the standard deviation of unit prices for each product, and how consistent are the prices?

SELECT 
    product_category_name,
    ROUND(STDDEV(unit_price), 2) AS price_variation
FROM
    retail_price
GROUP BY product_category_name;

#10) How does the lag price affect sales quantity for each product?
SELECT 
    product_id,
    Round(AVG(lag_price - unit_price),2) AS avg_discount,
    SUM(qty) AS total_qty
FROM
    retail_price
GROUP BY product_id;

#11) Create a time-series analysis of customer visits by month.
SELECT 
    month_year, SUM(customers) AS total_customers
FROM
    retail_price
GROUP BY month_year
ORDER BY month_year;

#12) Rank products by revenue within each category.

SELECT 
    product_category_name, product_id, RANK() OVER(PARTITION BY product_category_name ORDER BY SUM(total_price) DESC) AS revenue_rank
FROM
    retail_price
GROUP BY product_category_name , product_id;

#13) Compare average sales quantity per product across all categories.
SELECT 
    product_category_name, AVG(qty) AS avg_qty
FROM
    retail_price
GROUP BY product_category_name;

#14) How does each category's product weight correlate with total revenue?

SELECT 
    product_category_name,
    AVG(product_weight_g) AS avg_weight,
    SUM(total_price) AS total_revenue
FROM
    retail_price
    GROUP BY product_category_name;
    
#15) Analyze freight costs for products with high weights.
SELECT 
    product_id, product_weight_g, freight_price
FROM
    retail_price
WHERE
    product_weight_g > 1000
ORDER BY freight_price DESC;

#16)  Determine how product volume correlates with sales revenue.
SELECT 
    product_id,
    AVG(volume) AS avg_volume,
    ROUND(SUM(total_price), 2) AS total_revenue
FROM
    retail_price
GROUP BY product_id;

#17) Calculate revenue per unit freight cost for each product.
SELECT 
    product_id,
    ROUND(SUM(total_price) / SUM(freight_price), 2) AS revenue_per_freight_cost
FROM
    retail_price
GROUP BY product_id;

#18) Create a trigger to alert if freight price exceeds unit price.
DELIMITER //

CREATE TRIGGER check_freight_price 
BEFORE INSERT ON retail_price
FOR EACH ROW
BEGIN
    IF NEW.freight_price > NEW.unit_price THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Freight price cannot exceed unit price';
    END IF;
END;

//

DELIMITER ;

#19) Write a procedure to generate a monthly sales report for a given year.

DELIMITER //

CREATE PROCEDURE MonthlySalesReport1(IN report_year INT)
BEGIN
    SELECT 
        month, 
        SUM(total_price) AS total_revenue
    FROM 
        retail_price
    WHERE 
        year = report_year
    GROUP BY 
        month;
END;
//

DELIMITER ;


CALL MonthlySalesReport1(2017);

#20) Write a procedure to query top products dynamically based on a given limit.

DELIMITER //

CREATE PROCEDURE Top_quality_products(IN limit_num INT)
BEGIN
    SELECT 
        product_category_name, 
        SUM(total_price) AS total_revenue
    FROM 
        retail_price
    GROUP BY 
        product_category_name
    ORDER BY 
        total_revenue DESC
    LIMIT limit_num;
END;
//

DELIMITER ;

#21) Calculate the difference between lag price and unit price for each category.

SELECT 
    product_category_name,
    ROUND(AVG(lag_price - unit_price), 2) AS avg_lag_diff
FROM
    retail_price
GROUP BY product_category_name;


#22) Determine the price point with the highest revenue for each product.

SELECT 
    product_id,
    unit_price,
    ROUND(SUM(total_price),2) AS total_revenue
FROM
    retail_price
GROUP BY product_id , unit_price
ORDER BY total_revenue DESC;

#23)  Group sales based on freight cost ranges.

SELECT 
    CASE
        WHEN freight_price < 10 THEN 'Low'
        WHEN freight_price BETWEEN 10 AND 20 THEN 'Medium'
        ELSE 'High'
    END AS freight_range,
    SUM(total_price) AS total_revenue
FROM
    retail_price
GROUP BY freight_range;

#24) Calculate moving average of sales for each product.

SELECT 
    product_id, 
    month_year, 
    ROUND(AVG(total_price) OVER (
        PARTITION BY product_id 
        ORDER BY month_year 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg
FROM 
    retail_price;





