-- DROP TABLE IF EXISTS order_items CASCADE;
-- DROP TABLE IF EXISTS orders CASCADE;
-- DROP TABLE IF EXISTS stocks CASCADE;
-- DROP TABLE IF EXISTS staffs CASCADE;
-- DROP TABLE IF EXISTS customers CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS categories CASCADE;
-- DROP TABLE IF EXISTS brands CASCADE;
-- DROP TABLE IF EXISTS stores CASCADE;

-- -- CREATE TABLES WITH RELATIONSHIPS

-- CREATE TABLE stores (
--     store_id INT PRIMARY KEY,
--     store_name VARCHAR(255) NOT NULL,
--     phone VARCHAR(25),
--     email VARCHAR(255),
--     street VARCHAR(255),
--     city VARCHAR(255),
--     state VARCHAR(10),
--     zip_code VARCHAR(5)
-- );

-- CREATE TABLE brands (
--     brand_id INT PRIMARY KEY,
--     brand_name VARCHAR(255) NOT NULL
-- );

-- CREATE TABLE categories (
--     category_id INT PRIMARY KEY,
--     category_name VARCHAR(255) NOT NULL
-- );

-- CREATE TABLE products (
--     product_id INT PRIMARY KEY,
--     product_name VARCHAR(255) NOT NULL,
--     brand_id INT REFERENCES brands(brand_id),
--     category_id INT REFERENCES categories(category_id),
--     model_year SMALLINT NOT NULL,
--     list_price NUMERIC(10,2) NOT NULL
-- );

-- CREATE TABLE customers (
--     customer_id INT PRIMARY KEY,
--     first_name VARCHAR(255) NOT NULL,
--     last_name VARCHAR(255) NOT NULL,
--     phone VARCHAR(25),
--     email VARCHAR(255) NOT NULL,
--     street VARCHAR(255),
--     city VARCHAR(50),
--     state VARCHAR(25),
--     zip_code VARCHAR(5)
-- );

-- CREATE TABLE staffs (
--     staff_id INT PRIMARY KEY,
--     first_name VARCHAR(50) NOT NULL,
--     last_name VARCHAR(50) NOT NULL,
--     email VARCHAR(255) NOT NULL,
--     phone VARCHAR(25),
--     active BOOLEAN NOT NULL DEFAULT TRUE,
--     store_id INT REFERENCES stores(store_id),
--     manager_id INT REFERENCES staffs(staff_id)
-- );

-- CREATE TABLE orders (
--     order_id INT PRIMARY KEY,
--     customer_id INT REFERENCES customers(customer_id),
--     order_status SMALLINT NOT NULL,
--     order_date DATE NOT NULL,
--     required_date DATE NOT NULL,
--     shipped_date DATE,
--     store_id INT REFERENCES stores(store_id),
--     staff_id INT REFERENCES staffs(staff_id)
-- );

-- CREATE TABLE order_items (
--     order_id INT REFERENCES orders(order_id),
--     item_id INT,
--     product_id INT REFERENCES products(product_id),
--     quantity INT NOT NULL,
--     list_price NUMERIC(10,2) NOT NULL,
--     discount NUMERIC(4,2) NOT NULL DEFAULT 0,
--     PRIMARY KEY (order_id, item_id)
-- );

-- CREATE TABLE stocks (
--     store_id INT REFERENCES stores(store_id),
--     product_id INT REFERENCES products(product_id),
--     quantity INT,
--     PRIMARY KEY (store_id, product_id)
-- );

-- -- DATA IMPORT

-- COPY stores FROM 'C:/temp/stores.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY brands FROM 'C:/temp/brands.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY categories FROM 'C:/temp/categories.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY products FROM 'C:/temp/products.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY customers FROM 'C:/temp/customers.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY staffs FROM 'C:/temp/staffs.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY orders FROM 'C:/temp/orders.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY order_items FROM 'C:/temp/order_items.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');
-- COPY stocks FROM 'C:/temp/stocks.csv' WITH (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL');

-- -- DATA VALIDATION

-- SELECT table_name, 
--        (xpath('/row/cnt/text()', query_to_xml(format('SELECT COUNT(*) AS cnt FROM %I.%I', table_schema, table_name), false, true, '')))[1]::text::bigint AS row_count
-- FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- ORDER BY table_name;

-- -- Orphan Check (must return 0)
-- SELECT COUNT(*) FROM order_items oi WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.order_id = oi.order_id);
-- SELECT COUNT(*) FROM stocks st WHERE NOT EXISTS (SELECT 1 FROM stores s WHERE s.store_id = st.store_id);

