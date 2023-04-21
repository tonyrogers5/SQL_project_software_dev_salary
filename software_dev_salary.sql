/* 

Data Cleansing:

1. Modifying values.
- For cities Tucson, AZ and Lexington, KY, cost of living plus rent average shows 130097.8, which is significantly higher than the rest. An estimate is used to replace it, calculated by combining cost of living avg and rent avg. Although this is not the perfect value, it is the best estimate to replace the incorrect value which would skew the findings. 
- Same method is used to correct the rent avg (58597.6) for Cincinnati, OH and Milwaukee, WI and cost of living avg (15809.2) for Los Angeles, CA and Philadelphia, PA. 
- Since there is only one column that is incorrect for each row, it is better to impute them rather deleting the entire row and affect the sample size.

2. Removing unused volumns.
- Index column named MyUnknownColumn is removed since it does not help the context or purpose of the analysis, or provide useful information that is relevant to the analysis. 
- Adjusted salary column is unused and removed since the local purchasing power column is already provided and used in analysis, where adjusted salary would be used to calculate.


Analysis:

1. In all 77 major cities, software developers have higher salary than the average salary of all occupations.
2. The top five cities with the highest amount of software developer job opportunities are: Jersey City, NJ, New York, NY, Santa Clara, CA, San Jose, CA, and Seattle, WA.
3. Dayton, OH is the best city for software developers who want a high salary comparing to the cost of purchasing a home.
4. CA, DC, NJ and MD are some of the states where software developers have a higher salary than the national average. AR, NM, ID, and TN are some of the states where software developers have a lower salary than the national average. This is for the unadjusted salary and does not factor in the cost of living.
5. The top five metropolitan areas that have the highest purchasing power to cost of living plus rent ratio are Houston-The Woodlands-Sugar Land, TX, Little Rock-North Little Rock-Conway, AR, Tulsa, OK, Wichita, KS, and Columbus, OH. This shows the residents of these metropolitan areas can afford to purchase more goods and services with their income compared to others with a similar cost of living and rent, which indicate a higher standard of living for its resident. 
6. Out of 77 major cities, cost of living plus rent from 26 cities are below the national average while their local purchasing power index is above the national average. Example of these cities in descending orders are Houston, TX, Little Rock, AR, Dallas, TX, and Tulsa, OK. This suggest that these cities are more affordable and economically advantageous for individuals and business.
7. 21 Out of 77 major cities reflect software developers having above-average salaries and also experiencing a higher cost of living, making it more challenging to maintain a high standard of living. In this list of 21 cities, California stands out with its 9 cities meeting the criteria. Impressively, 6 of those 9 California cities rank among the top 10 in the list.


Dataset Context:

This dataset provides an extensive look into the financial health of software developers in major cities and metropolitan areas around the United States. We explore disparities between states and cities in terms of mean software developer salaries, median home prices, cost of living avgs, rent avgs, cost of living plus rent avgs and local purchasing power averages. Through this data set we can gain insights on how to better understand which areas are more financially viable than others when seeking employment within the software development field. Our data allow us to uncover patterns among certain geographic locations in order to identify other compelling financial opportunities that software developers may benefit from.

Dataset link: https://www.kaggle.com/datasets/thedevastator/u-s-software-developer-salaries

*/


SELECT * FROM portfolio.softwaredevincome;


-- Impute incorrect data. 


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

-- Query Result:

+------------+-------------------+
| city_count | salary_diff_count |
+------------+-------------------+
|         77 |                77 |
+------------+-------------------+


-- Shows the top 5 cities with the most software developer job opportunities and their numbers.


SELECT City, `Number of Software Developer Jobs`
FROM portfolio.softwaredevincome
ORDER BY `Number of Software Developer Jobs` DESC
LIMIT 5;

-- Query Result:

+-----------------+-----------------------------------+
| City            | Number of Software Developer Jobs |
+-----------------+-----------------------------------+
| Jersey City, NJ |                             98650 |
| New York, NY    |                             98650 |
| Santa Clara, CA |                             78730 |
| San Jose, CA    |                             78730 |
| Seattle, WA     |                             65760 |
+-----------------+-----------------------------------+


-- Shows the city that has the highest ratio of software developer salaries to average home price.


SELECT City, ROUND((`Mean Software Developer Salary (unadjusted)`/`Median Home Price`)*100,2) AS salary_to_home_price_ratio
FROM portfolio.softwaredevincome
ORDER BY salary_to_home_price_ratio DESC
LIMIT 1;

-- Query Result:

