SELECT * FROM e_comm;

-- Data Cleaning

-- 1. Total Number of Customers
SELECT COUNT(e_comm.customerid) AS TotalNumberOfCustomers
    FROM e_comm;

-- 2. Check for Duplicate Rows
SELECT customerid, COUNT(customerid),
       CASE WHEN COUNT(customerid) > 1 THEN COUNT(customerid) ELSE 0 END AS duplicate_id
       FROM e_comm
    GROUP BY customerid
        HAVING COUNT(customerid) > 1;

-- 3. Check for NULL values
SELECT 'tenure' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE tenure IS NULL
UNION
SELECT 'preferredlogindevice' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE preferredlogindevice IS NULL
UNION
SELECT 'warehousetohome' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE warehousetohome IS NULL
UNION
SELECT 'tenure' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE tenure IS NULL
UNION
SELECT 'preferredpaymentmode' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE preferredpaymentmode IS NULL
UNION
SELECT 'hourspendonapp' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE hourspendonapp IS NULL
UNION
SELECT 'orderamounthikefromlastyear' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE orderamounthikefromlastyear IS NULL
UNION
SELECT 'couponused' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE couponused IS NULL
UNION
SELECT 'ordercount' AS ColumnName, COUNT(*) AS NumofNull
    FROM e_comm
        WHERE ordercount IS NULL;

-- 4. Handle NULL values
UPDATE e_comm
    SET tenure = (SELECT AVG(tenure) FROM e_comm)
        WHERE tenure IS NULL;

UPDATE e_comm
    SET hourspendonapp = (SELECT AVG(hourspendonapp) FROM e_comm)
        WHERE hourspendonapp IS NULL;

UPDATE e_comm
    SET orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM e_comm)
        WHERE orderamounthikefromlastyear IS NULL;

UPDATE e_comm
    SET couponused = (SELECT AVG(couponused) FROM e_comm)
        WHERE couponused IS NULL;

UPDATE e_comm
    SET ordercount = (SELECT AVG(ordercount) FROM e_comm)
        WHERE ordercount IS NULL;

UPDATE e_comm
    SET warehousetohome = (SELECT ROUND(AVG(warehousetohome), 0) FROM e_comm)
        WHERE warehousetohome IS NULL;

-- 5. Added new column for churned or not customers
ALTER TABLE e_comm
    ADD CustomerStatus NVARCHAR(10);

UPDATE e_comm
    SET CustomerStatus =
        CASE WHEN churn = 1 THEN 'Churned'
             WHEN churn = 0 THEN 'Stayed'
        END;

-- 6. Added new column for customers that have complaints
ALTER TABLE e_comm
    ADD CustomerComplain NVARCHAR(10);

UPDATE e_comm
    SET CustomerComplain =
        CASE WHEN complain = '1' THEN 'Yes'
             WHEN complain = '0' THEN 'No'
        END;

-- Extra
SELECT DISTINCT e_comm.preferredlogindevice
    FROM e_comm;

UPDATE e_comm
    SET preferredlogindevice = 'Phone'
        WHERE preferredlogindevice = 'Mobile Phone';

SELECT DISTINCT e_comm.preferedordercat
    FROM e_comm;

UPDATE e_comm
    SET preferedordercat = 'Phone'
        WHERE preferedordercat = 'Mobile' OR preferedordercat ='Mobile Phone';

SELECT DISTINCT e_comm.preferredpaymentmode
    FROM e_comm;

UPDATE e_comm
    SET preferredpaymentmode = 'Cash on Delivery'
        WHERE preferredpaymentmode = 'COD';

UPDATE e_comm
    SET preferredpaymentmode = 'Credit Card'
        WHERE preferredpaymentmode = 'CC';

-- Fix Outliers
SELECT DISTINCT e_comm.warehousetohome
    FROM e_comm;

UPDATE e_comm
    SET warehousetohome = '26'
        WHERE warehousetohome = '126';

UPDATE e_comm
    SET warehousetohome = '27'
        WHERE warehousetohome = '127';


-- Data Exploration

-- 1. Overall Churn rate
SELECT COUNT(e_comm.customerid) AS numberofcustomers,
       (SELECT COUNT(CustomerStatus) FROM e_comm WHERE CustomerStatus = 'Churned') AS churnedcustomers,
       ROUND(((SELECT COUNT(CustomerStatus) FROM e_comm WHERE CustomerStatus = 'Churned')*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
       FROM e_comm;

SELECT preferredlogindevice,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
       FROM e_comm
            GROUP BY preferredlogindevice;

-- Distribution of customers across different city tiers
SELECT citytier,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
    FROM e_comm
        GROUP BY citytier
            ORDER BY churnrate DESC;

-- Most  preferred payment method across churned customers
SELECT preferredpaymentmode,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
    FROM e_comm
        GROUP BY preferredpaymentmode
            ORDER BY churnrate DESC;

-- Difference in churn rate based on gender
SELECT gender,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
FROM e_comm
GROUP BY gender
ORDER BY churnrate DESC;

-- Average time spent on app between churned and non churned customers
SELECT e_comm.CustomerStatus, ROUND(AVG(e_comm.hourspendonapp), 2) AS averagetimespent
    FROM e_comm
        GROUP BY e_comm.CustomerStatus;

-- Most preferred order category among churned customers
SELECT preferedordercat,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
    FROM e_comm
        GROUP BY preferedordercat
            ORDER BY churnrate DESC;

-- Relationship between customer satisfaction and churn
SELECT satisfactionscore,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
    FROM e_comm
        GROUP BY satisfactionscore
            ORDER BY churnrate DESC;

-- Marital status vs churn
SELECT maritalstatus,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
    FROM e_comm
        GROUP BY maritalstatus
            ORDER BY churnrate DESC;

-- Complaints affect churn
SELECT CustomerComplain,
       COUNT(e_comm.customerid) AS numberofcustomers,
       SUM(churn) AS ChurnedCustomers,
       ROUND((SUM(churn)*1.0/COUNT(e_comm.customerid)*1.0)*100, 2) AS churnrate
    FROM e_comm
        GROUP BY CustomerComplain
            ORDER BY churnrate DESC;

-- Coupons used between churned and non-churned customers
SELECT CustomerStatus, COUNT(couponused) AS coupons
    FROM e_comm
        GROUP BY churn;
