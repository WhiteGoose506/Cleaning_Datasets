-- Standardized Y and N to Yes and No in "Sold as Vacant" field
-- During rough inspection of the data, I spotted some weird formatting like 'N'

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
-- Before inserting CASE clause, my result displayed N:399, No:51403, Y:52, Yes:4623


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