-- This file contains six analytical queries for the NYSE stock portfolio database.

USE stock_portfolio_db;

-- Find all Information Technology sector securities
SELECT ticker_symbol, security_name, gics_sector, gics_subindustry
FROM   securities
WHERE  gics_sector = 'Information Technology'
ORDER BY security_name;

-- Total portfolio value per investor
SELECT
    i.investor_id,
    CONCAT(i.first_name, ' ', i.last_name)  AS investor_name,
    COUNT(DISTINCT p.portfolio_id)           AS num_portfolios,
    SUM(p.total_investment)                  AS total_invested,
    SUM(p.current_value)                     AS total_current_value,
    SUM(p.current_value - p.total_investment) AS total_gain_loss
FROM investors i
LEFT JOIN portfolios p ON i.investor_id = p.investor_id
GROUP BY i.investor_id, investor_name
ORDER BY total_current_value DESC;

-- All transactions with investor and security details
SELECT
    t.transaction_id,
    CONCAT(i.first_name, ' ', i.last_name) AS investor_name,
    p.portfolio_name,
    s.security_name,
    t.ticker_symbol,
    t.transaction_type,
    t.transaction_date,
    t.quantity,
    t.price_per_share,
    t.total_amount
FROM transactions t
JOIN portfolios p  ON t.portfolio_id  = p.portfolio_id
JOIN investors  i  ON p.investor_id   = i.investor_id
JOIN securities s  ON t.ticker_symbol = s.ticker_symbol
ORDER BY t.transaction_date DESC;

-- Securities with above-average trading volume
SELECT
    s.ticker_symbol,
    s.security_name,
    s.gics_sector,
    AVG(p.volume) AS avg_volume
FROM securities s
JOIN prices p ON s.ticker_symbol = p.ticker_symbol
GROUP BY s.ticker_symbol, s.security_name, s.gics_sector
HAVING AVG(p.volume) > (SELECT AVG(volume) FROM prices)
ORDER BY avg_volume DESC
LIMIT 10;

-- Investors with more than $50,000 total investment
SELECT
    i.investor_id,
    CONCAT(i.first_name, ' ', i.last_name) AS investor_name,
    i.risk_tolerance,
    COUNT(p.portfolio_id)      AS num_portfolios,
    SUM(p.total_investment)    AS total_investment
FROM investors i
JOIN portfolios p ON i.investor_id = p.investor_id
GROUP BY i.investor_id, investor_name, i.risk_tolerance
HAVING SUM(p.total_investment) > 50000
ORDER BY total_investment DESC;

-- High-value investors UNION investors with multiple portfolios
(SELECT
    i.investor_id,
    CONCAT(i.first_name, ' ', i.last_name) AS investor_name,
    'High Value' AS category,
    SUM(p.total_investment) AS value
FROM investors i
JOIN portfolios p ON i.investor_id = p.investor_id
GROUP BY i.investor_id, investor_name
HAVING SUM(p.total_investment) > 75000)

UNION

(SELECT
    i.investor_id,
    CONCAT(i.first_name, ' ', i.last_name),
    'Many Portfolios',
    COUNT(p.portfolio_id)
FROM investors i
JOIN portfolios p ON i.investor_id = p.investor_id
GROUP BY i.investor_id, investor_name
HAVING COUNT(p.portfolio_id) >= 2)

ORDER BY investor_id, category;

-- How much profit/loss on Apple stock vs. latest price
SELECT
    t.ticker_symbol,
    s.security_name,
    t.transaction_date,
    t.quantity,
    t.price_per_share                              AS bought_at,
    p.close_price                                  AS current_price,
    (p.close_price - t.price_per_share) * t.quantity AS profit_loss
FROM transactions t
JOIN securities s ON t.ticker_symbol = s.ticker_symbol
JOIN prices     p ON t.ticker_symbol = p.ticker_symbol
WHERE t.ticker_symbol   = 'AAPL'
  AND t.transaction_type = 'BUY'
  AND p.price_date = (SELECT MAX(price_date) FROM prices WHERE ticker_symbol = 'AAPL');
