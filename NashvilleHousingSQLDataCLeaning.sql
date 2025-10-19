
Select *
From [Portfolio Project]..NashvilleHousing


--Standardize Date Format
Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add SaleDateConverted Date;

Update [Portfolio Project]..NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data
Select *
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From [Portfolio Project]..NashvilleHousing A
JOIN [Portfolio Project]..NashvilleHousing B
    On A.ParcelID = B.ParcelID
    AND A.[UniqueID ] <> B.[UniqueID]
Where A.PropertyADDRESS is null

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From [Portfolio Project]..NashvilleHousing A
JOIN [Portfolio Project]..NashvilleHousing B
    On A.ParcelID = B.ParcelID
    AND A.[UniqueID ] <> B.[UniqueID]
Where A.PropertyADDRESS is null


--Breaking Out PropertyAddress Into Individual Columns (Addredd, City, State)
Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select OwnerAddress
From [Portfolio Project]..NashvilleHousing
--Where   OwnerAddress is not null

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From [Portfolio Project]..NashvilleHousing
Where   OwnerAddress is not null

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set PropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


--Change Y And N To Yes And No In "Sold As Vacant" Field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant 
       END
  From [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant 
       END


--Remove Duplicates
WITH RowNumCTE AS (
Select *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 Order By
                    UniqueID
                    ) row_num
From [Portfolio Project]..NashvilleHousing
--Order by ParcelID
)
Select*
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress


--Delete Unused Columns
Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP Column SaleDate











