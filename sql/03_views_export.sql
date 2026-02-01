-- 03_views_export.sql
-- Export view for Power BI (no fan-out joins)

CREATE OR REPLACE VIEW public.export_sales AS
SELECT
  f.sales_id,

  -- Synthetic transaction id
  md5(
    concat_ws('|',
      d.order_date::text,
      lower(trim(c.customer_name)),
      lower(coalesce(trim(c.state),'')),
      lower(coalesce(trim(c.city),'')),
      lower(trim(p.category)),
      lower(trim(p.sub_category)),
      coalesce(f.amount,0)::text,
      coalesce(f.quantity,0)::text
    )
  ) AS transaction_id,

  f.order_id,
  d.order_date,
  d.year,
  d.month,
  d.year_month,
  c.customer_name,
  c.state,
  c.city,
  p.category,
  p.sub_category,
  f.quantity,
  f.amount,
  f.profit
FROM fact_sales f
JOIN dim_customer c ON c.customer_id = f.customer_id
JOIN dim_date d ON d.date_id = f.date_id
JOIN dim_product_category p ON p.product_category_id = f.product_category_id;
