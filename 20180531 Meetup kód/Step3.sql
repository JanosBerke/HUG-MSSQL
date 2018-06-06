use tempdb;
go
--Change colunm type
alter table dbo.x
alter column a char(5) not null;

go
--Index physical stats
select *
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.x'), null, null, 'DETAILED')
order by object_id, index_id, partition_number, index_level;

go
--Check data page allocation
select allocated_page_page_id, is_allocated, is_iam_page, page_free_space_percent, page_type_desc, page_level 
from sys.dm_db_database_page_allocations(db_id(), object_id('dbo.x'), null, null, 'DETAILED')
where page_level is not null
order by page_type desc, allocated_page_page_id;

go
--Query physical location
select *, sys.fn_PhysLocFormatter(%%physloc%%) as physloc
from dbo.x
order by a;

go
--Check page
dbcc traceon(3604);
dbcc page(2, 1, 264, 3);
dbcc page(2, 3, 40, 3);

go