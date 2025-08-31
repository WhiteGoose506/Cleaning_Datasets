-- Create staging table as TEXT
CREATE TABLE public.uncleaned_nashville_housing_data_raw
( 
    UniqueID        INT     PRIMARY KEY, 
    ParcelID        TEXT,
    LandUse         TEXT,
    PropertyAddress TEXT,
    SaleDate        TEXT,
    SalePrice       TEXT,
    LegalReference  TEXT,
    SoldAsVacant    TEXT,
    OwnerName       TEXT,
    OwnerAddress    TEXT,
    Acreage         TEXT,
    TaxDistrict     TEXT,
    LandValue       TEXT,
    BuildingValue   TEXT,
    TotalValue      TEXT,
    YearBuilt       TEXT,
    Bedrooms        TEXT,
    FullBath        TEXT,
    HalfBath        TEXT 
);



-- Set ownership of the tables to the postgres user
ALTER TABLE public.uncleaned_nashville_housing_data_raw OWNER to postgres;



-- Copy and load csv file into table
COPY public.uncleaned_nashville_housing_data_raw
FROM 'C:\Users\Haiza\Desktop\Portfolio\Datasets\Uncleaned_raw_data_file\uncleaned_nashville_housing_data_raw.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');



-- Rename table names;
ALTER TABLE public.uncleaned_nashville_housing_data_raw
RENAME TO nashville_housing_data_raw;



-- Cross-check with last 5 uniqueid inside the raw csv;
SELECT *
FROM (
    SELECT *
    FROM public.nashville_housing_data_raw
    ORDER BY UniqueID
    LIMIT 5
) first5
UNION ALL
SELECT *
FROM (
    SELECT *
    FROM public.nashville_housing_data_raw
    ORDER BY UniqueID DESC
    LIMIT 5
) last5
ORDER BY UniqueID;