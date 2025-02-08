-- Thiết lập database
CREATE DATABASE IF NOT EXISTS comics_db
  CHARACTER SET = 'utf8mb4'
  COLLATE = 'utf8mb4_unicode_ci';

USE comics_db;

SET time_zone = '+07:00';

-- 1. Categories
CREATE TABLE Categories
(
    Id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Name        VARCHAR(50) NOT NULL UNIQUE,
    Slug        VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT,
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX       idx_category_slug (Slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Authors
CREATE TABLE Authors
(
    Id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Name      VARCHAR(100) NOT NULL,
    Slug      VARCHAR(100) NOT NULL UNIQUE,
    Biography TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX     idx_author_name (Name),
    INDEX     idx_author_slug (Slug),
    FULLTEXT  INDEX ftx_author_name_bio (Name, Biography)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Comics
CREATE TABLE Comics
(
    Id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Title             VARCHAR(255) NOT NULL,
    Slug              VARCHAR(255) NOT NULL UNIQUE,
    AlternativeTitles JSON,
    Description       TEXT,
    CoverImageUrl     VARCHAR(500),
    Status            ENUM('ongoing', 'completed', 'dropped') NOT NULL,
    ViewCount         BIGINT UNSIGNED DEFAULT 0,
    Rating            DECIMAL(3, 2) DEFAULT 0.00,
    TotalChapters     INT UNSIGNED DEFAULT 0,
    CategoryId        BIGINT UNSIGNED,
    CreatedAt         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CategoryId) REFERENCES Categories (Id) ON DELETE SET NULL,
    INDEX             idx_comic_status (Status),
    INDEX             idx_comic_views (ViewCount),
    INDEX             idx_comic_rating (Rating),
    INDEX             idx_comic_slug (Slug),
    FULLTEXT          INDEX ftx_comic_title_desc (Title, Description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Comics_Authors (quan hệ nhiều-nhiều)
CREATE TABLE Comics_Authors
(
    ComicId  BIGINT UNSIGNED,
    AuthorId BIGINT UNSIGNED,
    Role     ENUM('author', 'artist', 'translator') NOT NULL,
    PRIMARY KEY (ComicId, AuthorId, Role),
    FOREIGN KEY (ComicId) REFERENCES Comics (Id) ON DELETE CASCADE,
    FOREIGN KEY (AuthorId) REFERENCES Authors (Id) ON DELETE CASCADE,
    INDEX    idx_comic_authors (ComicId, AuthorId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tags
CREATE TABLE Tags
(
    Id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Name        VARCHAR(50) NOT NULL UNIQUE,
    Slug        VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX       idx_tag_slug (Slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Comics_Tags (quan hệ nhiều-nhiều)
CREATE TABLE Comics_Tags
(
    ComicId BIGINT UNSIGNED,
    TagId   BIGINT UNSIGNED,
    PRIMARY KEY (ComicId, TagId),
    FOREIGN KEY (ComicId) REFERENCES Comics (Id) ON DELETE CASCADE,
    FOREIGN KEY (TagId) REFERENCES Tags (Id) ON DELETE CASCADE,
    INDEX   idx_comic_tags (ComicId, TagId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Chapters
CREATE TABLE Chapters
(
    Id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ComicId       BIGINT UNSIGNED NOT NULL,
    ChapterNumber DECIMAL(10, 2) NOT NULL,
    Title         VARCHAR(255),
    ViewCount     BIGINT UNSIGNED DEFAULT 0,
    ImageUrls     JSON           NOT NULL,
    HTMLContent   MEDIUMTEXT,
    PageCount     INT UNSIGNED NOT NULL,
    CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ComicId) REFERENCES Comics (Id) ON DELETE CASCADE,
    UNIQUE KEY comic_chapter (ComicId, ChapterNumber),
    INDEX         idx_chapter_views (ViewCount),
    INDEX         idx_chapter_created (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Users
CREATE TABLE Users
(
    Id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Username    VARCHAR(50)  NOT NULL UNIQUE,
    Email       VARCHAR(255) NOT NULL UNIQUE,
    Password    VARCHAR(255) NOT NULL,
    Role        ENUM('user', 'moderator', 'admin') DEFAULT 'user',
    IsActive    TINYINT(1) DEFAULT 1,
    LastLoginAt TIMESTAMP NULL,
    Points BIGINT UNSIGNED DEFAULT 0,
    ActiveBadgeId BIGINT UNSIGNED,
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX       idx_user_email (Email),
    INDEX       idx_user_status (IsActive),
    FOREIGN KEY (ActiveBadgeId) REFERENCES Badges(Id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Reviews
CREATE TABLE Reviews
(
    Id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    UserId    BIGINT UNSIGNED NOT NULL,
    ComicId   BIGINT UNSIGNED NOT NULL,
    Rating    TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment   TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    FOREIGN KEY (ComicId) REFERENCES Comics (Id) ON DELETE CASCADE,
    UNIQUE KEY user_comic_review (UserId, ComicId),
    INDEX     idx_review_rating (Rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. ReadingHistory
CREATE TABLE ReadingHistory
(
    Id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    UserId     BIGINT UNSIGNED NOT NULL,
    ComicId    BIGINT UNSIGNED NOT NULL,
    ChapterId  BIGINT UNSIGNED NOT NULL,
    ReadPage   INT UNSIGNED DEFAULT 1,
    LastReadAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    FOREIGN KEY (ComicId) REFERENCES Comics (Id) ON DELETE CASCADE,
    FOREIGN KEY (ChapterId) REFERENCES Chapters (Id) ON DELETE CASCADE,
    UNIQUE KEY user_comic_chapter (UserId, ComicId, ChapterId),
    INDEX      idx_reading_last_read (LastReadAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. Favorites
CREATE TABLE Favorites
(
    Id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    UserId    BIGINT UNSIGNED NOT NULL,
    ComicId   BIGINT UNSIGNED NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    FOREIGN KEY (ComicId) REFERENCES Comics (Id) ON DELETE CASCADE,
    UNIQUE KEY user_comic_favorite (UserId, ComicId),
    INDEX     idx_favorite_created (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Settings
CREATE TABLE Settings
(
    Id                  BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    UserId              BIGINT UNSIGNED NOT NULL,
    NotificationEnabled TINYINT(1) DEFAULT 1,
    Theme               VARCHAR(20) DEFAULT 'light',
    CreatedAt           TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt           TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    UNIQUE KEY user_settings (UserId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. Badges
CREATE TABLE Badges
(
    Id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    Name         VARCHAR(50) NOT NULL UNIQUE,
    Description  TEXT,
    IconUrl      VARCHAR(500),
    EffectClass  VARCHAR(100), -- CSS class cho hiệu ứng
    Type         ENUM('achievement', 'purchase', 'special') NOT NULL,
    Requirements JSON,         -- Điều kiện để đạt được (ví dụ: {uploadedComics: 10})
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX        idx_badge_type (Type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Bảng User_Badges (Người dùng - Danh hiệu)
CREATE TABLE User_Badges
(
    Id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    UserId     BIGINT UNSIGNED NOT NULL,
    BadgeId    BIGINT UNSIGNED NOT NULL,
    IsActive   TINYINT(1) DEFAULT 1, -- Badge đang được hiển thị
    AcquiredAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    FOREIGN KEY (BadgeId) REFERENCES Badges (Id) ON DELETE CASCADE,
    UNIQUE KEY user_badge (UserId, BadgeId),
    INDEX      idx_badge_active (IsActive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. Bảng ComicSubmissions (Yêu cầu đăng truyện)
CREATE TABLE ComicSubmissions
(
    Id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    UserId        BIGINT UNSIGNED NOT NULL,
    Title         VARCHAR(255) NOT NULL,
    Description   TEXT,
    CoverImageUrl VARCHAR(500),
    CategoryId    BIGINT UNSIGNED,
    Status        ENUM('pending', 'approved', 'rejected', 'revision_required') DEFAULT 'pending',
    ModeratorId   BIGINT UNSIGNED, -- Mod xử lý submission
    ModeratorNote TEXT,            -- Ghi chú của mod
    CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    FOREIGN KEY (CategoryId) REFERENCES Categories (Id) ON DELETE SET NULL,
    FOREIGN KEY (ModeratorId) REFERENCES Users (Id) ON DELETE SET NULL,
    INDEX         idx_submission_status (Status),
    INDEX         idx_submission_user (UserId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. Bảng SubmissionComments (Comments cho yêu cầu đăng truyện)
CREATE TABLE SubmissionComments
(
    Id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    SubmissionId BIGINT UNSIGNED NOT NULL,
    UserId       BIGINT UNSIGNED NOT NULL,
    Comment      TEXT NOT NULL,
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SubmissionId) REFERENCES ComicSubmissions (Id) ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    INDEX        idx_submission_comments (SubmissionId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 17. Bảng để lưu thông tin người upload truyện
CREATE TABLE ComicUploaders
(
    ComicId   BIGINT UNSIGNED,
    UserId    BIGINT UNSIGNED,
    Role      ENUM('owner', 'collaborator') DEFAULT 'owner',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ComicId, UserId),
    FOREIGN KEY (ComicId) REFERENCES Comics (Id) ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES Users (Id) ON DELETE CASCADE,
    INDEX     idx_comic_uploaders (ComicId, UserId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


