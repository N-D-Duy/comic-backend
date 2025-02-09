-- Thiết lập database
CREATE DATABASE IF NOT EXISTS comics_slave
  CHARACTER SET = 'utf8mb4'
  COLLATE = 'utf8mb4_unicode_ci';

USE comics_slave;

SET time_zone = '+07:00';

-- 1. Categories
CREATE TABLE categories
(
    id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL UNIQUE,
    slug        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX       idx_category_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Authors
CREATE TABLE authors
(
    id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name      VARCHAR(100) NOT NULL,
    slug      VARCHAR(100) NOT NULL UNIQUE,
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX     idx_author_name (name),
    INDEX     idx_author_slug (slug),
    FULLTEXT  INDEX ftx_author_name_bio (name, biography)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Comics
CREATE TABLE comics
(
    id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title             VARCHAR(255) NOT NULL,
    slug              VARCHAR(255) NOT NULL UNIQUE,
    alternative_titles JSON,
    description       TEXT,
    cover_image_url   VARCHAR(500),
    status            ENUM('ongoing', 'completed', 'dropped') NOT NULL,
    view_count        BIGINT UNSIGNED DEFAULT 0,
    rating            DECIMAL(3, 2) DEFAULT 0.00,
    total_chapters    INT UNSIGNED DEFAULT 0,
    category_id       BIGINT UNSIGNED,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL,
    INDEX             idx_comic_status (status),
    INDEX             idx_comic_views (view_count),
    INDEX             idx_comic_rating (rating),
    INDEX             idx_comic_slug (slug),
    FULLTEXT          INDEX ftx_comic_title_desc (title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Comics_Authors (quan hệ nhiều-nhiều)
CREATE TABLE comics_authors
(
    comic_id  BIGINT UNSIGNED,
    author_id BIGINT UNSIGNED,
    role      ENUM('author', 'artist', 'translator') NOT NULL,
    PRIMARY KEY (comic_id, author_id, role),
    FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors (id) ON DELETE CASCADE,
    INDEX    idx_comic_authors (comic_id, author_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tags
CREATE TABLE tags
(
    id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL UNIQUE,
    slug        VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX       idx_tag_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Comics_Tags (quan hệ nhiều-nhiều)
CREATE TABLE comics_tags
(
    comic_id BIGINT UNSIGNED,
    tag_id   BIGINT UNSIGNED,
    PRIMARY KEY (comic_id, tag_id),
    FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE,
    INDEX   idx_comic_tags (comic_id, tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Chapters
CREATE TABLE chapters
(
    id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    comic_id      BIGINT UNSIGNED NOT NULL,
    chapter_number DECIMAL(10, 2) NOT NULL,
    title         VARCHAR(255),
    view_count    BIGINT UNSIGNED DEFAULT 0,
    image_urls    JSON           NOT NULL,
    html_content  MEDIUMTEXT,
    page_count    INT UNSIGNED NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE,
    UNIQUE KEY comic_chapter (comic_id, chapter_number),
    INDEX         idx_chapter_views (view_count),
    INDEX         idx_chapter_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 13. Badges
CREATE TABLE badges
(
    id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(50) NOT NULL UNIQUE,
    description  TEXT,
    icon_url     VARCHAR(500),
    effect_class VARCHAR(100), -- CSS class cho hiệu ứng
    type         ENUM('achievement', 'purchase', 'special') NOT NULL,
    requirements JSON,         -- Điều kiện để đạt được (ví dụ: {uploadedComics: 10})
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX        idx_badge_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Users
CREATE TABLE users
(
    id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    role          ENUM('user', 'moderator', 'admin') DEFAULT 'user',
    is_active     TINYINT(1) DEFAULT 1,
    last_login_at TIMESTAMP NULL,
    points        BIGINT UNSIGNED DEFAULT 0,
    active_badge_id BIGINT UNSIGNED,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX         idx_user_email (email),
    INDEX         idx_user_status (is_active),
    FOREIGN KEY (active_badge_id) REFERENCES badges(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Reviews
CREATE TABLE reviews
(
    id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id   BIGINT UNSIGNED NOT NULL,
    comic_id  BIGINT UNSIGNED NOT NULL,
    rating    TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment   TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE,
    UNIQUE KEY user_comic_review (user_id, comic_id),
    INDEX     idx_review_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. ReadingHistory
CREATE TABLE reading_history
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id    BIGINT UNSIGNED NOT NULL,
    comic_id   BIGINT UNSIGNED NOT NULL,
    chapter_id BIGINT UNSIGNED NOT NULL,
    read_page  INT UNSIGNED DEFAULT 1,
    last_read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE,
    FOREIGN KEY (chapter_id) REFERENCES chapters (id) ON DELETE CASCADE,
    UNIQUE KEY user_comic_chapter (user_id, comic_id, chapter_id),
    INDEX      idx_reading_last_read (last_read_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. Favorites
CREATE TABLE favorites
(
    id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id   BIGINT UNSIGNED NOT NULL,
    comic_id  BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE,
    UNIQUE KEY user_comic_favorite (user_id, comic_id),
    INDEX     idx_favorite_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Settings
CREATE TABLE settings
(
    id                  BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id             BIGINT UNSIGNED NOT NULL,
    notification_enabled TINYINT(1) DEFAULT 1,
    theme               VARCHAR(20) DEFAULT 'light',
    created_at          TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    UNIQUE KEY user_settings (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Bảng User_Badges (Người dùng - Danh hiệu)
CREATE TABLE user_badges
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id    BIGINT UNSIGNED NOT NULL,
    badge_id   BIGINT UNSIGNED NOT NULL,
    is_active  TINYINT(1) DEFAULT 1, -- Badge đang được hiển thị
    acquired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badges (id) ON DELETE CASCADE,
    UNIQUE KEY user_badge (user_id, badge_id),
    INDEX      idx_badge_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. Bảng ComicSubmissions (Yêu cầu đăng truyện)
CREATE TABLE comic_submissions
(
    id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id       BIGINT UNSIGNED NOT NULL,
    title         VARCHAR(255) NOT NULL,
    description   TEXT,
    cover_image_url VARCHAR(500),
    category_id   BIGINT UNSIGNED,
    status        ENUM('pending', 'approved', 'rejected', 'revision_required') DEFAULT 'pending',
    moderator_id  BIGINT UNSIGNED, -- Mod xử lý submission
    moderator_note TEXT,            -- Ghi chú của mod
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL,
    FOREIGN KEY (moderator_id) REFERENCES users (id) ON DELETE SET NULL,
    INDEX         idx_submission_status (status),
    INDEX         idx_submission_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. Bảng SubmissionComments (Comments cho yêu cầu đăng truyện)
CREATE TABLE submission_comments
(
    id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    submission_id BIGINT UNSIGNED NOT NULL,
    user_id       BIGINT UNSIGNED NOT NULL,
    comment      TEXT NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES comic_submissions (id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    INDEX        idx_submission_comments (submission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 17. Bảng để lưu thông tin người upload truyện
CREATE TABLE comic_uploaders
(
    comic_id   BIGINT UNSIGNED,
    user_id    BIGINT UNSIGNED,
    role       ENUM('owner', 'collaborator') DEFAULT 'owner',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comic_id, user_id),
    FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    INDEX     idx_comic_uploaders (comic_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;