--==1 Retrieve all columns from the table for the first 10 rows
select top 10 * from Alibaba

--==2 Display the products where the shipping city is 'Bangalore'
select DISTINCT(item_NM), Shipping_city from Alibaba
where Shipping_city = 'Bangalore'

--==3 Retrieve the top 5 products with the highest item price.
SELECT TOP 5 WITH TIES item_NM , Item_Price  from
(
    SELECT distinct(item_NM),Item_Price FROM Alibaba
	)  AS UNIQUEPRODUCT
order by Item_Price desc

--==4 Calculate the average quantity sold.
select AVG(quantity) as avgQuantitySold from Alibaba

--==5 Group the data by category and display the total quantity sold for each category
select Category ,SUM(quantity) as total_quantity  from Alibaba
group by Category 
order by total_quantity desc

--==6 Create a new table for payment methods and join it with the main table to 
--display product names and their payment methods
create table payment_methods (
   payment_method_id int primary key ,
   payment_method varchar(50) not null
   );

insert into payment_methods(payment_method_id,payment_method)
values (1,'prepaid'),
	  (2,'COD');

select Alibaba.Item_NM,payment_methods.payment_method
from Alibaba
join payment_methods on Alibaba.Payment_Method = payment_methods.payment_method;

--==7 Find products where the cost price is greater than the average cost price.
select distinct(Item_NM),Cost_Price from Alibaba
where Cost_Price > (select avg(Cost_Price) from Alibaba)
order by Cost_Price desc

--==8 Calculate the total special price for products in the 'WATCHES' category
select sum(Special_Price_effective) as TotalSpecial_price ,Category  from Alibaba
where Category = 'WATCHES'
group by Category

--==9  Increase the cost price by 10% for products in the Women Clothing category.
select  item_NM ,sum(Cost_Price+Cost_Price*10/100) as cost_price from Alibaba
where Category = 'Women Apparel'
group by item_NM

--==10  Remove all products where the sale flag is Not on Sale.
delete from Alibaba
where Sale_Flag = 'not on sale'

--==11  Create a new column 'Discount_Type' that categorizes products based on their
-- item price: 'High' if above $8000, 'Medium' if between $8000 and $5000, 'Low' if below $5000..
alter table Alibaba add Discount_Type nvarchar(50)

update Alibaba set Discount_Type = 
  case
     when Item_Price > 8000 then 'High'
	 when Item_Price between 5000 and 7999 then 'Medium' 
	 else 'Low'
  end ;
  SELECT * FROM Alibaba
--==12 Rank the products based on their special prices within each category
select 
    DISTINCT(Item_NM) ,Category,special_price_effective,
	rank() over (partition by category order by special_price_effective desc) as price_rank 
from Alibaba
ORDER BY special_price_effective
--==13 Calculate the running total of the quantity sold for each product.
select 
   distinct( Item_NM),
	Quantity,
	sum(Quantity) over (partition by Item_NM order by Item_NM) as running_total_quantity
from Alibaba
order by Item_NM

--==Create a CTE that lists products in the 'Fashion' sub-category with their corresponding brand and color.
with FationProduct as(
    select 
	    item_NM, 
		brand,
		color
	from Alibaba
	where Sub_category= 'Fashion'
	)
select * from FationProduct

--== Pivot the data to show the total quantity sold for each category and sub-category.

--==Unpivot the table to transform the 'Value_CM1' and 'Value_CM2' columns into a single column named 'CM_Value'
--== Create a stored procedure that a category name as input and returns the total quantity sold for that category.
create procedure 
@GetTotalQuantitySoldByCategory 
   @categoryName nvarchar(100)
as begin 
set noncount on;
select sum(quantitySold) as TotalQuantitySold 
from Alibaba
where Category = @categoryName;
end

--==Find Top 3 Categories with the Highest Revenue, Including the Contribution of Each Subcategory
with Rev_by_subCat as (
  select
     Category,
	 Sub_category,
	 sum(item_price) as total_revenue
  from Alibaba
  group by Category, Sub_category
),
rankCat as (
  select 
     Category,
	 sum(total_revenue) as CatRev,
	 rank() over(order by sum(total_revenue) desc) as RevRank
 from Rev_by_subCat
 group by Category
	)
select 
   rc.Category, 
   rc.CatRev,
   rbs.total_revenue
from rankCat as rc
join Rev_by_subCat as rbs on 
   rc.RevRank <= 3
order by 
   rc.CatRev desc,
   rbs.total_revenue desc;

--== Identify Cities with Above-Average Special Price per Category
with AVG_special_price as (
   select 
      avg(Special_price) as avg_Special_price
   from Alibaba
)
select distinct(Shipping_city) from Alibaba,AVG_special_price
where Special_price >AVG_special_price 
order by Shipping_city;

--=======Data analytics=========
--== KPIS======
--=== Total sales
select sum(cost_price*Quantity) as total_sales 
from AliBaba

--=== Total Discount
select sum(coupon_money_effective) as  Total_Discount
from AliBaba

--=== Total Customers
select count(distinct s_no) as TotalCustomer
from AliBaba

--=== Avg order value
select cast(sum(cost_price*Quantity) as float)/ count(distinct s_no) as AVG_Order_value
from AliBaba

--=== Total Orders
select count(distinct s_no) as TotalCustomer
from AliBaba


--===total Quantityies beased on shipping city
select Shipping_city,sum(Quantity) as total_quantity from AliBaba
group by Shipping_city 
order by total_quantity desc

--===total Sales beased on category
select Category,sum(cost_price*Quantity) as total_sales from AliBaba
group by Category 
order by total_sales desc

--===total sales beased on payment methods 
select Payment_Method,sum(cost_price*Quantity) as total_sales from AliBaba
group by Payment_Method 
order by total_sales desc

--===Top sales products 
select Item_NM,sum(cost_price*Quantity) as total_Quantity from AliBaba
group by Item_NM 
order by total_Quantity desc

--===Total sale beased on color 
select color,sum(cost_price*Quantity) as total_sales from AliBaba
group by color 
order by total_sales desc

--=== effect coupon 
select Isnull (coupon_percentage,0) as discount_percentage ,
sum(cost_price*Quantity) as total_sales
from AliBaba 
group by Isnull (coupon_percentage,0)
order by discount_percentage desc


