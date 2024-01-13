-- -----------Exploring Walmart sales data---------


-- Create a database
CREATE DATABASE IF NOT EXISTS salesDataWalmart;

-- Create table
CREATE TABLE IF NOT EXISTS sales (
		invoice_id VARCHAR (30) NOT NULL PRIMARY KEY,
        brach VARCHAR (5) NOT NULL,
        city  VARCHAR (30) NOT NULL,
        customer_type VARCHAR(30) NOT NULL,
		gender VARCHAR(30) NOT NULL,
		product_line VARCHAR(100) NOT NULL,
		unit_price DECIMAL(10,2) NOT NULL,
		quantity INT NOT NULL,
		tax_pct FLOAT(6,4) NOT NULL,
		total DECIMAL(12, 4) NOT NULL,
		date DATETIME NOT NULL,
		time TIME NOT NULL,
		payment VARCHAR(15) NOT NULL,
		cogs DECIMAL(10,2) NOT NULL,
		gross_margin_pct FLOAT(11,9),
		gross_income DECIMAL(12, 4),
		rating FLOAT(2, 1)
        );
-- data cleaning done by NOT NULL 

-- ------------------------------- Feature Engineering---------------------------


-- Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. 
-- This will help answer the question on which part of the day most sales are made.

SELECT
	time,
    (CASE
	   WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
       WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
       ELSE 'Evening'
    END) As Time_of_Date 
    
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR (20);
UPDATE sales
SET time_of_day = (
CASE
	   WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
       WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
       ELSE 'Evening'
    END
);


-- Add a new column named day_name that contains the extracted days of the week on which 
-- the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
-- This will help answer the question on which week of the day each branch is busiest.

SELECT 
     date,
     DAYNAME (date) AS day_name
FROM sales;
ALTER TABLE sales ADD COLUMN day_name VARCHAR (10) -- to add day_name column to sales table

UPDATE sales          -- To update a column named day_name with days
SET day_name = DAYNAME(date);


-- Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
SELECT
	date,
    MONTHNAME (date) AS month_name
FROM sales;
ALTER TABLE sales ADD COLUMN month_name VARCHAR (10)

UPDATE sales          
SET month_name = MONTHNAME(date);


-- ---------------------- Generic Question-----------------------
-- Question 1: How many unique cities does the data have?

SELECT 
DISTINCT city
FROM sales; 

-- Question 2: In which city is each branch?

SELECT 
     DISTINCT brach
FROM sales;
 
SELECT DISTINCT 
	   city, 
       brach
FROM sales;

-- -------------- Product-------------

-- Question 1: How many unique product lines does the data have? 
SELECT 
      COUNT(DISTINCT product_line) 
FROM sales;

-- Question 2: What is the most common payment method?
SELECT 
payment,
COUNT(payment) AS cnt
FROM sales
GROUP BY payment
ORDER BY cnt DESC;
 
 -- Question 3: What is the most selling product line?
 SELECT 
product_line,
COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- Question 4: What is the total revenue by month?
SELECT 
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- Question 5: What month had the largest COGS?
SELECT 
      month_name AS month,
      SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- Question 5: What product line had the largest revenue?
SELECT 
     product_line,
     SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- Question 6: What is the city with the largest revenue?
SELECT 
    brach,
    city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, brach
ORDER BY total_revenue DESC;

-- Question 7: What product line had the largest VAT?
SELECT
    product_line,
    AVG(tax_pct) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Question 8: Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales


-- Question 9: Which branch sold more products than average product sold?
SELECT
     brach,
     SUM(quantity) AS qty
	FROM sales
    GROUP BY brach
    HAVING SUM(quantity) > (SELECT AVG (quantity) FROM sales);
    
    -- question 10:What is the most common product line by gender?
    SELECT
        gender,
        product_line,
        COUNT(gender) AS total_cnt
	FROM sales
    GROUP BY gender, product_line
    ORDER BY total_cnt DESC;
    
-- Question 11: What is the average rating of each product line?
SELECT 
     ROUND (AVG(rating), 2) AS avg_rating,
     product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ------- Sale--------------
-- Question 1:Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY total_sales DESC;
    
-- Qusetion 2: Which of the customer types brings the most revenue?
SELECT 
	customer_type,
    SUM(total) AS total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;

-- Question 3: Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
     city,
     AVG(tax_pct) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT;

-- Question 4: Which customer type pays the most in VAT?
SELECT
     customer_type,
     AVG(tax_pct) AS VAT
FROM sales
GROUP BY   customer_type
ORDER BY VAT;

-- -------------- Customer--------------

-- Question 1: How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- Question 2: How many unique payment methods does the data have?
SELECT 
	DISTINCT payment
FROM sales;

-- Question 3: What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Question 4:Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


-- Question 5: What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

--  Question 6: What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE brach = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

--  Question 7: Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


--  Question 8: Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE brach = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


--  Question 9: Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



--  Question 10: Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE brach = "C"
GROUP BY day_name
ORDER BY total_sales DESC;