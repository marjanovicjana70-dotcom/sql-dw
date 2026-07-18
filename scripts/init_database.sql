/*
Svrha:
Skripta sluzi pre svega kao provera da li vec postoji baza 'DataWarehouse' i ako postoji obrisace je i napravice je opet
Kada napravi bazu napravice se i tri seme bronze, silver, gold.
*/

USE master;
GO


IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
   ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO


CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
