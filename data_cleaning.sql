-- Step 1: Create a staging table for cleaning the data safely
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- Populate the staging table with data from the original table
INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- Step 2: Check for duplicates in the staging table
SELECT company, industry, total_laid_off, `date`,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, `date`
       ) AS row_num
FROM world_layoffs.layoffs_staging;

-- Identify rows with duplicates by looking for row numbers greater than 1
SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- Remove duplicates by keeping only the first occurrence
WITH DELETE_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
    FROM DELETE_CTE
) AND row_num > 1;

-- Step 3: Standardize the `industry` column
-- Update blank values in `industry` to NULL
UPDATE world_layoffs.layoffs_staging
SET industry = NULL
WHERE industry = '';

-- Populate null values in `industry` based on other rows with the same company
UPDATE world_layoffs.layoffs_staging t1
JOIN world_layoffs.layoffs_staging t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Standardize variations in industry names (e.g., 'Crypto Currency' -> 'Crypto')
UPDATE world_layoffs.layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Step 4: Standardize the `country` column

-- Remove trailing periods in country names
UPDATE world_layoffs.layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- Step 5: Convert the `date` column to proper DATE format
-- Update the `date` column values using STR_TO_DATE
UPDATE world_layoffs.layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the datatype of the `date` column to DATE
ALTER TABLE world_layoffs.layoffs_staging
MODIFY COLUMN `date` DATE;

-- Step 6: Handle null values and remove rows with insufficient data
-- Delete rows where both `total_laid_off` and `percentage_laid_off` are null
DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Step 7: Final cleanup
-- Drop temporary columns like `row_num` if they exist
ALTER TABLE world_layoffs.layoffs_staging
DROP COLUMN row_num;

-- Verify the cleaned data
SELECT * 
FROM world_layoffs.layoffs_staging;
