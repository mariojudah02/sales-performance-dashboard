-- =========================================
-- 04_views_kpi.sql
-- KPI views (monthly + summary + insights)
-- =========================================

-- 1) Monthly KPIs (trend, MoM, ARPU)
CREATE OR REPLACE VIEW public.kpi_monthly AS
WITH monthly AS (
  SELECT
    year_month,
    SUM(amount) AS revenue,
    SUM(profit) AS profit,
    SUM(quantity) AS units,
    COUNT(DISTINCT transaction_id) AS orders,
    COUNT(DISTINCT customer_name) AS active_customers
  FROM public.export_sales
  GROUP BY 1
),
mom AS (
  SELECT
    year_month,
    revenue,
    profit,
    units,
    orders,
    active_customers,
    LAG(revenue) OVER (ORDER BY year_month) AS prev_revenue
  FROM monthly
)
SELECT
  year_month,
  revenue,
  profit,
  units,
  orders,
  active_customers,
  CASE WHEN prev_revenue IS NULL OR prev_revenue = 0 THEN NULL
       ELSE ROUND(100 * (revenue - prev_revenue) / prev_revenue::numeric, 2)
  END AS mom_growth_pct,
  CASE WHEN active_customers = 0 THEN NULL
       ELSE ROUND(revenue / active_customers::numeric, 2)
  END AS arpu
FROM mom
ORDER BY year_month;

-- 2) Revenue concentration (Top 10% customers share)
CREATE OR REPLACE VIEW public.kpi_revenue_concentration AS
WITH cust_rev AS (
  SELECT
    customer_name,
    SUM(amount) AS revenue
  FROM public.export_sales
  GROUP BY 1
),
ranked AS (
  SELECT
    customer_name,
    revenue,
    NTILE(10) OVER (ORDER BY revenue DESC) AS decile
  FROM cust_rev
),
final AS (
  SELECT
    SUM(revenue) AS total_revenue,
    SUM(CASE WHEN decile = 1 THEN revenue ELSE 0 END) AS top10pct_revenue
  FROM ranked
)
SELECT
  total_revenue,
  top10pct_revenue,
  ROUND(top10pct_revenue / NULLIF(total_revenue, 0)::numeric, 4) AS top10pct_share
FROM final;

-- 3) Repeat purchase rate (overall)
CREATE OR REPLACE VIEW public.kpi_repeat_purchase_rate AS
WITH customer_tx AS (
  SELECT
    customer_name,
    COUNT(DISTINCT transaction_id) AS transactions
  FROM public.export_sales
  GROUP BY 1
)
SELECT
  ROUND(
    COUNT(*) FILTER (WHERE transactions > 1)::numeric / NULLIF(COUNT(*), 0),
    4
  ) AS repeat_purchase_rate,
  COUNT(*) AS total_customers,
  COUNT(*) FILTER (WHERE transactions > 1) AS repeat_customers
FROM customer_tx;
