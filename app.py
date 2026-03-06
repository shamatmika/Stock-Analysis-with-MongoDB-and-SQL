#Gradio frontend

#Tabs:
#  1. Data Preparation  – reduce_dataset helper
#  2. MySQL Queries     – run any of the 6 predefined SQL queries (with live DB)
#  3. MongoDB Explorer  – run predefined Mongo find/aggregate operations
#  4. SQL Reference     – view the full SQL schema and query code
#  5. MongoDB Reference – view the full Mongo CRUD script

#Usage:
#    pip install gradio pandas mysql-connector-python pymongo
#    python frontend/app.py


import os
import textwrap
import pandas as pd
import gradio as gr
try:
    import mysql.connector
    MYSQL_AVAILABLE = True
except ImportError:
    MYSQL_AVAILABLE = False

try:
    from pymongo import MongoClient
    MONGO_AVAILABLE = True
except ImportError:
    MONGO_AVAILABLE = False


# HELPER FUNCTIONS
# Sample n rows from each uploaded CSV and return as DataFrames
def reduce_dataset(securities_file, prices_file, n): 
    if securities_file is None or prices_file is None:
        return None, None, "Please upload both CSV files."
    try:
        sec = pd.read_csv(securities_file.name).sample(n=int(n), random_state=42)
        pri = pd.read_csv(prices_file.name).sample(n=int(n), random_state=42)
        sec.to_csv("securities_200.csv", index=False)
        pri.to_csv("prices_200.csv", index=False)
        msg = f"Sampled {n} rows each. Files saved as securities_200.csv and prices_200.csv."
        return sec, pri, msg
    except Exception as e:
        return None, None, f" Error: {e}"

# Connect to MySQL and run the selected predefined query
def run_mysql_query(host, port, user, password, database, query_name):
    if not MYSQL_AVAILABLE:
        return None, "mysql-connector-python not installed. Run: pip install mysql-connector-python"
    sql = SQL_QUERIES.get(query_name, "")
    if not sql.strip():
        return None, " No query selected."
    try:
        conn = mysql.connector.connect(
            host=host, port=int(port), user=user, password=password, database=database
        )
        df = pd.read_sql(textwrap.dedent(sql), conn)
        conn.close()
        return df, f"Returned {len(df)} rows."
    except Exception as e:
        return None, f"{e}"

# Run a basic MongoDB find operation
def run_mongo_op(uri, database, collection, operation, filter_field, filter_value, limit):
    if not MONGO_AVAILABLE:
        return None, "pymongo not installed. Run: pip install pymongo"
    try:
        client = MongoClient(uri, serverSelectionTimeoutMS=4000)
        db = client[database]
        col = db[collection]

        query = {}
        if filter_field.strip() and filter_value.strip():
            # Try numeric conversion
            try:
                val = float(filter_value) if "." in filter_value else int(filter_value)
            except ValueError:
                val = filter_value
            query = {filter_field.strip(): val}

        if operation == "find":
            cursor = col.find(query, {"_id": 0}).limit(int(limit))
            docs = list(cursor)
        elif operation == "count":
            count = col.count_documents(query)
            return pd.DataFrame([{"count": count}]), f"Count: {count}"
        else:
            docs = []

        client.close()
        if not docs:
            return pd.DataFrame(), "No documents matched."
        df = pd.json_normalize(docs)
        return df, f"Returned {len(df)} document(s)."
    except Exception as e:
        return None, f"{e}"


def load_sql_file(filename):
    path = os.path.join(os.path.dirname(__file__), "..", "sql", filename)
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        return f"File not found: {path}"


def load_mongo_file():
    path = os.path.join(os.path.dirname(__file__), "..", "mongodb", "mongo_operations.js")
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        return f"File not found: {path}"


