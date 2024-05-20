
###### Purpose - This project aims to gain insight into the sales data of Amazon to understand the different factors that affect sales of the different branches.

create database Amazon_Sales;
use Amazon_Sales;

#### Data Wrangling
#All values are set with NOT NULL constraint so no columns has any null value. 

SELECT 
    SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END) AS null_invoice_id,
    SUM(CASE WHEN branch IS NULL THEN 1 ELSE 0 END) AS null_branch,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN customer_type IS NULL THEN 1 ELSE 0 END) AS null_customer_type,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN product_line IS NULL THEN 1 ELSE 0 END) AS null_product_line,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN VAT IS NULL THEN 1 ELSE 0 END) AS null_VAT,
    SUM(CASE WHEN total IS NULL THEN 1 ELSE 0 END) AS null_total,
    SUM(CASE WHEN paymentdate IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN paymenttime IS NULL THEN 1 ELSE 0 END) AS null_time,
    SUM(CASE WHEN payment IS NULL THEN 1 ELSE 0 END) AS null_payment_method,
    SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS null_cogs,
    SUM(CASE WHEN gross_margin_percentage IS NULL THEN 1 ELSE 0 END) AS null_gross_margin_percentage,
    SUM(CASE WHEN gross_income IS NULL THEN 1 ELSE 0 END) AS null_gross_income,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating
FROM salesdata;

#Prints sum of null values in each column which is zero.

### Feature Engineering

UPDATE salesdata
SET paymentdate=STR_TO_DATE(paymentdate, "%d-%m-%Y");
ALTER TABLE salesdata
MODIFY COLUMN paymentdate DATE;

UPDATE salesdata
SET paymenttime = STR_TO_DATE(paymenttime, '%H:%i:%s');
ALTER TABLE salesdata
MODIFY COLUMN paymenttime TIME;

#Adding a new column named timeofday
ALTER TABLE salesdata
ADD COLUMN timeofday VARCHAR(10);

UPDATE salesdata
SET timeofday =
    CASE 
        WHEN HOUR(paymenttime) < 12 THEN 'Morning'
        WHEN HOUR(paymenttime) >= 12 AND HOUR(paymenttime) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END;

#Adding a new column named dayname
ALTER TABLE salesdata
ADD COLUMN dayname VARCHAR(3);

UPDATE salesdata
SET dayname = UPPER(LEFT(DAYNAME(paymentdate), 3));

#Adding a new column named monthname
ALTER TABLE salesdata
ADD COLUMN monthname VARCHAR(3);

UPDATE salesdata
SET monthname = UPPER(LEFT(MONTHNAME(paymentdate), 3));

###  Exploratory Data Analysis (EDA)

#Q1. What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT city) AS count_of_city
FROM salesdata;

/*** It has been found that there are three distinct cities from which customers purchased items. ***/

#Q2. For each branch, what is the corresponding city?
SELECT branch, city
FROM salesdata
GROUP BY branch, city;

/*** Branch A is located in 'Yangon', Branch C is located in 'Naypyitaw' and B is located in 'Mandalay'. ***/

#Q3. What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT product_line) AS count_of_product_line
FROM salesdata;

/*** There are 6 distinct product lines in the dataset. ***/

#Q4. Which payment method occurs most frequently?
SELECT payment, COUNT(*) AS payment_method_count
FROM salesdata
GROUP BY payment
ORDER BY payment_method_count DESC
LIMIT 1;

/*** 'Ewallet' is the payment method that occurs most frequently. ***/

#Q5. Which product line has the highest sales?
SELECT product_line, COUNT(product_line) AS sales
FROM salesdata
GROUP BY product_line
ORDER BY sales DESC
LIMIT 1;

/*** 'Fashion accessories' is the product line having highest sales. ***/

#Q6. How much revenue is generated each month?
SELECT monthname, SUM(quantity*unit_price) AS monthly_revenue
FROM salesdata
GROUP BY monthname
ORDER BY monthly_revenue DESC;

