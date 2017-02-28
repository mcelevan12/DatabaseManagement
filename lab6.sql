/* 1. Display the name and city of customers who live in any city that makes the most different kinds of products. 
 *   (There are two cities that make the most different products. 
 *   Return the name and city of customers from either one of those.) */
SELECT C.name, C.city
FROM (
      SELECT city, count(city) AS city_count, rank() OVER (ORDER BY count(city) DESC) AS rank
      FROM Products
      GROUP BY city
     ) R INNER JOIN Customers C ON R.city = C.city
WHERE R.rank = 1;


/* 2. Display the names of products whose priceUSD is strictly above the average priceUSD, in reverse-alphabetical order. */
SELECT P.name
FROM Products P 
WHERE P.priceUSD > ( 
                    SELECT avg(priceUSD)
                    FROM Products P
                   )
ORDER BY P.name DESC;


/* 3. Display the customer name, pid ordered, and the total for all orders, sorted by total from low to high. */ 
SELECT C.name, O.pid, O.totalUSD
FROM Customers C INNER JOIN Orders O ON C.cid = O.cid
ORDER BY O.totalUSD ASC


/* 4. Display all customer names (in alphabetical order) and their total ordered, and nothing more. 
 *   Use coalesce to avoid showing NULLs. */
SELECT C.name, COALESCE(sum(O.totalUSD), 0)
FROM Customers C LEFT OUTER JOIN Orders O ON C.cid = O.cid
GROUP BY C.name
ORDER BY C.name ASC;


/* 5. Display the names of all customers who bought products from agents based in Newark along with the names of the products they ordered, and the names of the agents who sold it to them. */
SELECT C.name, P.name, A.name
FROM Orders O INNER JOIN Customers C ON C.cid = O.cid
              INNER JOIN Products P  ON P.pid = O.pid
              INNER JOIN Agents A    ON A.aid = O.aid
WHERE A.city = 'Newark';


/* 6. Write a query to check the accuracy of the totalUSD column in the Orders table. 
 *  This means calculating Orders.totalUSD from data in other tables and comparing those values to the values in Orders.totalUSD. 
 *  Display all rows in Orders where Orders.totalUSD is incorrect, if any. */
SELECT O.*
FROM Orders O INNER JOIN Customers C ON C.cid = O.cid
              INNER JOIN Products P  ON P.pid = O.pid
              INNER JOIN Agents A    ON A.aid = O.aid
WHERE O.totalUSD != (O.qty * P.priceUSD * ((100 - C.discount) / 100))
ORDER BY O.TotalUSD - (O.qty * P.priceUSD * ((100 - C.discount) / 100)) DESC

 
/* 7. What’s the difference between a LEFT OUTER JOIN and a RIGHT OUTER JOIN? 
 *  Give example queries in SQL to demonstrate. 
 *  (Feel free to use the CAP database to make your points here.) 
 * 
 * A left outer join takes all of the data on the left table and tries to combine it with the right one.
 *   If it can't it will instead insert <null> for the values on the right table.
 *   A right outer join s the opposite.  */




 