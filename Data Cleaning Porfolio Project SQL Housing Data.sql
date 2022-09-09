/*

Cleaning Data in SQL Queries 

*/

Select *
From PorfolioProject.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, Convert(Date, SaleDate)
From PorfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)


ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

Select *
From PorfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PorfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))  as Address

From PorfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )  

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 




Select OwnerAddress
From PorfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',' ,'.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',' ,'.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',' ,'.') , 1)
From PorfolioProject.dbo.NashvilleHousing





ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' ,'.') , 3)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255); 


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' ,'.') , 2)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState NVARCHAR(255); 

Update NashvilleHousing
SET OWnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' ,'.') , 1)



Select *
From PorfolioProject.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No in "Sold as Vacant" field



Select Distinct(SoldAsVacant), Count(SoldasVacant)
From PorfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From PorfolioProject.dbo.NashvilleHousing


Update NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From PorfolioProject.dbo.NashvilleHousing





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




-- Remove Duplicates 

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num



From PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress 




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Delete Unused Columns


Select * 
From PorfolioProject.dbo.NashvilleHousing

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate