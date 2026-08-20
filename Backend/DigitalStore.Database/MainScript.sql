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
    Name NVARCHAR(50) NOT NULL,    -- e.g. "آسان"
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

-- ImageTypes Table (Lookup for ContentImages ImageType)
CREATE TABLE ImageTypes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Seed ImageTypes (Lookup)
SET IDENTITY_INSERT ImageTypes ON;
INSERT INTO ImageTypes (Id, TypeName) VALUES 
(1, 'FullPage'),
(2, 'Figure'),
(3, 'Chart'),
(4, 'Table'),
(5, 'Formula'),
(6, 'Other');
SET IDENTITY_INSERT ImageTypes OFF;
GO

-- Courses Table
CREATE TABLE Courses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    ImageUrl NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- PackageCourses Table (Mapping between Packages and Courses)
CREATE TABLE PackageCourses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PackageId INT NOT NULL,
    CourseId INT NOT NULL,
    SortOrder INT DEFAULT 0,
    CONSTRAINT FK_PackageCourses_Packages FOREIGN KEY (PackageId) REFERENCES Packages(Id) ON DELETE CASCADE,
    CONSTRAINT FK_PackageCourses_Courses FOREIGN KEY (CourseId) REFERENCES Courses(Id) ON DELETE CASCADE
);
GO

-- Topics Table (Pure deduplicated concepts)
CREATE TABLE Topics (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ImageUrl NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- CourseTopics Table (Tree hierarchy of concepts within a Course)
CREATE TABLE CourseTopics (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CourseId INT NOT NULL,
    TopicId INT NOT NULL,
    ParentCourseTopicId INT NULL, -- Self-reference for unlimited hierarchy depth
    SortOrder INT DEFAULT 0,
    CONSTRAINT FK_CourseTopics_Courses FOREIGN KEY (CourseId) REFERENCES Courses(Id) ON DELETE CASCADE,
    CONSTRAINT FK_CourseTopics_Topics FOREIGN KEY (TopicId) REFERENCES Topics(Id) ON DELETE CASCADE,
    CONSTRAINT FK_CourseTopics_Parent FOREIGN KEY (ParentCourseTopicId) REFERENCES CourseTopics(Id)
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
    SourceCode NVARCHAR(150) NULL, -- Helper key for data import/convert pipeline (e.g. Fizik2_ZipLine_SibeTorsh_Q001)
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Questions_Topics FOREIGN KEY (TopicId) REFERENCES Topics(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Questions_DifficultyLevels FOREIGN KEY (DifficultyLevelId) REFERENCES DifficultyLevels(Id)
);
CREATE INDEX IX_Questions_SourceCode ON Questions(SourceCode);
GO

-- DetailedAnswers Table (One-to-Many with Questions: supports multiple solutions per question)
CREATE TABLE DetailedAnswers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    QuestionId INT NOT NULL, -- Removed UNIQUE to allow multiple solutions per question
    AnswerText NVARCHAR(MAX),
    AnswerAuthor NVARCHAR(100),
    AnswerYear INT,
    SourceCode NVARCHAR(150) NULL, -- Helper key for data import/convert pipeline (e.g. Fizik2_ZipLine_SibeTorsh_A001_01)
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_DetailedAnswers_Questions FOREIGN KEY (QuestionId) REFERENCES Questions(Id) ON DELETE CASCADE
);
CREATE INDEX IX_DetailedAnswers_SourceCode ON DetailedAnswers(SourceCode);
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
    ImageTypeId INT NOT NULL DEFAULT 6,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_ContentImages_EntityTypes FOREIGN KEY (EntityTypeId) REFERENCES EntityTypes(Id),
    CONSTRAINT FK_ContentImages_ImageTypes FOREIGN KEY (ImageTypeId) REFERENCES ImageTypes(Id)
);
CREATE INDEX IX_ContentImages_Entity ON ContentImages(EntityTypeId, EntityId);
CREATE UNIQUE INDEX IX_ContentImages_FullPage ON ContentImages(EntityTypeId, EntityId, ImageTypeId) WHERE ImageTypeId = 1;
GO

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

