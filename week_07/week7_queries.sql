SELECT title, length, NTILE(100) OVER (ORDER BY length) AS percentile
FROM film;

					
