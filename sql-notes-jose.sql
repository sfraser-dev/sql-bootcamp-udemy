-- SQL single line comments

/* 
SQL multi 
line comments
*/

-- SQL uses 'single quotes', double quotes give error
-- SQL letter case does matter for vaiables
-- SQL answers business questions

-- SELECT
-- FROM
-- DISTINCT
-- COUNT
-- WHERE
-- =, >, <, >=, <=, != (<>), AND, OR, NOT
-- ORDER BY
-- ASC (default ascending)
-- DESC 
-- LIMIT (limit amount of rows returned)

-- ----- SELECT, DISTINCT AND COUNT clauses
-- remove cols that are duplicates (like set()) for the col)
SELECT DISTINCT my_col FROM my_table;
SELECT DISTINCT(my_col) FROM my_table; -- can also write like this
-- how many rows in this col (ie: the table)
SELECT COUNT(my_col)
-- how many distinct rows are there? 
SELECT COUNT(DISTINCT my_col)

-- Using the dvdrental.tar sample DB
-- count total amount of rows in payment table
SELECT COUNT(*) FROM payment;

-- ----- SELECT, WHERE, ORDER BY and LIMIT clauses
SELECT * FROM customer WHERE first_name = 'Jared';
SELECT * FROM film WHERE rental_rate > 4;
SELECT * FROM film WHERE rental_rate > 4 AND replacement_cost > 19.99;
SELECT * FROM film WHERE rental_rate > 4 AND replacement_cost > 19.99 AND rating='R';
SELECT * FROM film WHERE rating='R' OR rating='PG-13';
SELECT * FROM film WHERE rating!='R';
SELECT * FROM customer WHERE first_name='Nancy' AND last_name='Thomas';
SELECT description FROM film WHERE title='Outlaw Hanky';
SELECT address,phone FROM address WHERE address='259 Ipoh Drive';
-- SELECT * FROM customer ORDER BY store_id, first_name;
-- quickly get 1 row from table to see data type,
-- column names, general table layout, etc
SELECT * FROM payments LIMIT 1;
-- get the most recent 5 payments
-- SELECT * FROM payment ORDER BY payment_date DESC LIMIT 5;
-- get the most recent 5 payments that were not 0
SELECT * FROM payment WHERE amount!=0 ORDER BY payment_date DESC LIMIT 5; 
SELECT payment_date, customer_id ID
  FROM payment ORDER BY payment_date ASC LIMIT 10;
-- note length is a SQL command (as well as a column in film table)
SELECT title, length FROM film ORDER BY length ASC LIMIT 5;
-- note length is a SQL command (as well as a column in film table), so use
-- table.col notation
SELECT title, length FROM film WHERE length <= 50 ORDER BY length;
SELECT title, film.length FROM film WHERE film.length <= 50 ORDER BY film.length;
SELECT COUNT(film.length) FROM film WHERE film.length <= 50;

-- ----- BETWEEN AND NOT BETWEEN clauses
-- BETWEEN low and high is like using val >= low AND val <= high (inclusive
-- of low and high)
-- NOT BETWEEN is like val < low OR val > high (exclusive of low and high)
-- Nice, so NOT BETWEEN is every that is not BETWEEN
-- BETWEEN can be used with dates in the YYYY-MM-DD format
SELECT COUNT(*) FROM payment WHERE amount BETWEEN 8 AND 9;
SELECT COUNT(*) FROM payment WHERE amount NOT BETWEEN 8 AND 9;
SELECT * FROM payment WHERE payment_date BETWEEN '2007-02-01' AND '2007-02-15'; 

-- ----- IN clause
SELECT * FROM payment WHERE amount = 0.99 OR amount = 1.98 OR amount = 1.99;
SELECT * FROM payment WHERE amount IN (0.99, 1.98, 1.99);
SELECT * FROM payment WHERE amount NOT IN (0.99, 1.98, 1.99);

-- ----- LIKE / ILIKE Pattern Matching (strings) clauses
-- ILIKE   -- ignore case
-- %       -- multiple sequnece of characters
-- _       -- single character
-- ___     -- can use multiple inderscores
-- Regex   -- PostgreSQL can use Regex (see "functions matching")
--
-- Find names begining with J 
SELECT * FROM customer WHERE first_name ILIKE 'J%';
SELECT COUNT(*) FROM customer WHERE first_name ILIKE 'J%'; 
SELECT * FROM customer WHERE first_name NOT ILIKE 'J%'; 
SELECT * FROM customer WHERE first_name ILIKE 'J%' AND last_name ILIKE 'S%';

