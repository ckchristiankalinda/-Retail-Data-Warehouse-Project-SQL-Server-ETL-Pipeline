/*=============================================================================
 FILE NAME: ddl_bronze.sql

 DESCRIPTION:
 Creates Bronze Layer tables used to store raw data imported
 from CSV files without transformation.

 SOURCE FILES:
 - customer_info.csv
 - sales_details.csv
 - product_info.csv
 - payment_details.csv
 - region_info.csv
 - date_details.csv

=============================================================================*/

/*==============================================================
    BRONZE.CUSTOMERS
    Raw customer data from CSV
==============================================================*/
IF OBJECT_ID('bronze.crm_customers', 'U') IS NOT NULL
    DROP TABLE bronze.crm_customers;
GO

CREATE TABLE bronze.crm_customers (
    customer_id        NVARCHAR (20)   NOT NULL    ,
    customer_name      NVARCHAR(100)       ,
    gender             NVARCHAR(20)        ,
    age                INT                 ,
    country            NVARCHAR(100)       ,
    customer_segment   NVARCHAR(50)        ,
    signup_date        DATE                
);
GO

/*==============================================================
    BRONZE.DATE_DETAILS
    Raw date dimension data
==============================================================*/
IF OBJECT_ID('bronze.crm_date_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_date_details;
GO

CREATE TABLE bronze.crm_date_details (
    date_id NVARCHAR(20),
    full_date DATE,
    day_number INT,
    month_number INT,
    year_number INT,
    quarter_number INT
);
GO

/*==============================================================
    BRONZE.PAYMENTS
    Raw payment information
==============================================================*/
IF OBJECT_ID('bronze.crm_payments_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_payments_details;
GO

CREATE TABLE bronze.crm_payments_details (
    payment_id         NVARCHAR(20)        ,
    payment_method     NVARCHAR(50)        ,
    payment_status     NVARCHAR(50)        
);
GO

/*==============================================================
    BRONZE.PRODUCTS
    Raw product catalog data
==============================================================*/
IF OBJECT_ID('bronze.crm_product_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_product_info;
GO

CREATE TABLE bronze.crm_product_info (
    product_id         NVARCHAR(20)        NOT NULL,
    product_name       NVARCHAR(150)       NULL,
    category           NVARCHAR(100)       NULL,
    brand              NVARCHAR(100)       NULL,
    cost_price         DECIMAL(10,2)       NULL,
    selling_price      DECIMAL(10,2)       NULL
);
GO

/*==============================================================
    BRONZE.REGIONS
    Raw geographical region data
==============================================================*/
IF OBJECT_ID('bronze.crm_region_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_region_info;
GO

CREATE TABLE bronze.crm_region_info (
    region_id          NVARCHAR(20)                 NULL,
    region_name        NVARCHAR(100)       NULL,
    country            NVARCHAR(100)       NULL
);
GO

/*==============================================================
    BRONZE.SALES
    Raw sales transaction data
==============================================================*/
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    order_id           NVARCHAR (20)                 NOT NULL,
    customer_id        NVARCHAR (20)                 NOT NULL,
    product_id         NVARCHAR (20)               NOT NULL,
    date_id            NVARCHAR (20)                 NULL,
    region_id          NVARCHAR (20)                 NULL,
    payment_id         NVARCHAR (20)                 NULL,
    quantity           INT                 NULL,
    unit_price         DECIMAL(10,2)       NULL,
    discount           DECIMAL(10,2)       NULL,
    total_amount       DECIMAL(12,2)       NULL,
    profit             DECIMAL(12,2)       NULL
);
GO