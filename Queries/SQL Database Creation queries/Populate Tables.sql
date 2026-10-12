-- Populate Database with a csv files

USE [OlistDB];
GO

-- SET NOCOUNT ON hides repeated 'rows affected' messages while thousands of rows load.
SET NOCOUNT ON;
-- SET XACT_ABORT ON makes SQL Server roll back the transaction if a runtime error occurs.
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRANSACTION;

-- Insert first parent tables
-- Warning: When running script, change Path to the actual location of files
-- Use ROWTERMINATOR = '0x0a' because original csv files were created using unix-system.
-- CODEPAGE = '65001' for UTF-8 encoding to read brasilian characters

BULK INSERT olist.customers FROM 'Path\OLIST Project\data\olist_customers_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

BULK INSERT olist.products FROM 'Path\OLIST Project\data\olist_products_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

BULK INSERT olist.sellers FROM 'Path\OLIST Project\data\olist_sellers_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

BULK INSERT olist.category_translation FROM 'Path\OLIST Project\data\product_category_name_translation.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );


-- geolocation needs additional step, since it contains new column
EXEC('CREATE VIEW olist.vw_bulk_geolocation AS
SELECT 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM olist.geolocation;')

BULK INSERT olist.vw_bulk_geolocation
FROM 'Path\OLIST Project\data\olist_geolocation_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a',CODEPAGE = '65001', TABLOCK );


BULK INSERT olist.marketing_qualified_leads FROM 'Path\OLIST Project\data\Marketing funnel\olist_marketing_qualified_leads_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

-- Insert child tables
BULK INSERT olist.orders FROM 'Path\OLIST Project\data\olist_orders_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

BULK INSERT olist.order_items FROM 'Path\OLIST Project\data\olist_order_items_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

BULK INSERT olist.payments 
FROM 'Path\OLIST Project\data\olist_order_payments_clean.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

BULK INSERT olist.reviews FROM 'Path\OLIST Project\data\olist_order_reviews_clean.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2,  ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

BULK INSERT olist.closed_deals FROM 'Path\OLIST Project\data\Marketing funnel\olist_closed_deals_dataset.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK );

-- This verifies all expected row counts before making the transaction permanent.
IF (SELECT COUNT_BIG(*) FROM olist.orders) <> 99441 RAISERROR(N'Unexpected row count in orders.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.order_items) <> 112650 RAISERROR(N'Unexpected row count in order_items.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.reviews) <> 99224 RAISERROR(N'Unexpected row count in reviews.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.customers) <> 99441 RAISERROR(N'Unexpected row count in customers.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.products) <> 32951 RAISERROR(N'Unexpected row count in products.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.sellers) <> 3095 RAISERROR(N'Unexpected row count in sellers.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.payments) <> 103886 RAISERROR(N'Unexpected row count in payments.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.category_translation) <> 71 RAISERROR(N'Unexpected row count in category_translation.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.geolocation) <> 1000163 RAISERROR(N'Unexpected row count in geolocation.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.closed_deals) <> 842 RAISERROR(N'Unexpected row count in closed_deals.', 16, 1);
IF (SELECT COUNT_BIG(*) FROM olist.marketing_qualified_leads) <> 8000 RAISERROR(N'Unexpected row count in marketing_qualified_leads.', 16, 1);

COMMIT;
PRINT 'Data load completed and validated successfully.';

END TRY
-- If Commit wasn't succesful we can catch it using @@TRANCOUNT. 
-- Begin Transaction increments count by 1, Commit decreases it by 1.
-- By the end, we had 1 begin and 1 commit, so count should be 0.
BEGIN CATCH
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SELECT 
    ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH
GO

-- Compare the displayed values with the expected counts shown in the comments.
SELECT 'customers' AS TableName, COUNT_BIG(*) AS Actual, 99441 AS Expected FROM olist.customers
UNION ALL SELECT 'products', COUNT_BIG(*), 32951 FROM olist.products
UNION ALL SELECT 'sellers', COUNT_BIG(*), 3095 FROM olist.sellers
UNION ALL SELECT 'category_translation', COUNT_BIG(*), 71 FROM olist.category_translation
UNION ALL SELECT 'geolocation', COUNT_BIG(*), 1000163 FROM olist.geolocation
UNION ALL SELECT 'marketing_qualified_leads', COUNT_BIG(*), 8000 FROM olist.marketing_qualified_leads
UNION ALL SELECT 'orders', COUNT_BIG(*), 99441 FROM olist.orders
UNION ALL SELECT 'order_items', COUNT_BIG(*), 112650 FROM olist.order_items
UNION ALL SELECT 'payments', COUNT_BIG(*), 103886 FROM olist.payments
UNION ALL SELECT 'closed_deals', COUNT_BIG(*), 842 FROM olist.closed_deals
UNION ALL SELECT 'reviews', COUNT_BIG(*), 99224 FROM olist.reviews;