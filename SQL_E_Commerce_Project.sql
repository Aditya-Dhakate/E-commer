create database E_Commerce_Project;
use E_Commerce_Project;
select * from olist_orders_dataset;
SET SQL_SAFE_UPDATES = 0;
UPDATE olist_orders_dataset SET order_purchase_timestamp = STR_TO_DATE(order_purchase_timestamp, '%m/%d/%Y %H:%i') WHERE order_purchase_timestamp IS NOT NULL;
ALTER TABLE olist_orders_dataset MODIFY COLUMN order_purchase_timestamp DATETIME;
UPDATE olist_orders_dataset SET order_approved_at = STR_TO_DATE(order_approved_at, '%m/%d/%Y %H:%i') WHERE order_approved_at is not null AND order_approved_at != '';
UPDATE olist_orders_dataset SET order_approved_at = NULL WHERE order_approved_at = '';
alter table olist_orders_dataset MODIFY COLUMN order_approved_at datetime;
update olist_orders_dataset set order_delivered_carrier_date = str_to_date(order_delivered_carrier_date, '%m/%d/%Y %H:%i') where order_delivered_carrier_date is not null and order_delivered_carrier_date != '';
update olist_orders_dataset set order_delivered_carrier_date = null where order_delivered_carrier_date = '';
alter table olist_orders_dataset modify order_delivered_carrier_date datetime; 
update olist_orders_dataset set order_delivered_customer_date = str_to_date(order_delivered_customer_date, '%m/%d/%Y %H:%i') where order_delivered_customer_date is not null and order_delivered_customer_date != '';
update olist_orders_dataset set order_delivered_customer_date = null where order_delivered_customer_date = '';
alter table olist_orders_dataset modify order_delivered_customer_date datetime;
update olist_orders_dataset set order_estimated_delivery_date = str_to_date(order_estimated_delivery_date, '%m/%d/%Y %H:%i') where order_estimated_delivery_date is not null;
alter table olist_orders_dataset modify order_estimated_delivery_date datetime;
select * from olist_order_payments_dataset;
commit;
alter table olist_orders_dataset add column Day_Type varchar(20) after order_purchase_timestamp;
select * from olist_orders_dataset;
update olist_orders_dataset set day_type = case when dayofweek(order_purchase_timestamp) in (1, 7) then 'WeekEnd'
else 'WeekDay'
end;
alter table olist_orders_dataset add primary key (order_id(50));
alter table olist_order_payments_dataset modify order_id varchar(50);
alter table olist_orders_dataset modify order_id varchar(50);
alter table olist_order_payments_dataset add constraint fk_foreign_key foreign key (order_id) references olist_orders_dataset (order_id) on delete cascade on update cascade;

-- Extracting weekday vs weekend payment statistics
-- Q1 --

SELECT p.payment_type AS Payment_Type,
      Day_type,
    COUNT(p.order_id) AS Total_Orders,
   round(SUM(p.payment_value),2) AS Total_Payment_Value,
   round(AVG(p.payment_value),2) AS Average_Payment_Value
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY Day_Type, Payment_Type
ORDER BY Day_Type ASC;

-- Q2 --
-- Number of Orders with review score 5 and payment type as credit card --
select * from olist_order_reviews_dataset;
select o2.review_score, o1.payment_type, count(o1.order_id) as Number_of_orders 
from olist_order_payments_dataset o1
inner join olist_order_reviews_dataset o2 on o1.order_id = o2.order_id
where o2.review_score = 5 and o1.payment_type = 'credit_card' ;

-- Average number of days taken for order_delivered_customer_date for pet_shop --
-- Q3 --
flush tables;
select * from olist_order_items_dataset;
select * from olist_products_dataset;
select * from olist_orders_dataset;

select o1.Product_category_name, avg(order_delivered_customer_date - order_purchase_timestamp) as Avg_no_of_days
from olist_products_dataset o1 inner join olist_order_items_dataset o2
on o1.product_id = o2.product_id inner join olist_orders_dataset o3 on o2.order_id = o3.order_id
where o1.product_category_name = 'pet_shop';

-- Average price and payment values from customers of sao paulo city --
-- Q4 --
select * from olist_order_payments_dataset;
select * from olist_order_items_dataset;
select * from olist_customers_dataset;
select * from olist_orders_dataset;

select o4.customer_city,round(avg(o2.price),0) as Avg_Price, round(avg(o1.payment_value),0) as Avg_Payment 
from olist_order_payments_dataset o1 left join olist_order_items_dataset o2 on o1.order_id = o2.order_id
left join olist_orders_dataset o3 on o3.order_id = o2.order_id left join olist_customers_dataset o4 
on o3.customer_id = o4.customer_id where o4.customer_city = 'sao paulo' ;

-- Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores --
-- Q5 --
select * from olist_orders_dataset;
select * from olist_order_reviews_dataset;

select timestampdiff(day, o1.order_purchase_timestamp, o1.order_delivered_customer_date) as Shipping_Days, round(avg(o2.review_score),0) as Avg_review_Scores 
from olist_order_reviews_dataset o2 inner join olist_orders_dataset o1 
on o2.order_id = o1.order_id
group by shipping_days;