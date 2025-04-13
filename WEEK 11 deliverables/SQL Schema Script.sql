DROP DATABASE IF EXISTS InventoryDB;
CREATE DATABASE InventoryDB;
USE InventoryDB;

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'manager', 'staff') NOT NULL
);

CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50),
    address TEXT
);

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50),
    address TEXT
);

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

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
);

CREATE TABLE Discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    discount_percentage DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE SET NULL
);

CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE StockTransactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    transaction_type ENUM('IN', 'OUT') NOT NULL,
    quantity INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE AuditLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

INSERT INTO Users (username, password, role) VALUES
('admin1', 'hashed_password', 'admin'),
('manager1', 'hashed_password', 'manager'),
('staff1', 'hashed_password', 'staff');

INSERT INTO Suppliers (name, contact, address) VALUES
('Tech Supplies Inc.', '1234567890', '123 Tech St, City A'),
('Gadget World', '0987654321', '456 Gadget Ave, City B');

INSERT INTO Categories (category_name) VALUES
('Laptops'),
('Smartphones'),
('Accessories');

INSERT INTO Customers (name, contact, address) VALUES
('Charlie', '1112223333', '789 Customer Rd, City C'),
('River', '4445556666', '101 Customer St, City D');

INSERT INTO Orders (user_id, customer_id, status) VALUES
((SELECT user_id FROM Users WHERE username='admin1'), 1, 'Completed'),
((SELECT user_id FROM Users WHERE username='manager1'), 2, 'Pending');

INSERT INTO Products (name, description, category_id, supplier_id, stock_quantity, price, reorder_level, warranty_period)
VALUES 
('Laptop A', 'High-performance laptop', (SELECT category_id FROM Categories WHERE category_name='Laptops'), (SELECT supplier_id FROM Suppliers LIMIT 1), 20, 1200.00, 5, 24),
('Smartphone X', 'Latest smartphone model', (SELECT category_id FROM Categories WHERE category_name='Smartphones'), (SELECT supplier_id FROM Suppliers LIMIT 1), 30, 800.00, 3, 12);

INSERT INTO StockTransactions (product_id, transaction_type, quantity) 
VALUES 
((SELECT product_id FROM Products WHERE name='Laptop A'), 'IN', 50),
((SELECT product_id FROM Products WHERE name='Smartphone X'), 'IN', 100);

INSERT INTO AuditLog (user_id, action) VALUES
(1, 'Added new product'),
(2, 'Processed order');

DELIMITER //
CREATE PROCEDURE AddStock(IN p_product_id INT, IN p_quantity INT)
BEGIN
    UPDATE Products SET stock_quantity = stock_quantity + p_quantity WHERE product_id = p_product_id;
    INSERT INTO StockTransactions (product_id, transaction_type, quantity) VALUES (p_product_id, 'IN', p_quantity);
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE ReduceStock(IN p_product_id INT, IN p_quantity INT)
BEGIN
    IF (SELECT stock_quantity FROM Products WHERE product_id = p_product_id) >= p_quantity THEN
        UPDATE Products SET stock_quantity = stock_quantity - p_quantity WHERE product_id = p_product_id;
        INSERT INTO StockTransactions (product_id, transaction_type, quantity) VALUES (p_product_id, 'OUT', p_quantity);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock available';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE PopulateData()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 100000 DO
        INSERT INTO Products (name, description, category_id, supplier_id, stock_quantity, price, reorder_level, warranty_period)
        VALUES (CONCAT('Product ', i), 'Sample description', (SELECT category_id FROM Categories ORDER BY RAND() LIMIT 1), (SELECT supplier_id FROM Suppliers ORDER BY RAND() LIMIT 1), FLOOR(10 + (RAND() * 90)), ROUND(RAND() * 5000, 2), 5, 12);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL PopulateData();