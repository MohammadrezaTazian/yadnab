USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'YadnabDB')
BEGIN
    ALTER DATABASE YadnabDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE YadnabDB;
END
GO

CREATE DATABASE YadnabDB;
GO

USE YadnabDB;
GO

-- =============================================
-- 1. Tables Creation
-- =============================================

-- EducationalLevels Table (previously Grades)
CREATE TABLE EducationalLevels (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- Users Table
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PhoneNumber NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    EducationalLevelId INT, -- Foreign Key to EducationalLevels
    RefreshToken NVARCHAR(500),
    RefreshTokenExpiryTime DATETIME2,
    ProfilePicture NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Users_EducationalLevels FOREIGN KEY (EducationalLevelId) REFERENCES EducationalLevels(Id)
);
GO

-- Settings Table
CREATE TABLE Settings (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT,
    [Key] NVARCHAR(100) NOT NULL,
    Value NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- Packages Table (previously Products)
CREATE TABLE Packages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Category NVARCHAR(100), -- e.g. "Grade6", "MathPhysics"
    ImageUrl NVARCHAR(MAX),
    Price DECIMAL(18,2) NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- DifficultyLevels Table
CREATE TABLE DifficultyLevels (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,    -- e.g. "ساده"
    NameEn NVARCHAR(50) NOT NULL,  -- e.g. "Easy"
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- EntityTypes Table (Lookup for ContentImages)
CREATE TABLE EntityTypes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE -- 'Question', 'DetailedAnswer', 'EducationContent'
);
GO

-- Seed EntityTypes (Lookup)
SET IDENTITY_INSERT EntityTypes ON;
INSERT INTO EntityTypes (Id, TypeName) VALUES 
(1, 'Question'),
(2, 'DetailedAnswer'),
(3, 'EducationContent');
SET IDENTITY_INSERT EntityTypes OFF;
GO

-- Topics Table (Independent Hierarchical Tree)
CREATE TABLE Topics (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ParentId INT, -- Self-Referencing for hierarchy
    Title NVARCHAR(200) NOT NULL,
    ImageUrl NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Topics_Parent FOREIGN KEY (ParentId) REFERENCES Topics(Id)
);
GO

-- PackageTopics Table (Many-to-Many mapping between Packages and Topics)
CREATE TABLE PackageTopics (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PackageId INT NOT NULL,
    TopicId INT NOT NULL,
    CONSTRAINT FK_PackageTopics_Packages FOREIGN KEY (PackageId) REFERENCES Packages(Id) ON DELETE CASCADE,
    CONSTRAINT FK_PackageTopics_Topics FOREIGN KEY (TopicId) REFERENCES Topics(Id) ON DELETE CASCADE
);
GO

-- Questions Table
CREATE TABLE Questions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TopicId INT NOT NULL,
    QuestionText NVARCHAR(MAX) NOT NULL,
    Option1 NVARCHAR(MAX) NOT NULL,
    Option2 NVARCHAR(MAX) NOT NULL,
    Option3 NVARCHAR(MAX) NOT NULL,
    Option4 NVARCHAR(MAX) NOT NULL,
    CorrectOption INT NOT NULL,
    QuestionDesigner NVARCHAR(100),
    QuestionYear INT,
    DifficultyLevelId INT NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Questions_Topics FOREIGN KEY (TopicId) REFERENCES Topics(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Questions_DifficultyLevels FOREIGN KEY (DifficultyLevelId) REFERENCES DifficultyLevels(Id)
);
GO

-- DetailedAnswers Table
CREATE TABLE DetailedAnswers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    QuestionId INT NOT NULL UNIQUE, -- One-to-One with Questions
    AnswerText NVARCHAR(MAX),
    AnswerAuthor NVARCHAR(100),
    AnswerYear INT,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_DetailedAnswers_Questions FOREIGN KEY (QuestionId) REFERENCES Questions(Id) ON DELETE CASCADE
);
GO

-- EducationContents Table
CREATE TABLE EducationContents (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TopicId INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    ContentText NVARCHAR(MAX),
    MediaUrl NVARCHAR(MAX),
    MediaType NVARCHAR(50), -- 'Text', 'Image', 'Video'
    TeacherName NVARCHAR(100),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_EducationContents_Topics FOREIGN KEY (TopicId) REFERENCES Topics(Id) ON DELETE CASCADE
);
GO

