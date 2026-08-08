"""
Convert every sheet in an .xlsx file into its own table in a SQLite .db file.

Just set XLSX_PATH below and run this script. The .db file will be created
in the same folder as this script, with the same base name as the xlsx
(e.g. dataset.xlsx -> dataset.db).

Requires: pandas, openpyxl
    pip install pandas openpyxl
"""

import re
import sqlite3
from pathlib import Path
import pandas as pd

# ---- Add the path of the xlsx file and run ----
XLSX_PATH = "./Commerce.xlsx"
# -----------------------------------------------


def sanitize_table_name(name: str) -> str:
    """Turn a sheet name into a safe SQLite table name."""
    name = name.strip()
    name = re.sub(r"\W+", "_", name)      # replace non-alphanumeric chars with _
    name = re.sub(r"^_+|_+$", "", name)   # trim leading/trailing underscores
    if not name or name[0].isdigit():
        name = f"t_{name}"
    return name.lower()


def xlsx_to_sqlite(xlsx_path: str, db_path: str) -> list[str]:
    xlsx_path = Path(xlsx_path)
    db_path = Path(db_path)

    # Read all sheets into a dict of {sheet_name: DataFrame}
    sheets = pd.read_excel(xlsx_path, sheet_name=None)

    conn = sqlite3.connect(db_path)
    created_tables = []

    try:
        for sheet_name, df in sheets.items():
            table_name = sanitize_table_name(sheet_name)

            # Also sanitize column names so they're valid SQL identifiers
            df.columns = [sanitize_table_name(str(c)) for c in df.columns]

            df.to_sql(table_name, conn, if_exists="replace", index=False)
            created_tables.append(table_name)
    finally:
        conn.commit()
        conn.close()

    return created_tables


def main():
    xlsx_path = Path(XLSX_PATH)
    if not xlsx_path.exists():
        print(f"Could not find xlsx file: {xlsx_path.resolve()}")
        return

    db_path = xlsx_path.with_suffix(".db")
    tables = xlsx_to_sqlite(xlsx_path, db_path)

    print(f"\nCreated database: {db_path.resolve()}")
    print(f"Tables ({len(tables)}):")
    for t in tables:
        print(f"  - {t}")


if __name__ == "__main__":
    main()
