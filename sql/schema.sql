--DROP
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
    category            TEXT,
    sub_category        TEXT
);

CREATE TABLE dim_date (
    date_id     SERIAL PRIMARY KEY,
    order_date  DATE UNIQUE,
    year        INTEGER,
    month       INTEGER,
    year_month  TEXT
);

CREATE TABLE dim_customer (
    customer_id     SERIAL PRIMARY KEY,
    customer_name   TEXT,
    state           TEXT,
    city            TEXT
);

CREATE TABLE fact_sales (
    sales_id              SERIAL PRIMARY KEY,
    order_id              TEXT,
    customer_id           INTEGER,
    product_category_id   INTEGER,
    date_id               INTEGER,
    quantity              INTEGER,
    amount                NUMERIC,
    profit                NUMERIC
);