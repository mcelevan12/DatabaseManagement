--1. Get the cities of agents booking an order for a customer whose cid is 'c006'. --
SELECT city
FROM agents
WHERE aid IN(
             SELECT aid
             FROM orders
             WHERE cid = 'c006'
            )
ORDER BY aid ASC;


/* 2. Get the distinct ids of products ordered through any agent who takes at least one order from a customer in Kyoto, sorted by pid from highest to lowest.
 * (This is not the same as asking for ids of products ordered by customers in Kyoto.)
 */
SELECT DISTINCT pid
FROM Orders
WHERE aid IN(
             SELECT aid
             FROM Orders
             WHERE cid IN (
                           SELECT cid
                           FROM Customers
                           WHERE city = 'Kyoto'
                          )
            )
ORDER BY pid DESC;


--3. Get the ids and names of customers who did not place an order through agent a01. --
SELECT cid, name
FROM Customers
WHERE cid NOT IN(
                 SELECT cid
                 FROM Orders
                 WHERE aid = 'a01'
                )
ORDER BY cid ASC;


--4. Get the ids of customers who ordered both product p01 and p07. --
SELECT cid 
FROM Orders
WHERE pid = 'p01'
       INTERSECT
SELECT cid 
FROM Orders
WHERE pid = 'p07'


--5. Get the ids of products not ordered by any customers who placed any order through agent a08 in pid order from highest to lowest. --
SELECT /*DISTINCT*/ pid 
FROM Orders
WHERE cid NOT IN(
                 SELECT cid
                 FROM Orders
                 WHERE aid = 'a08'
                )
ORDER BY pid DESC;


--6. Get the name, discount, and city for all customers who place orders through agents in Tokyo or New York. --
SELECT name, discount, city
FROM Customers
WHERE cid IN (
              SELECT cid
              FROM Orders
              WHERE aid IN (
                            SELECT aid
                            FROM Agents
                            WHERE city = 'Tokyo' 
                               OR city = 'New York'
                           )
             )
ORDER BY name ASC;


--7. Get all customers who have the same discount as that of any customers in Duluth or London--
SELECT *
FROM Customers
WHERE discount IN (
                   SELECT discount
                   FROM Customers
                   WHERE city = 'Duluth' OR city = 'London'
                  )
ORDER BY cid ASC;


/* 8. Tell me about check constraints: What are they? What are they good for? What’s the advantage of putting that sort of thing inside the database? Make up some examples 
 * of good uses of check constraints and some examples of bad uses of check constraints. Explain the differences in your examples and argue your case.
 * 
 *   Check consraints are used to ensure that data stays acording to some standard.  They help force consistancy in data.  The advantage of putting theminside the database is it ensures
 * that they will always be ture no matter what system is being used.  Some good check constraints are for things that follow rules now and forever.  For example making sure that a price
 * is nonegative. On the otherhand bad check constraints are things that can change,  like having an employee store id being either Seattle or Pheonix.  This is bad
 * becasue there can be a new store that opens up in Quebec and now the check constraint is no longer valid.  
 * / 
 