-- =============================================
-- 2. Stored Procedures
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetUserByPhoneNumber
    @PhoneNumber NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Users WHERE PhoneNumber = @PhoneNumber;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateUser
    @PhoneNumber NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Users (PhoneNumber, CreatedAt)
    VALUES (@PhoneNumber, GETDATE());
    
    SELECT * FROM Users WHERE Id = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateUser
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

CREATE OR ALTER PROCEDURE sp_GetUserByRefreshToken
    @RefreshToken NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Users WHERE RefreshToken = @RefreshToken;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateProfilePicture
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

CREATE OR ALTER PROCEDURE sp_GetAllPackages
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Packages;
END
GO

CREATE OR ALTER PROCEDURE sp_GetPackagesByCategory
    @Category NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Packages WHERE Category = @Category;
END
GO

CREATE OR ALTER PROCEDURE sp_GetSettingByKey
    @UserId INT,
    @Key NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Settings WHERE UserId = @UserId AND [Key] = @Key;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateSetting
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
    SELECT * FROM Settings WHERE UserId = @UserId AND [Key] = @Key;
END
GO

CREATE OR ALTER PROCEDURE sp_GetTopicsByPackage
    @PackageId INT
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #TempTree (
        Id INT,
        ParentId INT NULL,
        Title NVARCHAR(200),
        ImageUrl NVARCHAR(MAX),
        SortOrder INT
    );

    -- 1. Courses mapped to this Package (Level 1 Root Nodes: Id = 100000 + Course.Id, ParentId = NULL)
    INSERT INTO #TempTree (Id, ParentId, Title, ImageUrl, SortOrder)
    SELECT 
        100000 + c.Id AS Id,
        CAST(NULL AS INT) AS ParentId,
        c.Title,
        c.ImageUrl,
        pc.SortOrder AS SortOrder
    FROM Courses c
    INNER JOIN PackageCourses pc ON c.Id = pc.CourseId
    WHERE pc.PackageId = @PackageId;

    -- 2. Non-Leaf CourseTopics (Intermediate Parent Nodes: Id = 200000 + CourseTopic.Id)
    INSERT INTO #TempTree (Id, ParentId, Title, ImageUrl, SortOrder)
    SELECT 
        200000 + ct.Id AS Id,
        CASE 
            WHEN ct.ParentCourseTopicId IS NULL THEN 100000 + ct.CourseId 
            ELSE 200000 + ct.ParentCourseTopicId 
        END AS ParentId,
        t.Title,
        t.ImageUrl,
        ct.SortOrder
    FROM CourseTopics ct
    INNER JOIN Topics t ON ct.TopicId = t.Id
    INNER JOIN PackageCourses pc ON ct.CourseId = pc.CourseId
    WHERE pc.PackageId = @PackageId
      AND EXISTS (SELECT 1 FROM CourseTopics child WHERE child.ParentCourseTopicId = ct.Id);

    -- 3. Leaf CourseTopics (Leaf Nodes: Id = Real Topic.Id required by Flutter/Questions)
    INSERT INTO #TempTree (Id, ParentId, Title, ImageUrl, SortOrder)
    SELECT 
        t.Id AS Id,
        CASE 
            WHEN ct.ParentCourseTopicId IS NULL THEN 100000 + ct.CourseId 
            ELSE 200000 + ct.ParentCourseTopicId 
        END AS ParentId,
        t.Title,
        t.ImageUrl,
        ct.SortOrder
    FROM CourseTopics ct
    INNER JOIN Topics t ON ct.TopicId = t.Id
    INNER JOIN PackageCourses pc ON ct.CourseId = pc.CourseId
    WHERE pc.PackageId = @PackageId
      AND NOT EXISTS (SELECT 1 FROM CourseTopics child WHERE child.ParentCourseTopicId = ct.Id);

    -- Return distinct ordered virtual tree
    SELECT Id, ParentId, Title, ImageUrl
    FROM #TempTree
    GROUP BY Id, ParentId, Title, ImageUrl, SortOrder
    ORDER BY ParentId, SortOrder;

    DROP TABLE #TempTree;
END
GO

CREATE OR ALTER PROCEDURE sp_GetQuestionsByTopicId
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

CREATE OR ALTER PROCEDURE sp_GetQuestionById
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

CREATE OR ALTER PROCEDURE sp_GetEducationContentsByTopicId
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

CREATE OR ALTER PROCEDURE sp_GetEducationContentById
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

