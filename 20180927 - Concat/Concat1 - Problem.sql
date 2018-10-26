--http://www.itprotoday.com/software-development/row-concatenation-solutions-arent-all-equal
--http://tsql.solidq.com/books/tf3/
USE tempdb;
GO

IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL 
  DROP TABLE dbo.T1;
GO
--Create table
CREATE TABLE dbo.T1(
  col1 INT IDENTITY(1,1),
  col2 VARCHAR(100),
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
--Concatenate
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
--Cleanup
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL 
  DROP TABLE dbo.T1;