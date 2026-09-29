-- DBAS 1020 - Week 3 (Part 2) Migration demo
-- File name follows the migration-tool convention:  V<version>__<description>.sql
--   V001 = steam_library_solution.sql (the original schema)
--   V002 = this file (add genres + alter existing tables)
--
-- A migration moves an EXISTING database (with real data in it) from one
-- version to the next. Notice what is NOT here: no DROP DATABASE, no
-- re-creating tables that already exist. We never rebuild prod from scratch.
--
-- MySQL note: every DDL statement auto-commits. If statement 4 fails,
-- statements 1-3 have already happened and cannot be rolled back.
-- That's why real migrations are tested on a copy first, backed up,
-- and ship with a DOWN script.

USE steam_library;

-- ======================================================================
-- UP
-- ======================================================================

-- ---------- 1. New lookup table ----------
-- Constraints are NAMED so a future migration can find and drop them.
CREATE TABLE genre (
    genre_id   INT AUTO_INCREMENT,
    genre_name VARCHAR(40) NOT NULL,
    CONSTRAINT pk_genre          PRIMARY KEY (genre_id),
    CONSTRAINT uq_genre_name     UNIQUE (genre_name),
    CONSTRAINT chk_genre_name    CHECK (genre_name <> '')
);

-- ---------- 2. Junction table: game <-> genre is many-to-many ----------
-- A game has many genres (Balatro: Roguelike, Card, Strategy).
-- A genre has many games.
-- Same pattern as ownership: two FKs that together form the PK.
CREATE TABLE game_genre (
    game_id  INT NOT NULL,
    genre_id INT NOT NULL,
    CONSTRAINT pk_game_genre       PRIMARY KEY (game_id, genre_id),
    CONSTRAINT fk_game_genre_game  FOREIGN KEY (game_id)
        REFERENCES game(game_id)   ON DELETE CASCADE,   -- game removed -> its tags go too
    CONSTRAINT fk_game_genre_genre FOREIGN KEY (genre_id)
        REFERENCES genre(genre_id) ON DELETE RESTRICT   -- can't delete a genre still in use
);

-- ---------- 3. ALTER existing tables (they already hold data!) ----------

-- 3a. New optional column: NULL is allowed, so existing rows are fine.
ALTER TABLE game
    ADD COLUMN release_date DATE NULL AFTER title;

-- 3b. New REQUIRED column on a table with rows: must supply a DEFAULT,
--     otherwise existing rows get a meaningless implicit value.
--     DEFAULT CURRENT_TIMESTAMP also means the app can't "forget" or fake it.
ALTER TABLE users
    ADD COLUMN created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 3c. Tighten a rule on existing data (succeeds only if the data already obeys it).
ALTER TABLE developer
    ADD CONSTRAINT uq_developer_name UNIQUE (developer_name);

-- Other ALTER forms worth showing (not run here):
--   ALTER TABLE game RENAME COLUMN title TO game_title;          -- rename
--   ALTER TABLE game MODIFY COLUMN title VARCHAR(150) NOT NULL;   -- change type/nullability
--   ALTER TABLE game DROP CHECK game_chk_1;                       -- drop by name (see SHOW CREATE TABLE)
--   ALTER TABLE game DROP COLUMN release_date;                    -- destructive: data is gone


-- ---------- 4. Seed lookup data (OPTIONAL - this is DML, next week's topic) ----------
-- Real migrations often seed lookup tables. Uncomment only if you want the preview.
-- INSERT INTO genre (genre_name) VALUES
-- ('Roguelike'), ('Card'), ('Action RPG'), ('FPS'), ('CRPG'), ('Puzzle'), ('Platformer');
-- INSERT INTO game_genre (game_id, genre_id) VALUES
-- (1,1),(1,2),(2,3),(3,4),(4,5),(5,6),(6,1),(7,3),(8,7);


-- ---------- Verify ----------
SHOW TABLES;
DESCRIBE game_genre;
SHOW CREATE TABLE game_genre;


-- ======================================================================
-- DOWN  (undo V002 - run these instead of UP to roll back)
-- Reverse order: children before parents, newest change first.
-- ======================================================================
-- ALTER TABLE developer DROP INDEX uq_developer_name;
-- ALTER TABLE users     DROP COLUMN created_at;
-- ALTER TABLE game      DROP COLUMN release_date;
-- DROP TABLE game_genre;
-- DROP TABLE genre;