-- -- CORE BUSINESS INTELLIGENCE QUERIES

-- -- 1. Overall KPI Dashboard
-- SELECT 
--     'Total Revenue' AS metric, ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS value FROM order_items oi
-- UNION ALL
-- SELECT 'Total Orders', COUNT(DISTINCT order_id) FROM orders
-- UNION ALL
-- SELECT 'Total Products', COUNT(*) FROM products
-- UNION ALL
-- SELECT 'Zero Stock Items', COUNT(*) FROM stocks WHERE quantity = 0
-- UNION ALL
-- SELECT 'Unsold Products', COUNT(*) FROM products p WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id)
-- UNION ALL
-- SELECT 'Avg Order Value', ROUND(AVG(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) FROM order_items oi;

-- -- 2. Store Performance Ranking
-- SELECT 
--     s.store_name,
--     COUNT(DISTINCT o.order_id) AS total_orders,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS store_revenue,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric / NULLIF(COUNT(DISTINCT o.order_id),0), 2) AS avg_order_value
-- FROM stores s
-- JOIN orders o ON s.store_id = o.store_id
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY s.store_name
-- ORDER BY store_revenue DESC;

-- -- 3. Top 15 Products by Revenue
-- SELECT 
--     p.product_name,
--     c.category_name,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS revenue,
--     SUM(oi.quantity) AS units_sold,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric / NULLIF(SUM(oi.quantity), 0), 2) AS revenue_per_unit
-- FROM order_items oi
-- JOIN products p ON oi.product_id = p.product_id
-- JOIN categories c ON p.category_id = c.category_id
-- GROUP BY p.product_name, c.category_name
-- ORDER BY revenue DESC
-- LIMIT 15;

-- -- 4. Customer Lifetime Value (Top 10)
-- SELECT 
--     c.first_name || ' ' || c.last_name AS customer_name,
--     COUNT(DISTINCT o.order_id) AS total_orders,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS total_spent,
--     ROUND(AVG(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS avg_order_value
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY customer_name
-- ORDER BY total_spent DESC
-- LIMIT 10;

-- -- 5. Staff Efficiency Ranking
-- SELECT 
--     s.first_name || ' ' || s.last_name AS staff_name,
--     COUNT(DISTINCT o.order_id) AS orders_handled,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS revenue_generated,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric / COUNT(DISTINCT o.order_id), 2) AS revenue_per_order
-- FROM staffs s
-- JOIN orders o ON s.staff_id = o.staff_id
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY staff_name
-- ORDER BY revenue_per_order DESC;

-- -- 6. Zero Stock Replenishment Priority
-- SELECT 
--     s.store_name,
--     COUNT(*) AS zero_stock_count,
--     STRING_AGG(p.product_name, '; ') AS products_to_restock
-- FROM stocks st
-- JOIN stores s ON st.store_id = s.store_id
-- JOIN products p ON st.product_id = p.product_id
-- WHERE st.quantity = 0
-- GROUP BY s.store_name
-- ORDER BY zero_stock_count DESC;

-- -- 7. Monthly Revenue Trend
-- SELECT 
--     DATE_TRUNC('month', o.order_date) AS month,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS revenue
-- FROM orders o
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY month
-- ORDER BY month;

-- -- 8. Discount Impact Analysis
-- SELECT 
--     ROUND(discount * 100, 0) AS discount_percent,
--     COUNT(*) AS items_sold,
--     ROUND(SUM(quantity * list_price * (1 - discount))::numeric, 2) AS revenue_after_discount,
--     ROUND((SUM(quantity * list_price) - SUM(quantity * list_price * (1 - discount)))::numeric, 2) AS discount_cost
-- FROM order_items
-- GROUP BY discount_percent
-- ORDER BY discount_percent DESC;

-- -- 9. Unsold Products Summary
-- SELECT 
--     c.category_name,
--     COUNT(*) AS unsold_products,
--     ROUND(AVG(p.list_price)::numeric, 2) AS avg_list_price
-- FROM products p
-- JOIN categories c ON p.category_id = c.category_id
-- WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id)
-- GROUP BY c.category_name
-- ORDER BY unsold_products DESC;

