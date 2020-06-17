--Basic CRUD

GO
--2.Find All Information About Departments
USE SoftUni;

SELECT *
	FROM Departments AS d;

GO
--3.Find all Department Names
SELECT d.[Name]
	FROM Departments AS d;

GO
--4.Find Salary of Each Employee
SELECT e.FirstName, e.LastName, e.Salary
	FROM Employees AS e;

GO
--5.Find Full Name of Each Employee
SELECT e.FirstName, e.MiddleName, e.LastName
	FROM Employees AS e;

GO
--6.Find Email Address of Each Employee
SELECT CONCAT(e.FirstName, '.', e.LastName, '@softuni.bg') AS [Full Email Address]
	FROM Employees AS e;

GO
--7.Find All Different Employee’s Salaries
SELECT DISTINCT e.Salary
	FROM Employees AS e;

GO
--8.Find all Information About Employees
SELECT *
	FROM Employees AS e
		WHERE e.JobTitle = 'Sales Representative';

GO
--9.Find Names of All Employees by Salary in Range
SELECT e.FirstName, e.LastName, e.JobTitle
	FROM Employees AS e
		WHERE e.Salary >= 20000 AND e.Salary <= 30000;

GO
--10.Find Names of All Employees
SELECT CONCAT(e.FirstName, ' ', e.MiddleName, ' ', e.LastName) AS [Full Name]
	FROM Employees AS e
		WHERE e.Salary IN (25000, 14000, 12500, 23600);

GO
--11.Find All Employees Without Manager
SELECT e.FirstName, e.LastName
	FROM Employees AS e
		WHERE e.ManagerID IS NULL;​

GO
--12.Find All Employees with Salary More Than
SELECT e.FirstName, e.LastName, e.Salary
	FROM Employees AS e
		WHERE e.Salary > 50000
			ORDER BY e.Salary DESC;

GO
--13.Find 5 Best Paid Employees
SELECT TOP(5) e.FirstName, e.LastName
	FROM Employees AS e
		ORDER BY e.Salary DESC;

GO
--14.Find All Employees Except Marketing
SELECT e.FirstName, e.LastName
	FROM Employees AS e
		WHERE e.DepartmentID != 4;

GO
--15.Sort Employees Table
SELECT *
	FROM Employees AS e
		ORDER BY e.Salary DESC,
		         e.FirstName ASC,
				 e.LastName DESC,
				 e.MiddleName ASC;

GO
--16.Create View Employees with Salaries
CREATE VIEW V_EmployeesSalaries
	AS
		(SELECT e.FirstName, e.LastName, e.Salary
			FROM Employees AS e);

GO
--17.Create View Employees with Job Titles
CREATE VIEW V_EmployeeNameJobTitle 
	AS
		(SELECT CONCAT(e.FirstName, ' ', e.MiddleName, ' ', e.LastName) AS [Full Name],
		        e.JobTitle AS [Job Title]
			FROM Employees AS e);

GO
--18.Distinct Job Titles
SELECT DISTINCT e.JobTitle
	FROM Employees AS e;

GO
--19.Find First 10 Started Projects
SELECT TOP(10) *
	FROM Projects AS p
		ORDER BY p.StartDate ASC,
		         p.[Name] ASC;

GO
--20.Last 7 Hired Employees
SELECT TOP(7) e.FirstName, e.LastName, e.HireDate
	FROM Employees AS e
		ORDER BY e.HireDate DESC;

GO
--21.Increase Salaries
UPDATE Employees
	SET Salary += Salary * 0.12
		WHERE DepartmentID IN (1, 2, 4, 11);

SELECT e.Salary
	FROM Employees AS e;

GO
--22.All Mountain Peaks
USE [Geography];

SELECT p.PeakName
	FROM Peaks AS p
		ORDER BY p.PeakName ASC;

GO
--23.Biggest Countries by Population
SELECT TOP(30) c.CountryName, c.[Population]
	FROM Countries AS c
		WHERE c.ContinentCode = 'EU'
			ORDER BY c.[Population] DESC,
			         c.CountryName ASC;

GO
--24.Countries and Currency (Euro / Not Euro)
SELECT c.CountryName, c.CountryCode, 
	CASE c.CurrencyCode
		WHEN 'EUR' THEN 'Euro'
		ELSE 'Not Euro'
	END AS [Currency]
		FROM Countries AS c
			ORDER BY c.CountryName ASC;

GO
--25.All Diablo Characters
USE Diablo;

SELECT c.[Name]
	FROM Characters AS c
		ORDER BY c.[Name] ASC;