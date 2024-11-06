USE `modelcarsdb`;

-- -------------------------------------------------------------------------------------------------------------------
-- Task1 top  10 customers by credit limit

select  customerName,creditLimit from customers  order by creditLimit desc limit 10;
############################################################################################################################################
-- TASK2 FIND AVERAGE  CREDITLIMIT OF CUSTOMERS FOR EACH COUNTRY


select  customerName ,country,avg(creditLimit) as avg_creditlimit from customers 
group by country,customerName order by avg_creditlimit desc;

#######################################################################################################################################
-- task3 Find the no.of customers of each  state

select  state, count(customerNumber) as No_of_customers from customers group by state order by No_of_customers desc;

#################################################################################################################################
-- Task4 find the who are not placed the customers

select  customers.customerNumber,customers.customerName  as  "names_of_orders_ haven't_placed"from customers 
left join orders on customers.customerNumber= orders.customerNumber where orderNumber IS NULL;

####################################################################################################################################
-- Task5  calculate the Total sales of each customer


SELECT customers.customerName, SUM(orderdetails.quantityOrdered * orderdetails.priceEach) AS totalSales
FROM customers 
JOIN orders  ON customers.customerNumber = orders.customerNumber
JOIN orderdetails  ON orders.orderNumber = orderdetails.orderNumber
GROUP BY customers.customerName;



##########################################################################################################################################
-- Task6 List out customers with their  assigned sales representatives

 select customerName,employees.firstName,employees.lastName from employees 
 join  customers on  customers.salesRepEmployeeNumber=employees.employeeNumber where jobTitle ='Sales Rep';

###########################################################################################################################################
-- Task7 reterive the customer  their most recent payment detailes


select customers.customerNumber, customers.customerName,payments.paymentDate from customers 
join payments on payments.customerNumber=customers.customerNumber  order by paymentDate desc limit 1;

#########################################################################################################################################
-- Task8  

-- identify the customers who have exceeded the their credit limit

SELECT customers.customerName,
       SUM(orderdetails.quantityOrdered * orderdetails.priceEach) AS total_sales,
       customers.creditLimit
FROM customers
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
GROUP BY customers.customerNumber
HAVING total_sales > customers.creditLimit;

#################################################################################################################################

-- TASK9

-- find the  names all customers  who  have a placed  an order  for product from  specific production line


SELECT DISTINCT customers.customerName
FROM customers 
JOIN orders 
JOIN orderdetails
JOIN products
ON (customers .customerNumber = orders.customerNumber) and(orders.orderNumber =orderdetails.orderNumber) and( orderdetails.productCode = products.productCode)
WHERE products.productLine = 'planes';


###############################################################################################################################################
-- TASK10

-- Find the  names all customers  who  have a placed  an order  for product from   MOST EXPENCIVE PRODUCT

SELECT DISTINCT Customers.CustomerName
FROM Customers
JOIN Orders ON Customers.CustomerNumber = Orders.CustomerNumber
JOIN OrderDetails ON Orders.OrderNumber = OrderDetails.OrderNumber
JOIN Products ON OrderDetails.ProductCode = Products.ProductCode
WHERE Products.buyPrice = (
    SELECT MAX(buyPrice) FROM Products limit 1
);

#################################################################################################################################################
-- TASK2(1) 
-- count the  number of employees working with each office

select employees.officeCode,count(employeeNumber) as no_of_employees from employees
join offices on employees.officeCode=offices.officeCode group by officeCode order by no_of_employees  desc;

############################################################################################################################################s

-- TASK2(2)

-- identify the office with less than certain number of employees.

select employees.officeCode,count(employeeNumber) as no_of_employees from employees
 join offices on employees.officeCode=offices.officeCode where offices.officeCode<6 group by officeCode order by no_of_employees  desc;
 
#######################################################################################################################################
-- Task2(3)
-- List the offices assigned territory

select officeCode,territory from offices;
##################################################################################################################################
-- Task2(4)

-- find the offices that have no employees assigned to them

-- every office have the employees.

SELECT o.officeCode,o.city
FROM offices o
LEFT JOIN employees e ON o.officeCode = e.officeCode
WHERE e.officeCode IS NULL;


