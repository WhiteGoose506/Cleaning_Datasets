-- Splitting out propertyaddress and owneraddress into Individual Columns (Address, City, State) where applicable
-- While the data looks useful, there's too many feasable variation, white space, different wordings, etc..
-- Why not Trim and seperate them to increase the integrity of the data by making the split data usesable in EDA process.


SELECT 
    propertyaddress,
    owneraddress
FROM 
    nashville_housing_data_raw;


-- Focusing on propertyaddress first.
SELECT
    TRIM(SPLIT_PART(propertyaddress, ',', 1)) AS property_street_address,
    TRIM(SPLIT_PART(propertyaddress, ',', 2)) AS property_city
FROM nashville_housing_data_raw;


-- Here is when I decided to use BEGIN instead, just to make sure table looks alright before commiting.
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


-- Focusing on owneraddress last.
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

/*
Now I think about it...I could have actually join the two columns together and wrote something like below:


BEGIN;

ALTER TABLE nashville_housing_data_raw
ADD COLUMN property_street_address VARCHAR(255),
ADD COLUMN property_city VARCHAR(255),
ADD COLUMN owner_street_address VARCHAR(255),
ADD COLUMN owner_city VARCHAR(255),
ADD COLUMN owner_state VARCHAR(255);

UPDATE nashville_housing_data_raw
SET property_street_address = TRIM(SPLIT_PART(propertyaddress, ',', 1)),
    property_city = TRIM(SPLIT_PART(propertyaddress, ',', 2)),
    owner_street_address = TRIM(SPLIT_PART(owneraddress, ',', 1)),
    owner_city = TRIM(SPLIT_PART(owneraddress, ',', 2)),
    owner_state = TRIM(SPLIT_PART(owneraddress, ',', 3));

SELECT
    property_street_address,
    property_city,
    owner_street_address,
    owner_city,
    owner_state
FROM
    nashville_housing_data_raw;

COMMIT/ROLLBACK;


Even if I were to messed up my numbering or focusing wrong columns during query, 
I can simply check and rollback if I want to.
*/