--- Initailizing the database

DROP DATABASE  IF EXISTS Northstar_portfolio;
GO
CREATE DATABASE Northstar_portfolio;

USE Northstar_portfolio;

--- Creating Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO