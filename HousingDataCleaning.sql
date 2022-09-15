-- This project will show you some basic methods to clean housing data with SQL
-- By Yaping on 14/09/2022


-- Review data

SELECT TOP 10 *
FROM NashvilleHousing..NashvilleHousing

-- 1. Try to change and save the datatype of SaleDate

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

-- Aleternatively, you can do this another way by adding a new column

ALTER TABLE NashvilleHousing
ADD ConvertedSaleDate DATE

UPDATE NashvilleHousing
SET ConvertedSaleDate = CONVERT(date, SaleDate)

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing..NashvilleHousing

-- 2. Check the NULL value of PropertyAddress
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- Populate the NULL with the same ParcelID
-- First, find the null rows
SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing a
JOIN NashvilleHousing..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL

-- Then, update the table a by populate the values from  table b
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing a
JOIN NashvilleHousing..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL

-- 3. Seperate the property address into 2 columns: address, city
SELECT TOP 10 *
FROM NashvilleHousing..NashvilleHousing 

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS SPropertyAddress
, CHARINDEX(',', PropertyAddress)
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) ) AS SPropertyCity
FROM NashvilleHousing..NashvilleHousing 

-- Add a new column called address
ALTER TABLE NashvilleHousing..NashvilleHousing 
ADD SPropertyAddress NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing 
SET SPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- Add a new column called city
ALTER TABLE NashvilleHousing..NashvilleHousing 
ADD SPropertyCity NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing 
SET SPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) )

SELECT TOP 10 *
FROM NashvilleHousing..NashvilleHousing 

-- 4. Seperate the OwnerAddress into 3 columns: address, city, STATE

SELECT TOP 10 OwnerAddress
FROM NashvilleHousing..NashvilleHousing

-- Split the column
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS SOwnerState
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS SOwnerCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS SOwnerAddress
FROM NashvilleHousing..NashvilleHousing

-- Add the splitted columns
ALTER TABLE NashvilleHousing..NashvilleHousing
ADD SOwnerAddress NVARCHAR(255)

UPDATE NashvilleHousing..NashvilleHousing
SET SOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD SOwnerCity NVARCHAR(255)

UPDATE NashvilleHousing..NashvilleHousing
SET SOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD SOwnerState NVARCHAR(255)

UPDATE NashvilleHousing..NashvilleHousing
SET SOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Check the results
SELECT TOP 10 *
FROM NashvilleHousing..NashvilleHousing

--5. Clean the SoldAsVacant, unify the Yes and Y as Yes (No and N as No) 

-- Check the values of SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

-- Replace the Y with Yes and N with No
SELECT SoldAsVacant
,    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant 
    END

FROM NashvilleHousing..NashvilleHousing

UPDATE NashvilleHousing..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant 
                   END


-- 6. Check the duplicated rows, and remove them.

WITH RowNumberCTE AS(
SELECT *
, ROW_NUMBER() OVER (
    PARTITION BY ParcelID, 
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) AS Row_num
FROM NashvilleHousing..NashvilleHousing
)

SELECT *
FROM RowNumberCTE
WHERE Row_num > 1

DELETE
FROM RowNumberCTE
WHERE Row_num >1

-- Drop some unuseful coloumns

SELECT *
FROM NashvilleHousing..NashvilleHousing

ALTER TABLE NashvilleHousing..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress
