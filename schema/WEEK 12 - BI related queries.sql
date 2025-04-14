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