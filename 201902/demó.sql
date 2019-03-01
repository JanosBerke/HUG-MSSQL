USE [WideWorldImporters]
GO

--Prep
SELECT * INTO [Sales].[OrdersCopy] FROM [Sales].[Orders];
GO
CREATE NONCLUSTERED INDEX [NCI_CustomerID_OrdersCopy] ON [Sales].[OrdersCopy] ([CustomerID]);
GO

-- RID lookup
SET STATISTICS IO ON;
SELECT 
[OrderID],
[CustomerID],
[SalespersonPersonID],
[PickedByPersonID],
[ContactPersonID]
FROM [Sales].[OrdersCopy]
WHERE 
	[CustomerID] = 1;
SET STATISTICS IO OFF;
/*
Table 'OrdersCopy'. Scan count 1, logical reads 131, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

SET STATISTICS IO ON;
SELECT 
[CustomerID]
FROM [Sales].[OrdersCopy]
WHERE 
	[CustomerID] = 1;
SET STATISTICS IO OFF;
/*
Table 'OrdersCopy'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

CREATE NONCLUSTERED INDEX [NCI_Covering1] ON [Sales].[OrdersCopy] ([CustomerID])
INCLUDE ([OrderID], [SalespersonPersonID], [PickedByPersonID], [ContactPersonID])
GO

-- nincs RID lookup
SET STATISTICS IO ON;
SELECT 
[OrderID],
[CustomerID],
[SalespersonPersonID],
[PickedByPersonID],
[ContactPersonID]
FROM [Sales].[OrdersCopy]
WHERE 
	[CustomerID] = 1;
SET STATISTICS IO OFF;
/*
Table 'OrdersCopy'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/



-- key lookup
SET STATISTICS IO ON;
SELECT 
[OrderID],
[CustomerID],
[SalespersonPersonID],
[PickedByPersonID],
[ContactPersonID]
FROM [Sales].[Orders]
WHERE 
	[CustomerID] = 1;
SET STATISTICS IO OFF;
/*
Table 'Orders'. Scan count 1, logical reads 406, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/
GO

-- nincs key lookup
SET STATISTICS IO ON;
SELECT [OrderID], [CustomerID] FROM [Sales].[Orders]
WHERE 
	[CustomerID] = 1;
SET STATISTICS IO OFF;
/*
Table 'Orders'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/
GO

CREATE NONCLUSTERED INDEX [NCI_Covering2] ON [Sales].[Orders] ([CustomerID])
INCLUDE ([SalespersonPersonID], [PickedByPersonID], [ContactPersonID]);
GO

SET STATISTICS IO ON;
SELECT 
[OrderID],
[CustomerID],
[SalespersonPersonID],
[PickedByPersonID],
[ContactPersonID]
FROM [Sales].[Orders]
WHERE 
	[CustomerID] = 1;
SET STATISTICS IO OFF;
/*
Table 'Orders'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

-- cleanup
DROP INDEX IF EXISTS [NCI_Covering1] ON [Sales].[OrdersCopy];
GO
DROP INDEX IF EXISTS [NCI_Covering2] ON [Sales].[Orders];
GO
DROP TABLE IF EXISTS [Sales].[OrdersCopy]