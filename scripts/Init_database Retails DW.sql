
/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'Retails_DW' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'Retails_DW' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/



USE MASTER;
GO
-- Drop and recreate the 'Retails_DW' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Retails_DW')
BEGIN
    ALTER DATABASE Retails_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Retails_DW;
END;
GO

-- Create the 'Retails_DWe' database

CREATE DATABASE Retails_DW;
GO

USE Retails_DW;
GO
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;

GO;

