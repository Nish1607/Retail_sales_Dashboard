create database Retail_sales

use Retail_sales
SELECT 'Products_Staging' AS Col, COUNT(*) FROM dbo.Products_Staging UNION ALL
SELECT 'Customers_Staging', COUNT(*) FROM dbo.Customers_Staging UNION ALL
SELECT 'Stores_Staging', COUNT(*) FROM dbo.Stores_Staging UNION ALL
SELECT 'Date_Staging', COUNT(*) FROM dbo.Date_Staging UNION ALL
SELECT 'Sales_Staging', COUNT(*) FROM dbo.Sales_Staging;
--------1.Validating Data-------------------------------------------------
SELECT TOP 10 * FROM dbo.Products_Staging;
SELECT TOP 10 * FROM dbo.Customers_Staging;
SELECT TOP 10 * FROM dbo.Sales_Staging;
SELECT TOP 10 * FROM [dbo].[Date_Staging]
SELECT TOP 10 * FROM [dbo].[Stores_Staging];

---Identify missing data--
SELECT COUNT(*) AS Nulls, 'ProductName' AS ColName FROM Products_Staging WHERE ProductName IS NULL OR LTRIM(RTRIM(ProductName)) = '';
SELECT COUNT(*) AS Nulls, 'Gender' AS ColName FROM Customers_Staging WHERE Gender IS NULL ;


SELECT * FROM Sales_Staging WHERE TRY_CONVERT(DECIMAL(10,2), UnitPrice) IS NULL;

--Find Duplicates
SELECT SaleID, COUNT(*) AS CountOfDuplicate
FROM Sales_Staging
GROUP BY SaleID
HAVING COUNT(*) > 1;

SELECT * FROM Sales_Staging WHERE ProductID IS NULL OR CustomerID IS NULL OR StoreID IS NULL;

-------2.Cleaning & Tranformation-----------------------------------------------------

SELECT LTRIM(RTRIM(ProductName)) AS CleanName FROM Products_Staging;

---convert datatype safely-----
SELECT TOP 10 * FROM dbo.Sales_Staging;
SELECT * FROM Sales_Staging WHERE TRY_CONVERT(DECIMAL(10,2),  REPLACE(UnitPrice,'$','')) IS NULL;

---handle missing values---
SELECT ProductName, COUNT(*) AS ProductCount
FROM dbo.Products_Staging
GROUP BY ProductName;

UPDATE dbo.Products_Staging
SET ProductName = 'Unknown Product'
WHERE ProductName IS NULL OR LTRIM(RTRIM(ProductName)) = '';

---Standardize inconsistent categories
SELECT TOP 10 * FROM dbo.Products_Staging;
select distinct  Category from dbo.Products_Staging;

UPDATE dbo.Products_Staging
SET Category = 'Jewelry & Accessories'
WHERE Category LIKE '%Jewelry%Accessories%';


select distinct city from dbo.Customers_Staging;

---delete duplicate data
;WITH CTE AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY SaleID ORDER BY DateKey DESC) AS rn
  FROM Sales_Staging
)
DELETE FROM CTE WHERE rn > 1

SELECT SaleID, COUNT(SaleID) AS totalID
FROM Sales_Staging
GROUP BY SaleID
HAVING COUNT(SaleID) > 1;
  

-----convert to get 2 decimals----------------
  ALTER TABLE dbo.Products_Staging           ---add column for CostPrice
ADD CleanedCostPrice DECIMAL(10,2);

 UPDATE dbo.Products_Staging                 ---update in col
SET CleanedCostPrice = ROUND(CostPrice, 2);


  ALTER TABLE dbo.Products_Staging           ---add column for selling price
ADD CleanedSellingPrice DECIMAL(10,2);

 UPDATE dbo.Products_Staging                 ---update in col
SET CleanedSellingPrice = ROUND(SellingPrice, 2); 

---Full Name where first letter for fname and lname in capital

