-- 99_checks.sql

-- Row counts
SELECT COUNT(*) AS raw_rows FROM raw_sales;
SELECT COUNT(*) AS fact_rows FROM fact_sales;

-- Revenue match
SELECT SUM(amount) AS fact_revenue FROM fact_sales;
SELECT SUM(amount) AS export_revenue FROM export_sales;

-- Transaction sanity
SELECT
  COUNT(*) AS rows,
  COUNT(DISTINCT transaction_id) AS distinct_transactions,
  COUNT(DISTINCT order_id) AS distinct_order_id
FROM export_sales;

-- KPI sanity
SELECT * FROM kpi_monthly;
SELECT * FROM kpi_revenue_concentration;
SELECT * FROM kpi_repeat_purchase_rate;

-- Month coverage
SELECT MIN(year_month) AS min_ym, MAX(year_month) AS max_ym, COUNT(*) AS months
FROM kpi_monthly;
