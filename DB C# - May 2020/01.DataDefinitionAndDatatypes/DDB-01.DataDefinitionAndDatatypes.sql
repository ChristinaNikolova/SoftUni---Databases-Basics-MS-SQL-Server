GO
--Data Definition and Datatypes
--1.Create Database
CREATE DATABASE Minions;
USE Minions;

GO
--2.Create Tables
CREATE TABLE Minions(
	Id INT PRIMARY KEY NOT NULL, 
	[Name] NVARCHAR(50) NOT NULL,
	Age INT CHECK(Age >= 0),
);

CREATE TABLE Towns(
	Id INT PRIMARY KEY NOT NULL, 
	[Name] NVARCHAR(50) UNIQUE NOT NULL,
);

GO
--3.Alter Minions Table
ALTER TABLE Minions
	ADD TownId INT FOREIGN KEY REFERENCES Towns(ID);

GO
--4.insert Records in Both Tables
INSERT INTO Towns(Id, [Name])
	VALUES
		(1, 'Sofia'),
		(2, 'Plovdiv'),
		(3, 'Varna');

INSERT INTO Minions(Id, [Name], Age, TownId)
	VALUES
		(1, 'Kevin', 22, 1),
		(2, 'Bob', 15, 3),
		(3, 'Steward', NULL, 2);

GO
--5.Truncate Table Minions
TRUNCATE TABLE Minions;

GO
--6.Drop All Tables
DROP TABLE Minions;
DROP TABLE Towns;

GO
--7.Create Table People
CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY,
	[Name]  NVARCHAR(200) NOT NULL,
	Picture VARBINARY (MAX) CHECK(DATALENGTH(Picture) <= 2 * 1024 * 1024),
	Height DECIMAL(3,2),
	[Weight] DECIMAL(5,2),
	Gender CHAR(1) NOT NULL,
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX),
);

INSERT INTO People([Name], Gender, Birthdate)
	VALUES
		('John', 'm', '1995-12-12'),
		('Mia', 'f', '1996-12-02'),
		('David', 'm', '1995-12-12'),
		('Dea', 'f', '1995-12-12'),
		('Peter', 'm', '1995-12-12');

GO
--8.Create Table Users
CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX) CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024),
	LastLoginTime DATETIME,
	IsDeleted BIT,
);

INSERT INTO Users(Username, [Password])
	VALUES
		('John', '123456'),
		('Mia', '123456'),
		('David', '123456'),
		('Dea', '123456'),
		('Peter', '123456');

GO
--9.Change Primary Key
ALTER TABLE Users
	DROP CONSTRAINT [PK__Users__3214EC0718C5C0BC];

ALTER TABLE Users
	ADD CONSTRAINT PK_IdUsername PRIMARY KEY(Id, Username);

GO
--10.Add Check Constraint
ALTER TABLE Users
	ADD CONSTRAINT CH_PasswordLength CHECK(LEN([Password]) >= 5);

GO
--11.Set Default Value of a Field
ALTER TABLE Users
	ADD CONSTRAINT DEFAULT_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime;

GO
--12.Set Unique Field
ALTER TABLE Users
	DROP CONSTRAINT [PK_IdUsername];

ALTER TABLE Users
	ADD CONSTRAINT PK_Id PRIMARY KEY(Id);

ALTER TABLE Users
	ADD CONSTRAINT CH_UsernameLength CHECK(LEN(Username) >= 3);

GO
--13.Movies Database
CREATE DATABASE Movies;
USE Movies;

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY, 
	DirectorName NVARCHAR(100) NOT NULL, 
	Notes NVARCHAR(MAX),
);

INSERT INTO Directors(DirectorName)
	VALUES
		('John'),
		('Mia'),
		('David'),
		('Dea'),
		('Peter');

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY, 
	GenreName NVARCHAR(50) UNIQUE NOT NULL, 
	Notes NVARCHAR(MAX),
);

INSERT INTO Genres(GenreName)
	VALUES
		('Comedy'),
		('Drama'),
		('Action'),
		('Crime'),
		('Horror');

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY, 
	CategoryName NVARCHAR(100) UNIQUE NOT NULL, 
	Notes NVARCHAR(MAX),
);

INSERT INTO Categories(CategoryName)
	VALUES
		('Comedy'),
		('Drama'),
		('Action'),
		('Crime'),
		('Horror');

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY, 
	Title NVARCHAR(100) NOT NULL, 
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL, 
	CopyrightYear INT NOT NULL, 
	[Length] DECIMAL(7,2), 
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL, 
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL, 
	Rating DECIMAL(5,2), 
	Notes NVARCHAR(MAX),
);

INSERT INTO Movies(Title, DirectorId, CopyrightYear, GenreId, CategoryId)
	VALUES
		('Movie1', 1, 1995, 1, 1),
		('Movie2', 1, 1995, 1, 4),
		('Movie3', 1, 1995, 4, 2),
		('Movie4', 1, 1995, 1, 2),
		('Movie5', 1, 1995, 3, 1);


