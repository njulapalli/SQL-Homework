use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name 
From actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT CONCAT(first_name, ' ' , last_name) AS 'Actor Name'
  FROM actor ;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

Select actor_id, first_name, last_name From actor Where first_name = 'Joe';

--  2b. Find all actors whose last name contain the letters `GEN`:

Select * From actor Where last_name like '%GEN%' ;

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

Select * From actor Where last_name like '%LI%'  Order by last_name, first_name;  

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

Select country_id, country From Country Where country IN ( 'Afghanistan', 'Bangladesh', 'China'); 

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE actor
ADD description BLOB;

Select * From actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description; 

Select * From actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.


SELECT last_name, count(last_name)
 FROM  actor
 Group by last_name;
 
 -- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
 
SELECT last_name, count(last_name) AS last_name_count
FROM  actor
Group by last_name
HAVING last_name_count >1;  

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SELECT * FROM actor 
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS'; 

UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS'; 

SELECT * FROM actor 
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS'; 

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, 
-- change it to `GROUCHO`.

UPDATE actor 
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS'; 

SELECT * FROM actor 
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS'; 


-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 

select * from  address;

CREATE TABLE my_address (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  /*!50705 location GEOMETRY NOT NULL,*/
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id)
);
INSERT INTO `my_address` 
VALUES 
(1,'47 MySakila Drive',NULL,'Alberta',300,'','',/*!50705 0x0000000001010000003E0A325D63345CC0761FDB8D99D94840,*/'2014-09-25 22:30:27'),
(2,'28 MySQL Boulevard',NULL,'QLD',576,'','',/*!50705 0x0000000001010000008E10D4DF812463404EE08C5022A23BC0,*/'2014-09-25 22:30:09'),
(3,'23 Workhaven Lane',NULL,'Alberta',300,'','14033335568',/*!50705 0x000000000101000000CDC4196863345CC01DEE7E7099D94840,*/'2014-09-25 22:30:27');

select * from my_address;

DROP TABLE my_address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:


SELECT staff.first_name, staff.last_name, address.address
FROM 
staff 
LEFT JOIN address on staff.address_id = address.address_id; 

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT payment.staff_id, staff.first_name, staff.last_name, payment.amount, payment.payment_date 
FROM 
staff
LEFT JOIN payment on staff.staff_id = payment.staff_id
WHERE  payment_date LIKE '2005-08%' 
;
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT film.title, COUNT(film_actor.actor_id) AS "Number of Actors"
FROM 
film_actor
LEFT JOIN film on film.film_id = film_actor.film_id

Group by film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? 
SELECT  film.title, count(film.title)
FROM inventory
inner join film  on film.film_id = inventory.film_id 
where film.title = 'Hunchback Impossible'
group by film.title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
--  List the customers alphabetically by last name:

SELECT  customer.first_name, customer.last_name, sum(payment.amount)
FROM customer
inner join payment on customer.customer_id = payment.customer_id
group by customer.first_name, customer.last_name;



-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select film.title
from film
where (film.title like 'Q%' or film.title like 'K%')
and exists 
(
   select * from language where language.language_id = film.language_id
   and language.name = 'English'
)

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT  film.title, 
( 
	select concat (actor.first_name, ' ', actor.last_name) from actor where actor.actor_id = film_actor.actor_id 
)
from film
join film_actor on film.film_id = film_actor.film_id
where film.title = 'Alone Trip';


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT  country, customer.first_name, customer.last_name,  customer.email
FROM customer
inner join address on address.address_id = customer.address_id
inner join city on address.city_id = city.city_id
inner join country on country.country_id = city.country_id
where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

SELECT  country, customer.first_name, customer.last_name,  customer.email
FROM customer
inner join address on address.address_id = customer.address_id
inner join city on address.city_id = city.city_id
where country.country = 'Canada'

--  7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
--  Identify all movies categorized as _family_ films.
select film.title, category.name
from film 
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
and category.name = 'Family']

-- 7e. Display the most frequently rented movies in descending order.

select film.title, count(film.title) as "Number of Rentals"
from inventory 
inner join rental on rental.inventory_id = inventory.inventory_id
inner join film on film.film_id = inventory.film_id
group by film.title
Order by count(film.title) desc

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id, sum(payment.amount) as "Dollars"  
from payment
inner join staff on staff.staff_id = payment.staff_id
inner join store on store.store_id = staff.store_id 
group by store.store_id

-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store
inner join address on address.address_id = store.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id ;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select  category.name, sum(payment.amount) as "gross income in dollars" 
from film
inner join film_category on film_category.film_id = film.film_id 
inner join category on category.category_id =  film_category.category_id
inner join inventory on film.film_id =  inventory.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by category.name
Order by sum(payment.amount) desc
limit 5;


--  8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
--  Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.


Create View  top_five_grossers as 
select  category.name, sum(payment.amount) as "gross income in dollars" 
from film
inner join film_category on film_category.film_id = film.film_id 
inner join category on category.category_id =  film_category.category_id
inner join inventory on film.film_id =  inventory.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by category.name
Order by sum(payment.amount) desc
limit 5;
 
 -- 8b. How would you display the view that you created in 8a?
Select * from top_five_grossers;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop View  top_five_grossers;