-- ----- Challenges
SELECT COUNT(amount) FROM payment WHERE amount > 5; 
SELECT COUNT(*) FROM actor WHERE first_name LIKE 'P%'; 
SELECT DISTINCT(district) FROM address; 
SELECT COUNT(DISTINCT(district)) FROM address; 
SELECT COUNT(*) FROM film WHERE rating='R' AND replacement_cost BETWEEN 5 AND 15;
SELECT COUNT(*) FROM film WHERE title LIKE '%Truman%';

-- ----- GROUP BY and aggregate functions
-- aggregate function: take multiple inputs and return a single output
-- the most common aggregate functions are avg(), count(), max(), min(), sum()
SELECT MIN(replacement_cost) FROM film;
SELECT SUM(replacement_cost) FROM film;
SELECT ROUND(AVG(replacement_cost),2) FROM film;
SELECT MIN(replacement_cost), MAX(replacement_cost) FROM film;
-- see the total that every customer spent
SELECT SUM(amount), customer_id FROM payment GROUP BY customer_id 
-- sort the previous query to see the highest spending customer (nb: order by
-- sum()).. notice we order by sum(amount), not amount, as we need to order by
-- the aggregate result
SELECT SUM(amount), customer_id
  FROM payment GROUP BY customer_id ORDER BY SUM(amount) DESC;
-- how much did each customer spent PER staff member sorted
-- "PER" gives a hint that a group by is needed
SELECT customer_id, staff_id, SUM(amount)
  FROM payment GROUP BY (staff_id, customer_id) ORDER BY customer_id ASC;
-- sort the days most revenue was made from high to low
-- payment_date is a time-stamp, date and time to sub second, so need the
-- date() function
SELECT DATE(payment_date), SUM(amount) FROM payment
GROUP BY DATE (payment_date)
ORDER BY SUM(amount) DESC;

-- ----- Challenge
-- what staff member has processes the most payments?
SELECT COUNT(amount), staff_id FROM payment GROUP BY staff_id;
-- Corporate want to know what is the average replacement cost PER film rating?
SELECT * FROM film LIMIT 5; -- give me a view of the table film
SELECT ROUND(AVG(replacement_cost),2), rating FROM film GROUP BY rating;
-- what are the top 5 customers by total spend - give them a coupon?
SELECT customer_id, SUM(amount)
  FROM payment GROUP BY customer_id ORDER BY SUM(amount) DESC LIMIT 5;

-- ----- HAVING clause
-- Happens after an aggregate function, ie: after a GROUP BY
-- We can use WHERE if it's not an aggregate function result
-- We can use HAVING on an aggregate function result
-- HAVING allows us to use the aggregate result as a filter along with a GROUP BY
SELECT company, SUM(sales)
FROM finance_table
WHERE company !='Google'
GROUP BY company
HAVING SUM(sales)>1000;

-- ----- HAVING challenge
-- customers that have 40 or more transactions
SELECT customer_id, COUNT(amount) FROM payment
GROUP BY customer_id
HAVING COUNT(amount) >= 40

-- customers that have spent > $100 interacting with staff_id2
SELECT customer_id, SUM(amount), staff_id FROM payment
WHERE staff_id = 2
GROUP BY customer_id, staff_id
HAVING SUM(amount) > 100

-- ----- ASSESSMENT test
-- customers that have spent > $110 interacting with staff_id2
SELECT customer_id, SUM(amount), staff_id FROM payment
WHERE staff_id = 2
GROUP BY customer_id, staff_id
HAVING SUM(amount) > 110

-- how many films begin with letter J
SELECT COUNT(title) FROM film
WHERE title ILIKE 'J%';

-- customer has the highest customer ID number whose name starts 
-- with an 'E' and has an address ID lower than 500?
SELECT first_name, last_name FROM customer
WHERE first_name ILIKE 'E%' AND address_id < 500
ORDER BY customer_id DESC
LIMIT 1

-- ----- JOINS
/*
(full) inner join: is the easiest, 
only keep rows present in both tables,
symmetrical venn diagram.

(full) outer join:
also easy, symmetrical venn diagram

inverse inner join "trick"
(full) outer join with where A=null OR B=null: 
*/

