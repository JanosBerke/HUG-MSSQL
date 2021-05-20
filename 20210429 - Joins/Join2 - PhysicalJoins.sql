use tempdb;
go
--Check if table exists
if object_id('dbo.fiuk') is not null
  drop table dbo.fiuk;
go
create table dbo.fiuk (id int, nev nvarchar(20))
go
--Check if table exists
if object_id('dbo.lanyok') is not null
  drop table dbo.lanyok;
go
create table dbo.lanyok (id int, nev nvarchar(20))
go
--Insert values
insert into dbo.fiuk values
(1, N'Zsolt'),
(2, N'Péter'),
(4, N'Zalán'),
(6, N'Marcell')
go
insert into dbo.lanyok values
(1, N'Júlia'),
(3, N'Mária'),
(4, N'Enikõ'),
(5, N'Éva')
go

--List all rows
select *
from dbo.fiuk

select *
from dbo.lanyok
go
set statistics io on;
go
----------------------------------------------------------------------------------------------------
--Join hints https://docs.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-join

--Nested loop
--Inner and outer table vs inner and outer join
--Force on join level
select *
from dbo.fiuk
inner loop join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Force on query level
select *
from dbo.fiuk
inner join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id
option (loop join);
 
--Algorithm for nested loop
--for each row R1 in the outer table (dbo.fiuk)
--    for each row R2 in the inner table (dbo.lanyok)
--        if R1 joins with R2
--            return (R1, R2)

--Reads outer table only once and inner table many times
--The cost is proportional to the cost of producing the outer rows multipled by the cost of producing the inner rows for each outer row.

--Does not support some logical joins (directly)
--Right and full outer join
--Right semi-join and right anti-semi-join

--Right outer join with forced inner loop join
--Error 8622
select *
from dbo.fiuk
right outer loop join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;
go
--Left outer join
select *
from dbo.fiuk
right outer join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id
option (loop join);
go

--Right outer join without forced inner loop join
--Execution plan contains left outer join with nested loop
select *
from dbo.fiuk
right outer join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Extended algorithm for left outer join
--for each row R1 in the outer table
--    begin
--        for each row R2 in the inner table
--            if R1 joins with R2
--                return (R1, R2)
--        if R1 did not join
--            return (R1, NULL)
--    end

--Full outer join = left outer join union left anti semi join
select *
from dbo.fiuk
full outer loop join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;
go

--Supports inequality predicates
select *
from dbo.fiuk
inner loop join dbo.lanyok
on dbo.fiuk.id >= dbo.lanyok.id;

--Cross join uses nested loop only
--https://docs.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql

----------------------------------------------------------------------------------------------------
--Merge join
--Requires at least 1 equijoin and inputs must be sorted on the join keys
select *
from dbo.fiuk
inner merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Sort can spill into tempdb
--https://www.sqlshack.com/sql-server-2017-sort-spill-memory-and-adaptive-memory-grant-feedback/

--Non equijoin with forced merge join
--Error 8622
select *
from dbo.fiuk
inner merge join dbo.lanyok
on dbo.fiuk.id >= dbo.lanyok.id;
go
--Does not support cross join
--Error 156
select *
from dbo.fiuk
cross merge join dbo.lanyok
go
--Algorithm for merge join
--get first row R1 from input 1
--get first row R2 from input 2
--while not at the end of either input
--    begin
--        if R1 joins with R2
--            begin
--                return (R1, R2)
--                get next row R2 from input 2
--            end
--        else if R1 < R2
--            get next row R1 from input 1
--        else
--            get next row R2 from input 2
--    end

--Create non unique index on dbo.fiuk table
create clustered index fiukid on dbo.fiuk(id)

--Sort operator on dbo.fiuk disappeared
select *
from dbo.fiuk
inner merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Create non unique index on dbo.lanyok table
create clustered index lanyokid on dbo.lanyok(id);

--Sort operator on dbo.lanyok disappeared
select *
from dbo.fiuk
inner merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;
--Check Many to Many property
--SQL Server creates worktable

--Create unique index on dbo.fiuk table
create unique clustered index fiukid on dbo.fiuk(id) with drop_existing;

--Many to Many property is false
--Needs unique index or distinct sort or group by
--No worktable
select *
from dbo.fiuk
inner merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Create unique index on dbo.lanyok table
create unique clustered index lanyokid on dbo.lanyok(id) with drop_existing;

--Many to Many property is false
select *
from dbo.fiuk
inner merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Remove unique index on dbo.fiuk table
create clustered index fiukid on dbo.fiuk(id) with drop_existing;

--Many to Many property is true
--Worktable appeares on the Messages tab
select *
from dbo.fiuk
inner merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Supports all outer joins
--Left outer
select *
from dbo.fiuk
left outer merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;
--Right outer
select *
from dbo.fiuk
right outer merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;
--Full outer
select *
from dbo.fiuk
full outer merge join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Create unique index on dbo.fiuk table
create unique clustered index fiukid on dbo.fiuk(id) with drop_existing;

--Sometimes supports full outer join without equality predicate
--There are unique index on buth tables
--Many to Many property is true
select *
from dbo.fiuk
full outer merge join dbo.lanyok
on dbo.fiuk.id >= dbo.lanyok.id;

--Index cleanup
drop index lanyokid on dbo.lanyok;
drop index fiukid on dbo.fiuk;

----------------------------------------------------------------------------------------------------
--Hash join
--Requires at least one equijoin predicate
--The hash join executes in two phases: build and probe
--Hash function can lead to collisions it must check each potential match to ensure that it really joins.
select *
from dbo.fiuk
inner hash join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--for each row R1 in the build table
--    begin
--        calculate hash value on R1 join key(s)
--        insert R1 into the appropriate hash bucket
--    end
--for each row R2 in the probe table
--    begin
--        calculate hash value on R2 join key(s)
--        for each row R1 in the corresponding hash bucket
--            if R1 joins with R2
--                return (R1, R2)
--    end

--Hash join is blocking on its build input, it must completely read and process its entire build input before it can return any rows
--Requires a memory grant to store the hash table
--To minimize the memory required by the hash join, Query optimizer trys to choose the smaller of the two tables as the build table
--If the memory grant is not enough it is spilling a small percentage of the total hash table to disk (workfile in tempdb)

--Hash warning
--https://blogs.msdn.microsoft.com/sql_server_team/sql-server-2016-added-information-on-tempdb-spill-events-showplan/

--Supports all outer joins
--Left outer
select *
from dbo.fiuk
left outer hash join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;
--Right outer
select *
from dbo.fiuk
right outer hash join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;
--Full outer
select *
from dbo.fiuk
full outer hash join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id;

--Requires equijoin
--Error 8622
select *
from dbo.fiuk
inner hash join dbo.lanyok
on dbo.fiuk.id >= dbo.lanyok.id;