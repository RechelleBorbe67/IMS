-- Part 1: Schema Implementation with Proper Constraints
DROP DATABASE IF EXISTS InventoryDB;
CREATE DATABASE InventoryDB;
USE InventoryDB;

-- Users table with enhanced constraints
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL CHECK (LENGTH(password) >= 8),
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
    role ENUM('admin', 'manager', 'staff') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (role)
) ENGINE=InnoDB;

-- Suppliers table with enhanced constraints
CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    email VARCHAR(100) CHECK (email LIKE '%@%.%'),
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_name (name),
    INDEX idx_supplier_contact (contact)
) ENGINE=InnoDB;

-- Customers table with enhanced constraints
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    email VARCHAR(100) CHECK (email LIKE '%@%.%'),
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_name (name),
    INDEX idx_customer_contact (contact)
) ENGINE=InnoDB;

-- Categories table with enhanced constraints
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    INDEX idx_category_name (category_name)
) ENGINE=InnoDB;

-- Products table with enhanced constraints
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sku VARCHAR(50) UNIQUE NOT NULL,
    category_id INT,
    supplier_id INT,
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    cost_price DECIMAL(10,2) NOT NULL CHECK (cost_price > 0),
    reorder_level INT DEFAULT 5 CHECK (reorder_level >= 0),
    warranty_period INT COMMENT 'Warranty in months',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE SET NULL,
    INDEX idx_product_name (name),
    INDEX idx_product_sku (sku),
    INDEX idx_product_category (category_id),
    INDEX idx_product_supplier (supplier_id)
) ENGINE=InnoDB;

-- First drop the table if it exists (add this line)
DROP TABLE IF EXISTS Discounts;

-- Then create the corrected table
CREATE TABLE Discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    discount_name VARCHAR(100) NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL CHECK (discount_percentage > 0 AND discount_percentage <= 100),
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,  -- Changed from generated column
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CHECK (end_date > start_date),
    INDEX idx_discount_product (product_id),
    INDEX idx_discount_dates (start_date, end_date)
) ENGINE=InnoDB;

-- Orders table with enhanced constraints
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    customer_id INT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded') DEFAULT 'Pending',
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    tax_amount DECIMAL(10,2) DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount DECIMAL(10,2) DEFAULT 0 CHECK (shipping_amount >= 0),
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Other') NOT NULL,
    payment_status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE SET NULL,
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_status (status),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB;

-- OrderItems table with enhanced constraints
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    total_price DECIMAL(10,2) GENERATED ALWAYS AS ((price - discount_amount) * quantity) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE SET NULL,
    INDEX idx_orderitem_order (order_id),
    INDEX idx_orderitem_product (product_id)
) ENGINE=InnoDB;

-- StockTransactions table with enhanced constraints
CREATE TABLE StockTransactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    transaction_type ENUM('IN', 'OUT', 'ADJUSTMENT', 'RETURN') NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    reference_id VARCHAR(50) COMMENT 'Can reference order_id, purchase_id, etc.',
    reference_type ENUM('ORDER', 'PURCHASE', 'ADJUSTMENT', 'OTHER') COMMENT 'Type of reference',
    notes TEXT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    INDEX idx_stock_product (product_id),
    INDEX idx_stock_date (transaction_date),
    INDEX idx_stock_type (transaction_type)
) ENGINE=InnoDB;

-- AuditLog table with enhanced constraints
CREATE TABLE AuditLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT,
    action_details JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_table (table_name),
    INDEX idx_audit_timestamp (timestamp)
) ENGINE=InnoDB;