SELECT FullName
FROM dbo.Customers_Staging
WHERE NOT (
    FullName COLLATE Latin1_General_CS_AS LIKE '[A-Z][a-z]% [A-Z][a-z]%'
    AND LEN(FullName) - LEN(REPLACE(FullName, ' ', '')) = 1
);

UPDATE dbo.Customers_Staging
SET FullName =
    UPPER(LEFT(FullName, 1)) +
    LOWER(SUBSTRING(FullName, 2, CHARINDEX(' ', FullName) - 1)) + ' ' +
    UPPER(SUBSTRING(FullName, CHARINDEX(' ', FullName) + 1, 1)) +
    LOWER(SUBSTRING(FullName, CHARINDEX(' ', FullName) + 2, LEN(FullName)))
WHERE FullName IS NOT NULL
  AND CHARINDEX(' ', FullName) > 0;

  ----Income col validate $,CAD

ALTER TABLE dbo.Customers_Staging
ADD CleanedIncome DECIMAL(12,2);

UPDATE dbo.Customers_Staging
SET CleanedIncome = TRY_CONVERT(DECIMAL(12,2),
    REPLACE(
        REPLACE(
            REPLACE(
                REPLACE(Income, '$', ''), 
            'CAD', ''), 
        ',', ''),
    '.$', '.00')
);




----Cleaning datet format-----------


    UPDATE dbo.Sales_Staging
SET CleanedDate =
    CASE
        -- Case 1: DD/MM/YYYY  → 21/04/2021
        WHEN DateKey LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
             AND TRY_CONVERT(DATE, DateKey, 103) IS NOT NULL THEN
            TRY_CONVERT(DATE, DateKey, 103)

        -- Case 2: YYYY/MM/DD  → 2022/02/17
        WHEN DateKey LIKE '[1-2][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9]'
             AND TRY_CONVERT(DATE, DateKey, 111) IS NOT NULL THEN
            TRY_CONVERT(DATE, DateKey, 111)

        -- Case 3: YYYY-MM-DD  → 2021-05-13
        -- (Invalid ones like 2021-13-05 will automatically become NULL)
        WHEN DateKey LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'
             AND TRY_CONVERT(DATE, DateKey, 120) IS NOT NULL THEN
            TRY_CONVERT(DATE, DateKey, 120)

        -- Case 4: MM-DD-YYYY  → 12-15-2022
        WHEN DateKey LIKE '[0-1][0-9]-[0-3][0-9]-[1-2][0-9][0-9][0-9]'
             AND TRY_CONVERT(DATE, DateKey, 110) IS NOT NULL THEN
            TRY_CONVERT(DATE, DateKey, 110)

        -- Case 5: Numeric YYYYMMDD → 20220421
        WHEN ISNUMERIC(DateKey) = 1 AND LEN(DateKey) = 8
             AND TRY_CONVERT(DATE, STUFF(STUFF(DateKey, 5, 0, '-'), 8, 0, '-')) IS NOT NULL THEN
            TRY_CONVERT(DATE, STUFF(STUFF(DateKey, 5, 0, '-'), 8, 0, '-'))
        -- Additional CASE (add as Case 6)
WHEN DateKey LIKE '[1-2][0-9][0-9][0-9]-[0-3][0-9]-[0-1][0-9]'
     AND TRY_CONVERT(DATE, CONCAT(
         LEFT(DateKey, 4), '-',  -- Year
         RIGHT(DateKey, 2), '-',  -- Month
         SUBSTRING(DateKey, 6, 2)  -- Day
     )) IS NOT NULL
THEN
    TRY_CONVERT(DATE, CONCAT(
         LEFT(DateKey, 4), '-',  -- Year
         RIGHT(DateKey, 2), '-',  -- Month
         SUBSTRING(DateKey, 6, 2)  -- Day
     ))

        ELSE NULL  -- Invalid or unrecognized (like 2021-13-05)
    END;