-- inverse inner join achieved using outer join WHERE NULL "trick"
SELECT * FROM payment 
FULL OUTER JOIN customer
ON customer.customer_id = payment.customer_id
WHERE customer.customer_id IS NULL OR payment.customer_id IS NULL;
-- (use IS keyword with NULL, not =)

/*
left (outer) join: exclusive to table A or row match with B (if only found
in table B, it will not be returned in the view), non-symetrical venn diagram,
returns everything in table A or things found in A & B. Order of tables is
important in left join (non-symmetrical)

right (outer) join is exact opposite of left join. In fact, reversing the
order of tables on a left join would give the same as a right join. Just
about how you think about the tables in your mind.
*/

-- ----- JOIN Challenge Tasks
-- Get emails of customers living in California
SELECT CONCAT(customer.first_name,' ',customer.last_name)
AS "full name", email, district
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id
WHERE address.district = 'California'

-- What movies has Nick Wahlberg in them
SELECT title, CONCAT(first_name, ' ', last_name)
AS "actor name" FROM film
INNER JOIN film_actor
ON film_actor.film_id = film.film_id
INNER JOIN actor
ON actor.actor_id = film_actor.actor_id
WHERE actor.first_name='Nick' AND actor.last_name='Wahlberg';

-- ----- UNIONS
-- Combines the view of two (or more) select statements together
-- Concatentes views of two+ SELECTS together

-- ----- Advanced SQL Commands -----
-- Day starts at time 00:00:00.000 and finishes at 23:59:59.999
-- HH:MM:SS.mmm (Hour, Minute, Second, millisecond)
-- ----- Timestamps and EXTRACT
-- 4 main ones: TIME, DATE, TIMESTAMP, TIMESTAMPTZ
-- Some commands: TIMEZONE, NOW, TIMEOFDAY, CURRENT_TIME, CURRENT_DATE
-- SHOW command returns system info
SHOW ALL;
SHOW TIMEZONE;
SELECT NOW(); -- Timestamp
SELECT TIMEOFDAY();
SELECT CURRENT_DATE;

-- Extract (obtain) a subcomponent of a date value
-- EXTRACT YEAR, MONTH, DAY, WEEK, QUARTER
-- AGE() gives the age using a timestamp
-- TO_CHAR(), changes datatypes to text
SELECT EXTRACT(YEAR FROM payment_date) FROM payment;
SELECT EXTRACT(YEAR FROM payment_date) AS "year" FROM payment;
SELECT AGE(payment_date) FROM payment;
SELECT TO_CHAR(payment_date, 'MONTH-YYYY') FROM payment;
SELECT TO_CHAR(payment_date, 'MONTH YYYY') FROM payment;
SELECT TO_CHAR(payment_date, 'mon YY') FROM payment;
SELECT TO_CHAR(payment_date, 'dd/mon/YY') FROM payment;
SELECT TO_CHAR(payment_date, 'dd/mm/yy') FROM payment;
SELECT TO_CHAR(payment_date, 'DAY MONTH YEAR') FROM payment;

-- ----- Timestamps and EXTRACT challeneg tasks
-- View months in which payments occurred (using DISTINCT)
SELECT DISTINCT(TO_CHAR(payment_date, 'MONTH')) FROM payment;
-- View months in which payments occurred (using GROUP BY)
SELECT (TO_CHAR(payment_date, 'MONTH'))
  FROM payment GROUP BY TO_CHAR(payment_date, 'MONTH');

-- How many payments occurred on each particular day?
-- TO_CHAR(payment_date,'Day') returns the Day capitalised (
-- Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday). 
SELECT COUNT(TO_CHAR(payment_date,'Day')), TO_CHAR(payment_date,'Day')
FROM payment GROUP BY TO_CHAR(payment_date,'Day');

-- How many payments occurred on Monday? (my answer using TO_CHAR)
-- Note: TO_CHAR blank pads certaing codes to 9 characters,
-- hence use ILIKE in the HAVING filtering clause
SELECT 
COUNT(TO_CHAR(payment_date,'Day')) AS "number of transactions", 
TO_CHAR(payment_date,'Day') AS "day"
FROM payment GROUP BY TO_CHAR(payment_date,'Day') 
HAVING TO_CHAR(payment_date,'Day') ILIKE 'mon%'

-- How many payments occurred on Monday? 
-- Jose's answer (using EXTRACT and DOW (Day Of Week). In PostgreSQL,
-- DOW starts on Sunday and is 0 indexed for day numbering
SELECT COUNT(*)
FROM payment
WHERE EXTRACT(dow FROM payment_date) = 1

