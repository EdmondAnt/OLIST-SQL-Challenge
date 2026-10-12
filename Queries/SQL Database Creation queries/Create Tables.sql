-- Choosing new database
USE [OlistDB];
GO

-- SET XACT_ABORT ON makes SQL Server roll back the transaction if a runtime error occurs.
SET XACT_ABORT ON;

-- SCHEMA_ID checks whether the olist schema already exists.
-- If it exists, RAISERROR stops the script before any tables or rows are changed.
IF SCHEMA_ID(N'olist') IS NOT NULL
BEGIN
    RAISERROR(N'The olist schema already exists in OlistProject. The setup has not been run again.', 16, 1);
    RETURN;
END;


-- A schema is a named container for related database objects.
-- Dynamic SQL is used because CREATE SCHEMA must be the only statement in its batch.
EXEC(N'CREATE SCHEMA olist');

BEGIN TRANSACTION;

-- CREATE TABLE defines the columns, data types and key for each project table.
-- Start by creating a parent tables, that doesn't require Foreign Keys

-- Customers
CREATE TABLE olist.customers ([customer_id] NVARCHAR(32) NOT NULL,
[customer_unique_id] NVARCHAR(32) NULL,
[customer_zip_code_prefix] NVARCHAR(255) NULL,
[customer_city] NVARCHAR(255) NULL,
[customer_state] NVARCHAR(255) NULL,
CONSTRAINT PK_customer_id PRIMARY KEY(customer_id));

-- Sellers
CREATE TABLE olist.sellers ([seller_id] NVARCHAR(32) NOT NULL,
[seller_zip_code_prefix] VARCHAR(5) NULL,
[seller_city] NVARCHAR(255) NULL,
[seller_state] NVARCHAR(255) NULL,
CONSTRAINT PK_seller_id PRIMARY KEY(seller_id));

-- Translations
CREATE TABLE olist.category_translation ([product_category_name] NVARCHAR(255) NOT NULL,
[product_category_name_english] NVARCHAR(255) NULL,
CONSTRAINT PK_translations PRIMARY KEY(product_category_name));

-- Geolocation
CREATE TABLE olist.geolocation ( geolocation_id INT IDENTITY(1,1) NOT NULL,  --Creating a surrogate id column
[geolocation_zip_code_prefix] VARCHAR(5) NOT NULL,
[geolocation_lat] DECIMAL(10,8) NOT NULL,
[geolocation_lng] DECIMAL(11,8) NOT NULL,
[geolocation_city] NVARCHAR(100) NOT NULL,
[geolocation_state] CHAR(2) NOT NULL
CONSTRAINT PK_geolocation_id PRIMARY KEY ([geolocation_id]));

-- Creating a non-clustered index to improve performance
CREATE NONCLUSTERED INDEX IX_geolocation_zip_code_prefix 
ON olist.geolocation (geolocation_zip_code_prefix)
INCLUDE (geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);
GO

-- Marketing Qualified Leads
CREATE TABLE olist.marketing_qualified_leads (
[mql_id]             NVARCHAR(32) NOT NULL,
[first_contact_date] DATETIME NULL,
[landing_page_id]    NVARCHAR(32) NULL,
[origin]             NVARCHAR(50) NULL, 
CONSTRAINT PK_marketing_qualified_leads PRIMARY KEY ([mql_id])
);

-- Create Child tables

-- Products

CREATE TABLE olist.products ([product_id] NVARCHAR(32) NOT NULL,
[product_category_name] NVARCHAR(255) NULL,
[product_name_lenght] INT NULL,
[product_description_lenght] INT NULL,
[product_photos_qty] INT NULL,
[product_weight_g] INT NULL,
[product_length_cm] INT NULL,
[product_height_cm] INT NULL,
[product_width_cm] INT NULL,
CONSTRAINT PK_product_id PRIMARY KEY(product_id),
CONSTRAINT FK_product_category_transl FOREIGN KEY ([product_category_name]) REFERENCES olist.category_translation([product_category_name])
);

