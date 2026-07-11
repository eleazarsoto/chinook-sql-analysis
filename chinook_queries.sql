-- ============================================================
-- Chinook Database — SQL Analysis (SQLite)
-- Author: Eleazar Soto
-- 17 queries covering filtering, JOINs, aggregation,
-- date functions, and subqueries.
-- All queries tested against chinook.db (SQLite)
-- ============================================================


-- ------------------------------------------------------------
-- Query 1: Full names and countries of all customers
-- NOT from the USA.
-- Result: 46 rows
-- ------------------------------------------------------------
SELECT FirstName || ' ' || LastName AS FullName, Country
FROM customers
WHERE Country <> 'USA';


-- ------------------------------------------------------------
-- Query 2: Full names and countries of all customers
-- from Brazil.
-- Result: 5 rows
-- ------------------------------------------------------------
SELECT FirstName || ' ' || LastName AS FullName, Country
FROM customers
WHERE Country = 'Brazil';


-- ------------------------------------------------------------
-- Query 3: Customer full names, invoice ID, invoice date
-- and billing country for all customers from France.
-- Notes:
--   * Filter on customers.Country (where the customer lives),
--     not BillingCountry.
--   * date() extracts the date only: the stored time is
--     always 00:00:00 and carries no information.
-- Result: 35 rows (5 customers x 7 invoices)
-- ------------------------------------------------------------
SELECT c.FirstName || ' ' || c.LastName AS FullName,
       i.InvoiceId,
       date(i.InvoiceDate) AS InvoiceDate,
       i.BillingCountry
FROM customers c
JOIN invoices i ON c.CustomerId = i.CustomerId
WHERE c.Country = 'France';


-- ------------------------------------------------------------
-- Query 4: All distinct employee roles.
-- Result: 5 roles
-- ------------------------------------------------------------
SELECT DISTINCT Title
FROM employees;


-- ------------------------------------------------------------
-- Query 5: Full names of employees with the role
-- 'Sales Support Agent'.
-- Result: 3 employees
-- ------------------------------------------------------------
SELECT FirstName || ' ' || LastName AS FullName
FROM employees
WHERE Title = 'Sales Support Agent';


-- ------------------------------------------------------------
-- Query 6: Number of invoices per country, descending.
-- Result: 24 countries (USA leads with 91 of 412 invoices)
-- ------------------------------------------------------------
SELECT BillingCountry, COUNT(*) AS Invoices
FROM invoices
GROUP BY BillingCountry
ORDER BY Invoices DESC;


-- ------------------------------------------------------------
-- Query 7: Average price per genre, descending.
-- Insight: all 5 genres at $1.99 are video content;
-- all music genres are flat at $0.99.
-- Result: 25 genres
-- ------------------------------------------------------------
SELECT g.Name, ROUND(AVG(t.UnitPrice), 2) AS AvgPrice
FROM tracks t
JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY AVG(t.UnitPrice) DESC;


-- ------------------------------------------------------------
-- Query 8: 'Sales Support Agent' employees and their total
-- sales, descending. Three-table chain:
-- employees -> customers (SupportRepId) -> invoices (CustomerId)
-- Sanity check: the three agents sum to $2,328.60,
-- the grand total of all invoices.
-- ------------------------------------------------------------
SELECT e.FirstName || ' ' || e.LastName AS FullName,
       ROUND(SUM(i.Total), 2) AS TotalSales
FROM employees e
JOIN customers c ON c.SupportRepId = e.EmployeeId
JOIN invoices i ON i.CustomerId = c.CustomerId
WHERE e.Title = 'Sales Support Agent'
GROUP BY FullName
ORDER BY TotalSales DESC;


-- ------------------------------------------------------------
-- Query 9: Number of tracks in each playlist.
-- Key decisions:
--   * LEFT JOIN keeps empty playlists (Movies, Audiobooks)
--   * COUNT(pl.TrackId) instead of COUNT(*) so empty
--     playlists show 0 (COUNT ignores NULLs)
--   * GROUP BY PlaylistId, not Name: several playlist names
--     are duplicated with different IDs
-- Result: 18 playlists
-- ------------------------------------------------------------
SELECT p.Name, COUNT(pl.TrackId) AS TrackCount
FROM playlists p
LEFT JOIN playlist_track pl ON p.PlaylistId = pl.PlaylistId
GROUP BY p.PlaylistId
ORDER BY COUNT(pl.TrackId);


