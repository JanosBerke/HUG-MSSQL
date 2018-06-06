use tempdb;

go
--Drop table if exists
if object_id('dbo.x') is not null
  drop table dbo.x;

go
--create table dbo.x(a char(2) not null, b char(2) not null, placeholder char(143) null
create table dbo.x(a char(2) not null, b char(2) not null, placeholder char(62) not null, constraint pk_x primary key(b)
);

go
--Insert some rows
insert into dbo.x(a, b, placeholder ) 
select right('0' + convert(varchar(2),number), 2), right('0' + convert(varchar(2),number), 2), 'x'
from master.dbo.spt_values
where type = 'P' and number between 0 and 99;

go
--Select all rows
select *
from dbo.x;

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
/*
0 - print just the page header 
1 - page header plus per-row hex dumps and a dump of the page slot array 
2 - page header plus whole page hex dump 
3 - page header plus detailed per-row interpretation
*/
dbcc traceon(3604);
dbcc page(2, 1, 264, 3);
dbcc page(2, 3, 40, 3);

go