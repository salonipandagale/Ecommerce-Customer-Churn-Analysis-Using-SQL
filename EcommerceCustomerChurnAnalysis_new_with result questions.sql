/* =========================================================
   ECOMMERCE CUSTOMER CHURN ANALYSIS
   MySQL Workbench
   ========================================================= */

CREATE DATABASE IF NOT EXISTS ecommerce_db;

USE ecommerce_db;


/* =========================================================
   STEP 1: CHECK DATA
   ========================================================= */

SELECT
    CustomerID,
    Churn,
    Tenure,
    PreferredLoginDevice,
    WarehouseToHome,
    HourSpendOnApp,
    NumberOfDeviceRegistered,
    PreferedOrderCat
FROM ecommercechurn
LIMIT 10;


/* =========================================================
   STEP 2: CLEAN NUMERIC COLUMNS
   Convert blank strings to NULL
   ========================================================= */

SET SQL_SAFE_UPDATES = 0;

UPDATE ecommercechurn
SET Tenure = NULL
WHERE TRIM(Tenure) = '';

UPDATE ecommercechurn
SET HourSpendOnApp = NULL
WHERE TRIM(HourSpendOnApp) = '';

SET SQL_SAFE_UPDATES = 1;


/* =========================================================
   STEP 3: CONVERT TEXT COLUMNS TO NUMERIC
   ========================================================= */

ALTER TABLE ecommercechurn
MODIFY COLUMN Tenure DECIMAL(10,2);

ALTER TABLE ecommercechurn
MODIFY COLUMN HourSpendOnApp DECIMAL(10,2);


/* =========================================================
   STEP 4: BASIC DATA QUALITY CHECKS
   ========================================================= */

-- Total number of customers
SELECT COUNT(DISTINCT CustomerID) AS TotalNumberOfCustomers
FROM ecommercechurn;


-- Check for duplicate CustomerIDs
SELECT
    CustomerID,
    COUNT(*) AS Count
FROM ecommercechurn
GROUP BY CustomerID
HAVING COUNT(*) > 1;


-- Check NULL values
SELECT
    'Tenure' AS ColumnName,
    COUNT(*) AS NullCount
FROM ecommercechurn
WHERE Tenure IS NULL

UNION ALL

SELECT
    'WarehouseToHome',
    COUNT(*)
FROM ecommercechurn
WHERE WarehouseToHome IS NULL

UNION ALL

SELECT
    'HourSpendOnApp',
    COUNT(*)
FROM ecommercechurn
WHERE HourSpendOnApp IS NULL

UNION ALL

SELECT
    'OrderAmountHikeFromlastYear',
    COUNT(*)
FROM ecommercechurn
WHERE OrderAmountHikeFromlastYear IS NULL

UNION ALL

SELECT
    'CouponUsed',
    COUNT(*)
FROM ecommercechurn
WHERE CouponUsed IS NULL

UNION ALL

SELECT
    'OrderCount',
    COUNT(*)
FROM ecommercechurn
WHERE OrderCount IS NULL

UNION ALL

SELECT
    'DaySinceLastOrder',
    COUNT(*)
FROM ecommercechurn
WHERE DaySinceLastOrder IS NULL;


/* =========================================================
   STEP 5: CALCULATE AVERAGES FOR MISSING VALUES
   ========================================================= */

SELECT
    ROUND(AVG(Tenure), 2) AS AverageTenure
FROM ecommercechurn
WHERE Tenure IS NOT NULL;


SELECT
    ROUND(AVG(HourSpendOnApp), 2) AS AverageHourSpendOnApp
FROM ecommercechurn
WHERE HourSpendOnApp IS NOT NULL;


SELECT
    ROUND(AVG(WarehouseToHome), 2) AS AverageWarehouseToHome
FROM ecommercechurn
WHERE WarehouseToHome IS NOT NULL;


SELECT
    ROUND(AVG(OrderAmountHikeFromlastYear), 2)
        AS AverageOrderAmountHike
FROM ecommercechurn
WHERE OrderAmountHikeFromlastYear IS NOT NULL;


SELECT
    ROUND(AVG(CouponUsed), 2) AS AverageCouponUsed
FROM ecommercechurn
WHERE CouponUsed IS NOT NULL;


SELECT
    ROUND(AVG(OrderCount), 2) AS AverageOrderCount
FROM ecommercechurn
WHERE OrderCount IS NOT NULL;


SELECT
    ROUND(AVG(DaySinceLastOrder), 2)
        AS AverageDaySinceLastOrder
FROM ecommercechurn
WHERE DaySinceLastOrder IS NOT NULL;


