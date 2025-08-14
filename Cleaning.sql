SELECT * FROM bytehaven.orders;

describe orders;

ALTER TABLE orders
RENAME column `ï»¿customer_id` to customer_id;


DESCRIBE geo_lookup;

ALTER TABLE geo_lookup
RENAME column `ï»¿COUNTRY_CODE` to country_code;


DESCRIBE customers;


ALTER TABLE customers
RENAME column `ï»¿customer_id` to id;


DESCRIBE order_status;

ALTER TABLE order_status
RENAME column `ï»¿ORDER_ID` to order_id;



-- Changing column names to lower case for consistency
ALTER TABLE customers CHANGE `id` `id` VARCHAR(50);
ALTER TABLE customers CHANGE `MARKETING_CHANNEL` `marketing_channel` VARCHAR(50);
ALTER TABLE customers CHANGE `ACCOUNT_CREATION_METHOD` `account_creation_method` VARCHAR(100);
ALTER TABLE customers CHANGE `COUNTRY_CODE` `country_code` VARCHAR(50);
ALTER TABLE customers CHANGE `LOYALTY_PROGRAM` `loyalty_program` INT;
ALTER TABLE customers CHANGE `CREATED_ON` `created_on` VARCHAR(50);




ALTER TABLE orders MODIFY COLUMN purchase_ts DATE;

-- Fixing data types of the date columns
UPDATE orders
SET purchase_ts = NULL
WHERE purchase_ts = '';


ALTER TABLE orders
MODIFY COLUMN purchase_ts DATE;

DESCRIBE orders;

DESCRIBE customers;

UPDATE customers
SET created_on = NULL
WHERE created_on = '';


ALTER TABLE customers
MODIFY COLUMN created_on DATE;

DESCRIBE order_status;


UPDATE order_status
SET 
    purchase_ts = NULLIF(TRIM(purchase_ts), ''),
    ship_ts     = NULLIF(TRIM(ship_ts), ''),
    delivery_ts = NULLIF(TRIM(delivery_ts), ''),
    refund_ts   = NULLIF(TRIM(refund_ts), '');


ALTER TABLE order_status MODIFY COLUMN purchase_ts DATE;
ALTER TABLE order_status MODIFY COLUMN ship_ts DATE;
ALTER TABLE order_status MODIFY COLUMN delivery_ts DATE;
ALTER TABLE order_status MODIFY COLUMN refund_ts DATE;

SELECT * FROM order_status;

DESCRIBE geo_lookup;

ALTER TABLE order_status
MODIFY COLUMN order_id VARCHAR(50);

ALTER TABLE orders
MODIFY COLUMN customer_id VARCHAR (500),
MODIFY COLUMN order_id VARCHAR(50),
MODIFY COLUMN product_id VARCHAR(50);

DESCRIBE customers;

ALTER TABLE customers
MODIFY COLUMN id VARCHAR(500);

ALTER TABLE orders
DROP COLUMN MyUnknownColumn_0;


UPDATE customers
SET marketing_channel = NULL
WHERE marketing_channel = '';
