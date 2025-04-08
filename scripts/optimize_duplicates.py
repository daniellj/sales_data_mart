from clickhouse_driver import Client
import logging
import os
from datetime import datetime, timedelta

LOG_FILE = 'optimize_partitions.log'
RETENTION_DAYS = 15

# === STEP 1: CLEAN OLD ENTRIES IF FILE EXISTS ===
if os.path.exists(LOG_FILE):
    cutoff_date = datetime.now() - timedelta(days=RETENTION_DAYS)
    with open(LOG_FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    with open(LOG_FILE, 'w', encoding='utf-8') as f:
        for line in lines:
            try:
                timestamp_str = line.split(' [')[0]
                log_date = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S,%f')
                if log_date >= cutoff_date:
                    f.write(line)
            except Exception:
                # Write malformed or non-log lines (optional)
                f.write(line)

# === STEP 2: SETUP LOGGER TO WRITE TO FILE AND CONSOLE ===
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Formatter
formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(message)s')

# File handler (append mode)
file_handler = logging.FileHandler(LOG_FILE, mode='a', encoding='utf-8')
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

# Console handler (stdout)
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

# === CLICKHOUSE CONNECTION CONFIGURATION ===
client = Client(
    host='127.0.0.1',
    port=9003,
    user='service_etl',
    # password='',  # uncomment if needed
    database='dw_raw'
)

logging.info("Starting detection of partitions with duplicates on Replacing tables...")

def clean_tuple_expr(expr: str) -> str:
    if not expr:
        return ''  # handle None or empty string
    expr = expr.strip()
    if expr.startswith('tuple(') and expr.endswith(')'):
        return expr[len('tuple('):-1]
    return expr

# === 1. FETCH USER TABLES WITH REPLACING ENGINES ===
tables_query = """
SELECT
    database,
    name AS table_name,
    partition_key,
    primary_key
FROM system.tables
WHERE database NOT IN (
    'system',
    'information_schema',
    'information_schema_cache',
    'INFORMATION_SCHEMA',
    '_temporary_and_external_tables'
)
AND engine LIKE '%Replacing%'
ORDER BY name
"""

try:
    tables = client.execute(tables_query)
except Exception as e:
    logging.error(f"Error fetching table list: {e}")
    exit(1)

for row in tables:
    db, table_name, partition_key, primary_key = row
    partition_key = clean_tuple_expr(partition_key)
    primary_key = clean_tuple_expr(primary_key)

    logging.info(f"Checking {db}.{table_name} | Partition key: {partition_key} | Primary key: {primary_key}")

    # === 2. IDENTIFY PARTITIONS CONTAINING DUPLICATES ===
    dup_query = f"""
        SELECT DISTINCT toString({partition_key}) AS partition
        FROM "{db}"."{table_name}"
        GROUP BY {partition_key}, {primary_key}
        HAVING count(*) > 1
    """

    try:
        partitions = client.execute(dup_query)
    except Exception as e:
        logging.error(f"Error querying {db}.{table_name}: {e}")
        continue

    if not partitions:
        logging.info(f"No duplicate partitions found in {db}.{table_name}")
        continue

    for (part_val,) in partitions:
        optimize_sql = f'OPTIMIZE TABLE "{db}"."{table_name}" PARTITION \'{part_val}\' FINAL'

        try:
            logging.info(f"Executing: {optimize_sql}")
            client.execute(optimize_sql)
        except Exception as e:
            logging.error(f"Error executing OPTIMIZE on {db}.{table_name}, partition {part_val}: {e}")
        else:
            logging.info(f"Successfully optimized: {optimize_sql}")

logging.info("Routine completed successfully.")
