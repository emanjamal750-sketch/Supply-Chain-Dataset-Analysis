

--=======================================================
-- Data KPIS
--=======================================================

SELECT 'Date Range',
       CONVERT(VARCHAR(20), MIN(SalesDate), 23) + ' to ' + CONVERT(VARCHAR(20), MAX(SalesDate), 23)
FROM project.Sales

UNION ALL

SELECT 'Total Products' AS KPI, CAST(COUNT(*) AS VARCHAR(50)) AS KPIValue
FROM project.Products

UNION ALL

SELECT 'Sold Products', CAST(COUNT(DISTINCT ProductID) AS VARCHAR(50))
FROM project.Sales

UNION ALL

SELECT 'Total Units Sold', CAST(SUM(Total) AS VARCHAR(50))
FROM project.Sales

UNION ALL

SELECT 'Total Revenue', CAST(SUM(s.Total * p.Price) AS VARCHAR(50))
FROM project.Sales s
JOIN project.Products p
    ON s.ProductID = p.ProductID

UNION ALL

SELECT 'Total Stock Units', CAST(SUM(StockBalance) AS VARCHAR(50))
FROM project.Stock

UNION ALL

SELECT 'Total Stock Value', CAST(SUM(StockValue) AS VARCHAR(50))
FROM project.Stock

UNION ALL

SELECT 'Top Selling Product',
       CAST((
            SELECT TOP 1 p.ProductName
            FROM project.Products p
            JOIN project.Sales s
                ON p.ProductID = s.ProductID
            GROUP BY p.ProductName
            ORDER BY SUM(s.Total) DESC
       ) AS VARCHAR(200))

UNION ALL

SELECT 'Top Brand',
       CAST((
            SELECT TOP 1 p.Brand
            FROM project.Products p
            JOIN project.Sales s
                ON p.ProductID = s.ProductID
            GROUP BY p.Brand
            ORDER BY SUM(s.Total) DESC
       ) AS VARCHAR(200))

UNION ALL

SELECT 'Best Sales Day',
       CAST((
            SELECT TOP 1 CONVERT(VARCHAR(20), SalesDate, 23)
            FROM project.Sales
            GROUP BY SalesDate
            ORDER BY SUM(Total) DESC
       ) AS VARCHAR(50))

UNION ALL

SELECT 'Total Branches', CAST(COUNT(DISTINCT Location) AS VARCHAR(50))
FROM project.Stock

UNION ALL

SELECT 'Out of Stock Products', CAST(COUNT(*) AS VARCHAR)
FROM (
    SELECT ProductID, SUM(StockBalance) AS StockBalance
    FROM project.Stock
    GROUP BY ProductID
) s WHERE StockBalance = 0;

--=======================================================
-- Sales performance
--=======================================================
--=======================================================
-- : What are the top-selling products?
--=======================================================
SELECT TOP 10
    p.ProductName,
    SUM(sa.Total) AS TotalSales
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales DESC;

--=======================================================
-- : What are the lowest-selling products?
--=======================================================
SELECT TOP 10
    p.ProductName,
    SUM(sa.Total) AS TotalSales
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales ASC;


--=======================================================
-- : What is the daily sales trend?
--=======================================================
SELECT 
    SalesDate,
    SUM(Total) AS DailySales
FROM project.Sales
GROUP BY SalesDate
ORDER BY SalesDate;



--=======================================================
-- : What is the best sales day?
--=======================================================
SELECT TOP 1
    SalesDate,
    SUM(Total) AS DailySales
FROM project.Sales
GROUP BY SalesDate
ORDER BY DailySales DESC;



--=======================================================
-- : What is the average daily sales per branch?
--=======================================================
SELECT 
    'Apsis' AS Branch,
    AVG(Apsis * 1.0) AS AvgDailySales
FROM project.Sales
UNION ALL
SELECT 
    'Basalt',
    AVG(Basalt * 1.0)
FROM project.Sales
UNION ALL
SELECT 
    'Ceres',
    AVG(Ceres * 1.0)
FROM project.Sales;



--=======================================================
-- : Which products have declining sales over time?
--=======================================================
WITH MonthlySales AS (
    SELECT 
        p.ProductName,
        FORMAT(sa.SalesDate, 'yyyy-MM') AS SalesMonth,
        SUM(sa.Total) AS MonthlySales
    FROM project.Products p
    JOIN project.Sales sa 
        ON p.ProductID = sa.ProductID
    GROUP BY p.ProductName, FORMAT(sa.SalesDate, 'yyyy-MM')
),
WithLag AS (
    SELECT *,
           LAG(MonthlySales) OVER (PARTITION BY ProductName ORDER BY SalesMonth) AS PrevMonthSales
    FROM MonthlySales
)
SELECT 
    ProductName,
    SalesMonth,
    MonthlySales,
    PrevMonthSales,
    MonthlySales - PrevMonthSales AS SalesChange
