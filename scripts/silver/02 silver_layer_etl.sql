
/*==============================================================
    SILVER LAYER - ETL TEMPLATE WITH MONITORING
    FEATURES:
    - Execution Tracking
    - Data Quality Logging
    - Performance Monitoring
    - Error Handling
==============================================================*/

/*==============================================================
 1. ETL LOG TABLE
==============================================================*/
IF OBJECT_ID('silver.etl_log','U') IS NOT NULL DROP TABLE silver.etl_log;
GO

CREATE TABLE silver.etl_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    procedure_name NVARCHAR(100),
    start_time DATETIME,
    end_time DATETIME,
    rows_loaded INT,
    status NVARCHAR(20),
    error_message NVARCHAR(MAX)
);
GO


/*==============================================================
 2. DATA QUALITY ISSUES TABLE
==============================================================*/
IF OBJECT_ID('silver.data_quality_issues','U') IS NOT NULL DROP TABLE silver.data_quality_issues;
GO

CREATE TABLE silver.data_quality_issues (
    issue_id INT IDENTITY(1,1) PRIMARY KEY,
    source_table NVARCHAR(100),
    record_id NVARCHAR(100),
    issue_type NVARCHAR(100),
    issue_description NVARCHAR(MAX),
    issue_date DATETIME DEFAULT GETDATE()
);
GO
/*==============================================================
 3. CRM CUSTOMERS - SILVER LOAD
==============================================================*/
CREATE OR ALTER PROCEDURE silver.load_crm_customers
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_start DATETIME2 = GETDATE();
    DECLARE @proc_end DATETIME2;

    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;

    DECLARE @rows_loaded INT = 0;
    DECLARE @execution_time_sec INT;

    PRINT '====================================================';
    PRINT 'STARTING PROCEDURE : silver.load_crm_customers';
    PRINT 'START TIME : ' + CONVERT(VARCHAR,@proc_start,120);
    PRINT '====================================================';

    BEGIN TRY

    /*=========================================================
        STEP 1 : TRUNCATE TARGET TABLE
    =========================================================*/
        SET @step_start = GETDATE();

        PRINT 'STEP 1 : TRUNCATING silver.crm_customers';

        TRUNCATE TABLE silver.crm_customers;

        SET @step_end = GETDATE();

        PRINT 'STEP 1 COMPLETED IN '
            + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
            + ' ms';

    /*=========================================================
        STEP 2 : LOG DATA QUALITY ISSUES
    =========================================================*/
        SET @step_start = GETDATE();

        PRINT 'STEP 2 : CHECKING DATA QUALITY';

        INSERT INTO silver.data_quality_issues
        (
            source_table,
            record_id,
            issue_type,
            issue_description
        )
        SELECT
            'bronze.crm_customers',
            customer_id,
            'Missing ID',
            'Customer ID is empty'
        FROM bronze.crm_customers
        WHERE NULLIF(TRIM(customer_id),'') IS NULL;

        PRINT CAST(@@ROWCOUNT AS VARCHAR)
            + ' DATA QUALITY ISSUES DETECTED';

        SET @step_end = GETDATE();

        PRINT 'STEP 2 COMPLETED IN '
            + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
            + ' ms';

    /*=========================================================
        STEP 3 : LOAD CLEAN DATA
    =========================================================*/
        SET @step_start = GETDATE();

        PRINT 'STEP 3 : LOADING CLEAN CUSTOMER DATA';

        ;WITH cte AS
        (
            SELECT *,
                   ROW_NUMBER() OVER
                   (
                       PARTITION BY TRIM(customer_id)
                       ORDER BY signup_date DESC
                   ) rn
            FROM bronze.crm_customers
        )
        INSERT INTO silver.crm_customers
        (
            customer_key,
            customer_name,
            gender,
            age,
            country_name,
            customer_segment,
            signup_date
        )
        SELECT
            TRIM(customer_id),

            COALESCE(
                NULLIF(TRIM(customer_name),''),
                'Unknown'
            ),

            CASE
                WHEN LOWER(TRIM(gender)) IN ('m','male')
                    THEN 'Male'
                WHEN LOWER(TRIM(gender)) IN ('f','female')
                    THEN 'Female'
                ELSE 'Unknown'
            END,

            CASE
                WHEN age BETWEEN 0 AND 120
                    THEN age
                ELSE NULL
            END,

            COALESCE(
                NULLIF(UPPER(TRIM(country)),''),
                'UNKNOWN'
            ),

            COALESCE(
                NULLIF(TRIM(customer_segment),''),
                'Unknown'
            ),

            CASE
                WHEN TRY_CONVERT(DATE,signup_date) > GETDATE()
                    THEN NULL
                ELSE TRY_CONVERT(DATE,signup_date)
            END

        FROM cte
        WHERE rn = 1
        AND NULLIF(TRIM(customer_id),'') IS NOT NULL;

        SET @rows_loaded = @@ROWCOUNT;

        SET @step_end = GETDATE();

        PRINT CAST(@rows_loaded AS VARCHAR)
            + ' CUSTOMERS LOADED';

        PRINT 'STEP 3 COMPLETED IN '
            + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
            + ' ms';

    /*=========================================================
        FINAL MONITORING
    =========================================================*/
        SET @proc_end = GETDATE();

        SET @execution_time_sec =
            DATEDIFF(SECOND,@proc_start,@proc_end);

        INSERT INTO silver.etl_log
        (
            procedure_name,
            start_time,
            end_time,
            rows_loaded,
            status,
            error_message
        )
        VALUES
        (
            'load_crm_customers',
            @proc_start,
            @proc_end,
            @rows_loaded,
            'SUCCESS',
            NULL
        );

        PRINT '----------------------------------------------------';
        PRINT 'PROCEDURE COMPLETED SUCCESSFULLY';
        PRINT 'ROWS LOADED : ' + CAST(@rows_loaded AS VARCHAR);
        PRINT 'TOTAL EXECUTION TIME : '
            + CAST(@execution_time_sec AS VARCHAR)
            + ' SECOND(S)';
        PRINT 'END TIME : '
            + CONVERT(VARCHAR,@proc_end,120);
        PRINT '====================================================';

    END TRY

    BEGIN CATCH

        SET @proc_end = GETDATE();

        INSERT INTO silver.etl_log
        (
            procedure_name,
            start_time,
            end_time,
            rows_loaded,
            status,
            error_message
        )
        VALUES
        (
            'load_crm_customers',
            @proc_start,
            @proc_end,
            0,
            'FAILED',
            ERROR_MESSAGE()
        );

        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
        PRINT 'ERROR OCCURRED';
        PRINT ERROR_MESSAGE();
        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

        THROW;

    END CATCH

