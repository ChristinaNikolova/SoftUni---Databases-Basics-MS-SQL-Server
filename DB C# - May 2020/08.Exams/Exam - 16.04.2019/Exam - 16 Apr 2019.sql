--Database Basics MS SQL Exam – 16 Apr 2019

GO
--1.DDL
CREATE DATABASE Airport;
USE Airport;

CREATE TABLE Planes(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	Seats INT CHECK(Seats >= 0) NOT NULL,
	[Range] INT CHECK([Range] >= 0) NOT NULL,
);

CREATE TABLE Flights(
	Id INT PRIMARY KEY IDENTITY,
	DepartureTime DATETIME2,
	ArrivalTime DATETIME2,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL,
);

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT CHECK(Age >= 0) NOT NULL,
	[Address] VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL,
);

CREATE TABLE LuggageTypes(
	Id INT PRIMARY KEY IDENTITY,
	[Type] VARCHAR(30) NOT NULL,
);

CREATE TABLE Luggages(
	Id INT PRIMARY KEY IDENTITY,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
);

CREATE TABLE Tickets(
	Id INT PRIMARY KEY IDENTITY,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
	LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
	Price DECIMAL(18, 2) NOT NULL,
);

GO
--2.Insert
INSERT INTO Planes([Name], Seats, [Range])
	VALUES
		('Airbus 336', 112, 5132),
		('Airbus 330', 432, 5325),
		('Boeing 369', 231, 2355),
		('Stelt 297', 254, 2143),
		('Boeing 338', 165, 5111),
		('Airbus 558', 387, 1342),
		('Boeing 128', 345, 5541);

INSERT INTO LuggageTypes([Type])
	VALUES
		('Crossbody Bag'),
		('School Backpack'),
		('Shoulder Bag');

GO
--3.Update
UPDATE Tickets
	SET Price += Price * 0.13
		WHERE FlightId IN (SELECT f.Id
								FROM Flights AS f
									WHERE f.Destination = 'Carlsbad');

GO
--4.Delete
DELETE Tickets
	WHERE FlightId IN (SELECT f.Id
							FROM Flights AS f
								WHERE f.Destination = 'Ayn Halagim');

DELETE Flights
	WHERE Destination = 'Ayn Halagim';

GO
--5.Trips
SELECT f.Origin, f.Destination
	FROM Flights AS f
		ORDER BY f.Origin ASC, 
		         f.Destination ASC;

GO
--6.The "Tr" Planes
SELECT pl.Id, pl.[Name], pl.Seats, pl.[Range]
	FROM Planes AS pl
		WHERE pl.[Name] LIKE '%tr%'
			ORDER BY pl.Id ASC, 
			         pl.[Name] ASC, 
					 pl.Seats ASC, 
					 pl.[Range] ASC;

GO
--7.Flight Profits
SELECT f.Id AS [FlightId],
       SUM(t.Price) AS [Price]
	FROM Flights AS f
		JOIN Tickets AS t
		ON f.Id = t.FlightId
			GROUP BY f.Id
				ORDER BY [Price] DESC,
				         [FlightId] ASC;

GO
--8.Passanger and Prices
SELECT TOP(10) p.FirstName, p.LastName, t.Price
	FROM Passengers AS p
		JOIN Tickets AS t
		ON p.Id = t.PassengerId
			ORDER BY t.Price DESC,
			         p.FirstName ASC,
					 p.LastName ASC;

GO
--9.Top Luggages
SELECT lt.[Type],
       COUNT(l.Id) AS [MostUsedLuggage]
	FROM LuggageTypes AS lt
		JOIN Luggages AS l
		ON lt.Id = l.LuggageTypeId
			GROUP BY lt.[Type]
				ORDER BY [MostUsedLuggage] DESC,
				         lt.[Type] ASC;

GO
--10.Passanger Trips
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name],
       f.Origin,
	   f.Destination
	FROM Passengers AS p
		JOIN Tickets AS t
		ON p.Id = t.PassengerId
		JOIN Flights AS f
		ON t.FlightId = f.Id
			ORDER BY [Full Name] ASC,
			         f.Origin ASC,
	                 f.Destination ASC;

GO
--11.Non Adventures People
SELECT p.FirstName AS [First Name],
       p.LastName AS [Last Name],
	   p.Age
	FROM Passengers AS p
		LEFT JOIN Tickets AS t
		ON p.Id = t.PassengerId
			WHERE t.Id IS NULL
				ORDER BY p.Age DESC,
				         [First Name] ASC,
						 [Last Name] ASC;