/*** The revenue generated each month is $110,754.16 in January, $92,589.88 in February, and $104,243.34 in March. ***/

#Q7. In which month did the cost of goods sold reach its peak?
SELECT monthname, SUM(cogs) AS monthly_cogs
FROM salesdata
GROUP BY monthname
ORDER BY monthly_cogs DESC
LIMIT 1;

/*** The cost of goods sold reached its peak in January, totaling $110,754.16. ***/

#Q8. Which product line generated the highest revenue?
SELECT product_line, SUM(quantity*unit_price) AS total_revenue
FROM salesdata
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

/*** The product line "Food and beverages" generated the highest revenue, amounting to $53,471.28. ***/

#Q9. In which city was the highest revenue recorded?
SELECT city, SUM(quantity*unit_price) AS total_revenue
FROM salesdata
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

/*** The highest revenue was recorded in Naypyitaw, totaling $105,303.53. ***/

#Q10. Which product line incurred the highest Value Added Tax?
SELECT product_line, SUM(vat) AS total_vat
FROM salesdata
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

/*** The product line "Food and beverages" incurred the highest Value Added Tax, totaling $2,673.56. ***/

#Q11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT *,
CASE
WHEN sales > avg_sales THEN 'Good'
ELSE 'Bad'
END AS sales_performance
FROM (
SELECT product_line,
SUM(total) AS sales,
AVG(SUM(total)) OVER () AS avg_sales
FROM salesdata
GROUP BY product_line
) AS subquery_alias;

/*** The sales for "Food and beverages," "Sports and travel," "Fashion accessories," "Home and lifestyle," and 
"Electronic accessories" are above average or good, while only the sales for "Health and beauty" are below average or bad. ***/

#Q12. Identify the branch that exceeded the average number of products sold.
SELECT branch, AVG(quantity) AS branch_product_average
FROM salesdata
GROUP BY branch
HAVING AVG(quantity) > (SELECT AVG(quantity) FROM salesdata);

/*** Branch C exceeded the average number of products sold, with an average of 5.5823 products sold per transaction. ***/

#Q13. Which product line is most frequently associated with each gender?
(SELECT gender, product_line, COUNT(*) AS frequency
FROM salesdata WHERE gender = 'Male'
GROUP BY gender, product_line
ORDER BY frequency DESC
LIMIT 1
)
UNION
(
SELECT gender, product_line, COUNT(*) AS frequency
FROM salesdata WHERE gender = 'Female'
GROUP BY gender, product_line
ORDER BY frequency DESC
LIMIT 1
);

/*** For males, the product line most frequently associated is "Health and beauty", 
while for females, the most frequently associated product line is "Fashion accessories". ***/

#Q14. Calculate the average rating for each product line.
SELECT product_line, ROUND(AVG(rating),2) AS average_rating
FROM salesdata
GROUP BY product_line;

/*** The analysis reveals that the "Food and beverages" product line boasts the highest average rating at 7.11,
indicating customer satisfaction. Meanwhile, the "Home and lifestyle" category exhibits the lowest average rating at 6.84. ***/

#Q15. Count the sales occurrences for each time of day on every weekday.
SELECT timeofday, dayname, COUNT(*) AS sales_occurrences
FROM salesdata
WHERE dayname!='SUN' AND dayname!='SAT'
GROUP BY timeofday, dayname
ORDER BY dayname, timeofday;

/*** The highest occurrence of sales across weekdays is in the afternoon time slot, particularly on Wednesdays with 81 transactions, 
followed closely by Thursdays with 76 transactions. Conversely, mornings exhibit the lowest sales frequency. ***/

#Q16. Identify the customer type contributing the highest revenue.
SELECT customer_type, SUM(quantity*unit_price) AS total_revenue
FROM salesdata
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

/*** The customer type "Member" contributes the highest revenue, totaling $156,403.28. ***/

#Q17. Determine the city with the highest VAT percentage.
SELECT city, ROUND(AVG((vat / total) * 100),2) AS vat_percentage
FROM salesdata
GROUP BY city
ORDER BY vat_percentage DESC
LIMIT 1;

