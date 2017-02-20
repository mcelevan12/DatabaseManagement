--1. Show the cities of agents booking an order for a customer whose id is 'c006'. Use joins this time; no subqueries. 
SELECT Agents.city
FROM Orders INNER JOIN Agents ON Orders.aid = Agents.aid
            INNER JOIN Customers ON Orders.cid = Customers.cid
WHERE Orders.cid = 'c006';


--2. Show the ids of products ordered through any agent who makes at least one order for a customer in Kyoto, sorted by pid from highest to lowest. Use joins; no subqueries. 
SELECT DISTINCT X.pid
FROM Orders O INNER JOIN Orders X    ON O.aid = X.aid
              INNER JOIN Customers C ON O.cid = C.cid
              INNER JOIN Products P  ON O.pid = P.pid
WHERE C.city = 'Kyoto'
ORDER BY pid DESC; 


--3. Show the names of customers who have never placed an order. Use a subquery. 
SELECT name
FROM Customers
WHERE cid NOT IN( 
                 SELECT cid
                 FROM Orders
                )
ORDER BY name ASC;                


--4. Show the names of customers who have never placed an order. Use an outer join. 
SELECT C.name
FROM Customers C LEFT OUTER JOIN Orders O ON C.cid = O.cid
WHERE O.cid IS NULL
ORDER BY name ASC;


--5. Show the names of customers who placed at least one order through an agent in their own city, along with those agent(s') names. 
SELECT DISTINCT C.name, A.name
FROM Orders O INNER JOIN Customers C ON O.cid = C.cid
              INNER JOIN Agents A  ON O.aid = A.aid
WHERE A.city = C.city;


--6. Show the names of customers and agents living in the same city, along with the name of the shared city, regardless of whether or not the customer has ever placed an order 
--with that agent. 
SELECT C.name, A.name
FROM Customers C INNER JOIN Agents A ON C.city = A.city;


--7. Show the name and city of customers who live in the city that makes the fewest different kinds of products. (Hint: Use count and group by on the Products table.)
SELECT C.name, C.city
FROM (
      SELECT city, count(city) AS city_count, rank() OVER (ORDER BY count(city) ASC) AS rank
      FROM Products
      GROUP BY city
     ) R INNER JOIN Customers C ON R.city = C.city
WHERE R.rank = 1;
