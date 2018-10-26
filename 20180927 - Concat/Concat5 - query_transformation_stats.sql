use tempdb;
GO
SELECT *
INTO before_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats;
GO
SELECT *
INTO after_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats;
GO
DROP TABLE after_query_transformation_stats, before_query_transformation_stats;
--Real execution starts
GO
SELECT *
INTO before_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats;
GO
--Actual query with OPTION (RECOMPILE)
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
ORDER BY col1
OPTION (RECOMPILE);

SELECT @C;

GO
SELECT *
INTO after_query_transformation_stats
FROM sys.dm_exec_query_transformation_stats;
GO
SELECT a.name, (a.promised - b.promised) as promised, (a.succeeded - b.succeeded) as succeeded
FROM before_query_transformation_stats b
JOIN after_query_transformation_stats a
ON b.name = a.name
WHERE b.succeeded <> a.succeeded;
--Cleanup
DROP TABLE before_query_transformation_stats, after_query_transformation_stats;
