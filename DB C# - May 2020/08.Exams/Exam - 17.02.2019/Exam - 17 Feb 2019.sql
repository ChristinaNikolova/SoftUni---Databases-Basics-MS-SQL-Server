--Database Basics MSSQL Exam – 17 Feb 2019S

GO
--1.DDL
CREATE DATABASE School;
USE School;

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(25),
	LastName NVARCHAR(30) NOT NULL,
	Age INT CHECK(Age >= 5 AND Age <= 100),
	[Address] NVARCHAR(50),
	Phone NCHAR(10),
);

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	Lessons INT CHECK(Lessons > 0) NOT NULL,
);

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY,
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
	Grade DECIMAL(3, 2) CHECK(Grade >= 2 AND Grade <= 6) NOT NULL,
);

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY,
	[Date] DATETIME2,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
);

CREATE TABLE StudentsExams(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
	Grade DECIMAL(3, 2) CHECK(Grade >= 2 AND Grade <= 6) NOT NULL,
	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentId, ExamId),
);

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	[Address] NVARCHAR(20) NOT NULL,
	Phone CHAR(10), 
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
);

CREATE TABLE StudentsTeachers(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,
	CONSTRAINT PK_StudentsTeachers PRIMARY KEY(StudentId, TeacherId),
);

