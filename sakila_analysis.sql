USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name,last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name,' ',last_name) AS actor_name FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id,first_name,last_name FROM actor 
	WHERE first_name = "JOE";

-- 2b. Find all actors whose last name contain the letters GEN
SELECT * FROM actor 
	WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
	WHERE last_name LIKE "%LI%"
	ORDER BY last_name ASC, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id,country FROM country
	WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. Add a middle_name column to the table actor. 
-- Position it between first_name and last_name.
ALTER TABLE actor ADD COLUMN middle_name TEXT AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
ALTER TABLE actor MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name,count(*) as last_name_count FROM actor 
	GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name,count(*) as last_name_count FROM actor 
	GROUP BY last_name 
	HAVING count(*) > 1;

-- 4c. Change GROUCHO WILLIAMS to HARPO WILLIAMS in the actor table
UPDATE actor SET first_name = "HARPO" 
	WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO
UPDATE actor SET first_name = 
	IF(actor_id=172 AND first_name = "HARPO", "GROUCHO", 
    IF(actor_id=172 AND first_name != "HARPO", "MUCHO GROUCHO", 
    first_name));

-- 5a. You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?
DESCRIBE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address:
SELECT first_name,last_name,address FROM staff s 
	JOIN address a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member 
-- in August of 2005. Use tables staff and payment.
SELECT first_name,last_name,sum(amount) 
	FROM staff s JOIN payment p ON s.staff_id = p.staff_id 
    WHERE payment_date LIKE "2005-08%" 
    GROUP BY last_name,first_name;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
SELECT title,sum(a.film_id) as total_actors FROM film f 
	JOIN film_actor a ON f.film_id = a.film_id 
    GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title,count(i.film_id) AS copies FROM film f 
	JOIN inventory i ON f.film_id = i.film_id 
    WHERE title = "HUNCHBACK IMPOSSIBLE";

-- 6e. Using the tables payment and customer and the JOIN command, list the total
-- paid by each customer. List the customers alphabetically by last name:
SELECT first_name,last_name,sum(amount) as total FROM customer c 
	JOIN payment p ON c.customer_id = p.customer_id 
    GROUP BY last_name,first_name 
    ORDER BY last_name ASC;

-- 7a. Use subqueries to display the titles of movies starting with 
-- the letters K and Q whose language is English.
SELECT title FROM film 
	WHERE title LIKE "K%" 
    OR title LIKE "Q%" 
    AND language_id IN (
		SELECT language_id FROM language 
        WHERE name = "ENGLISH");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name,last_name FROM actor 
	WHERE actor_id IN (
		SELECT actor_id FROM film_actor 
        WHERE film_id IN (
			SELECT film_id FROM film 
            WHERE title = "ALONE TRIP")) 
	GROUP BY last_name,first_name;

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers.
SELECT first_name,last_name,email FROM customer c 
	JOIN address a ON c.address_id = a.address_id 
    WHERE a.city_id IN (
		SELECT city_id FROM city 
        WHERE country_id IN (
			SELECT country_id FROM country 
            WHERE country = "CANADA")) 
	GROUP BY last_name,first_name; 

-- 7d. Identify all movies categorized as family films
SELECT title FROM film 
	WHERE film_id IN (
		SELECT film_id FROM film_category 
        WHERE category_id IN (
			SELECT category_id FROM category 
            WHERE name = "Family")) 
	GROUP BY title;

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title,sum(r.inventory_id) as total_rentals FROM film f 
	JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY f.title;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id,sum(amount) as business FROM store
	JOIN staff s ON store.manager_staff_id = s.staff_id
    JOIN payment p ON s.staff_id = p.staff_id
    GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id,ci.city,co.country FROM store s
	JOIN address a ON s.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    GROUP BY s.store_id;

-- 7h. List the top five genres in gross revenue in descending order. 
SELECT c.name as genre,sum(p.amount) as total FROM category c
	JOIN film_category f ON c.category_id = f.category_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.name
    ORDER BY p.amount DESC
    LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
CREATE VIEW top_five_genres AS
SELECT c.name as genre,sum(p.amount) as total FROM category c
	JOIN film_category f ON c.category_id = f.category_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.name
    ORDER BY p.amount DESC
    LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
