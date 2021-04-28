1.	Create a new column called “status” in the rental table that uses a case statement to indicate if a film was returned late, early, or on time. 
SELECT rental_id, inventory_id, date_part('day', return_date - rental_date) AS rental_length
INTO rental_3
FROM rental;

DROP View if exists rental_status;
Create view rental_status as
SELECT rental_id, r.inventory_id,
	CASE WHEN rental_duration -rental_length = 0 THEN 'On time'
		WHEN rental_duration -rental_length < 0 THEN 'Late'
		ELSE 'Early' END 
		AS status
FROM rental_3 AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id;

SELECT r1.rental_id, rental_date, r1.inventory_id, customer_id, return_date, staff_id, last_update, status
FROM rental AS r1
JOIN rental_status AS r2
ON r1.rental_id = r2.rental_id;
/*Building off of the week 6 homework I created a table with a new column of rental_length to use in my CASE calculation
Then I created a view that contained the rental_id, inventory_id and status of the rental, I needed to join the rental_3 table with the inventory and film
tables to get the status since rental_duration is only in the film table. Lastly I joined the rental table with the rental_status table
so the output has all of the columns in rental plus the new status column */

2.	Show the total payment amounts for people who live in Kansas City or Saint Louis. 
SELECT city, c1.customer_id, SUM(amount) AS total_payment
FROM payment AS p
JOIN customer AS c1
ON p.customer_id = c1.customer_id
JOIN address AS a
ON c1.address_id = a.address_id
JOIN city AS c2
ON c2.city_id = a.city_id
WHERE c1.customer_id IN 
	(SELECT customer_id
	FROM customer AS c1
	JOIN address AS a
	ON c1.address_id = a.address_id
	JOIN city AS c2
	ON c2.city_id = a.city_id
	WHERE city = 'Saint Louis' OR city = 'Kansas City')
GROUP BY c2.city, c1.customer_id
ORDER BY total_payment;
/*In order to show the total payment amounts for customers who live in KC of STL we needed
to join the payment, customer, address and city tables to include the city in the output
then we used a subquery to make sure that only customers who lived in STL or KC would be included */

3.	How many film categories are in each category? Why do you think there is a table for category and a table for film category?
SELECT COUNT(f.category_id), name
FROM film_category AS f
JOIN category AS c
ON f.category_id = c.category_id
GROUP BY f.category_id, name;
/*I pulled the count of each category_id in the film_category table and joined it withe the category
table to get the number of films in each category

I think there's a separate category table so that you can see all of the categories neatly in one place
rather than spread out among the film_category table*/

4.	Show a roster for the staff that includes their email, address, city, and country (not ids)
SELECT staff_id,email, address, address2, city, country
FROM staff AS s
JOIN address AS a
ON s.address_id = a.address_id
JOIN city AS c1
ON c1.city_id = a.city_id
JOIN country AS c2
ON c2.country_id = c1.country_id;
/*I had to join the staff, address, city and country tables on their key IDs to get the appropriate info*/

5.	Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
SELECT f.film_id, title, length
FROM film AS f
JOIN inventory AS i
ON f.film_id = i.film_id
WHERE inventory_id IN
(SELECT inventory_id
FROM rental
WHERE return_date BETWEEN '2005-05-15 00:00:00' AND '2005-05-31 23:59:59');
/*I joined the film and invenotry tables on film_id so that I would have access tot he invenotry_id column
then I did a subquery that checked for inventory_ids from the joined table in the resulting table of returns
between May 15 and May 31, 2005*/

6.	Write a subquery to show which movies are rented below the average price for all movies. 
SELECT f.title, rental_rate
FROM film AS f
JOIN inventory AS i
ON f.film_id = i.film_id
JOIN rental AS r
ON i.inventory_id = r.inventory_id
WHERE rental_rate < (SELECT AVG(rental_rate) FROM film);

/*Calculated average rental rate of all films in the subquery. Joined the film, inventory and rental
tables to determine which films were rented under the average rental rate. */

7.	Write a join statement to show which moves are rented below the average price for all movies.
SELECT f1.title, f1.rental_rate
FROM film AS f1
JOIN (SELECT AVG(rental_rate) AS avg_rental_rate FROM film) AS f2
ON f1.rental_rate < f2.avg_rental_rate
JOIN inventory AS i
ON f1.film_id = i.film_id
JOIN rental AS r
ON i.inventory_id = r.inventory_id;
/* Included my subquery as part of a join statement to compare the rental rate to the average rental rate*/

8.	Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they differ.
--Explain plan for #6 
Total Cost was 663.14
	#	Node	Rows
Plan
1.	Hash Inner Join (cost=239.13..663.14 rows=5341 width=21)
Hash Cond: (r.inventory_id = i.inventory_id)
5341
2.	Aggregate (cost=66.5..66.51 rows=1 width=32)	1
3.	Seq Scan on film as film (cost=0..64 rows=1000 width=6)	1000
4.	Seq Scan on rental as r (cost=0..310.44 rows=16044 width=4)	16044
5.	Hash (cost=153.55..153.55 rows=1525 width=25)	1525
6.	Hash Inner Join (cost=70.66..153.55 rows=1525 width=25)
Hash Cond: (i.film_id = f.film_id)
1525
7.	Seq Scan on inventory as i (cost=0..70.81 rows=4581 width=6)	4581
8.	Hash (cost=66.5..66.5 rows=333 width=25)	333
9.	Seq Scan on film as f (cost=0..66.5 rows=333 width=25)
Filter: (rental_rate < $0)

--Explain plan for #7
Total Cost was 693.5.
	#	Node	Rows
Plan
1.	Hash Inner Join (cost=269.49..693.5 rows=5341 width=21)
Hash Cond: (r.inventory_id = i.inventory_id)
5341
2.	Seq Scan on rental as r (cost=0..310.44 rows=16044 width=4)	16044
3.	Hash (cost=250.42..250.42 rows=1525 width=25)	1525
4.	Hash Inner Join (cost=147.19..250.42 rows=1525 width=25)
Hash Cond: (i.film_id = f1.film_id)
1525
5.	Seq Scan on inventory as i (cost=0..70.81 rows=4581 width=6)	4581
6.	Hash (cost=143.02..143.02 rows=333 width=25)	333
7.	Nested Loop Inner Join (cost=66.5..143.02 rows=333 width=25)
Join Filter: (f1.rental_rate < (avg(film.rental_rate)))
333
8.	Aggregate (cost=66.5..66.51 rows=1 width=32)	1
9.	Seq Scan on film as film (cost=0..64 rows=1000 width=6)	1000
10.	Seq Scan on film as f1 (cost=0..64 rows=1000 width=25)	

/*The code used in question 6 requires one fewer steps and is able to fun a little faster with a slightly lower cost.*/

9.	With a window function, write a query that shows the film, its duration, and what percentile the duration fits into. This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 
SELECT title, length, NTILE(100) OVER (ORDER BY length) AS percentile
FROM film;
/* Selected, title and length (for film duration) and then used the window function to show percentile*/
10.	In under 100 words, explain what the difference is between set-based and procedural programming. Be sure to specify which sql and python are. 
/* Set-based programming allows you to use code to say what results you want to get without necessarily specifiying how to get the results.
Procedural programming allows you to use code to say how to get the results you want via a set of procedural steps, you can also tell it what
you want to get but you have to do that procedurally as well.
So SQL is set-based programming because we can tell the database enginge what we want and the database engine figures out how.
Python is more of a procedural programming.
*/