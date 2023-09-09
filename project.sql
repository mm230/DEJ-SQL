/*Project: Customers and Products Analysis Using SQL

The scale model cars database contains eight tables:

Customers: customer data
Employees: all employee information
Offices: sales office information
Orders: customers' sales orders
OrderDetails: sales order line for each sales order
Payments: customers' payment records
Products: a list of scale model cars
ProductLines: a list of product line categories
*/

-- 1. Displaying the first five lines from the products table:
SELECT 'Customer' as table_name, 13 as number_of_attributes, count(*) as number_of_row FROM customers
UNION ALL
SELECT 'Products' as table_name, 9 as number_of_attributes, count(*) as number_of_row FROM products
UNION ALL
SELECT 'Productlines' as table_name, 13 as number_of_attributes, count(*) as number_of_row FROM productlines
UNION ALL
SELECT 'Orders' as table_name, 13 as number_of_attributes, count(*) as number_of_row FROM orders
UNION ALL
SELECT 'OrderDetails' as table_name, 13 as number_of_attributes, count(*) as number_of_row FROM orderdetails
UNION ALL
SELECT 'Payments' as table_name, 13 as number_of_attributes, count(*) as number_of_row FROM payments
UNION ALL
SELECT 'Employees'; as table_name, 13 as number_of_attributes, count(*) as number_of_row FROM employees
UNION ALL
SELECT 'Offices' as table_name, 13 as number_of_attributes, count(*) as number_of_row FROM offices;

-- 2. Write a query to compute the low stock for each product using a correlated subquery.
WITH low_stock_products  AS(
SELECT productCode, ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock 
																															  FROM products p
																														  WHERE p.productCode = od.productCode), 2) AS low_stock
  FROM orderdetails od
GROUP BY productCode
 ORDER BY low_Stock 
 LIMIT 10																														  
)
SELECT p.productName, od.productCode,  SUM(quantityOrdered * priceEach) AS product_performance
    FROM products p
	  JOIN orderdetails od
		  ON p.productCode = od.productCode
WHERE od.productCode IN (SELECT productCode 
															FROM low_stock_products)
  GROUP BY od.productCode
  ORDER BY product_performance DESC
  LIMIT 10;
  
--  3. Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place.
SELECT o.customerNumber,
				 SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS customer_profit
   FROM orders o
     JOIN orderdetails od
		  ON o.orderNumber = od.orderNumber
	 JOIN products p
		 ON od.productCode = p.productCode
 GROUP BY o.customerNumber;
 
-- 4. Write a query to find the top five VIP customers.
WITH profit_per_customer AS (
SELECT o.customerNumber,
				 SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS customer_profit
   FROM orders o
     JOIN orderdetails od
		  ON o.orderNumber = od.orderNumber
	 JOIN products p
		 ON od.productCode = p.productCode
 GROUP BY o.customerNumber
)
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, pc.customer_profit
    FROM customers c
	  JOIN profit_per_customer pc
		   ON c.customerNumber = pc.customerNumber
   GROUP BY c.customerNumber
   ORDER BY pc.customer_profit DESC
   LIMIT 5;
		
 -- 5. Similar to the previous query, write a query to find the top five least-engaged customers.
 WITH profit_per_customer AS (
SELECT o.customerNumber,
				 SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS customer_profit
   FROM orders o
     JOIN orderdetails od
		  ON o.orderNumber = od.orderNumber
	 JOIN products p
		 ON od.productCode = p.productCode
 GROUP BY o.customerNumber
)
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, pc.customer_profit
    FROM customers c
	  JOIN profit_per_customer pc
		   ON c.customerNumber = pc.customerNumber
   GROUP BY c.customerNumber
   ORDER BY pc.customer_profit 
   LIMIT 5;
   
-- 6. Write a query to compute the average of customer profits using the CTE on the previous screen.
WITH profit_per_customer AS (
SELECT o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS customer_profit
   FROM orders o
     JOIN orderdetails od
		  ON o.orderNumber = od.orderNumber
	 JOIN products p
		 ON od.productCode = p.productCode
 GROUP BY o.customerNumber
)
SELECT AVG(pc.customer_profit) AS LTV
   FROM profit_per_customer pc;
   
 /*
 Conclusion
 Question 1: Which products should we order more of or less of?

Answer 1: After analysing the results and comparing low stock with the highest performing products it seems like that the 
classic cars category should be the product line that should be restocked on a frequent basis. 
They appear 6 times in the top 10 highest performing products.

Question 2: How should we match marketing and communication strategies to customer behaviors?

Answer 2:  Analysing the results of the profit generated from both the top and lowest customer, it is advised to offer loyalty rewards
and service to the top perfomring customers in order to retain them.
For the bottom customers, it would be good to conduct surveys to better understand what they require of the company as well as 
what they expect to spend for the service. This will help in strategising the best approach to attract new customers.

Question 3: How Much Can We Spend on Acquiring New Customers?

Answer 3: The average lifetime value of a customer is £39,04. Therefore, we know that every new customer will generate a profit of 
£39,04. With this information we can plan how much funds the company would like to spend on new customer acquisition.
 
