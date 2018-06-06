--https://www.sqlskills.com/blogs/paul/inside-the-storage-engine-anatomy-of-a-page/
--https://www.sqlskills.com/blogs/paul/inside-the-storage-engine-anatomy-of-a-record/
--http://rusanu.com/2011/10/20/sql-server-table-columns-under-the-hood/

use tempdb;

go
select p.index_id, p.partition_number, 
	pc.leaf_null_bit,
	coalesce(cx.name, c.name) as column_name,
	pc.partition_column_id,
	pc.max_inrow_length,
	pc.max_length,
	pc.key_ordinal,
	pc.leaf_offset,
	pc.is_nullable,
	pc.is_dropped,
	pc.is_uniqueifier,
	pc.is_sparse,
	pc.is_anti_matter
from sys.system_internals_partitions p
join sys.system_internals_partition_columns pc
	on p.partition_id = pc.partition_id
left join sys.index_columns ic
	on p.object_id = ic.object_id
	and ic.index_id = p.index_id
	and ic.index_column_id = pc.partition_column_id
left join sys.columns c
	on p.object_id = c.object_id
	and ic.column_id = c.column_id	
left join sys.columns cx
	on p.object_id = cx.object_id	
	and p.index_id in (0,1)
	and pc.partition_column_id = cx.column_id
where p.object_id = object_id('dbo.x')
order by index_id, partition_number;