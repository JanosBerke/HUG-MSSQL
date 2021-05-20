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
OPTION (RECOMPILE);
GO
--Run with old CE, turn on trace flag for every session
DBCC TRACEON (9481, -1);
GO
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
OPTION (RECOMPILE);
GO
--Turn off old CE
DBCC TRACEOFF (9481, -1);
GO
--Run with old CE, change database compatibility level
ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 110;
GO
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
OPTION (RECOMPILE);
GO
--Change compatibility level to use new CE
ALTER DATABASE [AdventureWorks2017] SET COMPATIBILITY_LEVEL = 140;
GO
--Run with old CE, turn on legacy cardinality estimation on database level
ALTER DATABASE SCOPED CONFIGURATION
SET LEGACY_CARDINALITY_ESTIMATION = ON;
GO
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
OPTION (RECOMPILE);
GO
--Turn off legacy cardinality estimation 
ALTER DATABASE SCOPED CONFIGURATION
SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
--Challenge: How can I force bad plan with the new CE?
GO
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
OPTION (RECOMPILE);
GO
--Hints on indexes
GO
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.HumanResources.Employee AS e
       INNER MERGE JOIN AdventureWorks2017.Person.Person AS p
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER MERGE JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID))
       INNER LOOP JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID))
OPTION (RECOMPILE);
GO
--Move Person to the first place
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.Person.Person AS p
       INNER MERGE JOIN AdventureWorks2017.HumanResources.Employee AS e
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --1
       INNER MERGE JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --2
       INNER LOOP JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID)) --3
OPTION (RECOMPILE);
GO
--https://docs.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-join?view=sql-server-2017
--Read the remarks
GO
--Change join order
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.Person.Person AS p
       INNER MERGE JOIN AdventureWorks2017.HumanResources.Employee AS e
       INNER MERGE JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --2
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --1
       INNER LOOP JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID)) --3
OPTION (RECOMPILE);
GO
--Change join order
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.Person.Person AS p
       INNER MERGE JOIN AdventureWorks2017.HumanResources.Employee AS e
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --1
       INNER MERGE JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       INNER LOOP JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID)) --3
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --2
OPTION (RECOMPILE);
GO
--Change join order
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.Person.Person AS p
       INNER MERGE JOIN AdventureWorks2017.HumanResources.Employee AS e
       INNER MERGE JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       INNER LOOP JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID)) --3
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --2
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --1
OPTION (RECOMPILE);
GO
--Change join order with serial plan
SELECT e.BusinessEntityID, p.Title, p.FirstName, p.MiddleName,
       p.LastName, p.Suffix, e.JobTitle, p.EmailPromotion,
       a.AddressLine1, a.AddressLine2, a.City,
       a.PostalCode, p.AdditionalContactInfo
FROM   AdventureWorks2017.Person.Person AS p
       INNER MERGE JOIN AdventureWorks2017.HumanResources.Employee AS e
       INNER MERGE JOIN AdventureWorks2017.Person.BusinessEntityAddress AS bea
       INNER LOOP JOIN AdventureWorks2017.Person.Address AS a
       ON RTRIM(LTRIM(a.AddressID)) = RTRIM(LTRIM(bea.AddressID)) --3
       ON RTRIM(LTRIM(bea.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --2
       ON RTRIM(LTRIM(p.BusinessEntityID)) = RTRIM(LTRIM(e.BusinessEntityID)) --1
OPTION (RECOMPILE, MAXDOP 1);
GO
--Books about SQL Server
--https://www.amazon.com/T-SQL-Fundamentals-3rd-Itzik-Ben-Gan/dp/150930200X/
--https://www.amazon.com/T-SQL-Querying-Developer-Reference-Ben-Gan/dp/0735685045/
--https://www.amazon.com/Microsoft-SQL-Server-2012-Internals-ebook/dp/B00JDMQJYC/
--https://www.amazon.com/Pro-Server-Internals-Dmitri-Korotkevitch/dp/1484219635/
--https://www.red-gate.com/simple-talk/books/sql-server-execution-plans-third-edition-by-grant-fritchey/