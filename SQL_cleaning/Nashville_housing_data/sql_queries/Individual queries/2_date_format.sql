-- Standardize Date Format (Update Table as well)


SELECT
    TO_DATE(saledate, 'Month DD, YYYY') AS standardize_date
FROM
    nashville_housing_data_raw
LIMIT 100;

--Update the table
ALTER TABLE nashville_housing_data_raw
ALTER COLUMN saledate TYPE DATE
USING TO_DATE(saledate, 'Month DD, YYYY');

/* 
Once format and structure has been standardized, 
we cast type as DATE to finish this column
*/