-- ContentImages Table (Polymorphic Images for Questions, DetailedAnswers, EducationContents)
CREATE TABLE ContentImages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ImageUrl NVARCHAR(500) NOT NULL,
    DisplayOrder INT DEFAULT 0,
    AltText NVARCHAR(200),
    EntityTypeId INT NOT NULL,
    EntityId INT NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_ContentImages_EntityTypes FOREIGN KEY (EntityTypeId) REFERENCES EntityTypes(Id)
);
CREATE INDEX IX_ContentImages_Entity ON ContentImages(EntityTypeId, EntityId);
GO

-- =============================================
-- 2. Stored Procedures
-- =============================================

-- ---------------------------------------------
-- Auth Procedures
-- ---------------------------------------------

CREATE PROCEDURE sp_GetUserByPhoneNumber
    @PhoneNumber NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Users WHERE PhoneNumber = @PhoneNumber;
END
GO

CREATE PROCEDURE sp_CreateUser
    @PhoneNumber NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Users (PhoneNumber, CreatedAt)
    VALUES (@PhoneNumber, GETDATE());
    
    SELECT * FROM Users WHERE Id = SCOPE_IDENTITY();
END
GO

CREATE PROCEDURE sp_UpdateUser
    @Id INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @EducationalLevelId INT,
    @RefreshToken NVARCHAR(500),
    @RefreshTokenExpiryTime DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users
    SET FirstName = @FirstName,
        LastName = @LastName,
        EducationalLevelId = @EducationalLevelId,
        RefreshToken = @RefreshToken,
        RefreshTokenExpiryTime = @RefreshTokenExpiryTime
    WHERE Id = @Id;
END
GO

CREATE PROCEDURE sp_GetUserByRefreshToken
    @RefreshToken NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Users WHERE RefreshToken = @RefreshToken;
END
GO

CREATE PROCEDURE sp_UpdateProfilePicture
    @UserId INT,
    @ProfilePicture NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users
    SET ProfilePicture = @ProfilePicture
    WHERE Id = @UserId;

    SELECT * FROM Users WHERE Id = @UserId;
END
GO

-- ---------------------------------------------
-- Package Procedures (previously Product)
-- ---------------------------------------------

CREATE PROCEDURE sp_GetAllPackages
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Packages;
END
GO

CREATE PROCEDURE sp_GetPackagesByCategory
    @Category NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Packages WHERE Category = @Category;
END
GO

-- ---------------------------------------------
-- Settings Procedures
-- ---------------------------------------------

CREATE PROCEDURE sp_GetSettingByKey
    @UserId INT,
    @Key NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Settings WHERE UserId = @UserId AND [Key] = @Key;
END
GO

CREATE PROCEDURE sp_UpdateSetting
    @UserId INT,
    @Key NVARCHAR(100),
    @Value NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Settings WHERE UserId = @UserId AND [Key] = @Key)
    BEGIN
        UPDATE Settings SET Value = @Value WHERE UserId = @UserId AND [Key] = @Key;
    END
    ELSE
    BEGIN
        INSERT INTO Settings (UserId, [Key], Value) VALUES (@UserId, @Key, @Value);
    END
END
GO

-- ---------------------------------------------
-- Course Topic & Question Procedures
-- ---------------------------------------------

-- SP: Get Topics By PackageId (Using Recursive CTE for full topic hierarchy)
CREATE PROCEDURE sp_GetTopicsByPackage
    @PackageId INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH TopicHierarchy AS (
        -- Anchor member: topics directly mapped to the package
        SELECT 
            t.Id,
            t.ParentId,
            t.Title,
            t.ImageUrl
        FROM Topics t
        INNER JOIN PackageTopics pt ON t.Id = pt.TopicId
        WHERE pt.PackageId = @PackageId

        UNION ALL

        -- Recursive member: child topics of topics in TopicHierarchy
        SELECT 
            child.Id,
            child.ParentId,
            child.Title,
            child.ImageUrl
        FROM Topics child
        INNER JOIN TopicHierarchy parent ON child.ParentId = parent.Id
    )
    SELECT DISTINCT Id, ParentId, Title, ImageUrl
    FROM TopicHierarchy;
END
GO

