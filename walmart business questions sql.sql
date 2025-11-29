select * from walmart;

SELECT COUNT(*) FROM walmart;

SELECT payment_method, COUNT(*) FROM walmart
	GROUP BY payment_method;

SELECT COUNT(DISTINCT branch) FROM walmart;

SELECT MAX(quantity) FROM walmart;

--Business Problems--

-- Figuring out the number of payments from each different payment method and the amount of quantity sold. --
SELECT
	payment_method,
	COUNT (*) as no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--Identifying the highest rated category in each branch, displaying the branch, category, and rank--
SELECT *
FROM
(SELECT 
	branch, 
	category,
	AVG(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE rank =1;

--Identify the busiest day for each branch based on the number of transactions--
--Converting date data type to date
SELECT *
FROM
	(SELECT
	branch,
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
	COUNT(*) as no_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE rank = 1;

--Determine the average, minimum, and maximum rating of products for each city. List the city, average_rating, min_rating, and max_rating.--
SELECT 
	city,
	category,
	AVG(rating) as average_rating,
	MIN(rating) as minimum_rating,
	MAX(rating) as maximum_rating
FROM walmart
GROUP BY 1,2
ORDER BY 1,2 DESC

--Calculate the total profit for each category by considering the total_profit as (unit_price *quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit.--
SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as total_profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC

--Determine the most common payment method for each Branch.--
WITH cte
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as no_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
ORDER BY 1
)
SELECT *
FROM cte
WHERE rank = 1

--Categorize sales into 3 group MORNING, AFTERNOON, EVENING. Find out which of the shift and number of invoices--
SELECT
	branch,
	CASE
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3;

--Identify 5 branches with the highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)--

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
	FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
   GROUP BY 1
),
	
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY 1
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) ::numeric, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;





	