+------------+----------------------------+
| City       | salary_to_home_price_ratio |
+------------+----------------------------+
| Dayton, OH |                      80.05 |
+------------+----------------------------+


-- shows the average software developer income for each state, and how it compares to the national average, in descending order.


SELECT @average_salary := ROUND(AVG(`Mean Software Developer Salary (unadjusted)`),2)
FROM portfolio.softwaredevincome;

SELECT TRIM(SUBSTRING_INDEX(city, ',', -1)) AS State, CAST(ROUND(AVG(`Mean Software Developer Salary (unadjusted)`),2) AS DECIMAL (10,2)) AS State_Average_Salary, ROUND(AVG(`Mean Software Developer Salary (unadjusted)`) - @average_salary,2) AS Salary_Difference_From_National_Average
FROM portfolio.softwaredevincome
GROUP BY State
ORDER BY Salary_Difference_From_National_Average DESC;

-- Query Result: 

+-------+----------------------+-----------------------------------------+
| State | State_Average_Salary | Salary_Difference_From_National_Average |
+-------+----------------------+-----------------------------------------+
| CA    |            125268.78 |                                23402.57 |
| DC    |            119806.00 |                                17939.79 |
| NJ    |            118247.00 |                                16380.79 |
| MD    |            115006.00 |                                13139.79 |
| MA    |            114227.00 |                                12360.79 |
| TX    |            109190.40 |                                 7324.19 |
| WA    |            107616.67 |                                 5750.46 |
| CO    |            107223.33 |                                 5357.12 |
| GA    |            106334.00 |                                 4467.79 |
| UT    |            105334.00 |                                 3467.79 |
| NV    |            104495.00 |                                 2628.79 |
| NC    |            103815.00 |                                 1948.79 |
| IL    |            102082.00 |                                  215.79 |
| MN    |            101411.00 |                                 -455.21 |
| AZ    |            101175.67 |                                 -690.54 |
| VA    |            101153.00 |                                 -713.21 |
| NY    |             98649.80 |                                -3216.41 |
| PA    |             98286.00 |                                -3580.21 |
| FL    |             95930.20 |                                -5936.01 |
| OR    |             95064.50 |                                -6801.71 |
| MI    |             94145.50 |                                -7720.71 |
| OH    |             93923.80 |                                -7942.41 |
| IA    |             93386.00 |                                -8480.21 |
| KS    |             92595.00 |                                -9271.21 |
| NE    |             92339.00 |                                -9527.21 |
| SC    |             91976.00 |                                -9890.21 |
| KY    |             90861.50 |                               -11004.71 |
| HI    |             90796.00 |                               -11070.21 |
| AL    |             90219.00 |                               -11647.21 |
| WI    |             89792.00 |                               -12074.21 |
| IN    |             88732.00 |                               -13134.21 |
| MO    |             88732.00 |                               -13134.21 |
| OK    |             88092.00 |                               -13774.21 |
| TN    |             87952.50 |                               -13913.71 |
| ID    |             87712.00 |                               -14154.21 |
| NM    |             87097.00 |                               -14769.21 |
| AR    |             84434.00 |                               -17432.21 |
+-------+----------------------+-----------------------------------------+


-- Shows the top 5 metropolitan areas that have the highest local purchasing power relative to the cost of living plus rent.


SELECT Metro, ROUND(AVG(`Local Purchasing Power avg`)/AVG(`Cost of Living Plus Rent avg`),3) AS purchasing_power_to_cost_of_living_plus_rent_ratio
FROM portfolio.softwaredevincome
GROUP BY Metro
ORDER BY purchasing_power_to_cost_of_living_plus_rent_ratio DESC
LIMIT 5;

-- Query Result:

+------------------------------------------+----------------------------------------------------+
| Metro                                    | purchasing_power_to_cost_of_living_plus_rent_ratio |
+------------------------------------------+----------------------------------------------------+
| Houston-The Woodlands-Sugar Land, TX     |                                              3.742 |
| Little Rock-North Little Rock-Conway, AR |                                              3.541 |
| Tulsa, OK                                |                                              3.323 |
| Wichita, KS                              |                                              3.283 |
| Columbus, OH                             |                                              3.268 |
+------------------------------------------+----------------------------------------------------+


-- Shows all cities where cost of living plus rent is below the national average and local purchasing power is above the national average. This list is then sorted by local purchasing power to cost of living plus rent ratio in descending order.


