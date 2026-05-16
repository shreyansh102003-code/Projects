-- SQL Project - Data Cleaning

-- Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT *
FROM world_layoffs.Layoffs_raw;

CREATE TABLE world_layoffs.layoffs
LIKE World_layoffs.Layoffs_raw;

SELECT *
FROM world_layoffs.layoffs;

INSERT world_layoffs.layoffs
SELECT *
FROM World_layoffs.Layoffs_raw;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM  world_layoffs.layoffs
)
SELECT *
FROM Duplicate_cte 
WHERE row_num > 1;

SELECT *
FROM world_layoffs.layoffs
WHERE company = 'Casper';

-- we have to create new table as CTE's dont allow updating data, so we create through right clicking layoffs table, then copy to clipboard, then create statement, then paste

CREATE TABLE world_layoffs.layoffs2 (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO world_layoffs.layoffs2
SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM world_layoffs.layoffs;

-- now that we have this we can delete rows were row_num is greater than 2

DELETE FROM world_layoffs.layoffs2
WHERE row_num >= 2;

SELECT * 
FROM world_layoffs.layoffs2;

-- check problems in each column one by one

-- company check

SELECT Company
From world_layoffs.layoffs2;

-- trim the company names 

UPDATE world_layoffs.layoffs2
SET company = TRIM(company);

SELECT * 
FROM world_layoffs.layoffs2;

-- location check

SELECT DISTINCT location
From world_layoffs.layoffs2;

SELECT * 
FROM world_layoffs.layoffs2;
-- no problem, # location 'DÃ¼sseldorf', 'FlorianÃ³polis'can be a problem

-- industry check

SELECT DISTINCT industry
From world_layoffs.layoffs2;
-- 2 null/blank values and cryptocurrency has 3 different instances which should be updated 
UPDATE world_layoffs.layoffs2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
SELECT * 
FROM world_layoffs.layoffs2;

-- no need to check numeric data, so start with date now

SELECT DISTINCT date
From world_layoffs.layoffs2;

-- date is in a text format right now, we can update it to date format in the following manner

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs2;
UPDATE world_layoffs.layoffs2
SET `date` = STR_TO_DATE(`date`, '%m-%d-%Y');
ALTER TABLE world_layoffs.layoffs2
MODIFY COLUMN `date` DATE;
SELECT * 
FROM world_layoffs.layoffs2;

-- stage check

SELECT DISTINCT stage
From world_layoffs.layoffs2;

-- looks fine

SELECT * 
FROM world_layoffs.layoffs2;

-- country check

SELECT DISTINCT country
From world_layoffs.layoffs2;

-- united states is being repeated two times, so update

UPDATE world_layoffs.layoffs2
SET country = 'United States'
WHERE country LIKE 'United States%';
SELECT * 
FROM world_layoffs.layoffs2;

-- Handling null and blank values

-- check null values are in which column. They are present in industry, total_laid_off, percentage_laid_off, date, funds_raised_millions

-- first step is converting all blanks to null values

UPDATE world_layoffs.layoffs2
SET industry  = NULL
WHERE industry = '';
UPDATE world_layoffs.layoffs2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = '';

-- lets try mass imputation technique to fill the null values i.e. fill in missing information 

-- by leveraging the relationships and patterns already present in the wider dataset

-- now lets take a look at null values in text first i.e. industry. 

SELECT * 
FROM world_layoffs.layoffs2
WHERE industry IS NULL;

-- We have four industry with null values, lets search them on by one

SELECT *
FROM world_layoffs.layoffs2
WHERE company LIKE 'Bally%';

-- nothing can be done here

SELECT *
FROM world_layoffs.layoffs2
WHERE company LIKE 'airbnb%';

-- it has two entries one with null industry and other is not null

-- it looks like airbnb is a travel, but this one just isn't populated.

-- I'm sure it's the same for the others. What we can do is

-- write a query that if there is another row with the same company name, 

-- it will update it to the non-null industry values

-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- If you have a column like industry where some rows are NULL but you can find the correct value 

-- in another row for the same company, use a Self-Join.

UPDATE world_layoffs.layoffs2 t1
JOIN world_layoffs.layoffs2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's 

-- was the only one without a populated row to populate this null values

SELECT *
FROM world_layoffs.layoffs2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Identify columns and rows that we need to remove

SELECT *
FROM world_layoffs.layoffs2
WHERE total_laid_off IS NULL;

-- where total laid off and % laid off are null they are uselees and can be removed

SELECT *
FROM world_layoffs.layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
DELETE FROM world_layoffs.layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
SELECT * 
FROM world_layoffs.layoffs2;

-- Lets drop the row num column too

ALTER TABLE world_layoffs.layoffs2
DROP COLUMN row_num;
SELECT * 
FROM world_layoffs.layoffs2;