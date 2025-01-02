## Overview
This project demonstrates SQL-based data cleaning techniques on a dataset of global layoffs in 2022, sourced from [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022). The goal is to clean and prepare the data for analysis by addressing duplicates, null values, and inconsistencies.

## Dataset Fields
- `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`
- `date`, `stage`, `country`, `funds_raised_millions`

## Key Steps
1. **Duplicate Removal**: Identified and removed duplicates using `ROW_NUMBER()`.
2. **Standardization**: Corrected inconsistencies in `industry` and `country` fields.
3. **Null Handling**: Replaced blanks with `NULL` and filled missing `industry` values based on company data.
4. **Optimization**: Dropped rows with missing critical values and ensured correct data types.
