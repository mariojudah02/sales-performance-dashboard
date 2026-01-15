-- 1) Quick checks
SELECT COUNT(*) AS rows_total FROM raw_sales;

SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
  SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer
FROM raw_sales;

-- Duplicate rows check (approx)
SELECT order_id, order_date, customer_name, category, sub_category, amount, profit, quantity,
       COUNT(*) AS cnt
FROM raw_sales
GROUP BY 1,2,3,4,5,6,7,8
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

INSERT INTO dim_product_category (category, sub_category)
SELECT DISTINCT
  TRIM(category),
  TRIM(sub_category)
FROM raw_sales
WHERE category IS NOT NULL
  AND sub_category IS NOT NULL;
--TEST
SELECT COUNT(*) FROM dim_product_category;
SELECT * FROM dim_product_category LIMIT 10;

INSERT INTO dim_customer (customer_name, state, city)
SELECT DISTINCT
  TRIM(customer_name),
  TRIM(state),
  TRIM(city)
FROM raw_sales
WHERE customer_name IS NOT NULL;
--TEST
SELECT COUNT(*) FROM dim_customer;
SELECT * FROM dim_customer LIMIT 10;

INSERT INTO dim_date (order_date, year, month, year_month)
SELECT DISTINCT
  order_date,
  EXTRACT(YEAR FROM order_date)::INT AS year,
  EXTRACT(MONTH FROM order_date)::INT AS month,
  TO_CHAR(order_date, 'YYYY-MM') AS year_month
FROM raw_sales
WHERE order_date IS NOT NULL;
--TEST
SELECT COUNT(*) FROM dim_date;
SELECT MIN(order_date), MAX(order_date) FROM dim_date;

INSERT INTO fact_sales (
  order_id,
  customer_id,
  product_category_id,
  date_id,
  quantity,
  amount,
  profit
)
SELECT
  r.order_id,
  c.customer_id,
  p.product_category_id,
  d.date_id,
  r.quantity,
  r.amount AS amount,
  r.profit
FROM raw_sales r
JOIN dim_customer c
  ON c.customer_name = TRIM(r.customer_name)
 AND c.state = TRIM(r.state)
 AND c.city = TRIM(r.city)
JOIN dim_product_category p
  ON p.category = TRIM(r.category)
 AND p.sub_category = TRIM(r.sub_category)
JOIN dim_date d
  ON d.order_date = r.order_date;
--TEST
SELECT COUNT(*) FROM fact_sales;
SELECT * FROM fact_sales LIMIT 10;

--FK CONSTRAINTS AND INDEXES
ALTER TABLE fact_sales
  ADD CONSTRAINT fk_fact_customer
  FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id);

ALTER TABLE fact_sales
  ADD CONSTRAINT fk_fact_product_category
  FOREIGN KEY (product_category_id) REFERENCES dim_product_category(product_category_id);

ALTER TABLE fact_sales
  ADD CONSTRAINT fk_fact_date
  FOREIGN KEY (date_id) REFERENCES dim_date(date_id);

CREATE INDEX idx_fact_date ON fact_sales(date_id);
CREATE INDEX idx_fact_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_product_category ON fact_sales(product_category_id);
