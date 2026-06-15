/*==============================================================
    SILVER LAYER DATA QUALITY TESTING (FIXED VERSION)
==============================================================*/

PRINT '=========================================';
PRINT 'SILVER DATA QUALITY TESTS STARTED';
PRINT '=========================================';

--------------------------------------------------------------
-- TEST 1 : CUSTOMER KEY NULL CHECK
--------------------------------------------------------------
PRINT 'TEST 1 : CUSTOMER KEY NULL CHECK';

SELECT COUNT(*) AS null_customer_keys
FROM silver.crm_customers
WHERE customer_key IS NULL
   OR LTRIM(RTRIM(customer_key)) = '';

--------------------------------------------------------------
-- TEST 2 : DUPLICATE CUSTOMERS
--------------------------------------------------------------
PRINT 'TEST 2 : DUPLICATE CUSTOMERS';

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM silver.crm_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

--------------------------------------------------------------
-- TEST 3 : INVALID AGE
--------------------------------------------------------------
PRINT 'TEST 3 : INVALID AGE';

SELECT *
FROM silver.crm_customers
WHERE age IS NULL
   OR age < 0
   OR age > 120;

--------------------------------------------------------------
-- TEST 4 : FUTURE SIGNUP DATE (SAFE)
--------------------------------------------------------------
PRINT 'TEST 4 : FUTURE SIGNUP DATE';

SELECT *
FROM silver.crm_customers
WHERE TRY_CONVERT(DATE, signup_date) > CAST(GETDATE() AS DATE);

--------------------------------------------------------------
-- TEST 5 : SALES DUPLICATES
--------------------------------------------------------------
PRINT 'TEST 5 : DUPLICATE SALES ORDERS';

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_sales
GROUP BY order_id
HAVING COUNT(*) > 1;

--------------------------------------------------------------
-- TEST 6 : INVALID QUANTITY
--------------------------------------------------------------
PRINT 'TEST 6 : INVALID QUANTITY';

SELECT *
FROM silver.crm_sales
WHERE quantity IS NULL
   OR quantity <= 0
   OR quantity > 10000;

--------------------------------------------------------------
-- TEST 7 : INVALID UNIT PRICE
--------------------------------------------------------------
PRINT 'TEST 7 : INVALID UNIT PRICE';

SELECT *
FROM silver.crm_sales
WHERE unit_price IS NULL
   OR unit_price <= 0;

--------------------------------------------------------------
-- TEST 8 : INVALID DISCOUNT
--------------------------------------------------------------
PRINT 'TEST 8 : INVALID DISCOUNT';

SELECT *
FROM silver.crm_sales
WHERE discount < 0
   OR discount > 100;

--------------------------------------------------------------
-- TEST 9 : NEGATIVE TOTAL SALES
--------------------------------------------------------------
PRINT 'TEST 9 : NEGATIVE SALES';

SELECT *
FROM silver.crm_sales
WHERE total_amount < 0;

--------------------------------------------------------------
-- TEST 10 : INVALID PROFIT
--------------------------------------------------------------
PRINT 'TEST 10 : INVALID PROFIT';

SELECT *
FROM silver.crm_sales
WHERE profit < -1000000
   OR profit > 1000000;

--------------------------------------------------------------
-- TEST 11 : PRODUCT KEY NULL
--------------------------------------------------------------
PRINT 'TEST 11 : PRODUCT KEY NULL';

SELECT *
FROM silver.crm_products
WHERE product_id IS NULL
   OR LTRIM(RTRIM(product_id)) = '';

--------------------------------------------------------------
-- TEST 12 : DUPLICATE PRODUCTS
--------------------------------------------------------------
PRINT 'TEST 12 : DUPLICATE PRODUCTS';

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_products
GROUP BY product_id
HAVING COUNT(*) > 1;

--------------------------------------------------------------
-- TEST 13 : NEGATIVE COST PRICE
--------------------------------------------------------------
PRINT 'TEST 13 : NEGATIVE COST PRICE';

