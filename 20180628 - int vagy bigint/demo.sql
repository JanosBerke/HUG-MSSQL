USE [integer]
GO

/*
DECLARE @s   bigint = 1048576
DECLARE @i   int = 2048 -- 0/2048
WHILE @i > -2048 -- -2048 / 0
BEGIN
	   
	   INSERT INTO T2
	   SELECT TOP (@s)
		   ROW_NUMBER() OVER (ORDER BY a.column_id ASC)-@s*@i-1
	   FROM
		   sys.columns a
	   CROSS JOIN 
		  sys.columns b
	   CROSS JOIN 
		  sys.columns c

	   SET @i -= 1
	   BACKUP LOG [integer] to disk = N'nul:'
END
*/


-- integer összes értékének helyfoglalása (nettó)
SELECT 2*POWER(2.,31)*4/1024/1024/1024 AS [size_gb]

-- bigint összes értékének helyfoglalása (nettó)
SELECT 2*POWER(2.,63)*8/1024/1024/1024/1024/1024/1024 AS [size_exabytes]

-- sql db max méret 524 PB
SELECT 2*POWER(2.,63)*8/1024/1024/1024/1024/1024/524 AS [num_of_db]

-- valóban???
EXEC sp_spaceused 'T1'

/*CCI
name	rows			reserved		 data		  index_size	unused
T1	4294967296	11534568 KB	 11436080 KB	  16 KB		98472 KB
*/


EXEC sp_spaceused 'T2'
/* rowstore
name	rows			reserved		 data		  index_size	unused
T2	4294967296     55330568 KB	 55240768 KB	  89392 KB	408 KB
				54033 MB		 53946 MB		  87 MB
 */			 


-- mi van a page-en
-- page T2
DBCC IND ('integer', 't2', 0)

DBCC TRACEON (3604);
DBCC PAGE (N'integer', 1, 6933032, 3);
GO
/*
m_type = 1 data page
m_slotCnt = 622 sorok száma
Metadata: IndexId = 1 CI

Slot 0 Offset 0x60 Length 11

Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP    Record Size = 11

Slot 0 Column 0 Offset 0x0 Length 4 Length (physical) 0 --> nem uniqie index! 4 byte lenne, ha duplikátum van
UNIQUIFIER = 0                      

Slot 0 Column 1 Offset 0x4 Length 4 Length (physical) 4
col1 = 1611698890 
*/

DBCC TRACEON (3604);
DBCC PAGE (N'integer', 1, 6933032, 2);
GO

/* 2 byte / sor
OFFSET TABLE:

Row - Offset                        
621 (0x26d) - 6927 (0x1b0f)         
620 (0x26c) - 6916 (0x1b04) 
*/

/*
Így a page helyfoglalás
96 byte header
622*11 byte sor
622*2 byte row offset
total: 8182 byte a 8196 byte-ból
*/


-- index info
SELECT 
    [page_count]   * 8  /1024		 AS [pages_mb],
    [record_count] * 4  /1024/1024	 AS [net_int_size_mb],
    [record_count] * 11 /1024/1024	 AS [data_size_mb],
    [record_count] * 2  /1024/1024	 AS [row_offset_size_mb],
    *
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('T2'), 1, NULL, 'DETAILED')


-- CCI
SELECT
    SUM([total_rows]) AS [rows],
    SUM([size_in_bytes])/1024/1024 AS [size_mb]
FROM sys.dm_db_column_store_row_group_physical_stats
WHERE
    [object_id] = OBJECT_ID('T1')