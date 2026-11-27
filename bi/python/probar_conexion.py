import argparse
import os
import sys

import pyodbc

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--servidor", default=os.environ.get("ETL_SERVIDOR", r"LAPTOP-NNHMBL3E"))
    parser.add_argument("--base-dm", default=os.environ.get("ETL_BASE_DM", "DM_Ventas_Libreria"))
    args = parser.parse_args()

    driver = next(
        (d for d in ("ODBC Driver 18 for SQL Server", "ODBC Driver 17 for SQL Server")
         if d in pyodbc.drivers()),
        None,
    )
    if driver is None:
        print("No se encontro ODBC Driver 17 ni 18.")
        return 1

    try:
        conexion = pyodbc.connect(
            f"DRIVER={{{driver}}};"
            f"SERVER={args.servidor};"
            f"DATABASE={args.base_dm};"
            "Trusted_Connection=yes;"
            "TrustServerCertificate=yes;",
            timeout=10,
        )
    except pyodbc.Error as error:
        print("No se pudo conectar:", error)
        return 1

    cursor = conexion.cursor()
    cursor.execute("SELECT DB_NAME()")
    print("Conexion exitosa con SQL Server")
    print("Base de datos:", cursor.fetchone()[0])

    cursor.execute("SELECT OBJECT_ID('dbo.sp_carga_etl'), OBJECT_ID('dbo.etl_log')")
    sp, log = cursor.fetchone()
    print("sp_carga_etl instalado:", "si" if sp else "NO")
    print("etl_log existe:", "si" if log else "NO")

    conexion.close()
    return 0 if (sp and log) else 1


if __name__ == "__main__":
    sys.exit(main())