-- This file is to insert sample investors, portfolios, transactions, watchlist.

USE stock_portfolio_db;

INSERT INTO investors (first_name, last_name, email, phone, risk_tolerance) VALUES
('Rajiv',    'AG',    'rajiv@email.com', '9566756753', 'Aggressive'),
('Saranya',   'AG',  'saranya@email.com',    '9466434854', 'Moderate'),
('Michael', 'VS', 'michael@email.com',     '98367394467', 'Conservative'),
('Shivam',   'T',    'shivam@email.com',    '9758433568', 'Moderate'),
('Karlin',   'F',    'karlin@email.com',    '9467398823', 'Aggressive');

INSERT INTO portfolios (investor_id, portfolio_name, creation_date, total_investment) VALUES
(1, 'Growth Portfolio',    '2024-01-15', 50000.00),
(1, 'Tech Stocks',         '2024-03-20', 30000.00),
(2, 'Retirement Fund',     '2023-12-01', 100000.00),
(3, 'Conservative Income', '2024-02-10', 75000.00),
(4, 'Dividend Growth',     '2024-01-05', 45000.00);

INSERT INTO transactions
    (portfolio_id, ticker_symbol, transaction_type, transaction_date,
     quantity, price_per_share, total_amount, commission_fee)
VALUES
(1, 'AAPL',  'BUY',  '2024-01-20', 100, 185.50, 18550.00, 9.99),
(1, 'MSFT',  'BUY',  '2024-01-25',  50, 402.30, 20115.00, 9.99),
(2, 'GOOGL', 'BUY',  '2024-03-22',  75, 145.80, 10935.00, 9.99),
(3, 'JNJ',   'BUY',  '2023-12-05', 200, 155.20, 31040.00, 9.99),
(1, 'AAPL',  'SELL', '2024-06-15',  50, 210.00, 10500.00, 9.99);

INSERT INTO watchlist (investor_id, ticker_symbol, target_price, notes) VALUES
(1, 'TSLA', 250.00, 'Wait for correction before buying'),
(2, 'NVDA', 800.00, 'Strong AI growth potential'),
(3, 'KO',    58.00, 'Good dividend stock'),
(4, 'PG',   145.00, 'Consumer staples, safe bet');
