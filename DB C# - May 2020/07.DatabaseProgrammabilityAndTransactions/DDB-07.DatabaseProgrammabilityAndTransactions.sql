--Database Programmability and Transactions

GO
USE SoftUni;

GO
--01.Employees with Salary Above 35000
CREATE PROC usp_GetEmployeesSalaryAbove35000 
	AS
		SELECT e.FirstName AS [First Name],
		       e.LastName AS [Last Name]
			FROM Employees AS e
				WHERE e.Salary > 35000;
	GO

GO
EXEC usp_GetEmployeesSalaryAbove35000;

GO
--02.Employees with Salary Above Number
CREATE PROC usp_GetEmployeesSalaryAboveNumber(@minTargetSalary DECIMAL(18,4)) 
	AS
		SELECT e.FirstName AS [First Name],
		       e.LastName AS [Last Name]
			FROM Employees AS e
				WHERE e.Salary >= @minTargetSalary;
	GO

GO
EXEC usp_GetEmployeesSalaryAboveNumber @minTargetSalary = 48100;

GO
--03.Town Names Starting With
CREATE PROC usp_GetTownsStartingWith(@startSubstring NVARCHAR(MAX)) 
	AS
		SELECT t.[Name] AS [Town]
			FROM Towns AS t
				WHERE LEFT(t.[Name], LEN(@startSubstring)) = @startSubstring;
	GO

GO
EXEC usp_GetTownsStartingWith @startSubstring = 'b';

GO
--04.Employees from Town
CREATE PROC usp_GetEmployeesFromTown(@targetTownName NVARCHAR(MAX)) 
	AS
		SELECT e.FirstName AS [First Name],
		       e.LastName AS [Last Name]
			FROM Employees AS e
				JOIN Addresses AS a
				ON e.AddressID = a.AddressID
				JOIN Towns AS t
				ON a.TownID = t.TownID
					WHERE t.[Name] = @targetTownName;
	GO

GO
EXEC usp_GetEmployeesFromTown @targetTownName = 'Sofia';

GO
--05.Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
	RETURNS VARCHAR(7)
		AS
			BEGIN
				DECLARE @salaryLevel VARCHAR(7);

				IF(@salary < 30000)
					BEGIN
						SET @salaryLevel = 'Low';
					END
				ELSE IF(@salary BETWEEN 30000 AND 50000)
					BEGIN
						SET @salaryLevel = 'Average';
					END
				ELSE IF(@salary > 50000)
					BEGIN
						SET @salaryLevel = 'High';
					END

				RETURN @salaryLevel;
			END

GO
SELECT e.Salary,
       dbo.ufn_GetSalaryLevel(e.Salary) AS [Salary Level]
	FROM Employees AS e;

GO
--06.Employees by Salary Level
CREATE PROC usp_EmployeesBySalaryLevel(@targetSalaryLevel VARCHAR(7)) 
	AS
		SELECT e.FirstName AS [First Name],
		       e.LastName AS [Last Name]
			FROM Employees AS e
				WHERE dbo.ufn_GetSalaryLevel(e.Salary) = @targetSalaryLevel;
	GO

GO
EXEC usp_EmployeesBySalaryLevel @targetSalaryLevel = 'High';

GO
--07.Define Function
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX)) 
	RETURNS BIT
		AS
			BEGIN
				DECLARE @currentIndex INT = 1;
				DECLARE @currentSymbol NCHAR(1);

				WHILE(@currentIndex <= LEN(@word))
					BEGIN
						SET @currentSymbol = SUBSTRING(@word, @currentIndex, 1);

						IF(CHARINDEX(@currentSymbol, @setOfLetters, 1) = 0)
							BEGIN
								RETURN 0;
							END

						SET @currentIndex += 1;
					END

				RETURN 1;
			END

GO
SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia') AS [Result];

