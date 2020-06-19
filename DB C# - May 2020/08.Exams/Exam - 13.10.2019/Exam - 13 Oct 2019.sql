--(Demo) Databases MSSQL Server Exam - 13 Oct 2019

GO
--1.DDL
CREATE DATABASE Bitbucket;
USE Bitbucket;

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL,
);

CREATE TABLE Repositories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
);

CREATE TABLE RepositoriesContributors(
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	CONSTRAINT PK_RepositoriesContributors PRIMARY KEY(RepositoryId, ContributorId),
);

CREATE TABLE Issues(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus CHAR(6) NOT NULL,
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
);

CREATE TABLE Commits(
	Id INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues(Id),
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL, 
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
);

CREATE TABLE Files(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	Size DECIMAL(18, 2) NOT NULL,
	ParentId INT FOREIGN KEY REFERENCES Files(Id),
	CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL,
);

GO
--2.Insert
INSERT INTO Files([Name], Size, ParentId, CommitId)
	VALUES
		('Trade.idk', 2598.0, 1, 1),
		('menu.net', 9238.31, 2, 2),
		('Administrate.soshy', 1246.93, 3, 3),
		('Controller.php', 7353.15, 4, 4),
		('Find.java', 9957.86, 5, 5),
		('Controller.json', 14034.87, 3, 6),
		('Operate.xix', 7662.92, 7, 7);

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
	VALUES
		('Critical Problem with HomeController.cs file', 'open', 1, 4),
		('Typo fix in Judge.html', 'open', 4, 3),
		('Implement documentation for UsersService.cs', 'closed', 8, 2),
		('Unreachable code in Index.cs', 'open', 9, 8);

GO
--3.Update
UPDATE Issues
	SET IssueStatus = 'closed'
		WHERE AssigneeId = 6;

GO
--4.Delete
DELETE Issues
	WHERE RepositoryId IN (SELECT r.Id
								FROM Repositories AS r
									WHERE r.[Name] = 'Softuni-Teamwork');

DELETE RepositoriesContributors 
	WHERE RepositoryId IN (SELECT r.Id
								FROM Repositories AS r
									WHERE r.[Name] = 'Softuni-Teamwork');

GO
--5.Commits
SELECT c.Id, c.[Message], c.RepositoryId, c.ContributorId
	FROM Commits AS c
		ORDER BY c.Id ASC, 
		         c.[Message] ASC, 
				 c.RepositoryId ASC, 
				 c.ContributorId ASC;

GO
--6.Heavy HTML
SELECT f.Id, f.[Name], f.Size
	FROM Files AS f
		WHERE f.Size > 1000
		  AND f.[Name] LIKE '%html%'
			ORDER BY f.Size DESC,
			         f.Id ASC, 
					 f.[Name] ASC;

GO
--7.Issues and Users
SELECT i.Id,
       CONCAT(u.Username, ' : ', i.Title) AS [IssueAssignee]
	FROM Issues AS i
		JOIN Users AS u
		ON i.AssigneeId = u.Id
			ORDER BY i.Id DESC,
			         [IssueAssignee] ASC;

GO
--8.Non-Directory Files
SELECT f.Id,
       f.[Name],
	   CONCAT(f.Size, 'KB') AS [Size]
	FROM Files AS f
		LEFT JOIN Files AS p
		ON f.Id = p.ParentId
			WHERE p.Id IS NULL
				ORDER BY f.Id ASC,
                         f.[Name] ASC,
						 f.Size DESC;

GO
--9.Most Contributed Repositories
SELECT TOP(5) r.Id,
              r.[Name],
			  COUNT(c.Id) AS [Commits]
	FROM RepositoriesContributors AS rc
		JOIN Repositories AS r
		ON rc.RepositoryId = r.Id
		JOIN Commits AS c
		ON r.Id = c.RepositoryId
			GROUP BY r.Id,
                     r.[Name]
				ORDER BY [Commits] DESC,
				         r.Id ASC,
						 r.[Name] ASC;

GO
--10.User and Files
SELECT u.Username,
       AVG(f.Size) AS [Size]
	FROM Users AS u
		JOIN Commits AS c
		ON u.Id = c.ContributorId
		JOIN Files AS f
		ON c.Id = f.CommitId
			GROUP BY u.Username
				ORDER BY [Size] DESC,
				         u.Username ASC;

GO
--11.User Total Commits
CREATE FUNCTION udf_UserTotalCommits(@username VARCHAR(MAX))
	RETURNS INT
		AS
			BEGIN
				DECLARE @commitsCount INT = (SELECT COUNT(c.Id)
												FROM Users AS u
													JOIN Commits AS c
													ON u.Id = c.ContributorId
														WHERE u.Username = @username);

				RETURN @commitsCount;
			END

GO
SELECT dbo.udf_UserTotalCommits('UnderSinduxrein');

GO
--12.Find by Extensions
CREATE PROC usp_FindByExtension(@extension VARCHAR(MAX))
	AS
		SELECT f.Id,
		       f.[Name],
			   CONCAT(f.Size, 'KB') AS [Size]
			FROM Files AS f
				WHERE SUBSTRING(f.[Name], CHARINDEX('.', f.[Name], 1) + 1, LEN(f.[Name])) = @extension
					ORDER BY f.Id ASC,
					         f.[Name] ASC,
							 f.Size DESC;

	GO

GO
EXEC usp_FindByExtension 'txt';