-- ----- Math functions
-- https://www.postgresql.org/docs/current/functions-math.html
SELECT ROUND(rental_rate/replacement_cost,2)*100 AS "percent cost" FROM film;

-- ----- String functions
-- https://www.postgresql.org/docs/current/functions-string.html

-- View customers who have first names of less than 5 letters
SELECT * FROM customer
WHERE CHAR_LENGTH(customer.first_name) < 5;

-- String concatenation operator ||
SELECT customer.first_name || ' ' || customer.last_name AS "full name"
FROM customer

-- Create an email address string for the customers
SELECT
LOWER(SUBSTRING(customer.first_name,1,1)) || 
'.' ||
LOWER(customer.last_name)  ||
'@company.com' AS "new email"
FROM customer


-- ----- Sub-query
-- Essentially perform a query on the results of another query

-- View movies that have a rental rate higher than the average rental rate
SELECT title, rental_rate 
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film);

-- View titles that have been returned between two specific dates
-- Using two inner joins, no sub-query
SELECT film.title, film.rental_rate, rental.return_date
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE rental.return_date BETWEEN '2005-05-29' AND '2005-05-30'
ORDER BY film.title;

-- Using one inner join as a sub-query to a query using IN as the sub-query
-- returns multiple results
SELECT film.title, film.film_id
FROM film
WHERE film.film_id IN
(
  -- sub-query view of film_ids between two dates
  SELECT inventory.film_id
  FROM rental
  INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
  WHERE rental.return_date BETWEEN '2005-05-29' AND '2005-05-30'
)
ORDER BY film.title;

-- Find customers who have at least one payment > $11
SELECT first_name, last_name
FROM customer 
WHERE EXISTS
(
  SELECT * FROM payment
  WHERE payment.customer_id = customer.customer_id AND payment.amount > 11
)

-- Find customers who have at least one payment > $11 (with AS variables for tables)
SELECT first_name, last_name
FROM customer AS c
WHERE EXISTS -- checks to see if rows exist in returned sub-query
(
  SELECT * FROM payment AS p
  WHERE p.customer_id = c.customer_id AND p.amount > 11
)
-- ----- Self-join
-- Query in which table is joined to itself
-- Useful for comparing values in a column within the same table
-- Not as common as other joins and highly depends on table structure
-- Can be thought of as a join of two copies of the same table
-- Just uses the JOIN keyword and joins same table
-- MUST use an alias for "each" table or it would be ambiguous (two
-- aliases to the same table)

-- Self join to match each employee with who they report to
DROP TABLE IF EXISTS employees;
CREATE TABLE employees(employee_id INT,
                       name VARCHAR(20),
                       reports_to INT);
INSERT INTO employees VALUES(1, 'Andrew', 3);
INSERT INTO employees VALUES(2, 'Bob', 3);
INSERT INTO employees VALUES(3, 'Charlie', 4);
INSERT INTO employees VALUES(4, 'David', 1);

SELECT emp.employee_id, emp.name, emp.reports_to,
rep.employee_id, rep.name
FROM employees AS emp
JOIN employees AS rep
ON emp.reports_to = rep.employee_id;

-- ----- Assessment Test 2 with new exercises.tar DB -----
SELECT * FROM cd.facilities;

SELECT name, membercost FROM cd.facilities;

SELECT name, membercost FROM cd.facilities WHERE membercost > 0;

SELECT facid, name, membercost, monthlymaintenance 
FROM cd.facilities
WHERE membercost > 0 AND membercost < (monthlymaintenance/50.0);

SELECT * FROM cd.facilities WHERE facid=1 OR facid=5; -- using OR
SELECT * FROM cd.facilities WHERE facid IN (1, 5); -- not using OR

SELECT * FROM cd.members WHERE joindate > '2012-09-01';

SELECT DISTINCT(surname) FROM cd.members ORDER BY surname LIMIT 10;

-- Show the most recent date of member joining
SELECT members.joindate FROM cd.members       -- (1) 
ORDER BY joindate DESC LIMIT 1;
-- or...
SELECT MAX(members.joindate) FROM cd.members; -- (2)

SELECT * FROM cd.facilities WHERE guestcost >= 10;

