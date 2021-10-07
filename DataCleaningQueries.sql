Select * from DataCleaningProject.dbo.NashvilleHousing

-- Standardize date format

Select SaleDate, CONVERT(Date, SaleDate)
From dbo.NashvilleHousing

Alter table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------
--Populate Property address data

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

---------------------------
-- Break out address into individual Columns (Address, City, State)

-- Adding the address
ALTER Table NashvilleHousing
Add PropertySplitAddress VARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

--Adding the city
ALTER Table NashvilleHousing
Add PropertySplitCity VARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

------------------------
--Break OwnerAddress into Address, City and State
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

------------------------
-- Change Y and N to Yes and No in "SoldAsVacant" field

Update DataCleaningProject.dbo.NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
					) row_num
From DataCleaningProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

------------------------
-- Delete Unused columns

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


