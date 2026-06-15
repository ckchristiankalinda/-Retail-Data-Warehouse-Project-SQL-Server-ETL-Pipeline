/*=============================================================================
 FILE NAME: ddl_silver_layer.sql

 DESCRIPTION:
 Creates Silver Layer tables containing cleaned and standardized
 business entities.

 OBJECTS:
 - crm_customers
 - crm_sales
 - crm_products
 - crm_payments
 - crm_regions
 - crm_date

=============================================================================*/
/*==============================================================
    SILVER LAYER - TABLES CREATION
==============================================================*/


---------------------------------------------------------------
-- CUSTOMERS
---------------------------------------------------------------
IF OBJECT_ID('silver.crm_customers', 'U') IS NOT NULL
    DROP TABLE silver.crm_customers;
GO

CREATE TABLE silver.crm_customers (
    customer_key        NVARCHAR(20),
    customer_name       NVARCHAR(100),
    gender              NVARCHAR(10),
    age                 INT,
    country_name        NVARCHAR(100),
    customer_segment    NVARCHAR(50),
    signup_date         DATE,
    created_date        DATETIME DEFAULT GETDATE(),
    updated_date        DATETIME NULL
);
GO

---------------------------------------------------------------
-- SALES
---------------------------------------------------------------
IF OBJECT_ID('silver.crm_sales', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales;
GO

CREATE TABLE silver.crm_sales (
    order_id        NVARCHAR(20),
    customer_key    NVARCHAR(20),
    product_id      NVARCHAR(20),
    date_id         NVARCHAR(20),
    region_id       NVARCHAR(20),
    payment_id      NVARCHAR(20),
    quantity        INT,
    unit_price      DECIMAL(10,2),
    discount        DECIMAL(10,2),
    total_amount    DECIMAL(12,2),
    profit          DECIMAL(12,2),
    created_date    DATETIME DEFAULT GETDATE()
);
GO

---------------------------------------------------------------
-- PRODUCTS
---------------------------------------------------------------
IF OBJECT_ID('silver.crm_products', 'U') IS NOT NULL
    DROP TABLE silver.crm_products;
GO

CREATE TABLE silver.crm_products (
    product_id      NVARCHAR(20),
    product_name    NVARCHAR(150),
    category        NVARCHAR(100),
    brand           NVARCHAR(100),
    cost_price      DECIMAL(10,2),
    selling_price   DECIMAL(10,2),
    created_date    DATETIME DEFAULT GETDATE()
);
GO

---------------------------------------------------------------
-- PAYMENTS
---------------------------------------------------------------
IF OBJECT_ID('silver.crm_payments', 'U') IS NOT NULL
    DROP TABLE silver.crm_payments;
GO

CREATE TABLE silver.crm_payments (
    payment_id      NVARCHAR(20),
    payment_method  NVARCHAR(50),
    payment_status  NVARCHAR(50),
    created_date    DATETIME DEFAULT GETDATE()
);
GO

---------------------------------------------------------------
-- REGIONS
---------------------------------------------------------------
IF OBJECT_ID('silver.crm_regions', 'U') IS NOT NULL
    DROP TABLE silver.crm_regions;
GO

CREATE TABLE silver.crm_regions (
    region_id       NVARCHAR(20),
    region_name     NVARCHAR(100),
    country         NVARCHAR(100),
    created_date    DATETIME DEFAULT GETDATE()
);
GO

---------------------------------------------------------------
-- DATE DIMENSION
---------------------------------------------------------------
IF OBJECT_ID('silver.crm_date', 'U') IS NOT NULL
    DROP TABLE silver.crm_date;
GO

CREATE TABLE silver.crm_date (
    date_id         NVARCHAR(20),
    full_date       DATE,
    day_number      INT,
    month_number    INT,
    year_number     INT,
    quarter_number  INT,
    created_date    DATETIME DEFAULT GETDATE()
);
GO