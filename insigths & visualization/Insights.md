
### 1. Data Cleaning Steps
In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

•Convert the week_date to a DATE format

•Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

•Add a month_number with the calendar month for each week_date value as the 3rd column

•Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

•Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

![image](https://github.com/roysushmita/8-weeks-SQL-challenge/assets/129031314/6b017e86-bfbe-4925-be98-9166f5dbcc12)


•Add a new demographic column using the following mapping for the first letter in the segment values:

![image](https://github.com/roysushmita/8-weeks-SQL-challenge/assets/129031314/4549a55d-59b0-4595-b2e5-d0bcbc4f067e)


•Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

•Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

Check the Data cleaning [here](https://github.com/roysushmita/8-weeks-SQL-challenge/blob/main/Case%20study%235/SQL%20query/Data%20cleaning-CS5.sql)

--Creating table:
```
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
```
--inserting values in the columns of clean_weekly_sales

```
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
```

```
SELECT * FROM clean_weekly_sales
```
First 10 rows are given below.

| week_date   | week_number | month_number | calendar_year | region  | platform | segment | age_band      | demographic | customer_type | transactions | sales    | avg_transaction |
|-------------|-------------|--------------|----------------|---------|----------|---------|---------------|-------------|----------------|--------------|----------|------------------|
| 2020-08-31  | 36          | 8            | 2020           | ASIA    | Retail   | C3      | Retirees       | Couples     | New            | 120631       | 3656163  | 30               |
| 2020-08-31  | 36          | 8            | 2020           | ASIA    | Retail   | F1      | Young Adults   | Families    | New            | 31574        | 996575   | 31               |
| 2020-08-31  | 36          | 8            | 2020           | USA     | Retail   | unknown | unknown        | unknown     | Guest          | 529151       | 16509610 | 31               |
| 2020-08-31  | 36          | 8            | 2020           | EUROPE  | Retail   | C1      | Young Adults   | Couples     | New            | 4517         | 141942   | 31               |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Retail   | C2      | Middle Aged    | Couples     | New            | 58046        | 1758388  | 30               |
| 2020-08-31  | 36          | 8            | 2020           | CANADA  | Shopify  | F2      | Middle Aged    | Families    | Existing       | 1336         | 243878   | 182              |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Shopify  | F3      | Retirees       | Families    | Existing       | 2514         | 519502   | 206              |
| 2020-08-31  | 36          | 8            | 2020           | ASIA    | Shopify  | F1      | Young Adults   | Families    | Existing       | 2158         | 371417   | 172              |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Shopify  | F2      | Middle Aged    | Families    | New            | 318          | 49557    | 155              |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Retail   | C3      | Retirees       | Couples     | New            | 111032       | 3888162  | 35               |

##

### 2. Data Exploration

Check Data exploration [Here](https://github.com/roysushmita/8-weeks-SQL-challenge/blob/main/Case%20study%235/SQL%20query/Data%20exploration-CS5.sql)

**1. What day of the week is used for each week_date value?**
```
SELECT DISTINCT(to_char(week_date,'day'))
AS week_day
FROM clean_weekly_sales;
```
| week_day |
|----------|
| Monday   |

So, the day of the week is used for each week_date value is "Monday".

**2. What range of week numbers are missing from the dataset?**
```
WITH week_number_cte AS (SELECT GENERATE_SERIES(1,52) AS week_number)
SELECT DISTINCT cte.week_number
FROM week_number_cte cte
LEFT OUTER JOIN
clean_weekly_sales csw
ON cte.week_number = csw.week_number
WHERE csw.week_number IS NULL;
```
| week_number |
|-------------|
| 1           |
| 2           |
| 3           |
| 4           |
| 5           |
| 6           |
| 7           |
| 8           |
| 9           |
| 10          |
| 11          |
| 12          |
| 37          |
| 38          |
| 39          |
| 40          |
| 41          |
| 42          |
| 43          |
| 44          |
| 45          |
| 46          |
| 47          |
| 48          |
| 49          |
| 50          |
| 51          |
| 52          |

A total of 28 weeks are missing from the dataset.

**3. How many total transactions were there for each year in the dataset?**
```
SELECT calendar_year,SUM(transactions) as total_transaction
FROM clean_weekly_sales
GROUP BY calendar_year;
```
| calendar_year | total_transaction       |
|------|-------------|
| 2018 | 346406460 |
| 2019 | 365639285 |
| 2020 | 375813651 |

Total transactions for 2018 was $346,406,460, followed by $365,639,285 in 2019 and finally $375,813,651 in 2020. This showed consistent growth in transaction numbers over the years.

**4. What is the total sales for each region for each month?**
```
SELECT region,month_number,SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,month_number
ORDER BY region,month_number;
```
| region | month_number | total_sales |
|--------|--------------|-------------|
| AFRICA | 3            | 567767480   |
| AFRICA | 4            | 1911783504  |
| AFRICA | 5            | 1647244738  |
| AFRICA | 6            | 1767559760  |
| AFRICA | 7            | 1960219710  |
| AFRICA | 8            | 1809596890  |
| AFRICA | 9            | 276320987   |
| ASIA   | 3            | 529770793   |
| ASIA   | 4            | 1804628707  |
| ASIA   | 5            | 1526285399  |
| ASIA   | 6            | 1619482889  |
| ASIA   | 7            | 1768844756  |
| ASIA   | 8            | 1663320609  |
| ASIA   | 9            | 252836807   |
| CANADA | 3            | 144634329   |
| CANADA | 4            | 484552594   |
| CANADA | 5            | 412378365   |
| CANADA | 6            | 443846698   |
| CANADA | 7            | 477134947   |
| CANADA | 8            | 447073019   |
| CANADA | 9            | 69067959    |
| EUROPE | 3            | 35337093    |

24 records are added above.

**5. What is the total count of transactions for each platform?**
```
SELECT platform,SUM(transactions) AS total_count_transaction
FROM clean_weekly_sales
GROUP BY platform;
```
| platform  | total_count_transaction |
|-----------|--------------------------|
| Shopify   | 5925169               |
| Retail    | 1081934227           |

Retail is significantly out performing Shopify by a total transaction count of 1,080,1934,227, where the count for shopify is 5,925,169.

**6. What is the percentage of sales for Retail vs Shopify for each month?**
```
WITH transaction_cte AS (SELECT calendar_year,month_number,platform,SUM(sales) AS monthly_plat_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number,
ROUND(100.0 * SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS retail_percentage,
100-ROUND(100.0 *  SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS shopify_percentage
FROM transaction_cte
GROUP BY calendar_year,month_number;
```
| calendar_year | month_number | retail_percentage | shopify_percentage |
|---------------|--------------|---------------------|----------------------|
| 2018          | 3            | 97.92               | 2.08                 |
| 2018          | 4            | 97.93               | 2.07                 |
| 2018          | 5            | 97.73               | 2.27                 |
| 2018          | 6            | 97.76               | 2.24                 |
| 2018          | 7            | 97.75               | 2.25                 |
| 2018          | 8            | 97.71               | 2.29                 |
| 2018          | 9            | 97.68               | 2.32                 |
| 2019          | 3            | 97.71               | 2.29                 |
| 2019          | 4            | 97.80               | 2.20                 |
| 2019          | 5            | 97.52               | 2.48                 |
| 2019          | 6            | 97.42               | 2.58                 |
| 2019          | 7            | 97.35               | 2.65                 |
| 2019          | 8            | 97.21               | 2.79                 |
| 2019          | 9            | 97.09               | 2.91                 |
| 2020          | 3            | 97.30               | 2.70                 |
| 2020          | 4            | 96.96               | 3.04                 |
| 2020          | 5            | 96.71               | 3.29                 |
| 2020          | 6            | 96.80               | 3.20                 |
| 2020          | 7            | 96.67               | 3.33                 |
| 2020          | 8            | 96.51               | 3.49                 |

The analysis of sales percentage for Retail vs. Shopify by month and year demonstrates that Retail consistently dominates the sales share in each period. Although the of sales percentage increased for Shopify slightly in the year of 2020, it still couldn't dominate the Retail's sales percentage.

*another way*

```
WITH temp_cte AS (SELECT calendar_year, month_number, platform,SUM(sales) AS monthly_plat_sales
				  FROM clean_weekly_sales GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number, platform,
ROUND(100 * (monthly_plat_sales/ SUM(monthly_plat_sales) OVER(PARTITION BY calendar_year, month_number)),2) 
AS sale_percentage
FROM temp_cte;
```
| calendar_year | month_number | platform | sale_percentage |
|---------------|--------------|----------|------------------|
| 2018          | 3            | Shopify  | 2.08             |
| 2018          | 3            | Retail   | 97.92            |
| 2018          | 4            | Shopify  | 2.07             |
| 2018          | 4            | Retail   | 97.93            |
| 2018          | 5            | Shopify  | 2.27             |
| 2018          | 5            | Retail   | 97.73            |
| 2018          | 6            | Retail   | 97.76            |
| 2018          | 6            | Shopify  | 2.24             |
| 2018          | 7            | Shopify  | 2.25             |
| 2018          | 7            | Retail   | 97.75            |
| 2018          | 8            | Shopify  | 2.29             |
| 2018          | 8            | Retail   | 97.71            |
| 2018          | 9            | Retail   | 97.68            |
| 2018          | 9            | Shopify  | 2.32             |
| 2019          | 3            | Shopify  | 2.29             |
| 2019          | 3            | Retail   | 97.71            |
| 2019          | 4            | Shopify  | 2.20             |
| 2019          | 4            | Retail   | 97.80            |
| 2019          | 5            | Shopify  | 2.48             |
| 2019          | 5            | Retail   | 97.52            |
| 2019          | 6            | Retail   | 97.42            |
| 2019          | 6            | Shopify  | 2.58             |
| 2019          | 7            | Shopify  | 2.65             |
| 2019          | 7            | Retail   | 97.35            |
| 2019          | 8            | Retail   | 97.21            |
| 2019          | 8            | Shopify  | 2.79             |
| 2019          | 9            | Shopify  | 2.91             |
| 2019          | 9            | Retail   | 97.09            |
| 2020          | 3            | Retail   | 97.30            |
| 2020          | 3            | Shopify  | 2.70             |
| 2020          | 4            | Retail   | 96.96            |
| 2020          | 4            | Shopify  | 3.04             |
| 2020          | 5            | Shopify  | 3.29             |
| 2020          | 5            | Retail   | 96.71            |
| 2020          | 6            | Shopify  | 3.20             |
| 2020          | 6            | Retail   | 96.80            |
| 2020          | 7            | Retail   | 96.67            |
| 2020          | 7            | Shopify  | 3.33             |
| 2020          | 8            | Retail   | 96.51            |
| 2020          | 8            | Shopify  | 3.49             |
	  
**7. What is the percentage of sales by demographic for each year in the dataset?**
```
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
```
| calendar_year | family_percentage | couple_percentage | unknown_percentage |
|---------------|---------------------|---------------------|----------------------|
| 2018          | 31.99               | 26.38               | 41.63                |
| 2019          | 32.47               | 27.28               | 40.25                |
| 2020          | 32.73               | 28.72               | 38.55                |

So, it can be seen that over the years "unknown" demography, is contributing most to the sales. 

*another way*

```
WITH temp_cte as (SELECT calendar_year,demographic,
				 SUM(sales) as yearly_demo_sale
				 FROM clean_weekly_sales GROUP BY calendar_year,demographic)
SELECT calendar_year,demographic,
ROUND(100.0* yearly_demo_sale/ SUM(yearly_demo_sale) OVER(PARTITION BY calendar_year),2) as percentage_sale
FROM temp_cte ORDER BY calendar_year,demographic;
```
| calendar_year | demographic | percentage_sale |
|---------------|-------------|------------------|
| 2018          | Couples     | 26.38            |
| 2018          | Families    | 31.99            |
| 2018          | Unknown     | 41.63            |
| 2019          | Couples     | 27.28            |
| 2019          | Families    | 32.47            |
| 2019          | Unknown     | 40.25            |
| 2020          | Couples     | 28.72            |
| 2020          | Families    | 32.73            |
| 2020          | Unknown     | 38.55            |

**8. Which age_band and demographic values contribute the most to Retail sales?**
```
SELECT age_band,demographic,SUM(sales) AS retail_contribution,
ROUND(100.0 * SUM(sales)/SUM(SUM(sales)) OVER(),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band,demographic
ORDER BY retail_contribution DESC;
```
| age_band      | demographic | retail_contribution | contribution_percentage |
|---------------|--------------|----------------------|--------------------------|
| unknown       | unknown      | 16067285533         | 40.52                    |
| Retirees      | Families     | 6634686916          | 16.73                    |
| Retirees      | Couples      | 6370580014          | 16.07                    |
| Middle Aged   | Families     | 4354091554          | 10.98                    |
| Young Adults  | Couples      | 2602922797          | 6.56                     |
| Middle Aged   | Couples      | 1854160330          | 4.68                     |
| Young Adults  | Families     | 1770889293          | 4.47                     |


From the above table, it can be seen that "unknown" category in both demography and age_band makes the most signification contribution to the Retail sales.

**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**
```
SELECT calendar_year,platform,round(SUM(sales)/SUM(transactions),2) correct_avg_size, 
round(AVG(avg_transaction)::NUMERIC,2) incorrect_avg_size
FROM clean_weekly_sales 
GROUP BY calendar_year,platform ORDER BY calendar_year;
```
| calendar_year | platform | correct_avg_size | incorrect_avg_size |
|---------------|----------|-------------------|---------------------|
| 2018          | Retail   | 36.00             | 42.41               |
| 2018          | Shopify  | 192.00            | 187.80              |
| 2019          | Retail   | 36.00             | 41.47               |
| 2019          | Shopify  | 183.00            | 177.07              |
| 2020          | Shopify  | 179.00            | 174.40              |
| 2020          | Retail   | 36.00             | 40.14               |

We cannot use the "avg_transaction" column to determine the actual average transaction size, as doing so would yield inaccurate results. The "avg_transaction" column represents the average dollar amount spent per transaction during a specific week for the given region, platform, segment, age band, demographic, and customer type. Consequently, this column cannot be employed to calculate the average transaction size for each year when comparing Retail vs. Shopify.

##

### 3. Before & After Analysis
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

Check out the Before & After Analysis [here](https://github.com/roysushmita/8-weeks-SQL-challenge/blob/main/Case%20study%235/SQL%20query/Before%20after%20analysis-CS5.sql)
   
```
SELECT DISTINCT(DATE_PART('week',week_date)) as week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';
```
| week_number |
|-------------|
| 25          |


**1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?**
```
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 21 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| before_change | after_change | sale_change | rate_of_change |
|---------------|--------------|-------------|----------------|
| 2345878357    | 2318994169   | -26884188   | -1.15          |

The sale got reduced after introducing sustainable packaging within 4 weeks. The sale reduced by 1.15% within just 4 weeks.

**2. What about the entire 12 weeks before and after?**
```
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 13 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| before_change | after_change | sale_change  | rate_of_change |
|---------------|--------------|--------------|-----------------|
| 7126273147    | 6973947753   | -152325394   | -2.14           |

The sale got reduced by 2.14% after introducing sustainable packaging in DataMart within 12 weeks.

**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**
```
WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 21 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| calendar_year | before_change | after_change | sale_change  | rate_of_change |
|---------------|---------------|--------------|--------------|-----------------|
| 2018          | 2125140809    | 2129242914   | 4102105      | 0.19            |
| 2019          | 2249989796    | 2252326390   | 2336594      | 0.10            |
| 2020          | 2345878357    | 2318994169   | -26884188    | -1.15           |

This analysis indicates that the sustainable packaging changes introduced in June 2020 had a notable impact on sales compared to the same periods in 2018 and 2019. In 2018, sales increased by $4,102,105 (0.19%) compared to the period before and after the packaging change, and in 2019 also, there was a positive sales variance of $2,336,594 (0.10%). However, 2020 experienced a substantial sales decrease with a significant negative variance of $26,884,188 (-1.15%), showing a clear change from the positive patterns in the previous years.

```
WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| calendar_year | before_change | after_change | sale_change | rate_of_change |
|---------------|---------------|--------------|-------------|-----------------|
| 2018          | 6396562317    | 6500818510   | 104256193   | 1.63            |
| 2019          | 6883386397    | 6862646103   | -20740294   | -0.30           |
| 2020          | 7126273147    | 6973947753   | -152325394  | -2.14           |

In the 12 weeks surrounding the sustainable packaging changes in June 2020, sales dynamics shifted. In 2018, a positive change of $104.26M (1.63%) occurred, followed by a slight dip of $20.74M (-0.30%) in 2019. However, 2020 experienced a notable decline with a negative change of $152.33M (-2.14%). This indicates a variance from tradition and highlights a major long-term impact of the sustainability actions put in place.

### 4. Bonus Question
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

region
platform
age_band
demographic
customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

Check out the Bonus Questions [here](https://github.com/roysushmita/8-weeks-SQL-challenge/blob/main/Case%20study%235/SQL%20query/Bonusqn-CS5.sql)
**--Impact on region**

```
WITH temp_cte AS (SELECT region,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY region)
SELECT region,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;
```
| region         | before_change | after_change  | sale_change   | rate_of_change |
|----------------|---------------|---------------|---------------|-----------------|
| ASIA           | 1637244466    | 1583807621    | -53436845     | -3.26           |
| OCEANIA        | 2354116790    | 2282795690    | -71321100     | -3.03           |
| SOUTH AMERICA  | 213036207     | 208452033     | -4584174      | -2.15           |
| CANADA         | 426438454     | 418264441     | -8174013      | -1.92           |
| USA            | 677013558     | 666198715     | -10814843     | -1.60           |
| AFRICA         | 1709537105    | 1700390294    | -9146811      | -0.54           |
| EUROPE         | 108886567     | 114038959     | 5152392       | 4.73            |

The most negatively impacted region was ASIA(-3.26%) in sales metrics in 2020, followed by OCEANIA(-3.03), SOUTH AMERICA(-2.15). Even other regions except EUROPE experienced decline in sale. This emphasizes the need for region-specific strategies for optimized sales.

**--Impact on platform**
```
WITH temp_cte AS (SELECT platform,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY platform)
SELECT platform,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;
```
| platform | before_change | after_change  | sale_change  | rate_of_change |
|----------|---------------|---------------|--------------|-----------------|
| Retail   | 6906861113    | 6738777279    | -168083834   | -2.43           |
| Shopify  | 219412034     | 235170474     | 15758440     | 7.18            |

So, Retail sales took a hit with a decline of 2.43%, while Shopify witnessed a significant positive shift of 7.18%. This highlights the need for distinct strategies for each platform to optimize sales.

**--Impact on age_band**
```
WITH temp_cte AS (SELECT age_band,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY age_band)
SELECT age_band,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;
```
| age_band      | before_change | after_change | sale_change | rate_of_change |
|---------------|---------------|--------------|-------------|-----------------|
| unknown       | 2764354464    | 2671961443   | -92393021   | -3.34           |
| Middle Aged   | 1164847640    | 1141853348   | -22994292   | -1.97           |
| Retirees      | 2395264515    | 2365714994   | -29549521   | -1.23           |
| Young Adults  | 801806528     | 794417968    | -7388560    | -0.92           |



**--Impact on demographic**
```
WITH temp_cte AS (SELECT demographic,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY demographic)
SELECT demographic,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;
```
| demographic   | before_change | after_change | sale_change  | rate_of_change |
|---------------|---------------|--------------|--------------|-----------------|
| unknown       | 2764354464    | 2671961443   | -92393021    | -3.34           |
| Families      | 2328329040    | 2286009025   | -42320015    | -1.82           |
| Couples       | 2033589643    | 2015977285   | -17612358    | -0.87           |

The most significant negative impact on sales metrics in 2020 was observed in the "unknown" demographic, with a noticable decline of 3.34%. Surprisingly, even within the "Retail" platform, this demographic contributed the most and experienced the highest decrease after the introduction of the change. This emphasizes the need for targeted strategies in understanding and mitigating this decline.

**--Impact on customer_type**
```
WITH temp_cte AS (SELECT customer_type,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY customer_type)
SELECT customer_type,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;
```
| customer_type | before_change | after_change  | sale_change   | rate_of_change |
|---------------|---------------|---------------|---------------|-----------------|
| Guest         | 2573436301 | 2496233635 | -77202666   | -3.00           |
| Existing      | 3690116427 | 3606243454 | -83872973   | -2.27           |
| New           | 862720419   | 871470664   | 8750245     | 1.01            |

With a reduction of 3%, the biggest sales decline in 2020 can be seen in the 'Guest' customer_type. In the meantime, a slight increase of 1.01% can be seen among the "New" customers, highlighting the varied impact of sustainable packaging changes across different customer types. 
