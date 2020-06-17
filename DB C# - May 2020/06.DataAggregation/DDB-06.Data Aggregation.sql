--Exercises: Data Aggregation
GO
USE Gringotts;

GO
--1.Records’ Count
SELECT COUNT(*) AS [Count]
	FROM WizzardDeposits AS wd;

GO
--2.Longest Magic Wand
SELECT MAX(wd.MagicWandSize) AS [LongestMagicWand]
	FROM WizzardDeposits AS wd;

GO
--3.Longest Magic Wand per Deposit Groups
SELECT wd.DepositGroup,
       MAX(wd.MagicWandSize) AS [LongestMagicWand]
	FROM WizzardDeposits AS wd
		GROUP BY wd.DepositGroup;

GO
--4.Smallest Deposit Group per Magic Wand Size
SELECT TOP(2) wd.DepositGroup
	FROM WizzardDeposits AS wd
		GROUP BY wd.DepositGroup
			ORDER BY AVG(wd.MagicWandSize) ASC;

GO
--5.Deposits Sum
SELECT wd.DepositGroup,
       SUM(wd.DepositAmount) AS [TotalSum]
	FROM WizzardDeposits AS wd
		GROUP BY wd.DepositGroup;

GO
--6.Deposits Sum for Ollivander Family
SELECT wd.DepositGroup,
       SUM(wd.DepositAmount) AS [TotalSum]
	FROM WizzardDeposits AS wd
		WHERE wd.MagicWandCreator = 'Ollivander family'
			GROUP BY wd.DepositGroup;

GO
--7.Deposits Filter
SELECT wd.DepositGroup,
       SUM(wd.DepositAmount) AS [TotalSum]
	FROM WizzardDeposits AS wd
		WHERE wd.MagicWandCreator = 'Ollivander family'
			GROUP BY wd.DepositGroup
				HAVING SUM(wd.DepositAmount) < 150000
					ORDER BY [TotalSum] DESC;

GO
--8.Deposit Charge
SELECT wd.DepositGroup,
       wd.MagicWandCreator,
	   MIN(wd.DepositCharge) AS [MinDepositCharge]
	FROM WizzardDeposits AS wd
		GROUP BY wd.DepositGroup,
		         wd.MagicWandCreator
			ORDER BY wd.MagicWandCreator ASC,
			         wd.DepositGroup ASC;

GO
--9.Age Groups
SELECT CASE
			WHEN wd.Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN wd.Age BETWEEN 11 AND 20 THEN '[11-20]'
			WHEN wd.Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN wd.Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN wd.Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN wd.Age BETWEEN 51 AND 60 THEN '[51-60]'
			WHEN wd.Age >= 61 THEN '[61+]'
       END AS [AgeGroup],
	   COUNT(wd.Id) AS [WizardCount]
	FROM WizzardDeposits AS wd
		GROUP BY (CASE
			          WHEN wd.Age BETWEEN 0 AND 10 THEN '[0-10]'
			          WHEN wd.Age BETWEEN 11 AND 20 THEN '[11-20]'
			          WHEN wd.Age BETWEEN 21 AND 30 THEN '[21-30]'
			          WHEN wd.Age BETWEEN 31 AND 40 THEN '[31-40]'
			          WHEN wd.Age BETWEEN 41 AND 50 THEN '[41-50]'
			          WHEN wd.Age BETWEEN 51 AND 60 THEN '[51-60]'
			          WHEN wd.Age >= 61 THEN '[61+]'
				  END);

GO
--10.First Letter
SELECT LEFT(wd.FirstName, 1) AS [FirstLetter]
	FROM WizzardDeposits AS wd
		WHERE wd.DepositGroup = 'Troll Chest'
			GROUP BY LEFT(wd.FirstName, 1)
				ORDER BY [FirstLetter] ASC;

GO
--11.Average Interest
SELECT wd.DepositGroup,
       wd.IsDepositExpired,
	   AVG(wd.DepositInterest) AS [AverageInterest]
	FROM WizzardDeposits AS wd
		WHERE wd.DepositStartDate > '1985-01-01'
			GROUP BY wd.DepositGroup,
					 wd.IsDepositExpired
				ORDER BY wd.DepositGroup DESC,
				         wd.IsDepositExpired ASC;

GO
--12.Rich Wizard, Poor Wizard
SELECT SUM([temp].[Difference]) AS [SumDifference]
	FROM
		(SELECT wd.FirstName AS [Host Wizard],
                wd.DepositAmount AS [Host Wizard Deposit],
	            LEAD(wd.FirstName) OVER(ORDER BY wd.Id ASC) AS [Guest Wizard],
	            LEAD(wd.DepositAmount) OVER(ORDER BY wd.Id ASC) AS [Guest Wizard Deposit],
	            wd.DepositAmount - LEAD(wd.DepositAmount) OVER(ORDER BY wd.Id ASC) AS [Difference]
			FROM WizzardDeposits AS wd) AS [temp];

GO
USE SoftUni;

GO
--13.Departments Total Salaries
SELECT e.DepartmentID,
       SUM(e.Salary) AS [TotalSalary]
	FROM Employees AS e
		GROUP BY e.DepartmentID
			ORDER BY e.DepartmentID ASC;

GO
--14.Employees Minimum Salaries
SELECT e.DepartmentID,
       MIN(e.Salary) AS [MinimumSalary]
	FROM Employees AS e
		WHERE e.DepartmentID IN (2, 5, 7)
		  AND e.HireDate > '2000-01-01'
			GROUP BY e.DepartmentID;

GO
--15.Employees Average Salaries
SELECT *
	INTO EmployeesWithHighestSalaries
		FROM Employees AS e
			WHERE e.Salary > 30000;

DELETE EmployeesWithHighestSalaries
	WHERE ManagerID = 42;

UPDATE EmployeesWithHighestSalaries
	SET Salary += 5000
		WHERE DepartmentID = 1;

SELECT t.DepartmentID,
       AVG(t.Salary) AS [AverageSalary]
	FROM EmployeesWithHighestSalaries AS t
		GROUP BY t.DepartmentID;

GO
--16.Employees Maximum Salaries
SELECT e.DepartmentID,
       MAX(e.Salary) AS [MaxSalary]
	FROM Employees AS e
		GROUP BY e.DepartmentID
			HAVING MAX(e.Salary) NOT BETWEEN 30000 AND 70000;

GO
--17.Employees Count Salaries
SELECT COUNT(e.Salary) AS [Count]
	FROM Employees AS e
		WHERE e.ManagerID IS NULL;

GO
--18.3rd Highest Salary 
SELECT [temp].DepartmentID,
       [temp].Salary AS [ThirdHighestSalary]
	FROM 
		(SELECT e.DepartmentID,
                e.Salary,
	            DENSE_RANK() OVER(PARTITION BY e.DepartmentID ORDER BY e.Salary DESC) AS [Rank]
			FROM Employees AS e) AS [temp]
		WHERE [temp].[Rank] = 3
			GROUP BY [temp].DepartmentID,
			         [temp].Salary;

GO
--19.Salary Challenge 
SELECT TOP(10) e.FirstName, e.LastName, e.DepartmentID
	FROM Employees AS e
		WHERE e.Salary > (SELECT AVG(e2.Salary)
								FROM Employees AS e2
									WHERE e.DepartmentID = e2.DepartmentID
										GROUP BY e2.DepartmentID)
			ORDER BY e.DepartmentID;