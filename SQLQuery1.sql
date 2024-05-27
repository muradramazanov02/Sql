CREATE TABLE Categories (
    Id INT PRIMARY KEY,
    Name nvarchar(50) NOT NULL UNIQUE
)
CREATE TABLE Tags (
    Id INT PRIMARY KEY,
    Name nvarchar(50) NOT NULL UNIQUE
)
CREATE TABLE Users (
    Id INT PRIMARY KEY,
    UserName nvarchar(55) NOT NULL UNIQUE,
    FullName NVARCHAR(55) NOT NULL,
    Age INT CHECK (Age >= 0 AND Age <= 150)
)
CREATE TABLE Blogs (
    Id INT PRIMARY KEY,
    Title NVARCHAR(50) NOT NULL CHECK (LEN(Title) <= 50),
    Description NVARCHAR(MAX) NOT NULL,
    UserId INT,
    CategoryId INT,
    isDeleted BIT DEFAULT 0,
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
)
CREATE TABLE Comments (
    Id INT PRIMARY KEY,
    Content NVARCHAR(50) NOT NULL CHECK (LEN(Content) <= 250),
    UserId INT,
    BlogId INT,
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (BlogId) REFERENCES Blogs(Id)
)
CREATE VIEW Blog_User_View AS
SELECT B.Title AS BlogTitle, U.UserName, U.FullName
FROM Blogs B
INNER JOIN Users U ON B.UserId = U.Id;

CREATE VIEW Blog_Category_View AS
SELECT B.Title AS BlogTitle, C.Name AS CategoryName
FROM Blogs B
INNER JOIN Categories C ON B.CategoryId = C.Id;

CREATE PROCEDURE GetUserComments
    @userId INT
AS
BEGIN
    SELECT C.*
    FROM Comments C
    WHERE C.UserId = @userId;
END


CREATE PROCEDURE GetUserBlogs
    @userId INT
AS
BEGIN
    SELECT B.*
    FROM Blogs B
    WHERE B.UserId = @userId;
END;

CREATE FUNCTION GetBlogCountByCategory
    (@categoryId INT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*)
    FROM Blogs
    WHERE CategoryId = @categoryId;
    RETURN @count;
END;

CREATE FUNCTION GetUserBlogsTable
    (@userId INT)
RETURNS TABLE
AS
RETURN (
    SELECT *
    FROM Blogs
    WHERE UserId = @userId
);
CREATE TRIGGER DeleteBlogTrigger
ON Blogs
INSTEAD OF DELETE
AS
BEGIN
    UPDATE Blogs
    SET isDeleted = 1
    WHERE Id IN (SELECT Id FROM deleted);
END;