--FINAL EXECUTION
/*=============================================================================
 FILE NAME: final_execution.sql

 DESCRIPTION:
 Master execution script used to run the complete Data Warehouse
 pipeline from Silver Layer to Gold Layer.

 EXECUTION FLOW:

 1. Load Silver Layer
 2. Run Data Quality Checks
 3. Load Gold Layer
 4. Query Reporting Objects

=============================================================================*/
-- 1. Load Silver
EXEC silver.load_silver_all;
GO

-- 2. Load quality Check
EXEC silver.run_data_quality_checks;
GO

-- 3. Load Gold
EXEC gold.load_gold_all;
GO

-- 4.  BI Usage
SELECT * FROM gold.report_customer;
SELECT * FROM gold.report_product;
SELECT * FROM gold.v_report_sales;
SELECT * FROM gold.v_executive_dashboard;
