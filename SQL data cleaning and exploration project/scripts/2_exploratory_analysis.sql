-- SQL Project - Exploratory data analysis

-- Here we are just going to explore the data and find trends or patterns or anything interesting like outliers

-- We are mostly going to work with total laid off and not percentage laid off

-- This is because along with percentage laid off we are not given total number of employees in a company

-- Trying some EASIER QUERIES on numbers

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(total_laid_off),  MAX(percentage_laid_off)
FROM world_layoffs.layoffs2
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of the company laid off

SELECT *
FROM world_layoffs.layoffs2
WHERE  percentage_laid_off = 1;

-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funds_raised_millions we can see how big some of these companies were

SELECT *
FROM world_layoffs.layoffs2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- BritishVolt lost like 2.4 billion dollars!, Quibi raised like 2 billion dollars and went under

-- Lets try to see companies with the biggest layoffs

SELECT company, total_laid_off
FROM world_layoffs.layoffs2
ORDER BY 2 DESC
LIMIT 5;

-- Trying to see Companies with the most Total Layoffs (as some companies have multiple rows)

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- Trying to see Locations with the most Total Layoffs (as some companies have multiple rows)

SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- Lets also look at how the lay off got affected in each country

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs2
GROUP BY country
ORDER BY 2 DESC;

-- So USA and India got affected the most though USA is ahead by a large margin

-- Lets take a look at date range for the data
SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs.layoffs2;

-- So this layoff data is from 2020 to 2023 (only 3 months in 2023)

-- now lets group it by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs2
GROUP BY Year(`date`)
ORDER BY 1 DESC;

-- since we had only 3 month data for 2023, its evident that it is going to surpass 2022 easily.

-- now lets see te stages and industries where layoffs were maximum

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs2
GROUP BY industry
ORDER BY 2 DESC;
-- consumer industry had most layoffs
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs2
GROUP BY stage
ORDER BY 2 DESC;

-- past IPO stage got massive layoffs

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. Top 3 for each year,  

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM world_layoffs.layoffs2
  GROUP BY company, years
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


-- Now lets take a look at Rolling Total of Layoffs Per Month

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

-- It answers the question: "How are layoffs accumulating month-over-month across the entire dataset?"

-- This shows that layoffs increased by nearly 10,000 to 20,000 each month

