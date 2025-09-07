SELECT *
FROM layoffs;

-- Create Staging Table

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Magnify; Check each row

SELECT *
FROM layoffs_staging
WHERE company = 'Wildlife Studios';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- create a new staging table because issues with CTEs

CREATE TABLE `layoffs_staging2` (
  `company` VARCHAR(255) DEFAULT NULL,
  `location` VARCHAR(255) DEFAULT NULL,
  `industry` VARCHAR(255) DEFAULT NULL,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` VARCHAR(255) DEFAULT NULL,
  `date` VARCHAR(255) DEFAULT NULL,
  `stage` VARCHAR(255) DEFAULT NULL,
  `country` VARCHAR(255) DEFAULT NULL,
  `funds_raised_millions` VARCHAR(255) DEFAULT NULL,
  `row_num` INT
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;


-- insert new relevant column for duplicates
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- delete duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- Standardize the Data

-- trim evident whitespaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- standardize some values that are basically same
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Some values ending in unrelated characters eg periods
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Turn date column into date datatype
SELECT *
FROM layoffs_staging2;

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Removing carriage return characters (Enter) from initial import
SELECT funds_raised_millions
FROM layoffs_staging2
WHERE funds_raised_millions LIKE '%\r';

UPDATE layoffs_staging2
SET funds_raised_millions = REPLACE(funds_raised_millions, '\r', '');

SELECT funds_raised_millions
FROM layoffs_staging2;


-- Turn funds_raised_millions column into INT

SELECT funds_raised_millions
FROM layoffs_staging2
ORDER BY 1 DESC;

UPDATE layoffs_staging2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL';

ALTER TABLE layoffs_staging2
MODIFY COLUMN funds_raised_millions INT;

-- NULL/Blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'AirBNB';

-- Populating NULL/Blank Values with known data
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

/* Had TO turn blanks TO NULL VALUES because it ran INTO issues
when we tried to update with a where clause that has an OR */

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

-- Remove rows with no value to us; in this case, where the relevant values are NULL

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- Remove Any Columns

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;