GO
--08.Delete Employees and Departments
CREATE PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
	AS
		DELETE EmployeesProjects
			WHERE EmployeeID IN (SELECT e.EmployeeID
									FROM Employees AS e
										WHERE e.DepartmentID = @departmentId);

			UPDATE Employees
				SET ManagerID = NULL	
					WHERE ManagerID IN (SELECT e.EmployeeID
											FROM Employees AS e
												WHERE e.DepartmentID = @departmentId);

			ALTER TABLE Departments
				ALTER COLUMN ManagerID INT;

            UPDATE Departments
				SET ManagerID = NULL
					WHERE ManagerID IN (SELECT e.EmployeeID
											FROM Employees AS e
												WHERE e.DepartmentID = @departmentId);

			DELETE Employees
				WHERE DepartmentID = @departmentId;

			DELETE Departments
				WHERE DepartmentID = @departmentId;

			SELECT COUNT(*)
				FROM Employees AS e
					WHERE e.DepartmentID = @departmentId;
	GO

GO
EXEC usp_DeleteEmployeesFromDepartment @departmentId = 1;

GO
USE Bank;

GO
--09.Find Full Name
CREATE PROC usp_GetHoldersFullName 
	AS
		SELECT CONCAT(ah.FirstName, ' ', ah.LastName) AS [Full Name]
			FROM AccountHolders AS ah;
	GO

GO
EXEC usp_GetHoldersFullName;

GO
--10.People with Balance Higher Than
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@targetMinBalance DECIMAL(18, 4))
	AS
		SELECT ah.FirstName AS [First Name],
		       ah.LastName AS [Last Name]
			FROM AccountHolders AS ah
				JOIN Accounts AS a
				ON ah.Id = a.AccountHolderId
					GROUP BY ah.FirstName,
					         ah.LastName
						HAVING SUM(a.Balance) > @targetMinBalance
							ORDER BY [First Name],
							         [Last Name];
	GO

GO
EXEC usp_GetHoldersWithBalanceHigherThan @targetMinBalance = 30000;

GO
--11.Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue(@initialSum DECIMAL(18, 4), @yearlyInterestRate FLOAT, @numberOfYears INT)
	RETURNS DECIMAL(18, 4)
		AS
			BEGIN
				DECLARE @futureSum DECIMAL(18, 4) = @initialSum * (POWER(1 + @yearlyInterestRate, @numberOfYears));
				RETURN @futureSum;
			END

GO
SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5) AS [Output];

GO
--12.Calculating Interest
CREATE PROC usp_CalculateFutureValueForAccount(@targetAccountId INT, @interestRate FLOAT)
	AS
		SELECT a.Id AS [Account Id],
		       ah.FirstName AS [First Name],
			   ah.LastName AS [Last Name],
			   a.Balance AS [Current Balance],
			   dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS [Balance in 5 years]
			FROM Accounts AS a
				JOIN AccountHolders AS ah
				ON a.AccountHolderId = ah.Id
					WHERE a.Id = @targetAccountId

	GO

GO
EXEC usp_CalculateFutureValueForAccount @targetAccountId = 1, @interestRate = 0.1;

GO
USE Diablo

GO
--13.Cash in User Games Odd Rows
CREATE FUNCTION ufn_CashInUsersGames(@targetGameName NVARCHAR(MAX))
	RETURNS TABLE
		AS
			RETURN
				SELECT SUM([temp].Cash) AS [SumCash]
					FROM
						(SELECT ug.Cash,
				                ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS [Rank]
							FROM UsersGames AS ug
								JOIN Games AS g
								ON ug.GameId = g.Id
									WHERE g.[Name] = @targetGameName) AS [temp]
						WHERE [temp].[Rank] % 2 = 1;

GO
SELECT *
	FROM dbo.ufn_CashInUsersGames('Love in a mist');

GO
--14.Create Table Logs
CREATE TABLE Logs
(
  LogID INT IDENTITY NOT NULL,
  AccountID INT FOREIGN KEY REFERENCES Accounts(Id),
  OldSum DECIMAL(18, 2),
  NewSum DECIMAL(18, 2),
);

CREATE TRIGGER tr_ChangeBalance ON Accounts
	AFTER UPDATE
		AS
			BEGIN
				INSERT INTO Logs(AccountID, OldSum, NewSum)
					SELECT i.Id, d.Balance, i.Balance 
						FROM inserted AS i
							INNER JOIN deleted AS d
							ON i.Id = d.Id;
			END