-- SP: Get Questions By TopicId
CREATE PROCEDURE sp_GetQuestionsByTopicId
    @TopicId INT,
    @CurrentUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Get Questions and Answers
    SELECT 
        q.Id,
        q.TopicId,
        q.QuestionText,
        q.Option1,
        q.Option2,
        q.Option3,
        q.Option4,
        q.CorrectOption,
        q.QuestionDesigner,
        q.QuestionYear,
        q.DifficultyLevelId,
        dl.Name AS DifficultyLevelName,
        dl.NameEn AS DifficultyLevelNameEn,
        CAST(CASE WHEN ulq.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsLiked,
        da.Id AS DetailedAnswerId,
        da.QuestionId AS DetailedAnswerQuestionId,
        da.AnswerText,
        da.AnswerAuthor,
        da.AnswerYear,
        CAST(CASE WHEN ulda.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS DetailedAnswerIsLiked
    INTO #TempQuestions
    FROM Questions q
    LEFT JOIN DifficultyLevels dl ON q.DifficultyLevelId = dl.Id
    LEFT JOIN DetailedAnswers da ON q.Id = da.QuestionId
    LEFT JOIN UserLikes ulq ON q.Id = ulq.TargetId AND ulq.TargetType = 1 AND ulq.UserId = @CurrentUserId
    LEFT JOIN UserLikes ulda ON da.Id = ulda.TargetId AND ulda.TargetType = 2 AND ulda.UserId = @CurrentUserId
    WHERE q.TopicId = @TopicId;

    -- Return the questions
    SELECT * FROM #TempQuestions;

    -- 2. Get Content Images (for Questions and DetailedAnswers)
    SELECT ci.* 
    FROM ContentImages ci
    JOIN #TempQuestions tq ON (ci.EntityTypeId = 1 AND ci.EntityId = tq.Id) OR (ci.EntityTypeId = 2 AND ci.EntityId = tq.DetailedAnswerId)
    ORDER BY ci.EntityTypeId, ci.EntityId, ci.DisplayOrder;

    DROP TABLE #TempQuestions;
END
GO

-- SP: Get Question By Id
CREATE PROCEDURE sp_GetQuestionById
    @QuestionId INT,
    @CurrentUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Get Question
    SELECT 
        q.Id,
        q.TopicId,
        q.QuestionText,
        q.Option1,
        q.Option2,
        q.Option3,
        q.Option4,
        q.CorrectOption,
        q.QuestionDesigner,
        q.QuestionYear,
        q.DifficultyLevelId,
        dl.Name AS DifficultyLevelName,
        dl.NameEn AS DifficultyLevelNameEn,
        CAST(CASE WHEN ulq.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsLiked,
        da.Id AS DetailedAnswerId,
        da.QuestionId AS DetailedAnswerQuestionId,
        da.AnswerText,
        da.AnswerAuthor,
        da.AnswerYear,
        CAST(CASE WHEN ulda.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS DetailedAnswerIsLiked
    INTO #TempQuestionById
    FROM Questions q
    LEFT JOIN DifficultyLevels dl ON q.DifficultyLevelId = dl.Id
    LEFT JOIN DetailedAnswers da ON q.Id = da.QuestionId
    LEFT JOIN UserLikes ulq ON q.Id = ulq.TargetId AND ulq.TargetType = 1 AND ulq.UserId = @CurrentUserId
    LEFT JOIN UserLikes ulda ON da.Id = ulda.TargetId AND ulda.TargetType = 2 AND ulda.UserId = @CurrentUserId
    WHERE q.Id = @QuestionId;

    SELECT * FROM #TempQuestionById;

    -- 2. Get Images
    SELECT ci.* 
    FROM ContentImages ci
    JOIN #TempQuestionById tq ON (ci.EntityTypeId = 1 AND ci.EntityId = tq.Id) OR (ci.EntityTypeId = 2 AND ci.EntityId = tq.DetailedAnswerId)
    ORDER BY ci.EntityTypeId, ci.EntityId, ci.DisplayOrder;

    DROP TABLE #TempQuestionById;
END
GO

-- SP: Get EducationContents By TopicId
CREATE PROCEDURE sp_GetEducationContentsByTopicId
    @TopicId INT,
    @CurrentUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Get Education Contents
    SELECT 
        ec.*,
        CAST(CASE WHEN ul.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsLiked
    INTO #TempContents
    FROM EducationContents ec
    LEFT JOIN UserLikes ul ON ec.Id = ul.TargetId AND ul.TargetType = 3 AND ul.UserId = @CurrentUserId
    WHERE ec.TopicId = @TopicId;

    SELECT * FROM #TempContents;

    -- 2. Get Images (EntityTypeId = 3)
    SELECT ci.*
    FROM ContentImages ci
    JOIN #TempContents tc ON ci.EntityId = tc.Id
    WHERE ci.EntityTypeId = 3
    ORDER BY ci.EntityId, ci.DisplayOrder;

    DROP TABLE #TempContents;
END
GO

-- SP: Get EducationContent By Id
CREATE PROCEDURE sp_GetEducationContentById
    @Id INT,
    @CurrentUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Get Education Content
    SELECT 
        ec.*,
        CAST(CASE WHEN ul.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsLiked
    INTO #TempContent
    FROM EducationContents ec
    LEFT JOIN UserLikes ul ON ec.Id = ul.TargetId AND ul.TargetType = 3 AND ul.UserId = @CurrentUserId
    WHERE ec.Id = @Id;

    SELECT * FROM #TempContent;

    -- 2. Get Images (EntityTypeId = 3)
    SELECT ci.*
    FROM ContentImages ci
    JOIN #TempContent tc ON ci.EntityId = tc.Id
    WHERE ci.EntityTypeId = 3
    ORDER BY ci.DisplayOrder;

    DROP TABLE #TempContent;
END
GO

-- SP: Get ContentImages By Entity
CREATE PROCEDURE sp_GetContentImages
    @EntityTypeId INT,
    @EntityId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ci.Id,
        ci.ImageUrl,
        ci.DisplayOrder,
        ci.AltText,
        ci.EntityTypeId,
        ci.EntityId
    FROM ContentImages ci
    WHERE ci.EntityTypeId = @EntityTypeId AND ci.EntityId = @EntityId
    ORDER BY ci.DisplayOrder;
END
GO

-- SP: Search Entities (Questions, Answers, EducationContents)
CREATE PROCEDURE sp_SearchEntities
    @EntityTypeId INT,
    @SearchText NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1 = Question
    IF @EntityTypeId = 1
    BEGIN
        SELECT TOP 50
            Id,
            LEFT(QuestionText, 100) AS Title,
            (SELECT TOP 1 ImageUrl FROM ContentImages WHERE EntityTypeId = 1 AND EntityId = Questions.Id) AS ExistingImageUrl
        FROM Questions
        WHERE (@SearchText IS NULL OR QuestionText LIKE N'%' + @SearchText + N'%')
        ORDER BY Id DESC;
    END

    -- 2 = DetailedAnswer
    ELSE IF @EntityTypeId = 2
    BEGIN
        SELECT TOP 50
            da.Id,
            N'پاسخ سوال: ' + LEFT(q.QuestionText, 50) + '...' AS Title,
            (SELECT TOP 1 ImageUrl FROM ContentImages WHERE EntityTypeId = 2 AND EntityId = da.Id) AS ExistingImageUrl
        FROM DetailedAnswers da
        JOIN Questions q ON da.QuestionId = q.Id
        WHERE (@SearchText IS NULL OR q.QuestionText LIKE N'%' + @SearchText + N'%')
        ORDER BY da.Id DESC;
    END

    -- 3 = EducationContent
    ELSE IF @EntityTypeId = 3
    BEGIN
        SELECT TOP 50
            Id,
            Title,
            (SELECT TOP 1 ImageUrl FROM ContentImages WHERE EntityTypeId = 3 AND EntityId = EducationContents.Id) AS ExistingImageUrl
        FROM EducationContents
        WHERE (@SearchText IS NULL OR Title LIKE N'%' + @SearchText + N'%')
        ORDER BY Id DESC;
    END
END
GO

-- SP: Add Content Image
CREATE PROCEDURE sp_AddContentImage
    @EntityTypeId INT,
    @EntityId INT,
    @ImageUrl NVARCHAR(500),
    @AltText NVARCHAR(200) = NULL,
    @DisplayOrder INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO ContentImages (EntityTypeId, EntityId, ImageUrl, AltText, DisplayOrder)
    VALUES (@EntityTypeId, @EntityId, @ImageUrl, @AltText, @DisplayOrder);
    
    SELECT * FROM ContentImages WHERE Id = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Feature: Likes & Comments System
-- =============================================

-- UserLikes Table
CREATE TABLE UserLikes (
    Id BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    TargetId INT NOT NULL,
    TargetType TINYINT NOT NULL, -- 1=Question, 2=Answer, 3=EducationContent, 4=Comment
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_UserLikes_Users FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);
GO

CREATE UNIQUE INDEX IX_UserLikes_Unique ON UserLikes(UserId, TargetId, TargetType);
CREATE INDEX IX_UserLikes_Target ON UserLikes(TargetId, TargetType);
GO

-- Comments Table
CREATE TABLE Comments (
    Id BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    TargetId INT NOT NULL,
    TargetType TINYINT NOT NULL, -- 1=Question, 2=Answer, 3=EducationContent
    ParentCommentId BIGINT,
    Content NVARCHAR(1000) NOT NULL,
    LikeCount INT DEFAULT 0,
    IsDeleted BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Comments_Users FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Comments_Parent FOREIGN KEY (ParentCommentId) REFERENCES Comments(Id)
);
GO

CREATE INDEX IX_Comments_Target ON Comments(TargetId, TargetType);
GO

-- ---------------------------------------------
-- Likes & Comments Stored Procedures
-- ---------------------------------------------

CREATE PROCEDURE sp_ToggleLike
    @UserId INT,
    @TargetId INT,
    @TargetType TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM UserLikes WHERE UserId = @UserId AND TargetId = @TargetId AND TargetType = @TargetType)
    BEGIN
        -- Unlike
        DELETE FROM UserLikes WHERE UserId = @UserId AND TargetId = @TargetId AND TargetType = @TargetType;
        SELECT CAST(0 AS BIT) AS IsLiked;
    END
    ELSE
    BEGIN
        -- Like
        INSERT INTO UserLikes (UserId, TargetId, TargetType, CreatedAt) VALUES (@UserId, @TargetId, @TargetType, GETDATE());
        SELECT CAST(1 AS BIT) AS IsLiked;
    END
END
GO

CREATE PROCEDURE sp_AddComment
    @UserId INT,
    @TargetId INT,
    @TargetType TINYINT,
    @ParentCommentId BIGINT = NULL,
    @Content NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Comments (UserId, TargetId, TargetType, ParentCommentId, Content, CreatedAt)
    VALUES (@UserId, @TargetId, @TargetType, @ParentCommentId, @Content, GETDATE());
    
    SELECT * FROM Comments WHERE Id = SCOPE_IDENTITY();
END
GO

CREATE PROCEDURE sp_GetCommentsByTargetId
    @TargetId INT,
    @TargetType TINYINT,
    @CurrentUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.Id,
        c.UserId,
        c.TargetId,
        c.TargetType,
        c.ParentCommentId,
        c.Content,
        c.CreatedAt,
        c.IsDeleted,
        u.FirstName + ' ' + u.LastName AS UserDisplayName,
        u.ProfilePicture AS UserAvatar,
        CAST(CASE WHEN ul.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsLikedByCurrentUser,
        (SELECT COUNT(*) FROM UserLikes WHERE TargetId = c.Id AND TargetType = 4) AS LikeCount
    FROM Comments c
    JOIN Users u ON c.UserId = u.Id
    LEFT JOIN UserLikes ul ON c.Id = ul.TargetId AND ul.TargetType = 4 AND ul.UserId = @CurrentUserId
    WHERE c.TargetId = @TargetId AND c.TargetType = @TargetType AND c.IsDeleted = 0
    ORDER BY c.CreatedAt ASC;
END
GO

CREATE PROCEDURE sp_DeleteComment
    @Id BIGINT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Comments SET IsDeleted = 1 WHERE Id = @Id AND UserId = @UserId;
END
GO

-- =============================================
-- 3. Seed Data
-- =============================================

-- Seed Difficulty Levels
INSERT INTO DifficultyLevels (Name, NameEn) VALUES 
(N'ساده', 'Easy'),
(N'متوسط', 'Medium'),
(N'سخت', 'Hard');
GO

-- Seed Educational Levels (previously Grades)
INSERT INTO EducationalLevels (Name, Description) VALUES 
(N'پایه ششم', N'تیزهوشان پایه ششم به هفتم'),
(N'پایه نهم', N'تیزهوشان پایه نهم به دهم'),
(N'کنکور تجربی', N'آزمون سراسری علوم تجربی');
GO

-- Seed Packages (previously Products)
INSERT INTO Packages (Title, Description, Price, Category) VALUES 
(N'پکیج جامع هوش ششم', N'شامل تمامی مباحث هوش کلامی، ریاضی و تصویری', 500000, 'Grade6'),
(N'پکیج ریاضی و فیزیک', N'ریاضی و فیزیک دبیرستان', 300000, 'MathPhysics'),
(N'پکیج جامع کنکور تجربی', N'شامل زیست، شیمی، فیزیک و ریاضی با پاسخ تشریحی', 1200000, 'KonkurTajrobi');
GO

-- Seed Topics (Independent Hierarchical Tree)
INSERT INTO Topics (Title, ImageUrl) VALUES 
(N'هوش کلامی', 'assets/images/topics/verbal.png'),
(N'هوش ریاضی', 'assets/images/topics/math.png'),
(N'هوش تصویری', 'assets/images/topics/visual.png'),
(N'فیزیک', 'assets/images/topics/physics.png'),
(N'زیست شناسی', 'assets/images/topics/biology.png'),
(N'شیمی', 'assets/images/topics/chemistry.png'),
(N'ریاضیات', 'assets/images/topics/math_tajrobi.png');

-- Seed Nested Topics for Biology
DECLARE @BioId INT = (SELECT Id FROM Topics WHERE Title = N'زیست شناسی' AND ParentId IS NULL);

INSERT INTO Topics (ParentId, Title, ImageUrl) VALUES 
(@BioId, N'سلول', 'assets/images/topics/cell.png'),
(@BioId, N'ژنتیک', 'assets/images/topics/genetics.png');

DECLARE @CellId INT = (SELECT Id FROM Topics WHERE Title = N'سلول' AND ParentId = @BioId);

INSERT INTO Topics (ParentId, Title, ImageUrl) VALUES
(@CellId, N'اندامک‌ها', 'assets/images/topics/organelles.png'),
(@CellId, N'غشا', 'assets/images/topics/membrane.png');

-- Seed PackageTopics (Mapping Packages to Topics)
DECLARE @PkgGrade6 INT = (SELECT Id FROM Packages WHERE Category = 'Grade6');
DECLARE @PkgMath INT = (SELECT Id FROM Packages WHERE Category = 'MathPhysics');
DECLARE @PkgKonkur INT = (SELECT Id FROM Packages WHERE Category = 'KonkurTajrobi');

INSERT INTO PackageTopics (PackageId, TopicId) VALUES
(@PkgGrade6, (SELECT Id FROM Topics WHERE Title = N'هوش کلامی')),
(@PkgGrade6, (SELECT Id FROM Topics WHERE Title = N'هوش ریاضی')),
(@PkgGrade6, (SELECT Id FROM Topics WHERE Title = N'هوش تصویری')),
(@PkgMath, (SELECT Id FROM Topics WHERE Title = N'فیزیک')),
(@PkgMath, (SELECT Id FROM Topics WHERE Title = N'ریاضیات')),
(@PkgKonkur, (SELECT Id FROM Topics WHERE Title = N'زیست شناسی')),
(@PkgKonkur, (SELECT Id FROM Topics WHERE Title = N'شیمی')),
(@PkgKonkur, (SELECT Id FROM Topics WHERE Title = N'فیزیک')),
(@PkgKonkur, (SELECT Id FROM Topics WHERE Title = N'ریاضیات'));
GO

-- Seed Questions
DECLARE @VerbalId INT = (SELECT Id FROM Topics WHERE Title = N'هوش کلامی');
DECLARE @DiffEasy INT = (SELECT Id FROM DifficultyLevels WHERE NameEn = 'Easy');
DECLARE @DiffMed INT = (SELECT Id FROM DifficultyLevels WHERE NameEn = 'Medium');

-- Question 1
INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @VerbalId, 
    N'رابطه "درخت" به "جنگل" مانند رابطه "قطره" است به ...؟', 
    N'دریا', N'باران', N'آب', N'رودخانه', 
    1, 
    1402, 
    @DiffEasy
);

-- Question 2
INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @VerbalId, 
    N'متضاد کلمه "آغاز" کدام است؟', 
    N'شروع', N'پایان', N'ابتدا', N'وسط', 
    2, 
    1403, 
    @DiffEasy
);

-- Question 3 (Biology - Konkur)
DECLARE @BiologyId INT = (SELECT Id FROM Topics WHERE Title = N'اندامک‌ها');

INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @BiologyId, 
    N'کدام اندامک مسئول تولید انرژی در سلول است؟', 
    N'هسته', N'میتوکندری', N'ریبوزوم', N'لیزوزوم', 
    2, 
    1402, 
    @DiffEasy
);
GO

-- Seed Detailed Answers
DECLARE @Q1Id INT = (SELECT Id FROM Questions WHERE QuestionText LIKE N'رابطه "درخت"%');

INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @Q1Id,
    N'همانطور که درخت جزئی از جنگل است، قطره نیز جزئی از دریا است. رابطه، رابطه "جزء به کل" است.',
    N'استاد علوی',
    1402
);

-- Answer for Bio Q
DECLARE @BioQId INT = (SELECT Id FROM Questions WHERE QuestionText LIKE N'کدام اندامک مسئول%');

INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @BioQId,
    N'میتوکندری به عنوان نیروگاه سلول شناخته می‌شود و وظیفه اصلی آن تولید انرژی به صورت ATP از طریق تنفس سلولی است.',
    N'دکتر زیستی',
    1402
);
GO

-- Seed Education Contents
DECLARE @VerbalId_Edu INT = (SELECT Id FROM Topics WHERE Title = N'هوش کلامی');
DECLARE @BiologyId INT = (SELECT Id FROM Topics WHERE Title = N'زیست شناسی');

INSERT INTO EducationContents (TopicId, Title, ContentText, MediaUrl, MediaType, TeacherName)
VALUES 
(
    @VerbalId_Edu,
    N'آموزش تناسب واژگان',
    N'در این درس به بررسی تناسب بین واژگان می‌پردازیم. واژگان متناسب واژگانی هستند که...',
    'https://example.com/verbal-lesson-1.mp4',
    'Video',
    N'استاد حسینی'
),
(
    @VerbalId_Edu,
    N'نکات کلیدی هوش کلامی',
    N'۱. به مترادف‌ها دقت کنید. ۲. متضادها را بشناسید...',
    NULL,
    'Text',
    N'خانم رضایی'
),
(
    @BiologyId,
    N'آشنایی با ساختار سلول',
    N'سلول واحد سازنده بدن موجودات زنده است. اجزای اصلی سلول شامل غشا، سیتوپلاسم و هسته می‌باشند...',
    NULL,
    'Text',
    N'دکتر زیستی'
);
GO

-- Seed Users (Test User with ID 3)
DECLARE @Grade6LevelId INT = (SELECT Id FROM EducationalLevels WHERE Name = N'پایه ششم');

SET IDENTITY_INSERT Users ON;
IF NOT EXISTS (SELECT 1 FROM Users WHERE Id = 3)
BEGIN
    INSERT INTO Users (Id, PhoneNumber, FirstName, LastName, EducationalLevelId, CreatedAt) 
    VALUES (3, '09351881491', N'کاربر', N'تستی', @Grade6LevelId, GETDATE());
END
SET IDENTITY_INSERT Users OFF;

INSERT INTO Users (PhoneNumber, FirstName, LastName, EducationalLevelId) 
VALUES ('09123456789', N'کاربر', N'تستی دیگر', @Grade6LevelId);

DECLARE @TestUserId INT = SCOPE_IDENTITY();

-- Seed Comments (for Question 1)
DECLARE @Q1_Id INT = (SELECT TOP 1 Id FROM Questions);

INSERT INTO Comments (UserId, TargetId, TargetType, Content)
VALUES (@TestUserId, @Q1_Id, 1, N'این سوال خیلی نکته‌دار بود، ممنون!');

DECLARE @ParentCommId BIGINT = SCOPE_IDENTITY();

INSERT INTO Comments (UserId, TargetId, TargetType, ParentCommentId, Content)
VALUES (@TestUserId, @Q1_Id, 1, @ParentCommId, N'خواهش می‌کنم، دقت کنید که...');
GO

-- Seed Questions with Images
DECLARE @BioTopicId INT = (SELECT Id FROM Topics WHERE Title = N'زیست شناسی' AND ParentId IS NOT NULL);
IF @BioTopicId IS NULL
BEGIN
    INSERT INTO Topics (Title) VALUES (N'زیست‌شناسی سلولی');
    SET @BioTopicId = SCOPE_IDENTITY();
END

INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @BioTopicId,
    N'کدام اندامک مسئول تولید انرژی (ATP) در سلول است؟',
    N'هسته',
    N'میتوکندری',
    N'دستگاه گلژی',
    N'شبکه آندوپلاسمی',
    2,
    1402,
    1
);

