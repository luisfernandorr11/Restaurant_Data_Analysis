import os
import sys
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

# Load environment variables from a local .env file
load_dotenv()

# --- SYSTEM INITIALIZATION & CORE CONFIGURATION ---
# Pulls the database URL securely from environment variables
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    print("[ERROR] DATABASE_URL is not set in the environment variables.", file=sys.stderr)
    sys.exit(1)

# Establish active target connection engine pool instance
engine = create_engine(DATABASE_URL)

# --- DIRECTORY MAPPING ---
BASE_DIR = os.path.expanduser("~/Documents/AZTECA SQL PROJECT")

# --- SCHEMA REGISTRY & EXTRACT-TRANSFORM-LOAD (ETL) PIPELINE ---
data_registry = {
    "summary_sales_data": [],
    "category_sales_summary": [],
    "daily_sales_data": [],
    "summary_labor_cost": [],
    "job_labor_cost": [],
    "hourly_sales_data": [],
    "weekday_sales_data": [],
    "master_food_data": [],
    "staging_item_sales": []
}

print("[INFO] Initializing filesystem traversal and schema ingestion arrays...")

# Step 1: Sequential Extraction and Metadata Mapping Lifecycle
for root, _, files in os.walk(BASE_DIR):
    current_directory = os.path.basename(root)
    
    for file in files:
        if file.endswith('.csv'):
            file_lower = file.lower()
            file_path = os.path.join(root, file)
            target_table = None
            
            # Complex string matrix pattern-matching array routing rules
            if "sales" in file_lower or "net_sales" in file_lower or "totals" in file_lower:
                if "category" in file_lower:
                    target_table = "category_sales_summary"
                elif "summary" in file_lower:
                    target_table = "summary_sales_data"
                elif "by day" in file_lower or "sales by day" in file_lower:
                    target_table = "daily_sales_data"
                elif "time of day" in file_lower or "hour" in file_lower:
                    target_table = "hourly_sales_data"
                elif "day of week" in file_lower:
                    target_table = "weekday_sales_data"
            
            elif "labor" in file_lower:
                if "summary" in file_lower:
                    target_table = "summary_labor_cost"
                elif "job" in file_lower:
                    target_table = "job_labor_cost"
            
            elif "product" in file_lower or "mix" in file_lower or "food" in file_lower:
                target_table = "master_food_data"
            elif "item" in file_lower:
                target_table = "staging_item_sales"
            
            # Execute standard data parsing rules if a valid layout vector is isolated
            if target_table:
                try:
                    df = pd.read_csv(file_path)
                    
                    # Standard structural layout schema normalization array
                    df.columns = df.columns.str.strip().str.lower()
                    df.columns = df.columns.str.replace(" ", "_").str.replace("%", "pct").str.replace("(", "").str.replace(")", "")
                    
                    # Inject operational auditing metadata parameters
                    df['source_month_folder'] = current_directory
                    df['source_file_name'] = file
                    
                    data_registry[target_table].append(df)
                    print(f"[STAGED] Scope: {current_directory} | File: {file}")
                except Exception as e:
                    print(f"[ERROR] Transactional processing failure on entity {file}: {str(e)}", file=sys.stderr)

print("\n[INFO] Initializing transactional schema injection operations to target cloud storage...")

# Step 2: Schema Reconciliation and Data Target Ingestion Lifecycle
for table_name, df_list in data_registry.items():
    if df_list:
        print(f"[LOAD] Restructuring relational layout map parameters for target: {table_name}")
        
        # Cross-file schema merging resolves variable structural layout shifts across monthly blocks
        final_df = pd.concat(df_list, ignore_index=True, sort=False)
        
        # Direct stream ingestion to cloud PostgreSQL server layers
        final_df.to_sql(name=table_name, con=engine, if_exists='replace', index=False)
        print(f"[SUCCESS] Target table operational footprint '{table_name}' synchronized. Total Rows: {len(final_df)}")

print("\n[SUCCESS] Production ETL Pipeline execution complete. Cloud database schemas optimized.")