FROM WithLag
WHERE MonthlySales < PrevMonthSales
ORDER BY SalesChange ASC;



--=======================================================
-- : What is the best sales week?
--=======================================================
SELECT TOP 1
    DATEPART(YEAR, SalesDate)  AS SalesYear,
    DATEPART(WEEK, SalesDate)  AS WeekNumber,
    MIN(SalesDate)             AS WeekStart,
    MAX(SalesDate)             AS WeekEnd,
    SUM(Total)                 AS WeeklySales
FROM project.Sales
GROUP BY DATEPART(YEAR, SalesDate), DATEPART(WEEK, SalesDate)
ORDER BY WeeklySales DESC;



--=======================================================
-- Product & brand analysis
--=======================================================
--=======================================================
-- : Which brand generates the highest sales?
--=======================================================
SELECT 
    p.Brand,
    SUM(sa.Total) AS TotalSales
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
GROUP BY p.Brand
ORDER BY TotalSales DESC;



--=======================================================
-- : Which product group drives the most sales?
--=======================================================
SELECT 
    p.ProductGroup,
    SUM(sa.Total) AS TotalSales
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
GROUP BY p.ProductGroup
ORDER BY TotalSales DESC;

--=======================================================
-- : Which products generate the highest revenue?
--=======================================================
SELECT 
    p.ProductName,
    SUM(sa.Total * p.Price) AS Revenue
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC;


--=======================================================
-- : What are the top 5 products in each brand?
--=======================================================
WITH SalesPerProduct AS (
    SELECT 
        p.Brand,
        p.ProductName,
        SUM(sa.Total) AS TotalSales
    FROM project.Products p
    JOIN project.Sales sa 
        ON p.ProductID = sa.ProductID
    GROUP BY p.Brand, p.ProductName
)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Brand ORDER BY TotalSales DESC) AS rn
    FROM SalesPerProduct
) x
WHERE rn <= 5;

--=======================================================
-- : Which products have high price but low sales?
--=======================================================
SELECT TOP 10
    p.ProductName,
    p.Price,
    SUM(sa.Total) AS TotalSales
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
GROUP BY p.ProductName, p.Price
HAVING p.Price > (SELECT AVG(Price) FROM project.Products)
ORDER BY TotalSales ASC;



--=======================================================
-- : What is the average price per brand and product group?
--=======================================================
SELECT 
    Brand,
    ProductGroup,
    COUNT(ProductID)    AS NumberOfProducts,
    AVG(Price)          AS AvgPrice,
    MIN(Price)          AS MinPrice,
    MAX(Price)          AS MaxPrice
FROM project.Products
GROUP BY Brand, ProductGroup
ORDER BY Brand, ProductGroup;


--=======================================================
-- Branch analysis
--=======================================================


--=======================================================
--Which branch contributes the most sales?
--=======================================================
SELECT 'Apsis' AS Branch, SUM(Apsis) AS TotalSales FROM project.Sales
UNION ALL
SELECT 'Basalt', SUM(Basalt) FROM project.Sales
UNION ALL
SELECT 'Ceres', SUM(Ceres) FROM project.Sales;

--=======================================================
-- : What is the top-selling product in each branch?
--=======================================================
WITH BranchSales AS (
    SELECT 
        p.ProductName,
        SUM(sa.Apsis)  AS Apsis_Sales,
        SUM(sa.Basalt) AS Basalt_Sales,
        SUM(sa.Ceres)  AS Ceres_Sales
    FROM project.Products p
    JOIN project.Sales sa 
        ON p.ProductID = sa.ProductID
    GROUP BY p.ProductName
),
Ranked AS (
    SELECT
        ProductName,
        'Apsis'      AS Branch,
        Apsis_Sales  AS TotalSales,
        ROW_NUMBER() OVER (ORDER BY Apsis_Sales  DESC) AS rn
    FROM BranchSales
    UNION ALL
    SELECT
        ProductName,
        'Basalt',
        Basalt_Sales,
        ROW_NUMBER() OVER (ORDER BY Basalt_Sales DESC)
    FROM BranchSales
    UNION ALL
    SELECT
        ProductName,
        'Ceres',
        Ceres_Sales,
        ROW_NUMBER() OVER (ORDER BY Ceres_Sales  DESC)
    FROM BranchSales
)
SELECT Branch, ProductName, TotalSales
FROM Ranked
WHERE rn = 1
ORDER BY Branch;


