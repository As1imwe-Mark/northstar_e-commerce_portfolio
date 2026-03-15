--- Insert Data into Silver Layer tables
--- This stored procedure performs the transformation step of the Medallion Architecture
--- It cleans, standardizes and loads data from the Bronze layer into the Silver layer

CREATE PROCEDURE load_bronze AS
BEGIN
BEGIN TRY

--- =========================================================
--- CUSTOMERS TABLE
--- =========================================================
--- Remove existing records to allow a fresh reload of data
TRUNCATE TABLE bronze.customers;

BULK INSERT bronze.customers
FROM 'C:\Datasets\northstar_ecommerce_dataset_csv\customers.csv'
WITH (
    FORMAT = 'CSV',       
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    TABLOCK
);


--- =========================================================
--- MARKETING SPEND TABLE
--- =========================================================

--- Remove old data
TRUNCATE TABLE bronze.marketing_spend;

BULK INSERT bronze.marketing_spend
FROM 'C:\Datasets\northstar_ecommerce_dataset_csv\marketing_spend.csv'
WITH (
    FORMAT = 'CSV',       
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    TABLOCK
);


--- =========================================================
--- ORDER ITEMS TABLE
--- =========================================================

--- Remove existing records before load
TRUNCATE TABLE bronze.order_items;

BULK INSERT bronze.order_items
FROM 'C:\Datasets\northstar_ecommerce_dataset_csv\order_items.csv'
WITH (
    FORMAT = 'CSV',       
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    TABLOCK
);

--- =========================================================
--- ORDERS TABLE
--- =========================================================

--- Remove old order data
TRUNCATE TABLE bronze.orders;

BULK INSERT bronze.orders
FROM 'C:\Datasets\northstar_ecommerce_dataset_csv\orders.csv'
WITH (
    FORMAT = 'CSV',       
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    TABLOCK
);

--- =========================================================
--- PRODUCTS TABLE
--- =========================================================

--- Remove existing product data
TRUNCATE TABLE bronze.products;

BULK INSERT bronze.products
FROM 'C:\Datasets\northstar_ecommerce_dataset_csv\products.csv'
WITH (
    FORMAT = 'CSV',          
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    TABLOCK
);

--- =========================================================
--- RETURNS TABLE
--- =========================================================

--- Remove existing return data
TRUNCATE TABLE bronze.returns;

BULK INSERT bronze.returns
FROM 'C:\Datasets\northstar_ecommerce_dataset_csv\returns.csv'
WITH (
    FORMAT = 'CSV',       
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    TABLOCK
);
END TRY
BEGIN CATCH
PRINT'-----------------------------------------------------------------------------------------'
PRINT'A problem occurred when loading the tables in the bronze layer'
PRINT'Error Message'+ ERROR_MESSAGE()
PRINT'Error Message'+ CAST(ERROR_NUMBER() AS NVARCHAR)
PRINT'------------------------------------------------------------------------------------------'
END CATCH;
END;

--- Checking Data integrity
SELECT * FROM bronze.returns
SELECT * FROM bronze.customers
SELECT * FROM bronze.orders
SELECT * FROM bronze.marketing_spend
SELECT * FROM bronze.order_items
SELECT * FROM bronze.products
