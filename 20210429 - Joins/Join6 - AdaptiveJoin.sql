--Storage Engine history
--7.0 Clustered, nonclustered and full-text index
--2000
--2005 XML Primary and secondary indexes, Include
--2008 Filtered Nonclustered Index, Geometry, geography and hierarchyid
--2012 Nonclustered columnstore (readonly) and batch mode (1000 rows)
--2014 In-Memory and Clustered columnstore (readonly), New CE
--2016 Operational Analytics and In-Memory Analytics (Updateable Columnstore), operator improvements (more operators run in batch mode)
--2017 Adaptive Join in batch mode, Adaptive Query Processing
--2019 Intelligent Query Processing
--https://docs.microsoft.com/en-us/sql/relational-databases/performance/intelligent-query-processing

--Set compatibility level SQL Server 2019
ALTER DATABASE AdventureWorks2017 SET COMPATIBILITY_LEVEL = 150;
GO
USE AdventureWorks2017;
GO
--Drop AWBuildVersionCS
IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'AWBuildVersionCS')
  DROP TABLE dbo.AWBuildVersionCS;
GO
--Create AWBuildVersionCS with columnstore index
CREATE TABLE dbo.AWBuildVersionCS(
	SystemInformationID TINYINT NOT NULL,
	[Database Version] NVARCHAR(25) NOT NULL,
	VersionDate DATETIME NOT NULL,
	ModifiedDate DATETIME NOT NULL,
 INDEX [CC_AWBuildVersion_SystemInformationID] CLUSTERED COLUMNSTORE ON [PRIMARY]
) ON [PRIMARY];
GO
--Add row
INSERT INTO dbo.AWBuildVersionCS
SELECT *
FROM dbo.AWBuildVersion;
GO
--Turn on actual execution plan
--Clustered Index Scan, RowStore, Row Mode
SELECT *
FROM dbo.AWBuildVersion;
GO
--Clustered Columnstore Index Scan, ColumnStore, Batch Mode
SELECT *
FROM dbo.AWBuildVersionCS;
GO
--Colunmstore index
--https://www.red-gate.com/simple-talk/sql/database-administration/columnstore-indexes-in-sql-server-2012/
--https://www.nikoport.com/2013/07/05/clustered-columnstore-indexes-part-1-intro/
GO
--Drop Sales.SalesOrderHeaderCLCS
IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'SalesOrderHeaderCLCS')
  DROP TABLE Sales.SalesOrderHeaderCLCS;
GO
--Create Sales.SalesOrderHeaderCS with clustered columnstore index
CREATE TABLE Sales.SalesOrderHeaderCLCS(
	SalesOrderID INT NOT NULL,
	RevisionNumber TINYINT NOT NULL,
	OrderDate DATETIME NOT NULL,
	DueDate DATETIME NOT NULL,
	ShipDate DATETIME NULL,
	Status TINYINT NOT NULL,
	OnlineOrderFlag BIT NOT NULL,
	SalesOrderNumber NVARCHAR(25) NOT NULL,
	PurchaseOrderNumber NVARCHAR(25) NULL,
	AccountNumber NVARCHAR(15) NULL,
	CustomerID INT NOT NULL,
	SalesPersonID INT NULL,
	TerritoryID INT NULL,
	BillToAddressID INT NOT NULL,
	ShipToAddressID INT NOT NULL,
	ShipMethodID INT NOT NULL,
	CreditCardID INT NULL,
	CreditCardApprovalCode VARCHAR(15) NULL,
	CurrencyRateID INT NULL,
	SubTotal MONEY NOT NULL,
	TaxAmt MONEY NOT NULL,
	Freight MONEY NOT NULL,
	TotalDue MONEY NOT NULL,
	Comment NVARCHAR(128) NULL,
	rowguid UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
	ModifiedDate DATETIME NOT NULL,
 INDEX [CC_SalesOrderHeaderCS] CLUSTERED COLUMNSTORE ON [PRIMARY]
) ON [PRIMARY];
GO
--Add rows
INSERT INTO Sales.SalesOrderHeaderCLCS
SELECT *
FROM Sales.SalesOrderHeader
GO
--SQL Server 2016 and no parameter
--No adaptive join
ALTER DATABASE AdventureWorks2017 SET COMPATIBILITY_LEVEL = 130;
GO
--Sales.SalesOrderHeader CL + NCL index
--Hash Match
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 277;

--Sales.SalesOrderHeaderCLCS Clustered ColumnStore
--Hash Match
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 277;

