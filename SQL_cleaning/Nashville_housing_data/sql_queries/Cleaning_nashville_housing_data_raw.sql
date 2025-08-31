-- 1) Intro to see overview and nulls


SELECT * 
FROM nashville_housing_data_raw;

-- Checking for nulls in each table column
SELECT 'UniqueID' AS table_column_name, COUNT(*) - COUNT(UniqueID) AS null_count FROM nashville_housing_data_raw
UNION ALL
SELECT 'ParcelID', COUNT(*) - COUNT(ParcelID) FROM nashville_housing_data_raw
UNION ALL
SELECT 'LandUse', COUNT(*) - COUNT(LandUse) FROM nashville_housing_data_raw
UNION ALL
SELECT 'PropertyAddress', COUNT(*) - COUNT(PropertyAddress) FROM nashville_housing_data_raw
UNION ALL
SELECT 'SaleDate', COUNT(*) - COUNT(SaleDate) FROM nashville_housing_data_raw
UNION ALL
SELECT 'SalePrice', COUNT(*) - COUNT(SalePrice) FROM nashville_housing_data_raw
UNION ALL
SELECT 'LegalReference', COUNT(*) - COUNT(LegalReference) FROM nashville_housing_data_raw
UNION ALL
SELECT 'SoldAsVacant', COUNT(*) - COUNT(SoldAsVacant) FROM nashville_housing_data_raw
UNION ALL
SELECT 'OwnerAddress', COUNT(*) - COUNT(OwnerAddress) FROM nashville_housing_data_raw
UNION ALL
SELECT 'Acreage', COUNT(*) - COUNT(Acreage) FROM nashville_housing_data_raw
UNION ALL
SELECT 'TaxDistrict', COUNT(*) - COUNT(TaxDistrict) FROM nashville_housing_data_raw
UNION ALL
SELECT 'LandValue', COUNT(*) - COUNT(LandValue) FROM nashville_housing_data_raw
UNION ALL
SELECT 'BuildingValue', COUNT(*) - COUNT(BuildingValue) FROM nashville_housing_data_raw
UNION ALL
SELECT 'TotalValue', COUNT(*) - COUNT(TotalValue) FROM nashville_housing_data_raw
UNION ALL
SELECT 'YearBuilt', COUNT(*) - COUNT(YearBuilt) FROM nashville_housing_data_raw
UNION ALL
SELECT 'Bedrooms', COUNT(*) - COUNT(Bedrooms) FROM nashville_housing_data_raw
UNION ALL
SELECT 'FullBath', COUNT(*) - COUNT(FullBath) FROM nashville_housing_data_raw
UNION ALL
SELECT 'HalfBath', COUNT(*) - COUNT(HalfBath) FROM nashville_housing_data_raw
ORDER BY null_count;
/* 
- 11/18 columns have nulls
- Only PropertyAddress has the least amount of nulls, at 29 row counts, therefore this problem is addressable
- Remaining columns have nulls with more than 30,000 rows should we eliminate-update table?
    > Or extract without the column name since it could affect the other columns?
*/;



-- 2) Standardize date format (Update table as well)

SELECT
    TO_DATE(saledate, 'Month DD, YYYY') AS standardize_date
FROM
    nashville_housing_data_raw
LIMIT 100;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN saledate TYPE DATE
USING TO_DATE(saledate, 'Month DD, YYYY');



-- 3) Imputate populate property address data (Since propertyAddress has only 29 rows of nulls value)

SELECT 
    a.parcelid,
    a.propertyaddress,
    b.parcelid,
    b.propertyaddress,
    COALESCE(b.propertyaddress,a.propertyaddress) AS updatednull_propertyaddress
FROM 
    nashville_housing_data_raw AS a
INNER JOIN nashville_housing_data_raw AS b On 
    (a.parcelid = b.parcelid AND
    a.uniqueid <> b.uniqueid)
WHERE b.propertyaddress IS NULL;


UPDATE nashville_housing_data_raw AS b
SET propertyaddress = a.propertyaddress
FROM 
    nashville_housing_data_raw AS a
WHERE 
    a.parcelid = b.parcelid AND
    a.uniqueid <> b.uniqueid AND
    b.propertyaddress IS NULL;



-- 4) Splitting out propertyaddress and owneraddress into individual columns (Address, City, State) where applicable

SELECT 
    propertyaddress,
    owneraddress
FROM 
    nashville_housing_data_raw;


SELECT
    TRIM(SPLIT_PART(propertyaddress, ',', 1)) AS property_street_address,
    TRIM(SPLIT_PART(propertyaddress, ',', 2)) AS property_city
FROM nashville_housing_data_raw;


BEGIN;

ALTER TABLE nashville_housing_data_raw
ADD COLUMN property_street_address VARCHAR(255),
ADD COLUMN property_city VARCHAR(255);

UPDATE nashville_housing_data_raw
SET property_street_address = TRIM(SPLIT_PART(propertyaddress, ',', 1)),
property_city = TRIM(SPLIT_PART(propertyaddress, ',', 2));

SELECT *
FROM nashville_housing_data_raw;

COMMIT;



SELECT
    TRIM(SPLIT_PART(owneraddress, ',', 1)) AS owner_street_address,
    TRIM(SPLIT_PART(owneraddress, ',', 2)) AS owner_city,
    TRIM(SPLIT_PART(owneraddress, ',', 3)) AS owner_state
FROM nashville_housing_data_raw;


BEGIN;