/* =========================================================
   STEP 6: IMPUTE NULL VALUES
   Using JOIN with derived averages
   Avoids MySQL Error 1093
   ========================================================= */

SET SQL_SAFE_UPDATES = 0;


UPDATE ecommercechurn e
JOIN (
    SELECT AVG(Tenure) AS avg_tenure
    FROM ecommercechurn
) a
SET e.Tenure = a.avg_tenure
WHERE e.Tenure IS NULL;


UPDATE ecommercechurn e
JOIN (
    SELECT AVG(HourSpendOnApp) AS avg_hours
    FROM ecommercechurn
) a
SET e.HourSpendOnApp = a.avg_hours
WHERE e.HourSpendOnApp IS NULL;


UPDATE ecommercechurn e
JOIN (
    SELECT AVG(WarehouseToHome) AS avg_distance
    FROM ecommercechurn
) a
SET e.WarehouseToHome = a.avg_distance
WHERE e.WarehouseToHome IS NULL;


UPDATE ecommercechurn e
JOIN (
    SELECT AVG(OrderAmountHikeFromlastYear) AS avg_hike
    FROM ecommercechurn
) a
SET e.OrderAmountHikeFromlastYear = a.avg_hike
WHERE e.OrderAmountHikeFromlastYear IS NULL;


UPDATE ecommercechurn e
JOIN (
    SELECT AVG(CouponUsed) AS avg_coupon
    FROM ecommercechurn
) a
SET e.CouponUsed = a.avg_coupon
WHERE e.CouponUsed IS NULL;


UPDATE ecommercechurn e
JOIN (
    SELECT AVG(OrderCount) AS avg_orders
    FROM ecommercechurn
) a
SET e.OrderCount = a.avg_orders
WHERE e.OrderCount IS NULL;


UPDATE ecommercechurn e
JOIN (
    SELECT AVG(DaySinceLastOrder) AS avg_days
    FROM ecommercechurn
) a
SET e.DaySinceLastOrder = a.avg_days
WHERE e.DaySinceLastOrder IS NULL;


SET SQL_SAFE_UPDATES = 1;


/* =========================================================
   STEP 7: CREATE CUSTOMER STATUS
   ========================================================= */

ALTER TABLE ecommercechurn
ADD COLUMN CustomerStatus VARCHAR(50);


SET SQL_SAFE_UPDATES = 0;

UPDATE ecommercechurn
SET CustomerStatus =
CASE
    WHEN Churn = 1 THEN 'Churned'
    WHEN Churn = 0 THEN 'Stayed'
END;

SET SQL_SAFE_UPDATES = 1;


/* =========================================================
   STEP 8: CREATE COMPLAINT STATUS
   ========================================================= */

ALTER TABLE ecommercechurn
ADD COLUMN ComplainReceived VARCHAR(10);


SET SQL_SAFE_UPDATES = 0;

UPDATE ecommercechurn
SET ComplainReceived =
CASE
    WHEN Complain = 1 THEN 'Yes'
    WHEN Complain = 0 THEN 'No'
END;

SET SQL_SAFE_UPDATES = 1;


/* =========================================================
   STEP 9: STANDARDIZE CATEGORICAL VALUES
   ========================================================= */

SET SQL_SAFE_UPDATES = 0;


-- Preferred Login Device
SELECT DISTINCT PreferredLoginDevice
FROM ecommercechurn;


UPDATE ecommercechurn
SET PreferredLoginDevice = 'Phone'
WHERE PreferredLoginDevice = 'Mobile Phone';


-- Preferred Order Category
SELECT DISTINCT PreferedOrderCat
FROM ecommercechurn;


UPDATE ecommercechurn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';


-- Preferred Payment Mode
SELECT DISTINCT PreferredPaymentMode
FROM ecommercechurn;


UPDATE ecommercechurn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';


SET SQL_SAFE_UPDATES = 1;


/* =========================================================
   STEP 10: CHECK WAREHOUSE DISTANCE VALUES
   ========================================================= */

SELECT DISTINCT WarehouseToHome
FROM ecommercechurn
ORDER BY WarehouseToHome;


/*
   Correct suspected data-entry errors:
   126 -> 26
   127 -> 27
*/

SET SQL_SAFE_UPDATES = 0;

UPDATE ecommercechurn
SET WarehouseToHome = 27
WHERE WarehouseToHome = 127;

UPDATE ecommercechurn
SET WarehouseToHome = 26
WHERE WarehouseToHome = 126;

SET SQL_SAFE_UPDATES = 1;


/* =========================================================
   BUSINESS ANALYSIS
   ========================================================= */


/* =========================================================
   1. OVERALL CUSTOMER CHURN RATE
   ========================================================= */

SELECT
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    COUNT(*) - SUM(Churn) AS StayedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn;