--Sales.SalesOrderHeader CL + NCL index
--Nested Loop
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 287;

--Sales.SalesOrderHeaderCS Clustered ColumnStore
--Nested Loop
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 287;
GO
--SQL Server 2017 and no parameter
--Adaptive join for columnstore index
ALTER DATABASE AdventureWorks2017 SET COMPATIBILITY_LEVEL = 140;
GO
--Sales.SalesOrderHeader CL + NCL index
--Hash Match
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 277;

--Sales.SalesOrderHeaderCLCS Clustered ColumnStore
--Adaptive Join
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 277;

--Sales.SalesOrderHeader CL + NCL index
--Nested Loop
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 287;

--Sales.SalesOrderHeaderCS Clustered ColumnStore
--Adaptive Join
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = 287;
GO
--Adaptive Join has three inputs, supports only four logical join operations: inner join, left outer join, left semi join, and left anti semi join
--requires at least one equality-based join predicate, it uses lots of memory, and it is semi-blocking.
--https://sqlserverfast.com/epr/adaptive-join/
--Estimated Join Type - Actual Join Type
--Adaptive Threshold Rows

--https://docs.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver15

--A query plan can dynamically switch to a better join strategy during execution without having to be recompiled.
--Workloads with frequent oscillations between small and large join input scans will benefit most from this feature.

--SQL Server 2016 and parameter
--No adaptive join
--Hash match
--Nested loop with recompile
ALTER DATABASE AdventureWorks2017 SET COMPATIBILITY_LEVEL = 130;
GO
DECLARE @SalesPersonID INT = 277;
--Sales.SalesOrderHeader CL + NCL index
--Hash Match
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID
--OPTION (RECOMPILE);

--Sales.SalesOrderHeaderCLCS Clustered ColumnStore
--Hash Match
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID
--OPTION (RECOMPILE);

SET @SalesPersonID = 287
--Sales.SalesOrderHeader CL + NCL index
--Hash Match
--Nested Loop with recompile
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID
--OPTION (RECOMPILE);

--Sales.SalesOrderHeaderCS Clustered ColumnStore
--Hash Match
--Nested Loop with recompile
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID
--OPTION (RECOMPILE);

--SQL Server 2017 and parameter
--Adaptive join for columnstore index
ALTER DATABASE AdventureWorks2017 SET COMPATIBILITY_LEVEL = 140;
GO
DECLARE @SalesPersonID INT = 277;
--Sales.SalesOrderHeader CL + NCL index
--Hash Match
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;

--Sales.SalesOrderHeaderCLCS Clustered ColumnStore
--Adaptive Join
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;

SET @SalesPersonID = 287
--Sales.SalesOrderHeader CL + NCL index
--Hash Match
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;

--Sales.SalesOrderHeaderCS Clustered ColumnStore
--Adaptive Join
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;
GO
--Drop Sales.SalesOrderHeaderCL_NCLCS
IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'SalesOrderHeaderCL_NCLCS')
  DROP TABLE Sales.SalesOrderHeaderCL_NCLCS;
