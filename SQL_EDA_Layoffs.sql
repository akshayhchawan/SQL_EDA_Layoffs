-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging2;

-- Checking number of highest layoffs and perecent of highest layoff
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Total Period 
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Companies which have 100% layoffs
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Total layoffs in comapnies 
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- top 10 companies by layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

-- total layoffs by Industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- total layoffs by Country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- total layoffs by Year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- total layoffs by funding
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average Percentage of Layoffs by Industry
SELECT industry, AVG(percentage_laid_off)
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY AVG(percentage_laid_off) DESC;

-- Layoffs by Company Size 
SELECT company, AVG(funds_raised_millions), SUM(total_laid_off) 
FROM layoffs_staging2
WHERE company IS NOT NULL
GROUP BY company
ORDER BY SUM(total_laid_off)  DESC;

-- Rolling total laid off by month

SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_total as(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) as roling_total
FROM Rolling_total;

-- Total laid off by companies per year top 5
WITH company_year (company, years, total_laid_off)AS(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC)
, company_year_rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS rankings
FROM company_year
WHERE years IS NOT NULL
ORDER BY rankings ASC)

SELECT *
FROM company_year_rank
WHERE rankings <=5;
