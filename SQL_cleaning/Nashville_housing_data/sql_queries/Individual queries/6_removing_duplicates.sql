-- Remove duplicates across the table

WITH duplicates AS
(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY parcelid, propertyaddress, saledate, saleprice
            ORDER BY uniqueid
        ) AS row_num
    FROM
        nashville_housing_data_raw
) 
SELECT
    uniqueid,
    row_num
FROM 
    duplicates AS d
WHERE
    row_num > 1;


BEGIN;

WITH duplicates AS(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY parcelid, propertyaddress, saledate, SalePrice
            ORDER BY uniqueid
        ) AS row_num
    FROM
        nashville_housing_data_raw
) 

DELETE FROM nashville_housing_data_raw AS n
USING duplicates AS d
WHERE 
    n.uniqueid = d.uniqueid AND
    row_num > 1
RETURNING d.*;   -- to check what has been deleted.

COMMIT;

/*
The checking deleted affected rows is necessary.
Provides reassurance before committing to the deletion of the duplicated rows
*/