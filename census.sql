/* SQL Analysis of US Census data from 2000 and 2010 
Author: Nathaniel Cekay*/

CREATE TABLE census_data (
	zipcode varchar(25),
	geo_id varchar(100),
	minimum_age numeric,
	maximum_age numeric,
	gender varchar(100),
	population numeric,
	census_year numeric
);

/* To prepare, I checked the data in Excel and 
arranged the columns in the same order. I also added a column for the year,
designating the 2000 census from the 2010 census */
/* Importing the 2000 census data */

COPY census_data
FROM 'C:\Datasets\population_by_zip_2000.csv'
WITH (FORMAT CSV, HEADER);

/* Importing the 2010 census data */

SELECT * FROM census_data;

COPY census_data
FROM 'C:\Datasets\population_by_zip_2010.csv'
WITH (FORMAT CSV, HEADER);

/* Removing the empty rows from the data */

ALTER TABLE census_data
DROP COLUMN minimum_age;

ALTER TABLE census_data
DROP COLUMN maximum_age;

ALTER TABLE census_data
DROP COLUMN gender;

SELECT * FROM census_data;

/* Checking for missing values */

SELECT *
FROM census_data
WHERE zipcode IS NULL;

SELECT *
FROM census_data
WHERE geo_id IS NULL;

SELECT *
FROM census_data
WHERE population IS NULL;

/* After removing the empty columns, there were no additional missing values */

SELECT * FROM census_data;

/* The data did not contain any Zip code values less than 5 digits */

/* Here I will get rid of extra characters in the Zip code column */
UPDATE census_data
SET zipcode = REPLACE(zipcode, '860000US', '');

UPDATE census_data
SET zipcode = REPLACE(zipcode, '8600000US', '');

/* I delete the rows that have XX in the zip*/

DELETE FROM census_data WHERE zipcode LIKE '%XX%'

/* Next I will check the data for short Zip code values, less than 5 digits*/

SELECT *
FROM census_data
WHERE length(zipcode) <5;

/* The data did not contain any ZIP code values less than 5 digits*/


/*here I return a list of Zip codes that appeared twice in the census */

SELECT zipcode, COUNT(zipcode)
FROM census_data
GROUP BY zipcode
HAVING COUNT(zipcode) > 1;


/* I change the column type to numeric to look at correlation*/

ALTER TABLE census_data
ALTER COLUMN zipcode TYPE numeric
USING zipcode::numeric;

/* Next I examine the correlation between Zip code population */

SELECT corr(zipcode, population)
    AS zipcode_and_population
FROM census_data;

/* there is a very weak correlation of 0.064 between Zip code and population*/

/* Here I calculate the average population*/

SELECT AVG(population)
FROM census_data;

/* The average population is 9475 people*/

/* Here I select the zipcode with the highest population*/

SELECT *
FROM census_data 
WHERE population = ( SELECT MAX(population) FROM census_data );

/* The result is 10456, the Bronx, NY, with 86547 people in 2010*/

/* Here I look at the 5 Zip codes with the highest populations*/

SELECT *
FROM census_data 
ORDER BY population DESC
LIMIT 5;

/* The results are 10456 in 2010, 60620 in 2000, 60804 in 2010,
60505 in 2010, and 60640 in 2000 */

/* Here I look at the 5 Zip codes with the lowest populations*/

SELECT *
FROM census_data 
ORDER BY population ASC
LIMIT 5;

/* the results are 24846 in 2000, 49263 in 2000, 97604 in 2000,
27841 in 2000, and 42759 in 2000 */

/* Here I use a subquery to view the top 90th percentile cutoff for total_sales*/

SELECT *
FROM census_data
WHERE population >= (
	SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY population)
	FROM census_data
	)
ORDER BY population DESC;

/* This returns the 100 Zip codes with the largest population,
in other words the top 90th percentile cutoff for population*/
