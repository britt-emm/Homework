1.	Show all customers whose last names start with T. Order them by first name from A-Z.
SELECT *
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name;
-- selected all columns from the customer table
/* the WHERE line limited it to last names beginning with T and the
ORDER BY put them in alphabetical order */
2.	Show all rentals returned from 5/28/2005 to 6/1/2005
SELECT *
FROM rental
WHERE return_date BETWEEN '2005-05-28 0:00:00' AND '2005-06-01 23:59:59';
/* selected all rentals returned between 5/28/2005 yo 6/1/2005
The WHERE lines used BETWEEN and because the columns utilized a timestamp
I had to format my dates to match the timestamp
Also put the timestamp in quote */
3.	How would you determine which movies are rented the most?
SELECT COUNT(r.inventory_id) AS number_of_rentals, f.film_id, f.title
FROM inventory AS i
INNER JOIN rental AS r
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON f.film_id = i.film_id
GROUP BY f.film_id
ORDER BY COUNT(*) DESC;
/* You want to join the inventory, rental and film tables because you need 
a count of how many times each inventory ID was rented for each film. 
You group by film_id because there can be multiple inventory_ids for one film_id*/
4.	Show how much each customer spent on movies (for all time) . Order them from least to most.
SELECT customer_id, SUM(amount) AS total_payment
FROM payment
GROUP BY customer_id
ORDER BY total_payment;
/*this selects all of the customer and the sum of the amounts each customer paid aliased as total_payment
The results are grouped by customer_id and then put in order by the total payment from smallest to largest*/
5.	Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.
SELECT CONCAT(first_name,' ',last_name) AS actor_name, COUNT(f1.film_id) AS number_of_films
FROM actor AS a
INNER JOIN film_actor AS f1
ON a.actor_id = f1.actor_id
INNER JOIN film AS f2
ON f1.film_id = f2.film_id
WHERE release_year = 2006
GROUP BY actor_name
ORDER BY number_of_films DESC
LIMIT 5;
/* SELECT CONCAT() allows me to combine the first and last name columns into a single name column
joined the actor and film_actor tables to get the common column of film_id that we could then join
with the film column to know how many films each actor was in. COUNT() was used to get the number of films
Then we limited the films to those that were released in 2006 and grouped them by actor
in order of number of films descending so that the higher number of films would show up at the top. 
You could just do limit 1 but I chose 5 so I could see a comparison. */
6.	Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to understand how this works http://postgresguide.com/performance/explain.html 
-- Number 4
SELECT customer_id, SUM(amount) AS total_payment
FROM payment
GROUP BY customer_id
ORDER BY total_payment;
/* sorts through 599 rows(cost =362.06..363.56) Sort Key (sum(amount))
HashAggregate (cost= 326.94..334.43 rows = 599) 
Group Key: customer_id
seq scan on payment (cost=0.00.. 253.96 rows = 14596)*/

-- Number 5
SELECT CONCAT(first_name,' ',last_name) AS actor_name, COUNT(f2.film_id) AS number_of_films
/* 1. seq scan 'actor AS a' startup cost 0, total cost 4, Hash inner startup cost 4, total cost 4; seq scan film_actor startup cost 0, total cost 84.62
seq scan film AS f2 startup cost 0, total cost 66.5, filter release_year = 2006, Hash inner startup cost 66.5, total cost 66.5 */
FROM actor AS a
INNER JOIN film_actor AS f1
ON a.actor_id = f1.actor_id
-- 2. hash join inner startup cost 6.5, total cost 105.76
INNER JOIN film AS f2
ON f1.film_id = f2.film_id
-- 3. hash join inner startup cost 85.5 total cost 212.81
WHERE release_year = 2006
GROUP BY actor_name
--4 Aggregate simple hashed concat() startup cost 240.12, total cost 241.72
ORDER BY number_of_films DESC
--5 Sort count(f2.film_id) startup cost 243.84, total cost 244.16
LIMIT 5;
-- 6 Limit startup cost 243.84, total cost 243.86
7.	What is the average rental rate per genre?
SELECT c.category_id, name AS genre, AVG(rental_rate)::NUMERIC(10,2) AS avg_rental_rate
FROM category AS c
LEFT JOIN film_category AS f1
ON c.category_id = f1.category_id
LEFT JOIN film AS f2
USING(film_id)
GROUP BY c.category_id;
/* Select the columns category ID, category name as genre and the average rental rate formatted like a dollar amount
left join category  to film_cateegory on teh category id and then left join to the film table on the film_id since film_id isnt in the category table
group by category_id*/
8.	How many films were returned late? Early? On time?
SELECT inventory_id, date_part('day', return_date - rental_date) AS rental_length
INTO rental_2
FROM rental;

SELECT COUNT(*),
	CASE WHEN rental_duration - rental_length = 0 THEN 'On time'
		WHEN rental_duration - rental_length < 0 THEN 'Late'
		ELSE 'Early' END
		AS return_timing
FROM rental_2 AS r
INNER JOIN inventory AS i
USING(inventory_id)
INNER JOIN film AS f
USING(film_id)
GROUP BY return_timing;
/* First create a new table rental_2 that calculates rental_length in days
Then Use CASE WHEN THEN to sort the rental length into three categories: on time, late, early
You will need to join the new rental_2 table with the inventory table to get an inventory_id
and join with the film table to get a film_id and to access the rental duration 
(the amount of time a film can be rented). Then you can group the results by return_timing*/
9.	What categories are the most rented and what are their total sales?
SELECT COUNT(p.rental_id), c.name AS category_name, SUM(p.amount)
FROM category c
JOIN film_category f
ON c.category_id = f.category_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY category_name
ORDER BY COUNT(p.rental_id) DESC;
/* Need to join the category, film_category, rental, inventory and payment tables
to be able to look at categories, payments and number of rentals together.
You want the count of the rental to see what category is most rented, and 
the sum of the payments to look at total sales. Not all of the categories
in the top 5 for rentals are the top 5 for sales.*/
10.	Create a view for 8 and a view for 9. Be sure to name them appropriately. 
-- Number 8
CREATE VIEW rental_return_timing AS
SELECT COUNT(*),
	CASE WHEN rental_duration - rental_length = 0 THEN 'On time'
		WHEN rental_duration - rental_length < 0 THEN 'Late'
		ELSE 'Early' END
		AS return_timing
FROM rental_2 AS r
INNER JOIN inventory AS i
USING(inventory_id)
INNER JOIN film AS f
USING(film_id)
GROUP BY return_timing;
/* This created a view that will return the same columns and rows showing 
how many rentals were returned on time, late or early if the view
is referenced in a query. ** Note that I did not include the creation
of the rental_2 table since it already exists from when I ran it the first time*/

-- Number 9
CREATE VIEW top_category_rentals_and_sales AS
SELECT COUNT(p.rental_id), c.name AS category_name, SUM(p.amount)
FROM category c
JOIN film_category f
ON c.category_id = f.category_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY category_name
ORDER BY COUNT(p.rental_id) DESC;
/* This created a view called top_category_rentals_and_sales so
that now if you run SELECT * FROM top_category_rentals_and_sales
you will see the same rows and columns*/
Bonus: Write a query that shows how many films were rented each month. Group them by category and month. 