/*** The city with the highest VAT percentage is Yangon, with a VAT rate of approximately 4.76%. ***/

#Q18. Identify the customer type with the highest VAT payments.
SELECT customer_type, ROUND(SUM(vat),2) AS total_VAT_payments
FROM salesdata
GROUP BY customer_type
ORDER BY total_VAT_payments DESC
LIMIT 1;

/*** The customer type "Member" has the highest VAT payments, totaling $7,820.16. ***/

#Q19. What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT customer_type) AS count_of_customer_type
FROM salesdata;

/*** There are 2 distinct customer types present in the dataset. ***/

#Q20. What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT payment) AS count_of_payment_method
FROM salesdata;

/*** There are 3 distinct payment methods present in the dataset. ***/

#Q21. Which customer type occurs most frequently?
SELECT customer_type, COUNT(*) AS frequency
FROM salesdata
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;

/*** The customer type "Member" occurs most frequently in the dataset, with a count of 501 occurrences. ***/

#Q22. Identify the customer type with the highest purchase frequency.
SELECT customer_type, SUM(quantity) AS total_purchase_frequency
FROM salesData
GROUP BY customer_type
ORDER BY total_purchase_frequency DESC
LIMIT 1;

/*** The customer type "Member" has the highest purchase frequency, with a count of 2785 transactions. ***/

#Q23. Determine the predominant gender among customers.
SELECT gender, COUNT(*) AS frequency
FROM salesdata
GROUP BY gender
ORDER BY frequency DESC
LIMIT 1;

/*** The predominant gender among customers is female compared to male, with a count of 501 occurrences. ***/

#Q24. Examine the distribution of genders within each branch.
SELECT branch, gender, COUNT(*) AS gender_count
FROM salesdata
GROUP BY branch, gender
ORDER BY branch, gender;

/*** The analysis reveals that there is a relatively balanced distribution of genders across branches A and B,
with slightly more males than females. However, branch C exhibits a notable disparity,
with a higher proportion of females compared to males. ***/

#Q25. Identify the time of day when customers provide the most ratings.
SELECT timeofday, COUNT(rating) AS rating_count
FROM salesdata
WHERE rating IS NOT NULL
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 1;

/*** Customers provide the most ratings during the afternoon, with a count of 528 ratings. ***/

#Q26. Determine the time of day with the highest customer ratings for each branch.
WITH RankedTimes AS (
SELECT branch, timeofday, COUNT(rating) AS rating_count,
RANK() OVER (PARTITION BY branch ORDER BY COUNT(rating) DESC) AS branch_rank
FROM salesdata
WHERE rating IS NOT NULL
GROUP BY branch, timeofday
)
SELECT branch, timeofday, rating_count
FROM RankedTimes
WHERE branch_rank = 1;

/*** The analysis reveals that the afternoon is the time of day with the highest customer ratings across all branches,
with Branch A leading at 185 ratings, followed closely by Branch C at 181 ratings. ***/

#Q27. Identify the day of the week with the highest average ratings.
SELECT dayname, ROUND(AVG(rating),2) AS avg_rating
FROM salesdata
WHERE rating IS NOT NULL
GROUP BY dayname
ORDER BY avg_rating DESC
LIMIT 1;

/*** The day of the week with the highest average ratings is Monday, with an average rating of 7.15. ***/

#Q28. Determine the day of the week with the highest average ratings for each branch.
WITH AvgRatings AS (
SELECT branch, dayname, ROUND(AVG(rating),2) AS avg_rating,
RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS day_rank
FROM salesdata
WHERE rating IS NOT NULL
GROUP BY branch, dayname
)
SELECT branch, dayname, avg_rating
FROM AvgRatings
WHERE day_rank = 1;

/*** The analysis reveals that for Branch A, Friday has the highest average ratings at 7.31,
while for Branch B, it's Monday with an average rating of 7.34,
and for Branch C, Friday also leads with an average rating of 7.28. ***/