SELECT COUNT(*) ,CleanedDate AS NullDateCount
FROM dbo.Sales_Staging
WHERE CleanedDate IS NULL group by CleanedDate;

select DateKey ,CleanedDate from Sales_Staging;

SELECT DateKey, CleanedDate
FROM dbo.Sales_Staging
WHERE CleanedDate IS NULL;

SELECT DateKey                         --gives me incorrect dates forrmat
FROM dbo.Sales_Staging
WHERE CleanedDate IS NULL
GROUP BY DateKey;

--Seperate invalids into a backup table
SELECT *
INTO InvalidDates_Log
FROM dbo.Sales_Staging
WHERE CleanedDate IS NULL;


select *  from InvalidDates_Log

ALTER TABLE dbo.Sales_Staging ADD IsInvalidDate BIT;

UPDATE dbo.Sales_Staging
SET IsInvalidDate = CASE WHEN CleanedDate IS NULL THEN 1 ELSE 0 END;



-----Updating clean data--------------------------------

  ALTER TABLE dbo.Sales_Staging          ---add column for selling price
ADD CleanedNetAmount DECIMAL(10,2);

 UPDATE dbo.Sales_Staging                 ---update in col
SET CleanedNetAmount = ROUND(NetAmount, 2); 

ALTER TABLE dbo.Sales_Staging
ADD CleanedDiscountPct DECIMAL(5, 4);

UPDATE dbo.Sales_Staging
SET CleanedDiscountPct = 
    ROUND(CASE 
        WHEN DiscountPct < 0 THEN 0 
        ELSE DiscountPct 
    END, 4);

select distinct CleanedPaymentMethod from Sales_Staging

ALTER TABLE dbo.Sales_Staging
ADD CleanedPaymentMethod VARCHAR(50);

UPDATE dbo.Sales_Staging
SET CleanedPaymentMethod =
    CASE
        -- Standardize Cash
        WHEN LOWER(REPLACE(PaymentMethod, ' ', '')) LIKE '%cash%' THEN 'Cash'

        -- Standardize Debit Card
        WHEN LOWER(REPLACE(PaymentMethod, ' ', '')) LIKE '%debit%' THEN 'Debit Card'

        -- Standardize Credit Card
        WHEN LOWER(REPLACE(PaymentMethod, ' ', '')) LIKE '%credit%' THEN 'Credit Card'

        -- Standardize Card (unspecified)
        WHEN LOWER(REPLACE(PaymentMethod, ' ', '')) = 'card' THEN 'Card'

        -- Standardize Online
        WHEN LOWER(PaymentMethod) LIKE '%online%' THEN 'Online'

        -- Default
        ELSE 'Other'
    END;



-- Check for missing dates (e.g., gap between dates)
SELECT MIN(DateKey), MAX(DateKey), COUNT(*) 
FROM Date_Staging;
-- Example: Add DayOfWeek
SELECT DateKey, DATENAME(WEEKDAY, DateKey) AS DayOfWeekName
FROM Date_Staging;

SELECT Date, COUNT(*) AS Count 
FROM dbo.Date_Staging
WHERE Date IS NULL
GROUP BY Date
ORDER BY Count DESC;

---Advance query
SELECT * FROM dbo.Date_Staging
WHERE Date < '2010-01-01' OR Date > GETDATE();



ALTER TABLE Sales_Staging
ADD CONSTRAINT FK_Sales_Products FOREIGN KEY (ProductID)
REFERENCES Products_Staging(ProductID);


---add pk in col
SELECT StoreID, COUNT(*) AS Cnt
FROM Sales_Staging
GROUP BY StoreID
HAVING COUNT(*) > 1;
-- If there's no PK on Customers_Staging
ALTER TABLE Date_Staging
ADD CONSTRAINT DateIdd PRIMARY KEY (ID);

select * from Sales_Staging where ProductID is null