GO
--2.Insert
INSERT INTO Teachers(FirstName, LastName, [Address], Phone, SubjectId)
	VALUES
		('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
		('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
		('Merrile', 'Lambdin', '81 Dahle Plaza', '4373065154', 5),
		('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4);

INSERT INTO Subjects([Name], Lessons)
	VALUES
		('Geometry', 12),
		('Health', 10),
		('Drama', 7),
		('Sports', 9);

GO
--3.Update
UPDATE StudentsSubjects
	SET Grade = 6.00
		WHERE SubjectId IN (1, 2)
		  AND Grade >= 5.50;

GO
--4.Delete
DELETE StudentsTeachers 
	WHERE TeacherId IN (SELECT t.Id
							FROM Teachers AS t
								WHERE t.Phone LIKE '%72%');

DELETE Teachers
	WHERE Phone LIKE '%72%';


GO
--5.Teen Students
SELECT s.FirstName, s.LastName, s.Age
	FROM Students AS s
		WHERE s.Age >= 12
			ORDER BY s.FirstName ASC,
			         s.LastName ASC;

GO
--6.Cool Addresses
SELECT CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS [Full Name],
       s.[Address]
	FROM Students AS s
		WHERE s.[Address] LIKE '%road%'
			ORDER BY s.FirstName ASC,
			         s.LastName ASC,
					 s.[Address] ASC;

GO
--7.42 Phones
SELECT s.FirstName,
       s.[Address],
	   s.Phone
	FROM Students AS s
		WHERE s.MiddleName IS NOT NULL
		  AND s.Phone LIKE '42%'
			ORDER BY s.FirstName ASC;

GO
--8.Students Teachers
SELECT s.FirstName, 
       s.LastName,
	   COUNT(st.TeacherId) AS [TeachersCount]
	FROM Students AS s
		JOIN StudentsTeachers AS st
		ON s.Id = st.StudentId
			GROUP BY s.FirstName,
			         s.LastName;

GO
--9.Subjects with Students
SELECT CONCAT(t.FirstName, ' ', t.LastName) AS [FullName],
       CONCAT(sub.[Name], '-', sub.Lessons) AS [Subjects],
	   COUNT(st.StudentId) AS [Students]
	FROM Teachers AS t
		JOIN Subjects AS sub
		ON t.SubjectId = sub.Id
		JOIN StudentsTeachers AS st
		ON t.Id = st.TeacherId
			GROUP BY t.FirstName, 
			         t.LastName,
					 sub.[Name], 
					 sub.Lessons
				ORDER BY [Students] DESC,
				         [FullName] ASC,
						 [Subjects] ASC;

GO
--10.Students to Go
SELECT CONCAT(s.FirstName, ' ', s.LastName) AS [Full Name]
	FROM Students AS s
		LEFT JOIN StudentsExams AS se
		ON s.Id = se.StudentId
			WHERE se.ExamId IS NULL
				ORDER BY [Full Name] ASC;

GO
--11.Busiest Teachers
SELECT TOP(10) t.FirstName,
               t.LastName,
			   COUNT(st.StudentId) AS [StudentsCount]
	FROM Teachers AS t
		JOIN StudentsTeachers AS st
		ON t.Id = st.TeacherId
			GROUP BY t.FirstName,
                     t.LastName
				ORDER BY [StudentsCount] DESC,
				         t.FirstName ASC,
                         t.LastName ASC;

GO
--12.Top Students
SELECT TOP(10) s.FirstName AS [First Name],
               s.LastName AS [Last Name],
			   FORMAT(AVG(se.Grade), 'F2') AS [Grade]
	FROM Students AS s
		JOIN StudentsExams AS se
		ON s.Id = se.StudentId
			GROUP BY s.FirstName,
			         s.LastName
				ORDER BY AVG(se.Grade) DESC,
				         [First Name] ASC,
						 [Last Name] ASC;

GO
--13.Second Highest Grade
SELECT [temp].FirstName, [temp].LastName, [temp].Grade
	FROM
		(SELECT s.FirstName,
                s.LastName,
	            ss.Grade,
	            ROW_NUMBER() OVER(PARTITION BY s.FirstName, s.LastName ORDER BY ss.Grade DESC) AS [Rank]
			FROM Students AS s
				JOIN StudentsSubjects AS ss
				ON s.Id = ss.StudentId) AS [temp]
		WHERE [temp].[Rank] = 2
			ORDER BY [temp].FirstName ASC, 
			         [temp].LastName ASC;

GO
--14.Not So In The Studying
SELECT CONCAT(s.FirstName, ' ', (s.MiddleName +  ' '), s.LastName) AS [Full Name]
	FROM Students AS s
		LEFT JOIN StudentsSubjects AS ss
		ON s.ID = ss.StudentId
			WHERE ss.Id IS NULL
				ORDER BY [Full Name] ASC;

GO
--15.Top Student per Teacher
SELECT [temp].[Teacher Full Name],
       [temp].[Subject Name],
	   [temp].[Student Full Name],
	   FORMAT([temp].Grade, 'F2') AS [Grade]
	FROM 
		(SELECT CONCAT(t.FirstName, ' ', t.LastName) AS [Teacher Full Name],
				sub.[Name] AS [Subject Name],
				CONCAT(s.FirstName, ' ', s.LastName) AS [Student Full Name],
				AVG(ss.Grade) AS [Grade],
				RANK() OVER (PARTITION BY t.FirstName, t.LastName ORDER BY AVG(ss.Grade) DESC) AS [Rank]
			FROM Teachers AS t
				JOIN StudentsTeachers AS st
				ON t.Id = st.TeacherId
				JOIN Students AS s
				ON st.StudentId = s.Id
				JOIN Subjects AS sub
				ON t.SubjectId = sub.Id
				JOIN StudentsSubjects AS ss
				ON s.Id = ss.StudentId AND ss.SubjectId = sub.Id
					GROUP BY t.FirstName,
					         t.LastName,
							 sub.[Name],
							 s.FirstName,
							 s.LastName) AS [temp]
		WHERE [temp].[Rank] = 1
			ORDER BY [temp].[Subject Name] ASC,
			         [temp].[Teacher Full Name] ASC,
					 [temp].Grade DESC;

GO
--16.Average Grade per Subject
SELECT sub.[Name],
       AVG(ss.Grade) AS [AverageGrade]
	FROM Subjects AS sub
		JOIN StudentsSubjects AS ss
		ON sub.Id = ss.SubjectId
			GROUP BY sub.[Name],
			         sub.Id
				ORDER BY sub.Id ASC;

GO
--17.Exams Information
SELECT CASE
			WHEN DATEPART(QUARTER, e.[Date]) = 1 THEN 'Q1'
			WHEN DATEPART(QUARTER, e.[Date]) = 2 THEN 'Q2'
			WHEN DATEPART(QUARTER, e.[Date]) = 3 THEN 'Q3'
			WHEN DATEPART(QUARTER, e.[Date]) = 4 THEN 'Q4'
			ELSE 'TBA'
	   END AS [Quarter],
	   sub.[Name] AS [SubjectName],
	   COUNT(se.StudentId) AS [StudentsCount]
	FROM Exams AS e
		JOIN Subjects AS sub
		ON e.SubjectId = sub.Id
		JOIN StudentsExams AS se
		ON e.Id = se.ExamId
			WHERE se.Grade >= 4
				GROUP BY CASE
							WHEN DATEPART(QUARTER, e.[Date]) = 1 THEN 'Q1'
							WHEN DATEPART(QUARTER, e.[Date]) = 2 THEN 'Q2'
							WHEN DATEPART(QUARTER, e.[Date]) = 3 THEN 'Q3'
							WHEN DATEPART(QUARTER, e.[Date]) = 4 THEN 'Q4'
							ELSE 'TBA'
						 END,
						 sub.[Name]
					ORDER BY [Quarter] ASC;

GO
--18.Exam Grades
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(3, 2))
	RETURNS NVARCHAR(MAX)
		AS
			BEGIN
				DECLARE @studentFirstName NVARCHAR(MAX) = (SELECT s.FirstName
																FROM Students AS s
																	WHERE s.Id = @studentId);

				IF(@studentFirstName IS NULL)
					BEGIN
						RETURN 'The student with provided id does not exist in the school!';
					END

				IF(@grade > 6.00)
					BEGIN
						RETURN 'Grade cannot be above 6.00!';
					END

				DECLARE @countGrades INT = (SELECT COUNT(se.Grade)
												FROM Students AS s
													JOIN StudentsExams AS se
													ON s.Id = se.StudentId
														WHERE s.Id = @studentId
														  AND (se.Grade >= @grade AND se.Grade <= (@grade + 0.50)));

				RETURN CONCAT('You have to update ', @countGrades, ' grades for the student ', @studentFirstName);
			END

GO
SELECT dbo.udf_ExamGradesToUpdate(12, 6.20);
SELECT dbo.udf_ExamGradesToUpdate(12, 5.50);
SELECT dbo.udf_ExamGradesToUpdate(121, 5.50);

GO
--19.Exclude From School
CREATE PROC usp_ExcludeFromSchool(@StudentId INT)
	AS
		IF((SELECT COUNT(*) FROM Students WHERE Id = @StudentId) = 0)
			BEGIN
				;RAISERROR('This school has no student with the provided id!', 16, 1);
				RETURN;
			END

		DELETE StudentsExams 
			WHERE StudentId = @StudentId;

		DELETE StudentsSubjects
			WHERE StudentId = @StudentId;

		DELETE StudentsTeachers
			WHERE StudentId = @StudentId;

		DELETE Students	
			WHERE Id = @StudentId;
	GO

GO
EXEC usp_ExcludeFromSchool 1;
SELECT COUNT(*) FROM Students;
EXEC usp_ExcludeFromSchool 301;
