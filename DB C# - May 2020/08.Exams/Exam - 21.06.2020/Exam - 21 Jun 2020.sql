--Databases MSSQL Server Exam - 21 Jun 2020

GO
--1
CREATE DATABASE TripService;
USE TripService;

CREATE TABLE Cities(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode NCHAR(2) NOT NULL,
);

CREATE TABLE Hotels(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	[CityId] INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(18, 2)
);

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(18, 2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT  FOREIGN KEY REFERENCES Hotels(Id) NOT NULL,
);

CREATE TABLE Trips(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,
	CONSTRAINT CH_BookDate CHECK(BookDate < ArrivalDate),
	CONSTRAINT CH_ArrivalDate CHECK(ArrivalDate < ReturnDate),
);

CREATE TABLE Accounts(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
	BirthDate DATE NOT NULL,
	Email NVARCHAR(100) NOT NULL UNIQUE,
);

CREATE TABLE AccountsTrips(
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
	TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
	Luggage INT CHECK(Luggage >= 0) NOT NULL,
    CONSTRAINT PK_AccountsTrips PRIMARY KEY(AccountId, TripId),
);

GO
--2
INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
	VALUES
		('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
		('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
		('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
		('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg');


INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
	VALUES
		(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
		(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
		(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
		(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
		(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL);

GO
--3
UPDATE Rooms
	SET Price += Price * 0.14
		WHERE HotelId IN (5, 7, 9);

GO
--4
DELETE AccountsTrips
	WHERE AccountId = 47;

GO
--5
SELECT a.FirstName, 
       a.LastName, 
	   FORMAT(a.BirthDate, 'MM-dd-yyyy') AS [BirthDate], 
	   c.[Name] AS [Hometown], 
	   a.Email
	FROM Accounts AS a
		JOIN Cities AS c
		ON a.CityId = c.Id
			WHERE a.Email LIKE 'e%'
				ORDER BY c.[Name] ASC;

GO
--6
SELECT c.[Name] AS [City],
       COUNT(h.Id) AS [Hotels]
	FROM Cities AS c
		JOIN Hotels AS h
		ON c.Id = h.CityId
			GROUP BY c.[Name]
				ORDER BY [Hotels] DESC,
				         [City] ASC;

GO
--7
SELECT a.Id AS [AccountId],
       CONCAT(a.FirstName, ' ', a.LastName) AS [FullName],
	   MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [LongestTrip],
	   MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [ShortestTrip]
	FROM Accounts AS a
		JOIN AccountsTrips AS acct
		ON a.Id = acct.AccountId
		JOIN Trips AS t
		ON acct.TripId = t.Id
			WHERE a.MiddleName IS NULL
			  AND t.CancelDate IS NULL
			  GROUP BY a.Id, 
			           a.FirstName,
					   a.LastName
				ORDER BY [LongestTrip] DESC,
				         [ShortestTrip] ASC;

GO
--8
SELECT TOP(10) c.Id,
               c.[Name] AS [City],
			   c.CountryCode AS [Country],
			   COUNT(a.Id) AS [Accounts]
	FROM Cities AS c
		JOIN Accounts AS a
		ON c.Id = a.CityId
			GROUP BY c.Id,
			         c.[Name],
					 c.CountryCode 
				ORDER BY [Accounts] DESC;	

GO
--9
SELECT a.Id,
       a.Email,
	   c.[Name] AS [City],
	   COUNT(t.Id) AS [Trips]
	FROM Accounts AS a
		JOIN AccountsTrips AS acct
		ON a.Id = acct.AccountId
		JOIN Trips AS t 
		ON acct.TripId = t.Id
		JOIN Rooms AS r
		ON t.RoomId = r.Id
		JOIN Hotels AS h
		ON r.HotelId = h.Id
		JOIN Cities AS c
		ON h.CityId = c.Id
			WHERE a.CityId = c.Id						
				GROUP BY a.Id,
                         a.Email,
	                     c.[Name]
					ORDER BY [Trips] DESC,
					         a.Id ASC;

GO
--10
SELECT t.Id,
       CONCAT(a.FirstName, ' ', (a.MiddleName +  ' '), a.LastName) AS [Full Name],
	   c.[Name] AS [From],
	   c2.[Name] [To],
	   CASE
			WHEN t.CancelDate IS NULL THEN CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
			ELSE 'Canceled'
	   END AS [Duration]
	FROM Trips AS t
		JOIN AccountsTrips AS acct
		ON t.Id = acct.TripId
		JOIN Accounts AS a
		ON acct.AccountId = a.Id
		JOIN Cities AS c
		ON a.CityId = c.Id
		JOIN Rooms AS r
		ON t.RoomId = r.Id
		JOIN Hotels AS h
		ON r.HotelId = h.Id
		JOIN Cities AS c2
		ON h.CityId = c2.Id
			ORDER BY [Full Name] ASC,
			         t.Id ASC;

GO
--11
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
	RETURNS NVARCHAR(MAX)
		AS
			BEGIN
				DECLARE @roomId INT = (SELECT TOP(1) r.Id
										FROM Hotels AS h
											JOIN Rooms AS r
											ON h.Id = r.HotelId
											JOIN Trips AS t
											ON r.Id = t.RoomId
												WHERE h.Id = @HotelId
												 AND (@Date < t.ArrivalDate OR @Date > t.ReturnDate
												 OR t.CancelDate IS NOT NULL)
												 AND r.Beds > @People
													ORDER BY r.Price * @People DESC);

			   IF(@roomId IS NULL)
					BEGIN
						RETURN 'No rooms available';
					END


		       DECLARE @roomType NVARCHAR(MAX) = (SELECT r.Type
													FROM Rooms AS r
														WHERE r.Id = @roomId)

		       DECLARE @roomBeds INT = (SELECT r.Beds
													FROM Rooms AS r
														WHERE r.Id = @roomId)

		       DECLARE @price DECIMAL(18, 2) = (SELECT r.Price
													FROM Rooms AS r
														WHERE r.Id = @roomId)

		       DECLARE @base DECIMAL(18, 2) = (SELECT h.BaseRate
												FROM Rooms AS r
												JOIN Hotels AS h
												ON r.HotelId = h.Id
													WHERE r.Id = @roomId)

          DECLARE @totalPrice DECIMAL(18, 2) = (@base + @price) * @People;

		  RETURN CONCAT('Room ',@roomId,': ', @roomType, ' (', @roomBeds, ' beds) - $', @totalPrice);

		  END

GO
SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2);
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3);

GO
--12
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
	AS

		DECLARE @oldHOtelId INT = (SELECT h.Id
										FROM Trips AS t
											JOIN Rooms AS r
											ON t.RoomId = r.Id
											JOIN Hotels AS h
											ON r.HotelId = h.Id
												WHERE t.Id = @TripId);

		DECLARE @newHotelId INT = (SELECT h.Id
										FROM Rooms AS r
											JOIN Hotels AS h
											ON r.HotelId = h.Id
												WHERE r.Id = @TargetRoomId);

		IF(@oldHOtelId != @newHotelId)
			BEGIN
				RAISERROR('Target room is in another hotel!', 16, 1);
				RETURN;
			END

		DECLARE @totalBeds INT = (SELECT COUNT(r.Beds)
									FROM Trips AS t
										JOIN Rooms AS r
										ON t.RoomId = r.Id
										JOIN AccountsTrips AS ac
										ON t.Id = ac.TripId
											WHERE t.Id = @TripId);

		DECLARE @newRoombeds INT = (SELECT r.Beds
										FROM Rooms AS r
											WHERE r.Id = @TargetRoomId);

		IF(@totalBeds > @newRoombeds)
			BEGIN
				RAISERROR('Not enough beds in target room!', 16, 1);
				RETURN;
			END

		UPDATE Trips
			SET RoomId = @TargetRoomId
				WHERE Id = @TripId;

GO
EXEC usp_SwitchRoom 10, 11;
SELECT RoomId FROM Trips WHERE Id = 10;
EXEC usp_SwitchRoom 10, 7;
EXEC usp_SwitchRoom 10, 8;
