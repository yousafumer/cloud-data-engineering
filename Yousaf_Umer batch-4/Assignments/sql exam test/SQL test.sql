--Q1. List top 5 customers by total order amount.
--Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.


select Top 5 o.customerid, c.name , sum(o.totalAmount) as total_spent 
from salesorder o
left join customer c
on o.customerid = c.CustomerID
group by o.CustomerID , c.name
Order by total_spent desc



--Q2. Find the number of products supplied by each supplier.
--Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.


select s.SupplierID,  s.name, Count(Quantity) as ProductCount
From Supplier s
left join purchaseorder po
on s.SupplierID = po.SupplierID
left join PurchaseOrderDetail pod
on po.OrderID = pod.OrderID
group by s.SupplierID , s.name
having count(quantity) >=10




--Q3. Identify products that have been ordered but never returned.
--Show ProductID, ProductName, and total order quantity.


select p.ProductID , p.Name , count(sod.quantity)
From  SalesOrderDetail sod
left join product  p
on sod.productid = p.ProductID
where sod.productid  not in ( select productid from returndetail)
Group by p.productid, p.name





--Q4. For each category, find the most expensive product.
--Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.


select c.categoryid, c.name as categoryname, p.name productname, p.price 
from product p
inner join category c
on p.CategoryID = c.CategoryID
where p.price = (select max(p2.price) from Product p2
					where p2.CategoryID = p.CategoryID)



--Q5. List all sales orders with customer name, product name, category, and supplier.
--For each sales order, display:
--OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.


SELECT 
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    sp.Name AS SupplierName,
    sod.Quantity
FROM salesorder so
left join customer c
on so.CustomerID = so.CustomerID
inner join SalesOrderDetail sod 
on so.OrderID= sod.OrderID
inner join Product p
on sod.ProductID = p.ProductID
inner join Category cat
on p.CategoryID = cat.CategoryID
inner join PurchaseOrderDetail pod
on pod.ProductID = p.ProductID
inner join PurchaseOrder po
on pod.OrderID = po.OrderID
inner join supplier sp
on sp.supplierid = po.supplierid



--Q6. Find all shipments with details of warehouse, manager, and products shipped.
--Display:
--ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.


Select s.shipmentid, l.name as WarehouseName, e.name as ManagerName, 
p.name as ProductName, sd.quantity as QuantityShipped, s.trackingnumber
from shipment s
inner join warehouse w
on s.WarehouseID = w.WarehouseID
inner join location l
on w.LocationID = l.LocationID
left join employee e
on w.ManagerID = e.EmployeeID
inner join shipmentdetail sd
on s.ShipmentID = sd.ShipmentID
inner join product p
on sd.ProductID = p.ProductID



-- Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.

select CustomerID, CustomerName, OrderID, TotalAmount
from (
    select c.customerid, c.name as CustomerName, 
    so.orderid, so.totalamount,
    rank() over(partition by c.customerid order by so.totalamount desc) as rnk
    from salesorder so
    inner join customer c
    on so.customerid = c.customerid
) as rnk_tbl
where rnk <= 3



-- Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.


select ProductID, ProductName, OrderID, OrderDate, Quantity,
lag(Quantity) over(partition by ProductID order by OrderDate) as PrevQuantity,
lead(Quantity) over(partition by ProductID order by OrderDate) as NextQuantity
from (
    select p.productid, p.name as ProductName,
    so.orderid, so.orderdate, sod.quantity
    from salesorderdetail sod
    inner join product p
    on sod.productid = p.productid
    inner join salesorder so
    on sod.orderid = so.orderid
) as sales_hist


--Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
--CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.


create view vw_CustomerOrderSummary as
select c.customerid, c.name as CustomerName,
count(so.orderid) as TotalOrders,
sum(so.totalamount) as TotalAmountSpent,
max(so.orderdate) as LastOrderDate
from customer c
left join salesorder so
on c.customerid = so.customerid
group by c.customerid, c.name