-- Number of slots booked by facility in Sept 2012, using time in
-- hours, mins, secs and milli-seconds to grab all of September
SELECT facid, SUM(slots)
FROM cd.bookings
WHERE starttime
BETWEEN '2012-09-01 00:00:00.000' AND '2012-09-30 23:59:59.999'
GROUP BY (facid);

-- Filter with HAVING for aggregate function 
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY (facid)
HAVING SUM(slots) > 1000
ORDER BY facid;

-- YY-MM-DD HH:MM:SS.mmm
SELECT bookings.facid, bookings.starttime, facilities.name
FROM cd.bookings
INNER JOIN cd.facilities
ON facilities.facid = bookings.facid
WHERE
  facilities.name LIKE 'Tennis Court _' 
  AND bookings.starttime BETWEEN
    '2012-09-21 00:00:00.000' AND '2012-09-21 23:59:59.999' 
ORDER BY bookings.starttime;

-- During a particular day, another way (just date, not time)
SELECT bookings.facid, bookings.starttime, facilities.name
FROM cd.bookings
INNER JOIN cd.facilities
ON facilities.facid = bookings.facid
WHERE
  facilities.name LIKE 'Tennis Court _' 
  AND bookings.starttime >= '2012-09-21'
  AND bookings.starttime <  '2012-09-22' 
ORDER BY bookings.starttime;

-- David Farrell
SELECT bookings.facid, bookings.starttime,
CONCAT(members.firstname,' ',members.surname) AS "member name"
FROM cd.bookings
INNER JOIN cd.members
ON members.memid = bookings.memid
WHERE members.firstname='David' AND members.surname='Farrell';

-- ----- Creating Databases and Tables -----
-- SERIAL - generate a sequence of integers, useful for PKs, will NOT adjust
--          if a row is removed (historical record that a row was removed)

DROP TABLE IF EXISTS account;
CREATE TABLE account(
  user_id SERIAL PRIMARY KEY,
  user_name VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(50) NOT NULL,
  email VARCHAR(250) UNIQUE NOT NULL,
  created_on TIMESTAMP NOT NULL,
  last_login TIMESTAMP
);

DROP TABLE IF EXISTS job;
CREATE TABLE job (
  job_id SERIAL PRIMARY KEY,
  job_name VARCHAR(200) UNIQUE NOT NULL
);

-- intermediary table to connect someone's job to their account
-- shows us how to reference a FOREIGN KEY
DROP TABLE IF EXISTS account_job;
CREATE TABLE account_job(
  user_id INTEGER REFERENCES account(user_id),  -- FK
  job_id INTEGER REFERENCES job(job_id),        -- FK
  hire_date TIMESTAMP
);
-- When inputting data to a FK column, the PK it refers to
-- must already exist or we get an error

INSERT INTO account(user_name, password, email, created_on)
VALUES('Jose', 'password', 'jose@mail.com', CURRENT_TIMESTAMP);

ALTER TABLE account RENAME COLUMN user_name TO username;

INSERT INTO job(job_name) VALUES ('Astronaut');
INSERT INTO job(job_name) VALUES ('President');

INSERT INTO account_job(user_id, job_id,hire_date) 
VALUES(1,1,CURRENT_TIMESTAMP);
INSERT INTO account_job(user_id, job_id,hire_date) 
VALUES(101,2,CURRENT_TIMESTAMP);

-- Update particular cells in the tables
UPDATE account SET last_login = CURRENT_TIMESTAMP;
UPDATE account SET last_login = created_on;
-- Update particular cells in the table from another table informally
-- known as an "UPDATE JOIN" (update join trick)
UPDATE account_job SET hire_date = account.created_on
FROM account WHERE account_job.user_id = account.user_id;
-- Update a cell an simultaneously return a view of some table columns
UPDATE account SET last_login = CURRENT_TIMESTAMP
RETURNING email,created_on, last_login;

-- delete a particular row from a table
DELETE FROM account_job WHERE user_id = 101 -- delete a row
-- delete all the rows from a table
DELETE FROM account_job

-- delete a particular row (after creating it) and return/view columns
INSERT INTO job(job_name) VALUES('Cowboy');
DELETE FROM job WHERE job_name='Cowboy' RETURNING job_id,job_name;

-- alter command
CREATE TABLE information(
  info_id SERIAL PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  person VARCHAR(50) NOT NULL UNIQUE
);

-- rename the table
ALTER TABLE information RENAME TO new_info;
-- rename a column
ALTER TABLE new_info RENAME COLUMN person TO people;