GO
--15.Create Table Emails
CREATE TABLE NotificationEmails
(
	Id INT IDENTITY NOT NULL,
	Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
	[Subject] VARCHAR(50),
	Body TEXT,
);

GO

CREATE TRIGGER tr_EmailsNotificationsAfterInsert
	ON Logs AFTER INSERT 
		AS
			BEGIN
				INSERT INTO NotificationEmails(Recipient, [Subject], Body)
					SELECT i.AccountID, 
						CONCAT('Balance change for account: ', i.AccountId),
							CONCAT('On ',GETDATE(),' your balance was changed from ', i.NewSum, ' to ', i.OldSum)
								FROM inserted AS i;
			END

GO
--16.Deposit Money
CREATE PROCEDURE usp_DepositMoney(@AccountId INT, @MoneyAmount MONEY)
	AS
		BEGIN TRANSACTION
			UPDATE Accounts
				SET Balance += @MoneyAmount
					WHERE Id = @AccountId;

		COMMIT

GO
--17.Withdraw Money Procedure
 CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY)
	AS
		BEGIN TRANSACTION
			UPDATE Accounts
				SET Balance -= @MoneyAmount
					WHERE Id = @AccountId;

		DECLARE @LeftBalance MONEY = (SELECT Balance 
											FROM Accounts
												 WHERE Id = @AccountId);

	 IF(@LeftBalance < 0)
		BEGIN
			ROLLBACK;
			RAISERROR('',16,2);
			RETURN;
		END
	COMMIT

GO
--18.Money Transfer
CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount MONEY)
	AS
		BEGIN TRANSACTION
			EXEC usp_DepositMoney @ReceiverId, @Amount;
			EXEC usp_WithdrawMoney @SenderId, @Amount;
	COMMIT

GO
--20.Massive Shopping
DECLARE @UserName VARCHAR(50) = 'Stamat';
DECLARE @GameName VARCHAR(50) = 'Safflower';
DECLARE @UserID INT = (SELECT Id FROM Users WHERE Username = @UserName);
DECLARE @GameID INT = (SELECT Id FROM Games WHERE [Name] = @GameName);
DECLARE @UserMoney DECIMAL(18, 2) = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID);
DECLARE @ItemsTotalPrice DECIMAL(18, 2);
DECLARE @UserGameID INT = (SELECT Id FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID);

BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 11 AND 12);

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID;
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK;
	END

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 19 AND 21);

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID;
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK;
	END

SELECT Name AS [Item Name]
FROM Items
WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @userGameID)
ORDER BY [Item Name];


GO
--21.Employees with Three Projects
CREATE PROC usp_AssignProject(@EmloyeeId INT , @ProjectID INT)
	AS
		BEGIN TRANSACTION
			DECLARE @ProjectsCount INT;
			SET @ProjectsCount = (SELECT COUNT(ProjectID) 
										FROM EmployeesProjects 
											WHERE EmployeeID = @emloyeeId);

		IF(@ProjectsCount >= 3)
			BEGIN 
				ROLLBACK;
				RAISERROR('The employee has too many projects!', 16, 1);
				RETURN;
			END

		INSERT INTO EmployeesProjects
			VALUES
			(@EmloyeeId, @ProjectID);
 
	COMMIT


GO
--22.Delete Employees
DROP TABLE Deleted_Employees;

CREATE TABLE Deleted_Employees
(
	EmployeeId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50), 
	LastName VARCHAR(50), 
	MiddleName VARCHAR(50), 
	JobTitle VARCHAR(50), 
	DeparmentId INT, 
	Salary DECIMAL(18, 2)
);

CREATE TRIGGER tr_DeleteEmployee ON Employees AFTER DELETE
	AS
		INSERT INTO Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
			SELECT d.FirstName, d.LastName, d.MiddleName, d.JobTitle, d.DepartmentID, d.Salary 
				FROM deleted AS d;


		SELECT * 
			FROM Deleted_Employees
				DELETE FROM Employees
					WHERE EmployeeID = 1;

GO