CREATE OR ALTER PROCEDURE sp_GetContentImages
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
        ci.EntityId,
        ci.ImageTypeId
    FROM ContentImages ci
    WHERE ci.EntityTypeId = @EntityTypeId AND ci.EntityId = @EntityId
    ORDER BY ci.DisplayOrder;
END
GO

CREATE OR ALTER PROCEDURE sp_SearchEntities
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

CREATE OR ALTER PROCEDURE sp_AddContentImage
    @EntityTypeId INT,
    @EntityId INT,
    @ImageUrl NVARCHAR(500),
    @AltText NVARCHAR(200) = NULL,
    @DisplayOrder INT = 0,
    @ImageTypeId INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO ContentImages (EntityTypeId, EntityId, ImageUrl, AltText, DisplayOrder, ImageTypeId)
    VALUES (@EntityTypeId, @EntityId, @ImageUrl, @AltText, @DisplayOrder, @ImageTypeId);
    
    SELECT * FROM ContentImages WHERE Id = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE sp_ToggleLike
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

CREATE OR ALTER PROCEDURE sp_AddComment
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

CREATE OR ALTER PROCEDURE sp_GetCommentsByTargetId
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

CREATE OR ALTER PROCEDURE sp_DeleteComment
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
(N'آسان', 'Easy'),
(N'متوسط', 'Medium'),
(N'سخت', 'Hard');
GO

-- Seed Educational Levels
INSERT INTO EducationalLevels (Name, Description) VALUES 
(N'پایه ششم', N'توضیحات مربوط به پایه ششم'),
(N'پایه هفتم', N'توضیحات مربوط به پایه هفتم'),
(N'دوازدهم تجربی', N'پکیج جامع سال دوازدهم تجربی');
GO

-- Seed Packages
INSERT INTO Packages (Title, Description, Price, Category) VALUES 
(N'پکیج جامع دوازدهم تجربی کنکور', N'پکیج کامل دروس اختصاصی کنکور تجربی', 1200000, 'Grade12Tajrobi'),
(N'پکیج جامع دوازدهم ریاضی کنکور', N'پکیج کامل دروس اختصاصی کنکور ریاضی', 1200000, 'Grade12Math'),
(N'پکیج جامع پایه ششم', N'پکیج کامل دروس هوش و استعداد ششم', 500000, 'Grade6');
GO

-- Seed Courses
INSERT INTO Courses (Title, Description) VALUES 
(N'فیزیک ۳ دوازدهم تجربی', N'درس فیزیک پایه دوازدهم رشته تجربی'),
(N'فیزیک ۳ دوازدهم ریاضی', N'درس فیزیک پایه دوازدهم رشته ریاضی'),
(N'هوش و استعداد ششم', N'درس هوش و استعداد تحلیلی پایه ششم');
GO

-- Seed PackageCourses
DECLARE @PkgTajrobi INT = (SELECT Id FROM Packages WHERE Category = 'Grade12Tajrobi');
DECLARE @PkgMath INT = (SELECT Id FROM Packages WHERE Category = 'Grade12Math');
DECLARE @PkgGrade6 INT = (SELECT Id FROM Packages WHERE Category = 'Grade6');

DECLARE @CoursePhysTajrobi INT = (SELECT Id FROM Courses WHERE Title = N'فیزیک ۳ دوازدهم تجربی');
DECLARE @CoursePhysMath INT = (SELECT Id FROM Courses WHERE Title = N'فیزیک ۳ دوازدهم ریاضی');
DECLARE @CourseGrade6 INT = (SELECT Id FROM Courses WHERE Title = N'هوش و استعداد ششم');

INSERT INTO PackageCourses (PackageId, CourseId, SortOrder) VALUES
(@PkgTajrobi, @CoursePhysTajrobi, 1),
(@PkgMath, @CoursePhysMath, 1),
(@PkgGrade6, @CourseGrade6, 1);
GO

