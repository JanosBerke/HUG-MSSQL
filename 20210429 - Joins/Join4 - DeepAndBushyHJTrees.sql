--Left deep, right deep, bushy hash join tree
--https://blogs.msdn.microsoft.com/craigfr/2006/08/10/hash-join/
USE tempdb;
GO
--Drop tables if exist
IF OBJECT_ID('T1') IS NOT NULL
  DROP TABLE T1;
IF OBJECT_ID('T2') IS NOT NULL
  DROP TABLE T2;
IF OBJECT_ID('T3') IS NOT NULL
  DROP TABLE T3;
IF OBJECT_ID('T4') IS NOT NULL
  DROP TABLE T4;
GO
--Create tables
CREATE TABLE T1 (a INT, b INT, x CHAR(200));
CREATE TABLE T2 (a INT, b INT, x CHAR(200));
CREATE TABLE T3 (a INT, b INT, x CHAR(200));
CREATE TABLE T4 (a INT, b INT, x CHAR(200));
GO
--Fill T1
SET NOCOUNT ON
DECLARE @i INT = 0;
WHILE @i < 1000
  BEGIN
    INSERT T1 VALUES (@i * 2, @i * 5, @i);
    SET @i = @i + 1;
  END
GO
--Fill T2
DECLARE @i INT = 0;
WHILE @i < 10000
  BEGIN
    INSERT T2 VALUES (@i * 3, @i * 7, @i);
    SET @i = @i + 1;
  END
GO
--Fill T3
DECLARE @i INT = 0;
WHILE @i < 100000
  BEGIN
    INSERT T3 VALUES (@i * 5, @i * 11, @i);
    SET @i = @i + 1;
  END
GO
--Fill T4
DECLARE @i INT = 0;
WHILE @i < 100000
  BEGIN
    INSERT T4 VALUES (@i * 7, @i * 13, @i);
    SET @i = @i + 1;
  END
GO
SET STATISTICS IO, TIME ON;
GO
--Simple plan
SELECT *
FROM T1 JOIN T2 ON T1.a = T2.a;
GO
--Left deep plan
SELECT *
FROM (T1 JOIN T2 ON T1.a = T2.a)
    JOIN T3 ON T1.b = T3.a;
GO
--Right deep plan
SELECT *
FROM (T1 JOIN T2 ON T1.a = T2.a)
    JOIN T3 ON T1.b = T3.a
WHERE T1.a < 100;
--4 tables
--Left deep plan
SELECT *
FROM T1 
    JOIN T2 ON T1.a = T2.a
    JOIN T3 ON T1.a = T3.a
    JOIN T4 ON T3.a = T4.a;
GO
--Bushy tree
SELECT *
FROM (T1 JOIN T2 ON T1.a = T2.a)
    JOIN 
	(T3 JOIN T4 ON T3.a = T4.a)
	ON T1.a = T3.a
OPTION (FORCE ORDER);