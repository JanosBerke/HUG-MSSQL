USE tempdb;
GO

IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL 
  DROP TABLE dbo.T1;
GO
--Create table
CREATE TABLE dbo.T1(
  col1 INT IDENTITY(1,1) NOT NULL,
  col2 VARCHAR(100) NOT NULL,
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
GO
--Solution: Add an always true where clause if the column is nullable
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
WHERE col2 > '0'
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
WHERE col2 IS NOT NULL
ORDER BY col1;

SELECT @C;
GO

DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
WHERE col2 = col2
ORDER BY col1;

SELECT @C;
GO
--Cleanup
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL 
  DROP TABLE dbo.T1;