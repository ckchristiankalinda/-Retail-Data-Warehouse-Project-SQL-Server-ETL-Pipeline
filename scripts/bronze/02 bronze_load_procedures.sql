/*=============================================================================
 FILE NAME: bronze_load_procedures.sql

 DESCRIPTION:
 Loads source CSV files into Bronze tables using BULK INSERT.

 FEATURES:
 - Bulk data ingestion
 - Execution monitoring
 - Row count tracking
 - Error handling

=============================================================================*/
/*==============================================================
    SCHEMA ETL
==============================================================*/
IF NOT EXISTS (
    SELECT * 
    FROM sys.schemas
    WHERE name = 'etl'
)
BEGIN
    EXEC('CREATE SCHEMA etl');
END
GO


/*==============================================================
    STORED PROCEDURE: bronze.load_crm_customers
    DESCRIPTION:
        Load raw customer data into Bronze layer
        Includes execution time tracking
==============================================================*/
CREATE OR ALTER PROCEDURE bronze.load_crm_customers
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @row_count INT;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '=========================================';
        PRINT 'LOADING BRONZE: crm_customers';
        PRINT '=========================================';

        -- Step 1: Clean table
        TRUNCATE TABLE bronze.crm_customers;

        -- Step 2: Load CSV
        BULK INSERT bronze.crm_customers
        FROM 'D:\My Lessons\SQL\retail_dw_dataset\customer_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK,
            CODEPAGE = '65001'
        );

        -- Step 3: Validation
        SELECT @row_count = COUNT(*) FROM bronze.crm_customers;

        SET @batch_end_time = GETDATE();

        PRINT 'Rows Loaded: ' + CAST(@row_count AS NVARCHAR);
        PRINT 'Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);

        PRINT 'BRONZE crm_customers LOAD COMPLETED';

    END TRY
    BEGIN CATCH
        PRINT 'ERROR DURING LOAD crm_customers';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO



/*==============================================================
    STORED PROCEDURE: bronze.load_crm_date_details
==============================================================*/
CREATE OR ALTER PROCEDURE bronze.load_crm_date_details
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @row_count INT;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT 'LOADING BRONZE: crm_date_details';

        TRUNCATE TABLE bronze.crm_date_details;

        BULK INSERT bronze.crm_date_details
        FROM 'D:\My Lessons\SQL\retail_dw_dataset\date_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT @row_count = COUNT(*) FROM bronze.crm_date_details;

        SET @batch_end_time = GETDATE();

        PRINT 'Rows Loaded: ' + CAST(@row_count AS NVARCHAR);
        PRINT 'Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);

        PRINT 'BRONZE crm_date_details LOAD COMPLETED';

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO



/*==============================================================
    STORED PROCEDURE: bronze.load_crm_payments_details
==============================================================*/
CREATE OR ALTER PROCEDURE bronze.load_crm_payments_details
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @row_count INT;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT 'LOADING BRONZE: crm_payments_details';

        TRUNCATE TABLE bronze.crm_payments_details;

        BULK INSERT bronze.crm_payments_details
        FROM 'D:\My Lessons\SQL\retail_dw_dataset\payment_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT @row_count = COUNT(*) FROM bronze.crm_payments_details;

        SET @batch_end_time = GETDATE();

        PRINT 'Rows Loaded: ' + CAST(@row_count AS NVARCHAR);
        PRINT 'Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);

        PRINT 'BRONZE crm_payments_details LOAD COMPLETED';

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO



/*==============================================================
    STORED PROCEDURE: bronze.load_crm_product_info
==============================================================*/
CREATE OR ALTER PROCEDURE bronze.load_crm_product_info
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @row_count INT;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT 'LOADING BRONZE: crm_product_info';

        TRUNCATE TABLE bronze.crm_product_info;

        BULK INSERT bronze.crm_product_info
        FROM 'D:\My Lessons\SQL\retail_dw_dataset\product_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT @row_count = COUNT(*) FROM bronze.crm_product_info;

        SET @batch_end_time = GETDATE();

        PRINT 'Rows Loaded: ' + CAST(@row_count AS NVARCHAR);
        PRINT 'Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);

        PRINT 'BRONZE crm_product_info LOAD COMPLETED';

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO



/*==============================================================
    STORED PROCEDURE: bronze.load_crm_region_info
==============================================================*/
CREATE OR ALTER PROCEDURE bronze.load_crm_region_info
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @row_count INT;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT 'LOADING BRONZE: crm_region_info';

        TRUNCATE TABLE bronze.crm_region_info;

        BULK INSERT bronze.crm_region_info
        FROM 'D:\My Lessons\SQL\retail_dw_dataset\region_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT @row_count = COUNT(*) FROM bronze.crm_region_info;

        SET @batch_end_time = GETDATE();

        PRINT 'Rows Loaded: ' + CAST(@row_count AS NVARCHAR);
        PRINT 'Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);

        PRINT 'BRONZE crm_region_info LOAD COMPLETED';

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO



/*==============================================================
    STORED PROCEDURE: bronze.load_crm_sales_details
==============================================================*/
CREATE OR ALTER PROCEDURE bronze.load_crm_sales_details
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @row_count INT;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT 'LOADING BRONZE: crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'D:\My Lessons\SQL\retail_dw_dataset\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT @row_count = COUNT(*) FROM bronze.crm_sales_details;

        SET @batch_end_time = GETDATE();

        PRINT 'Rows Loaded: ' + CAST(@row_count AS NVARCHAR);
        PRINT 'Duration (seconds): ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);

        PRINT 'BRONZE crm_sales_details LOAD COMPLETED';

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze_all
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @pipeline_start DATETIME2 = GETDATE();
    DECLARE @pipeline_end DATETIME2;

    PRINT '====================================================';
    PRINT 'STARTING BRONZE LAYER PIPELINE';
    PRINT 'START TIME : ' + CONVERT(VARCHAR,@pipeline_start,120);
    PRINT '====================================================';

    EXEC bronze.load_crm_customers;
    EXEC bronze.load_crm_sales_details;
    EXEC bronze.load_crm_product_info;
    EXEC bronze.load_crm_payments_details;
    EXEC bronze.load_crm_region_info;
    EXEC bronze.load_crm_date_details;

    SET @pipeline_end = GETDATE();

    PRINT '====================================================';
    PRINT 'BRONZE PIPELINE COMPLETED SUCCESSFULLY';
    PRINT 'TOTAL PIPELINE DURATION : '
        + CAST(DATEDIFF(SECOND,@pipeline_start,@pipeline_end) AS VARCHAR)
        + ' SECOND(S)';
    PRINT 'END TIME : '
        + CONVERT(VARCHAR,@pipeline_end,120);
    PRINT '====================================================';

END;
GO