SELECT *
FROM silver.crm_products
WHERE cost_price < 0;

--------------------------------------------------------------
-- TEST 14 : SELLING PRICE < COST PRICE
--------------------------------------------------------------
PRINT 'TEST 14 : INVALID PRODUCT PRICING';

SELECT *
FROM silver.crm_products
WHERE selling_price < cost_price;

--------------------------------------------------------------
-- TEST 15 : PAYMENT DUPLICATES
--------------------------------------------------------------
PRINT 'TEST 15 : DUPLICATE PAYMENTS';

SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

--------------------------------------------------------------
-- TEST 16 : REGION DUPLICATES
--------------------------------------------------------------
PRINT 'TEST 16 : DUPLICATE REGIONS';

SELECT
    region_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_regions
GROUP BY region_id
HAVING COUNT(*) > 1;

--------------------------------------------------------------
-- TEST 17 : DATE DUPLICATES
--------------------------------------------------------------
PRINT 'TEST 17 : DUPLICATE DATES';

SELECT
    date_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_date
GROUP BY date_id
HAVING COUNT(*) > 1;

--------------------------------------------------------------
-- TEST 18 : ORPHAN SALES - CUSTOMER
--------------------------------------------------------------
PRINT 'TEST 18 : SALES WITHOUT CUSTOMER';

SELECT *
FROM silver.crm_sales s
LEFT JOIN silver.crm_customers c
    ON s.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

--------------------------------------------------------------
-- TEST 19 : ORPHAN SALES - PRODUCT
--------------------------------------------------------------
PRINT 'TEST 19 : SALES WITHOUT PRODUCT';

SELECT *
FROM silver.crm_sales s
LEFT JOIN silver.crm_products p
    ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------------------
-- TEST 20 : ORPHAN SALES - PAYMENT
--------------------------------------------------------------
PRINT 'TEST 20 : SALES WITHOUT PAYMENT';

SELECT *
FROM silver.crm_sales s
LEFT JOIN silver.crm_payments p
    ON s.payment_id = p.payment_id
WHERE p.payment_id IS NULL;

--------------------------------------------------------------
-- TEST 21 : ORPHAN SALES - REGION
--------------------------------------------------------------
PRINT 'TEST 21 : SALES WITHOUT REGION';

SELECT *
FROM silver.crm_sales s
LEFT JOIN silver.crm_regions r
    ON s.region_id = r.region_id
WHERE r.region_id IS NULL;

--------------------------------------------------------------
-- TEST 22 : ORPHAN SALES - DATE
--------------------------------------------------------------
PRINT 'TEST 22 : SALES WITHOUT DATE';

SELECT *
FROM silver.crm_sales s
LEFT JOIN silver.crm_date d
    ON s.date_id = d.date_id
WHERE d.date_id IS NULL;

--------------------------------------------------------------
-- TEST 23 : SALES RECONCILIATION
--------------------------------------------------------------
PRINT 'TEST 23 : SALES RECONCILIATION';

SELECT
    SUM(total_amount) AS total_sales,
    SUM(profit) AS total_profit,
    COUNT(*) AS total_orders
FROM silver.crm_sales;

--------------------------------------------------------------
-- TEST 24 : ETL FAILURES
--------------------------------------------------------------
PRINT 'TEST 24 : ETL FAILURES';

SELECT *
FROM silver.etl_log
WHERE status = 'FAILED';

--------------------------------------------------------------
-- TEST 25 : DATA QUALITY ISSUES SUMMARY
--------------------------------------------------------------
PRINT 'TEST 25 : DATA QUALITY ISSUES SUMMARY';

SELECT
    issue_type,
    COUNT(*) AS total_issues
FROM silver.data_quality_issues
GROUP BY issue_type
ORDER BY total_issues DESC;

PRINT '=========================================';
PRINT 'SILVER DATA QUALITY TESTS COMPLETED';
PRINT '=========================================';