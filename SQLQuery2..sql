USE db_SQLCaseStudies

--List all the states in which we have customers who bought cellphones since 2005 till today.

SELECT DISTINCT
State 
FROM
CELL.DIM_LOCATION AS T1
LEFT JOIN CELL.FACT_TRANSACTIONS AS T2 ON T1.IDLocation = T2.IDLocation
GROUP BY
State,
Date
HAVING
YEAR(T2.DATE) >= 2005;

-- Which state in the US is buying more 'Samsung' cell phones?

SELECT TOP 1
State
FROM
CELL.DIM_LOCATION AS T1
INNER JOIN CELL.FACT_TRANSACTIONS AS T2 ON T1.IDLocation= T2.IDLocation
LEFT JOIN CELL.DIM_MODEL AS T3 ON T2.IDModel= T3.IDModel
RIGHT JOIN CELL.DIM_MANUFACTURER AS T4 ON T3.IDManufacturer = T4.IDManufacturer
WHERE
Manufacturer_Name = 'Samsung' AND Country = 'US'
GROUP BY
State,
Quantity
ORDER BY 
Quantity DESC;

-- Number of transactions for each model per zip code per state.

SELECT
T2.IDModel,
Model_Name,
ZipCode,
State,
COUNT(T1.IDCustomer) AS NUM_OF_TRANSACTION
FROM
CELL.FACT_TRANSACTIONS AS T1
LEFT JOIN CELL.DIM_MODEL AS T2 ON T1.IDModel = T2.IDModel
RIGHT JOIN CELL.DIM_LOCATION AS T3 ON T1.IDLocation = T3.IDLocation
GROUP BY
T2.IDModel,
Model_Name,
ZipCode,
State;

-- Cheapest cellphone.

 SELECT TOP 1
 IDModel,
 Model_Name,
 Unit_price
 FROM
 CELL.DIM_MODEL
 ORDER BY
 Unit_price ASC

 -- Average price for each model in the top 5 manufacturers in terms of sales quantity and order by average price.

SELECT
Manufacturer_Name,
Model_Name,
AVG(TotalPrice) AS AVG_RATE,
SUM(Quantity)AS SALE_QUANTITY
FROM
CELL.DIM_MODEL AS M1
LEFT JOIN CELL.FACT_TRANSACTIONS AS T1 ON T1.IDModel= M1.IDModel
RIGHT JOIN CELL.DIM_MANUFACTURER AS M2 ON M1.IDManufacturer= M2.IDManufacturer
WHERE Manufacturer_Name IN(
SELECT TOP 5
Manufacturer_Name
FROM CELL.FACT_TRANSACTIONS AS T1
LEFT JOIN CELL.DIM_MODEL AS M1 ON T1.IDModel=M1.IDModel
INNER JOIN CELL.DIM_MANUFACTURER AS M2 ON M1.IDManufacturer=M2.IDManufacturer
GROUP BY Manufacturer_Name
ORDER BY SUM(Quantity) DESC
)
GROUP BY 
Manufacturer_Name,
Model_Name ;

-- List the names of the customers and the average amount spent in 2009, where the average is higher than 500

SELECT
Customer_Name,
AVG(TotalPrice) AS AVG_AMT_SPENT
FROM
CELL.DIM_CUSTOMER AS T1
RIGHT JOIN CELL.FACT_TRANSACTIONS AS T2 ON T1.IDCustomer = T2.IDCustomer
WHERE
YEAR(Date) = 2009
GROUP BY
Customer_Name
HAVING
AVG(TotalPrice) > 500;

-- List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010.

SELECT T1.Model_Name FROM
(
SELECT TOP 5
Model_Name,
SUM(Quantity) AS Total_Quatity
FROM CELL.DIM_MODEL AS M
INNER JOIN CELL.FACT_TRANSACTIONS AS T ON M.IDModel=T.IDModel
WHERE
DATEPART(Year,Date) = '2008'
GROUP BY
Model_Name
ORDER BY SUM(Quantity) DESC ) AS T1

INNER JOIN 
(SELECT TOP 5
Model_Name,
SUM(Quantity)  AS Total_Quatity
FROM CELL.DIM_MODEL AS M
INNER JOIN CELL.FACT_TRANSACTIONS AS T ON M.IDModel=T.IDModel
WHERE
DATEPART(Year,Date) = '2009'
GROUP BY
Model_Name
ORDER BY SUM(Quantity) DESC ) AS T2 ON T1.Model_Name = T2.Model_Name

INNER JOIN
(SELECT TOP 5
Model_Name,
SUM(Quantity)  AS Total_Quatity
FROM CELL.DIM_MODEL AS M
INNER JOIN CELL.FACT_TRANSACTIONS AS T ON M.IDModel=T.IDModel
WHERE
DATEPART(Year,Date) = '2010'
GROUP BY
Model_Name
ORDER BY SUM(Quantity) DESC 
) AS T3 ON T2.Model_Name = T3.Model_Name ;


