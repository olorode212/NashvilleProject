/*
Cleaning Data in SQL Queries

*/

SELECT *
FROM [NashvilleProject].[dbo].[NashvilleHousing]

  --Standardize Date Format

  SELECT SaleDateConverted, CONVERT(Date,SaleDate)
  FROM [NashvilleProject].[dbo].[NashvilleHousing]

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

  --- Populate Property Address Data

  SELECT *
  FROM [NashvilleProject].[dbo].[NashvilleHousing]
  --Where PropertyAddress is null
  order by ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
FROM [NashvilleProject].[dbo].[NashvilleHousing] a
Join [NashvilleProject].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
FROM [NashvilleProject].[dbo].[NashvilleHousing] a
Join [NashvilleProject].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

---- Breaking out Address into individual colums (Address, City, State)

SELECT *
  FROM [NashvilleProject].[dbo].[NashvilleHousing]

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [NashvilleProject].[dbo].[NashvilleHousing]

Alter Table NashvilleHousing
Add ProperSplitAddress Nvarchar(225);

Update NashvilleHousing
Set ProperSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertyCity Nvarchar(225);

Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




Select
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
FROM [NashvilleProject].[dbo].[NashvilleHousing]



Alter Table NashvilleHousing
Add OwnerPropertyCity Nvarchar(225);

Update NashvilleHousing
Set OwnerPropertyCity = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerPropertyAddress Nvarchar(225);

Update NashvilleHousing
Set OwnerPropertyAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerPropertyState Nvarchar(225);

Update NashvilleHousing
Set OwnerPropertyState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


Select *
FROM [NashvilleProject].[dbo].[NashvilleHousing]

---Change 1 and 0 to Yes and No in 'Sold as vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [NashvilleProject].[dbo].[NashvilleHousing]
Group by SoldAsVacant
Order by SoldAsVacant


Select SoldAsVacant
, Case When SoldAsVacant = 0 Then 'No'
   When SoldAsVacant = 1 Then 'Yes'
   Else 'Unknown'
   End As SoldAsVacant
FROM [NashvilleProject].[dbo].[NashvilleHousing]


ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(3);



Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 0 Then 'No'
   When SoldAsVacant = 1 Then 'Yes'
   Else 'Unknown'
   End 
FROM [NashvilleProject].[dbo].[NashvilleHousing]


---Remove Duplicates
With RowNumCTE AS (
Select *,
   ROW_NUMBER() over (
   Partition by ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By 
				  UniqueID
				  ) row_num
FROM [NashvilleProject].[dbo].[NashvilleHousing]
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--- Delete Unused Columns

Select *
FROM [NashvilleProject].[dbo].[NashvilleHousing]


Alter Table [NashvilleProject].[dbo].[NashvilleHousing]
Drop Column PropertyAddress,OwnerAddress,TaxDistrict