-- ------------------------------------------------------------
-- Query 10: Sales per day for the first 15 days of
-- January 2010. Filtering on date(InvoiceDate) avoids the
-- text-comparison trap where 'YYYY-MM-DD HH:MM:SS' > 'YYYY-MM-DD'
-- would silently exclude the last day.
-- Result: sales on only 4 days in that window
-- ------------------------------------------------------------
SELECT date(InvoiceDate) AS Day, COUNT(*) AS Sales
FROM invoices
WHERE date(InvoiceDate) BETWEEN '2010-01-01' AND '2010-01-15'
GROUP BY date(InvoiceDate)
ORDER BY Day;


-- ------------------------------------------------------------
-- Query 11: Invoice count and total sales for 2009 vs 2013.
-- Insight: 2013 had fewer invoices (80 vs 83) but higher
-- revenue ($450.58 vs $449.46) - higher average ticket.
-- ------------------------------------------------------------
SELECT strftime('%Y', InvoiceDate) AS Year,
       COUNT(*) AS Invoices,
       ROUND(SUM(Total), 2) AS TotalSales
FROM invoices
WHERE strftime('%Y', InvoiceDate) IN ('2009', '2013')
GROUP BY Year
ORDER BY Year;


-- ------------------------------------------------------------
-- Query 12: Number of line items on invoice ID 37.
-- Result: 4 lines
-- ------------------------------------------------------------
SELECT COUNT(*) AS Lines
FROM invoice_items
WHERE InvoiceId = 37;


-- ------------------------------------------------------------
-- Query 13: Number of line items per invoice.
-- Sanity check: line counts sum to 2,240 = total rows
-- in invoice_items.
-- Result: 412 invoices
-- ------------------------------------------------------------
SELECT InvoiceId, COUNT(*) AS Lines
FROM invoice_items
GROUP BY InvoiceId;


-- ------------------------------------------------------------
-- Query 14: Invoice IDs and totals above the average
-- invoice value. Scalar subquery pattern: the inner query
-- computes the benchmark ($5.65), the outer query filters by it.
-- Result: 179 invoices
-- ------------------------------------------------------------
SELECT InvoiceId, Total
FROM invoices
WHERE Total > (SELECT AVG(Total) FROM invoices);


-- ------------------------------------------------------------
-- Query 15: Customer IDs, full names and total spent,
-- descending by spend.
-- Sanity check: the 59 customer totals sum to $2,328.60,
-- the grand total of all invoices.
-- Result: 59 customers (top spender: Helena Holy, $49.62)
-- ------------------------------------------------------------
SELECT c.CustomerId,
       c.FirstName || ' ' || c.LastName AS FullName,
       ROUND(SUM(i.Total), 2) AS TotalSpent
FROM customers c
JOIN invoices i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC;


-- ------------------------------------------------------------
-- Query 16: Number of purchasing customers, number of tracks
-- purchased, and average tracks per customer.
-- Notes:
--   * COUNT(DISTINCT CustomerId) so repeat buyers count once
--   * SUM(Quantity) counts units sold, not line items
--   * Integer division truncates: 2240/59 would give 37
--     instead of 38. The * 1.0 factor forces real division
--     and ROUND(..., 0) rounds to the nearest integer.
-- Result: 59 customers, 2,240 tracks, 38 tracks/customer
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT i.CustomerId) AS "Clientes Con Compra",
       SUM(ii.Quantity) AS "Tracks Comprados",
       ROUND(SUM(ii.Quantity) * 1.0 / COUNT(DISTINCT i.CustomerId), 0) AS "Promedio Por Cliente"
FROM invoices i
JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId;


-- ------------------------------------------------------------
-- Query 17: Monthly revenue during 2009.
-- strftime('%m', ...) extracts the month for grouping;
-- strftime('%Y', ...) filters the year. ISO month strings
-- ('01'..'12') sort chronologically by default.
-- Sanity check: months sum to $449.46, matching Query 11.
-- Result: 12 rows
-- ------------------------------------------------------------
SELECT strftime('%m', InvoiceDate) AS Mes,
       ROUND(SUM(Total), 2) AS Facturacion
FROM invoices
WHERE strftime('%Y', InvoiceDate) = '2009'
GROUP BY Mes
ORDER BY Mes;;
ORDER BY Mes;