DECLARE @BioQId2 INT = SCOPE_IDENTITY();

INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @BioQId2,
    N'میتوکندری اندامکی است که وظیفه تنفس سلولی و تولید انرژی را بر عهده دارد.',
    N'دکتر زیست',
    1402
);

DECLARE @BioDAId INT = SCOPE_IDENTITY();

-- Question with 2 Images (Math)
DECLARE @MathTopicId2 INT = (SELECT Id FROM Topics WHERE Title = N'هوش ریاضی');

INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @MathTopicId2,
    N'با توجه به دو شکل زیر، مقدار مجهول x کدام است؟',
    N'۱۰',
    N'۱۲',
    N'۱۵',
    N'۱۸',
    3,
    1403,
    2
);

DECLARE @MathQId INT = SCOPE_IDENTITY();

INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @MathQId,
    N'با مقایسه دو شکل متوجه می‌شویم که رابطه بین اعداد به صورت جمع دو عدد بالایی ضرب در ۲ است.',
    N'استاد هوش',
    1403
);

-- Seed Content Images for Questions & Answers
INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES 
('/images/questions/mitochondria.svg', 0, N'میتوکندری', 1, @BioQId2),
('/images/questions/math_p1.svg', 0, N'شکل ۱', 1, @MathQId),
('/images/questions/math_p2.svg', 1, N'شکل ۲', 1, @MathQId),
('/images/questions/mitochondria_diagram.svg', 0, N'دیاگرام', 2, @BioDAId);
GO

