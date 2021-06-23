-- Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.[Nashville Housing]

-- Standardize Data Format

Select SaleDate, convert(date,Saledate)
From PortfolioProject.dbo.[Nashville Housing]

Update PortfolioProject.dbo.[Nashville Housing]
SET SaleDate = Convert(date,SaleDate)

--Showing 2nd way to convert Date format

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
Add SaleDateConverted Date;

Update PortfolioProject.dbo.[Nashville Housing]
SET SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
from PortfolioProject.dbo.[Nashville Housing]

-- Populate Porperty Address Date

Select *
from PortfolioProject.dbo.[Nashville Housing]
--Where PropertyAddress is null
order by ParcelID

Select ParcA.ParcelID, ParcA.PropertyAddress, ParcB.ParcelID, ParcB.PropertyAddress, ISNULL(ParcA.PropertyAddress, ParcB.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] ParcA
Join PortfolioProject.dbo.[Nashville Housing] ParcB
	on ParcA.ParcelID = ParcB.ParcelID
	AND ParcA.[UniqueID ] <> ParcB.[UniqueID ]
Where ParcA.PropertyAddress is null

Update ParcA
SET PropertyAddress = ISNULL(ParcA.PropertyAddress, ParcB.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] ParcA
Join PortfolioProject.dbo.[Nashville Housing] ParcB
	on ParcA.ParcelID = ParcB.ParcelID
	AND ParcA.[UniqueID ] <> ParcB.[UniqueID ]
Where ParcA.PropertyAddress is null

-- Breaking out Address into Individual "Address", "City" and "State"

Select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing]

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.[Nashville Housing]
SET PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.[Nashville Housing]
SET PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.[Nashville Housing]

-- Using Parse to break down Owner Address

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PortfolioProject.dbo.[Nashville Housing]

-- Changing Y/N to Yes and No in "Sold as Vacant" Column. This is to have only the "Yes" or "No" options in the dataset

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.[Nashville Housing]
Group by SoldAsVacant
order by SoldAsVacant

select soldasvacant
, case when soldasvacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From PortfolioProject.dbo.[Nashville Housing]

Update PortfolioProject.dbo.[Nashville Housing]
SET SoldAsVacant = case when soldasvacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

--Remove Duplicates In Dataset


with RowNumCTE AS(
Select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
From PortfolioProject.dbo.[Nashville Housing]
--order by ParcelID
)
SELECT *
From RowNumCTE
WHERE row_num > 1


-- Deleting Unused Columns

SELECT *
From PortfolioProject.dbo.[Nashville Housing]

ALTER TABLE PortfolioProject.dbo.[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




