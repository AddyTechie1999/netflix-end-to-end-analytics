-- Q1. How is Netflix’s content split between Movies and TV Shows?
SELECT `type`, COUNT(DISTINCT show_id) AS no_of_titles
FROM netflix_staging
GROUP BY `type`;

-- Q2. How has Netflix's catalog grown over the years since its relevance in 2010?
SELECT YEAR(date_added) AS year_added, 
COUNT(DISTINCT show_id) AS no_of_titles
FROM netflix_staging
GROUP BY year_added
HAVING year_added >= 2010
ORDER BY year_added;

-- Q3. What are the top 10 genres with the highest number of titles on Netflix?
SELECT genre, COUNT(DISTINCT show_id) AS no_of_titles
FROM netflix_genre
GROUP BY genre
ORDER BY no_of_titles DESC
LIMIT 10;

-- Q4. Which content ratings (TV-MA, TV-14, PG, etc.) dominate the platform (top 5)?
SELECT rating, COUNT(DISTINCT show_id) AS no_of_titles
FROM netflix_staging
GROUP BY rating
ORDER BY no_of_titles DESC
LIMIT 5;

-- Q5. Which countries produces the most Netflix content (top 10)?
SELECT country, COUNT(DISTINCT show_id) AS no_of_titles
FROM netflix_country
GROUP BY country
ORDER BY no_of_titles DESC
LIMIT 10;

-- Q6. Which countries (top 10) focuses more on TV Shows vs Movies?
WITH top_countries AS (
	SELECT country
	FROM netflix_country
	GROUP BY country
	ORDER BY COUNT(DISTINCT show_id) DESC
	LIMIT 10
)
SELECT c.country,
CONCAT(ROUND(
	COUNT(CASE WHEN s.`type` = 'Movie' THEN 1 END) / COUNT(DISTINCT s.show_id) * 100, 2
), '%') AS 'Movies %',
CONCAT(ROUND(
	COUNT(CASE WHEN s.`type` = 'TV Show' THEN 1 END) / COUNT(DISTINCT s.show_id) * 100, 2
), '%') AS 'TV Shows %'
FROM netflix_staging s
	JOIN netflix_country c ON s.show_id = c.show_id
    JOIN top_countries tc ON c.country = tc.country
GROUP BY c.country
ORDER BY COUNT(DISTINCT s.show_id) DESC;

-- Q7. How does genre distribution differ between top 10 countries(3 genres per country)?
WITH top_countries AS (
	SELECT country
	FROM netflix_country
	GROUP BY country
	ORDER BY COUNT(DISTINCT show_id) DESC
	LIMIT 10
)
SELECT country, genre
FROM (
	SELECT c.country, g.genre,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(DISTINCT g.show_id) DESC, g.genre) AS rn
	FROM netflix_genre g
		JOIN netflix_country c ON g.show_id = c.show_id
		JOIN top_countries tc ON c.country = tc.country
	GROUP BY c.country, g.genre
    ORDER BY tc.country
) t
WHERE t.rn <= 3;

-- Q8. In which months does Netflix add the most new content?
SELECT MONTHNAME(date_added) AS month_added,
COUNT(DISTINCT show_id) AS no_of_titles
FROM netflix_staging
WHERE YEAR(date_added) >= 2016
AND date_added IS NOT NULL
GROUP BY month_added
ORDER BY no_of_titles DESC;

-- Q9. What is the average time gap between content release year and date added to Netflix?
SELECT ROUND(AVG(
	TIMESTAMPDIFF(MONTH,
	STR_TO_DATE(CONCAT(release_year, '-01-01'), '%Y-%m-%d'), 
	date_added)
) / 12, 2) AS avg_time_gap
FROM netflix_staging
WHERE date_added IS NOT NULL
AND release_year IS NOT NULL;

-- Q10. What genres dominate mature (TV-MA / R-rated) content (top 5)?
SELECT g.genre, 
COUNT(DISTINCT g.show_id) AS mature_titles
FROM netflix_genre g
	JOIN netflix_staging s ON g.show_id = s.show_id
WHERE s.rating IN ('TV-MA', 'R')
GROUP BY g.genre
ORDER BY mature_titles DESC
LIMIT 5;

-- Q11. Which genres (top 5) are most common in recent releases (last 5 years)?
SELECT g.genre, 
COUNT(DISTINCT g.show_id) AS no_of_titles
FROM netflix_genre g
	JOIN netflix_staging s ON g.show_id = s.show_id
WHERE s.date_added >= DATE_SUB(
(SELECT MAX(date_added) FROM netflix_staging),
 INTERVAL 5 YEAR)
GROUP BY g.genre
ORDER BY no_of_titles DESC
LIMIT 5;

-- Q12. What is the average duration of Movies by genre?
SELECT g.genre, ROUND(AVG(
	CAST(SUBSTRING_INDEX(s.duration, ' ', 1) AS UNSIGNED)), 2
    ) AS avg_duration_in_min
FROM netflix_staging s
	JOIN netflix_genre g ON s.show_id = g.show_id
WHERE duration LIKE '%min%'
AND s.`type` = 'Movie'
GROUP BY g.genre
ORDER BY avg_duration_in_min DESC;

-- Q13. What is the most common TV Show duration pattern?
SELECT CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS seasons,
COUNT(DISTINCT show_id) AS total_tv_shows
FROM netflix_staging
WHERE duration LIKE '%Season%'
AND duration IS NOT NULL
AND `type` = 'TV Show'
GROUP BY seasons
ORDER BY total_tv_shows DESC;

-- Q14. What percentage of titles have missing director, cast or country data in the dimension table 'netflix_raw'?
SELECT 
CONCAT(
	ROUND(
		COUNT(DISTINCT CASE
			WHEN director IS NULL OR TRIM(director) = '' THEN show_id
		END) / COUNT(DISTINCT show_id) * 100 , 2)
, '%') AS percent_of_missing_director,
CONCAT(
	ROUND(
		COUNT(DISTINCT CASE
			WHEN `cast` IS NULL OR TRIM(`cast`) = '' THEN show_id
		END) / COUNT(DISTINCT show_id) * 100 , 2)
, '%') AS percent_of_missing_cast,
CONCAT(
	ROUND(
		COUNT(DISTINCT CASE
			WHEN country IS NULL OR TRIM(country) = '' THEN show_id
		END) / COUNT(DISTINCT show_id) * 100 , 2)
, '%') AS percent_of_missing_country
FROM netflix_raw;

-- Q15. Which regions and genres present growth opportunities?
WITH top_countries AS (
	SELECT country
	FROM netflix_country
	GROUP BY country
	ORDER BY COUNT(DISTINCT show_id) DESC
	LIMIT 10
)
SELECT country, genre
FROM (
	SELECT c.country, g.genre,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(DISTINCT g.show_id) DESC, g.genre) AS rn
	FROM netflix_genre g
		JOIN netflix_country c ON g.show_id = c.show_id
		JOIN top_countries tc ON c.country = tc.country
	GROUP BY c.country, g.genre
    ORDER BY tc.country, rn
) t
WHERE t.rn BETWEEN 2 AND 4;


