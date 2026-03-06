# This program helps to randomly samples 200 rows from the NYSE securities and prices CSVs.
# Run this before loading data into MySQL or MongoDB.
import argparse
import pandas as pd
from pathlib import Path

def reduce_dataset(securities_path, prices_path, output_dir=".", n=200, random_state=42):
    securities = pd.read_csv(securities_path)
    prices = pd.read_csv(prices_path)

    print(f"Original shapes:  securities={securities.shape}  prices={prices.shape}")

    securities_sample = securities.sample(n=n, random_state=random_state)
    prices_sample = prices.sample(n=n, random_state=random_state)

    print(f"Reduced shapes:   securities={securities_sample.shape}  prices={prices_sample.shape}")

    Path(output_dir).mkdir(parents=True, exist_ok=True)
    sec_out = Path(output_dir) / "securities_200.csv"
    pri_out = Path(output_dir) / "prices_200.csv"

    securities_sample.to_csv(sec_out, index=False)
    prices_sample.to_csv(pri_out, index=False)

    print(f"Saved: {sec_out}")
    print(f"Saved: {pri_out}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Reduce NYSE dataset to 200 rows each.")
    parser.add_argument("--securities", default="securities.csv")
    parser.add_argument("--prices", default="prices-split-adjusted.csv")
    parser.add_argument("--output", default="data")
    parser.add_argument("--n", type=int, default=200)
    args = parser.parse_args()
    reduce_dataset(args.securities, args.prices, args.output, args.n)