-- Seed Education Contents for Organelles
DECLARE @OrganellesTopicId INT = (SELECT Id FROM Topics WHERE Title = N'اندامک‌ها');
IF @OrganellesTopicId IS NULL
BEGIN
    SET @OrganellesTopicId = (SELECT TOP 1 Id FROM Topics WHERE Title LIKE N'%زیست%'); 
END

INSERT INTO EducationContents (TopicId, Title, ContentText, MediaUrl, MediaType, TeacherName)
VALUES 
(
    @OrganellesTopicId, 
    N'ساختار و عملکرد میتوکندری', 
    N'میتوکندری اندامکی دو غشایی است که وظیفه اصلی آن تولید انرژی زیستی (ATP) برای سلول است. این اندامک دارای DNA مستقل و ریبوزوم‌های مخصوص خود می‌باشد که نشان‌دهنده منشاء باکتریایی آن است. غشای درونی آن چین‌خورده است تا سطح تماس برای واکنش‌های تنفسی افزایش یابد.',
    NULL,
    'Text',
    N'دکتر سلولی'
),
(
    @OrganellesTopicId,
    N'شبکه آندوپلاسمی و دستگاه گلژی',
    N'شبکه آندوپلاسمی (ER) شبکه‌ای از لوله‌ها و کیسه‌های متصل به هم است. نوع زبر آن دارای ریبوزوم است و در پروتئین‌سازی نقش دارد، و نوع صاف آن در ساخت لیپیدها موثر است. دستگاه گلژی نیز وظیفه بسته‌بندی و ارسال مواد ساخته شده را بر عهده دارد.',
    NULL,
    'Text',
    N'دکتر مولکولی'
);

DECLARE @EduContentId1 INT = (SELECT Id FROM EducationContents WHERE Title = N'ساختار و عملکرد میتوکندری');
DECLARE @EduContentId2 INT = (SELECT Id FROM EducationContents WHERE Title = N'شبکه آندوپلاسمی و دستگاه گلژی');

INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES 
('/images/questions/mitochondria.svg', 0, N'شمای کلی میتوکندری', 3, @EduContentId1),
('/images/questions/mitochondria_diagram.svg', 1, N'جزئیات غشای درونی', 3, @EduContentId1),
('/images/questions/mitochondria_diagram.svg', 0, N'دیاگرام شبکه آندوپلاسمی', 3, @EduContentId2);
GO

PRINT 'Database setup completed successfully.';
