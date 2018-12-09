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

--Cross join
--Old syntax
select *
from dbo.fiuk, dbo.lanyok

--New syntax, use this instead of the previous 
select *
from dbo.fiuk
cross join dbo.lanyok
go

--Inner join
--Old syntax
select *
from dbo.fiuk, dbo.lanyok
where dbo.fiuk.id = dbo.lanyok.id

--New syntax, use this instead of the previous 
select *
from dbo.fiuk
inner join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id

--Non equijoin
select *
from dbo.fiuk
inner join dbo.lanyok
on dbo.fiuk.id >= dbo.lanyok.id
go

--Outer joins
--Left outer join
select *
from dbo.fiuk
left outer join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id

--Right outer join
--Check the execution plan, SQL Server optimized as a left outer join
select *
from dbo.lanyok
right outer join dbo.fiuk
on dbo.fiuk.id = dbo.lanyok.id

--Full outer jion
select *
from dbo.lanyok
full outer join dbo.fiuk
on dbo.fiuk.id = dbo.lanyok.id
go

--Take care of the where caluse in case of outer joins
select *
from dbo.fiuk
left outer join dbo.lanyok
on dbo.fiuk.id = dbo.lanyok.id
where dbo.fiuk.id < 6

select *
from dbo.lanyok
right outer join dbo.fiuk
on dbo.fiuk.id = dbo.lanyok.id
where dbo.lanyok.id < 6

select *
from dbo.lanyok
right outer join dbo.fiuk
on dbo.fiuk.id = dbo.lanyok.id and dbo.lanyok.id < 6
go

--Incorrect syntax near '*='.
select *
from dbo.lanyok, dbo.fiuk
where dbo.fiuk.id *= dbo.lanyok.id
go

--Apply
--Cross apply
select *
from dbo.fiuk
cross apply (select * from dbo.lanyok where dbo.fiuk.id = dbo.lanyok.id) as x

--Outer apply
select *
from dbo.fiuk
outer apply (select * from dbo.lanyok where dbo.fiuk.id = dbo.lanyok.id) as x
go

--Semi joins
--Semi join
select *
from dbo.fiuk
where exists (select 1 from dbo.lanyok where dbo.fiuk.id = dbo.lanyok.id) 

--Anti semi join
select *
from dbo.fiuk
where not exists (select 1 from dbo.lanyok where dbo.fiuk.id = dbo.lanyok.id) 
