# NYSE Stock Portfolio using MySQL & MongoDB Mini Project

> The aim here is to analyze daily NYSE stock prices and company sector data using **MySQL** and **MongoDB** to generate actionable financial insights for investors. Gradio has been used as a simple frontend

---

## Project Structure

```
nyse-stock-portfolio/
├── README.md
├── reduce_dataset.py        # Randomly sample 200 rows from CSVs
├── sql/
│   ├── 01_schema.sql            # CREATE TABLE statements
│   ├── 02_load_data.sql         # LOAD DATA LOCAL INFILE commands
│   ├── 03_sample_data.sql       # INSERT sample investors/portfolios/etc.
│   └── 04_queries.sql           # 6 analytical SQL queries
├── mongodb/
│   └── mongo_operations.js      # CRUD operations in MongoDB Shell syntax
└── frontend/
    └── app.py                   # Gradio frontend for interactive querying
```

---

## Dataset

Download from Kaggle: [New York Stock Exchange](https://www.kaggle.com/datasets/dgawlik/nyse?resource=download)

Files used:
- `prices-split-adjusted.csv`
- `securities.csv`

Run `data_prep/reduce_dataset.py` to sample 200 rows from each for development.

---

## Quick Start

### 1. Install Python dependencies
```bash
pip install -r requirements.txt
```

### 2. Prepare data
```bash
python data_prep/reduce_dataset.py
```

### 3. Set up MySQL
```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p stock_portfolio_db < sql/02_load_data.sql
mysql -u root -p stock_portfolio_db < sql/03_sample_data.sql
```

### 4. Set up MongoDB
Open MongoDB Compass or `mongosh` and run the contents of `mongodb/mongo_operations.js`.

### 5. Launch the Gradio Frontend
```bash
python frontend/app.py
```
Then open http://localhost:7860 in your browser.

---

## Entity-Relationship Overview

| Entity | Primary Key | Relationships |
|---|---|---|
| Securities | ticker_symbol | → Prices (1:M), Transactions (1:M), Watchlist (1:M) |
| Prices | price_id | → Securities (M:1) |
| Investors | investor_id | → Portfolios (1:M), Watchlist (1:M) |
| Portfolios | portfolio_id | → Investors (M:1), Transactions (1:M) |
| Transactions | transaction_id | → Portfolios (M:1), Securities (M:1) |
| Watchlist | watchlist_id | → Investors (M:1), Securities (M:1) |