-- Seed Topics (Pure Deduplicated Concepts)
INSERT INTO Topics (Title, ImageUrl) VALUES 
(N'هوش کلامی', 'assets/images/topics/verbal.png'),
(N'هوش ریاضی', 'assets/images/topics/math.png'),
(N'هوش تصویری', 'assets/images/topics/visual.png'),
(N'فیزیک', 'assets/images/topics/physics.png'),
(N'زیست شناسی', 'assets/images/topics/biology.png'),
(N'شیمی', 'assets/images/topics/chemistry.png'),
(N'ریاضیات', 'assets/images/topics/math_tajrobi.png'),
(N'سلول', 'assets/images/topics/cell.png'),
(N'ژنتیک', 'assets/images/topics/genetics.png'),
(N'اندامک‌ها', 'assets/images/topics/organelles.png'),
(N'غشا', 'assets/images/topics/membrane.png'),
(N'نوسان و موج', 'assets/images/topics/physics.png'),
(N'برهم‌کنش‌های موج', 'assets/images/topics/physics.png'),
(N'موج', 'assets/images/topics/physics.png'),
(N'ویژگی‌های موج', 'assets/images/topics/physics.png'),
(N'بازتاب موج', 'assets/images/topics/physics.png');
GO

-- Seed CourseTopics
DECLARE @CoursePhysTajrobi INT = (SELECT Id FROM Courses WHERE Title = N'فیزیک ۳ دوازدهم تجربی');
DECLARE @CoursePhysMath INT = (SELECT Id FROM Courses WHERE Title = N'فیزیک ۳ دوازدهم ریاضی');
DECLARE @CourseGrade6 INT = (SELECT Id FROM Courses WHERE Title = N'هوش و استعداد ششم');

DECLARE @T_Verbal INT = (SELECT Id FROM Topics WHERE Title = N'هوش کلامی');
DECLARE @T_Math INT = (SELECT Id FROM Topics WHERE Title = N'هوش ریاضی');
DECLARE @T_Visual INT = (SELECT Id FROM Topics WHERE Title = N'هوش تصویری');

DECLARE @T_Novasan INT = (SELECT Id FROM Topics WHERE Title = N'نوسان و موج');
DECLARE @T_BerhamKonesh INT = (SELECT Id FROM Topics WHERE Title = N'برهم‌کنش‌های موج');
DECLARE @T_Mooj INT = (SELECT Id FROM Topics WHERE Title = N'موج');
DECLARE @T_Veyzegi INT = (SELECT Id FROM Topics WHERE Title = N'ویژگی‌های موج');
DECLARE @T_Baztab INT = (SELECT Id FROM Topics WHERE Title = N'بازتاب موج');

-- 1. CourseTopics for Grade 6
INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CourseGrade6, @T_Verbal, NULL, 1),
(@CourseGrade6, @T_Math, NULL, 2),
(@CourseGrade6, @T_Visual, NULL, 3);

-- 2. CourseTopics for Physics 3 Tajrobi (فیزیک ۳ دوازدهم تجربی)
-- نوسان و موج -> موج -> ویژگی‌های موج -> بازتاب موج
INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysTajrobi, @T_Novasan, NULL, 1);

DECLARE @CT_Novasan_Tajrobi INT = SCOPE_IDENTITY();

INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysTajrobi, @T_Mooj, @CT_Novasan_Tajrobi, 1);

DECLARE @CT_Mooj_Tajrobi INT = SCOPE_IDENTITY();

INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysTajrobi, @T_Veyzegi, @CT_Mooj_Tajrobi, 1);

DECLARE @CT_Veyzegi_Tajrobi INT = SCOPE_IDENTITY();

INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysTajrobi, @T_Baztab, @CT_Veyzegi_Tajrobi, 1);

-- 3. CourseTopics for Physics 3 Math (فیزیک ۳ دوازدهم ریاضی)
-- برهم‌کنش‌های موج -> موج -> ویژگی‌های موج -> بازتاب موج
INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysMath, @T_BerhamKonesh, NULL, 1);

DECLARE @CT_BerhamKonesh_Math INT = SCOPE_IDENTITY();

INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysMath, @T_Mooj, @CT_BerhamKonesh_Math, 1);

DECLARE @CT_Mooj_Math INT = SCOPE_IDENTITY();

INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysMath, @T_Veyzegi, @CT_Mooj_Math, 1);

DECLARE @CT_Veyzegi_Math INT = SCOPE_IDENTITY();

INSERT INTO CourseTopics (CourseId, TopicId, ParentCourseTopicId, SortOrder) VALUES
(@CoursePhysMath, @T_Baztab, @CT_Veyzegi_Math, 1);
GO

