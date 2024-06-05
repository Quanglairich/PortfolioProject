/* 
Cleaning Data in SQL
*/

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize date format : Tiêu chuẩn hóa định dạng ngày tháng

select SaleDate, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing 
set SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address Data : Loại bỏ những giá trị null trong PropertyAddress

-- B1: Tìm tất cả dữ liệu địa chỉ bị null 
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null 

-- B2: Thay thế dữ liệu null bằng dữ liệu chính xác
update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null 

-- Breaking out address into individual columns (Address, City, State) : Tách dữ liệu cột địa chỉ thành các dữ liệu địa chỉ, tỉnh/thành, phường/xã
-- subtring: Cut chuỗi, (cột tham chiếu, thứ tự bắt đầu cut, số kí tự cần cut)
-- charindex: Tìm đến kí tự trong chuỗi

select 
substring(PropertyAddress,1,charindex(',' ,PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',' ,PropertyAddress)+1,len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing 
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',' ,PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing 
set PropertySplitCity = substring(PropertyAddress,1,charindex(',' ,PropertyAddress)-1)

select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

-- C2: Dùng hàm parsename
select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing 
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing 
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing 
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field : Thay đổi Y/N thành Yes/No

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-- Remove Duplicate : Xóa dữ liệu trùng
-- Sử dụng CTE và row_number ()

with RownumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
	order by UniqueID) 
	as row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete from RownumCTE
where row_num > 1

--Sử dụng ROW_NUMBER() để gán số thứ tự cho mỗi hàng trong từng nhóm
-- PARTITION BY : Chia các hàng theo cột tham chiếu
-- ORDER BY: Xác định thứ tự trong mỗi nhóm
-- delete from where row_num > 1: Xóa các dòng dữ liệu có số được đánh > 1


-- Delete unused columns: Xóa các cột không dùng đên
alter table PortfolioProject.dbo.NashvilleHousing
drop column TaxDistrict
