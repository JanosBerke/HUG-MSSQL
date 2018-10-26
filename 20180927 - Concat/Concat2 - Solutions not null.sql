USE tempdb;
GO

IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL 
  DROP TABLE dbo.T1;
GO
--Create table
CREATE TABLE dbo.T1(
  col1 INT IDENTITY(1,1),
  col2 VARCHAR(100) NULL,
  col3 BINARY(2000) NULL DEFAULT(0x),
  CONSTRAINT PK_T1 PRIMARY KEY(col1));
GO
--Add some rows
INSERT INTO dbo.T1(col2)
SELECT number
FROM master.dbo.spt_values
WHERE TYPE = 'P'
  AND number BETWEEN 1 AND 100;
GO
--List all rows
SELECT *
FROM dbo.T1
--------------------------------------------------
--Drop index if exists
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.T1') AND name = 'idx_T1_col2')
  DROP INDEX idx_T1_col2 ON dbo.T1
GO
--Concatenate
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
--Create covered index
CREATE NONCLUSTERED INDEX idx_T1_col2 ON dbo.T1(col2, col1);
--------------------------------------------------
--Returns only the last item
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1 
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
GO
--Solution: Force the old index
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1 WITH (INDEX = PK_T1)
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
GO
--Solution: Force the new index
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1 WITH (INDEX = idx_T1_col2)
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
GO
--Solution: Force scan hint (SQL Server 2008 R2 SP1)
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1 WITH (FORCESCAN)
WHERE col1 > 0
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
GO
--Solution: Force seek hint without index name
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1 WITH (FORCESEEK)
WHERE col1 > 0
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
GO
--Solution: Force seek hint with index name (SQL Server 2008 R2 SP1)
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1 WITH (FORCESEEK, INDEX(PK_T1))
WHERE col1 > 0
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
GO
--Solution: FOR XML PATH (SQL Server 2005)
SELECT 
(SELECT col2 + ';' AS [text()]
FROM dbo.T1
ORDER BY col1
FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)')
GO
--------------------------------------------------
GO
--Solution: Add an always true where clause if the column is nullable
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
WHERE col2 IS NOT NULL
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
--Solution: Add an always true where clause
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
WHERE col2 = col2
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
--Solution: Use string agg
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = STRING_AGG (col2, ';') WITHIN GROUP (ORDER BY col1)
FROM dbo.T1;

SELECT @C;
GO
--------------------------------------------------
--Solution: Add the best covered index, colunm order is important!
CREATE NONCLUSTERED INDEX idx_T1_col1_col2 ON dbo.T1(col1, col2);
--------------------------------------------------
GO
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
ORDER BY col1;

SELECT @C;
GO
DROP INDEX idx_T1_col1_col2 ON dbo.T1
--------------------------------------------------
--Cleanup
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL 
  DROP TABLE dbo.T1;