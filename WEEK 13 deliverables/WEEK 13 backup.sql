CREATE DATABASE  IF NOT EXISTS `inventorydb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `inventorydb`;
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: inventorydb
-- ------------------------------------------------------
-- Server version	9.2.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auditlog`
--

DROP TABLE IF EXISTS `auditlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditlog` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action_type` varchar(50) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `record_id` int DEFAULT NULL,
  `action_details` json DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_audit_user` (`user_id`),
  KEY `idx_audit_table` (`table_name`),
  KEY `idx_audit_timestamp` (`timestamp`),
  KEY `idx_auditlog_timestamp` (`timestamp`),
  CONSTRAINT `auditlog_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditlog`
--

LOCK TABLES `auditlog` WRITE;
/*!40000 ALTER TABLE `auditlog` DISABLE KEYS */;
INSERT INTO `auditlog` VALUES (1,1,'CREATE','Products',1,'{\"name\": \"Laptop Pro 15\", \"price\": 1299.99}','192.168.1.100',NULL,'2025-04-15 03:28:14'),(2,1,'CREATE','Orders',1,'{\"customer_id\": 1, \"total_amount\": 1299.99}','192.168.1.100',NULL,'2025-04-15 03:28:14'),(3,2,'UPDATE','Products',2,'{\"price\": \"1099.99\"}','192.168.1.101',NULL,'2025-04-15 03:28:14'),(4,3,'CREATE','OrderItems',3,'{\"order_id\": 3, \"product_id\": 5}','192.168.1.102',NULL,'2025-04-15 03:28:14'),(5,4,'DELETE','Discounts',4,'{\"discount_name\": \"Clearance\"}','192.168.1.103',NULL,'2025-04-15 03:28:14');
/*!40000 ALTER TABLE `auditlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `description` text,
  `parent_category_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `category_name` (`category_name`),
  KEY `parent_category_id` (`parent_category_id`),
  KEY `idx_category_name` (`category_name`),
  CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Electronics','All electronic devices',NULL,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(2,'Computers','Computers and related equipment',1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(3,'Laptops','Portable computers',2,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(4,'Desktops','Desktop computers',2,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(5,'Tablets','Tablet devices',2,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(6,'Phones','Mobile phones and smartphones',1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(7,'Smartphones','Advanced mobile phones',6,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(8,'Feature Phones','Basic mobile phones',6,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(9,'Accessories','Electronic accessories',1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(10,'Cables','Various cables and connectors',9,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(11,'Adapters','Power and data adapters',9,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(12,'Batteries','Rechargeable batteries',9,'2025-04-15 03:28:14','2025-04-15 03:28:14');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `contact` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `city` varchar(50) NOT NULL,
  `country` varchar(50) NOT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `loyalty_points` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  KEY `idx_customer_name` (`name`),
  KEY `idx_customer_contact` (`contact`),
  CONSTRAINT `customers_chk_1` CHECK ((`email` like _utf8mb4'%@%.%'))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Charlie Brown','Charlie Brown','charlie@example.com','1112223333','789 Customer Rd','Boston','USA','02108',100,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(2,'River Song','River Song','river@example.com','4445556666','101 Customer St','Austin','USA','78701',250,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(3,'Alex Johnson','Alex Johnson','alex@example.com','7778889999','202 Client Ave','Denver','USA','80202',50,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(4,'Morgan Lee','Morgan Lee','morgan@example.com','3334445555','303 Buyer Blvd','Miami','USA','33101',500,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(5,'Taylor Smith','Taylor Smith','taylor@example.com','6667778888','404 Shopper Lane','Portland','USA','97201',75,'2025-04-15 03:28:14','2025-04-15 03:28:14');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discounts`
--

DROP TABLE IF EXISTS `discounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discounts` (
  `discount_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `discount_name` varchar(100) NOT NULL,
  `discount_percentage` decimal(5,2) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`discount_id`),
  KEY `idx_discount_product` (`product_id`),
  KEY `idx_discount_dates` (`start_date`,`end_date`),
  CONSTRAINT `discounts_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `discounts_chk_1` CHECK (((`discount_percentage` > 0) and (`discount_percentage` <= 100))),
  CONSTRAINT `discounts_chk_2` CHECK ((`end_date` > `start_date`))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discounts`
--

LOCK TABLES `discounts` WRITE;
/*!40000 ALTER TABLE `discounts` DISABLE KEYS */;
INSERT INTO `discounts` VALUES (1,1,'Summer Sale',15.00,'2023-06-01 00:00:00','2023-06-30 23:59:59',0,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(2,2,'Back to School',10.00,'2023-08-01 00:00:00','2023-08-31 23:59:59',0,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(3,6,'Holiday Special',20.00,'2023-12-01 00:00:00','2023-12-31 23:59:59',0,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(4,9,'Clearance',30.00,'2023-07-01 00:00:00','2023-07-31 23:59:59',0,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(5,11,'Battery Promotion',15.00,'2023-09-01 00:00:00','2023-09-30 23:59:59',0,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(6,1,'Test Discount',10.00,'2025-04-15 11:28:16','2025-04-16 11:28:16',1,'2025-04-15 03:28:16','2025-04-15 03:28:16');
/*!40000 ALTER TABLE `discounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `lowstockview`
--

DROP TABLE IF EXISTS `lowstockview`;
/*!50001 DROP VIEW IF EXISTS `lowstockview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `lowstockview` AS SELECT 
 1 AS `product_id`,
 1 AS `name`,
 1 AS `stock_quantity`,
 1 AS `reorder_level`,
 1 AS `supplier_id`,
 1 AS `supplier_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `orderitems`
--

DROP TABLE IF EXISTS `orderitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderitems` (
  `order_item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `discount_amount` decimal(10,2) DEFAULT '0.00',
  `total_price` decimal(10,2) GENERATED ALWAYS AS (((`price` - `discount_amount`) * `quantity`)) STORED,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_item_id`),
  KEY `idx_orderitem_order` (`order_id`),
  KEY `idx_orderitem_product` (`product_id`),
  KEY `idx_orderitems_product` (`product_id`),
  CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `orderitems_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE SET NULL,
  CONSTRAINT `orderitems_chk_1` CHECK ((`quantity` > 0)),
  CONSTRAINT `orderitems_chk_2` CHECK ((`price` > 0)),
  CONSTRAINT `orderitems_chk_3` CHECK ((`discount_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitems`
--

LOCK TABLES `orderitems` WRITE;
/*!40000 ALTER TABLE `orderitems` DISABLE KEYS */;
INSERT INTO `orderitems` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price`, `discount_amount`, `created_at`) VALUES (1,1,1,1,1299.99,0.00,'2025-04-15 03:28:14'),(2,2,2,2,1099.99,0.00,'2025-04-15 03:28:14'),(3,3,5,1,499.99,0.00,'2025-04-15 03:28:14'),(4,4,9,3,19.99,0.00,'2025-04-15 03:28:14'),(5,4,10,2,49.99,0.00,'2025-04-15 03:28:14'),(6,5,7,1,699.99,0.00,'2025-04-15 03:28:14');
/*!40000 ALTER TABLE `orderitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `order_number` varchar(20) NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Pending','Processing','Shipped','Delivered','Cancelled','Refunded') DEFAULT 'Pending',
  `total_amount` decimal(12,2) NOT NULL,
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `shipping_amount` decimal(10,2) DEFAULT '0.00',
  `payment_method` enum('Cash','Credit Card','Debit Card','Bank Transfer','Other') NOT NULL,
  `payment_status` enum('Pending','Paid','Failed','Refunded') DEFAULT 'Pending',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `user_id` (`user_id`),
  KEY `idx_order_customer` (`customer_id`),
  KEY `idx_order_status` (`status`),
  KEY `idx_order_date` (`order_date`),
  KEY `idx_orders_total` (`total_amount`),
  KEY `idx_orders_date_status` (`order_date`,`status`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE SET NULL,
  CONSTRAINT `orders_chk_1` CHECK ((`total_amount` >= 0)),
  CONSTRAINT `orders_chk_2` CHECK ((`tax_amount` >= 0)),
  CONSTRAINT `orders_chk_3` CHECK ((`shipping_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,1,'ORD-10001','2025-04-15 03:28:14','Delivered',1299.99,104.00,0.00,'Credit Card','Paid',NULL,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(2,2,2,'ORD-10002','2025-04-15 03:28:14','Processing',2199.98,176.00,15.00,'Debit Card','Paid',NULL,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(3,3,3,'ORD-10003','2025-04-15 03:28:14','Pending',499.99,40.00,0.00,'Credit Card','Pending',NULL,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(4,4,4,'ORD-10004','2025-04-15 03:28:14','Shipped',179.94,14.40,5.00,'Bank Transfer','Paid',NULL,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(5,5,5,'ORD-10005','2025-04-15 03:28:14','Cancelled',699.99,56.00,0.00,'Credit Card','Refunded',NULL,'2025-04-15 03:28:14','2025-04-15 03:28:14');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `productinventoryview`
--

DROP TABLE IF EXISTS `productinventoryview`;
/*!50001 DROP VIEW IF EXISTS `productinventoryview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `productinventoryview` AS SELECT 
 1 AS `product_id`,
 1 AS `product_name`,
 1 AS `category_name`,
 1 AS `supplier_name`,
 1 AS `stock_quantity`,
 1 AS `price`,
 1 AS `reorder_level`,
 1 AS `stock_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `sku` varchar(50) NOT NULL,
  `category_id` int DEFAULT NULL,
  `supplier_id` int DEFAULT NULL,
  `stock_quantity` int DEFAULT '0',
  `price` decimal(10,2) NOT NULL,
  `cost_price` decimal(10,2) NOT NULL,
  `reorder_level` int DEFAULT '5',
  `warranty_period` int DEFAULT NULL COMMENT 'Warranty in months',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `idx_product_name` (`name`),
  KEY `idx_product_sku` (`sku`),
  KEY `idx_product_category` (`category_id`),
  KEY `idx_product_supplier` (`supplier_id`),
  KEY `idx_products_price` (`price`),
  KEY `idx_products_stock` (`stock_quantity`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL,
  CONSTRAINT `products_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`) ON DELETE SET NULL,
  CONSTRAINT `products_chk_1` CHECK ((`stock_quantity` >= 0)),
  CONSTRAINT `products_chk_2` CHECK ((`price` > 0)),
  CONSTRAINT `products_chk_3` CHECK ((`cost_price` > 0)),
  CONSTRAINT `products_chk_4` CHECK ((`reorder_level` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Laptop Pro 15','High-performance business laptop','LP-1001',3,1,50,1299.99,899.99,5,24,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(2,'Laptop Air 13','Ultra-lightweight laptop','LP-1002',3,1,35,1099.99,799.99,5,24,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(3,'Desktop Power','High-end desktop computer','DT-2001',4,2,20,1499.99,1099.99,3,36,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(4,'Desktop Mini','Compact desktop computer','DT-2002',4,2,15,899.99,649.99,3,24,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(5,'Tablet Plus 10','10-inch tablet with stylus','TB-3001',5,3,40,499.99,349.99,10,12,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(6,'Phone X','Flagship smartphone','PH-4001',7,4,100,999.99,699.99,15,12,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(7,'Phone Y','Mid-range smartphone','PH-4002',7,4,80,699.99,499.99,15,12,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(8,'Basic Phone','Simple feature phone','PH-4003',8,4,30,99.99,69.99,5,6,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(9,'USB-C Cable','1m USB-C to USB-C cable','AC-5001',10,5,200,19.99,9.99,50,1,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(10,'Power Adapter','65W USB-C power adapter','AC-5002',11,5,150,49.99,29.99,30,12,1,'2025-04-15 03:28:14','2025-04-15 03:28:14'),(11,'Laptop Battery','Replacement laptop battery','AC-5003',12,5,75,79.99,49.99,20,6,1,'2025-04-15 03:28:14','2025-04-15 03:28:14');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `salesreportview`
--

DROP TABLE IF EXISTS `salesreportview`;
/*!50001 DROP VIEW IF EXISTS `salesreportview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `salesreportview` AS SELECT 
 1 AS `order_id`,
 1 AS `order_number`,
 1 AS `order_date`,
 1 AS `customer_name`,
 1 AS `staff_username`,
 1 AS `status`,
 1 AS `total_amount`,
 1 AS `payment_method`,
 1 AS `payment_status`,
 1 AS `item_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `stocktransactions`
--

DROP TABLE IF EXISTS `stocktransactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stocktransactions` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `transaction_type` enum('IN','OUT','ADJUSTMENT','RETURN') NOT NULL,
  `quantity` int NOT NULL,
  `reference_id` varchar(50) DEFAULT NULL COMMENT 'Can reference order_id, purchase_id, etc.',
  `reference_type` enum('ORDER','PURCHASE','ADJUSTMENT','OTHER') DEFAULT NULL COMMENT 'Type of reference',
  `notes` text,
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_stock_product` (`product_id`),
  KEY `idx_stock_date` (`transaction_date`),
  KEY `idx_stock_type` (`transaction_type`),
  KEY `idx_stocktrans_product_date` (`product_id`,`transaction_date`),
  CONSTRAINT `stocktransactions_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `stocktransactions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `stocktransactions_chk_1` CHECK ((`quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stocktransactions`
--

LOCK TABLES `stocktransactions` WRITE;
/*!40000 ALTER TABLE `stocktransactions` DISABLE KEYS */;
INSERT INTO `stocktransactions` VALUES (1,1,'IN',100,'PO-1001','PURCHASE',NULL,'2025-04-15 03:28:14',1),(2,2,'IN',50,'PO-1001','PURCHASE',NULL,'2025-04-15 03:28:14',1),(3,3,'IN',30,'PO-1002','PURCHASE',NULL,'2025-04-15 03:28:14',2),(4,4,'IN',20,'PO-1002','PURCHASE',NULL,'2025-04-15 03:28:14',2),(5,5,'IN',50,'PO-1003','PURCHASE',NULL,'2025-04-15 03:28:14',3),(6,6,'IN',150,'PO-1004','PURCHASE',NULL,'2025-04-15 03:28:14',1),(7,7,'IN',100,'PO-1004','PURCHASE',NULL,'2025-04-15 03:28:14',1),(8,8,'IN',50,'PO-1005','PURCHASE',NULL,'2025-04-15 03:28:14',2),(9,9,'IN',300,'PO-1006','PURCHASE',NULL,'2025-04-15 03:28:14',3),(10,10,'IN',200,'PO-1006','PURCHASE',NULL,'2025-04-15 03:28:14',3),(11,11,'IN',100,'PO-1007','PURCHASE',NULL,'2025-04-15 03:28:14',1),(12,1,'OUT',1,'ORD-10001','ORDER',NULL,'2025-04-15 03:28:14',1),(13,2,'OUT',2,'ORD-10002','ORDER',NULL,'2025-04-15 03:28:14',2),(14,5,'OUT',1,'ORD-10003','ORDER',NULL,'2025-04-15 03:28:14',3),(15,9,'OUT',3,'ORD-10004','ORDER',NULL,'2025-04-15 03:28:14',4),(16,10,'OUT',2,'ORD-10004','ORDER',NULL,'2025-04-15 03:28:14',4),(17,7,'OUT',1,'ORD-10005','ORDER',NULL,'2025-04-15 03:28:14',5);
/*!40000 ALTER TABLE `stocktransactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `contact` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `city` varchar(50) NOT NULL,
  `country` varchar(50) NOT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`supplier_id`),
  KEY `idx_supplier_name` (`name`),
  KEY `idx_supplier_contact` (`contact`),
  CONSTRAINT `suppliers_chk_1` CHECK ((`email` like _utf8mb4'%@%.%'))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'Tech Supplies Inc.','John Smith','john@techsupplies.com','1234567890','123 Tech St','San Francisco','USA','94105','2025-04-15 03:28:14','2025-04-15 03:28:14'),(2,'Gadget World','Sarah Johnson','sarah@gadgetworld.com','0987654321','456 Gadget Ave','New York','USA','10001','2025-04-15 03:28:14','2025-04-15 03:28:14'),(3,'Electro Parts Co.','Mike Brown','mike@electroparts.com','5551234567','789 Electro Rd','Chicago','USA','60601','2025-04-15 03:28:14','2025-04-15 03:28:14'),(4,'Global Components','Lisa Wong','lisa@globalcomponents.com','5559876543','101 Global Blvd','Los Angeles','USA','90015','2025-04-15 03:28:14','2025-04-15 03:28:14'),(5,'Quality Electronics','David Kim','david@qualityelectronics.com','5554567890','202 Quality Lane','Seattle','USA','98101','2025-04-15 03:28:14','2025-04-15 03:28:14');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` enum('admin','manager','staff') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_role` (`role`),
  CONSTRAINT `users_chk_1` CHECK ((length(`password`) >= 8)),
  CONSTRAINT `users_chk_2` CHECK ((`email` like _utf8mb4'%@%.%'))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin1','$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue','admin1@inventory.com','admin','2025-04-15 03:28:14','2025-04-15 03:28:14'),(2,'manager1','$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue','manager1@inventory.com','manager','2025-04-15 03:28:14','2025-04-15 03:28:14'),(3,'staff1','$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue','staff1@inventory.com','staff','2025-04-15 03:28:14','2025-04-15 03:28:14'),(4,'staff2','$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue','staff2@inventory.com','staff','2025-04-15 03:28:14','2025-04-15 03:28:14'),(5,'manager2','$2a$10$xJwL5v5Jz5U5Jz5U5Jz5Ue','manager2@inventory.com','manager','2025-04-15 03:28:14','2025-04-15 03:28:14');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'inventorydb'
--
/*!50003 DROP PROCEDURE IF EXISTS `GenerateLargeDataset` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateLargeDataset`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `lowstockview`
--

/*!50001 DROP VIEW IF EXISTS `lowstockview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `lowstockview` AS select `p`.`product_id` AS `product_id`,`p`.`name` AS `name`,`p`.`stock_quantity` AS `stock_quantity`,`p`.`reorder_level` AS `reorder_level`,`p`.`supplier_id` AS `supplier_id`,(select `suppliers`.`name` from `suppliers` where (`suppliers`.`supplier_id` = `p`.`supplier_id`)) AS `supplier_name` from `products` `p` where (`p`.`stock_quantity` <= `p`.`reorder_level`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `productinventoryview`
--

/*!50001 DROP VIEW IF EXISTS `productinventoryview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `productinventoryview` AS select `p`.`product_id` AS `product_id`,`p`.`name` AS `product_name`,`c`.`category_name` AS `category_name`,`s`.`name` AS `supplier_name`,`p`.`stock_quantity` AS `stock_quantity`,`p`.`price` AS `price`,`p`.`reorder_level` AS `reorder_level`,(case when (`p`.`stock_quantity` <= `p`.`reorder_level`) then 'Reorder Needed' else 'OK' end) AS `stock_status` from ((`products` `p` join `categories` `c` on((`p`.`category_id` = `c`.`category_id`))) join `suppliers` `s` on((`p`.`supplier_id` = `s`.`supplier_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `salesreportview`
--

/*!50001 DROP VIEW IF EXISTS `salesreportview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `salesreportview` AS select `o`.`order_id` AS `order_id`,`o`.`order_number` AS `order_number`,`o`.`order_date` AS `order_date`,`c`.`name` AS `customer_name`,`u`.`username` AS `staff_username`,`o`.`status` AS `status`,`o`.`total_amount` AS `total_amount`,`o`.`payment_method` AS `payment_method`,`o`.`payment_status` AS `payment_status`,count(`oi`.`order_item_id`) AS `item_count` from (((`orders` `o` join `customers` `c` on((`o`.`customer_id` = `c`.`customer_id`))) left join `users` `u` on((`o`.`user_id` = `u`.`user_id`))) join `orderitems` `oi` on((`o`.`order_id` = `oi`.`order_id`))) group by `o`.`order_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-15 11:33:39
