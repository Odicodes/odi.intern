-- Data cleaning 
SELECT *
FROM layoffs;

-- Step 1 remove duplicates 
-- step 2 standardize the data (Correct spellings and make the data standard across the table)
-- step 3 Null values or Blank values 
-- step 4 Remove coulmns and rows that aren't neccessary (There are some instances in which you shouldn't)

CREATE TABLE layoffs_staging 
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

with duplicate_cte as 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging 
WHERE company = 'casper';

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging3;

INSERT INTO layoffs_staging3
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM layoffs_staging3
;

-- data standardization
-- finding issues in data then fixing it 

SELECT company, TRIM(company)
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging3
ORDER BY 1;
;

UPDATE layoffs_staging3
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`layoffs_staging3
FROM layoffs_staging3
;

UPDATE layoffs_staging3
SET `date` = str_to_date(`date`, '%m/%d/%Y' );

ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;

-- working with null and blank values 
SELECT * 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging3
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging3
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging3
WHERE company LIKE  'Bally%';

SELECT t1.industry, t2.industry
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
    AND t1.location = t2.location 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging3;

ALTER TABLE layoffs_staging3
DROP column row_num;


