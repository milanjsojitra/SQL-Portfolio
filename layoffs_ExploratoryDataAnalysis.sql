-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- data date scope
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- most laid off
SELECT *
FROM layoffs_staging2
ORDER BY total_laid_off DESC;

-- went completely under; by number of people
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- went completely under; by funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- specific company
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Amazon';

-- total laid off by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- specific industry
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Retail'
ORDER BY total_laid_off DESC;

-- total laid off by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- specific country
SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States'
ORDER BY total_laid_off DESC;

-- total laid off by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- total laid off by date
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- total laid off by year & month
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

-- total laid off by year & month, with rolling total
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1
)
SELECT `month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;

-- total laid off by year & month, and by industry
SELECT SUBSTRING(`date`,1,7) AS `month`, industry, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`, industry
ORDER BY 1;

-- total laid off by year, and by industry
SELECT YEAR(`DATE`), industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`DATE`), industry
ORDER BY 1;

-- total laid off with scope
SELECT
	MIN(`DATE`),
	MAX(`DATE`),
	SUM(total_laid_off) total_laid_off
FROM layoffs_staging2
ORDER BY 1 DESC;

-- total laid off by stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- total laid off by year, and by industry add specific industry
SELECT YEAR(`DATE`), industry, SUM(total_laid_off)
FROM layoffs_staging2
WHERE industry LIKE 'Crypto'
GROUP BY YEAR(`DATE`), industry
ORDER BY 1;

-- total laid off by year, and by specific company
SELECT YEAR(`DATE`), company, SUM(total_laid_off)
FROM layoffs_staging2
WHERE company LIKE 'airbnb'
GROUP BY YEAR(`DATE`), company
ORDER BY 1;

-- total laid off by year & month & specific company, with rolling total
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, company, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
AND company LIKE 'Amazon'
GROUP BY `month`, company
ORDER BY 1
)
SELECT `month`, company, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;

-- total laid off by year & specific company, with rolling total
WITH Rolling_Total AS
(
SELECT YEAR(`date`) AS `year`, company, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
AND company LIKE 'Amazon'
GROUP BY `year`, company
ORDER BY 1
)
SELECT `year`, company, total_off,
SUM(total_off) OVER(ORDER BY `year`) AS rolling_total
FROM Rolling_Total;

-- total laid off by year, company, ranked
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Ranked AS
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Ranked
WHERE Ranking <= 5
;

-- total laid off by year, industry, ranked
WITH Industry_Year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Ranked AS
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Ranked
WHERE Ranking <= 5
;
