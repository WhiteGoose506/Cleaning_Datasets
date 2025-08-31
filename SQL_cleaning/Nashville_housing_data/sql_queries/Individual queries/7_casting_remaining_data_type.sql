-- Casting on the remaining data type.
-- But first, perform standardization on any misformatted records.

-- 1) Checking on saleprice then cast
SELECT 
    saleprice,
    REGEXP_REPLACE(TRIM(saleprice), '[^0-9]', '', 'g') AS standardized_salesprice
FROM nashville_housing_data_raw
WHERE saleprice;
-- Returns back 12 rows with wrong format + another column that shows the aftermath of the reformat.


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



-- 3) Checking on legalreference (Leave in TEXT)
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
-- '^[0-9]+(\.[0-9]+)?$' precaution to consider above and below the numeric decimal points
-- Returns 0 counts of alphabetized text or words

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



-- 5) Remaining columns looks like an interger.
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

/*
That marks the end of my cleaning session
Kindly Ignore Drop Column, I simply wanted to test, more of a personal self question and answer role
    > Was trying to think for myself if that particular columns was truly needed
    > Based on criticality as well as ranking the necessity against other columns
*/