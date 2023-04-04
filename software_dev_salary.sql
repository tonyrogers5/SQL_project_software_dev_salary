SELECT * FROM portfolio.softwaredevincome;


-- Impute incorrect data. See findings at the bottom for more details. 

UPDATE portfolio.softwaredevincome
SET `Cost of Living Plus Rent avg` = ROUND((`Cost of Living avg` + `Rent avg`),2)
WHERE City = 'Tucson, AZ' OR City = 'Lexington, KY';

UPDATE portfolio.softwaredevincome
SET `Rent avg` = ROUND((`Cost of Living Plus Rent avg` - `Cost of Living avg`),2)
WHERE City = 'Cincinnati, OH' OR City = 'Milwaukee, WI';

UPDATE portfolio.softwaredevincome
SET `Cost of Living avg` = ROUND((`Cost of Living Plus Rent avg` - `Rent avg`),2)
WHERE City = 'Los Angeles, CA' OR City = 'Philadelphia, PA';


-- Shows the cities where software developers earn a higher salary on average comparing to all occupations.

SELECT COUNT(City) AS city_count,  COUNT(`Mean Software Developer Salary (unadjusted)` - `Mean Unadjusted Salary (all occupations)`) as salary_diff_count
FROM portfolio.softwaredevincome
WHERE `Mean Software Developer Salary (unadjusted)` > `Mean Unadjusted Salary (all occupations)`;


-- Shows the top 5 cities with the most software developer job opportunities and their numbers.

SELECT City, `Number of Software Developer Jobs`
FROM portfolio.softwaredevincome
ORDER BY `Number of Software Developer Jobs` DESC
LIMIT 5;


-- Shows the city that has the highest ratio of software developer salaries to average home price.

SELECT City, ROUND((`Mean Software Developer Salary (unadjusted)`/`Median Home Price`)*100,2) AS salary_to_home_price_ratio
FROM portfolio.softwaredevincome
ORDER BY salary_to_home_price_ratio DESC
LIMIT 1;


-- shows the average software developer income for each state, and how it compares to the national average, in descending order.

SELECT @average_salary := ROUND(AVG(`Mean Software Developer Salary (unadjusted)`),2)
FROM portfolio.softwaredevincome;

SELECT TRIM(SUBSTRING_INDEX(city, ',', -1)) AS State, CAST(ROUND(AVG(`Mean Software Developer Salary (unadjusted)`),2) AS DECIMAL (10,2)) AS State_Average_Salary, ROUND(AVG(`Mean Software Developer Salary (unadjusted)`) - @average_salary,2) AS Salary_Difference_From_National_Average
FROM portfolio.softwaredevincome
GROUP BY State
ORDER BY Salary_Difference_From_National_Average DESC;


-- Shows the top 5 metropolitan areas that have the highest local purchasing power relative to the cost of living plus rent.

SELECT Metro, AVG(`Local Purchasing Power avg`)/AVG(`Cost of Living Plus Rent avg`) AS purchasing_power_to_cost_of_living_plus_rent_ratio
FROM portfolio.softwaredevincome
GROUP BY Metro
ORDER BY purchasing_power_to_cost_of_living_plus_rent_ratio DESC
LIMIT 5;


-- Shows all cities where cost of living plus rent is below the national average and local purchasing power is above the national average. This list is then sorted by local purchasing power to cost of living plus rent ratio in descending order.

SELECT City, AVG(`Local Purchasing Power avg`)/AVG(`Cost of Living Plus Rent avg`) AS purchasing_power_to_cost_of_living_plus_rent_ratio
FROM portfolio.softwaredevincome
WHERE `Cost of Living Plus Rent avg` < (SELECT AVG(`Cost of Living Plus Rent avg`) FROM portfolio.softwaredevincome) 
AND `Local Purchasing Power avg` > (SELECT AVG(`Local Purchasing Power avg`) FROM portfolio.softwaredevincome)
GROUP BY City
ORDER BY purchasing_power_to_cost_of_living_plus_rent_ratio DESC;


-- Shows the cities where the average salary is higher than the national average salary, but the cost of living plus rent is also higher than the national average.

SELECT city, `Mean Software Developer Salary (unadjusted)`, `Cost of Living Plus Rent avg`
FROM portfolio.softwaredevincome
WHERE `Mean Software Developer Salary (unadjusted)`  > (SELECT AVG(`Mean Software Developer Salary (unadjusted)`) FROM portfolio.softwaredevincome) 
AND `Cost of Living Plus Rent avg` > (SELECT AVG(`Cost of Living Plus Rent avg`) FROM portfolio.softwaredevincome)
ORDER BY `Mean Software Developer Salary (unadjusted)` DESC;


-- Dropping unused columns.

ALTER TABLE portfolio.softwaredevincome
DROP COLUMN MyUnknownColumn, 
DROP COLUMN `Mean Software Developer Salary (adjusted)`;



/* 

Data Cleansing:

1. Modifying values.
- For cities Tucson, AZ and Lexington, KY, cost of living plus rent average shows 130097.8, which is significantly higher than the rest. An estimate is used to replace it, calculated by combining cost of living avg and rent avg. Although this is not the perfect value, it is the best estimate to replace the incorrect value which would skew the findings. 
- Same method is used to correct the rent avg (58597.6) for Cincinnati, OH and Milwaukee, WI and cost of living avg (15809.2) for Los Angeles, CA and Philadelphia, PA. 
- Since there is only one column that is incorrect for each row, it is better to impute them rather deleting the entire row and affect the sample size.

2. Removing unused volumns.
- Index column named MyUnknownColumn is removed since it does not help the context or purpose of the analysis, or provide useful information that is relevant to the analysis. 
- Adjusted salary column is unused and removed since the local purchasing power column is already provided and used in analysis, where adjusted salary would be used to calculate.


Findings:

1. In all 77 major cities, software developers have higher salary than the average salary of all occupations.
2. The top five cities with the highest amount of software developer job opportunities are: Jersey City, NJ, New York, NY, Santa Clara, CA, San Jose, CA, and Seattle, WA.
3. Dayton, OH is the best city for software developers who want a high salary comparing to the cost of purchasing a home.
4. CA, DC, NJ and MD are some of the states where software developers have a higher salary than the national average. AR, NM, ID, and TN are some of the states where software developers have a lower salary than the national average. This is for the unadjusted salary and does not factor in the cost of living.
5. The top five metropolitan areas that have the highest purchasing power to cost of living plus rent ratio are Houston-The Woodlands-Sugar Land, TX, Little Rock-North Little Rock-Conway, AR, Tulsa, OK, Wichita, KS, and Columbus, OH. This shows the residents of these metropolitan areas can afford to purchase more goods and services with their income compared to others with a similar cost of living and rent, which indicate a higher standard of living for its resident. 
6. Out of 77 major cities, cost of living plus rent from 26 cities are below the national average while their local purchasing power index is above the national average. Example of these cities in descending orders are Houston, TX, Little Rock, AR, Dallas, TX, and Tulsa, OK. This suggest that these cities are more affordable and economically advantageous for individuals and business.
7. 21 Out of 77 major cities reflect software developers having above-average salaries and also experiencing a higher cost of living, making it more challenging to maintain a high standard of living. In this list of 21 cities, California stands out with its 9 cities meeting the criteria. Impressively, 6 of those 9 California cities rank among the top 10 in the list.


Dataset used and context: https://www.kaggle.com/datasets/thedevastator/u-s-software-developer-salaries

*/
