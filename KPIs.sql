--=======================================================
-- Dashboard KPIs
--=======================================================
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
       ) AS VARCHAR(50));