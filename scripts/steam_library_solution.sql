-- DBAS 1020 - Week 3 Activity SOLUTION
-- Steam Library database (normalized in Week 2)
-- Run in MySQL Workbench connected as root (port 13306).

DROP DATABASE IF EXISTS steam_library;
CREATE DATABASE IF NOT EXISTS steam_library;
USE steam_library;

-- ---------- DDL (create parents before children) ----------

CREATE TABLE country (
    country_id   INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id    INT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(30) NOT NULL UNIQUE,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE developer (
    developer_id   INT AUTO_INCREMENT PRIMARY KEY,
    developer_name VARCHAR(100) NOT NULL,
    country_id     INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE game (
    game_id      INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(100) NOT NULL,
    price        DECIMAL(5,2) NOT NULL CHECK (price >= 0),
    developer_id INT NOT NULL,
    FOREIGN KEY (developer_id) REFERENCES developer(developer_id)
);

-- Junction table: its key columns are foreign keys, so they are plain INT
-- (not AUTO_INCREMENT). Together they form the composite primary key.
CREATE TABLE ownership (
    user_id    INT,
    game_id    INT,
    price_paid DECIMAL(5,2) NOT NULL CHECK (price_paid >= 0),
    hours      INT NOT NULL DEFAULT 0 CHECK (hours >= 0),
    achieved   DECIMAL(5,2) CHECK (achieved BETWEEN 0 AND 100),
    PRIMARY KEY (user_id, game_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (game_id) REFERENCES game(game_id)
);

-- ---------- Sample data (preview of next week's DML) ----------
-- The id columns are left out so AUTO_INCREMENT assigns them (1, 2, 3...).
-- Comments show the matching code from the Week 2 spreadsheet.

INSERT INTO country (country_name) VALUES
('Canada'),     -- 1  (c1)
('USA'),        -- 2  (c2)
('UK'),         -- 3  (c3)
('Japan'),      -- 4  (c4)
('Belgium');    -- 5  (c5)

INSERT INTO users (username, country_id) VALUES
('pixelpanda',   1),   -- 1  (u001)
('vexmoth',      1),   -- 2  (u002)
('saltyhalifax', 1),   -- 3  (u003)
('grimjoy',      2),   -- 4  (u004)
('nullptr_nate', 2),   -- 5  (u005)
('kestrel',      3),   -- 6  (u006)
('mochi_dev',    4),   -- 7  (u007)
('brambleweft',  5);   -- 8  (u008)

INSERT INTO developer (developer_name, country_id) VALUES
('LocalThunk',     1),   -- 1  (d10)
('FromSoftware',   4),   -- 2  (d11)
('Valve',          2),   -- 3  (d12)
('Larian Studios', 5),   -- 4  (d13)
('poncle',         3),   -- 5  (d14)
('Studio MDHR',    1);   -- 6  (d15)

INSERT INTO game (title, price, developer_id) VALUES
('Balatro',           19.99, 1),   -- 1  (g1)
('Elden Ring',        79.99, 2),   -- 2  (g2)
('Counter-Strike 2',   0.00, 3),   -- 3  (g3)
('Baldur''s Gate 3',  89.99, 4),   -- 4  (g4)
('Portal 2',          12.49, 3),   -- 5  (g5)
('Vampire Survivors',  6.49, 5),   -- 6  (g6)
('Elden Ring',        79.99, 2),   -- 7  (g7)
('Cuphead',           26.99, 6);   -- 8  (g8)

INSERT INTO ownership (user_id, game_id, price_paid, hours, achieved) VALUES
(1, 1, 19.99,  87,  62),
(2, 2, 79.99, 156,  71),
(3, 3,  0.00, 512,   8),
(4, 4, 89.99, 203,  49),
(5, 5,  3.74,  19, 100),
(6, 6,  6.49,  55,  78),
(7, 7, 79.99, 311,  83),
(8, 8, 13.49,  22,  31);

-- ---------- Verify ----------
SHOW TABLES;
DESCRIBE ownership;
SELECT u.username, g.title, d.developer_name, c.country_name AS dev_country
FROM ownership o
JOIN users u     ON u.user_id = o.user_id
JOIN game g      ON g.game_id = o.game_id
JOIN developer d ON d.developer_id = g.developer_id
JOIN country c   ON c.country_id = d.country_id;