GO
--12.Lost Luggages
SELECT p.PassportId AS [Passport Id],
       p.[Address]
	FROM Passengers AS p
		LEFT JOIN Luggages AS l
		ON p.Id = l.PassengerId
			WHERE l.Id IS NULL
				ORDER BY [Passport Id] ASC,
				         p.[Address] ASC;

GO
--13.Count of Trips
SELECT p.FirstName AS [First Name],
       p.LastName AS [Last Name],
	   COUNT(t.Id) AS [Total Trips]
	FROM Passengers AS p
		LEFT JOIN Tickets AS t
		ON p.Id = t.PassengerId
			GROUP BY p.FirstName,
			         p.LastName,
					 p.Id
				ORDER BY [Total Trips] DESC,
				         [First Name] ASC,
						 [Last Name] ASC;

GO
--14.Full Info
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name],
       pl.[Name] AS [Plane Name],
	   CONCAT(f.Origin, ' - ', f.Destination) AS [Trip],
	   lt.[Type] AS [Luggage Type]
	FROM Passengers AS p
		JOIN Tickets AS t
		ON p.Id = t.PassengerId
		JOIN Flights AS f
		ON t.FlightId = f.Id
		JOIN Planes AS pl
		ON f.PlaneId = pl.Id
		JOIN Luggages AS l
		ON t.LuggageId = l.Id
		JOIN LuggageTypes AS lt
		ON l.LuggageTypeId = lt.Id
			ORDER BY [Full Name] ASC,
			         [Plane Name] ASC,
					 f.Origin ASC,
					 f.Destination ASC,
					 [Luggage Type] ASC;

GO
--15.Most Expesnive Trips
SELECT [temp].[First Name],
       [temp].[Last Name],
	   [temp].Destination,
	   [temp].Price
	FROM 
		(SELECT p.FirstName AS [First Name],
				p.LastName AS [Last Name],
				f.Destination,
				t.Price,
				RANK() OVER(PARTITION BY p.FirstName, p.LastName ORDER BY t.Price DESC) AS [Rank]
			FROM Passengers AS p
				JOIN Tickets AS t
				ON p.Id = t.PassengerId
				JOIN Flights AS f
				ON t.FlightId = f.Id) AS [temp]
		WHERE [temp].[Rank] = 1
			ORDER BY [temp].Price DESC,
					 [temp].[First Name] ASC,
					 [temp].[Last Name] ASC,
					 [temp].Destination ASC;

GO
--16.Destinations Info
SELECT f.Destination,
       COUNT(t.Id) AS [FilesCount]
	FROM Flights AS f
		LEFT JOIN Tickets AS t
		ON f.Id = t.FlightId
			GROUP BY f.Destination
				ORDER BY [FilesCount] DESC,
				         f.Destination ASC;

GO
--17.PSP
SELECT pl.[Name],
       pl.Seats,
	   COUNT(t.Id) AS [Passengers Count]
	FROM Planes AS pl
		LEFT JOIN Flights AS f
		ON pl.Id = f.PlaneId
		LEFT JOIN Tickets AS t
		ON f.Id = t.FlightId
			GROUP BY pl.[Name],
			         pl.Seats
				ORDER BY [Passengers Count] DESC,
				         pl.[Name] ASC,
                         pl.Seats ASC;

GO
--18.Vacation
CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(MAX), @destination VARCHAR(MAX), @peopleCount INT) 
	RETURNS VARCHAR(MAX)
		AS
			BEGIN
				IF(@peopleCount <= 0)
					BEGIN
						RETURN 'Invalid people count!';
					END

				DECLARE @flightId INT = (SELECT f.Id
											FROM Flights AS f
												WHERE f.Origin = @origin
												  AND f.Destination = @destination);

				IF(@flightId IS NULL)
					BEGIN
						RETURN 'Invalid flight!';
					END

				DECLARE @pricePerTicket DECIMAL(18, 2) = (SELECT t.Price
																FROM Flights AS f
																	JOIN Tickets AS t
																	ON f.Id = t.FlightId
																		WHERE f.Id = @flightId);

				DECLARE @totalSum DECIMAL(18, 2) = @pricePerTicket * @peopleCount;
				RETURN CONCAT('Total price ', @totalSum);
			END

GO
SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33);
SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', -1);
SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33);

GO
--19.Wrong Data
CREATE PROC usp_CancelFlights
	AS
		UPDATE Flights
			SET ArrivalTime = NULL,
			    DepartureTime = NULL
				WHERE DATEDIFF(SECOND, ArrivalTime, DepartureTime) < 0;
	GO

GO
EXEC usp_CancelFlights;
