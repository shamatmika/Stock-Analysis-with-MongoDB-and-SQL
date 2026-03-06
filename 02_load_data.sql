-- This file will load your reduced CSV files into MySQL.
--
-- Prerequisites:
--   1. Run 01_schema.sql first.
--   2. Enable local_infile:
--        SET GLOBAL local_infile = 1;
--      then reconnect with: mysql --local-infile=1 -u root -p stock_portfolio_db
--   3. Update the file paths below to match your system.

USE stock_portfolio_db;

SHOW VARIABLES LIKE 'local_infile'; -- Check that local_infile is enabled

LOAD DATA LOCAL INFILE '/path/to/data/securities_200.csv' -- Load securities (update path as needed)
INTO TABLE securities
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/data/prices_200.csv' -- Load prices (update path as needed)
INTO TABLE prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 'securities' AS table_name, COUNT(*) AS rows FROM securities
UNION ALL
SELECT 'prices',     COUNT(*) FROM prices;
