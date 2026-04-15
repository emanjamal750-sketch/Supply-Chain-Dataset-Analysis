--=======================================================
--Row Counts
--=======================================================

SELECT 'project.Products' AS TableName, COUNT(*) FROM project.Products
UNION ALL
SELECT 'project.Stock', COUNT(*) FROM project.Stock
UNION ALL
SELECT 'project.Sales', COUNT(*) FROM project.Sales;


--=======================================================
 --Missing Values
--=======================================================

SELECT * FROM project.Products
WHERE ProductID IS NULL OR ProductName IS NULL;

SELECT * FROM project.Stock
WHERE PurchaseID IS NULL OR ProductID IS NULL OR OrderDate IS NULL OR StockBalance IS NULL;

SELECT * FROM project.Sales
WHERE SalesDate IS NULL OR ProductID IS NULL OR Total IS NULL;

--=======================================================
 --Duplicates
--=======================================================

SELECT ProductID, COUNT(*) 
FROM project.Products
GROUP BY ProductID
HAVING COUNT(*) > 1;

SELECT PurchaseID, COUNT(*) 
FROM project.Stock
GROUP BY PurchaseID
HAVING COUNT(*) > 1;

-- Check exact duplicate rows in Sales only
SELECT 
    SalesDate,
    ProductID,
    Apsis,
    Basalt,
    Ceres,
    Total,
    COUNT(*) AS DuplicateCount
FROM project.Sales
GROUP BY 
    SalesDate,
    ProductID,
    Apsis,
    Basalt,
    Ceres,
    Total
HAVING COUNT(*) > 1;

--=======================================================
 --Integrity
--=======================================================

SELECT DISTINCT s.ProductID
FROM project.Stock s
LEFT JOIN project.Products p ON s.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

SELECT DISTINCT s.ProductID
FROM project.Sales s
LEFT JOIN project.Products p ON s.ProductID = p.ProductID
WHERE p.ProductID IS NULL;


--=======================================================
 --Text Cleaning
--=======================================================

SELECT * FROM project.Products
WHERE ProductID <> LTRIM(RTRIM(ProductID))
   OR ProductName <> LTRIM(RTRIM(ProductName));

SELECT * FROM project.Stock
WHERE ProductID <> LTRIM(RTRIM(ProductID));

SELECT * FROM project.Sales
WHERE ProductID <> LTRIM(RTRIM(ProductID));


--=======================================================
 --Business Logic Checks
--=======================================================

-- Total = Apsis + Basalt + Ceres
SELECT * FROM project.Sales
WHERE ISNULL(Apsis,0) + ISNULL(Basalt,0) + ISNULL(Ceres,0) <> ISNULL(Total,0);

-- StockValue check
SELECT 
    s.ProductID,
    p.ProductName,
    s.StockBalance,
    p.Price,
    s.StockValue,
    (s.StockBalance * p.Price) AS ExpectedValue
FROM project.Stock s
JOIN project.Products p ON s.ProductID = p.ProductID
WHERE ABS(s.StockValue - (s.StockBalance * p.Price)) > 0.01;


--=======================================================
 --Date Checks
--=======================================================

SELECT * FROM project.Stock
WHERE DeliveryDate < OrderDate;

SELECT * FROM project.Sales
WHERE SalesDate > GETDATE();



--=======================================================
 --Duplicate Product Names
--=======================================================

SELECT ProductName, COUNT(*)
FROM project.Products
GROUP BY ProductName
HAVING COUNT(*) > 1;

SELECT 
    ProductName,
    Brand,
    Price,
    COUNT(*) AS Cnt
FROM project.Products
GROUP BY 
    ProductName,
    Brand,
    Price
HAVING COUNT(*) > 1;

 
--=======================================================
 --Blank Values
--=======================================================

SELECT * FROM project.Products
WHERE LTRIM(RTRIM(ISNULL(ProductID,''))) = ''
   OR LTRIM(RTRIM(ISNULL(ProductName,''))) = '';

SELECT * FROM project.Stock
WHERE LTRIM(RTRIM(ISNULL(PurchaseID,''))) = '';

SELECT * FROM project.Sales
WHERE LTRIM(RTRIM(ISNULL(ProductID,''))) = '';