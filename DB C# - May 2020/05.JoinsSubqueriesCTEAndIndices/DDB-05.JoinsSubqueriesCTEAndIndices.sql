--Joins, Subqueries, CTE and Indices

GO
USE SoftUni

GO
--1.Employee Address
SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText
	FROM Employees AS e
		JOIN Addresses AS a
		ON e.AddressID = a.AddressID
			ORDER BY e.AddressID ASC;

GO
--2.Addresses with Towns
SELECT TOP(50) e.FirstName,
			   e.LastName,
			   t.[Name] AS [Town],
			   a.AddressText
	FROM Employees AS e
		JOIN Addresses AS a
		ON e.AddressID = a.AddressID
		JOIN Towns AS t
		ON a.TownID = t.TownID
			ORDER BY e.FirstName ASC,
			         e.LastName ASC;

GO
--3.Sales Employees
SELECT e.EmployeeID,
       e.FirstName,
	   e.LastName,
	   d.[Name] AS [DepartmentName]
	FROM Employees AS e
		JOIN Departments AS d
		ON e.DepartmentID = d.DepartmentID
			WHERE d.[Name] = 'Sales'
				ORDER BY e.EmployeeID ASC;

GO
--4.Employee Departments
SELECT TOP(5) e.EmployeeID,
			  e.FirstName,
			  e.Salary,
			  d.[Name] AS [DepartmentName]
	FROM Employees AS e
		JOIN Departments AS d
		ON e.DepartmentID = d.DepartmentID
			WHERE e.Salary > 15000
				ORDER BY d.DepartmentID ASC;

GO
--5.Employees Without Projects
SELECT TOP(3) e.EmployeeID, e.FirstName
	FROM Employees AS e
		LEFT JOIN EmployeesProjects AS ep
		ON e.EmployeeID = ep.EmployeeID
			WHERE ep.EmployeeID IS NULL
				ORDER BY e.EmployeeID ASC;

GO
--6.Employees Hired After
SELECT e.FirstName,
       e.LastName,
	   e.HireDate,
	   d.[Name] AS [DeptName]
	FROM Employees AS e
		JOIN Departments AS d
		ON e.DepartmentID = d.DepartmentID
			WHERE e.HireDate > '1999-01-01'
			  AND d.[Name] IN ('Sales', 'Finance')
				ORDER BY e.HireDate ASC;

GO
--7.Employees With Project
SELECT TOP(5) e.EmployeeID,
			  e.FirstName,
			  p.[Name] AS [ProjectName]
	FROM Employees AS e
		JOIN EmployeesProjects AS ep
		ON e.EmployeeID = ep.EmployeeID
		JOIN Projects AS p
		ON ep.ProjectID = p.ProjectID
			WHERE p.StartDate > '2002-08-13'
			  AND p.EndDate IS NULL
				ORDER BY e.EmployeeID ASC;

GO
--8.Employee 24
SELECT e.EmployeeID,
       e.FirstName, 
	   CASE
			WHEN YEAR(p.[StartDate]) >= 2005 THEN NULL
			ELSE p.[Name]
	   END AS [ProjectName]
	FROM Employees AS e
		JOIN EmployeesProjects AS ep
		ON e.EmployeeID = ep.EmployeeID
		JOIN Projects AS p
		ON ep.ProjectID = p.ProjectID
			WHERE e.EmployeeID = 24;

GO
--9.Employee Manager
SELECT e.EmployeeID,
       e.FirstName,
	   e.ManagerID,
	   m.FirstName AS [ManagerName]
	FROM Employees AS e
		JOIN Employees AS m
		ON e.ManagerID = m.EmployeeID
			WHERE e.ManagerID IN (3, 7)
				ORDER BY e.EmployeeID ASC;

GO
--10.Employees Summary
SELECT TOP(50) e.EmployeeID,
			   CONCAT(e.FirstName, ' ', e.LastName) AS [EmployeeName],
			   CONCAT(m.FirstName, ' ', m.LastName) AS [ManagerName],
			   d.[Name] AS [DepartmentName]
	FROM Employees AS e
		JOIN Employees AS m
		ON e.ManagerID = m.EmployeeID
		JOIN Departments AS d
		ON e.DepartmentID = d.DepartmentID
			ORDER BY e.EmployeeID ASC;

