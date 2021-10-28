use AdventureWorks2017
GO
--Drop table if exists
IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'SalesOrderHeaderHeap')
  DROP TABLE dbo.SalesOrderHeaderHeap;
GO
--Create table without any index
SELECT *
INTO dbo.SalesOrderHeaderHeap
FROM Sales.SalesOrderHeader
GO
--Drop table if exists
IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'SalesOrderDetailHeap')
  DROP TABLE dbo.SalesOrderDetailHeap;
GO
--Create table without any index
SELECT *
INTO dbo.SalesOrderDetailHeap
FROM Sales.SalesOrderDetail
GO
--Turn on Actual Execution Plan
SELECT *
FROM dbo.SalesOrderHeaderHeap soh
INNER JOIN dbo.SalesOrderDetailHeap sod
  ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Missing index
--Properties window
--Estimated number of rows
--Estimated operator cost
--Estimated subtree cost
--Optimizer hardware dependent properties (DOP)
--OptimizerStatsUsage
--Set Options
--WaitStats

--Join order and column order
SELECT *
FROM dbo.SalesOrderDetailHeap sod
INNER JOIN dbo.SalesOrderHeaderHeap soh
  ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
GO
--Index usage stats (system_scans)
SELECT *
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID()
AND object_id = OBJECT_ID('dbo.SalesOrderHeaderHeap')
AND index_id = 0;
GO
--Estimated number of rows
SELECT OBJECT_NAME(object_id) AS ObjectName, *
FROM sys.stats
WHERE object_id = OBJECT_ID('dbo.SalesOrderHeaderHeap')
ORDER BY name;
GO
--Change 2nd parameter because it contains object_id
DBCC SHOW_STATISTICS('dbo.SalesOrderHeaderHeap', _WA_Sys_00000001_5614BF03)  WITH NO_INFOMSGS;
GO
--Force Order
--HeaderHeap hash match DetailHeap
--Estimated subtree cost
SELECT *
FROM dbo.SalesOrderHeaderHeap soh
INNER JOIN dbo.SalesOrderDetailHeap sod
  ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01'
OPTION (FORCE ORDER);
GO
--DetailHeap hash match HeaderHeap
SELECT *
FROM dbo.SalesOrderDetailHeap sod
INNER JOIN dbo.SalesOrderHeaderHeap soh
  ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01'
OPTION (FORCE ORDER);
--cost threshold for parallelism
SELECT * FROM sys.configurations WHERE name = 'cost threshold for parallelism';
GO
--Show IO and times
SET STATISTICS IO, TIME ON;
GO
--Force Join hint --------------------------------------------------
--Nested loop
SELECT *
FROM dbo.SalesOrderHeaderHeap soh
INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
  ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Warning: The join order has been enforced because a local join hint is used.
--Table spool
--Rebind - Rewind
GO
--Merge
SELECT *
FROM dbo.SalesOrderHeaderHeap soh
INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
  ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Warning: The join order has been enforced because a local join hint is used.
--Sort
--Table 'Worktable'.
GO
--Hash
SELECT *
FROM dbo.SalesOrderHeaderHeap soh
INNER HASH JOIN dbo.SalesOrderDetailHeap sod
  ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Warning: The join order has been enforced because a local join hint is used.
--Table 'Workfile'.
GO
--Force Join hint end --------------------------------------------------
--Force Join hint noindex table orders --------------------------------------------------
  --HeaderHeap nested loop DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap nested loop HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER LOOP JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap merge DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap merge HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER MERGE JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap hash DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER HASH JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap hash HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER HASH JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Force Join hint noindex table orders end --------------------------------------------------

--Create NCL index on SalesOrderHeaderHeap
CREATE NONCLUSTERED INDEX NCL_SalesOrderHeaderHeap_SalesOrderID ON dbo.SalesOrderHeaderHeap(SalesOrderID);

--Force Join hint Header NCL table orders --------------------------------------------------
  --HeaderHeap nested loop DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap nested loop HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER LOOP JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap merge DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap merge HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER MERGE JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap hash DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER HASH JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap hash HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER HASH JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Force Join hint Header NCL index table orders end --------------------------------------------------