-- Show the manufacturer with 2nd top sales in the year of 2009 and the manufacturer with 2nd top sales in the year of 2010.

SELECT * FROM (
SELECT
YEAR,
IDManufacturer,
Manufacturer_Name,
Total
from
  (
    select
      row_number() over ( order by sum(totalprice) desc ) as Row_Number,
	  DATEPART(YEAR,T1.DATE) AS YEAR,
     T3.IDManufacturer,
	 T4.Manufacturer_Name,
     sum(T1.totalprice) as Total
    from
      CELL.FACT_TRANSACTIONS AS T1
      JOIN CELL.DIM_DATE AS T2 on T2.date = T1.date
      JOIN CELL.DIM_MODEL AS T3 on T3.idmodel = T1.idmodel
	  JOIN CELL.DIM_MANUFACTURER AS T4 ON T3.IDManufacturer = T4.IDManufacturer
	  WHERE
	  YEAR(T1.DATE) = '2009'
    Group by
     T1.DATE,
     T3.IDManufacturer,
	 T4.Manufacturer_Name,
	 T1.totalprice
  ) RESULT
where
  RESULT.Row_Number = 2
  GROUP BY
  YEAR,
  IDManufacturer,
  Manufacturer_Name,
  Total
  UNION ALL
  SELECT
YEAR,
IDManufacturer,
Manufacturer_Name,
Total
from
  (
    select
      row_number() over ( order by sum(totalprice) desc ) as Row_Number,
	  DATEPART(YEAR,T1.DATE) AS YEAR,
     T3.IDManufacturer,
	 T4.Manufacturer_Name,
     sum(T1.totalprice) as Total
    from
      CELL.FACT_TRANSACTIONS AS T1
      JOIN CELL.DIM_DATE AS T2 on T2.date = T1.date
      JOIN CELL.DIM_MODEL AS T3 on T3.idmodel = T1.idmodel
	  JOIN CELL.DIM_MANUFACTURER AS T4 ON T3.IDManufacturer = T4.IDManufacturer
	  WHERE
	  YEAR(T1.DATE) = '2010'
    Group by
     T1.DATE,
     T3.IDManufacturer,
	 T4.Manufacturer_Name,
	 T1.totalprice
  ) RESULT
where
  RESULT.Row_Number = 2
  GROUP BY
  YEAR,
  IDManufacturer,
  Manufacturer_Name,
  Total
  ) AS A ;

-- Show the manufacturers that sold cellphone in 2010 but didn't in 2009
 
 SELECT * FROM  
 (
 SELECT DISTINCT
T1.IDManufacturer,
Manufacturer_Name
FROM
CELL.DIM_MANUFACTURER AS T1
JOIN CELL.DIM_MODEL AS T2 ON T1.IDManufacturer = T2.IDManufacturer
RIGHT JOIN CELL.FACT_TRANSACTIONS AS T3 ON T2.IDModel = T3.IDModel
 WHERE
 date >= '2010-01-01' and date < '2011-01-01'
 GROUP BY
 Date,
 T1.IDManufacturer,  
 Manufacturer_Name

 EXCEPT
 
 SELECT DISTINCT
T1.IDManufacturer,
Manufacturer_Name
FROM
CELL.DIM_MANUFACTURER AS T1
JOIN CELL.DIM_MODEL AS T2 ON T1.IDManufacturer = T2.IDManufacturer
RIGHT JOIN CELL.FACT_TRANSACTIONS AS T3 ON T2.IDModel = T3.IDModel
 WHERE
 date >= '2009-01-01' and date < '2010-01-01'
 GROUP BY
 Date,
 T1.IDManufacturer,  
 Manufacturer_Name ) AS A ;


-- Find top 100 customers and their average spend, average quantity by each year. Also find percentage of change in their spend.

SELECT *
      ,[AVG_SPEND] - LAG([AVG_SPEND], 1, 0) OVER (PARTITION BY [Customer_Name] ORDER BY [YEAR]) AS PERCENTAGE_OF_CHANGE
FROM (
SELECT TOP 100 
DATEPART(YEAR,Date) AS YEAR,
T1.IDCustomer,
Customer_Name,
TotalPrice AS TOTAL_AMT,
AVG(TotalPrice) AS AVG_SPEND,
AVG (Quantity) AS AVG_QUANTITY
FROM CELL.DIM_CUSTOMER AS T1
RIGHT JOIN CELL.FACT_TRANSACTIONS AS T2 ON T1.IDCustomer = T2.IDCustomer
GROUP BY
Date,
T1.IDCustomer,
Customer_Name,
TotalPrice, 
Quantity
ORDER BY
AVG_SPEND DESC ) AS A ;