GO
--Create Sales.SalesOrderHeaderCL_NCLCS with clustered index and nonclustered columnstore index
CREATE TABLE Sales.SalesOrderHeaderCL_NCLCS(
	SalesOrderID INT NOT NULL,
	RevisionNumber TINYINT NOT NULL,
	OrderDate DATETIME NOT NULL,
	DueDate DATETIME NOT NULL,
	ShipDate DATETIME NULL,
	Status TINYINT NOT NULL,
	OnlineOrderFlag BIT NOT NULL,
	SalesOrderNumber NVARCHAR(25) NOT NULL,
	PurchaseOrderNumber NVARCHAR(25) NULL,
	AccountNumber NVARCHAR(15) NULL,
	CustomerID INT NOT NULL,
	SalesPersonID INT NULL,
	TerritoryID INT NULL,
	BillToAddressID INT NOT NULL,
	ShipToAddressID INT NOT NULL,
	ShipMethodID INT NOT NULL,
	CreditCardID INT NULL,
	CreditCardApprovalCode VARCHAR(15) NULL,
	CurrencyRateID INT NULL,
	SubTotal MONEY NOT NULL,
	TaxAmt MONEY NOT NULL,
	Freight MONEY NOT NULL,
	TotalDue MONEY NOT NULL,
	Comment NVARCHAR(128) NULL,
	rowguid UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
	ModifiedDate DATETIME NOT NULL,
 CONSTRAINT [PK_SalesOrderHeaderCL_NCLCS_SalesOrderID] PRIMARY KEY CLUSTERED ([SalesOrderID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO
--Add rows
INSERT INTO Sales.SalesOrderHeaderCL_NCLCS
SELECT *
FROM Sales.SalesOrderHeader
GO
--CREATE NCL CS index
CREATE NONCLUSTERED COLUMNSTORE INDEX SalesOrderHeaderCL_NCLCS ON Sales.SalesOrderHeaderCL_NCLCS(SalesPersonID, SalesOrderID, SubTotal);
GO
--Adaptive join because CL or NCL columnstore index exists on tables
DECLARE @SalesPersonID INT = 277;

--Sales.SalesOrderHeaderCLCS Clustered ColumnStore
--Adaptive Join
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;

--Sales.SalesOrderHeaderCL_NCLCS NonClustered ColumnStore
--Adaptive Join
--NonClustered ColumnStore index is not used
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCL_NCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;

SET @SalesPersonID = 287

--Sales.SalesOrderHeaderCS Clustered ColumnStore
--Adaptive Join
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;

--Sales.SalesOrderHeaderCL_NCLCS NonClustered ColumnStore
--Adaptive Join
--NonClustered ColumnStore index is not used
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCL_NCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;
GO
--Nonclustered Columnstore index with 0 rows
--Drop Sales.SalesOrderHeaderCL_FakeNCLCS
IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'SalesOrderHeaderCL_FakeNCLCS')
  DROP TABLE Sales.SalesOrderHeaderCL_FakeNCLCS;
GO
--Create Sales.SalesOrderHeaderCL_FakeNCLCS with clustered index and empty nonclustered columnstore index
CREATE TABLE Sales.SalesOrderHeaderCL_FakeNCLCS(
	SalesOrderID INT NOT NULL,
	RevisionNumber TINYINT NOT NULL,
	OrderDate DATETIME NOT NULL,
	DueDate DATETIME NOT NULL,
	ShipDate DATETIME NULL,
	Status TINYINT NOT NULL,
	OnlineOrderFlag BIT NOT NULL,
	SalesOrderNumber NVARCHAR(25) NOT NULL,
	PurchaseOrderNumber NVARCHAR(25) NULL,
	AccountNumber NVARCHAR(15) NULL,
	CustomerID INT NOT NULL,
	SalesPersonID INT NULL,
	TerritoryID INT NULL,
	BillToAddressID INT NOT NULL,
	ShipToAddressID INT NOT NULL,
	ShipMethodID INT NOT NULL,
	CreditCardID INT NULL,
	CreditCardApprovalCode VARCHAR(15) NULL,
	CurrencyRateID INT NULL,
	SubTotal MONEY NOT NULL,
	TaxAmt MONEY NOT NULL,
	Freight MONEY NOT NULL,
	TotalDue MONEY NOT NULL,
	Comment NVARCHAR(128) NULL,
	rowguid UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
	ModifiedDate DATETIME NOT NULL,
 CONSTRAINT [PK_SalesOrderHeaderCL_FakeNCLCS_SalesOrderID] PRIMARY KEY CLUSTERED ([SalesOrderID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO
--Add rows
INSERT INTO Sales.SalesOrderHeaderCL_FakeNCLCS
SELECT *
FROM Sales.SalesOrderHeader
GO
--CREATE NCL CS index
--No rows because of the filter
CREATE NONCLUSTERED COLUMNSTORE INDEX SalesOrderHeaderCL_FakeNCLCS ON Sales.SalesOrderHeaderCL_FakeNCLCS(SalesPersonID, SalesOrderID, SubTotal)
WHERE SalesOrderID IS NULL;
GO
DECLARE @SalesPersonID INT = 277;
--Sales.SalesOrderHeaderCL_FakeNCLCS NonClustered ColumnStore
--Adaptive Join with RowStore
--NonClustered ColumnStore index is not used
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCL_FakeNCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;

SET @SalesPersonID = 287
--Sales.SalesOrderHeaderCL_FakeNCLCS NonClustered ColumnStore
--Adaptive Join with RowStore
--NonClustered ColumnStore index is not used
SELECT SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesOrderHeaderCL_FakeNCLCS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesPersonID = @SalesPersonID;
GO

--Disable Adaptive join
--Trace Flag 9398
--Compatibility level
--Database Scoped Configuration Option DISABLE_BATCH_MODE_ADAPTIVE_JOINS (2017) or BATCH_MODE_ADAPTIVE_JOINS (2019)
--Query hint DISABLE_BATCH_MODE_ADAPTIVE_JOINS