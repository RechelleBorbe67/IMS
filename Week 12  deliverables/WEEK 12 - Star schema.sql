-- STAR SCHEMA FOR INVENTORY ANALYTICS
-- Creates a separate data warehouse schema (inventory_dw) 
-- Extracts and transforms data from your existing InventoryDB

-- 1. Create the dimensional model schema
DROP SCHEMA IF EXISTS inventory_dw;
CREATE SCHEMA inventory_dw;
USE inventory_dw;

-- 2. Dimension: Time
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

-- 3. Dimension: Product
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

-- 4. Dimension: Customer
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    loyalty_points INT NOT NULL,
    customer_since DATE NOT NULL
);

-- 5. Dimension: Location
CREATE TABLE dim_location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50)
);

-- 6. Fact table: Sales
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

-- 7. Populate dimensions from your existing database
-- Time dimension
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

-- Product dimension
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

-- Customer dimension
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

-- Location dimension
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

-- 8. Populate fact table
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

-- 9. Create analytical views (optional but recommended)
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