-- alter constraints that already exist on certain columns
ALTER TABLE new_info ALTER COLUMN people DROP NOT NULL;
-- can now add data with the people column being null
INSERT INTO new_info(title) VALUES ('some new title')

-- drop a column
ALTER TABLE new_info DROP COLUMN people;
ALTER TABLE new_info DROP COLUMN IF EXISTS people;

-- test if values inserted into the table meets a check constraint  
CREATE TABLE employees(
  emp_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  birth_date DATE CHECK (birth_date > '1900-01-01'),
  hire_date DATE CHECK (hire_date > birth_date),
  salary INTEGER CHECK (salary > 0)
);

-- fails check constraint
INSERT INTO 
employees(first_name,last_name,birth_date,hire_date,salary)
VALUES('Jose', 'Smith', '1899-11-03', '2020-01-01', 100);
-- passes check constraints now
INSERT INTO 
employees(first_name,last_name,birth_date,hire_date,salary)
VALUES('Jose', 'Smith', '1990-11-03', '2020-01-01', 100);
-- fails check constraint
INSERT INTO 
employees(first_name,last_name,birth_date,hire_date,salary)
VALUES('Alice', 'Cooper', '1990-11-03', '2020-01-01', -100);
-- passes check constraints now
INSERT INTO 
employees(first_name,last_name,birth_date,hire_date,salary)
VALUES('Alice', 'Cooper', '1990-11-03', '2020-01-01', 100);
-- N.B. the serial PK will still increment for the failed
-- attempts trying to add rows (letting us know rows were 
-- removed or insert commands failed)

-- ----- Assessment Test 3 -----
CREATE TABLE teachers (
  teacher_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  homeroom_number INT,
  department VARCHAR(50),
  email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%@%'),
  phone VARCHAR(50) UNIQUE
);
CREATE TABLE students (
  student_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  homeroom_number INT NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%@%'),
  phone VARCHAR(50) UNIQUE,
  graduation_year DATE
);

INSERT INTO
students(   first_name,last_name,homeroom_number,email,
            phone,graduation_year)
VALUES(     'Mark','Watney',5,'tent@mars.com',
            '777-555-1234','2035');
INSERT INTO
teachers(   first_name,last_name,homeroom_number,
            department,email,phone)
VALUES(     'John','Salk',5,
            'Biology','jsalk@school.org','777-555-4321');

-- ----- Conditional Expressions and Procedures -----
-- ----- CASE
-- case general statement or expression
-- case general statement CASE WHEN x > 1 THEN ...
-- case expression CASE x WHEN 1 THEN ...
-- "think of case like another column view in SELECT statement" 
-- "case is in lieu of a column selected by SELECT"
-- "write SELECT & FROM, put CASE WHEN THEN END between SELECT &..
-- FROM, just like any other column getting selected / viewed"
-- the general case statement is the most flexible as we can.. 
-- ..check all kinds of conditions
-- case expression is more simplistic, just checking for equality
-- case general statement assign membership levels based on id:
SELECT 
customer_id AS "customer id",                       -- col selected
CASE                                                -- col selected
  WHEN customer_id BETWEEN 1 AND 5 THEN 'platinum'
  WHEN customer_id BETWEEN 6 AND 15 THEN 'gold'
  WHEN customer_id BETWEEN 16 AND 30 THEN 'silver'
  ELSE 'bronze'
END AS "membership level",
CONCAT(first_name,' ',last_name) AS "customer name" -- col selected
FROM customer;

-- find how many films have a rental rate of 0.99
SELECT
SUM(
  CASE 
    WHEN rental_rate = 0.99 THEN 1
    ELSE 0
  END 
) AS "sum 99 cent"
FROM film;
-- could have done this using group by, count, where and having
-- but using case allows better formatting, allows it all on the..
-- ..same row using a few copy and pastes. case count trick
SELECT
SUM(
  CASE 
    WHEN rental_rate = 0.99 THEN 1
    ELSE 0
  END 
) AS "sum 99 cent",
SUM(
  CASE 
    WHEN rental_rate = 2.99 THEN 1
    ELSE 0
  END 
) AS "sum 2.99 cent",
SUM(
  CASE 
    WHEN rental_rate = 4.99 THEN 1
    ELSE 0
  END 
) AS "sum 4.99 cent"
FROM film;
-- N.B. "case count" trick
-- "super common to count things using CASE/WHEN with 1 & 0 like this"