SELECT DISTINCT s.ProductID ,s.CustomerID, StoreID
FROM Sales_Staging s
Left JOIN Products_Staging p ON s.ProductID = p.ProductID
WHERE p.ProductID IS NULL ;

UPDATE Sales_Staging
SET StoreID = REPLACE(ProductID, 'PX', 'P')
WHERE ProductID LIKE 'PX%' AND
      REPLACE(ProductID, 'PX', 'P') IN (SELECT ProductID FROM Sales_Staging);

UPDATE Sales_Staging
SET StoreID = REPLACE(StoreID, 'X', '0')
WHERE StoreID LIKE '%X%';



ALTER TABLE Sales_Staging
ADD CONSTRAINT FK_Sales_Stores FOREIGN KEY (StoreID)
REFERENCES Stores_Staging(StoreID);


SELECT  * FROM dbo.Products_Staging;
SELECT TOP 10 * FROM dbo.Customers_Staging;
SELECT   *  FROM dbo.Sales_Staging;
SELECT * FROM [dbo].[Stores_Staging];
SELECT  * FROM [dbo].[Date_Staging]

select * from  dbo.Products_Staging where SubCategory is null
UPDATE Products_Staging
SET SubCategory = 'Perfume'
WHERE ProductName = 'Harbor Perfume' AND Brand = 'Harbor';

SELECT  * FROM dbo.Products_Staging;

SELECT DISTINCT
  Category,
  Brand,
  SubCategory
FROM Products_Staging
WHERE SubCategory IS NOT NULL
ORDER BY Category, Brand, SubCategory;

select category from Products_Staging where category is null

SELECT DISTINCT 
  Brand, 
  SubCategory, 
  Category
FROM Products_Staging
WHERE Category IS NOT NULL
ORDER BY Brand, SubCategory;

select productName from Products_Staging where ProductName ='Unknown Product'

update Products_Staging set productName = null where ProductName= 'Unknown Product'

select distinct Category from Products_Staging; 

SELECT 
  ProductID, 
  ProductName, 
  Brand, 
  SubCategory, 
  Category
FROM Products_Staging
WHERE Category IS NULL
ORDER BY Brand, SubCategory;

-----updated null catgory
UPDATE Products_Staging
SET Category = 
    CASE
    WHEN ProductName LIKE '%Cookware%' THEN 'House & Kitchen'
    WHEN ProductName LIKE '%NailCare%' THEN 'Beauty'
    WHEN ProductName LIKE '%Makeup%' THEN 'Beauty'
    WHEN ProductName LIKE '%Bracelets%' THEN 'Jewelry & Accessories'
    WHEN ProductName LIKE '%Smartwatch%' THEN 'Electronics'
    WHEN ProductName LIKE '%Haircare%' THEN 'Beauty'
    WHEN ProductName LIKE '%T-shirt%' THEN 'Apparel'
     WHEN ProductName LIKE '%Earbuds%' THEN 'Electronics'
     WHEN ProductName LIKE '%Rings%' THEN 'Jewelry & Accessories'
     WHEN ProductName LIKE '%Skincare%' THEN 'Beauty'
     when SubCategory LIKE '%Perfume%' THEN 'Beauty'
    ELSE Category 
END
WHERE Category IS NULL;

select distinct Brand from Products_Staging; 

SELECT 
  ProductName, 
  Brand, 
  SubCategory, 
  Category
FROM Products_Staging
WHERE Brand IS NULL
ORDER BY Brand 

UPDATE Products_Staging
SET Brand = 
    CASE
      WHEN ProductName LIKE '%Unknown%'  THEN 'Unknown'
     
    ELSE Brand 
END
WHERE Brand IS NULL;



SELECT TOP 10  * FROM dbo.Products_Staging;
SELECT TOP 10 * FROM dbo.Customers_Staging;
SELECT  TOP 10 *  FROM dbo.Sales_Staging;
SELECT  TOP 10 * FROM [dbo].[Stores_Staging];
SELECT  TOP 10 * FROM [dbo].[Date_Staging]