/* =========================================================
   2. CHURN RATE BY PREFERRED LOGIN DEVICE
   ========================================================= */

SELECT
    PreferredLoginDevice,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY PreferredLoginDevice
ORDER BY ChurnRate DESC;


/* =========================================================
   3. CHURN RATE BY CITY TIER
   ========================================================= */

SELECT
    CityTier,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY CityTier
ORDER BY ChurnRate DESC;


/* =========================================================
   4. WAREHOUSE-TO-HOME DISTANCE VS CHURN
   ========================================================= */

ALTER TABLE ecommercechurn
ADD COLUMN WarehouseToHomeRange VARCHAR(50);


SET SQL_SAFE_UPDATES = 0;

UPDATE ecommercechurn
SET WarehouseToHomeRange =
CASE
    WHEN WarehouseToHome <= 10
        THEN 'Very Close Distance'

    WHEN WarehouseToHome > 10
         AND WarehouseToHome <= 20
        THEN 'Close Distance'

    WHEN WarehouseToHome > 20
         AND WarehouseToHome <= 30
        THEN 'Moderate Distance'

    WHEN WarehouseToHome > 30
        THEN 'Far Distance'
END;

SET SQL_SAFE_UPDATES = 1;


SELECT
    WarehouseToHomeRange,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY WarehouseToHomeRange
ORDER BY ChurnRate DESC;


/* =========================================================
   5. PAYMENT MODE AMONG CHURNED CUSTOMERS
   ========================================================= */

SELECT
    PreferredPaymentMode,
    COUNT(*) AS ChurnedCustomers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM ecommercechurn
         WHERE Churn = 1),
        2
    ) AS PercentageOfChurnedCustomers
FROM ecommercechurn
WHERE Churn = 1
GROUP BY PreferredPaymentMode
ORDER BY ChurnedCustomers DESC;


/* =========================================================
   6. TENURE GROUP VS CHURN
   ========================================================= */

ALTER TABLE ecommercechurn
ADD COLUMN TenureRange VARCHAR(50);


SET SQL_SAFE_UPDATES = 0;

UPDATE ecommercechurn
SET TenureRange =
CASE
    WHEN Tenure <= 6
        THEN 'Up to 6 Months'

    WHEN Tenure > 6
         AND Tenure <= 12
        THEN '6-12 Months'

    WHEN Tenure > 12
         AND Tenure <= 24
        THEN '1-2 Years'

    WHEN Tenure > 24
        THEN 'More Than 2 Years'
END;

SET SQL_SAFE_UPDATES = 1;


SELECT
    TenureRange,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY ChurnRate DESC;


/* =========================================================
   7. GENDER VS CHURN
   ========================================================= */

SELECT
    Gender,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY Gender
ORDER BY ChurnRate DESC;


/* =========================================================
   8. APP USAGE VS CHURN
   ========================================================= */

SELECT
    CustomerStatus,
    COUNT(*) AS TotalCustomers,
    ROUND(AVG(HourSpendOnApp), 2)
        AS AverageHoursSpentOnApp
FROM ecommercechurn
GROUP BY CustomerStatus;


/* =========================================================
   9. REGISTERED DEVICES VS CHURN
   ========================================================= */

SELECT
    NumberOfDeviceRegistered,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY NumberOfDeviceRegistered
ORDER BY ChurnRate DESC;


/* =========================================================
   10. ORDER CATEGORY VS CHURN
   ========================================================= */

SELECT
    PreferedOrderCat,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY PreferedOrderCat
ORDER BY ChurnRate DESC;


/* =========================================================
   11. SATISFACTION SCORE VS CHURN
   ========================================================= */

SELECT
    SatisfactionScore,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY SatisfactionScore
ORDER BY SatisfactionScore;


/* =========================================================
   12. MARITAL STATUS VS CHURN
   ========================================================= */

SELECT
    MaritalStatus,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY MaritalStatus
ORDER BY ChurnRate DESC;


/* =========================================================
   13. AVERAGE ADDRESSES OF CHURNED CUSTOMERS
   ========================================================= */

SELECT
    ROUND(AVG(NumberOfAddress), 2)
        AS AverageNumberOfAddresses
FROM ecommercechurn
WHERE Churn = 1;


/* =========================================================
   14. COMPLAINTS VS CHURN
   ========================================================= */

SELECT
    ComplainReceived,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY ComplainReceived
ORDER BY ChurnRate DESC;


/* =========================================================
   15. COUPON USAGE VS CHURN
   ========================================================= */

SELECT
    CustomerStatus,
    COUNT(*) AS TotalCustomers,
    ROUND(AVG(CouponUsed), 2)
        AS AverageCouponsUsed