END;
GO

/*==============================================================
 4. CRM SALES - SILVER LOAD
==============================================================*/

CREATE OR ALTER PROCEDURE silver.load_crm_sales
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_start DATETIME2 = GETDATE();
    DECLARE @proc_end DATETIME2;

    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;

    DECLARE @rows_loaded INT = 0;
    DECLARE @execution_time_sec INT;

    PRINT '====================================================';
    PRINT 'STARTING PROCEDURE : silver.load_crm_sales';
    PRINT 'START TIME : ' + CONVERT(VARCHAR,@proc_start,121);
    PRINT '====================================================';

    BEGIN TRY

    /*=========================================================
        STEP 1 : TRUNCATE TARGET TABLE
    =========================================================*/
        SET @step_start = GETDATE();

        PRINT 'STEP 1 : TRUNCATING silver.crm_sales';

        TRUNCATE TABLE silver.crm_sales;

        SET @step_end = GETDATE();

        PRINT 'STEP 1 COMPLETED IN '
            + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
            + ' ms';

    /*=========================================================
        STEP 2 : LOG DATA QUALITY ISSUES
    =========================================================*/
        SET @step_start = GETDATE();

        PRINT 'STEP 2 : CHECKING DATA QUALITY';

        INSERT INTO silver.data_quality_issues
        (
            source_table,
            record_id,
            issue_type,
            issue_description
        )
        SELECT
            'bronze.crm_sales_details',
            order_id,
            'Missing Keys',
            'Mandatory keys missing'
        FROM bronze.crm_sales_details
        WHERE NULLIF(TRIM(order_id),'') IS NULL;

        PRINT CAST(@@ROWCOUNT AS VARCHAR)
            + ' DATA QUALITY ISSUES DETECTED';

        SET @step_end = GETDATE();

        PRINT 'STEP 2 COMPLETED IN '
            + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
            + ' ms';

    /*=========================================================
        STEP 3 : LOAD CLEAN SALES DATA
    =========================================================*/
        SET @step_start = GETDATE();

        PRINT 'STEP 3 : LOADING SALES DATA';

        ;WITH cte AS
        (
            SELECT *,
                   ROW_NUMBER() OVER
                   (
                       PARTITION BY TRIM(order_id)
                       ORDER BY order_id
                   ) rn
            FROM bronze.crm_sales_details
        )
        INSERT INTO silver.crm_sales
        (
            order_id,
            customer_key,
            product_id,
            date_id,
            region_id,
            payment_id,
            quantity,
            unit_price,
            discount,
            total_amount,
            profit
        )
        SELECT
            TRIM(order_id),
            TRIM(customer_id),
            TRIM(product_id),
            TRIM(date_id),
            TRIM(region_id),
            TRIM(payment_id),

            CASE
                WHEN quantity BETWEEN 1 AND 10000
                    THEN quantity
                ELSE NULL
            END,

            CASE
                WHEN unit_price BETWEEN 0.01 AND 1000000
                    THEN unit_price
                ELSE NULL
            END,

            CASE
                WHEN discount < 0 THEN 0
                WHEN discount > 100 THEN 100
                ELSE discount
            END,

            (quantity * unit_price * (1 - discount / 100.0)),

            CASE
                WHEN profit BETWEEN -1000000 AND 1000000
                    THEN profit
                ELSE NULL
            END

        FROM cte
        WHERE rn = 1;

        SET @rows_loaded = @@ROWCOUNT;

        SET @step_end = GETDATE();

        PRINT CAST(@rows_loaded AS VARCHAR)
            + ' SALES RECORDS LOADED';

        PRINT 'STEP 3 COMPLETED IN '
            + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
            + ' ms';

    /*=========================================================
        FINAL MONITORING
    =========================================================*/
        SET @proc_end = GETDATE();

        SET @execution_time_sec =
            DATEDIFF(SECOND,@proc_start,@proc_end);

        INSERT INTO silver.etl_log
        (
            procedure_name,
            start_time,
            end_time,
            rows_loaded,
            status,
            error_message
        )
        VALUES
        (
            'load_crm_sales',
            @proc_start,
            @proc_end,
            @rows_loaded,
            'SUCCESS',
            NULL
        );

        PRINT '----------------------------------------------------';
        PRINT 'PROCEDURE COMPLETED SUCCESSFULLY';
        PRINT 'ROWS LOADED : ' + CAST(@rows_loaded AS VARCHAR);
        PRINT 'TOTAL EXECUTION TIME : '
            + CAST(@execution_time_sec AS VARCHAR)
            + ' SECOND(S)';
        PRINT 'END TIME : '
            + CONVERT(VARCHAR,@proc_end,121);
        PRINT '====================================================';

    END TRY

    BEGIN CATCH

        SET @proc_end = GETDATE();

        INSERT INTO silver.etl_log
        (
            procedure_name,
            start_time,
            end_time,
            rows_loaded,
            status,
            error_message
        )
        VALUES
        (
            'load_crm_sales',
            @proc_start,
            @proc_end,
            0,
            'FAILED',
            ERROR_MESSAGE()
        );

        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
        PRINT 'ERROR OCCURRED';
        PRINT ERROR_MESSAGE();
        PRINT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

        THROW;

    END CATCH