########################################################################################################################################
-- Task2(5) 

-- Profit =  Total Sales−Total Expenses  

-- profit column is not given by using sales

SELECT customers.customerNumber, SUM(orderdetails.quantityOrdered * orderdetails.priceEach) AS mostprofitlSales
FROM customers
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
GROUP BY customers.customerNumber
ORDER BY mostprofitlSales DESC
LIMIT 1;

 
######################################################################################################################

-- Task2(6)

SELECT officeCode, city, employee_count
FROM (
    SELECT o.officeCode, o.city, COUNT(e.employeeNumber) AS employee_count
    FROM offices o
    JOIN employees e ON o.officeCode = e.officeCode
    GROUP BY o.officeCode, o.city
) AS office_employee_count
ORDER BY employee_count DESC
LIMIT 1;


#########################################################################################################################
-- Task(2)7-- find the  avg credit limit of customers for each offices

SELECT  customers.customerName, AVG(creditLimit) AS avg_limit 
FROM customers 
JOIN offices ON customers.country = offices.country 
GROUP BY  customers.customerName order by avg_limit ;

################################################################################################################################
-- Task(2)8  

 -- find the number of offices from each country

select count(officeCode) as office_name_number,offices.country from offices
join customers on offices.city=customers.city group by  country order by office_name_number;

################################################################################################################################################
-- task3(1)

-- find the number of products of each productline

SELECT ProductLine, COUNT(*) AS NumberOfProducts
FROM Products
GROUP BY ProductLine;

 ###########################################################################################################################
 
 -- TASK3)2)
 
  select productLine,avg(MSRP)  as max_price  from products  group by productLine limit 1;
  
  ######################################################################################################################################
  
  -- TASK3(3)  find the products with above or below 50  between 100
  
   select productName, MSRP from products where MSRP between 50 and 100;
   
   ##############################################################################################################################
   -- Task3(4)
   
 select  productLine,SUM(orderdetails.quantityOrdered * orderdetails.priceEach) AS totalSales  from products 
 join orderdetails on products.productCode=orderdetails.productCode
 group by productLine;
 #############################################################################################################################
 -- TASK3(5) identify the  products with low inventry levels (less than a specific thersold value of 10  for quantityinstock)
 
SELECT ProductName, QuantityInStock
FROM Products
WHERE QuantityInStock > 10;


########################################################################################################33
-- task3(6)  most expencive product based on msrp

select productName AS Most_Expencive_Product, (MSRP)  from products LIMIT 1;

#########################################################################################################################################
-- TASK3(7)

select productCode as products, SUM(orderdetails.quantityOrdered * orderdetails.priceEach) AS total_sales
from orderdetails
group by productCode;
##########################################################################################################################################
-- Task3(8)

DELIMITER //
create procedure sp_top_orders(IN in_total_quantity int )
begin
 select
    p.productCode, p.productName,
    SUM(od.quantityOrdered) AS total_quantity
from Products p
inner join Orderdetails od ON p.productCode = od.productCode
group by  p.productCode order by total_quantity desc limit in_total_quantity;
end //
DELIMITER ;

CALL sp_top_orders(5); 

###############################################################################################################################
-- TASK3(9)  identify the  products with low inventry levels (less than a specific thersold value of 10  for quantityinstock) and specific productLines
 

select productName as products, quantityInStock, productLine
from Products
where quantityInStock < 10 and productLine in ('Motorcycles','Classic Cars');

#################################################################################################################################
-- TASK3(10)   find the names of all products that have been orderd by more than 10 customers

select p.productName
from products p
join orderdetails od ON p.productCode = od.productCode
join orders o ON od.orderNumber = o.orderNumber
group by p.productName
having COUNT(DISTINCT o.customerNumber) > 10;


##########################################################################################################################################
-- task3(11)

SELECT productName
FROM products AS p
JOIN orderdetails AS od ON p.productCode = od.productCode 
WHERE od.quantityOrdered > (
    SELECT AVG(quantityOrdered) AS avg_quantity
    FROM orderdetails
    GROUP BY productLine
);


######################################################################################################################################










