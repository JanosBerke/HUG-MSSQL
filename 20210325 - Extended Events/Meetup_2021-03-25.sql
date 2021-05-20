---List traces
SELECT *
FROM sys.traces;
GO
--Default trace
EXEC sp_configure 'default trace enabled';
GO
--Show advanced options
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
--Default trace
EXEC sp_configure 'default trace enabled';
--Disable advanced options
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO
--Get system configurations
SELECT *
FROM sys.configurations
WHERE name = 'default trace enabled';
GO
--List trace categories
SELECT *
FROM sys.trace_categories
ORDER BY name;
GO
--Start Profiler
--Connect localhost
--Start new trace with SQL:BatchCompleted and SQL:BatchStarting
GO
--List trace categories and events
SELECT tc.name, te.*
FROM sys.trace_categories tc
JOIN sys.trace_events te
  ON tc.category_id = te.category_id
ORDER BY tc.name, te.name;
GO
--List trace columns
SELECT te.name, tc.*
FROM sys.trace_events te
JOIN sys.trace_event_bindings teb
  ON te.trace_event_id = teb.trace_event_id
JOIN sys.trace_columns tc
  ON teb.trace_column_id = tc.trace_column_id
WHERE te.name = 'SQL:BatchCompleted'
ORDER BY tc.trace_column_id;
GO
--Get events and columns from existing trace
SELECT te.name, tc.name, tc.type_name
FROM sys.fn_trace_geteventinfo(2) ftge
JOIN sys.trace_events te
  ON ftge.eventid = te.trace_event_id
JOIN sys.trace_columns tc
  ON ftge.columnid = tc.trace_column_id
ORDER BY te.name, tc.trace_column_id;
GO
--Get filters from existing trace
SELECT tc.name, CASE WHEN ftgf.comparison_operator = 0 THEN 'Equal'
                     WHEN ftgf.comparison_operator = 1 THEN 'Not equal'
                     WHEN ftgf.comparison_operator = 2 THEN 'Greater than'
                     WHEN ftgf.comparison_operator = 3 THEN 'Less than'
                     WHEN ftgf.comparison_operator = 4 THEN 'Greater than or equal'
                     WHEN ftgf.comparison_operator = 5 THEN 'Less than or equal'
                     WHEN ftgf.comparison_operator = 6 THEN 'Like'
                     WHEN ftgf.comparison_operator = 7 THEN 'Not like' END comparison_operator,
    ftgf.value, ftgf.logical_operator
FROM sys.fn_trace_getfilterinfo(2) ftgf
JOIN sys.trace_columns tc
  ON ftgf.columnid = tc.trace_column_id;
GO
--Read data from trace files
SELECT *
FROM sys.fn_trace_gettable('C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\log_141.trc', 0);
GO
--SQL Server Profiler
--https://docs.microsoft.com/en-us/sql/tools/sql-server-profiler/sql-server-profiler

--Converting SQL Trace to Extended Events in SQL Server 2012
--https://www.sqlskills.com/blogs/jonathan/converting-sql-trace-to-extended-events-in-sql-server-2012/
GO
--List trace -> Extended Events conversion
SELECT * FROM sys.trace_xe_action_map;
SELECT * FROM sys.trace_xe_event_map;
GO
--Lists all the packages registered with the Extended Events engine
SELECT *
FROM sys.dm_xe_packages
ORDER BY name;
GO
--List Extended Events dlls
SELECT xep.name, xep.description, lm.name
FROM sys.dm_xe_packages xep
LEFT JOIN sys.dm_os_loaded_modules lm
ON xep.module_address = lm.base_address
ORDER BY xep.name;
GO
--List object types
SELECT DISTINCT object_type
FROM sys.dm_xe_objects
ORDER BY object_type;
GO
--List XE events
SELECT *
FROM sys.dm_xe_objects
WHERE object_type = 'event'
ORDER BY name
GO
--List XE actions
SELECT *
FROM sys.dm_xe_objects
WHERE object_type = 'action'
ORDER BY name
GO
--List XE events
SELECT *
FROM sys.dm_xe_objects
WHERE object_type = 'pred_compare'
ORDER BY name
GO
--List running sessions
SELECT *
FROM sys.dm_xe_sessions
ORDER BY name;
--Extended Events
--https://docs.microsoft.com/en-us/sql/relational-databases/extended-events/extended-events

--Learning extended events in 60 days
--https://jasonbrimhall.info/2015/09/08/learning-extended-events-in-60-days/

--Stairway to sql server extended events
--https://www.sqlservercentral.com/stairways/stairway-to-sql-server-extended-events

--An xevent a day: 31 days of extended events
--https://www.sqlskills.com/blogs/jonathan/an-xevent-a-day-31-days-of-extended-events/

--System Health Session
--https://docs.microsoft.com/en-us/sql/relational-databases/extended-events/use-the-system-health-session

--Inside sys.dm_os_ring_buffers
--https://mssqlwiki.com/2013/03/29/inside-sys-dm_os_ring_buffers/