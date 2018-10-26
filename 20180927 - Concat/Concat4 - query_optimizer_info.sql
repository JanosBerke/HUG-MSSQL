use tempdb;
GO
SELECT *
INTO before_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info;
GO
SELECT *
INTO after_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info;
GO
DROP TABLE after_query_optimizer_info, before_query_optimizer_info;
--Real execution starts
GO
SELECT *
INTO before_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info;
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
INTO after_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info;
GO
SELECT a.counter, (a.occurrence - b.occurrence) as occurrence, (a.value - b.value) as value
FROM before_query_optimizer_info b
JOIN after_query_optimizer_info a
ON b.counter = a.counter
WHERE b.occurrence  <> a.occurrence ;
GO
--Cleanup
DROP TABLE before_query_optimizer_info, after_query_optimizer_info;
