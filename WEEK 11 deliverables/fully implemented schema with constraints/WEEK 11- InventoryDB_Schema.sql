-- InventoryDB_Schema.sql


-- 1. Database creation
DROP DATABASE IF EXISTS InventoryDB;
CREATE DATABASE InventoryDB;
USE InventoryDB;

-- 2. Tables with constraints
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL CHECK (LENGTH(password) >= 8),
    -- ... (all other columns + constraints)
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    -- ... (all other columns + constraints)
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- 3. Triggers/Procedures (if any)
DELIMITER //
CREATE TRIGGER example_trigger
BEFORE INSERT ON Products
FOR EACH ROW
BEGIN
    -- Your trigger logic here
END //
DELIMITER ;