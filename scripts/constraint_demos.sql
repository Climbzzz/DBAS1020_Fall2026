-- DBAS 1020 - Week 3 (Part 2) Constraint Demos
-- Run AFTER week3_steam_library_solution.sql (needs its sample data).
-- Run in MySQL Workbench connected as root (port 13306).
--
-- Every demo here is DDL only (ALTER / DROP) - no INSERT/UPDATE/DELETE.
-- Most statements are EXPECTED TO FAIL. Run them one at a time
-- (Ctrl+Enter on the current line) and read the error in the Output panel.
-- A failed ALTER changes nothing, so the database is left as it was.

USE steam_library;

-- ---------- 0. Look before you touch ----------
-- MySQL named every constraint we didn't name ourselves (game_chk_1, game_ibfk_1...).
SHOW CREATE TABLE game;

SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'steam_library'
ORDER BY table_name, constraint_type;

-- CHECK constraints are only enforced in MySQL 8.0.16+. Older versions
-- parsed CHECK and silently ignored it. Always confirm your version.
SELECT VERSION();

-- Strict mode stops MySQL from silently truncating/adjusting bad values.
-- Expect STRICT_TRANS_TABLES in the list.
SELECT @@sql_mode;


-- ---------- 1. UNIQUE - the database finds a bug the spreadsheet hid ----------
-- EXPECTED: Error 1062 Duplicate entry 'Elden Ring' for key 'game.uq_game_title'
-- Rows 2 and 7 are both 'Elden Ring' (g2 and g7 in the Week 2 data).
-- Discuss: real duplicate, or two different products? What decides that?
ALTER TABLE game ADD CONSTRAINT uq_game_title UNIQUE (title);

-- Contrast: developer names ARE already unique, so the same ALTER on
-- developer would succeed. We add that rule for real in the V002 migration.


-- ---------- 2. CHECK - existing data must already obey a new rule ----------
-- EXPECTED: Error 3819 Check constraint 'chk_ownership_hours_cap' is violated.
-- saltyhalifax has 512 hours in Counter-Strike 2.
ALTER TABLE ownership ADD CONSTRAINT chk_ownership_hours_cap CHECK (hours <= 500);


-- ---------- 3. FOREIGN KEY - you can't pull the rug out from under child rows ----------
-- EXPECTED: Error 3730 Cannot drop table 'country' referenced by a
-- foreign key constraint 'users_ibfk_1' on table 'users'.
DROP TABLE country;


-- ---------- 4. NOT NULL gotcha - "not null" is not the same as "has a real value" ----------
-- This SUCCEEDS. The 8 existing users get the implicit default for VARCHAR: ''.
ALTER TABLE users ADD COLUMN email VARCHAR(255) NOT NULL;
DESCRIBE users;

-- Now try to make email unique...
-- EXPECTED: Error 1062 Duplicate entry '' for key 'users.uq_users_email'
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);

-- Lesson: pair NOT NULL with a CHECK that rejects empty strings, e.g.
--   CHECK (email <> '')   or   CHECK (email LIKE '%_@_%._%')
-- ...and add required columns to tables with data *carefully* (see migration script).
-- Clean up so the rest of the class starts from the original schema:
ALTER TABLE users DROP COLUMN email;


-- ---------- 5. DEFAULT - secure by default ----------
-- SUCCEEDS. Every existing user is NOT an admin unless someone deliberately says so.
ALTER TABLE users ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT FALSE;
DESCRIBE users;
-- Discuss: what would DEFAULT TRUE have just done to all 8 users?
ALTER TABLE users DROP COLUMN is_admin;


-- ---------- Optional: a 10-second preview of next week ----------
-- Only if you want students to see a constraint reject a bad row directly.
-- Each statement FAILS, so no data is changed.
-- INSERT INTO game (title, price, developer_id) VALUES ('Free Money Simulator', -5.00, 1);  -- CHECK (3819)
-- INSERT INTO game (title, price, developer_id) VALUES ('Ghost Game', 9.99, 999);           -- FK (1452)
-- INSERT INTO users (username, country_id) VALUES ('pixelpanda', 1);                        -- UNIQUE (1062)
-- INSERT INTO users (username, country_id) VALUES (NULL, 1);                                -- NOT NULL (1048)
