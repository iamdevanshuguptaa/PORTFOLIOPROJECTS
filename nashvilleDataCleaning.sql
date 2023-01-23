-- Changing the table name coz it was too long...
ALTER TABLE nashville_housing_data_2013_2016 RENAME nashville;

--Checking out the whole dataset we have on nashville house data cleaning
SELECT *
FROM nashville;

SELECT SaleDate
FROM nashville;

-- Renaming average column
ALTER TABLE nashville
RENAME COLUMN Acreage TO Average;

-- Standardize Date format, not used in my process
SELECT SaleDate, CONVERT(SaleDate, DATE)
FROM nashville;

-- Standardize Date format, used in my process
SELECT DATE_FORMAT(STR_TO_DATE(SaleDate, '%m-%d-%Y') , '%Y-%m-%d')
FROM nashville;

UPDATE nashville
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%m-%d-%Y') , '%Y-%m-%d');

-- Checking whether PropertyAddress field have NULL values or not..
SELECT PropertyAddress
FROM nashville
WHERE PropertyAddress IS NULL;

-- demonstrating how to tackle null values if you want to populate them accurately. Using ISNULL(), We can perform this action....
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress , ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM nashville AS A
JOIN nashville AS B
    ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

-- If you are updating a table, use it's alias, not the original name since we are using SELF-JOIN here!!!
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM nashville AS A
JOIN nashville AS B
    ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

-- CHecking whether it is functioning properly or not we'll run the SELF-JOIN query again and this time, we must get an empty table as a result...
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM nashville AS A
JOIN nashville AS B
    ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

/* Breaking out Address into individual columns like address, city and state -> PropertyAddress
-- Address & City.....*/

SELECT SUBSTRING_INDEX(PropertyAddress, ',' , 1) AS Address, SUBSTRING_INDEX(PropertyAddress, ',' , -1) AS City, 
FROM nashville;

-- Creating two new columns for the address and city 
-- Address->
ALTER TABLE nashville
ADD PropertySpiltAddress VARCHAR(255);

UPDATE nashville
SET PropertySpiltAddress = SUBSTRING_INDEX(PropertyAddress, ',' , 1);

-- City->
ALTER TABLE nashville
ADD PropertySpiltCity VARCHAR(255);

UPDATE nashville
SET PropertySpiltCity = SUBSTRING_INDEX(PropertyAddress, ',' , -1);

SELECT PropertySpiltAddress, PropertySpiltCity
FROM nashville;

/* Breaking out Address into individual columns like address, city and state -> OwnerAddress
-- Address, City & State.....*/

SELECT SUBSTRING_INDEX(OwnerAddress, ',' , 1) AS Address, 
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',' , 2) , ',' , -1) AS City,  
SUBSTRING_INDEX(OwnerAddress, ',' , -1) AS State
FROM nashville;

-- Creating three new columns for the address, city & state 
-- Address->
ALTER TABLE nashville
ADD OwnerSpiltAddress VARCHAR(255);

UPDATE nashville
SET OwnerSpiltAddress = SUBSTRING_INDEX(OwnerAddress, ',' , 1);

-- City->
ALTER TABLE nashville
ADD OwnerSpiltCity VARCHAR(255);

UPDATE nashville
SET OwnerSpiltCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',' , 2) , ',' , -1) 

-- State->
ALTER TABLE nashville
ADD OwnerSpiltState VARCHAR(255);

UPDATE nashville
SET OwnerSpiltState = SUBSTRING_INDEX(OwnerAddress, ',' , -1) 

SELECT OwnerSpiltAddress, OwnerSpiltCity, OwnerSpiltState
FROM nashville;

-- Checking the 'SoldAsVacant' Field for some required changes....
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville
GROUP BY SoldAsVacant
ORDER BY 2;

-- Change Y and N to Yes and No in 'SoldAsVacant' Field....
SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM nashville;

UPDATE nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

-- Removing Duplicates.....
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY UniqueID) AS row_num
FROM nashville
)

DELETE d
FROM nashville AS d 
INNER JOIN RowNumCte AS r 
    ON d.UniqueID = r.UniqueID
WHERE row_num > 1;

-- For checking if the duplicate data is gone or not!!
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY UniqueID) AS row_num
FROM nashville
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Deleting unused columns
ALTER TABLE nashville
DROP COLUMN OwnerAddress, 
DROP COLUMN PropertyAddress, 
DROP COLUMN TaxDistrict; 

ALTER TABLE nashville
DROP COLUMN SaleDate; 