--=======================================================
-- : What is each branch's contribution % per brand?
--=======================================================
SELECT 
    p.Brand,
    SUM(sa.Apsis)  AS Apsis_Sales,
    SUM(sa.Basalt) AS Basalt_Sales,
    SUM(sa.Ceres)  AS Ceres_Sales,
    SUM(sa.Total)  AS TotalSales,
    ROUND(SUM(sa.Apsis)  * 100.0 / SUM(sa.Total), 2) AS Apsis_Pct,
    ROUND(SUM(sa.Basalt) * 100.0 / SUM(sa.Total), 2) AS Basalt_Pct,
    ROUND(SUM(sa.Ceres)  * 100.0 / SUM(sa.Total), 2) AS Ceres_Pct
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
GROUP BY p.Brand
ORDER BY TotalSales DESC;


--=======================================================
-- : Stock & supply chain
--=======================================================

--=======================================================
-- : Which products are low in stock (need restocking)?
--=======================================================
SELECT 
    p.ProductName,
    s.StockBalance
FROM project.Products p
JOIN (
    SELECT ProductID, SUM(StockBalance) AS StockBalance
    FROM project.Stock
    GROUP BY ProductID
) s
    ON p.ProductID = s.ProductID
WHERE s.StockBalance < 50
ORDER BY s.StockBalance;



--=======================================================
-- : Which products are overstocked?
--=======================================================
SELECT TOP 10
    p.ProductName,
    s.StockBalance
FROM project.Products p
JOIN (
    SELECT ProductID, SUM(StockBalance) AS StockBalance
    FROM project.Stock
    GROUP BY ProductID
) s
    ON p.ProductID = s.ProductID
ORDER BY s.StockBalance DESC;




--=======================================================
-- : How do sales compare to stock levels?
--=======================================================
SELECT 
    p.ProductName,
    SUM(sa.Total) AS TotalSales,
    s.StockBalance
FROM project.Products p

JOIN (
    SELECT ProductID, SUM(StockBalance) AS StockBalance
    FROM project.Stock
    GROUP BY ProductID
) s
    ON p.ProductID = s.ProductID

JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID

GROUP BY p.ProductName, s.StockBalance
ORDER BY TotalSales DESC;



--=======================================================
-- : Which products have high sales but low stock? (At-Risk)
--=======================================================
SELECT 
    p.ProductName,
    SUM(sa.Total)       AS TotalSales,
    s.StockBalance,
    CASE 
        WHEN s.StockBalance = 0           THEN 'Out of Stock'
        WHEN s.StockBalance < 20          THEN 'Critical'
        WHEN s.StockBalance < 50          THEN 'Low'
        ELSE                                   'Adequate'
    END AS StockStatus
FROM project.Products p
JOIN project.Sales sa 
    ON p.ProductID = sa.ProductID
JOIN (
    SELECT ProductID, SUM(StockBalance) AS StockBalance
    FROM project.Stock
    GROUP BY ProductID
) s 
    ON p.ProductID = s.ProductID
GROUP BY p.ProductName, s.StockBalance
HAVING SUM(sa.Total) > (SELECT AVG(Total) FROM project.Sales)
   AND s.StockBalance < 50
ORDER BY TotalSales DESC, s.StockBalance ASC;



--=======================================================
-- : What is the average delivery time per location?
--=======================================================
SELECT 
    Location,
    COUNT(PurchaseID)                                          AS TotalOrders,
    AVG(DATEDIFF(DAY, OrderDate, DeliveryDate))                AS AvgDeliveryDays,
    MIN(DATEDIFF(DAY, OrderDate, DeliveryDate))                AS MinDeliveryDays,
    MAX(DATEDIFF(DAY, OrderDate, DeliveryDate))                AS MaxDeliveryDays
FROM project.Stock
GROUP BY Location
ORDER BY AvgDeliveryDays DESC;



--=======================================================
-- : Which products are reordered the most?
--=======================================================
SELECT 
    p.ProductName,
    p.Brand,
    p.ProductGroup,
    COUNT(s.PurchaseID)     AS TimesReordered,
    SUM(s.OrderQuantity)    AS TotalOrdered
FROM project.Products p
JOIN project.Stock s 
    ON p.ProductID = s.ProductID
GROUP BY p.ProductName, p.Brand, p.ProductGroup
ORDER BY TimesReordered DESC;