GO
--11.Min Average Salary
SELECT TOP(1) AVG(e.Salary) AS [MinAverageSalary]
	FROM Employees AS e
		GROUP BY e.DepartmentID	
			ORDER BY AVG(e.Salary) ASC;		

GO
USE [Geography];

GO
--12.Highest Peaks in Bulgaria
SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation
	FROM MountainsCountries AS mc
		JOIN Mountains AS m
		ON mc.MountainId = m.Id
		JOIN Peaks AS p
		ON m.Id = p.MountainId
			WHERE mc.CountryCode = 'BG'
			  AND p.Elevation > 2835	
				ORDER BY p.Elevation DESC;

GO
--13.Count Mountain Ranges
SELECT mc.CountryCode,
       COUNT(mc.MountainId) AS [MountainRanges]
	FROM MountainsCountries AS mc
		WHERE mc.CountryCode IN ('BG', 'RU', 'US')
			GROUP BY mc.CountryCode;

GO
--14.Countries With or Without Rivers
SELECT TOP(5) c.CountryName, r.RiverName
	FROM Countries AS c
		LEFT JOIN CountriesRivers AS cr
		ON c.CountryCode = cr.CountryCode
		LEFT JOIN Rivers AS r
		ON cr.RiverId = r.Id
			WHERE c.ContinentCode = 'AF'
				ORDER BY c.CountryName ASC;

GO
--15.Continents and Currencies
SELECT [temp].[ContinentCode], [temp].[CurrencyCode], [temp].[CurrencyUsage]
	FROM 
		(SELECT c.ContinentCode,
				c.CurrencyCode,
				COUNT(c.CurrencyCode) AS [CurrencyUsage],
				RANK() OVER (PARTITION BY c.ContinentCode ORDER BY COUNT(c.CurrencyCode) DESC) AS [Rank]
			FROM Countries AS c
				GROUP BY c.ContinentCode,
						 c.CurrencyCode) AS [temp]
		WHERE [temp].[Rank] = 1
		  AND [temp].[CurrencyUsage] > 1
			ORDER BY [temp].[ContinentCode] ASC;
			
GO
--16.Countries Without any Mountains
SELECT COUNT(*) AS [Count]
	FROM Countries AS c
		LEFT JOIN MountainsCountries AS mc
		ON c.CountryCode = mc.CountryCode
			WHERE mc.MountainId IS NULL;

GO
--17.Highest Peak and Longest River by Country
SELECT TOP(5) c.CountryName,
			  MAX(p.Elevation) AS [HighestPeakElevation],
			  MAX(r.[Length]) AS [LongestRiverLength]
	FROM Countries AS c
		LEFT JOIN MountainsCountries AS mc
		ON c.CountryCode = mc.CountryCode
		LEFT JOIN Mountains AS m
		ON mc.MountainId = m.Id
		LEFT JOIN Peaks AS p
		ON m.Id = p.MountainId
		LEFT JOIN CountriesRivers AS cr
		ON c.CountryCode = cr.CountryCode
		LEFT JOIN Rivers AS r
		ON cr.RiverId = r.Id
			GROUP BY c.CountryName
				ORDER BY [HighestPeakElevation] DESC,
				         [LongestRiverLength] DESC,
						 c.CountryName ASC;
				         
GO
--18.Highest Peak Name and Elevation by Country
SELECT TOP(5) [temp].Country,
			  ISNULL([temp].PeakName, '(no highest peak)') AS [Highest Peak Name],
			  ISNULL([temp].Elevation, 0) AS [Highest Peak Elevation],
			  ISNULL([temp].MountainRange, '(no mountain)') AS [Mountain]
	FROM
		(SELECT c.CountryName AS [Country],
                p.PeakName,
	            p.Elevation,
	            m.MountainRange,
	            RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS [Rank]
			FROM Countries AS c
				LEFT JOIN MountainsCountries AS mc
				ON c.CountryCode = mc.CountryCode
				LEFT JOIN Mountains AS m
				ON mc.MountainId = m.Id
				LEFT JOIN Peaks AS p
				ON m.Id = p.MountainId) AS [temp]
					ORDER BY [temp].Country ASC,
					         [Highest Peak Name] ASC;