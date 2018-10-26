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
FROM dbo.T1;
--------------------------------------------------
--DROP index
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.T1') AND name = 'idx_T1_col2')
  DROP INDEX idx_T1_col2 ON dbo.T1;
GO
--------------------------------------------------
--Query SessionID
SELECT @@SPID;

--Drop extended event session if exists
IF EXISTS (SELECT *
	FROM sys.server_event_sessions
	WHERE NAME = 'query_trace_column_values')
DROP EVENT SESSION [query_trace_column_values] ON SERVER;
GO
--Change session_id!!
--Create extended event for sqlserver.query_trace_column_values (SQL Server 2016)
CREATE EVENT SESSION [query_trace_column_values] ON SERVER
ADD EVENT sqlserver.query_trace_column_values(
    WHERE ([package0].[equal_uint64]([sqlserver].[session_id],(74))))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO
--------------------------------------------------
--Turn on trace flag and xml statistics
DBCC TRACEON(2486);
SET STATISTICS XML ON;
GO
--Start extended event
ALTER EVENT SESSION [query_trace_column_values] ON SERVER STATE=START;
--Concatenate
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
ORDER BY col1;

SELECT @C;
GO
/*
--Run from new session
DECLARE @target_data XML;

SELECT @target_data = CAST( target_data AS XML )
FROM sys.dm_xe_sessions AS s 
    INNER JOIN sys.dm_xe_session_targets AS t ON t.event_session_address = s.address
WHERE s.name = 'query_trace_column_values';

;WITH cte AS
(SELECT n.c.query('.') as x
 FROM @target_data.nodes('/RingBufferTarget/event') n(c))
SELECT
x.value('(/event/data[@name="node_id"]/value)[1]', 'int') as node_id,
x.value('(/event/data[@name="column_name"]/value)[1]', 'sysname') as column_name,
x.value('(/event/data[@name="column_value"]/value)[1]', 'sysname') as column_value,
x.value('(/event/data[@name="row_id"]/value)[1]', 'sysname') as row_id,
x.value('(/event/data[@name="row_number"]/value)[1]', 'sysname') as row_number
FROM cte
ORDER BY row_id, column_name;
*/
--Stop extende event
ALTER EVENT SESSION [query_trace_column_values] ON SERVER STATE=STOP;

--------------------------------------------------
CREATE NONCLUSTERED INDEX idx_T1_col2 ON dbo.T1(col2, col1);
--------------------------------------------------
--Start extended event
ALTER EVENT SESSION [query_trace_column_values] ON SERVER STATE=START;
--Concatenate
GO
DECLARE @C AS VARCHAR(MAX) = ''

SELECT @C = @C + col2 + ';'
FROM dbo.T1
ORDER BY col1;

SELECT @C;
GO
--------------------------------------------------
--Cleanup
SET STATISTICS XML OFF;
DBCC TRACEOFF(2486);
GO
IF EXISTS (SELECT *
	FROM sys.server_event_sessions
	WHERE NAME = 'query_trace_column_values')
DROP EVENT SESSION [query_trace_column_values] ON SERVER;
GO
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL
  DROP TABLE dbo.T1;