-- Part 2: Initial Data Population (Small Dataset for Referential Integrity Testing)
-- Insert sample users
INSERT INTO Users (username, password, email, role) VALUES
('admin1', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue', 'admin1@inventory.com', 'admin'),
('manager1', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue', 'manager1@inventory.com', 'manager'),
('staff1', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue', 'staff1@inventory.com', 'staff'),
('staff2', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue', 'staff2@inventory.com', 'staff'),
('manager2', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue', 'manager2@inventory.com', 'manager');

-- Insert sample suppliers
INSERT INTO Suppliers (name, contact, email, phone, address, city, country, postal_code) VALUES
('Tech Supplies Inc.', 'John Smith', 'john@techsupplies.com', '1234567890', '123 Tech St', 'San Francisco', 'USA', '94105'),
('Gadget World', 'Sarah Johnson', 'sarah@gadgetworld.com', '0987654321', '456 Gadget Ave', 'New York', 'USA', '10001'),
('Electro Parts Co.', 'Mike Brown', 'mike@electroparts.com', '5551234567', '789 Electro Rd', 'Chicago', 'USA', '60601'),
('Global Components', 'Lisa Wong', 'lisa@globalcomponents.com', '5559876543', '101 Global Blvd', 'Los Angeles', 'USA', '90015'),
('Quality Electronics', 'David Kim', 'david@qualityelectronics.com', '5554567890', '202 Quality Lane', 'Seattle', 'USA', '98101');

-- Insert categories with hierarchy
INSERT INTO Categories (category_name, description, parent_category_id) VALUES
('Electronics', 'All electronic devices', NULL),
('Computers', 'Computers and related equipment', 1),
('Laptops', 'Portable computers', 2),
('Desktops', 'Desktop computers', 2),
('Tablets', 'Tablet devices', 2),
('Phones', 'Mobile phones and smartphones', 1),
('Smartphones', 'Advanced mobile phones', 6),
('Feature Phones', 'Basic mobile phones', 6),
('Accessories', 'Electronic accessories', 1),
('Cables', 'Various cables and connectors', 9),
('Adapters', 'Power and data adapters', 9),
('Batteries', 'Rechargeable batteries', 9);

-- Insert sample customers
INSERT INTO Customers (name, contact, email, phone, address, city, country, postal_code, loyalty_points) VALUES
('Charlie Brown', 'Charlie Brown', 'charlie@example.com', '1112223333', '789 Customer Rd', 'Boston', 'USA', '02108', 100),
('River Song', 'River Song', 'river@example.com', '4445556666', '101 Customer St', 'Austin', 'USA', '78701', 250),
('Alex Johnson', 'Alex Johnson', 'alex@example.com', '7778889999', '202 Client Ave', 'Denver', 'USA', '80202', 50),
('Morgan Lee', 'Morgan Lee', 'morgan@example.com', '3334445555', '303 Buyer Blvd', 'Miami', 'USA', '33101', 500),
('Taylor Smith', 'Taylor Smith', 'taylor@example.com', '6667778888', '404 Shopper Lane', 'Portland', 'USA', '97201', 75);

-- Insert sample products
INSERT INTO Products (name, description, sku, category_id, supplier_id, stock_quantity, price, cost_price, reorder_level, warranty_period) VALUES
('Laptop Pro 15', 'High-performance business laptop', 'LP-1001', 3, 1, 50, 1299.99, 899.99, 5, 24),
('Laptop Air 13', 'Ultra-lightweight laptop', 'LP-1002', 3, 1, 35, 1099.99, 799.99, 5, 24),
('Desktop Power', 'High-end desktop computer', 'DT-2001', 4, 2, 20, 1499.99, 1099.99, 3, 36),
('Desktop Mini', 'Compact desktop computer', 'DT-2002', 4, 2, 15, 899.99, 649.99, 3, 24),
('Tablet Plus 10', '10-inch tablet with stylus', 'TB-3001', 5, 3, 40, 499.99, 349.99, 10, 12),
('Phone X', 'Flagship smartphone', 'PH-4001', 7, 4, 100, 999.99, 699.99, 15, 12),
('Phone Y', 'Mid-range smartphone', 'PH-4002', 7, 4, 80, 699.99, 499.99, 15, 12),
('Basic Phone', 'Simple feature phone', 'PH-4003', 8, 4, 30, 99.99, 69.99, 5, 6),
('USB-C Cable', '1m USB-C to USB-C cable', 'AC-5001', 10, 5, 200, 19.99, 9.99, 50, 1),
('Power Adapter', '65W USB-C power adapter', 'AC-5002', 11, 5, 150, 49.99, 29.99, 30, 12),
('Laptop Battery', 'Replacement laptop battery', 'AC-5003', 12, 5, 75, 79.99, 49.99, 20, 6);

-- Insert sample discounts
INSERT INTO Discounts (product_id, discount_name, discount_percentage, start_date, end_date) VALUES
(1, 'Summer Sale', 15.00, '2023-06-01 00:00:00', '2023-06-30 23:59:59'),
(2, 'Back to School', 10.00, '2023-08-01 00:00:00', '2023-08-31 23:59:59'),
(6, 'Holiday Special', 20.00, '2023-12-01 00:00:00', '2023-12-31 23:59:59'),
(9, 'Clearance', 30.00, '2023-07-01 00:00:00', '2023-07-31 23:59:59'),
(11, 'Battery Promotion', 15.00, '2023-09-01 00:00:00', '2023-09-30 23:59:59');

-- Insert sample orders
INSERT INTO Orders (user_id, customer_id, order_number, status, total_amount, tax_amount, shipping_amount, payment_method, payment_status) VALUES
(1, 1, 'ORD-10001', 'Delivered', 1299.99, 104.00, 0.00, 'Credit Card', 'Paid'),
(2, 2, 'ORD-10002', 'Processing', 2199.98, 176.00, 15.00, 'Debit Card', 'Paid'),
(3, 3, 'ORD-10003', 'Pending', 499.99, 40.00, 0.00, 'Credit Card', 'Pending'),
(4, 4, 'ORD-10004', 'Shipped', 179.94, 14.40, 5.00, 'Bank Transfer', 'Paid'),
(5, 5, 'ORD-10005', 'Cancelled', 699.99, 56.00, 0.00, 'Credit Card', 'Refunded');

-- Insert sample order items
INSERT INTO OrderItems (order_id, product_id, quantity, price, discount_amount) VALUES
(1, 1, 1, 1299.99, 0.00),
(2, 2, 2, 1099.99, 0.00),
(3, 5, 1, 499.99, 0.00),
(4, 9, 3, 19.99, 0.00),
(4, 10, 2, 49.99, 0.00),
(5, 7, 1, 699.99, 0.00);

-- Insert sample stock transactions
INSERT INTO StockTransactions (product_id, transaction_type, quantity, reference_id, reference_type, user_id) VALUES
(1, 'IN', 100, 'PO-1001', 'PURCHASE', 1),
(2, 'IN', 50, 'PO-1001', 'PURCHASE', 1),
(3, 'IN', 30, 'PO-1002', 'PURCHASE', 2),
(4, 'IN', 20, 'PO-1002', 'PURCHASE', 2),
(5, 'IN', 50, 'PO-1003', 'PURCHASE', 3),
(6, 'IN', 150, 'PO-1004', 'PURCHASE', 1),
(7, 'IN', 100, 'PO-1004', 'PURCHASE', 1),
(8, 'IN', 50, 'PO-1005', 'PURCHASE', 2),
(9, 'IN', 300, 'PO-1006', 'PURCHASE', 3),
(10, 'IN', 200, 'PO-1006', 'PURCHASE', 3),
(11, 'IN', 100, 'PO-1007', 'PURCHASE', 1),
(1, 'OUT', 1, 'ORD-10001', 'ORDER', 1),
(2, 'OUT', 2, 'ORD-10002', 'ORDER', 2),
(5, 'OUT', 1, 'ORD-10003', 'ORDER', 3),
(9, 'OUT', 3, 'ORD-10004', 'ORDER', 4),
(10, 'OUT', 2, 'ORD-10004', 'ORDER', 4),
(7, 'OUT', 1, 'ORD-10005', 'ORDER', 5);

-- Insert sample audit logs
INSERT INTO AuditLog (user_id, action_type, table_name, record_id, action_details, ip_address) VALUES
(1, 'CREATE', 'Products', 1, '{"name": "Laptop Pro 15", "price": 1299.99}', '192.168.1.100'),
(1, 'CREATE', 'Orders', 1, '{"customer_id": 1, "total_amount": 1299.99}', '192.168.1.100'),
(2, 'UPDATE', 'Products', 2, '{"price": "1099.99"}', '192.168.1.101'),
(3, 'CREATE', 'OrderItems', 3, '{"order_id": 3, "product_id": 5}', '192.168.1.102'),
(4, 'DELETE', 'Discounts', 4, '{"discount_name": "Clearance"}', '192.168.1.103');

-- Part 3: Large Dataset Generation (100,000+ records)
-- This procedure will generate large datasets for testing and performance evaluation
DELIMITER //

CREATE PROCEDURE GenerateLargeDataset()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT;
    DECLARE num_categories INT;
    DECLARE num_suppliers INT;
    DECLARE num_customers INT;
    DECLARE num_users INT;
    DECLARE product_category INT;
    DECLARE product_supplier INT;
    DECLARE order_customer INT;
    DECLARE order_user INT;
    DECLARE order_status VARCHAR(20);
    DECLARE payment_status VARCHAR(20);
    
    -- Get counts of existing records
    SELECT COUNT(*) INTO num_categories FROM Categories;
    SELECT COUNT(*) INTO num_suppliers FROM Suppliers;
    SELECT COUNT(*) INTO num_customers FROM Customers;
    SELECT COUNT(*) INTO num_users FROM Users;
    
    -- Generate 100,000 products
    WHILE i <= 100000 DO
        -- Randomly select category and supplier
        SET product_category = 1 + FLOOR(RAND() * num_categories);
        SET product_supplier = 1 + FLOOR(RAND() * num_suppliers);
        
        INSERT INTO Products (
            name, 
            description, 
            sku, 
            category_id, 
            supplier_id, 
            stock_quantity, 
            price, 
            cost_price, 
            reorder_level, 
            warranty_period
        ) VALUES (
            CONCAT('Product ', i),
            CONCAT('Description for product ', i),
            CONCAT('SKU-', i),
            product_category,
            product_supplier,
            FLOOR(10 + (RAND() * 500)),
            ROUND(10 + (RAND() * 1000), 2),
            ROUND(5 + (RAND() * 800), 2),
            FLOOR(5 + (RAND() * 20)),
            FLOOR(6 + (RAND() * 36))
        );
        
        -- Insert initial stock transaction
        INSERT INTO StockTransactions (
            product_id,
            transaction_type,
            quantity,
            reference_id,
            reference_type,
            user_id
        ) VALUES (
            LAST_INSERT_ID(),
            'IN',
            FLOOR(10 + (RAND() * 500)),
            CONCAT('PO-', i),
            'PURCHASE',
            1 + FLOOR(RAND() * num_users)
        );
        
        SET i = i + 1;
    END WHILE;
    
    -- Generate 50,000 customers
    SET i = 6; -- Start after existing customers
    WHILE i <= 50000 DO
        INSERT INTO Customers (
            name,
            contact,
            email,
            phone,
            address,
            city,
            country,
            postal_code,
            loyalty_points
        ) VALUES (
            CONCAT('Customer ', i),
            CONCAT('Contact ', i),
            CONCAT('customer', i, '@example.com'),
            CONCAT('555', FLOOR(1000000 + RAND() * 9000000)),
            CONCAT(i, ' Main St'),
            CASE FLOOR(1 + RAND() * 10)
                WHEN 1 THEN 'New York'
                WHEN 2 THEN 'Los Angeles'
                WHEN 3 THEN 'Chicago'
                WHEN 4 THEN 'Houston'
                WHEN 5 THEN 'Phoenix'
                WHEN 6 THEN 'Philadelphia'
                WHEN 7 THEN 'San Antonio'
                WHEN 8 THEN 'San Diego'
                WHEN 9 THEN 'Dallas'
                WHEN 10 THEN 'San Jose'
            END,
            'USA',
            CONCAT(FLOOR(10000 + RAND() * 90000)),
            FLOOR(RAND() * 1000)
        );
        
        SET i = i + 1;
    END WHILE;
    
    -- Generate 10,000 orders with order items
    SET i = 6; -- Start after existing orders
    WHILE i <= 10000 DO
        -- Randomly select customer and user
        SET order_customer = 1 + FLOOR(RAND() * num_customers);
        SET order_user = 1 + FLOOR(RAND() * num_users);
        
        -- Randomly select order status
        SET order_status = CASE FLOOR(1 + RAND() * 6)
            WHEN 1 THEN 'Pending'
            WHEN 2 THEN 'Processing'
            WHEN 3 THEN 'Shipped'
            WHEN 4 THEN 'Delivered'
            WHEN 5 THEN 'Cancelled'
            WHEN 6 THEN 'Refunded'
        END;
        
        -- Randomly select payment status based on order status
        IF order_status IN ('Delivered', 'Shipped') THEN
            SET payment_status = 'Paid';
        ELSEIF order_status = 'Cancelled' THEN
            SET payment_status = CASE WHEN RAND() > 0.5 THEN 'Refunded' ELSE 'Failed' END;
        ELSE
            SET payment_status = CASE WHEN RAND() > 0.7 THEN 'Paid' ELSE 'Pending' END;
        END IF;
        
        -- Insert order
        INSERT INTO Orders (
            user_id,
            customer_id,
            order_number,
            status,
            total_amount,
            tax_amount,
            shipping_amount,
            payment_method,
            payment_status
        ) VALUES (
            order_user,
            order_customer,
            CONCAT('ORD-', 10000 + i),
            order_status,
            0, -- Will be updated by triggers
            ROUND(RAND() * 50, 2),
            CASE WHEN RAND() > 0.5 THEN ROUND(RAND() * 20, 2) ELSE 0 END,
            CASE FLOOR(1 + RAND() * 5)
                WHEN 1 THEN 'Cash'
                WHEN 2 THEN 'Credit Card'
                WHEN 3 THEN 'Debit Card'
                WHEN 4 THEN 'Bank Transfer'
                WHEN 5 THEN 'Other'
            END,
            payment_status
        );
        
        -- Generate 1-5 order items per order
        SET j = 1;
        WHILE j <= FLOOR(1 + RAND() * 5) DO
            -- Get random product that has stock
            SET @product_id = 0;
            SELECT product_id INTO @product_id FROM Products 
            WHERE stock_quantity > 0 
            ORDER BY RAND() 
            LIMIT 1;
            
            IF @product_id > 0 THEN
                -- Get product price
                SET @product_price = 0;
                SELECT price INTO @product_price FROM Products WHERE product_id = @product_id;
                
                -- Random discount (10% chance)
                SET @discount_amount = 0;
                IF RAND() > 0.9 THEN
                    SET @discount_amount = ROUND(@product_price * (RAND() * 0.3), 2); -- Up to 30% discount
                END IF;
                
                -- Random quantity (1-3)
                SET @quantity = FLOOR(1 + RAND() * 3);
                
                -- Insert order item
                INSERT INTO OrderItems (
                    order_id,
                    product_id,
                    quantity,
                    price,
                    discount_amount
                ) VALUES (
                    LAST_INSERT_ID(),
                    @product_id,
                    @quantity,
                    @product_price,
                    @discount_amount
                );
                
                -- Update stock
                UPDATE Products SET stock_quantity = stock_quantity - @quantity WHERE product_id = @product_id;
                
                -- Record stock transaction
                INSERT INTO StockTransactions (
                    product_id,
                    transaction_type,
                    quantity,
                    reference_id,
                    reference_type,
                    user_id
                ) VALUES (
                    @product_id,
                    'OUT',
                    @quantity,
                    CONCAT('ORD-', 10000 + i),
                    'ORDER',
                    order_user
                );
            END IF;
            
            SET j = j + 1;
        END WHILE;
        
        -- Update order total (handled by triggers in a real implementation)
        UPDATE Orders o
        JOIN (
            SELECT order_id, SUM(total_price) AS order_total
            FROM OrderItems
            WHERE order_id = LAST_INSERT_ID()
            GROUP BY order_id
        ) oi ON o.order_id = oi.order_id
        SET o.total_amount = oi.order_total + o.tax_amount + o.shipping_amount
        WHERE o.order_id = LAST_INSERT_ID();
        
        SET i = i + 1;
    END WHILE;
    
    -- Generate 100,000 stock transactions (additional to those already created)
    SET i = 1;
    WHILE i <= 100000 DO
        -- Get random product
        SET @product_id = 1 + FLOOR(RAND() * 100000);
        
        -- Random transaction type (weighted more towards IN)
        SET @transaction_type = CASE WHEN RAND() > 0.3 THEN 'IN' 
                                    ELSE CASE FLOOR(1 + RAND() * 3)
                                        WHEN 1 THEN 'OUT'
                                        WHEN 2 THEN 'ADJUSTMENT'
                                        WHEN 3 THEN 'RETURN'
                                    END
                                END;
        
        -- Random quantity
        SET @quantity = FLOOR(1 + RAND() * 100);
        
        -- Insert transaction
        INSERT INTO StockTransactions (
            product_id,
            transaction_type,
            quantity,
            reference_id,
            reference_type,
            user_id
        ) VALUES (
            @product_id,
            @transaction_type,
            @quantity,
            CASE 
                WHEN @transaction_type = 'IN' THEN CONCAT('PO-', 100000 + i)
                WHEN @transaction_type = 'OUT' THEN CONCAT('SO-', 100000 + i)
                ELSE NULL
            END,
            CASE 
                WHEN @transaction_type = 'IN' THEN 'PURCHASE'
                WHEN @transaction_type = 'OUT' THEN 'SALE'
                ELSE 'ADJUSTMENT'
            END,
            1 + FLOOR(RAND() * num_users)
        );
        
        -- Update product stock (simplified - in reality would need more complex logic)
        IF @transaction_type = 'IN' THEN
            UPDATE Products SET stock_quantity = stock_quantity + @quantity WHERE product_id = @product_id;
        ELSEIF @transaction_type = 'OUT' THEN
            UPDATE Products SET stock_quantity = GREATEST(0, stock_quantity - @quantity) WHERE product_id = @product_id;
        END IF;
        
        SET i = i + 1;
    END WHILE;
    
    -- Generate 50,000 audit log entries
    SET i = 6; -- Start after existing audit logs
    WHILE i <= 50000 DO
        SET @user_id = 1 + FLOOR(RAND() * num_users);
        SET @action_type = CASE FLOOR(1 + RAND() * 4)
            WHEN 1 THEN 'CREATE'
            WHEN 2 THEN 'READ'
            WHEN 3 THEN 'UPDATE'
            WHEN 4 THEN 'DELETE'
        END;
        
        SET @table_name = CASE FLOOR(1 + RAND() * 10)
            WHEN 1 THEN 'Products'
            WHEN 2 THEN 'Orders'
            WHEN 3 THEN 'Customers'
            WHEN 4 THEN 'Suppliers'
            WHEN 5 THEN 'Categories'
            WHEN 6 THEN 'OrderItems'
            WHEN 7 THEN 'Discounts'
            WHEN 8 THEN 'StockTransactions'
            WHEN 9 THEN 'Users'
            WHEN 10 THEN 'AuditLog'
        END;
        
        -- Insert audit log
        INSERT INTO AuditLog (
            user_id,
            action_type,
            table_name,
            record_id,
            action_details,
            ip_address
        ) VALUES (
            @user_id,
            @action_type,
            @table_name,
            CASE WHEN @table_name = 'Products' THEN 1 + FLOOR(RAND() * 100000)
                 WHEN @table_name = 'Orders' THEN 1 + FLOOR(RAND() * 10000)
                 WHEN @table_name = 'Customers' THEN 1 + FLOOR(RAND() * 50000)
                 WHEN @table_name = 'Suppliers' THEN 1 + FLOOR(RAND() * 5)
                 WHEN @table_name = 'Categories' THEN 1 + FLOOR(RAND() * 12)
                 WHEN @table_name = 'OrderItems' THEN 1 + FLOOR(RAND() * 30000)
                 WHEN @table_name = 'Discounts' THEN 1 + FLOOR(RAND() * 5)
                 WHEN @table_name = 'StockTransactions' THEN 1 + FLOOR(RAND() * 100000)
                 WHEN @table_name = 'Users' THEN 1 + FLOOR(RAND() * 5)
                 ELSE 1 + FLOOR(RAND() * 50000)
            END,
            JSON_OBJECT('detail', CONCAT('Sample action ', i)),
            CONCAT('192.168.', FLOOR(RAND() * 256), '.', FLOOR(RAND() * 256))
        );
        
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- Execute the large dataset generation (commented out for safety - uncomment to run)
-- CALL GenerateLargeDataset();

-- Optimize tables after large data inserts
OPTIMIZE TABLE Users;
OPTIMIZE TABLE Suppliers;
OPTIMIZE TABLE Customers;
OPTIMIZE TABLE Categories;
OPTIMIZE TABLE Products;
OPTIMIZE TABLE Discounts;
OPTIMIZE TABLE Orders;
OPTIMIZE TABLE OrderItems;
OPTIMIZE TABLE StockTransactions;
OPTIMIZE TABLE AuditLog;

-- Create indexes after data load for better performance
CREATE INDEX idx_products_price ON Products(price);
CREATE INDEX idx_products_stock ON Products(stock_quantity);
CREATE INDEX idx_orders_total ON Orders(total_amount);
CREATE INDEX idx_orders_date_status ON Orders(order_date, status);
CREATE INDEX idx_stocktrans_product_date ON StockTransactions(product_id, transaction_date);
CREATE INDEX idx_orderitems_product ON OrderItems(product_id);
CREATE INDEX idx_auditlog_timestamp ON AuditLog(timestamp);

-- Create views for common queries
CREATE VIEW ProductInventoryView AS
SELECT 
    p.product_id,
    p.name AS product_name,
    c.category_name,
    s.name AS supplier_name,
    p.stock_quantity,
    p.price,
    p.reorder_level,
    CASE WHEN p.stock_quantity <= p.reorder_level THEN 'Reorder Needed' ELSE 'OK' END AS stock_status
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
JOIN Suppliers s ON p.supplier_id = s.supplier_id;

CREATE VIEW SalesReportView AS
SELECT 
    o.order_id,
    o.order_number,
    o.order_date,
    c.name AS customer_name,
    u.username AS staff_username,
    o.status,
    o.total_amount,
    o.payment_method,
    o.payment_status,
    COUNT(oi.order_item_id) AS item_count
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
LEFT JOIN Users u ON o.user_id = u.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

CREATE VIEW LowStockView AS
SELECT 
    product_id,
    name,
    stock_quantity,
    reorder_level,
    supplier_id,
    (SELECT name FROM Suppliers WHERE supplier_id = p.supplier_id) AS supplier_name
FROM Products p
WHERE stock_quantity <= reorder_level;

-- Create triggers for business logic
DELIMITER //

CREATE TRIGGER after_order_insert
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    -- Update product stock
    UPDATE Products 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    -- Record stock transaction
    INSERT INTO StockTransactions (
        product_id,
        transaction_type,
        quantity,
        reference_id,
        reference_type,
        user_id
    ) VALUES (
        NEW.product_id,
        'OUT',
        NEW.quantity,
        (SELECT order_number FROM Orders WHERE order_id = NEW.order_id),
        'ORDER',
        (SELECT user_id FROM Orders WHERE order_id = NEW.order_id)
    );
END //

DELIMITER //

CREATE TRIGGER after_order_update
AFTER UPDATE ON OrderItems
FOR EACH ROW
BEGIN
    -- If quantity changed, adjust stock
    IF NEW.quantity != OLD.quantity THEN
        UPDATE Products 
        SET stock_quantity = stock_quantity + OLD.quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
        
        -- Update stock transaction
        UPDATE StockTransactions
        SET quantity = NEW.quantity
        WHERE reference_id = (SELECT order_number FROM Orders WHERE order_id = NEW.order_id)
        AND product_id = NEW.product_id
        AND transaction_type = 'OUT';
    END IF;
END //

DELIMITER ;

-- [All your existing code...]
-- [All CREATE TABLE statements...]
-- [All INSERT statements...]
-- [All other procedures/triggers...]

-- ===== ADD THESE LAST =====
-- Ensure this is the VERY LAST PART of your script

DELIMITER //

-- 1. First drop existing triggers/event if they exist
DROP TRIGGER IF EXISTS before_discount_insert//
DROP TRIGGER IF EXISTS before_discount_update//
DROP EVENT IF EXISTS update_discount_status//

-- 2. Create the triggers
CREATE TRIGGER before_discount_insert
BEFORE INSERT ON Discounts
FOR EACH ROW
BEGIN
    SET NEW.is_active = (NEW.start_date <= NOW() AND NEW.end_date >= NOW());
END//

CREATE TRIGGER before_discount_update
BEFORE UPDATE ON Discounts
FOR EACH ROW
BEGIN
    SET NEW.is_active = (NEW.start_date <= NOW() AND NEW.end_date >= NOW());
END//

-- 3. Create the event
CREATE EVENT update_discount_status
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    UPDATE Discounts 
    SET is_active = (start_date <= NOW() AND end_date >= NOW());
END//

DELIMITER ;

-- Optional: Immediate test
INSERT INTO Discounts (product_id, discount_name, discount_percentage, start_date, end_date)
VALUES (1, 'Test Discount', 10.00, NOW(), NOW() + INTERVAL 1 DAY);

SELECT CONCAT('Discount active status: ', is_active) AS test_result 
FROM Discounts 
WHERE discount_id = LAST_INSERT_ID();
-- Should return "Discount active status: 1"

SET GLOBAL event_scheduler = ON;


-- week 12 
-- Query 1: Monthly Sales Revenue by Product Category
SELECT 
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    c.category_name,
    SUM(oi.total_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
WHERE o.status NOT IN ('Cancelled', 'Refunded')
GROUP BY YEAR(o.order_date), MONTH(o.order_date), c.category_name
ORDER BY year, month, total_sales DESC;

-- Query 2: Customer Lifetime Value Analysis
SELECT 
    c.customer_id,
    c.name,
    c.city,
    c.loyalty_points,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    DATEDIFF(CURRENT_DATE, MIN(o.order_date)) AS days_as_customer,
SUM(o.total_amount) / (DATEDIFF(CURRENT_DATE, MIN(o.order_date)) / 365) AS clv
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.status NOT IN ('Cancelled', 'Refunded')
GROUP BY c.customer_id, c.name, c.city, c.loyalty_points
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY clv DESC
LIMIT 100;

-- Query 3: Inventory Turnover Analysis
SELECT 
    p.product_id,
    p.name,
    c.category_name,
    p.stock_quantity,
    SUM(CASE WHEN st.transaction_type = 'OUT' THEN st.quantity ELSE 0 END) AS units_sold_last_90_days,
    p.stock_quantity / NULLIF(SUM(CASE WHEN st.transaction_type = 'OUT' THEN st.quantity ELSE 0 END), 0) * 90 AS days_of_inventory,
    (SUM(CASE WHEN st.transaction_type = 'OUT' THEN st.quantity ELSE 0 END) / 3) / NULLIF(p.stock_quantity, 0) AS monthly_turnover_rate
FROM Products p
JOIN StockTransactions st ON p.product_id = st.product_id
JOIN Categories c ON p.category_id = c.category_id
WHERE st.transaction_date >= DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY)
GROUP BY p.product_id, p.name, c.category_name, p.stock_quantity
HAVING units_sold_last_90_days > 0
ORDER BY days_of_inventory DESC;

-- Query 4: Discount Effectiveness Analysis
SELECT 
    d.discount_id,
    d.discount_name,
    p.name AS product_name,
    d.discount_percentage,
    COUNT(oi.order_item_id) AS discounted_units_sold,
    SUM(oi.total_price) AS total_revenue,
    SUM(oi.quantity * (oi.price - p.cost_price - (oi.price * d.discount_percentage / 100))) AS gross_profit,
    AVG(oi.quantity * (oi.price - p.cost_price - (oi.price * d.discount_percentage / 100))) AS profit_per_unit,
    COUNT(oi.order_item_id) / DATEDIFF(d.end_date, d.start_date) AS daily_sales_rate
FROM Discounts d
JOIN Products p ON d.product_id = p.product_id
LEFT JOIN OrderItems oi ON p.product_id = oi.product_id 
    AND oi.order_id IN (
        SELECT order_id FROM Orders 
        WHERE order_date BETWEEN d.start_date AND d.end_date
        AND status NOT IN ('Cancelled', 'Refunded')
    )
WHERE d.is_active = FALSE -- Only completed discounts
GROUP BY d.discount_id, d.discount_name, p.name, d.discount_percentage
ORDER BY gross_profit DESC;

-- Query 5: Supplier Performance Dashboard
SELECT 
    s.supplier_id,
    s.name AS supplier_name,
    s.city,
    COUNT(DISTINCT p.product_id) AS products_supplied,
    SUM(st_in.quantity) AS total_units_supplied,
    SUM(st_in.quantity * p.cost_price) AS total_inventory_value,
    AVG(p.price - p.cost_price) AS avg_margin,
    COUNT(DISTINCT oi.order_item_id) AS units_sold,
    SUM(oi.total_price) AS sales_revenue,
    SUM(oi.total_price) / SUM(st_in.quantity * p.cost_price) AS inventory_turnover_ratio
FROM Suppliers s
JOIN Products p ON s.supplier_id = p.supplier_id
JOIN StockTransactions st_in ON p.product_id = st_in.product_id AND st_in.transaction_type = 'IN'
LEFT JOIN OrderItems oi ON p.product_id = oi.product_id
LEFT JOIN Orders o ON oi.order_id = o.order_id AND o.status NOT IN ('Cancelled', 'Refunded')
GROUP BY s.supplier_id, s.name, s.city
ORDER BY sales_revenue DESC;

-- Create the dimensional model
DROP SCHEMA IF EXISTS inventory_dw;
CREATE SCHEMA inventory_dw;
USE inventory_dw;

-- Dimension: Time
CREATE TABLE dim_time (
    time_id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    day TINYINT NOT NULL,
    month TINYINT NOT NULL,
    quarter TINYINT NOT NULL,
    year SMALLINT NOT NULL,
    day_of_week TINYINT NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    UNIQUE KEY (date)
);

-- Dimension: Product
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    category_id INT NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    parent_category_name VARCHAR(100),
    supplier_id INT NOT NULL,
    supplier_name VARCHAR(100) NOT NULL,
    current_price DECIMAL(10,2) NOT NULL,
    current_cost DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN NOT NULL
);

-- Dimension: Customer
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    loyalty_points INT NOT NULL,
    customer_since DATE NOT NULL
);

-- Dimension: Location
CREATE TABLE dim_location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50)
);

-- Fact table: Sales
CREATE TABLE fact_sales (
    sales_id INT AUTO_INCREMENT PRIMARY KEY,
    time_id INT NOT NULL,
    product_id INT NOT NULL,
    customer_id INT,
    location_id INT,
    order_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    cost_amount DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    INDEX idx_fact_sales_time (time_id),
    INDEX idx_fact_sales_product (product_id),
    INDEX idx_fact_sales_customer (customer_id),
    INDEX idx_fact_sales_location (location_id)
);

-- Populate dimension tables from operational database
-- Populate time dimension (for dates in the order system)
INSERT INTO dim_time (date, day, month, quarter, year, day_of_week, day_name, month_name, is_weekend)
SELECT 
    DISTINCT DATE(order_date) AS date,
    DAY(order_date) AS day,
    MONTH(order_date) AS month,
    QUARTER(order_date) AS quarter,
    YEAR(order_date) AS year,
    DAYOFWEEK(order_date) AS day_of_week,
    DAYNAME(order_date) AS day_name,
    MONTHNAME(order_date) AS month_name,
    DAYOFWEEK(order_date) IN (1,7) AS is_weekend
FROM InventoryDB.Orders
WHERE order_date IS NOT NULL;

-- Populate product dimension
INSERT INTO dim_product
SELECT 
    p.product_id,
    p.name AS product_name,
    p.sku,
    c.category_id,
    c.category_name,
    c.parent_category_id,
    pc.category_name AS parent_category_name,
    s.supplier_id,
    s.name AS supplier_name,
    p.price AS current_price,
    p.cost_price AS current_cost,
    p.is_active
FROM InventoryDB.Products p
JOIN InventoryDB.Categories c ON p.category_id = c.category_id
LEFT JOIN InventoryDB.Categories pc ON c.parent_category_id = pc.category_id
JOIN InventoryDB.Suppliers s ON p.supplier_id = s.supplier_id;

-- Populate customer dimension
INSERT INTO dim_customer
SELECT 
    customer_id,
    name AS customer_name,
    contact,
    city,
    country,
    loyalty_points,
    DATE(created_at) AS customer_since
FROM InventoryDB.Customers;

-- Populate location dimension
INSERT INTO dim_location (city, country, region)
SELECT 
    DISTINCT 
    city,
    country,
    CASE 
        WHEN country != 'USA' THEN 'International'
        WHEN city IN ('New York', 'Boston', 'Philadelphia') THEN 'Northeast'
        WHEN city IN ('Chicago', 'Houston', 'Dallas') THEN 'Midwest/South'
        WHEN city IN ('Los Angeles', 'San Francisco', 'San Diego', 'Seattle') THEN 'West'
        ELSE 'Other US'
    END AS region
FROM InventoryDB.Customers;

-- Populate fact table
INSERT INTO fact_sales (
    time_id, product_id, customer_id, location_id, order_id, 
    quantity, unit_price, discount_amount, total_amount, cost_amount, profit
)
SELECT 
    dt.time_id,
    dp.product_id,
    dc.customer_id,
    dl.location_id,
    o.order_id,
    oi.quantity,
    oi.price AS unit_price,
    oi.discount_amount,
    oi.total_price AS total_amount,
    (oi.quantity * dp.current_cost) AS cost_amount,
    (oi.total_price - (oi.quantity * dp.current_cost)) AS profit
FROM InventoryDB.OrderItems oi
JOIN InventoryDB.Orders o ON oi.order_id = o.order_id
JOIN dim_time dt ON DATE(o.order_date) = dt.date
JOIN dim_product dp ON oi.product_id = dp.product_id
LEFT JOIN dim_customer dc ON o.customer_id = dc.customer_id
LEFT JOIN dim_location dl ON dc.city = dl.city AND dc.country = dl.country
WHERE o.status NOT IN ('Cancelled', 'Refunded');

-- Create a materialized view for monthly sales performance
CREATE VIEW monthly_sales_performance AS
SELECT 
    t.year,
    t.month,
    t.month_name,
    p.category_name,
    COUNT(DISTINCT f.order_id) AS order_count,
    SUM(f.quantity) AS units_sold,
    SUM(f.total_amount) AS gross_sales,
    SUM(f.discount_amount) AS total_discounts,
    SUM(f.total_amount) - SUM(f.discount_amount) AS net_sales,
    SUM(f.profit) AS gross_profit,
    SUM(f.profit) / NULLIF(SUM(f.total_amount), 0) AS profit_margin
FROM fact_sales f
JOIN dim_time t ON f.time_id = t.time_id
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY t.year, t.month, t.month_name, p.category_name
ORDER BY t.year, t.month, p.category_name;

-- Create a materialized view for customer segmentation
CREATE VIEW customer_segmentation AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.country,
    l.region,
    COUNT(DISTINCT f.order_id) AS order_count,
    SUM(f.total_amount) AS total_spent,
    AVG(f.total_amount) AS avg_order_value,
    DATEDIFF(CURRENT_DATE, MIN(t.date)) AS days_as_customer,
    SUM(f.total_amount) / (DATEDIFF(CURRENT_DATE, MIN(t.date)) / 365) AS annual_spend,
    NTILE(5) OVER (ORDER BY SUM(f.total_amount) DESC) AS spending_segment,
    NTILE(5) OVER (ORDER BY COUNT(DISTINCT f.order_id) DESC) AS frequency_segment
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_time t ON f.time_id = t.time_id
JOIN dim_location l ON c.city = l.city AND c.country = l.country
GROUP BY c.customer_id, c.customer_name, c.city, c.country, l.region;
