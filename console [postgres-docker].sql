1.
-- The "ON DELETE CASCADE" feature is used to automatically delete a foreign key value once a linked row in the primary key column is deleted.
-- This operation is different than th normal FK function, where the FK value won't be deleted automatically.
-- By automatically erasing the linked value in the FK column, we can ensure a safer operation and avoid unlinked FK values.

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE CASCADE
);

INSERT INTO departments (department_name) VALUES ('HR'), ('IT'), ('Finance');
INSERT INTO employees (employee_name, department_id) VALUES
('Alice', 1), ('Bob', 2), ('Charlie', 3);
DELETE FROM departments WHERE department_id = 1;
SELECT * FROM employees;

2.
-- A "random_numbers" table is created with a decimal value for the items in the "random_value" column

CREATE TABLE random_numbers (
    id SERIAL PRIMARY KEY,
    random_value DECIMAL
);

-- 10 random numbers are inserted into the "random_value" column, being generated in some kind of a "for-range" loop with the "generate_series(1, 10)" order.
-- The generated randoms numbers will be from 0 to 1, a built in function, used by RANDOM(), and multiplied by 100, to allow for a 2 digits after the dot decimal numbers.
-- The "ROUND" function is used to round the decimal number for a 2 points limit, but in doing so we might lose accuracy. The "numeric" funtion is then used to ensure accuracy for the decimal number and without floating-point errors.

INSERT INTO random_numbers (random_value)
SELECT ROUND((RANDOM() * 100)::numeric, 2)
FROM generate_series(1, 10);

SELECT * FROM random_numbers;

-- This order will select 3 random rows to be shown:

SELECT * FROM random_numbers
ORDER BY RANDOM()
LIMIT 3;

-- This will update the value of the 1st number (id no. 1) to a new random number:

UPDATE random_numbers
SET random_value = ROUND((RANDOM() * 100)::numeric, 2)
WHERE id = 1;

SELECT * FROM random_numbers;

3.
-- This function creates a "sales" table, with an automatic serial no. as primary key.
-- The table will include the "product_name" column, in which values are limited to 100 characters (using VARCHAR )
-- Also a  decimal "sale_amount" column, in which numbers are limited to 10 digits, two of them after the point.
-- AND last, sale_timestamp uses a TIMESTAMP order, which will record the date and time of the sale.

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
--     product_name VARCHAR(100),
    sale_amount DECIMAL(10, 2),
    sale_timestamp TIMESTAMP
);

-- In here, the values for the "product_name", "sale_amount", and "sale_timestamp" are being inserted.:

INSERT INTO sales (product_name, sale_amount, sale_timestamp) VALUES
('Laptop', 1200.50, '2024-01-10 10:30:00'),
('Smartphone', 800.00, '2024-01-15 14:45:00'),
('Tablet', 450.75, '2024-02-05 09:00:00'),
('Monitor', 250.00, '2024-03-10 11:15:00'),
('Keyboard', 50.00, '2024-03-12 16:30:00');

-- This function will result in showing all sales that are equal to or bigger than the'2024-03-01 00:00:00' timestamp, while also smaller than the '2024-04-01 00:00:00' timestamp.
-- In other words, only sales made between midnight 1/3/2024 and midnight 1/4/2024 will be shown (sales from March only, actually)

SELECT * FROM sales
WHERE sale_timestamp >= '2024-03-01 00:00:00'
AND sale_timestamp < '2024-04-01 00:00:00';

-- The EXTRACT function shows a specific data from a list. in this case, potsgerSQL is related to an inner calender, and can identify the days by the dates provided in the TIMESTAMP.
-- In this case, only sales made on days 0 and 6 will be shown (0 being Sunday and 6 being Saturday) using the DOW (Day Of Week) function

SELECT * FROM sales
WHERE EXTRACT(DOW FROM sale_timestamp) IN (0, 6);

-- This command will show all the sales from the last week. PostgreSQL recognises today's date and time (using the 'NOW' function)' ||
-- and shows all records for 7 days up to this time using INTERVAL
-- מגניב בטירוף!

SELECT * FROM sales
WHERE sale_timestamp >= NOW() - INTERVAL '7 days';

-- This code will show all sales from any date, that were performed between 9 and 17, using the "HOUR" function

SELECT * FROM sales
WHERE EXTRACT(HOUR FROM sale_timestamp) BETWEEN 9 AND 17;

-- This will count the numbers of sales per date and arrange them in an ascending order accordinig to date.

SELECT DATE(sale_timestamp) AS sale_date, COUNT(*) AS total_sales
FROM sales
GROUP BY DATE(sale_timestamp)
ORDER BY sale_date;

-- This code will show all sales from all dates, that were performed before noon 12:00

SELECT * FROM sales
WHERE EXTRACT(HOUR FROM sale_timestamp) < 12;

-- Using this code we can track the first sale of specific products. The code shows the first record of a sale (using the MIN function) per product (using GROUP BY product_name)

SELECT product_name, MIN(sale_timestamp) AS first_sale
FROM sales
GROUP BY product_name;

-- This code will show the latest sell of a product, using MAX and GROUP by.

SELECT product_name, MAX(sale_timestamp) AS last_sale
FROM sales
GROUP BY product_name;

-- This code will sum up all sales made from any date, with the restriction of time being from noon 12 to 14:59.
-- That said, it means that "14" uses the upper border (14:59) and not the lower one (14:00), so the hour between 14:00 and 15:00 is included.
-- In this case, the total_sales column shows the figure 800, as the laptop was the only product sold between 12 and 14:59, at 14:45:00

SELECT DATE(sale_timestamp) AS sale_date, SUM(sale_amount) AS total_sales
FROM sales
WHERE EXTRACT(HOUR FROM sale_timestamp) BETWEEN 12 AND 14
GROUP BY DATE(sale_timestamp);
