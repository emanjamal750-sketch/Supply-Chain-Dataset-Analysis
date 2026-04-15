--=======================================================
-- Q1: What are the top-selling products?
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
-- Q2: What are the lowest-selling products?
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
-- Q3: Which brand generates the highest sales?
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
-- Q4: Which product group drives the most sales?
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
-- Q5: Which branch contributes the most sales?
--=======================================================
SELECT 'Apsis' AS Branch, SUM(Apsis) AS TotalSales FROM project.Sales
UNION ALL
SELECT 'Basalt', SUM(Basalt) FROM project.Sales
UNION ALL
SELECT 'Ceres', SUM(Ceres) FROM project.Sales;



--=======================================================
-- Q6: What is the daily sales trend?
--=======================================================
SELECT 
    SalesDate,
    SUM(Total) AS DailySales
FROM project.Sales
GROUP BY SalesDate
ORDER BY SalesDate;



--=======================================================
-- Q7: What is the best sales day?
--=======================================================
SELECT TOP 1
    SalesDate,
    SUM(Total) AS DailySales
FROM project.Sales
GROUP BY SalesDate
ORDER BY DailySales DESC;



--=======================================================
-- Q8: Which products are low in stock (need restocking)?
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
-- Q9: Which products are overstocked?
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
-- Q10: Which products generate the highest revenue?
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
-- Q11: How do sales compare to stock levels?
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
-- Q12: What are the top 5 products in each brand?
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