-- Seed Questions
DECLARE @VerbalId INT = (SELECT Id FROM Topics WHERE Title = N'هوش کلامی');
DECLARE @DiffEasy INT = (SELECT Id FROM DifficultyLevels WHERE NameEn = 'Easy');
DECLARE @DiffMed INT = (SELECT Id FROM DifficultyLevels WHERE NameEn = 'Medium');

-- Question 1
INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @VerbalId, 
    N'نسبت "شب" به "روز" مانند نسبت "سرد" است به ...؟', 
    N'گرم', N'برف', N'یخ', N'تاریکی', 
    1, 
    1402, 
    @DiffEasy
);

-- Question 2
INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @VerbalId, 
    N'معنای واژه "سامان" چیست؟', 
    N'نظم', N'آرامش', N'آراستگی', N'همه', 
    4, 
    1403, 
    @DiffEasy
);

-- Question 3 (Biology - Konkur)
DECLARE @BiologyId INT = (SELECT Id FROM Topics WHERE Title = N'زیست شناسی');

INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @BiologyId, 
    N'کدام اندامک یاخته‌ای مسئول تولید انرژی است؟', 
    N'هسته', N'میتوکندری', N'ریبوپلاست', N'لیزوزوم', 
    2, 
    1402, 
    @DiffEasy
);
GO

-- Seed Detailed Answers
DECLARE @Q1Id INT = (SELECT Id FROM Questions WHERE QuestionText LIKE N'نسبت "شب"%');

INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @Q1Id,
    N'شب و روز متضاد هم هستند، پس متضاد کلمه سرد، گرم است.',
    N'استاد مرادی',
    1402
);

-- Answer for Bio Q
DECLARE @BioQId INT = (SELECT Id FROM Questions WHERE QuestionText LIKE N'کدام اندامک%');

INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @BioQId,
    N'میتوکندری با تنفس سلولی منبع اصلی تولید ATP یا همان انرژی سلول است.',
    N'دکتر رضایی',
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
    N'مفاهیم اولیه هوش کلامی',
    N'در این درس به بررسی تناسب کلمات می‌پردازیم...',
    'https://example.com/verbal-lesson-1.mp4',
    'Video',
    N'استاد مرادی'
),
(
    @VerbalId_Edu,
    N'تکنیک‌های درک مطلب',
    N'۱. دقت به آرایه‌ها ۲. خلاصه‌نویسی...',
    NULL,
    'Text',
    N'استاد مرادی'
),
(
    @BiologyId,
    N'مقدمه‌ای بر یاخته شناسی',
    N'یاخته کوچکترین واحد ساختاری و عملکردی حیات است...',
    NULL,
    'Text',
    N'دکتر رضایی'
);
GO

-- Seed Users (Test User with ID 3)
DECLARE @Grade6LevelId INT = (SELECT Id FROM EducationalLevels WHERE Name = N'پایه ششم');

SET IDENTITY_INSERT Users ON;
IF NOT EXISTS (SELECT 1 FROM Users WHERE Id = 3)
BEGIN
    INSERT INTO Users (Id, PhoneNumber, FirstName, LastName, EducationalLevelId, CreatedAt) 
    VALUES (3, '09351881491', N'حمید', N'مرادی', @Grade6LevelId, GETDATE());
END
SET IDENTITY_INSERT Users OFF;

INSERT INTO Users (PhoneNumber, FirstName, LastName, EducationalLevelId) 
VALUES ('09123456789', N'محمد', N'رضا تازیان', @Grade6LevelId);

DECLARE @TestUserId INT = SCOPE_IDENTITY();

-- Seed Comments (for Question 1)
DECLARE @Q1_Id INT = (SELECT TOP 1 Id FROM Questions);

INSERT INTO Comments (UserId, TargetId, TargetType, Content)
VALUES (@TestUserId, @Q1_Id, 1, N'سوال بسیار عالی و استانداری بود!');

DECLARE @ParentCommId BIGINT = SCOPE_IDENTITY();

INSERT INTO Comments (UserId, TargetId, TargetType, ParentCommentId, Content)
VALUES (@TestUserId, @Q1_Id, 1, @ParentCommId, N'پاسخ استاد هم بسیار عالی بود...');
GO

