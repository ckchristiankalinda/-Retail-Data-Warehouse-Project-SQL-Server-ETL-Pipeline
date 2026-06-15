/*=============================================================================
 FILE NAME: procedure_silver data_quality _check.sql

 DESCRIPTION:
 Executes automated data quality validation tests before loading
 Gold Layer objects.

 VALIDATIONS:
 - Null checks
 - Duplicate checks
 - Business rule validation
 - Referential integrity
 - Data consistency checks

=============================================================================*/

/*-----------------------------------------------------------------------------
 TABLE: silver.data_quality_test_results

 PURPOSE:
 Store the outcome of data quality validation tests.

-----------------------------------------------------------------------------*/
/*==============================================================
    DATA QUALITY TEST RESULTS
==============================================================*/

IF OBJECT_ID('silver.data_quality_test_results','U') IS NOT NULL
    DROP TABLE silver.data_quality_test_results;
GO


CREATE TABLE silver.data_quality_test_results
(
    test_id INT IDENTITY(1,1) PRIMARY KEY,
    test_name NVARCHAR(200),
    failed_records INT,
    status NVARCHAR(20),
    execution_date DATETIME DEFAULT GETDATE()
);
GO

        
	/*-----------------------------------------------------------------------------
 PROCEDURE: silver.run_data_quality_checks

 PURPOSE:
 Execute all Silver Layer quality validation tests.
 Validate Silver Layer before Gold Load
 OUTPUT:
 PASS / FAIL status for each test.

-----------------------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE silver.run_data_quality_checks
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();

    PRINT '=========================================';
    PRINT 'STARTING DATA QUALITY CHECKS';
    PRINT '=========================================';

    ------------------------------------------------------------
    -- CLEAN PREVIOUS RESULTS
    ------------------------------------------------------------

    TRUNCATE TABLE silver.data_quality_test_results;

    ------------------------------------------------------------
    -- TEST 1 : NULL CUSTOMER KEYS
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'NULL CUSTOMER KEYS',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_customers
    WHERE customer_key IS NULL;

    ------------------------------------------------------------
    -- TEST 2 : DUPLICATE CUSTOMERS
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'DUPLICATE CUSTOMERS',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM
    (
        SELECT customer_key
        FROM silver.crm_customers
        GROUP BY customer_key
        HAVING COUNT(*) > 1
    ) d;

    ------------------------------------------------------------
    -- TEST 3 : INVALID AGE
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'INVALID AGE',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_customers
    WHERE age < 0
       OR age > 120;

    ------------------------------------------------------------
    -- TEST 4 : FUTURE SIGNUP DATE
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'FUTURE SIGNUP DATE',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_customers
    WHERE signup_date > GETDATE();

    ------------------------------------------------------------
    -- TEST 5 : DUPLICATE SALES
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'DUPLICATE SALES',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM
    (
        SELECT order_id
        FROM silver.crm_sales
        GROUP BY order_id
        HAVING COUNT(*) > 1
    ) d;

    ------------------------------------------------------------
    -- TEST 6 : INVALID QUANTITY
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'INVALID QUANTITY',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_sales
    WHERE quantity <= 0
       OR quantity > 10000;

    ------------------------------------------------------------
    -- TEST 7 : INVALID UNIT PRICE
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'INVALID UNIT PRICE',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_sales
    WHERE unit_price <= 0;

    ------------------------------------------------------------
    -- TEST 8 : INVALID PRODUCT PRICE
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'SELLING PRICE < COST PRICE',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_products
    WHERE selling_price < cost_price;

    ------------------------------------------------------------
    -- TEST 9 : SALES WITHOUT CUSTOMER
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'ORPHAN CUSTOMER SALES',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_sales s
    LEFT JOIN silver.crm_customers c
        ON s.customer_key = c.customer_key
    WHERE c.customer_key IS NULL;

    ------------------------------------------------------------
    -- TEST 10 : SALES WITHOUT PRODUCT
    ------------------------------------------------------------

    INSERT INTO silver.data_quality_test_results
    (
        test_name,
        failed_records,
        status
    )
    SELECT
        'ORPHAN PRODUCT SALES',
        COUNT(*),
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.crm_sales s
    LEFT JOIN silver.crm_products p
        ON s.product_id = p.product_id
    WHERE p.product_id IS NULL;

    ------------------------------------------------------------
    -- SUMMARY
    ------------------------------------------------------------

    PRINT '';
    PRINT 'DATA QUALITY RESULTS';
    PRINT '--------------------';

    SELECT *
    FROM silver.data_quality_test_results
    ORDER BY test_id;

    PRINT '';
    PRINT 'FAILED TESTS';

    SELECT *
    FROM silver.data_quality_test_results
    WHERE status = 'FAIL';

    PRINT '';
    PRINT 'CHECK DURATION (SEC): '
          + CAST(DATEDIFF(SECOND,@start_time,GETDATE()) AS NVARCHAR);

    PRINT '=========================================';
    PRINT 'DATA QUALITY CHECKS COMPLETED';
    PRINT '=========================================';

END;
GO