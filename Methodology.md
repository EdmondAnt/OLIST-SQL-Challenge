How to calculate Sales Revenue?

We have 2 sources of data that can be used to calculate revenue: Payments and Order_items tables.
Payments contain information on exact payments that were made by customers. It also contains cancelled and unavailable orders, that were probably reimbursed.
Order_items table contain price and freight value, combined they should be equal to actual payments.
Upon audit, there's slight variances between actual payments and price+freight from orders.

For the Category Sales Analysis, I am going to use order_items information, since variance is negligible and using payments carries out a multiplication risks. 
