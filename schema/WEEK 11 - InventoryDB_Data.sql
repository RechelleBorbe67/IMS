-- InventoryDB_Data.sql
-- Users (exact match to your schema)
INSERT INTO Users (username, password, role) VALUES
('admin1', '$2a$10$xJwL5v5Jz5U', 'admin'),
('manager1', '$2a$10$xJwL5v5Jz5U', 'manager'),
('staff1', '$2a$10$xJwL5v5Jz5U', 'staff');

-- Suppliers (matches your table structure)
INSERT INTO Suppliers (name, contact, address) VALUES
('Tech Supplies Inc.', '1234567890', '123 Tech St, City A'),
('Gadget World', '0987654321', '456 Gadget Ave, City B');

-- Customers (exact field match)
INSERT INTO Customers (name, contact, address) VALUES
('Charlie', '1112223333', '789 Customer Rd, City C'),
('River', '4445556666', '101 Customer St, City D');

-- Categories (minimal required data)
INSERT INTO Categories (category_name) VALUES
('Laptops'),
('Smartphones'),
('Accessories');

-- Products (fully compatible with your schema)
INSERT INTO Products (
  name, 
  description, 
  category_id, 
  supplier_id, 
  stock_quantity, 
  price, 
  reorder_level, 
  warranty_period
) VALUES
(
  'Laptop Pro 15', 
  'High-performance laptop', 
  (SELECT category_id FROM Categories WHERE category_name='Laptops'), 
  (SELECT supplier_id FROM Suppliers WHERE name LIKE 'Tech%'), 
  20, 
  1200.00, 
  5, 
  24
),
(
  'Smartphone X', 
  'Latest smartphone model', 
  (SELECT category_id FROM Categories WHERE category_name='Smartphones'), 
  (SELECT supplier_id FROM Suppliers WHERE name LIKE 'Gadget%'), 
  30, 
  800.00, 
  3, 
  12
);

-- Orders (100% schema-compliant)
INSERT INTO Orders (
  user_id, 
  customer_id, 
  order_date, 
  status
) VALUES
(
  (SELECT user_id FROM Users WHERE username='admin1'), 
  (SELECT customer_id FROM Customers WHERE name='Charlie'), 
  NOW(), 
  'Completed'
),
(
  (SELECT user_id FROM Users WHERE username='manager1'), 
  (SELECT customer_id FROM Customers WHERE name='River'), 
  NOW(), 
  'Pending'
);

-- OrderItems (linked correctly)
INSERT INTO OrderItems (
  order_id, 
  product_id, 
  quantity, 
  price
) VALUES
(
  (SELECT order_id FROM Orders WHERE status='Completed'), 
  (SELECT product_id FROM Products WHERE name LIKE 'Laptop%'), 
  1, 
  1200.00
),
(
  (SELECT order_id FROM Orders WHERE status='Pending'), 
  (SELECT product_id FROM Products WHERE name LIKE 'Smartphone%'), 
  2, 
  800.00
);

-- StockTransactions (matching your enum types)
INSERT INTO StockTransactions (
  product_id, 
  transaction_type, 
  quantity
) VALUES
(
  (SELECT product_id FROM Products WHERE name LIKE 'Laptop%'), 
  'IN', 
  50
),
(
  (SELECT product_id FROM Products WHERE name LIKE 'Smartphone%'), 
  'IN', 
  100
);

-- AuditLog (minimal sample)
INSERT INTO AuditLog (user_id, action) VALUES
((SELECT user_id FROM Users WHERE username='admin1'), 'Added sample data'),
((SELECT user_id FROM Users WHERE username='staff1'), 'Performed test import');