-- Imputate Populate Property Address data 
-- Since PropertyAddress has only 29 rows of nulls value


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

/*
The coalesce part is not necessary, but I wanted to include for visualization purpose how it would fill up.
It's only later in next query I asked myself "Is there a temporary updated table I could look at before permanently updating"
    > and there is, BEGIN; Your query; COMMIT/ROLLBACK;
*/