SELECT City, ROUND(AVG(`Local Purchasing Power avg`)/AVG(`Cost of Living Plus Rent avg`),3) AS purchasing_power_to_cost_of_living_plus_rent_ratio
FROM portfolio.softwaredevincome
WHERE `Cost of Living Plus Rent avg` < (SELECT AVG(`Cost of Living Plus Rent avg`) FROM portfolio.softwaredevincome) 
AND `Local Purchasing Power avg` > (SELECT AVG(`Local Purchasing Power avg`) FROM portfolio.softwaredevincome)
GROUP BY City
ORDER BY purchasing_power_to_cost_of_living_plus_rent_ratio DESC;

-- Query Result:

+----------------------+----------------------------------------------------+
| City                 | purchasing_power_to_cost_of_living_plus_rent_ratio |
+----------------------+----------------------------------------------------+
| Houston, TX          |                                              3.742 |
| Little Rock, AR      |                                              3.541 |
| Dallas, TX           |                                              3.366 |
| Tulsa, OK            |                                              3.323 |
| Columbus, OH         |                                              3.268 |
| Jacksonville, FL     |                                              3.168 |
| San Antonio, TX      |                                              3.159 |
| Ann Arbor, MI        |                                              3.142 |
| Raleigh, NC          |                                              3.043 |
| Oklahoma City, OK    |                                              3.041 |
| Salt Lake City, UT   |                                              3.039 |
| Kansas City, MO      |                                              2.941 |
| Albuquerque, NM      |                                                2.9 |
| Madison, WI          |                                              2.878 |
| Richmond, VA         |                                              2.871 |
| Albany, NY           |                                               2.81 |
| Cincinnati, OH       |                                              2.783 |
| Phoenix, AZ          |                                              2.782 |
| Colorado Springs, CO |                                              2.745 |
| Buffalo, NY          |                                               2.74 |
| Baltimore, MD        |                                              2.728 |
| Indianapolis, IN     |                                              2.714 |
| Las Vegas, NV        |                                              2.704 |
| Vancouver, WA        |                                              2.608 |
| Cleveland, OH        |                                              2.601 |
| Orlando, FL          |                                              2.511 |
+----------------------+----------------------------------------------------+


-- Shows the cities where the average salary is higher than the national average salary, but the cost of living plus rent is also higher than the national average.


SELECT city, `Mean Software Developer Salary (unadjusted)`, `Cost of Living Plus Rent avg`
FROM portfolio.softwaredevincome
WHERE `Mean Software Developer Salary (unadjusted)`  > (SELECT AVG(`Mean Software Developer Salary (unadjusted)`) FROM portfolio.softwaredevincome) 
AND `Cost of Living Plus Rent avg` > (SELECT AVG(`Cost of Living Plus Rent avg`) FROM portfolio.softwaredevincome)
ORDER BY `Mean Software Developer Salary (unadjusted)` DESC;

-- Query Result:

+-------------------+---------------------------------------------+------------------------------+
| city              | Mean Software Developer Salary (unadjusted) | Cost of Living Plus Rent avg |
+-------------------+---------------------------------------------+------------------------------+
| San Francisco, CA |                                      142101 |                       5290.7 |
| Oakland, CA       |                                      142101 |                       4754.9 |
| Santa Clara, CA   |                                      137397 |                       4720.8 |
| San Jose, CA      |                                      137397 |                       4083.6 |
| Seattle, WA       |                                      131167 |                       4091.5 |
| Washington, DC    |                                      119806 |                       4146.1 |
| Los Angeles, CA   |                                      119662 |                       4043.7 |
| Long Beach, CA    |                                      119662 |                       3356.6 |
| New York, NY      |                                      118247 |                       5252.9 |
| Jersey City, NJ   |                                      118247 |                       3805.7 |
| Boston, MA        |                                      114227 |                       4312.1 |
| San Diego, CA     |                                      113650 |                       3799.4 |
| Santa Barbara, CA |                                      112648 |                       4582.1 |
| Denver, CO        |                                      111824 |                       3460.6 |
| Austin, TX        |                                      109535 |                       3275.7 |
| Charlotte, NC     |                                      107046 |                       3221.1 |
| Atlanta, GA       |                                      106334 |                         3334 |
| Portland, OR      |                                      106108 |                       3446.9 |
| Philadelphia, PA  |                                      105352 |                       3430.6 |
| Sacramento, CA    |                                      102801 |                         3418 |
| Chicago, IL       |                                      102082 |                       3559.9 |
+-------------------+---------------------------------------------+------------------------------+


-- Dropping unused columns.


ALTER TABLE portfolio.softwaredevincome
DROP COLUMN MyUnknownColumn, 
DROP COLUMN `Mean Software Developer Salary (adjusted)`;



