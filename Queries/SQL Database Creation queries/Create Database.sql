-- Create Database
-- USE chooses specific database, we start from master
USE [master];
GO

-- Creating a database names Olist
IF DB_ID(N'OlistDB') IS NULL -- Checks if database with similar name exists
BEGIN
    EXEC(N'CREATE DATABASE [OlistDB]');
END;
GO 

-- Choosing new database
USE [OlistDB];
GO

-- SET NOCOUNT ON hides repeated "rows affected" messages while thousands of rows load.
SET NOCOUNT ON;

-- SET XACT_ABORT ON makes SQL Server roll back the transaction if a runtime error occurs.
SET XACT_ABORT ON;

-- SCHEMA_ID checks whether the olist_project schema already exists.
-- If it exists, RAISERROR stops the script before any tables or rows are changed.
IF SCHEMA_ID(N'OlistDB') IS NOT NULL
BEGIN
    RAISERROR(N'The OlistDB schema already exists in OlistProject. The setup has not been run again.', 16, 1);
    RETURN;
END;