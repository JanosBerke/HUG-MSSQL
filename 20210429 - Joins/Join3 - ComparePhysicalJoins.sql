--Download sample database
--https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks
--https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak
/*
USE master;
GO
RESTORE DATABASE AdventureWorks2017 FROM
DISK = N'C:\temp\AdventureWorks2017.bak' WITH
MOVE N'AdventureWorks2017' TO N'C:\temp\AdventureWorks2017.mdf',
MOVE N'AdventureWorks2017_log' TO N'C:\temp\AdventureWorks2017_log.ldf',
STATS = 5, REPLACE, RECOVERY;
GO
ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 140;
GO
*/
USE AdventureWorks2017;
GO
SET STATISTICS IO, TIME ON;
GO
--No hint
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.HumanResources.Employee AS e
       INNER JOIN AdventureWorks2017.Person.Person AS p
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID));
--Join orders
--http://www.benjaminnevarez.com/2010/06/optimizing-join-orders/
GO
--Include Actual Execution Plan and Live Query Statistics
--Loop join
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.HumanResources.Employee AS e
       INNER JOIN AdventureWorks2017.Person.Person AS p
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID))
OPTION (LOOP JOIN);
GO
--Merge join
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.HumanResources.Employee AS e
       INNER JOIN AdventureWorks2017.Person.Person AS p
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID))
OPTION (MERGE JOIN);
GO
--Hash join
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.HumanResources.Employee AS e
       INNER JOIN AdventureWorks2017.Person.Person AS p
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID))
OPTION (HASH JOIN);
--Run 3 queries with hints
--Estimated vs actual plan vs statistics time

--Join properties
--https://blogs.msdn.microsoft.com/craigfr/2006/08/16/summary-of-join-properties/

--Check Query costs
--Sort operators on merge joins and order of the rows
