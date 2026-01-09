/*

=======================================================================================================================================

Create Database and Schemas

========================================================================================================================================

Script Purpose;
   This scripts creates a new database names 'DataWarehouse' after checking if it already exists.
   If the database exists, it is dropped and recreated. Additionally, the scripts sets up three schemas within the databse: 'bronze', 'silver', and 'gold'.


WARNING:

Running this script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.

*/

-- Create Warehouse

USE master;

Go

  -- Drop and recreate the 'DataWarehouse' database
  IF EXISTS (SELECT 1 FROM sys.database WHERE name = 'DataWarehouse')
  BEGIN 
       ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
       DROP DATABASE DataWarehouse
 END;
 GO

-- Create the 'Datawarehouse' database

Create database DataWarehouse;
GO
  
USE DataWarehouse;
GO

-- Create Schemas

CREATE SCHEMA bronze;
GO
  
CREATE SCHEMA silver;
GO
  
CREATE SCHEMA gold;
GO
