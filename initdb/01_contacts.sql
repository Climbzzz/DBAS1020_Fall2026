USE appdb;

DROP TABLE IF EXISTS contacts;

CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(25)
);

INSERT INTO contacts
(first_name,last_name,email,phone)
VALUES
('Jamie','Symonds','jamie@example.com','902-555-1001'),
('Randy','Bourque','randy@example.com','902-555-1002'),
('Craig','Collins','craig@example.com','902-555-1003'),
('Alice','Johnson','alice@example.com','902-555-1004'),
('Bob','Smith','bob@example.com','902-555-1005');