ALTER TABLE nashville_housing_data_raw
ADD COLUMN owner_street_address VARCHAR(255),
ADD COLUMN owner_city VARCHAR(255),
ADD COLUMN owner_state VARCHAR(255);


UPDATE nashville_housing_data_raw
SET owner_street_address = TRIM(SPLIT_PART(owneraddress, ',', 1)),
owner_city = TRIM(SPLIT_PART(owneraddress, ',', 2)),
owner_state = TRIM(SPLIT_PART(owneraddress, ',', 3));

SELECT *
FROM nashville_housing_data_raw;

COMMIT;



-- 5) Standardized 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" field

SELECT 
    DISTINCT(soldasvacant),
    COUNT (*) AS total,
    CASE
        WHEN soldasvacant = 'N' THEN 'No'
        WHEN soldasvacant = 'Y' THEN 'Yes'
        ELSE soldasvacant
    END AS cleaned_soldasvacant
FROM 
    nashville_housing_data_raw
GROUP BY
    soldasvacant
-- N:399, No:51403, Y:52, Yes:4623


BEGIN;

UPDATE nashville_housing_data_raw
SET soldasvacant = 
    CASE
        WHEN soldasvacant = 'N' THEN 'No'
        WHEN soldasvacant = 'Y' THEN 'Yes'
        ELSE soldasvacant
    END
;

SELECT 
    DISTINCT(soldasvacant),
    COUNT (*)
FROM 
    nashville_housing_data_raw
GROUP BY
    soldasvacant;
-- No:51802, Yes:4675

COMMIT;



-- 6) Remove duplicates across the table

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



-- Casting the remaining data type, check for standardization before casting.

-- 1) Checking on saleprice then cast
BEGIN;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN saleprice TYPE INT
USING CASE
  WHEN regexp_replace(trim(saleprice), '[^0-9]', '', 'g') ~ '^[0-9]+$'
    THEN regexp_replace(trim(saleprice), '[^0-9]', '', 'g')::INT
  ELSE NULL
END;

-- To check if above standardization works correctly
SELECT
    COUNT(*) as failed_conversion
FROM
    nashville_housing_data_raw
WHERE
    saleprice IS NULL;
-- return count = 0

COMMIT;



-- 2) Checking on landuse (Leave in TEXT)
SELECT
    landuse,
    COUNT(*) AS total_variations_count
FROM
    nashville_housing_data_raw
GROUP BY
    landuse
ORDER BY
    landuse;
/* 
Looks good, returned 39 rows, ONLY 3 rows looks like a duplicate
while the remaining rows appears to be in different category
*/

UPDATE nashville_housing_data_raw
SET landuse = 'VACANT RESIDENTIAL LAND'
WHERE landuse = 'VACANT RESIENTIAL LAND' OR
        landuse = 'VACANT RES LAND';
-- Looks great but leave as TEXT



-- 3) Checking on legalreference(Leave in TEXT)
SELECT 
    legalreference, 
    COUNT(*) AS total_variations_count 
FROM nashville_housing_data_raw 
GROUP BY legalreference 
ORDER BY legalreference;
-- Displayed 52703 rows, there's duplicates 
-- Looks great but leave as TEXT



-- 4) Check on acreage before casting
SELECT acreage
FROM nashville_housing_data_raw
WHERE TRIM(acreage) !~ '^[0-9]+(\.[0-9]+)?$';
-- no text found, though all looks like floating point.

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN acreage TYPE NUMERIC
USING CASE
    WHEN trim(acreage) ~ '^[0-9]+(\.[0-9]+)?$'
        THEN trim(acreage)::NUMERIC
    ELSE NULL
END;

SELECT acreage
FROM nashville_housing_data_raw
WHERE acreage IS NULL;



-- 5) Remaining columns looks like intergers
-- Just do safety trimming incase.

-- Safe conversion of integer-like columns
BEGIN;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN landvalue TYPE INT
USING CASE
    WHEN trim(landvalue) ~ '^[0-9]+$'
        THEN trim(landvalue)::INT
    ELSE NULL
END;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN buildingvalue TYPE INT
USING CASE
    WHEN trim(buildingvalue) ~ '^[0-9]+$'
        THEN trim(buildingvalue)::INT
    ELSE NULL
END;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN totalvalue TYPE INT
USING CASE
    WHEN trim(totalvalue) ~ '^[0-9]+$'
        THEN trim(totalvalue)::INT
    ELSE NULL
END;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN yearbuilt TYPE INT
USING CASE
    WHEN trim(yearbuilt) ~ '^[0-9]+$'
        THEN trim(yearbuilt)::INT
    ELSE NULL
END;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN bedrooms TYPE INT
USING CASE
    WHEN trim(bedrooms) ~ '^[0-9]+$'
        THEN trim(bedrooms)::INT
    ELSE NULL
END;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN fullbath TYPE INT
USING CASE
    WHEN trim(fullbath) ~ '^[0-9]+$'
        THEN trim(fullbath)::INT
    ELSE NULL
END;

ALTER TABLE nashville_housing_data_raw
ALTER COLUMN halfbath TYPE INT
USING CASE
    WHEN trim(halfbath) ~ '^[0-9]+$'
        THEN trim(halfbath)::INT
    ELSE NULL
END;

COMMIT;


-- Delete Unused Columns


SELECT *
FROM nashville_housing_data_raw;

ALTER TABLE nashville_housing_data_raw
DROP COLUMN saledate,
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict;

































