
-- Project 4: Data Loading with Incremental Processing


CREATE TABLE SalesOrders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Amount DECIMAL(10, 2)
);

INSERT INTO SalesOrders (OrderID, CustomerName, Amount) VALUES
(1, 'Alice', 250.00),
(2, 'Bob', 180.50),
(3, 'Charlie', 320.00);

CREATE TABLE ProductInventory (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    StockQuantity INT
);

INSERT INTO ProductInventory (ProductID, ProductName, StockQuantity) VALUES
(101, 'Widget A', 50),
(102, 'Widget B', 30),
(103, 'Widget C', 20);

CREATE TABLE CustomerUpdates (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    LastUpdate DATETIME
);

INSERT INTO CustomerUpdates (CustomerID, CustomerName, LastUpdate) VALUES
(201, 'Alice', '2024-06-01 10:00:00'),
(202, 'Bob', '2024-06-02 15:30:00'),
(203, 'Charlie', '2024-06-03 09:45:00');

CREATE TABLE EmployeeChanges (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    ChangeTimestamp DATETIME
);

INSERT INTO EmployeeChanges (EmployeeID, EmployeeName, ChangeTimestamp) VALUES
(301, 'David', '2024-06-05 12:00:00'),
(302, 'Eva', '2024-06-06 08:20:00'),
(303, 'Frank', '2024-06-07 14:10:00');

CREATE TABLE ShipmentLogs (
    ShipmentID INT PRIMARY KEY,
    Destination VARCHAR(100),
    ShippedAt DATETIME
);

INSERT INTO ShipmentLogs (ShipmentID, Destination, ShippedAt) VALUES
(401, 'Toronto', '2024-06-08 11:00:00'),
(402, 'Montreal', '2024-06-09 13:45:00'),
(403, 'Vancouver', '2024-06-10 16:30:00');

CREATE TABLE WatermarkTracking (
    TableName VARCHAR(100) PRIMARY KEY,
    LastProcessedValue VARCHAR(100),  -- stores INT or DATETIME as string
    DataType VARCHAR(20)              -- 'INT' or 'DATETIME'
);

INSERT INTO WatermarkTracking (TableName, LastProcessedValue, DataType) VALUES
('SalesOrders', '0', 'INT'),
('ProductInventory', '0', 'INT'),
('CustomerUpdates', '1900-01-01 00:00:00', 'DATETIME'),
('EmployeeChanges', '1900-01-01 00:00:00', 'DATETIME'),
('ShipmentLogs', '1900-01-01 00:00:00', 'DATETIME');

DROP PROCEDURE IF EXISTS usp_LoadIncrementalData;
GO

CREATE PROCEDURE usp_LoadIncrementalData
    @TableName VARCHAR(100)
AS
BEGIN
    DECLARE @LastValue VARCHAR(100)
    DECLARE @DataType VARCHAR(20)
    DECLARE @ColumnName VARCHAR(100)
    DECLARE @SQL NVARCHAR(MAX)

    SELECT 
        @LastValue = LastProcessedValue,
        @DataType = DataType
    FROM WatermarkTracking
    WHERE TableName = @TableName

    IF @TableName = 'CustomerUpdates'
        SET @ColumnName = 'LastUpdate'
    ELSE IF @TableName = 'EmployeeChanges'
        SET @ColumnName = 'ChangeTimestamp'
    ELSE IF @TableName = 'ShipmentLogs'
        SET @ColumnName = 'ShippedAt'
    ELSE IF @TableName = 'SalesOrders'
        SET @ColumnName = 'OrderID'
    ELSE IF @TableName = 'ProductInventory'
        SET @ColumnName = 'ProductID'

    SET @SQL = '
    INSERT INTO ' + @TableName + '_Target
    SELECT * FROM ' + @TableName + '
    WHERE ' + @ColumnName + ' > ' + 
        CASE 
            WHEN @DataType = 'INT' THEN @LastValue 
            ELSE '''' + @LastValue + '''' 
        END + '

    UPDATE WatermarkTracking
    SET LastProcessedValue = (
        SELECT MAX(' + @ColumnName + ') FROM ' + @TableName + '
    )
    WHERE TableName = ''' + @TableName + ''''

    EXEC sp_executesql @SQL
END

CREATE TABLE SalesOrders_Target (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Amount DECIMAL(10, 2)
);

CREATE TABLE ProductInventory_Target (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    StockQuantity INT
);

CREATE TABLE CustomerUpdates_Target (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    LastUpdate DATETIME
);

CREATE TABLE EmployeeChanges_Target (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    ChangeTimestamp DATETIME
);

CREATE TABLE ShipmentLogs_Target (
    ShipmentID INT PRIMARY KEY,
    Destination VARCHAR(100),
    ShippedAt DATETIME
);

