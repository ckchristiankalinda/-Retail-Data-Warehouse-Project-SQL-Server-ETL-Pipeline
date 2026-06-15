--FINAL EXECUTION
/*=============================================================================
 FILE NAME: final_execution.sql

 DESCRIPTION:
 Master execution script used to run the complete Data Warehouse
 pipeline from Bronze Layer to Gold Layer.

 EXECUTION FLOW:
 1. Load Bronze Layer
 2. Load Silver Layer
 3. Run Data Quality Checks
 4. Load Gold Layer
 5. Query Reporting Objects

=============================================================================*/
-- 1. Load Bronze Layer 
EXEC bronze.load_bronze_all;
GO
 
-- 2. Load Silver Layer
EXEC silver.load_silver_all;
GO

-- 3. Load quality Check
EXEC silver.run_data_quality_checks;
GO

-- 4. Load Gold
EXEC gold.load_gold_all;
GO

-- 5.  BI Usage
SELECT * FROM gold.report_customer;
SELECT * FROM gold.report_product;
SELECT * FROM gold.v_report_sales;
SELECT * FROM gold.v_executive_dashboard;