GO
--14.Car Rental Database
CREATE DATABASE CarRental;
USE CarRental;

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY, 
	CategoryName NVARCHAR(50) UNIQUE NOT NULL, 
	DailyRate DECIMAL(7,2), 
	WeeklyRate DECIMAL(7,2), 
	MonthlyRate DECIMAL(7,2), 
	WeekendRate DECIMAL(7,2),
);

INSERT INTO Categories(CategoryName)
	VALUES 
		('Family'),
		('Sport'),
		('Minivan');

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY, 
	PlateNumber NVARCHAR(50) UNIQUE NOT NULL, 
	Manufacturer NVARCHAR(50) NOT NULL, 
	Model NVARCHAR(50) NOT NULL, 
	CarYear INT NOT NULL, 
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL, 
	Doors INT, 
	Picture VARBINARY(MAX), 
	Condition NVARCHAR(MAX), 
	Available BIT NOT NULL,
);

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Available)
	VALUES
		('1234', 'BMV', 'Random Model', 1995, 1, 1),
		('1235', 'BMV', 'Random Model', 1995, 1, 1),
		('1236', 'BMV', 'Random Model', 1995, 1, 1);

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY, 
	FirstName NVARCHAR(30) NOT NULL, 
	LastName NVARCHAR(30) NOT NULL, 
	Title NVARCHAR(20), 
	Notes NVARCHAR(MAX),
);

INSERT INTO Employees(FirstName, LastName)
	VALUES
		('John', 'Johnson'),
		('Mia', 'Johnson'),
		('David', 'Johnson');

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY, 
	DriverLicenceNumber NVARCHAR(50) UNIQUE NOT NULL, 
	FullName NVARCHAR(100) NOT NULL, 
	[Address] NVARCHAR(50), 
	City NVARCHAR(50), 
	ZIPCode INT, 
	Notes NVARCHAR(MAX),
);

INSERT INTO Customers(DriverLicenceNumber, FullName)
	VALUES
		('1234', 'John'),
		('1235', 'Mia'),
		('1236', 'David');

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL, 
	CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL, 
	TankLevel DECIMAL(10,2) NOT NULL, 
	KilometrageStart DECIMAL(18,3) NOT NULL, 
	KilometrageEnd DECIMAL(18,3) NOT NULL, 
	TotalKilometrage DECIMAL(18,3) NOT NULL, 
	StartDate DATETIME2 NOT NULL, 
	EndDate DATETIME2 NOT NULL, 
	TotalDays INT NOT NULL, 
	RateApplied DECIMAL(7,2), 
	TaxRate DECIMAL(7,2), 
	OrderStatus NVARCHAR(20), 
	Notes NVARCHAR(MAX),
);

INSERT INTO RentalOrders
	(EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays)
		VALUES
			(1, 1, 1, 1, 1, 1, 1, '2020-05-25', '2020-05-26', 1),
			(1, 1, 1, 1, 1, 1, 1, '2020-05-25', '2020-05-27', 2),
			(1, 1, 1, 1, 1, 1, 1, '2020-05-25', '2020-05-28', 3);

GO
--15.Hotel Database
CREATE DATABASE Hotel;
USE Hotel;

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY, 
	FirstName NVARCHAR(30) NOT NULL, 
	LastName NVARCHAR(30) NOT NULL, 
	Title NVARCHAR(20), 
	Notes NVARCHAR(MAX),
);

INSERT INTO Employees(FirstName, LastName)
	VALUES
		('John', 'Johnson'),
		('Mia', 'Johnson'),
		('David', 'Johnson');

CREATE TABLE Customers(
	AccountNumber NVARCHAR(50) PRIMARY KEY NOT NULL, 
	FirstName NVARCHAR(30) NOT NULL, 
	LastName NVARCHAR(30) NOT NULL, 
	PhoneNumber NVARCHAR(30), 
	EmergencyName NVARCHAR(30), 
	EmergencyNumber NVARCHAR(30), 
	Notes NVARCHAR(MAX),
);

INSERT INTO Customers(AccountNumber, FirstName, LastName)
	VALUES
		('1234', 'John', 'Johnson'),
		('1235', 'Mia', 'Johnson'),
		('1236', 'David', 'Johnson');


CREATE TABLE RoomStatus(
	RoomStatus NVARCHAR(20) PRIMARY KEY NOT NULL, 
	Notes NVARCHAR(MAX),
);

INSERT INTO RoomStatus(RoomStatus)
	VALUES
		('booked'),
		('not booked'),
		('no information');

CREATE TABLE RoomTypes(
	RoomType NVARCHAR(20) PRIMARY KEY NOT NULL, 
	Notes NVARCHAR(MAX),
);

INSERT INTO RoomTypes(RoomType)
	VALUES
		('single'),
		('double'),
		('apartment');