END;
GO

/*==============================================================
 5. CRM PRODUCTS - SILVER LOAD
==============================================================*/
CREATE OR ALTER PROCEDURE silver.load_crm_products
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_start DATETIME2 = GETDATE();
    DECLARE @proc_end DATETIME2;
    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;
    DECLARE @rows_loaded INT = 0;
    DECLARE @execution_time_sec INT;

    PRINT '====================================================';
    PRINT 'STARTING PROCEDURE : silver.load_crm_products';
    PRINT '====================================================';

    BEGIN TRY

        SET @step_start = GETDATE();

        PRINT 'STEP 1 : TRUNCATING silver.crm_products';

        TRUNCATE TABLE silver.crm_products;

        SET @step_end = GETDATE();

        PRINT 'STEP 1 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @step_start = GETDATE();

        PRINT 'STEP 2 : LOADING PRODUCT DATA';

        INSERT INTO silver.crm_products
        (
            product_id,
            product_name,
            category,
            brand,
            cost_price,
            selling_price
        )
        SELECT
            TRIM(product_id),
            COALESCE(NULLIF(TRIM(product_name),''),'Unknown'),
            COALESCE(NULLIF(TRIM(category),''),'Unknown'),
            COALESCE(NULLIF(TRIM(brand),''),'Unknown'),
            CASE WHEN cost_price < 0 THEN NULL ELSE cost_price END,
            CASE WHEN selling_price < cost_price THEN NULL ELSE selling_price END
        FROM bronze.crm_product_info;

        SET @rows_loaded = @@ROWCOUNT;

        SET @step_end = GETDATE();

        PRINT CAST(@rows_loaded AS VARCHAR)
              + ' PRODUCTS LOADED';

        PRINT 'STEP 2 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @proc_end = GETDATE();

        SET @execution_time_sec =
            DATEDIFF(SECOND,@proc_start,@proc_end);

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_products',
            @proc_start,
            @proc_end,
            @rows_loaded,
            'SUCCESS',
            NULL
        );

        PRINT 'TOTAL EXECUTION TIME : '
              + CAST(@execution_time_sec AS VARCHAR)
              + ' SECOND(S)';

    END TRY
    BEGIN CATCH

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_products',
            @proc_start,
            GETDATE(),
            0,
            'FAILED',
            ERROR_MESSAGE()
        );

        PRINT ERROR_MESSAGE();

        THROW;

    END CATCH