-- Orders
CREATE TABLE olist.orders ([order_id] NVARCHAR(32) NOT NULL,
[customer_id] NVARCHAR(32) NULL,
[order_status] NVARCHAR(255) NULL,
[order_purchase_timestamp] DATETIME2(0) NULL,
[order_approved_at] DATETIME2(0) NULL,
[order_delivered_carrier_date] DATETIME2(0) NULL,
[order_delivered_customer_date] DATETIME2(0) NULL,
[order_estimated_delivery_date] DATETIME2(0) NULL,
CONSTRAINT PK_order_id PRIMARY KEY(order_id),
CONSTRAINT FK_orders_customers FOREIGN KEY ([customer_id]) REFERENCES olist.customers([customer_id])
);

-- Order_items
CREATE TABLE olist.order_items ([order_id] NVARCHAR(32) NOT NULL,
[order_item_id] INT NOT NULL,
[product_id] NVARCHAR(32) NULL,
[seller_id] NVARCHAR(32) NULL,
[shipping_limit_date] DATETIME2(0) NULL,
[price] DECIMAL(14,2) NULL,
[freight_value] DECIMAL(14,2) NULL,
CONSTRAINT PK_order_items PRIMARY KEY(order_id,order_item_id),
CONSTRAINT FK_orderitems_orders FOREIGN KEY ([order_id]) REFERENCES olist.orders([order_id]),
CONSTRAINT FK_orderitems_products FOREIGN KEY ([product_id]) REFERENCES olist.products([product_id]),
CONSTRAINT FK_order_items_sellers FOREIGN KEY ([seller_id]) REFERENCES olist.sellers([seller_id])
);

-- Payments
CREATE TABLE olist.payments ([order_id] NVARCHAR(32) NOT NULL,
[payment_sequential] INT NOT NULL,
[payment_type] NVARCHAR(255) NULL,
[payment_installments] INT NULL,
[payment_value] DECIMAL(14,2) NULL,
CONSTRAINT PK_payments PRIMARY KEY(order_id,payment_sequential),
CONSTRAINT FK_payments_orders FOREIGN KEY ([order_id]) REFERENCES olist.orders([order_id])
);

-- Reviews
CREATE TABLE olist.reviews ([review_id] NVARCHAR(32) NOT NULL,
[order_id] NVARCHAR(32) NOT NULL,
[review_score] INT NULL,
[review_comment_title] NVARCHAR(MAX) NULL,
[review_comment_message] NVARCHAR(MAX) NULL,
[review_creation_date] DATETIME2(0) NULL,
[review_answer_timestamp] DATETIME2(0) NULL,
CONSTRAINT PK_reviews PRIMARY KEY ([review_id], [order_id]),
CONSTRAINT FK_reviews_orders FOREIGN KEY ([order_id]) REFERENCES olist.orders([order_id]));

-- Closed_deals
CREATE TABLE olist.closed_deals (
[mql_id]                        NVARCHAR(32) NOT NULL,
[seller_id]                     NVARCHAR(32) NOT NULL,
[sdr_id]                        NVARCHAR(32) NULL,
[sr_id]                         NVARCHAR(32) NULL,
[won_date]                      DATETIME2 NULL,
[business_segment]              NVARCHAR(100) NULL,
[lead_type]                     NVARCHAR(100) NULL,
[lead_behaviour_profile]        NVARCHAR(100) NULL,
[has_company]                   NVARCHAR(10) NULL,                  -- TRUE/FALSE
[has_gtin]                      NVARCHAR(10) NULL,                  -- TRUE/FALSE
[average_stock]                 NVARCHAR(50) NULL,         -- Stored as range text in Olist (e.g., '1-5', '5-20')
[business_type]                 NVARCHAR(100) NULL,
[declared_product_catalog_size] DECIMAL(10,2) NULL,        -- Numeric count/size
[declared_monthly_revenue]      DECIMAL(14,2) NULL,        -- Currency value
CONSTRAINT PK_closed_deals PRIMARY KEY ([mql_id]),
-- Connect marketing funnel to the main dataset
CONSTRAINT FK_closed_deals_sellers FOREIGN KEY ([seller_id]) REFERENCES olist.sellers ([seller_id]),
CONSTRAINT FK_mql_id FOREIGN KEY ([mql_id]) REFERENCES olist.marketing_qualified_leads ([mql_id])
);

COMMIT;

-- Check that all tables are created, has correct names and data types
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'olist'
ORDER BY TABLE_NAME, ORDINAL_POSITION;