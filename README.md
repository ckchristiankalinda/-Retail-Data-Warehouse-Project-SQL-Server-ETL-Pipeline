# 🏗️ Retail Data Warehouse using SQL Server | Medallion Architecture

<p align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-TSQL-red?style=for-the-badge\&logo=microsoftsqlserver)
![ETL](https://img.shields.io/badge/ETL-Pipeline-green?style=for-the-badge)
![Data Warehouse](https://img.shields.io/badge/Data%20Warehouse-Medallion-blue?style=for-the-badge)
![Data Quality](https://img.shields.io/badge/Data%20Quality-Framework-orange?style=for-the-badge)
![Power BI](https://img.shields.io/badge/Power%20BI-Analytics-yellow?style=for-the-badge\&logo=powerbi)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

</p>

---

# 📌 Project Overview

This project demonstrates the design and implementation of a complete **Retail Data Warehouse Solution** using **SQL Server** and the **Medallion Architecture (Bronze → Silver → Gold)**.

The objective was to transform raw retail CSV data into trusted analytical datasets ready for business intelligence reporting and dashboard development.

The solution includes:

✅ Data Ingestion

✅ ETL Development

✅ Data Cleaning & Standardization

✅ Data Quality Validation Framework

✅ ETL Monitoring & Logging

✅ Business Reporting Layer

✅ Analytical Views

✅ Power BI Ready Datasets

---

# 🎯 Business Problem

Retail companies often receive transactional data from multiple operational systems.

Raw data frequently contains:

* Missing values
* Duplicate records
* Invalid business information
* Inconsistent formatting
* Referential integrity issues

Without proper transformation, reporting becomes unreliable.

This project solves these challenges by implementing a structured Data Warehouse pipeline that ensures:

* Data reliability
* Data consistency
* Data governance
* Business-ready reporting

---

# 🏛️ Architecture

```text
                    CSV FILES
                         │
                         ▼
               ┌────────────────┐
               │ BRONZE LAYER   │
               │ Raw Data       │
               └────────────────┘
                         │
                         ▼
               ┌────────────────┐
               │ SILVER LAYER   │
               │ Data Cleaning  │
               │ Validation     │
               └────────────────┘
                         │
                         ▼
               ┌────────────────┐
               │ DATA QUALITY   │
               │ FRAMEWORK      │
               └────────────────┘
                         │
                         ▼
               ┌────────────────┐
               │ GOLD LAYER     │
               │ Business KPIs  │
               └────────────────┘
                         │
                         ▼
                 POWER BI DASHBOARD
```

---

# 📂 Project Structure

```text
Retail-Data-Warehouse-SQL/

│
├── datasets/
│   ├── customer_info.csv
│   ├── sales_details.csv
│   ├── product_info.csv
│   ├── payment_details.csv
│   ├── region_info.csv
│   └── date_details.csv
│
├── scripts/
│
│   ├── bronze/
│   │   ├── 01_bronze_tables.sql
│   │   └── 02_bronze_load_procedures.sql
│   │
│   ├── silver/
│   │   ├── 01_silver_tables.sql
│   │   ├── 02_silver_etl.sql
│   │   └── 03_data_quality_checks.sql
│   │
│   ├── gold/
│   │   ├── 01_gold_reports.sql
│   │   └── 02_gold_views.sql
│   │
│   └── execution/
│       └── final_execution.sql
│
├── screenshots/
│
├── docs/
│   └── architecture_diagram.png
│
└── README.md
```

---

# 🥉 Bronze Layer

## Purpose

Store raw source data exactly as received from CSV files.

No transformations are applied at this stage.

## Source Tables

| Table                | Description          |
| -------------------- | -------------------- |
| crm_customers        | Customer Information |
| crm_sales_details    | Sales Transactions   |
| crm_product_info     | Product Catalog      |
| crm_payments_details | Payment Information  |
| crm_region_info      | Geographic Regions   |
| crm_date_details     | Date Dimension       |

---

## Bronze Features

* BULK INSERT loading
* CSV ingestion
* Execution monitoring
* Row count validation
* Error handling
* Load duration tracking

---

# 🥈 Silver Layer

## Purpose

Transform raw data into clean, validated and standardized business entities.

---

## Data Cleaning Rules

### Customers

* Duplicate removal
* Gender standardization
* Country standardization
* Age validation (0–120)
* Missing value handling
* Future date validation

### Sales

* Duplicate order removal
* Quantity validation
* Discount normalization
* Sales amount recalculation
* Profit validation

### Products

* Missing value replacement
* Cost validation
* Selling price validation

### Payments

* Standardized payment methods
* Standardized payment statuses

### Regions

* Standardized region names
* Standardized country names

### Dates

* Date validation using TRY_CONVERT()

---

# 🔍 Data Quality Framework

A complete Data Quality Validation Framework was developed before Gold Layer execution.

---

## Quality Tests

### Customer Validation

* Null Customer Keys
* Duplicate Customers
* Invalid Age
* Future Signup Dates

### Sales Validation

* Duplicate Orders
* Invalid Quantity
* Invalid Unit Price
* Invalid Discounts

### Product Validation

* Invalid Product Pricing

### Referential Integrity

* Sales without Customers
* Sales without Products
* Sales without Regions
* Sales without Payments

---

## Monitoring Tables

### silver.etl_log

Tracks:

* Procedure Name
* Start Time
* End Time
* Rows Loaded
* Execution Status
* Error Messages

---

### silver.data_quality_issues

Stores:

* Source Table
* Record Identifier
* Issue Type
* Issue Description
* Detection Date

---

### silver.data_quality_test_results

Stores:

* Test Name
* Failed Records
* PASS / FAIL Status
* Execution Date

---

# 🥇 Gold Layer

## Purpose

Create business-ready datasets optimized for reporting and analytics.

---

## Customer Report

### Metrics

* Total Orders
* Total Quantity Purchased
* Total Sales
* Total Profit
* Average Order Value
* Last Order Date

### Customer Segmentation

* Under 18
* 18–25
* 26–35
* 36–50
* 50+

---

## Product Report

### Metrics

* Total Orders
* Total Quantity Sold
* Total Sales
* Total Profit
* Profit Margin %

---

# 📊 Analytical Views

---

## gold.v_report_sales

Enterprise Sales Dataset combining:

* Customers
* Products
* Regions
* Payments
* Dates
* Sales Transactions

Used for Power BI reporting.

---

## gold.v_executive_dashboard

Executive KPI View

### KPIs

* Total Orders
* Total Customers
* Total Products
* Total Quantity Sold
* Total Revenue
* Total Profit
* Average Order Value
* Profit Margin

---

# ⚙️ Pipeline Execution

```sql
-- Load Bronze Layer
EXEC bronze.load_bronze_all;
GO
-- Load Silver Layer
EXEC silver.load_silver_all;
GO

-- Run Data Quality Tests
EXEC silver.run_data_quality_checks;
GO

-- Load Gold Layer
EXEC gold.load_gold_all;
GO

-- Analytics Queries
SELECT * FROM gold.report_customer;
SELECT * FROM gold.report_product;
SELECT * FROM gold.v_report_sales;
SELECT * FROM gold.v_executive_dashboard;
```

---

# 🚀 Technical Skills Demonstrated

### Data Engineering

* ETL Development
* Data Warehousing
* Medallion Architecture
* Data Quality Framework
* ETL Monitoring

### SQL Development

* Stored Procedures
* Views
* CTEs
* Window Functions
* TRY/CATCH
* BULK INSERT
* Data Validation

### Business Intelligence

* KPI Development
* Customer Analytics
* Product Analytics
* Executive Reporting
* Power BI Integration

---

# 🛠️ Technologies Used

* SQL Server
* T-SQL
* Data Warehouse Design
* ETL Development
* Power BI
* GitHub

---

# 👨‍💻 Author

## Mutia Kalinda Christian

**Data Analyst | BI Developer | Data Science Learner**

### Skills

* SQL Server
* Power BI
* Tableau
* Python
* Data Warehousing
* ETL Development
* Data Analytics

### Certifications

* Data Science with AI — Digital Regenesys
* Data Management Using MySQL — Digital Regenesys
* Tableau Business Intelligence — Digital Regenesys
* MongoDB Fundamentals — Digital Regenesys
* Spreadsheet Essentials with Excel — Digital Regenesys
* Data Analytics Bootcamp — Alex The Analyst
* Data Analyst Bootcamp — Alex The Analyst

---

⭐ If you found this project useful, feel free to star the repository.