END;
GO

/*==============================================================
 6. CRM PAYEMENTS - SILVER LOAD
==============================================================*/
CREATE OR ALTER PROCEDURE silver.load_crm_payments
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_start DATETIME2 = GETDATE();
    DECLARE @proc_end DATETIME2;
    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;
    DECLARE @rows_loaded INT = 0;
    DECLARE @execution_time_sec INT;

    PRINT '====================================================';
    PRINT 'STARTING PROCEDURE : silver.load_crm_payments';
    PRINT '====================================================';

    BEGIN TRY

        SET @step_start = GETDATE();

        PRINT 'STEP 1 : TRUNCATING silver.crm_payments';

        TRUNCATE TABLE silver.crm_payments;

        SET @step_end = GETDATE();

        PRINT 'STEP 1 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @step_start = GETDATE();

        PRINT 'STEP 2 : LOADING PAYMENT DATA';

        INSERT INTO silver.crm_payments
        (
            payment_id,
            payment_method,
            payment_status
        )
        SELECT
            TRIM(payment_id),
            UPPER(TRIM(payment_method)),
            UPPER(TRIM(payment_status))
        FROM bronze.crm_payments_details;

        SET @rows_loaded = @@ROWCOUNT;

        SET @step_end = GETDATE();

        PRINT CAST(@rows_loaded AS VARCHAR)
              + ' PAYMENTS LOADED';

        PRINT 'STEP 2 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @proc_end = GETDATE();

        SET @execution_time_sec =
            DATEDIFF(SECOND,@proc_start,@proc_end);

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_payments',
            @proc_start,
            @proc_end,
            @rows_loaded,
            'SUCCESS',
            NULL
        );

        PRINT 'TOTAL EXECUTION TIME : '
              + CAST(@execution_time_sec AS VARCHAR)
              + ' SECOND(S)';

    END TRY
    BEGIN CATCH

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_payments',
            @proc_start,
            GETDATE(),
            0,
            'FAILED',
            ERROR_MESSAGE()
        );

        PRINT ERROR_MESSAGE();

        THROW;

    END CATCH
END;
GO

/*==============================================================
 7. CRM REGIONS - SILVER LOAD
==============================================================*/
CREATE OR ALTER PROCEDURE silver.load_crm_regions
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_start DATETIME2 = GETDATE();
    DECLARE @proc_end DATETIME2;
    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;
    DECLARE @rows_loaded INT = 0;
    DECLARE @execution_time_sec INT;

    PRINT '====================================================';
    PRINT 'STARTING PROCEDURE : silver.load_crm_regions';
    PRINT '====================================================';

    BEGIN TRY

        SET @step_start = GETDATE();

        PRINT 'STEP 1 : TRUNCATING silver.crm_regions';

        TRUNCATE TABLE silver.crm_regions;

        SET @step_end = GETDATE();

        PRINT 'STEP 1 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @step_start = GETDATE();

        PRINT 'STEP 2 : LOADING REGION DATA';

        INSERT INTO silver.crm_regions
        (
            region_id,
            region_name,
            country
        )
        SELECT
            TRIM(region_id),
            UPPER(TRIM(region_name)),
            UPPER(TRIM(country))
        FROM bronze.crm_region_info;

        SET @rows_loaded = @@ROWCOUNT;

        SET @step_end = GETDATE();

        PRINT CAST(@rows_loaded AS VARCHAR)
              + ' REGIONS LOADED';

        PRINT 'STEP 2 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @proc_end = GETDATE();

        SET @execution_time_sec =
            DATEDIFF(SECOND,@proc_start,@proc_end);

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_regions',
            @proc_start,
            @proc_end,
            @rows_loaded,
            'SUCCESS',
            NULL
        );

    END TRY
    BEGIN CATCH

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_regions',
            @proc_start,
            GETDATE(),
            0,
            'FAILED',
            ERROR_MESSAGE()
        );

        PRINT ERROR_MESSAGE();

        THROW;

    END CATCH
