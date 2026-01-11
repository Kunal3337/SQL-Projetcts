CREATE OR ALTER PROCEDURE bronze.load_bronze AS 

BEGIN
PRINT '==================================================================';
PRINT 'Loading Bronze Layer';
PRINT '==================================================================';

PRINT '------------------------------------------------------------------';
PRINT 'Loading CRM Tables';
PRINT '------------------------------------------------------------------';
BULK INSERT bronze.crm_cust_info
FROM '/var/opt/mssql/datafiles/cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK 
);

BULK INSERT bronze.crm_prd_info
FROM '/var/opt/mssql/datafiles/prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);


BULK INSERT bronze.crm_sales_details
FROM '/var/opt/mssql/datafiles/sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

PRINT '------------------------------------------------------------------';
PRINT 'Loading ERP Tables'
PRINT '------------------------------------------------------------------';

BULK INSERT bronze.erp_cust_az12
FROM '/var/opt/mssql/datafiles/source_erp/CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);


BULK INSERT bronze.erp_loc_a101
FROM '/var/opt/mssql/datafiles/source_erp/LOC_A101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);


BULK INSERT bronze.erp_px_cat_g1v2
FROM '/var/opt/mssql/datafiles/source_erp/PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

END

EXEC bronze.load_bronze
