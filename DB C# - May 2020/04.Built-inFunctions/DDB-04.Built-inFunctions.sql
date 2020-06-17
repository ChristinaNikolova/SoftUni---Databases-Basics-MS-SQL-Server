--Built-in Functions

GO
USE SoftUni;

GO
--1.Find Names of All Employees by First Name
SELECT e.FirstName, e.LastName
	FROM Employees AS e
		WHERE e.FirstName LIKE 'Sa%';

GO
--2.Find Names of All Employees by Last Name
SELECT e.FirstName, e.LastName
	FROM Employees AS e	
		WHERE e.LastName LIKE '%ei%';

GO
--3.Find First Names of All Employess
SELECT e.FirstName
	FROM Employees AS e
		WHERE e.DepartmentID IN (3, 10)
		  AND YEAR(e.HireDate) >= 1995 AND YEAR(e.HireDate) <= 2005;

GO
--4.Find All Employees Except Engineers
SELECT e.FirstName, e.LastName
	FROM Employees AS e
		WHERE e.JobTitle NOT LIKE '%engineer%';

GO
--5.Find Towns with Name Length
SELECT t.[Name]
	FROM Towns AS t
		WHERE LEN(t.[Name]) IN (5, 6)
			ORDER BY t.[Name] ASC;

GO
--6.Find Towns Starting With
SELECT t.TownID, t.[Name]
	FROM Towns AS t
		WHERE LEFT(t.[Name], 1) IN ('M', 'K', 'B', 'E')
			ORDER BY t.[Name] ASC;

GO
--7.Find Towns Not Starting With
SELECT t.TownID, t.[Name]
	FROM Towns AS t
		WHERE LEFT(t.[Name], 1) NOT IN ('R', 'B', 'D')
			ORDER BY t.[Name] ASC;

GO
--8.Create View Employees Hired After
CREATE VIEW V_EmployeesHiredAfter2000 
	AS
		(SELECT e.FirstName, e.LastName
			FROM Employees AS e
				WHERE YEAR(e.HireDate) > 2000);

GO
--9.Length of Last Name
SELECT e.FirstName, e.LastName
	FROM Employees AS e
		WHERE LEN(e.LastName) = 5;

GO
--10.Rank Employees by Salary
SELECT e.EmployeeID,
       e.FirstName,
	   e.LastName,
	   e.Salary,
	   DENSE_RANK() OVER(PARTITION BY e.Salary ORDER BY e.EmployeeID) AS [Rank]
	FROM Employees AS e
		WHERE e.Salary BETWEEN 10000 AND 50000
			ORDER BY e.Salary DESC;

GO
--11.Find All Employees with Rank 2
SELECT *
	FROM 
		(SELECT e.EmployeeID,
                e.FirstName,
	            e.LastName,
	            e.Salary,
	            DENSE_RANK() OVER(PARTITION BY e.Salary ORDER BY e.EmployeeID) AS [Rank]
			FROM Employees AS e
				WHERE e.Salary BETWEEN 10000 AND 50000) AS [temp]
		WHERE [temp].[Rank] = 2
			ORDER BY [temp].Salary DESC;

GO
USE [Geography]

GO
--12.Countries Holding 'A'
SELECT c.CountryName AS [Country Name],
       c.IsoCode AS [ISO Code]
	FROM Countries AS c
		WHERE c.CountryName LIKE '%a%a%a%'		
			ORDER BY [ISO Code] ASC;

GO
--13.Mix of Peak and River Names
SELECT p.PeakName,
       r.RiverName,
	   LOWER(CONCAT(p.PeakName, SUBSTRING(r.RiverName, 2, LEN(r.RiverName)))) AS [Mix]
	FROM Peaks AS p, Rivers AS r
		WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
			ORDER BY [Mix] ASC;

GO
USE Diablo;

GO
--14.Games From 2011 and 2012 Year
SELECT TOP(50) g.[Name],
                FORMAT(g.[Start], 'yyyy-MM-dd') AS [Start]
	FROM Games AS g
		WHERE YEAR(g.[Start]) >= 2011 AND YEAR(g.[Start]) <= 2012
			   ORDER BY [Start] ASC,
						g.[Name] ASC


GO
--15.User Email Providers
SELECT u.Username,
       SUBSTRING(u.Email, CHARINDEX('@', u.Email, 1) + 1, LEN(u.Email)) AS [Email Provider]
	FROM Users AS u
		ORDER BY [Email Provider] ASC,
		         u.Username ASC;

GO
--16.Get Users with IPAddress Like Pattern
SELECT u.Username,
       u.IpAddress AS [IP Address]
	FROM Users AS u
		WHERE u.IpAddress LIKE '___.1_%._%.___'
			ORDER BY u.Username ASC;

GO
--17.Show All Games with Duration
SELECT g.[Name] AS [Game],
       CASE
			WHEN DATEPART(HOUR, g.[Start]) >= 0 AND DATEPART(HOUR, g.[Start]) < 12 THEN 'Morning'
			WHEN DATEPART(HOUR, g.[Start]) >= 12 AND DATEPART(HOUR, g.[Start]) < 18 THEN 'Afternoon'
			WHEN DATEPART(HOUR, g.[Start]) >= 18 AND DATEPART(HOUR, g.[Start]) < 24 THEN 'Evening'
	   END AS [Part of the Day],
	   CASE	
			WHEN g.Duration <= 3 THEN 'Extra Short'
			WHEN g.Duration >= 4 AND g.Duration <= 6 THEN 'Short'
			WHEN g.Duration > 6 THEN 'Long'
			ELSE 'Extra Long'
	   END AS [Duration]
	FROM Games AS g
		ORDER BY [Game] ASC,
		         [Duration] ASC,
				 [Part of the Day] ASC;

GO
USE Orders;

GO
--18.Orders Table
SELECT o.ProductName,
       o.OrderDate,
	   DATEADD(DAY, 3, o.OrderDate) AS [Pay Due],
	   DATEADD(MONTH, 1, o.OrderDate) AS [Deliver Due]
	FROM Orders AS o;

GO
--19.People Table
CREATE DATABASE People;
USE People;

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
	Birthdate DATETIME2,
);

INSERT INTO People([Name], Birthdate)
	VALUES
		('Victor', '2000-12-07 00:00:00.000'),
		('Steven', '1992-09-10 00:00:00.000'),
		('Stephen', '1910-09-19 00:00:00.000'),
		('John', '2010-01-06 00:00:00.000');

SELECT p.[Name],
       DATEDIFF(YEAR, p.Birthdate, GETDATE()) AS [Age in Years],
	   DATEDIFF(MONTH, p.Birthdate, GETDATE()) AS [Age in Months],
	   DATEDIFF(DAY, p.Birthdate, GETDATE()) AS [Age in Days],
	   DATEDIFF(MINUTE, p.Birthdate, GETDATE()) AS [Age in Minutes]
	FROM People AS p;