CREATE TABLE BedTypes(
	BedType NVARCHAR(20) PRIMARY KEY NOT NULL, 
	Notes NVARCHAR(MAX),
);

INSERT INTO BedTypes(BedType)
	VALUES
		('single'),
		('double'),
		('king');

CREATE TABLE Rooms(
	RoomNumber NVARCHAR(20) PRIMARY KEY NOT NULL, 
	RoomType NVARCHAR(20) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL, 
	BedType NVARCHAR(20) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL, 
	Rate DECIMAL(5,2), 
	RoomStatus NVARCHAR(20) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL, 
	Notes NVARCHAR(MAX),
);

INSERT INTO Rooms(RoomNumber, RoomType, BedType, RoomStatus)
	VALUES
		('1', 'single', 'single', 'booked'),
		('2', 'single', 'single', 'booked'),
		('3', 'single', 'single', 'booked');

CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	PaymentDate DATETIME2 NOT NULL, 
	AccountNumber NVARCHAR(50) FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL, 
	FirstDateOccupied DATETIME2 NOT NULL, 
	LastDateOccupied DATETIME2 NOT NULL,
	TotalDays INT NOT NULL, 
	AmountCharged DECIMAL(7,2), 
	TaxRate DECIMAL(7,2), 
	TaxAmount DECIMAL(7,2), 
	PaymentTotal DECIMAL(10,2), 
	Notes NVARCHAR(MAX)
);

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, TotalDays)
	VALUES
		(1, '2020-06-27', '1234', '2020-06-27', '2020-06-28', 1),
		(2, '2020-06-27', '1234', '2020-06-28', '2020-06-29', 1),
		(3, '2020-06-27', '1234', '2020-06-28', '2020-06-29', 1);

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY IDENTITY, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	DateOccupied DATETIME2 NOT NULL, 
	AccountNumber NVARCHAR(50) FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL, 
	RoomNumber NVARCHAR(20) FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL, 
	RateApplied DECIMAL(7,2), 
	PhoneCharge DECIMAL(7,2), 
	Notes NVARCHAR(MAX)
);

INSERT INTO Occupancies(EmployeeId, DateOccupied, AccountNumber, RoomNumber)
	VALUES
		(1, '2020-06-27', '1234', '1'),
		(2, '2020-06-27', '1234', '2'),
		(3, '2020-06-27', '1234', '3');

GO
--16.Create SoftUni Database
CREATE DATABASE SoftUnii;
USE SoftUnii;

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY, 
	[Name] NVARCHAR(50) UNIQUE NOT NULL,
);

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY, 
	AddressText NVARCHAR(100) UNIQUE NOT NULL, 
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL,
);

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY, 
	[Name] NVARCHAR(60) UNIQUE NOT NULL,
);

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY, 
	FirstName NVARCHAR(30) NOT NULL, 
	MiddleName NVARCHAR(30), 
	LastName NVARCHAR(30) NOT NULL, 
	JobTitle NVARCHAR(50) NOT NULL, 
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL, 
	HireDate DATE NOT NULL, 
	Salary DECIMAL(10,2) NOT NULL, 
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id),
);

GO
--17.Backup Database
BACKUP DATABASE SoftUnii
	TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\Backup\softunii-backup.bak';

USE master;
DROP DATABASE SoftUnii;

RESTORE DATABASE SoftUnii
	FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\Backup\softunii-backup.bak';

USE SoftUnii;

GO
--18.Basic Insert
INSERT INTO Towns([Name])
	VALUES
		('Sofia'),
		('Plovdiv'),
		('Varna'),
		('Burgas');

INSERT INTO Departments([Name])
	VALUES
		('Engineering'),
		('Sales'),
		('Marketing'),
		('Software Development'),
		('Quality Assurance');

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
	VALUES
		('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
		('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
		('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
		('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
		('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88);

GO
--19.Basic Select All Fields
SELECT *
	FROM Towns;

SELECT *
	FROM Departments;

SELECT *
	FROM Employees;

GO
--20.Basic Select All Fields and Order Them
SELECT *
	FROM Towns
		ORDER BY [Name] ASC;

SELECT *
	FROM Departments
		ORDER BY [Name] ASC;

SELECT *
	FROM Employees
		ORDER BY Salary DESC;

GO
--21.Basic Select Some Fields
SELECT [Name]
	FROM Towns
		ORDER BY [Name] ASC;

SELECT [Name]
	FROM Departments
		ORDER BY [Name] ASC;

SELECT FirstName, LastName, JobTitle, Salary
	FROM Employees
		ORDER BY Salary DESC;

GO
--22.Increase Employees Salary
UPDATE Employees
	SET Salary += Salary * 0.10;

SELECT Salary
	FROM Employees;

GO
--23.Decrease Tax Rate
USE Hotel;

UPDATE Payments
	SET TaxRate -= TaxRate * 0.03;

SELECT TaxRate
	FROM Payments;

GO
--24.Delete All Records
TRUNCATE TABLE Occupancies;


