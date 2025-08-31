-- Create staging table as TEXT
CREATE TABLE public.customer_order_raw
(
    order_id       TEXT,
    customer_name  TEXT,
    email          TEXT,
    order_date     TEXT,
    product_name   TEXT,
    quantity       TEXT,
    price          TEXT,
    country        TEXT,
    order_status   TEXT,
    notes          TEXT
);

-- Set ownership of the tables to the postgres user
ALTER TABLE public.customer_order_raw OWNER to postgres;

-- Copy and load csv file into table
COPY public.customer_order_raw 
FROM 'C:\Users\Haiza\Desktop\Portfolio\Datasets\Uncleaned_raw_data_file\uncleaned_customer_orders.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