/*
"case count" trick (nicely formatted results)
count how many films are in each rating category
*/
-- first, view a list of all the different ratings
SELECT COUNT(*), rating FROM film GROUP BY rating;
-- count via general case statment
SELECT
SUM(
  CASE 
    WHEN rating = 'NC-17' THEN 1
    ELSE 0
  END
) AS "NC-17",
SUM(
  CASE 
    WHEN rating = 'PG' THEN 1
    ELSE 0
  END
) AS "PG",
SUM(
  CASE 
    WHEN rating = 'PG-13' THEN 1
    ELSE 0
  END
) AS "PG-13",
SUM(
  CASE 
    WHEN rating = 'G' THEN 1
    ELSE 0
  END
) AS "G",
SUM(
  CASE 
    WHEN rating = 'R' THEN 1
    ELSE 0
  END
) AS "R"
FROM film;

-- since the above is just check for simple equality, could
-- have used the more simplistic case expression instead for
-- doing the "case count" trick again
SELECT
SUM(
  CASE rating
    WHEN 'NC-17' THEN 1
    ELSE 0
  END
) AS "NC-17",
SUM(
  CASE rating
    WHEN 'PG' THEN 1
    ELSE 0
  END
) AS "PG",
SUM(
  CASE rating
    WHEN 'PG-13' THEN 1
    ELSE 0
  END
) AS "PG-13",
SUM(
  CASE rating
    WHEN 'G' THEN 1
    ELSE 0
  END
) AS "G",
SUM(
  CASE rating
    WHEN 'R' THEN 1
    ELSE 0
  END
) AS "R"
FROM film;

-- COALESCE (returns the first non-null value)
-- commonly used when doing calcs & want to replace null with 0 
-- 0 to null trick
SELECT item, (price - COALESCE(discount,0)) FROM table

-- CAST (convert from one datatype into another)
SELECT CAST('5' AS INTEGER); -- CAST function
SELECT '5'::INTEGER;         -- shorthand CAST/AS (postgreSQL only)

-- NULLIF
-- takes 2 inputs, return null if both equal, otherwise return..
-- the first input.
-- very useful in cases where a zero value would cause an error
-- or give an unwanted result (null preferable, it's not an error)
-- Common use case for nullif in DBs is we want to return null
-- rather than 0 

-- bit of a contrieved example dividing one "case count" by another
-- "case count" to get the ratio between departments 
CREATE TABLE depts(
  first_name VARCHAR(50),
  department VARCHAR(50)
);

INSERT INTO depts(first_name,department)
VALUES ('Vinton', 'A'), ('Lauren','A'), ('Claire','B');

SELECT
SUM(CASE department WHEN 'A' THEN 1 ELSE 0 END) / 
-- dividing top "case count" by bottom "case count"
SUM(CASE department WHEN 'B' THEN 1 ELSE 0 END) 
AS "department ratio"
FROM depts;

-- remove 'B' rows so we get a contrieved divide by 0 
DELETE FROM depts WHERE department='B';

-- change "case count" ratio calculation to return a null rather
-- than a 0
SELECT
SUM(CASE department WHEN 'A' THEN 1 ELSE 0 END) / 
-- dividing top "case count" by bottom "case count"
NULLIF(SUM(CASE department WHEN 'B' THEN 1 ELSE 0 END), 0) 
AS "department ratio"
FROM depts;

-- VIEWS
-- a DB object that is essentially just a stored query
-- very simple to create view: CREATE VIEW name_of_view AS...
-- There is a views folder in the Object Explorer Tree

-- in PostgreSQL, can also execute command to see all saved views
 select table_name from INFORMATION_SCHEMA.views WHERE table_schema = ANY (current_schemas(false))

CREATE VIEW customer_info_view AS
SELECT first_name, last_name
FROM customer
INNER JOIN address
ON address.address_id = customer.address_id;

-- Execute the saved view
SELECT * FROM customer_info_view;  

-- Update (replace) the saved view (add district column to output)
CREATE OR REPLACE VIEW customer_info_view AS
SELECT first_name, last_name, district
FROM customer
INNER JOIN address
ON address.address_id = customer.address_id;

-- Execute the saved view
SELECT * FROM customer_info_view;

-- Change the name of a view
ALTER VIEW customer_info_view RENAME TO c_info;
SELECT * FROM c_info;

-- Delete (drop) the saved view
DROP VIEW IF EXISTS c_info;