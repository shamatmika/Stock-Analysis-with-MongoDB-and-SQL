// Run in mongosh: load("mongodb/mongo_operations.js")
use("stock_portfolio_db");

// Import CSV data via MongoDB Compass

db.securities.countDocuments();   // should equal 200
db.securities.findOne();
db.prices.countDocuments();       // should equal 200
db.prices.findOne();


// Create
db.createCollection("investors");
db.createCollection("portfolios");
db.createCollection("transactions");
db.createCollection("watchlist");


// Insert
// Single documents
db.investors.insertOne({
    investor_id: 1, first_name: "Sam", last_name: "Vishal",
    email: "svishal@email.com", phone: "555-0101",
    registration_date: new Date("2024-01-15"), risk_tolerance: "Aggressive"
});

db.portfolios.insertOne({
    portfolio_id: 1, investor_id: 1, portfolio_name: "Growth Portfolio",
    creation_date: new Date("2024-01-15"), total_investment: 50000.00, current_value: 55000.00
});

db.transactions.insertOne({
    transaction_id: 1, portfolio_id: 1, ticker_symbol: "AAPL",
    transaction_type: "BUY", transaction_date: new Date("2024-01-20"),
    quantity: 100, price_per_share: 185.50, total_amount: 18550.00, commission_fee: 9.99
});

db.watchlist.insertOne({
    watchlist_id: 1, investor_id: 1, ticker_symbol: "TSLA",
    added_date: new Date("2024-02-01"), target_price: 250.00,
    notes: "Wait for correction before buying"
});

// -- Multiple documents --
db.investors.insertMany([
    { investor_id: 2, first_name: "Megha",   last_name: "V",  email: "megha@email.com",  phone: "9758846372", registration_date: new Date("2023-12-01"), risk_tolerance: "Moderate" },
    { investor_id: 3, first_name: "SArath", last_name: "K", email: "sarath@email.com",   phone: "9056560478", registration_date: new Date("2024-02-10"), risk_tolerance: "Conservative" },
    { investor_id: 4, first_name: "Radhika",   last_name: "S",    email: "radhika@email.com",  phone: "9004566735", registration_date: new Date("2024-01-05"), risk_tolerance: "Moderate" }
]);

db.portfolios.insertMany([
    { portfolio_id: 2, investor_id: 1, portfolio_name: "Tech Stocks",         creation_date: new Date("2024-03-20"), total_investment: 30000.00,  current_value: 32000.00 },
    { portfolio_id: 3, investor_id: 2, portfolio_name: "Retirement Fund",     creation_date: new Date("2023-12-01"), total_investment: 100000.00, current_value: 105000.00 },
    { portfolio_id: 4, investor_id: 3, portfolio_name: "Conservative Income", creation_date: new Date("2024-02-10"), total_investment: 75000.00,  current_value: 76500.00 }
]);

db.transactions.insertMany([
    { transaction_id: 2, portfolio_id: 1, ticker_symbol: "MSFT",  transaction_type: "BUY",  transaction_date: new Date("2024-01-25"), quantity: 50, price_per_share: 402.30, total_amount: 20115.00, commission_fee: 9.99 },
    { transaction_id: 3, portfolio_id: 2, ticker_symbol: "GOOGL", transaction_type: "BUY",  transaction_date: new Date("2024-03-22"), quantity: 75, price_per_share: 145.80, total_amount: 10935.00, commission_fee: 9.99 },
    { transaction_id: 4, portfolio_id: 1, ticker_symbol: "AAPL",  transaction_type: "SELL", transaction_date: new Date("2024-06-15"), quantity: 50, price_per_share: 210.00, total_amount: 10500.00, commission_fee: 9.99 }
]);

db.watchlist.insertMany([
    { watchlist_id: 2, investor_id: 2, ticker_symbol: "NVDA", added_date: new Date("2024-01-10"), target_price: 800.00, notes: "Strong AI growth potential" },
    { watchlist_id: 3, investor_id: 3, ticker_symbol: "KO",   added_date: new Date("2024-02-15"), target_price:  58.00, notes: "Good dividend stock" },
    { watchlist_id: 4, investor_id: 1, ticker_symbol: "NVDA", added_date: new Date("2024-02-20"), target_price: 850.00, notes: "AI and GPU leader" }
]);


// Read/Find
db.investors.find();
db.portfolios.find();
db.transactions.find();

// Single document
db.investors.findOne({ email: "karlin@email.com" });

// Filtered queries
db.investors.find({ risk_tolerance: "Aggressive" });
db.transactions.find({ transaction_type: "BUY" });
db.portfolios.find({ total_investment: { $gt: 50000 } });
db.securities.find({ gics_sector: "Information Technology" });
db.prices.find({ ticker_symbol: "AAPL" });


// Update
// Update one document
db.investors.updateOne({ email: "karlin@email.com" }, { $set: { phone: "9023775646" } });
db.portfolios.updateOne({ portfolio_id: 1 },              { $set: { current_value: 60000.00 } });
db.watchlist.updateOne({ watchlist_id: 1 },               { $set: { target_price: 275.00 } });

// Update many documents
db.investors.updateMany({ risk_tolerance: "Moderate" },                        { $set: { reviewed: true } });
db.transactions.updateMany({ transaction_date: { $lt: new Date("2024-01-01") } }, { $set: { archived: true } });

// Replace a full document
db.watchlist.replaceOne(
    { watchlist_id: 1 },
    { watchlist_id: 1, investor_id: 1, ticker_symbol: "TSLA",
      added_date: new Date("2024-02-01"), target_price: 300.00,
      notes: "Updated target, strong growth expected" }
);


// Delete
db.watchlist.deleteOne({ watchlist_id: 4 });
db.investors.deleteOne({ email: "rajiv@email.com" });

db.transactions.deleteMany({ archived: true });
db.watchlist.deleteMany({ target_price: { $lt: 50 } });
db.prices.deleteMany({ price_date: { $lt: new Date("2020-01-01") } });