-- --======================================
-- -- 10. Inventory & Replenishment
-- SELECT 
--     s.store_name,
--     COUNT(*) AS zero_stock_items,
--     STRING_AGG(p.product_name, '; ') AS affected_products
-- FROM stocks st
-- JOIN stores s ON st.store_id = s.store_id
-- JOIN products p ON st.product_id = p.product_id
-- WHERE st.quantity = 0
-- GROUP BY s.store_name
-- ORDER BY zero_stock_items DESC;

-- -- 11. Product Performance
-- SELECT 
--     p.product_name,
--     c.category_name,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS revenue,
--     SUM(oi.quantity) AS units_sold,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric / NULLIF(SUM(oi.quantity), 0), 2) AS revenue_per_unit
-- FROM order_items oi
-- JOIN products p ON oi.product_id = p.product_id
-- JOIN categories c ON p.category_id = c.category_id
-- GROUP BY p.product_name, c.category_name
-- ORDER BY revenue DESC
-- LIMIT 15;

-- -- 12. Customer Lifetime Value (Top 10)
-- SELECT 
--     c.first_name || ' ' || c.last_name AS customer_name,
--     COUNT(DISTINCT o.order_id) AS total_orders,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS total_spent,
--     ROUND(AVG(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS avg_order_value
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY customer_name
-- ORDER BY total_spent DESC
-- LIMIT 10;

-- -- 13. Staff Efficiency
-- SELECT 
--     s.first_name || ' ' || s.last_name AS staff_name,
--     COUNT(DISTINCT o.order_id) AS orders_handled,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS revenue_generated,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric / COUNT(DISTINCT o.order_id), 2) AS revenue_per_order
-- FROM staffs s
-- JOIN orders o ON s.staff_id = o.staff_id
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY staff_name
-- ORDER BY revenue_per_order DESC;

-- -- 14. Discount Impact
-- SELECT 
--     ROUND(discount * 100, 0) AS discount_percent,
--     COUNT(*) AS items_sold,
--     ROUND(SUM(quantity * list_price * (1 - discount))::numeric, 2) AS revenue_after_discount,
--     ROUND((SUM(quantity * list_price) - SUM(quantity * list_price * (1 - discount)))::numeric, 2) AS discount_cost
-- FROM order_items
-- GROUP BY discount_percent
-- ORDER BY discount_percent DESC;

-- -- 15. Monthly Revenue Trend
-- SELECT 
--     DATE_TRUNC('month', o.order_date) AS month,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS revenue
-- FROM orders o
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY month
-- ORDER BY month;

-- -- 16. Order Status with Revenue
-- SELECT 
--     order_status,
--     COUNT(*) AS order_count,
--     ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage,
--     ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS revenue
-- FROM orders o
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY order_status
-- ORDER BY order_count DESC;

-- -- 17. Products with Zero Sales
-- SELECT 
--     c.category_name,
--     COUNT(*) AS unsold_products,
--     ROUND(AVG(p.list_price)::numeric, 2) AS avg_list_price
-- FROM products p
-- JOIN categories c ON p.category_id = c.category_id
-- WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id)
-- GROUP BY c.category_name
-- ORDER BY unsold_products DESC;

-- Export for Power BI / Tableau / Excel
-- COPY (
--     SELECT 
--         o.order_id, o.order_date, o.order_status,
--         s.store_name, 
--         c.first_name || ' ' || c.last_name AS customer_name, c.state,
--         p.product_name, cat.category_name, b.brand_name,
--         oi.quantity, oi.list_price, oi.discount,
--         (oi.quantity * oi.list_price * (1 - oi.discount)) AS line_total,
--         st.quantity AS current_stock
--     FROM orders o
--     JOIN stores s ON o.store_id = s.store_id
--     JOIN customers c ON o.customer_id = c.customer_id
--     JOIN order_items oi ON o.order_id = oi.order_id
--     JOIN products p ON oi.product_id = p.product_id
--     JOIN categories cat ON p.category_id = cat.category_id
--     JOIN brands b ON p.brand_id = b.brand_id
--     LEFT JOIN stocks st ON st.store_id = o.store_id AND st.product_id = p.product_id
-- ) TO 'C:/temp/full_sales_data.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL 'NULL');
