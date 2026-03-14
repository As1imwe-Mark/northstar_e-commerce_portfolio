--- Stored procedure for inserting data into the bronze tables
CREATE PROCEDURE load_bronze AS
BEGIN
BEGIN TRY
--- Customer Table
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


--- Marketing Spend Table
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


-- Order Items Table
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

--- Orders Table
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

--- Products Table
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

--- Returns Table
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
