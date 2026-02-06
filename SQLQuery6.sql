use MyDatabase
/*select * from vitra
alter table vitra.sales
drop column date_now;
*/
select SaleDate, Employee, ProductName,DiscountPct,UnitPrice,TotalPrice,Region

from [Vitra.sales]
-- Total Sales for the Year

SELECT 
    SUM(TotalPrice) AS TotalSales
FROM [Vitra.sales];

--Top Selling Products
SELECT TOP 5
    ProductName,
    SUM(TotalPrice) AS TotalSales,
    COUNT(*) AS TotalOrders
FROM [Vitra.sales]
where ProductName is not null
GROUP BY ProductName
ORDER BY TotalSales DESC;
--onth with Highest and Lowest Sales
WITH MonthlySales AS (
    SELECT
        MONTH(SaleDate) AS SaleMonth,
        SUM(TotalPrice) AS TotalSales
    FROM [Vitra.sales]
    where  MONTH(SaleDate) is not null
    GROUP BY MONTH(SaleDate)
)
SELECT 
    SaleMonth,
    TotalSales
FROM MonthlySales
WHERE TotalSales = (SELECT MAX(TotalSales) FROM MonthlySales)  -- Highest month
   or TotalSales = (SELECT MIN(TotalSales) FROM MonthlySales)  -- Lowest month
ORDER BY TotalSales DESC;


--Top Regions by Sales
SELECT 
    Region,
    SUM(TotalPrice) AS TotalSales
FROM [Vitra.sales]
GROUP BY Region
having Region is not null
ORDER BY TotalSales DESC;

--Total Sales by Product
SELECT
    ProductName,
    SUM(TotalPrice) AS TotalSales
FROM [Vitra.sales]
where ProductName is not null
GROUP BY ProductName
ORDER BY TotalSales DESC;

--Monthly Sales Growth

WITH MonthlySales AS (
    SELECT
        YEAR(SaleDate) AS SaleYear,
        MONTH(SaleDate) AS SaleMonth,
        SUM(TotalPrice) AS TotalSales
    FROM [Vitra.sales]
    GROUP BY YEAR(SaleDate), MONTH(SaleDate)
),
LaggedSales AS (
    SELECT
        SaleYear,
        SaleMonth,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY SaleYear, SaleMonth) AS PrevMonthSales
    FROM MonthlySales
)
SELECT
    SaleYear,
    SaleMonth,
    TotalSales,
    PrevMonthSales,
    TotalSales - PrevMonthSales AS GrowthValue
FROM LaggedSales
WHERE PrevMonthSales IS NOT NULL and SaleMonth<>1
ORDER BY SaleYear, SaleMonth;

--Total Sales by Product
SELECT
    ProductName,
    SUM(TotalPrice) AS TotalSales
FROM [Vitra.sales]
GROUP BY ProductName
ORDER BY TotalSales DESC;


--Discount Percentage of Total Sales

SELECT
    SUM(ISNULL(TRY_CAST(TotalPrice AS MONEY), 0) * ISNULL(TRY_CAST(DiscountPct AS FLOAT), 0) / 100.0) AS DiscountAmount,
    SUM(ISNULL(TRY_CAST(TotalPrice AS MONEY), 0)) AS TotalSales,
    CASE 
        WHEN SUM(ISNULL(TRY_CAST(TotalPrice AS MONEY), 0)) = 0 THEN 0
        ELSE (SUM(ISNULL(TRY_CAST(TotalPrice AS MONEY), 0) * ISNULL(TRY_CAST(DiscountPct AS FLOAT), 0) / 100.0) * 100.0) 
             / SUM(ISNULL(TRY_CAST(TotalPrice AS MONEY), 0))
    END AS DiscountPercentage
FROM [Vitra.sales];




