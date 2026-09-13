CREATE DATABASE HOUSE;
USE HOUSE;

CREATE TABLE HOUSE_1(
AREA_SQFT TEXT,
BEDROOMS TEXT,
BATHROOMS TEXT,
YEAR_BUILT  TEXT,
PRICE TEXT,
LOCATION  TEXT
);
SELECT DISTINCT LOCATION FROM HOUSE_1;
UPDATE HOUSE_1
SET location = TRIM(location);

UPDATE HOUSE_1
SET PRICE = null
where trim(price) in ('N/A', 'UNAVAILABLE', '');

SELECT * FROM HOUSE_1;

SET SQL_SAFE_UPDATES = 0;

UPDATE HOUSE_1 
SET YEAR_BUILT = NULL
WHERE TRIM(YEAR_BUILT) IN ('');

UPDATE HOUSE_1
SET BEDROOMS = null
WHERE TRIM(BEDROOMS) IN ('');

UPDATE HOUSE_1
SET LOCATION = CASE
WHEN LOCATION IN ('la','l.a.','los anegles') THEN 'los angeles'
WHEN LOCATION IN ('sf') THEN 'san francisco'
WHEN LOCATION IN ('nyc') THEN 'new york city'
WHEN LOCATION IN ('chicgo') THEN 'chicago'
WHEN LOCATION IN ('bostan') THEN 'boston'
ELSE LOCATION
END;

SELECT DISTINCT LOCATION FROM HOUSE_1;
UPDATE HOUSE_1
SET AREA_SQFT  = NULL
WHERE AREA_SQFT < 0;

UPDATE HOUSE_1
SET BEDROOMS = NULL
WHERE BEDROOMS = 20;


SELECT AREA_SQFT , PRICE , PRICE/AREA_SQFT AS  price_per_sqft 
FROM HOUSE_1
WHERE PRICE IS NOT NULL AND AREA_SQFT IS NOT NULL
ORDER BY price_per_sqft ASC
LIMIT 15;

SELECT COUNT(*) 
FROM HOUSE_1 
WHERE price IS NOT NULL AND area_sqft IS NOT NULL 
AND price = area_sqft * 2000;

SELECT COUNT(*) 
FROM HOUSE_1 
WHERE price IS NOT NULL AND area_sqft IS NOT NULL 
AND price = area_sqft * 10;

UPDATE HOUSE_1
SET price = NULL
WHERE price = area_sqft * 2000;

SELECT area_sqft, bedrooms, bathrooms, year_built, price, location, COUNT(*) AS cnt
FROM HOUSE_1
GROUP BY area_sqft, bedrooms, bathrooms, year_built, price, location
HAVING COUNT(*) > 1;

WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY area_sqft, bedrooms, bathrooms, year_built, price, location
        ) AS rn
    FROM HOUSE_1
)
DELETE FROM HOUSE_1
WHERE (area_sqft, bedrooms, bathrooms, year_built, price, location) IN (
    SELECT area_sqft, bedrooms, bathrooms, year_built, price, location
    FROM ranked
    WHERE rn > 1
);