FROM ecommercechurn
GROUP BY CustomerStatus;


/* =========================================================
   16. DAYS SINCE LAST ORDER
   ========================================================= */

SELECT
    CustomerStatus,
    ROUND(AVG(DaySinceLastOrder), 2)
        AS AverageDaysSinceLastOrder
FROM ecommercechurn
GROUP BY CustomerStatus;


/* =========================================================
   17. CASHBACK AMOUNT VS CHURN
   ========================================================= */

ALTER TABLE ecommercechurn
ADD COLUMN CashbackAmountRange VARCHAR(50);


SET SQL_SAFE_UPDATES = 0;

UPDATE ecommercechurn
SET CashbackAmountRange =
CASE
    WHEN CashbackAmount <= 100
        THEN 'Low Cashback Amount'

    WHEN CashbackAmount > 100
         AND CashbackAmount <= 200
        THEN 'Moderate Cashback Amount'

    WHEN CashbackAmount > 200
         AND CashbackAmount <= 300
        THEN 'High Cashback Amount'

    WHEN CashbackAmount > 300
        THEN 'Very High Cashback Amount'
END;

SET SQL_SAFE_UPDATES = 1;


SELECT
    CashbackAmountRange,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(
        SUM(Churn) * 100.0 / COUNT(*),
        2
    ) AS ChurnRate
FROM ecommercechurn
GROUP BY CashbackAmountRange
ORDER BY ChurnRate DESC;


/* =========================================================
   FINAL DATA CHECK
   ========================================================= */

SELECT COUNT(*) AS FinalRowCount
FROM ecommercechurn;

SELECT
    SUM(Churn) AS ChurnedCustomers,
    COUNT(*) - SUM(Churn) AS StayedCustomers
FROM ecommercechurn;


/**Verifying the result**/
SELECT COUNT(*) AS TotalRows
FROM ecommercechurn;

SELECT *
FROM ecommercechurn
LIMIT 10;


-- 1. Overall metrics
SELECT
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate,
    ROUND(AVG(Tenure), 2) AS AverageTenure
FROM ecommercechurn;


-- 2. Churn by login device
SELECT
    PreferredLoginDevice,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY PreferredLoginDevice
ORDER BY ChurnRate DESC;


-- 3. Churn by city tier
SELECT
    CityTier,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY CityTier
ORDER BY ChurnRate DESC;


-- 4. Churn by warehouse distance
SELECT
    WarehouseToHomeRange,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY WarehouseToHomeRange
ORDER BY ChurnRate DESC;


-- 5. Churn by payment mode
SELECT
    PreferredPaymentMode,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY PreferredPaymentMode
ORDER BY ChurnRate DESC;


-- 6. Churn by tenure
SELECT
    TenureRange,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY ChurnRate DESC;


-- 7. Churn by gender
SELECT
    Gender,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY Gender
ORDER BY ChurnRate DESC;


-- 8. Churn by number of devices
SELECT
    NumberOfDeviceRegistered,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY NumberOfDeviceRegistered
ORDER BY ChurnRate DESC;


-- 9. Churn by order category
SELECT
    PreferedOrderCat,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY PreferedOrderCat
ORDER BY ChurnRate DESC;


-- 10. Churn by satisfaction score
SELECT
    SatisfactionScore,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY SatisfactionScore
ORDER BY SatisfactionScore;


-- 11. Churn by marital status
SELECT
    MaritalStatus,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY MaritalStatus
ORDER BY ChurnRate DESC;


-- 12. Churn by complaint
SELECT
    ComplainReceived,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY ComplainReceived
ORDER BY ChurnRate DESC;


-- 13. Average app usage
SELECT
    CustomerStatus,
    COUNT(*) AS Customers,
    ROUND(AVG(HourSpendOnApp), 2) AS AverageHoursSpent
FROM ecommercechurn
GROUP BY CustomerStatus;


-- 14. Average coupons used
SELECT
    CustomerStatus,
    COUNT(*) AS Customers,
    ROUND(AVG(CouponUsed), 2) AS AverageCouponsUsed
FROM ecommercechurn
GROUP BY CustomerStatus;


-- 15. Average days since last order
SELECT
    CustomerStatus,
    COUNT(*) AS Customers,
    ROUND(AVG(DaySinceLastOrder), 2) AS AverageDaysSinceLastOrder
FROM ecommercechurn
GROUP BY CustomerStatus;


-- 16. Churn by cashback range
SELECT
    CashbackAmountRange,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS ChurnRate
FROM ecommercechurn
GROUP BY CashbackAmountRange
ORDER BY ChurnRate DESC;