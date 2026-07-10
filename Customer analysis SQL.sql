CREATE DATABASE customer_analysis01;
USE customer_analysis01;
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(50),
  city VARCHAR(50),
  signup_date DATE
);

CREATE TABLE transactions (
  transaction_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  amount DECIMAL(10,2),
  product_category VARCHAR(50)
);

INSERT INTO customers VALUES
(1, 'Ravi Kumar',    'Hyderabad', '2023-01-10'),
(2, 'Priya Sharma',  'Mumbai',    '2023-02-15'),
(3, 'Arjun Reddy',   'Delhi',     '2023-03-20'),
(4, 'Sneha Patel',   'Chennai',   '2023-04-05'),
(5, 'Kiran Rao',     'Bangalore', '2023-05-12'),
(6, 'Divya Nair',    'Hyderabad', '2023-06-18'),
(7, 'Rahul Verma',   'Pune',      '2023-07-22'),
(8, 'Anjali Singh',  'Kolkata',   '2023-08-30');

INSERT INTO transactions VALUES
(101, 1, '2024-01-05', 1500.00, 'Electronics'),
(102, 1, '2024-02-10', 2300.00, 'Clothing'),
(103, 2, '2024-01-20', 800.00,  'Grocery'),
(104, 3, '2024-03-15', 4500.00, 'Electronics'),
(105, 3, '2024-04-10', 1200.00, 'Clothing'),
(106, 3, '2024-05-05', 3000.00, 'Electronics'),
(107, 4, '2023-12-01', 500.00,  'Grocery'),
(108, 5, '2024-06-10', 7000.00, 'Electronics'),
(109, 5, '2024-07-15', 2500.00, 'Clothing'),
(110, 6, '2022-10-10', 300.00,  'Grocery'),
(111, 7, '2024-08-01', 1800.00, 'Electronics'),
(112, 8, '2024-09-05', 950.00,  'Clothing');

SELECT c.customer_name,
       SUM(t.amount) AS total_spent
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

SELECT c.customer_name,
       COUNT(t.transaction_id) AS num_orders
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_name
ORDER BY num_orders DESC;

SELECT c.customer_name,
       MAX(t.order_date) AS last_purchase,
       DATEDIFF(CURRENT_DATE, MAX(t.order_date)) AS days_since_purchase
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_name
ORDER BY days_since_purchase ASC;

SELECT c.customer_name,
       DATEDIFF(CURRENT_DATE, MAX(t.order_date)) AS recency,
       COUNT(t.transaction_id)                   AS frequency,
       SUM(t.amount)                             AS monetary
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_name
ORDER BY monetary DESC;

SELECT customer_name, recency, frequency, monetary,
  CASE
    WHEN recency > 100 AND frequency >= 2 AND monetary >= 3000 THEN 'Champion'
    WHEN recency > 600 AND frequency >= 2                      THEN 'Loyal'
    WHEN recency > 300                                         THEN 'Lost'
    WHEN frequency = 1                                         THEN 'At Risk'
    ELSE 'Potential'
  END AS customer_segment
FROM (
  SELECT c.customer_name,
         DATEDIFF(CURRENT_DATE, MAX(t.order_date)) AS recency,
         COUNT(t.transaction_id)                   AS frequency,
         SUM(t.amount)                             AS monetary
  FROM customers c
  JOIN transactions t ON c.customer_id = t.customer_id
  GROUP BY c.customer_name
) rfm;

SELECT 
  COUNT(CASE WHEN days_inactive > 180 THEN 1 END) AS churned_customers,
  COUNT(*) AS total_customers,
  ROUND(COUNT(CASE WHEN days_inactive > 180 THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_percent
FROM (
  SELECT customer_id,
         DATEDIFF(CURRENT_DATE, MAX(order_date)) AS days_inactive
  FROM transactions
  GROUP BY customer_id
) t;

SELECT product_category,
       SUM(amount)  AS total_revenue,
       COUNT(*)     AS num_orders
FROM transactions
GROUP BY product_category
ORDER BY total_revenue DESC;