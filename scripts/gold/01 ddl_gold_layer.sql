/*=============================================================================
 FILE NAME: ddl_gold_layer.sql

 DESCRIPTION:
 Creates analytical reporting tables used by Power BI.

 OBJECTS:
 - report_customer
 - report_product

=============================================================================*/

/*==============================================================
    CUSTOMER ANALYTICS
==============================================================*/

IF OBJECT_ID('gold.report_customer','U') IS NOT NULL
    DROP TABLE gold.report_customer;
GO

CREATE TABLE gold.report_customer
(
    customer_key NVARCHAR(20),
    customer_name NVARCHAR(100),
    gender NVARCHAR(10),
    age INT,
    age_group NVARCHAR(20),
    country_name NVARCHAR(100),
    customer_segment NVARCHAR(50),
   
    total_orders INT,
    total_quantity INT,

    total_sales DECIMAL(18,2),
    total_profit DECIMAL(18,2),

    average_order_value DECIMAL(18,2),
	first_order_date DATE,
    last_order_date DATE,

    created_date DATETIME DEFAULT GETDATE()
);
GO

/*==============================================================
    PRODUCT ANALYTICS
==============================================================*/

IF OBJECT_ID('gold.report_product','U') IS NOT NULL
    DROP TABLE gold.report_product;
GO

CREATE TABLE gold.report_product
(
    product_id NVARCHAR(20),
    product_name NVARCHAR(150),
    category NVARCHAR(100),
    brand NVARCHAR(100),

    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),

    total_orders INT,
    total_quantity_sold INT,

    total_sales DECIMAL(18,2),
    total_profit DECIMAL(18,2),

    profit_margin DECIMAL(18,2),

    created_date DATETIME DEFAULT GETDATE()
);
GO