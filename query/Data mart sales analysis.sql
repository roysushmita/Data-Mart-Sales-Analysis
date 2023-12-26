/*In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
•Convert the week_date to a DATE format
•Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
•Add a month_number with the calendar month for each week_date value as the 3rd column
•Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
•Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
•Add a new demographic column using the following mapping for the first letter in the segment values:
•Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
•Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
*/


--Creating table:
CREATE TABLE clean_weekly_sales(
	week_date DATE,
	week_number INTEGER,
	month_number INTEGER,
	calendar_year INTEGER,
	region VARCHAR(15),
	platform VARCHAR(10),
	segment VARCHAR(15),
	age_band VARCHAR(20) not null,
	demographic VARCHAR(20) not null,
	customer_type VARCHAR(10),
	transactions INTEGER,
	sales INTEGER,
	avg_transaction float
)
--inserting values in the columns of clean_weekly_sales

INSERT INTO clean_weekly_sales(week_date,week_number,month_number, calendar_year,region,platform,segment,
							  age_band,demographic,customer_type,transactions,sales,avg_transaction)
SELECT TO_DATE(week_date, 'DD/MM/YY') as week_date,
	   DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) as week_number,
  	   DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) as month_number,
       DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) as calendar_year,
	   region, platform, 
	   CASE WHEN segment='null' THEN 'unknown' ELSE segment END AS segment,
	   CASE WHEN right(segment,1) = '1' THEN 'Young Adults'
            WHEN right(segment,1) = '2' THEN 'Middle Aged'
            WHEN right(segment,1) in ('3','4') THEN 'Retirees'
            ELSE 'unknown' END as age_band,
	 CASE WHEN left(segment,1) = 'C' THEN 'Couples'
    	  WHEN left(segment,1) = 'F' THEN 'Families'
    	  ELSE 'unknown' END as demographic,
     customer_type,transactions,sales,
	 ROUND((sales/transactions),2) as avg_transaction
FROM weekly_sales;

--1. What day of the week is used for each week_date value?
SELECT DISTINCT(to_char(week_date,'day'))
AS week_day
FROM clean_weekly_sales;

--2. What range of week numbers are missing from the dataset?
WITH week_number_cte AS (SELECT GENERATE_SERIES(1,52) AS week_number)
SELECT DISTINCT cte.week_number
FROM week_number_cte cte
LEFT OUTER JOIN
clean_weekly_sales csw
ON cte.week_number = csw.week_number
WHERE csw.week_number IS NULL;

--3. How many total transactions were there for each year in the dataset?
SELECT calendar_year,SUM(transactions) as total_transaction
FROM clean_weekly_sales
GROUP BY calendar_year;

--4. What is the total sales for each region for each month?
SELECT region,month_number,SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,month_number
ORDER BY region,month_number;

--5. What is the total count of transactions for each platform
SELECT platform,SUM(transactions) AS total_count_transaction
FROM clean_weekly_sales
GROUP BY platform;

--6. What is the percentage of sales for Retail vs Shopify for each month
WITH transaction_cte AS (SELECT calendar_year,month_number,platform,SUM(sales) AS monthly_plat_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number,
ROUND(100.0 * SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS retail_percentage,
100-ROUND(100.0 *  SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS shopify_percentage
FROM transaction_cte
GROUP BY calendar_year,month_number;

'''[OR]'''

WITH temp_cte AS (SELECT calendar_year, month_number, platform,SUM(sales) AS monthly_plat_sales
				  FROM clean_weekly_sales GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number, platform,
ROUND(100 * (monthly_plat_sales/ SUM(monthly_plat_sales) OVER(PARTITION BY calendar_year, month_number)),2) 
AS sale_percentage
FROM temp_cte;
	  
--7. What is the percentage of sales by demographic for each year in the dataset?
WITH transaction_cte AS (SELECT calendar_year, demographic,SUM(sales) AS yearly_demo_sales
FROM clean_weekly_sales
GROUP BY calendar_year, demographic)
SELECT calendar_year,
ROUND(100.0 * SUM (CASE WHEN demographic = 'Families' THEN yearly_demo_sales END)/SUM(yearly_demo_sales),2)
AS family_percentage,
ROUND(100.0 * SUM (CASE WHEN demographic = 'Couples' THEN yearly_demo_sales END)/SUM(yearly_demo_sales),2)
AS couple_percentage,
ROUND(100.0 * SUM (CASE WHEN demographic = 'unknown' THEN yearly_demo_sales END)/SUM(yearly_demo_sales),2) 
AS unknown_percentage
FROM transaction_cte
GROUP BY calendar_year;

'''[or]'''

WITH temp_cte as (SELECT calendar_year,demographic,
				 SUM(sales) as yearly_demo_sale
				 FROM clean_weekly_sales GROUP BY calendar_year,demographic)
SELECT calendar_year,demographic,
ROUND(100.0* yearly_demo_sale/ SUM(yearly_demo_sale) OVER(PARTITION BY calendar_year),2) percentage_sale
FROM temp_cte ORDER BY calendar_year,demographic;

--8. Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band,demographic,SUM(sales) AS retail_contribution,
ROUND(100.0 * SUM(sales)/SUM(SUM(sales)) OVER(),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band,demographic
ORDER BY retail_contribution DESC;

--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT calendar_year,platform,round(SUM(sales)/SUM(transactions),2) correct_avg_size, 
round(AVG(avg_transaction)::NUMERIC,2) incorrect_avg_size
FROM clean_weekly_sales 
GROUP BY calendar_year,platform ORDER BY calendar_year;

'''
3. Before & After Analysis
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable
packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change
and the previous week_date values would be before
'''
SELECT DISTINCT(DATE_PART('week',week_date)) as week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';
-------------------------------------------------------------------------------------------------------------------------------------------------
--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 21 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;


--2. What about the entire 12 weeks before and after?
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 13 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;

--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 21 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;


WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;

/*
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

region
platform
age_band
demographic
customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
*/
--Impact on region
WITH temp_cte AS (SELECT region,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY region)
SELECT region,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on platform
WITH temp_cte AS (SELECT platform,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY platform)
SELECT platform,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on age_band
WITH temp_cte AS (SELECT age_band,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY age_band)
SELECT age_band,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on demographic
WITH temp_cte AS (SELECT demographic,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY demographic)
SELECT demographic,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on customer_type
WITH temp_cte AS (SELECT customer_type,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY customer_type)
SELECT customer_type,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;