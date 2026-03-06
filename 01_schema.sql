-- This file creates the stock_portfolio_db database and all tables.
-- Run: mysql -u root -p < sql/01_schema.sql

CREATE DATABASE IF NOT EXISTS stock_portfolio_db;
USE stock_portfolio_db;

CREATE TABLE IF NOT EXISTS securities (
    ticker_symbol       VARCHAR(10)  PRIMARY KEY,
    security_name       VARCHAR(200) NOT NULL,
    sec_filings         VARCHAR(100),
    gics_sector         VARCHAR(100),
    gics_subindustry    VARCHAR(100),
    date_added          DATE,
    headquarters_address VARCHAR(300),
    cik                 VARCHAR(20)  UNIQUE
);

CREATE TABLE IF NOT EXISTS prices (
    price_id        INT          PRIMARY KEY,
    ticker_symbol   VARCHAR(10)  NOT NULL,
    price_date      DATE         NOT NULL,
    open_price      DECIMAL(10,2),
    high_price      DECIMAL(10,2),
    low_price       DECIMAL(10,2),
    close_price     DECIMAL(10,2),
    adj_close_price DECIMAL(10,2),
    volume          BIGINT,
    FOREIGN KEY (ticker_symbol) REFERENCES securities(ticker_symbol) ON DELETE CASCADE,
    UNIQUE KEY unique_ticker_date (ticker_symbol, price_date),
    CHECK (high_price >= low_price),
    CHECK (volume >= 0)
);

CREATE TABLE IF NOT EXISTS investors (
    investor_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(100) UNIQUE NOT NULL,
    phone             VARCHAR(20),
    registration_date DATE         NOT NULL DEFAULT (CURRENT_DATE),
    risk_tolerance    ENUM('Conservative','Moderate','Aggressive') DEFAULT 'Moderate',
    CHECK (email LIKE '%@%.%')
);

CREATE TABLE IF NOT EXISTS portfolios (
    portfolio_id      INT AUTO_INCREMENT PRIMARY KEY,
    investor_id       INT          NOT NULL,
    portfolio_name    VARCHAR(100) NOT NULL,
    creation_date     DATE         NOT NULL DEFAULT (CURRENT_DATE),
    total_investment  DECIMAL(15,2) DEFAULT 0.00,
    current_value     DECIMAL(15,2) DEFAULT 0.00,
    FOREIGN KEY (investor_id) REFERENCES investors(investor_id) ON DELETE CASCADE,
    CHECK (total_investment >= 0),
    CHECK (current_value >= 0)
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id    INT AUTO_INCREMENT PRIMARY KEY,
    portfolio_id      INT          NOT NULL,
    ticker_symbol     VARCHAR(10)  NOT NULL,
    transaction_type  ENUM('BUY','SELL') NOT NULL,
    transaction_date  DATE         NOT NULL,
    quantity          INT          NOT NULL,
    price_per_share   DECIMAL(10,2) NOT NULL,
    total_amount      DECIMAL(15,2) NOT NULL,
    commission_fee    DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (portfolio_id)   REFERENCES portfolios(portfolio_id) ON DELETE CASCADE,
    FOREIGN KEY (ticker_symbol)  REFERENCES securities(ticker_symbol),
    CHECK (quantity > 0),
    CHECK (price_per_share > 0),
    CHECK (commission_fee >= 0)
);

CREATE TABLE IF NOT EXISTS watchlist (
    watchlist_id  INT AUTO_INCREMENT PRIMARY KEY,
    investor_id   INT         NOT NULL,
    ticker_symbol VARCHAR(10) NOT NULL,
    added_date    DATE        NOT NULL DEFAULT (CURRENT_DATE),
    target_price  DECIMAL(10,2),
    notes         TEXT,
    FOREIGN KEY (investor_id)   REFERENCES investors(investor_id) ON DELETE CASCADE,
    FOREIGN KEY (ticker_symbol) REFERENCES securities(ticker_symbol),
    UNIQUE KEY unique_investor_ticker (investor_id, ticker_symbol),
    CHECK (target_price > 0)
);
