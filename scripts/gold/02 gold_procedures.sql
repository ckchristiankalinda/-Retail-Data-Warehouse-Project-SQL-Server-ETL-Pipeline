/*=============================================================================
 FILE NAME: gold_procedures.sql

 DESCRIPTION:
 Builds business-ready aggregated datasets for reporting.

 REPORTS:
 - Customer Performance Report
 - Product Performance Report

=============================================================================*/

/*==============================================================
    LOAD CUSTOMER REPORT
==============================================================*/

/*-----------------------------------------------------------------------------
 PROCEDURE: gold.load_report_customer

 PURPOSE:
 Generate customer-level performance metrics.

 KPIs:
 - Total Orders
 - Total Sales
 - Total Profit
 - Average Order Value
 - Last Order Date

-----------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE gold.load_report_customer
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();

    PRINT '======================================';
    PRINT 'LOADING GOLD CUSTOMER REPORT';
    PRINT '======================================';

    TRUNCATE TABLE gold.report_customer;

    INSERT INTO gold.report_customer
    (
        customer_key,
        customer_name,
        gender,
        age,
        age_group,
        country_name,
        customer_segment,
        signup_date,
        total_orders,
        total_quantity,
        total_sales,
        total_profit,
        average_order_value,
        last_order_date
    )

    SELECT

        c.customer_key,
        c.customer_name,
        c.gender,
        c.age,

        CASE
            WHEN c.age < 18 THEN 'Under 18'
            WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
            WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
            WHEN c.age BETWEEN 36 AND 50 THEN '36-50'
            ELSE '50+'
        END,

        c.country_name,
        c.customer_segment,
        c.signup_date,

        COUNT(DISTINCT s.order_id),

        ISNULL(SUM(s.quantity),0),

        ISNULL(SUM(s.total_amount),0),

        ISNULL(SUM(s.profit),0),

        ISNULL(AVG(s.total_amount),0),

        MAX(d.full_date)

    FROM silver.crm_customers c

    LEFT JOIN silver.crm_sales s
        ON c.customer_key = s.customer_key

    LEFT JOIN silver.crm_date d
        ON s.date_id = d.date_id

    GROUP BY
        c.customer_key,
        c.customer_name,
        c.gender,
        c.age,
        c.country_name,
        c.customer_segment,
        c.signup_date;

    PRINT 'Rows Loaded: ' + CAST(@@ROWCOUNT AS NVARCHAR);

    PRINT 'Duration (sec): '
        + CAST(DATEDIFF(SECOND,@start_time,GETDATE()) AS NVARCHAR);

END;
GO

/*==============================================================
    LOAD PRODUCT REPORT
==============================================================*/

CREATE OR ALTER PROCEDURE gold.load_report_product
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();

    PRINT '======================================';
    PRINT 'LOADING GOLD PRODUCT REPORT';
    PRINT '======================================';

    TRUNCATE TABLE gold.report_product;

    INSERT INTO gold.report_product
    (
        product_id,
        product_name,
        category,
        brand,
        cost_price,
        selling_price,
        total_orders,
        total_quantity_sold,
        total_sales,
        total_profit,
        profit_margin
    )

    SELECT

        p.product_id,
        p.product_name,
        p.category,
        p.brand,

        p.cost_price,
        p.selling_price,

        COUNT(DISTINCT s.order_id),

        ISNULL(SUM(s.quantity),0),

        ISNULL(SUM(s.total_amount),0),

        ISNULL(SUM(s.profit),0),

        CASE
            WHEN SUM(s.total_amount) = 0 THEN 0
            ELSE
                ROUND(
                    (SUM(s.profit) * 100.0)
                    / SUM(s.total_amount)
                ,2)
        END

    FROM silver.crm_products p

    LEFT JOIN silver.crm_sales s
        ON p.product_id = s.product_id

    GROUP BY

        p.product_id,
        p.product_name,
        p.category,
        p.brand,
        p.cost_price,
        p.selling_price;

    PRINT 'Rows Loaded: ' + CAST(@@ROWCOUNT AS NVARCHAR);

    PRINT 'Duration (sec): '
        + CAST(DATEDIFF(SECOND,@start_time,GETDATE()) AS NVARCHAR);

END;
GO

/*==============================================================
    GOLD ORCHESTRATOR
==============================================================*/

CREATE OR ALTER PROCEDURE gold.load_gold_all
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();

    PRINT '======================================';
    PRINT 'STARTING GOLD LAYER';
    PRINT '======================================';

    EXEC gold.load_report_customer;

    EXEC gold.load_report_product;

    PRINT '======================================';
    PRINT 'GOLD LAYER COMPLETED';
    PRINT 'Duration (sec): '
          + CAST(DATEDIFF(SECOND,@start_time,GETDATE()) AS NVARCHAR);
    PRINT '======================================';

END;
GO