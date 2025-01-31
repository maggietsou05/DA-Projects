-- Removing duplicates: looking with CTE
WITH duplicate_cte AS(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, date, stage, country, funds_raised_millions
	) AS row_num
FROM layoffs_staging)

SELECT *
FROM duplicate_cte
WHERE row_num > 1

-- Created a new table to remove duplicated columns
INSERT INTO layoffs_staging2

SELECT *, ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, date, stage, country, funds_raised_millions
	) AS row_num
FROM layoffs_staging;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing the data
SELECT DISTINCT company
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

ALTER TABLE layoffs_staging2
ALTER COLUMN funds_raised_millions TYPE numeric
USING funds_raised_millions::numeric

-- Standardizing the date
UPDATE layoffs_staging2
SET date = TO_DATE(date, 'MM/DD/YYYY');

ALTER TABLE layoffs_staging2
ALTER COLUMN date TYPE DATE
USING date::DATE;

-- Populate the nulls and blanks
SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
SET industry = t2.industry
FROM layoffs_staging2 t2
	WHERE t1.company = t2.company
	AND t1.industry IS NULL
	AND t2.industry IS NOT NULL;

-- Delete unuseful columns
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2