# GRADIO UI
with gr.Blocks(title="NYSE Stock Portfolio Explorer", theme=gr.themes.Soft()) as demo:

    gr.Markdown(
        """
        # NYSE Stock Portfolio Explorer        
        Use the tabs below to prepare data, run SQL queries, explore MongoDB, or view reference code.
        """
    )

    # Tab 1: Data Preparation
    with gr.Tab("Data Preparation"):
        gr.Markdown("### Reduce NYSE CSVs to 200 rows each")
        gr.Markdown(
            "Upload the raw Kaggle CSVs (`securities.csv` and `prices-split-adjusted.csv`). The tool will randomly sample *n* rows and save reduced files locally."
        )
        with gr.Row():
            sec_upload = gr.File(label="securities.csv", file_types=[".csv"])
            pri_upload = gr.File(label="prices-split-adjusted.csv", file_types=[".csv"])
        n_slider = gr.Slider(50, 1000, value=200, step=50, label="Sample size (n)")
        reduce_btn = gr.Button("Reduce Dataset", variant="primary")
        reduce_status = gr.Textbox(label="Status", interactive=False)
        with gr.Row():
            sec_preview = gr.Dataframe(label="Securities preview (first 10 rows)", max_rows=10)
            pri_preview = gr.Dataframe(label="Prices preview (first 10 rows)", max_rows=10)

        reduce_btn.click(
            reduce_dataset,
            inputs=[sec_upload, pri_upload, n_slider],
            outputs=[sec_preview, pri_preview, reduce_status],
        )

    # Tab 2: MySQL Queries
    with gr.Tab(" MySQL Queries"):
        gr.Markdown("### Run predefined SQL queries against your MySQL database")
        if not MYSQL_AVAILABLE:
            gr.Markdown(" **mysql-connector-python** not installed, install it to enable live queries.")
        with gr.Row():
            with gr.Column(scale=1):
                gr.Markdown("**Connection Settings**")
                db_host = gr.Textbox(value="localhost", label="Host")
                db_port = gr.Textbox(value="3306", label="Port")
                db_user = gr.Textbox(value="root", label="User")
                db_pass = gr.Textbox(value="", label="Password", type="password")
                db_name = gr.Textbox(value="stock_portfolio_db", label="Database")
            with gr.Column(scale=2):
                gr.Markdown("**Select a Query**")
                query_select = gr.Dropdown(
                    choices=list(SQL_QUERIES.keys()),
                    value=list(SQL_QUERIES.keys())[0],
                    label="Predefined Query",
                )
                query_preview = gr.Code(
                    value=SQL_QUERIES[list(SQL_QUERIES.keys())[0]],
                    language="sql",
                    label="SQL Preview",
                    interactive=False,
                )
                query_select.change(lambda q: SQL_QUERIES[q], inputs=query_select, outputs=query_preview)

        run_sql_btn = gr.Button(" Run Query", variant="primary")
        sql_status = gr.Textbox(label="Status", interactive=False)
        sql_result = gr.Dataframe(label="Results", max_rows=50)

        run_sql_btn.click(
            run_mysql_query,
            inputs=[db_host, db_port, db_user, db_pass, db_name, query_select],
            outputs=[sql_result, sql_status],
        )

    # Tab 3: MongoDB Explorer
    with gr.Tab(" MongoDB Explorer"):
        gr.Markdown("### Query your MongoDB collections")
        if not MONGO_AVAILABLE:
            gr.Markdown(" **pymongo** not installed, install it to enable live queries.")
        with gr.Row():
            mongo_uri  = gr.Textbox(value="mongodb://localhost:27017", label="MongoDB URI")
            mongo_db   = gr.Textbox(value="stock_portfolio_db", label="Database")
        with gr.Row():
            mongo_col  = gr.Dropdown(
                choices=["investors","portfolios","transactions","watchlist","securities","prices"],
                value="investors", label="Collection"
            )
            mongo_op   = gr.Radio(choices=["find","count"], value="find", label="Operation")
            mongo_lim  = gr.Slider(1, 100, value=20, step=1, label="Limit (find)")
        with gr.Row():
            mongo_ff   = gr.Textbox(label="Filter field (optional)", placeholder="e.g. risk_tolerance")
            mongo_fv   = gr.Textbox(label="Filter value (optional)", placeholder="e.g. Aggressive")

        run_mongo_btn = gr.Button(" Run Operation", variant="primary")
        mongo_status  = gr.Textbox(label="Status", interactive=False)
        mongo_result  = gr.Dataframe(label="Results", max_rows=50)

        run_mongo_btn.click(
            run_mongo_op,
            inputs=[mongo_uri, mongo_db, mongo_col, mongo_op, mongo_ff, mongo_fv, mongo_lim],
            outputs=[mongo_result, mongo_status],
        )

    # Tab 4: SQL Reference
    with gr.Tab(" SQL Reference"):
        gr.Markdown("Browse the SQL source files.")
        sql_file_select = gr.Dropdown(
            choices=["01_schema.sql","02_load_data.sql","03_sample_data.sql","04_queries.sql"],
            value="01_schema.sql", label="File"
        )
        sql_code_view = gr.Code(
            value=load_sql_file("01_schema.sql"),
            language="sql", label="Contents", interactive=False
        )
        sql_file_select.change(load_sql_file, inputs=sql_file_select, outputs=sql_code_view)

    # Tab 5: MongoDB Reference
    with gr.Tab(" MongoDB Reference"):
        gr.Markdown("Browse the full MongoDB CRUD operations script.")
        gr.Code(value=load_mongo_file(), language="javascript", label="mongo_operations.js", interactive=False)


if __name__ == "__main__":
    demo.launch(share=False)
