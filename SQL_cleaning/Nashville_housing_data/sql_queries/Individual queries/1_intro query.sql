-- Overall table (56477 rows)
-- Eyeballing the data to see structure


SELECT * 
FROM nashville_housing_data_raw;


-- Overseeing nulls value, then identify easier addressable problems.
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