--Drop index on SalesOrderHeaderHeap
DROP INDEX NCL_SalesOrderHeaderHeap_SalesOrderID ON dbo.SalesOrderHeaderHeap;
--Create NCL index on SalesOrderDetailHeap
CREATE NONCLUSTERED INDEX NCL_SalesOrderDetailHeap_SalesOrderID ON dbo.SalesOrderDetailHeap(SalesOrderID);

--Force Join hint Detail NCL table orders --------------------------------------------------
  --HeaderHeap nested loop DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap nested loop HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER LOOP JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap merge DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap merge HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER MERGE JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap hash DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER HASH JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap hash HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER HASH JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Force Join hint Detail NCL index table orders end --------------------------------------------------

--Create NCL index on SalesOrderHeaderHeap
CREATE NONCLUSTERED INDEX NCL_SalesOrderHeaderHeap_SalesOrderID ON dbo.SalesOrderHeaderHeap(SalesOrderID);

--Force Join hint Header and Detail NCL table orders --------------------------------------------------
  --HeaderHeap nested loop DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap nested loop HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER LOOP JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap merge DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap merge HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER MERGE JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap hash DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER HASH JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap hash HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER HASH JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Force Join hint Header and Detail NCL index table orders end --------------------------------------------------

--Drop index on SalesOrderHeaderHeap
DROP INDEX NCL_SalesOrderHeaderHeap_SalesOrderID ON dbo.SalesOrderHeaderHeap;
--Drop index on SalesOrderDetailHeap
DROP INDEX NCL_SalesOrderDetailHeap_SalesOrderID ON dbo.SalesOrderDetailHeap;
--Create CL index on SalesOrderHeaderHeap
CREATE CLUSTERED INDEX CL_SalesOrderHeaderHeap_SalesOrderID ON dbo.SalesOrderHeaderHeap(SalesOrderID);

--Force Join hint Header CL table orders --------------------------------------------------
  --HeaderHeap nested loop DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap nested loop HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER LOOP JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap merge DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap merge HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER MERGE JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap hash DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER HASH JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap hash HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER HASH JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Force Join hint Header CL index table orders end --------------------------------------------------

--DROP CL index on SalesOrderHeaderHeap
DROP INDEX CL_SalesOrderHeaderHeap_SalesOrderID ON dbo.SalesOrderHeaderHeap;
--Create CL index on SalesOrderHeaderHeap
CREATE CLUSTERED INDEX CL_SalesOrderDetailHeap_SalesOrderID ON dbo.SalesOrderDetailHeap(SalesOrderID);

--Force Join hint Detail CL table orders --------------------------------------------------
  --HeaderHeap nested loop DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap nested loop HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER LOOP JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap merge DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap merge HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER MERGE JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap hash DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER HASH JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap hash HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER HASH JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Force Join hint Detail CL index table orders end --------------------------------------------------

--Create CL index on SalesOrderHeaderHeap
CREATE CLUSTERED INDEX CL_SalesOrderHeaderHeap_SalesOrderID ON dbo.SalesOrderHeaderHeap(SalesOrderID);

--Force Join hint Header and Detail CL table orders --------------------------------------------------
  --HeaderHeap nested loop DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER LOOP JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap nested loop HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER LOOP JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap merge DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER MERGE JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap merge HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER MERGE JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --HeaderHeap hash DetailHeap
  SELECT *
  FROM dbo.SalesOrderHeaderHeap soh
  INNER HASH JOIN dbo.SalesOrderDetailHeap sod
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
  GO
  --DetailHeap hash HeaderHeap
  SELECT *
  FROM dbo.SalesOrderDetailHeap sod
  INNER HASH JOIN dbo.SalesOrderHeaderHeap soh
    ON sod.SalesOrderID = soh.SalesOrderID
  WHERE soh.OrderDate >= '2011-01-01' AND soh.OrderDate < '2012-01-01';
--Force Join hint Header and Detail CL index table orders end --------------------------------------------------
