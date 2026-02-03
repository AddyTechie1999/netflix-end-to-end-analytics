-- Main Staging Table
CREATE TABLE netflix_staging (
  `show_id` VARCHAR(10) primary key,
  `type` varchar(10),
  `title` nvarchar(200),
  `date_added` date,
  `release_year` int DEFAULT NULL,
  `rating` varchar(10),
  `duration` varchar(10),
  `description` varchar(500)
);

-- Populate the staging table
-- Creating a CTE to identify duplicate values
-- Added a CASE statement to uniquely identify formats such as '06-Sep-18' or 'May 28, 2016' for 'date_added' column
INSERT INTO netflix_staging
WITH cte AS (
	SELECT *,
    ROW_NUMBER() OVER(PARTITION BY title, `type`, director ORDER BY show_id) AS rn
    FROM netflix_raw
)
SELECT 
show_id, `type`, title,
CASE
	WHEN TRIM(date_added) LIKE '%,%' THEN
		STR_TO_DATE(date_added, '%M %d, %Y')
	WHEN TRIM(date_added) LIKE '%-%' THEN
		STR_TO_DATE(date_added, '%d-%b-%y')
	ELSE NULL
END AS date_added,
release_year, rating, duration, `description`
FROM cte
WHERE rn = 1;

-- Using a numbers table trick since MySQL doesn't have string_split
CREATE TABLE numbers (
    n INT
);

INSERT INTO numbers (n)
VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

-- Dimension-Style Tables
-- Genre Table
CREATE TABLE netflix_genre (
  `show_id` VARCHAR(10),
  `genre` VARCHAR(100)
);

-- Populate the genre table : normalized multi-valued 'listed_in' column to split comma-separated values into individual rows
INSERT INTO netflix_genre (show_id, genre)
SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre
FROM netflix_raw
JOIN numbers
ON n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''));

-- Director Table
CREATE TABLE netflix_director (
  `show_id` VARCHAR(10),
  `director` VARCHAR(150)
);

-- Populate the director table : normalized multi-valued 'director' column to split comma-separated values into individual rows
INSERT INTO netflix_director (show_id, director)
SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', n), ',', -1))
FROM netflix_raw
JOIN numbers
ON n <= 1 + LENGTH(director) - LENGTH(REPLACE(director, ',', ''))
WHERE director IS NOT NULL;

-- Cast Table
CREATE TABLE netflix_cast (
  `show_id` VARCHAR(10),
  `actor` VARCHAR(150)
);

-- Populate the cast table : normalized multi-valued 'cast' column to split comma-separated values into individual rows
INSERT INTO netflix_cast (show_id, actor)
SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`cast`, ',', n), ',', -1))
FROM netflix_raw
JOIN numbers
ON n <= 1 + LENGTH(`cast`) - LENGTH(REPLACE(`cast`, ',', ''))
WHERE `cast` IS NOT NULL;

-- Country Table
CREATE TABLE netflix_country (
  `show_id` VARCHAR(10),
  `country` VARCHAR(100)
);

-- Populate the country table : normalized multi-valued 'country' column to split comma-separated values into individual rows
INSERT INTO netflix_country (show_id, country)
SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1))
FROM netflix_raw
JOIN numbers
ON n <= 1 + LENGTH(country) - LENGTH(REPLACE(country, ',', ''))
WHERE country IS NOT NULL;

