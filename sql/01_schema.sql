-- 01_schema.sql
-- Raw + star schema tables

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product_category;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS raw_sales;

CREATE TABLE raw_sales (
    order_id        TEXT,
    amount          NUMERIC,
    profit          NUMERIC,
    quantity        INTEGER,
    category        TEXT,
    sub_category    TEXT,
    payment_mode    TEXT,
    order_date      DATE,
    customer_name   TEXT,
    state           TEXT,
    city            TEXT,
    year_month      TEXT
);

CREATE TABLE dim_product_category (
    product_category_id SERIAL PRIMARY KEY,
    category            TEXT NOT NULL,
    sub_category        TEXT NOT NULL,
    CONSTRAINT uq_dim_product_category UNIQUE (category, sub_category)
);

CREATE TABLE dim_date (
    date_id     SERIAL PRIMARY KEY,
    order_date  DATE NOT NULL UNIQUE,
    year        INTEGER NOT NULL,
    month       INTEGER NOT NULL,
    year_month  TEXT NOT NULL
);

CREATE TABLE dim_customer (
    customer_id     SERIAL PRIMARY KEY,
    customer_name   TEXT NOT NULL,
    state           TEXT,
    city            TEXT,
    CONSTRAINT uq_dim_customer UNIQUE (customer_name, state, city)
);

CREATE TABLE fact_sales (
    sales_id              SERIAL PRIMARY KEY,
    order_id              TEXT,
    customer_id           INTEGER NOT NULL,
    product_category_id   INTEGER NOT NULL,
    date_id               INTEGER NOT NULL,
    quantity              INTEGER,
    amount                NUMERIC,
    profit                NUMERIC
);

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
