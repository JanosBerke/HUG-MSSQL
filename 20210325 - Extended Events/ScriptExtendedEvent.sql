SET NOCOUNT ON;
GO
SELECT --ses.name, 
 'IF EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name = ''' + ses.name + ''' AND session_source = ''server'')
  ALTER EVENT SESSION [' + ses.name + '] ON SERVER STATE = STOP;

IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = ''' + ses.name + ''')
  DROP EVENT SESSION [' + ses.name + '] ON SERVER;

CREATE EVENT SESSION [' + ses.name +'] ON SERVER 
' + REPLACE(EventDef.Events, '()','') + ISNULL(EventTarget.Targets, '') + CAST('
WITH (MAX_MEMORY=' + CAST(ses.max_memory AS VARCHAR(20)) +' KB,EVENT_RETENTION_MODE=' + ses.event_retention_mode_desc +',MAX_DISPATCH_LATENCY=' + CAST(ses.max_dispatch_latency/1000 AS VARCHAR(20)) +' SECONDS,MAX_EVENT_SIZE=' + CAST(ses.max_event_size AS VARCHAR(20))+ ' KB,MEMORY_PARTITION_MODE='+ ses.memory_partition_mode_desc +',TRACK_CAUSALITY=' + CASE ses.track_causality WHEN 1 THEN 'ON' ELSE 'OFF' END +',STARTUP_STATE=' + CASE ses.startup_state WHEN 1 THEN 'ON' ELSE 'OFF' END +');
GO' AS VARCHAR(1024))
FROM sys.server_event_sessions AS ses
  CROSS APPLY (SELECT STUFF(( SELECT  ',' + CHAR(10) + 'ADD EVENT ' + sese.package + '.' + sese.name + ISNULL('(' + ISNULL(sesf.SETOperation, '') + 
  ISNULL('
    ACTION(' + sesa.Actions + ')', '') +
  ISNULL('
    WHERE ' + sese.predicate, '') +')', '')
               FROM sys.server_event_session_events AS sese  --Events
               CROSS APPLY ( SELECT STUFF(( SELECT ',' + sesa.package + '.' + sesa.name
                             FROM sys.server_event_session_actions AS sesa
                             WHERE sesa.event_session_id = sese.event_session_id
                               AND sese.event_id = sesa.event_id
                             ORDER BY sesa.package, sesa.name
                             FOR XML PATH('') ), 1, 1, '') AS Actions) AS sesa  --Actions 
               OUTER APPLY (SELECT STUFF(( SELECT ',' + 'SET ' + sesf.name + '=(' + CAST(sesf.value AS VARCHAR(10)) + ')'
                            FROM sys.server_event_session_fields sesf
                            WHERE sesf.event_session_id = sese.event_session_id
                              AND sesf.object_id = sese.event_id
							FOR XML PATH('') ), 1, 1, '') AS SETOperation) AS sesf  --Fields
               WHERE ses.event_session_id = sese.event_session_id
               ORDER BY sese.package, sese.name
               FOR XML PATH(''),TYPE).value('.','varchar(max)') , 1, 2, '') AS Events) AS EventDef
CROSS APPLY (SELECT STUFF(( SELECT ',' + '
ADD TARGET ' + sest.package + '.' + sest.name + ISNULL('(SET ' + EventFields.Fields + ')', '')
             FROM sys.server_event_session_targets sest
             CROSS APPLY (SELECT STUFF((SELECT ',' + CAST(sesf.name AS VARCHAR(128)) + '=' + 
                                 CASE WHEN ISNUMERIC(CAST(sesf.value AS VARCHAR(128))) = 1
  					                  THEN '(' + CAST(sesf.value AS VARCHAR(128)) + ')'
  					                  ELSE 'N''' + CAST(sesf.value AS VARCHAR(128)) + '''' END
                          FROM sys.server_event_session_fields sesf
                          WHERE sesf.event_session_id = sest.event_session_id
                           AND sesf.object_id = sest.target_id
						  ORDER BY sesf.name
						  FOR XML PATH(''),TYPE).value('.','varchar(max)') , 1, 1, '') AS Fields)  AS EventFields
             WHERE ses.event_session_id = sest.event_session_id
             ORDER BY sest.package, sest.name
             FOR XML PATH(''),TYPE).value('.','varchar(max)') , 1, 1, '') AS Targets) AS EventTarget
--WHERE ses.name = 'system_health'
OPTION (RECOMPILE);