END;
GO

/*==============================================================
 8. CRM DATE - SILVER LOAD
==============================================================*/
CREATE OR ALTER PROCEDURE silver.load_crm_date
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_start DATETIME2 = GETDATE();
    DECLARE @proc_end DATETIME2;
    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;
    DECLARE @rows_loaded INT = 0;
    DECLARE @execution_time_sec INT;

    PRINT '====================================================';
    PRINT 'STARTING PROCEDURE : silver.load_crm_date';
    PRINT '====================================================';

    BEGIN TRY

        SET @step_start = GETDATE();

        PRINT 'STEP 1 : TRUNCATING silver.crm_date';

        TRUNCATE TABLE silver.crm_date;

        SET @step_end = GETDATE();

        PRINT 'STEP 1 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @step_start = GETDATE();

        PRINT 'STEP 2 : LOADING DATE DIMENSION';

        INSERT INTO silver.crm_date
        (
            date_id,
            full_date,
            day_number,
            month_number,
            year_number,
            quarter_number
        )
        SELECT
            TRIM(date_id),
            TRY_CONVERT(DATE,full_date),
            day_number,
            month_number,
            year_number,
            quarter_number
        FROM bronze.crm_date_details;

        SET @rows_loaded = @@ROWCOUNT;

        SET @step_end = GETDATE();

        PRINT CAST(@rows_loaded AS VARCHAR)
              + ' DATE RECORDS LOADED';

        PRINT 'STEP 2 COMPLETED IN '
              + CAST(DATEDIFF(MILLISECOND,@step_start,@step_end) AS VARCHAR)
              + ' ms';

        SET @proc_end = GETDATE();

        SET @execution_time_sec =
            DATEDIFF(SECOND,@proc_start,@proc_end);

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_date',
            @proc_start,
            @proc_end,
            @rows_loaded,
            'SUCCESS',
            NULL
        );

        PRINT 'TOTAL EXECUTION TIME : '
              + CAST(@execution_time_sec AS VARCHAR)
              + ' SECOND(S)';

    END TRY
    BEGIN CATCH

        INSERT INTO silver.etl_log
        VALUES
        (
            'load_crm_date',
            @proc_start,
            GETDATE(),
            0,
            'FAILED',
            ERROR_MESSAGE()
        );

        PRINT ERROR_MESSAGE();

        THROW;

    END CATCH
END;
GO



/*==============================================================
    MASTER ORCHESTRATOR
==============================================================*/

CREATE OR ALTER PROCEDURE silver.load_silver_all
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @pipeline_start DATETIME2 = GETDATE();
    DECLARE @pipeline_end DATETIME2;

    PRINT '====================================================';
    PRINT 'STARTING SILVER LAYER PIPELINE';
    PRINT 'START TIME : ' + CONVERT(VARCHAR,@pipeline_start,120);
    PRINT '====================================================';

    EXEC silver.load_crm_customers;
    EXEC silver.load_crm_sales;
    EXEC silver.load_crm_products;
    EXEC silver.load_crm_payments;
    EXEC silver.load_crm_regions;
    EXEC silver.load_crm_date;

    SET @pipeline_end = GETDATE();

    PRINT '====================================================';
    PRINT 'SILVER PIPELINE COMPLETED SUCCESSFULLY';
    PRINT 'TOTAL PIPELINE DURATION : '
        + CAST(DATEDIFF(SECOND,@pipeline_start,@pipeline_end) AS VARCHAR)
        + ' SECOND(S)';
    PRINT 'END TIME : '
        + CONVERT(VARCHAR,@pipeline_end,120);
    PRINT '====================================================';

END;
GO



