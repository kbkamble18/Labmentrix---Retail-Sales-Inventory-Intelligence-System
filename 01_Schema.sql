-- -- Drop any leftover tables
-- DROP TABLE IF EXISTS order_items CASCADE;
-- DROP TABLE IF EXISTS orders CASCADE;
-- DROP TABLE IF EXISTS customers CASCADE;
-- DROP TABLE IF EXISTS staffs CASCADE;
-- DROP TABLE IF EXISTS stores CASCADE;
-- DROP TABLE IF EXISTS stocks CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS categories CASCADE;
-- DROP TABLE IF EXISTS brands CASCADE;

-- -- Production tables
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
--     brand_id INT NOT NULL,
--     category_id INT NOT NULL,
--     model_year INT,
--     list_price DECIMAL(10,2) NOT NULL,
--     FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
--     FOREIGN KEY (category_id) REFERENCES categories(category_id)
-- );

-- CREATE TABLE stores (
--     store_id INT PRIMARY KEY,
--     store_name VARCHAR(255) NOT NULL,
--     phone VARCHAR(25),
--     email VARCHAR(255),
--     street VARCHAR(255),
--     city VARCHAR(255),
--     state VARCHAR(10),
--     zip_code VARCHAR(10)
-- );

-- CREATE TABLE staffs (
--     staff_id INT PRIMARY KEY,
--     first_name VARCHAR(50) NOT NULL,
--     last_name VARCHAR(50) NOT NULL,
--     email VARCHAR(255),
--     phone VARCHAR(25),
--     active SMALLINT NOT NULL,
--     store_id INT NOT NULL,
--     manager_id INT,
--     FOREIGN KEY (store_id) REFERENCES stores(store_id)
-- );

-- CREATE TABLE customers (
--     customer_id INT PRIMARY KEY,
--     first_name VARCHAR(50) NOT NULL,
--     last_name VARCHAR(50) NOT NULL,
--     phone VARCHAR(25),
--     email VARCHAR(255),
--     street VARCHAR(255),
--     city VARCHAR(255),
--     state VARCHAR(10),
--     zip_code VARCHAR(10)
-- );

-- CREATE TABLE orders (
--     order_id INT PRIMARY KEY,
--     customer_id INT NOT NULL,
--     order_status SMALLINT NOT NULL,
--     order_date DATE NOT NULL,
--     required_date DATE NOT NULL,
--     shipped_date DATE,
--     store_id INT NOT NULL,
--     staff_id INT NOT NULL,
--     FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
--     FOREIGN KEY (store_id) REFERENCES stores(store_id),
--     FOREIGN KEY (staff_id) REFERENCES staffs(staff_id)
-- );

-- CREATE TABLE order_items (
--     order_id INT NOT NULL,
--     item_id INT NOT NULL,
--     product_id INT NOT NULL,
--     quantity INT NOT NULL,
--     list_price DECIMAL(10,2) NOT NULL,
--     discount DECIMAL(4,2) NOT NULL DEFAULT 0.00,
--     PRIMARY KEY (order_id, item_id),
--     FOREIGN KEY (order_id) REFERENCES orders(order_id),
--     FOREIGN KEY (product_id) REFERENCES products(product_id)
-- );

-- CREATE TABLE stocks (
--     store_id INT NOT NULL,
--     product_id INT NOT NULL,
--     quantity INT NOT NULL,
--     PRIMARY KEY (store_id, product_id),
--     FOREIGN KEY (store_id) REFERENCES stores(store_id),
--     FOREIGN KEY (product_id) REFERENCES products(product_id)
-- );

-- 1. Import small lookup tables first
-- 1. Small lookup tables
-- \copy brands FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/brands.csv' WITH (FORMAT CSV, HEADER);
-- \copy categories FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/categories.csv' WITH (FORMAT CSV, HEADER);
-- \copy products FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/products.csv' WITH (FORMAT CSV, HEADER);
-- \copy stores FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/stores.csv' WITH (FORMAT CSV, HEADER);
-- \copy staffs FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/staffs.csv' WITH (FORMAT CSV, HEADER);

-- -- 2. Main tables
-- \copy customers FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/customers.csv' WITH (FORMAT CSV, HEADER);
-- \copy orders FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/orders.csv' WITH (FORMAT CSV, HEADER);
-- \copy order_items FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/order_items.csv' WITH (FORMAT CSV, HEADER);
-- \copy stocks FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/stocks.csv' WITH (FORMAT CSV, HEADER);

-- SELECT COUNT(*) FROM order_items;
-- TRUNCATE TABLE order_items;
-- SELECT COUNT(*) FROM orders;
-- COPY order_items 
-- FROM 'C:/Users/Tsex/Documents/Labmentrix/Project_5_Retail Sales & Inventory Intelligence System/data/order_items.csv' 
-- WITH (FORMAT CSV, HEADER);

-- sudo -u postgres psql

-- Run this EXACTLY in pgAdmin Query Tool or psql (not Process Watcher)
copy public.order_items(order_id, item_id, product_id, quantity, list_price, discount) 
FROM 'C:/temp/order_items.csv' 
WITH (FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '"', NULL 'NULL');