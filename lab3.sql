/* Lab 3 
 * Evan McElheny 
 * 2/1/2017
 */

--1. List the order number and total dollars of all orders.--
SELECT ordNumber, totalUSD
FROM Orders
ORDER BY ordNumber ASC;

--2. List the name and city of agents named Smith.--
SELECT name, city
FROM Agents
WHERE name = 'Smith'
ORDER BY aid ASC;

--3. List the id, name, and price of products with quantity more than 200,100.--
SELECT pid, name, priceUSD
FROM Products
WHERE quantity >= '200100'
ORDER BY priceUSD DESC;

--4. List the names and cities of customers in Duluth.--
SELECT name, city
FROM Customers
WHERE city = 'Duluth'
ORDER BY name ASC;

--5. List the names of agents not in New York and not in Duluth.--
SELECT name
FROM Agents
WHERE city != 'New York'
         INTERSECT
SELECT name
FROM Agents
WHERE city != 'Duluth'
ORDER BY name ASC;

--6. List all data for products in neither Dallas nor Duluth that cost US$1 or more.--
SELECT DISTINCT *
FROM Products
WHERE pid IN(
             SELECT pid
             FROM Products
             WHERE city != 'Dallas'
                     INTERSECT
             SELECT pid
             FROM Products
             WHERE city != 'Duluth'
            )
AND priceUSD >= 1.0
ORDER BY pid ASC;


--7. List all data for orders in February or May. --
SELECT DISTINCT *
FROM Orders
WHERE month = 'Feb' OR month = 'May'
ORDER BY ordnumber;

--8. List all data for orders in February of US$600 or more. --
SELECT DISTINCT *
FROM Orders
WHERE month = 'Feb' AND totalusd >= 600 
ORDER BY ordnumber;

--9. List all orders from the customer whose cid is C005.--
SELECT DISTINCT *
FROM Orders
WHERE cid = 'c005'
ORDER BY ordnumber;






