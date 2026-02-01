-- 02_etl.sql
-- Load dims + fact from raw_sales

-- DIM: product category
INSERT INTO dim_product_category (category, sub_category)
SELECT DISTINCT
  TRIM(category),
  TRIM(sub_category)
FROM raw_sales
WHERE category IS NOT NULL
  AND sub_category IS NOT NULL
ON CONFLICT (category, sub_category) DO NOTHING;

-- DIM: customer
INSERT INTO dim_customer (customer_name, state, city)
SELECT DISTINCT
  TRIM(customer_name),
  NULLIF(TRIM(state), ''),
  NULLIF(TRIM(city), '')
FROM raw_sales
WHERE customer_name IS NOT NULL
ON CONFLICT (customer_name, state, city) DO NOTHING;

-- DIM: date
INSERT INTO dim_date (order_date, year, month, year_month)
SELECT DISTINCT
  order_date,
  EXTRACT(YEAR FROM order_date)::INT,
  EXTRACT(MONTH FROM order_date)::INT,
  TO_CHAR(order_date, 'YYYY-MM')
FROM raw_sales
WHERE order_date IS NOT NULL
ON CONFLICT (order_date) DO NOTHING;

-- FACT
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
  r.amount,
  r.profit
FROM raw_sales r
JOIN dim_customer c
  ON c.customer_name = TRIM(r.customer_name)
 AND COALESCE(c.state,'') = COALESCE(TRIM(r.state),'')
 AND COALESCE(c.city,'')  = COALESCE(TRIM(r.city),'')
JOIN dim_product_category p
  ON p.category = TRIM(r.category)
 AND p.sub_category = TRIM(r.sub_category)
JOIN dim_date d
  ON d.order_date = r.order_date;
