-- InventoryDB_Schema.sql
DROP DATABASE IF EXISTS InventoryDB;
CREATE DATABASE InventoryDB;
USE InventoryDB;

-- Users table 
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'manager', 'staff') NOT NULL
) ENGINE=InnoDB;

-- Suppliers table 
CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50),
    address TEXT
) ENGINE=InnoDB;

-- Customers table 
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50),
    address TEXT
) ENGINE=InnoDB;

-- Categories table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Products table 
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT,
    supplier_id INT,
    stock_quantity INT DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    reorder_level INT DEFAULT 5,
    warranty_period INT COMMENT 'Warranty in months',
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Discounts table 
CREATE TABLE Discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    discount_percentage DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CHECK (end_date > start_date)
) ENGINE=InnoDB;

-- Orders table 
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- OrderItems table 
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- StockTransactions table (original ENUM types)
CREATE TABLE StockTransactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    transaction_type ENUM('IN', 'OUT') NOT NULL,
    quantity INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- AuditLog table 
CREATE TABLE AuditLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

--  original stored procedures 
DELIMITER //
CREATE PROCEDURE AddStock(IN p_product_id INT, IN p_quantity INT)
BEGIN
    UPDATE Products SET stock_quantity = stock_quantity + p_quantity 
    WHERE product_id = p_product_id;
    INSERT INTO StockTransactions (product_id, transaction_type, quantity) 
    VALUES (p_product_id, 'IN', p_quantity);
END //

CREATE PROCEDURE ReduceStock(IN p_product_id INT, IN p_quantity INT)
BEGIN
    IF (SELECT stock_quantity FROM Products WHERE product_id = p_product_id) >= p_quantity THEN
        UPDATE Products SET stock_quantity = stock_quantity - p_quantity 
        WHERE product_id = p_product_id;
        INSERT INTO StockTransactions (product_id, transaction_type, quantity) 
        VALUES (p_product_id, 'OUT', p_quantity);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock available';
    END IF;
END //
DELIMITER ;