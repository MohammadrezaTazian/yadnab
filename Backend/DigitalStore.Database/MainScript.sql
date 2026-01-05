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

-- Users Table
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PhoneNumber NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    Grade NVARCHAR(50),      -- e.g. "Grade 6"
    RefreshToken NVARCHAR(500),
    RefreshTokenExpiryTime DATETIME2,
    ProfilePicture NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- Grades Table
CREATE TABLE Grades (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- Settings Table
CREATE TABLE Settings (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT,
    [Key] NVARCHAR(100) NOT NULL,
    Value NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE()
    -- Foreign Key to Users is optional depending on requirements, usually 1-1 or 1-n
    -- CONSTRAINT FK_Settings_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);
GO

-- Products Table
CREATE TABLE Products (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Category NVARCHAR(100),
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

-- CourseTopics Table (Categories)
CREATE TABLE CourseTopics (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Category NVARCHAR(100) NOT NULL, -- e.g. "Grade6"
    Title NVARCHAR(200) NOT NULL,    -- e.g. "پایه ششم"
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- TopicItems Table (Sub-topics)
CREATE TABLE TopicItems (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CourseTopicId INT NOT NULL,
    ParentId INT, -- Self-Referencing for hierarchy
    Title NVARCHAR(200) NOT NULL,    -- e.g. "هوش کلامی"
    ImageUrl NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_TopicItems_CourseTopics FOREIGN KEY (CourseTopicId) REFERENCES CourseTopics(Id) ON DELETE CASCADE,
    CONSTRAINT FK_TopicItems_Parent FOREIGN KEY (ParentId) REFERENCES TopicItems(Id) -- No Cascade Delete to prevent accidental chain deletion, or use with caution
);
GO

-- Questions Table
CREATE TABLE Questions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TopicItemId INT NOT NULL,
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
    CONSTRAINT FK_Questions_TopicItems FOREIGN KEY (TopicItemId) REFERENCES TopicItems(Id) ON DELETE CASCADE,
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
    TopicItemId INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    ContentText NVARCHAR(MAX),
    MediaUrl NVARCHAR(MAX),
    MediaType NVARCHAR(50), -- 'Text', 'Image', 'Video'
    TeacherName NVARCHAR(100),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_EducationContents_TopicItems FOREIGN KEY (TopicItemId) REFERENCES TopicItems(Id) ON DELETE CASCADE
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
    @Grade NVARCHAR(50),
    @RefreshToken NVARCHAR(500),
    @RefreshTokenExpiryTime DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users
    SET FirstName = @FirstName,
        LastName = @LastName,
        Grade = @Grade,
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
-- Product Procedures
-- ---------------------------------------------

CREATE PROCEDURE sp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Products;
END
GO

CREATE PROCEDURE sp_GetProductsByCategory
    @Category NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Products WHERE Category = @Category;
END
GO

-- ---------------------------------------------
-- Settings Procedures (Added for completeness)
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

-- SP: Get Course Topics By Category (Joins CourseTopics and TopicItems)
CREATE PROCEDURE sp_GetCourseTopicsByCategory
    @Category NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ct.Id AS CourseTopicId,
        ct.Category,
        ct.Title AS CategoryTitle,
        ti.Id AS TopicItemId,
        ti.ParentId,
        ti.Title AS TopicTitle,
        ti.ImageUrl AS TopicImageUrl
    FROM CourseTopics ct
    LEFT JOIN TopicItems ti ON ct.Id = ti.CourseTopicId
    WHERE ct.Category = @Category
    ORDER BY ti.ParentId, ti.Id; -- Basic ordering, application logic handles tree construction
END
GO

-- SP: Get Questions By TopicItemId
CREATE PROCEDURE sp_GetQuestionsByTopicItemId
    @TopicItemId INT,
    @CurrentUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Get Questions and Answers
    SELECT 
        q.Id,
        q.TopicItemId,
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
    INTO #TempQuestions -- Store in temp table to join for images
    FROM Questions q
    LEFT JOIN DifficultyLevels dl ON q.DifficultyLevelId = dl.Id
    LEFT JOIN DetailedAnswers da ON q.Id = da.QuestionId
    LEFT JOIN UserLikes ulq ON q.Id = ulq.TargetId AND ulq.TargetType = 1 AND ulq.UserId = @CurrentUserId
    LEFT JOIN UserLikes ulda ON da.Id = ulda.TargetId AND ulda.TargetType = 2 AND ulda.UserId = @CurrentUserId
    WHERE q.TopicItemId = @TopicItemId;

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
        q.TopicItemId,
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

-- SP: Get EducationContents By TopicItemId
CREATE PROCEDURE sp_GetEducationContentsByTopicId
    @TopicItemId INT,
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
    WHERE ec.TopicItemId = @TopicItemId;

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

-- =============================================
-- 3. Seed Data
-- =============================================

-- Seed Difficulty Levels
INSERT INTO DifficultyLevels (Name, NameEn) VALUES 
(N'ساده', 'Easy'),
(N'متوسط', 'Medium'),
(N'سخت', 'Hard');
GO

-- Seed Grades
INSERT INTO Grades (Name, Description) VALUES 
(N'پایه ششم', N'تیزهوشان پایه ششم به هفتم'),
(N'پایه نهم', N'تیزهوشان پایه نهم به دهم'),
(N'کنکور تجربی', N'آزمون سراسری علوم تجربی');
GO

-- Seed Course Topics (Categories)
INSERT INTO CourseTopics (Category, Title) VALUES 
('Grade6', N'هوش ششم'),
('MathPhysics', N'ریاضی و فیزیک'),
('KonkurTajrobi', N'کنکور تجربی');
GO

-- Seed Topic Items
DECLARE @Grade6Id INT = (SELECT Id FROM CourseTopics WHERE Category = 'Grade6');
DECLARE @MathId INT = (SELECT Id FROM CourseTopics WHERE Category = 'MathPhysics');
DECLARE @KonkurTajrobiId INT = (SELECT Id FROM CourseTopics WHERE Category = 'KonkurTajrobi');

INSERT INTO TopicItems (CourseTopicId, Title, ImageUrl) VALUES 
(@Grade6Id, N'هوش کلامی', 'assets/images/topics/verbal.png'),
(@Grade6Id, N'هوش ریاضی', 'assets/images/topics/math.png'),
(@Grade6Id, N'هوش تصویری', 'assets/images/topics/visual.png'),
(@MathId, N'فیزیک', 'assets/images/topics/physics.png'),
(@KonkurTajrobiId, N'زیست شناسی', 'assets/images/topics/biology.png'),
(@KonkurTajrobiId, N'شیمی', 'assets/images/topics/chemistry.png'),
(@KonkurTajrobiId, N'فیزیک', 'assets/images/topics/physics_tajrobi.png'),
(@KonkurTajrobiId, N'ریاضیات', 'assets/images/topics/math_tajrobi.png');

-- Seed Nested Topics for Biology
DECLARE @BioId INT = (SELECT Id FROM TopicItems WHERE Title = N'زیست شناسی' AND ParentId IS NULL);

INSERT INTO TopicItems (CourseTopicId, ParentId, Title, ImageUrl) VALUES 
(@KonkurTajrobiId, @BioId, N'سلول', 'assets/images/topics/cell.png'),
(@KonkurTajrobiId, @BioId, N'ژنتیک', 'assets/images/topics/genetics.png');

DECLARE @CellId INT = SCOPE_IDENTITY(); -- Approximate (logic might need fetching by title if batched)
-- Better to fetch ID explicitly
SELECT @CellId = Id FROM TopicItems WHERE Title = N'سلول' AND ParentId = @BioId;

INSERT INTO TopicItems (CourseTopicId, ParentId, Title, ImageUrl) VALUES
(@KonkurTajrobiId, @CellId, N'اندامک‌ها', 'assets/images/topics/organelles.png'),
(@KonkurTajrobiId, @CellId, N'غشا', 'assets/images/topics/membrane.png');
GO

-- Seed Questions
DECLARE @VerbalId INT = (SELECT Id FROM TopicItems WHERE Title = N'هوش کلامی');
DECLARE @DiffEasy INT = (SELECT Id FROM DifficultyLevels WHERE NameEn = 'Easy');
DECLARE @DiffMed INT = (SELECT Id FROM DifficultyLevels WHERE NameEn = 'Medium');

-- Question 1
INSERT INTO Questions (TopicItemId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @VerbalId, 
    N'رابطه "درخت" به "جنگل" مانند رابطه "قطره" است به ...؟', 
    N'دریا', N'باران', N'آب', N'رودخانه', 
    1, -- Correct: Darya (Sea) roughly
    1402, 
    @DiffEasy
);

-- Question 2
INSERT INTO Questions (TopicItemId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @VerbalId, 
    N'متضاد کلمه "آغاز" کدام است؟', 
    N'شروع', N'پایان', N'ابتدا', N'وسط', 
    2, 
    1403, 
    @DiffEasy
);

-- Question 3 (Biology - Konkur)
DECLARE @BiologyId INT = (SELECT Id FROM TopicItems WHERE Title = N'اندامک‌ها');

INSERT INTO Questions (TopicItemId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @BiologyId, 
    N'کدام اندامک مسئول تولید انرژی در سلول است؟', 
    N'هسته', N'میتوکندری', N'ریبوزوم', N'لیزوزوم', 
    2, -- Mitochondria
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
DECLARE @VerbalId_Edu INT = (SELECT Id FROM TopicItems WHERE Title = N'هوش کلامی');
DECLARE @BiologyId INT = (SELECT Id FROM TopicItems WHERE Title = N'زیست شناسی');

INSERT INTO EducationContents (TopicItemId, Title, ContentText, MediaUrl, MediaType, TeacherName)
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

-- =============================================
-- Feature: Likes & Comments System
-- =============================================

-- UserLikes Table
CREATE TABLE UserLikes (
    Id BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL, -- changed to INT to match Users table Id type
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
    UserId INT NOT NULL, -- changed to INT
    TargetId INT NOT NULL,
    TargetType TINYINT NOT NULL, -- 1=Question, 2=Answer, 3=EducationContent
    ParentCommentId BIGINT,
    Content NVARCHAR(1000) NOT NULL,
    LikeCount INT DEFAULT 0,
    IsDeleted BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Comments_Users FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Comments_Parent FOREIGN KEY (ParentCommentId) REFERENCES Comments(Id) -- Self-referencing
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
    -- Soft delete, only if user owns it
    UPDATE Comments SET IsDeleted = 1 WHERE Id = @Id AND UserId = @UserId;
END
GO

-- Seed Users (Test User with ID 3 for authentication token)
SET IDENTITY_INSERT Users ON;
IF NOT EXISTS (SELECT 1 FROM Users WHERE Id = 3)
BEGIN
    INSERT INTO Users (Id, PhoneNumber, FirstName, LastName, Grade, CreatedAt) 
    VALUES (3, '09351881491', N'کاربر', N'تستی', N'پایه ششم', GETDATE());
END
SET IDENTITY_INSERT Users OFF;

-- Also seed a generic test user
INSERT INTO Users (PhoneNumber, FirstName, LastName, Grade) 
VALUES ('09123456789', N'کاربر', N'تستی دیگر', N'پایه ششم');

DECLARE @TestUserId INT = SCOPE_IDENTITY();

-- Seed Comments (for Question 1)
DECLARE @Q1_Id INT = (SELECT TOP 1 Id FROM Questions);

-- Top level comment
INSERT INTO Comments (UserId, TargetId, TargetType, Content)
VALUES (@TestUserId, @Q1_Id, 1, N'این سوال خیلی نکته‌دار بود، ممنون!');

DECLARE @ParentCommId BIGINT = SCOPE_IDENTITY();

-- Reply
INSERT INTO Comments (UserId, TargetId, TargetType, ParentCommentId, Content)
VALUES (@TestUserId, @Q1_Id, 1, @ParentCommId, N'خواهش می‌کنم، دقت کنید که...');
GO

-- Seed Products
INSERT INTO Products (Title, Description, Price, Category) VALUES 
(N'پکیج جامع هوش ششم', N'شامل تمامی مباحث هوش کلامی، ریاضی و تصویری', 500000, 'Grade6'),
(N'پکیج جامع کنکور تجربی', N'شامل زیست، شیمی، فیزیک و ریاضی با پاسخ تشریحی', 1200000, 'KonkurTajrobi');
GO

PRINT 'Database MainTemplate recreated successfully with seeded data.';

-- Seed Questions with Images (Math & Biology)
DECLARE @BiologyId INT = (SELECT Id FROM TopicItems WHERE Title = N'اندامک‌ها');
-- If 'اندامک‌ها' doesn't exist, fallback to 'زیست‌شناسی' or create it. Assuming it exists or I should use existing one.
-- Let's check existing topics first.
-- Checking TopicItems...
-- I'll use a known topic or insert one if needed.
-- Let's stick to using @KonkurTajrobiId for now or check previous VIEW.
-- I'll just insert a new topic to be safe or use Math.

-- Insert a topic for Biology if not exists (for safety in this script block)
IF NOT EXISTS (SELECT 1 FROM TopicItems WHERE Title = N'زیست‌شناسی سلولی')
BEGIN
    INSERT INTO TopicItems (CourseTopicId, Title) VALUES ((SELECT Id FROM CourseTopics WHERE Category = 'KonkurTajrobi'), N'زیست‌شناسی سلولی');
END
DECLARE @BioTopicId INT = (SELECT Id FROM TopicItems WHERE Title = N'زیست‌شناسی سلولی');

-- Question with Image (Biology)
INSERT INTO Questions (TopicItemId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
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

-- Detailed Answer
INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @BioQId2,
    N'میتوکندری اندامکی است که وظیفه تنفس سلولی و تولید انرژی را بر عهده دارد.',
    N'دکتر زیست',
    1402
);

DECLARE @BioDAId INT = SCOPE_IDENTITY();

-- Question with 2 Images (Math)
DECLARE @MathTopicId2 INT = (SELECT Id FROM TopicItems WHERE Title = N'هوش ریاضی');

INSERT INTO Questions (TopicItemId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
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
-- EntityTypeId: 1=Question, 2=DetailedAnswer, 3=EducationContent

-- Bio Question Images
INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES 
('/images/questions/mitochondria.svg', 0, N'میتوکندری', 1, @BioQId2);

-- Math Question Images
INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES 
('/images/questions/math_p1.svg', 0, N'شکل ۱', 1, @MathQId),
('/images/questions/math_p2.svg', 1, N'شکل ۲', 1, @MathQId);

-- Bio Detailed Answer Image (Example)
INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES
('/images/questions/mitochondria_diagram.svg', 0, N'دیاگرام', 2, @BioDAId);
GO

-- Seed Education Contents for Organelles (Extra Request)
DECLARE @OrganellesTopicId INT = (SELECT Id FROM TopicItems WHERE Title = N'اندامک‌ها');
-- Fallback if topic doesn't exist (e.g. if script ran partially or order changed)
IF @OrganellesTopicId IS NULL
BEGIN
    SET @OrganellesTopicId = (SELECT TOP 1 Id FROM TopicItems WHERE Title LIKE N'%زیست%'); 
END

INSERT INTO EducationContents (TopicItemId, Title, ContentText, MediaUrl, MediaType, TeacherName)
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

DECLARE @EduContentId1 INT = SCOPE_IDENTITY(); -- This gets the LAST id. We need both.
-- Better fetching strategy to be safe
SET @EduContentId1 = (SELECT Id FROM EducationContents WHERE Title = N'ساختار و عملکرد میتوکندری');
DECLARE @EduContentId2 INT = (SELECT Id FROM EducationContents WHERE Title = N'شبکه آندوپلاسمی و دستگاه گلژی');

-- Images for Mitochondria Content (EntityTypeId = 3)
INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES 
('/images/questions/mitochondria.svg', 0, N'شمای کلی میتوکندری', 3, @EduContentId1),
('/images/questions/mitochondria_diagram.svg', 1, N'جزئیات غشای درونی', 3, @EduContentId1);

-- Images for ER Content
INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES 
('/images/questions/mitochondria_diagram.svg', 0, N'دیاگرام شبکه آندوپلاسمی', 3, @EduContentId2);
GO