-- Seed Questions with Images
DECLARE @BioTopicId INT = (SELECT Id FROM Topics WHERE Title = N'زیست شناسی');

INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @BioTopicId,
    N'کدام اندامک مسئول ساخت ATP است؟',
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
    N'میتوکندری انرژی مورد نیاز را تولید می‌کند.',
    N'دکتر رضایی',
    1402
);

DECLARE @BioDAId INT = SCOPE_IDENTITY();

-- Question with 2 Images (Math)
DECLARE @MathTopicId2 INT = (SELECT Id FROM Topics WHERE Title = N'هوش ریاضی');

INSERT INTO Questions (TopicId, QuestionText, Option1, Option2, Option3, Option4, CorrectOption, QuestionYear, DifficultyLevelId)
VALUES (
    @MathTopicId2,
    N'در شکل زیر مقدار x را بیابید:',
    N'۱۰',
    N'۲۰',
    N'۳۰',
    N'۴۰',
    3,
    1403,
    2
);

DECLARE @MathQId INT = SCOPE_IDENTITY();

INSERT INTO DetailedAnswers (QuestionId, AnswerText, AnswerAuthor, AnswerYear)
VALUES (
    @MathQId,
    N'با استفاده از رابطه فیثاغورس x به دست می‌آید.',
    N'استاد احمدی',
    1403
);

-- Seed Content Images for Questions & Answers
DECLARE @VerbalQ1Id INT = (SELECT Id FROM Questions WHERE QuestionText LIKE N'نسبت "شب"%');
DECLARE @VerbalDA1Id INT = (SELECT Id FROM DetailedAnswers WHERE QuestionId = @VerbalQ1Id);

INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId, ImageTypeId)
VALUES 
('/images/questionsImageFile/001.png', 0, N'تصویر کامل سوال هوش کلامی', 1, @VerbalQ1Id, 1),
('/images/answersImageFile/001.png', 0, N'تصویر کامل پاسخ تشریحی هوش کلامی', 2, @VerbalDA1Id, 1),
('/images/questions/mitochondria.svg', 0, N'میتوکندری', 1, @BioQId2, 6),
('/images/questions/math_p1.svg', 0, N'شکل ۱', 1, @MathQId, 6),
('/images/questions/math_p2.svg', 1, N'شکل ۲', 1, @MathQId, 6),
('/images/questions/mitochondria_diagram.svg', 0, N'دیاگرام', 2, @BioDAId, 6);
GO

-- Seed Education Contents for Organelles
DECLARE @OrganellesTopicId INT = (SELECT Id FROM Topics WHERE Title = N'اندامک‌ها');
IF @OrganellesTopicId IS NULL
BEGIN
    SET @OrganellesTopicId = (SELECT TOP 1 Id FROM Topics WHERE Title LIKE N'%اندامک%'); 
END

INSERT INTO EducationContents (TopicId, Title, ContentText, MediaUrl, MediaType, TeacherName)
VALUES 
(
    @OrganellesTopicId, 
    N'ساختار و عملکرد میتوکندری', 
    N'میتوکندری یکی از مهم‌ترین اندامک‌های سلول است...',
    NULL,
    'Text',
    N'دکتر رضایی'
),
(
    @OrganellesTopicId,
    N'شبکه آندوپلاسمی',
    N'شبکه آندوپلاسمی به دو صورت زبر و صاف وجود دارد...',
    NULL,
    'Text',
    N'دکتر رضایی'
);

DECLARE @EduContentId1 INT = (SELECT Id FROM EducationContents WHERE Title = N'ساختار و عملکرد میتوکندری');
DECLARE @EduContentId2 INT = (SELECT Id FROM EducationContents WHERE Title = N'شبکه آندوپلاسمی');

INSERT INTO ContentImages (ImageUrl, DisplayOrder, AltText, EntityTypeId, EntityId)
VALUES 
('/images/questions/mitochondria.svg', 0, N'نمای میتوکندری', 3, @EduContentId1),
('/images/questions/mitochondria_diagram.svg', 1, N'تصویر یاخته', 3, @EduContentId1),
('/images/questions/mitochondria_diagram.svg', 0, N'شبکه آندوپلاسمی', 3, @EduContentId2);
GO

PRINT 'Database setup completed successfully.';
