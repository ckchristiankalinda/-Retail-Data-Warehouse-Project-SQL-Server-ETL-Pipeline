/*=============================================================================
 FILE NAME: gold_views.sql

 DESCRIPTION:
 Creates analytical views used by Power BI dashboards.

 VIEWS:
 - v_report_sales
 - v_executive_dashboard

=============================================================================*/

/*==============================================================
    SALES ANALYTICAL VIEW
==============================================================*/

/*-----------------------------------------------------------------------------
 VIEW: gold.v_report_sales

 PURPOSE:
 Create a complete sales dataset by joining all business entities.

 USED BY:
 Power BI Sales Dashboard

-----------------------------------------------------------------------------*/
CREATE OR ALTER VIEW gold.v_report_sales
AS

SELECT

    s.order_id,

    d.full_date,

    c.customer_key,
    c.customer_name,
    c.gender,
    c.country_name,
    c.customer_segment,

    p.product_id,
    p.product_name,
    p.category,
    p.brand,

    r.region_name,
    r.country,

    pay.payment_method,
    pay.payment_status,

    s.quantity,
    s.unit_price,
    s.discount,
    s.total_amount,
    s.profit

FROM silver.crm_sales s

LEFT JOIN silver.crm_customers c
    ON s.customer_key = c.customer_key

LEFT JOIN silver.crm_products p
    ON s.product_id = p.product_id

LEFT JOIN silver.crm_regions r
    ON s.region_id = r.region_id

LEFT JOIN silver.crm_payments pay
    ON s.payment_id = pay.payment_id

LEFT JOIN silver.crm_date d
    ON s.date_id = d.date_id;
GO

/*==============================================================
    EXECUTIVE KPI DASHBOARD
==============================================================*/

/*-----------------------------------------------------------------------------
 VIEW: gold.v_executive_dashboard

 PURPOSE:
 Provide executive KPIs for management reporting.

 KPIs:
 - Total Sales
 - Total Profit
 - Total Orders
 - Total Customers
 - Average Order Value
 - Profit Margin

-----------------------------------------------------------------------------*/
CREATE OR ALTER VIEW gold.v_executive_dashboard
AS

SELECT

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT customer_key) AS total_customers,

    COUNT(DISTINCT product_id) AS total_products,

    SUM(quantity) AS total_quantity,

    SUM(total_amount) AS total_sales,

    SUM(profit) AS total_profit,

    AVG(total_amount) AS average_order_value,

    CASE
        WHEN SUM(total_amount) = 0 THEN 0
        ELSE
            ROUND(
                (SUM(profit) * 100.0)
                / SUM(total_amount)
            ,2)
    END AS profit_margin

FROM silver.crm_sales;
GO

