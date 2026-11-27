import argparse
import logging
import os
import sys
from datetime import datetime
from pathlib import Path

import pyodbc

CARPETA_LOGS = Path(__file__).resolve().parent / "logs"
CARPETA_LOGS.mkdir(exist_ok=True)
ARCHIVO_LOG = CARPETA_LOGS / f"etl_{datetime.now():%Y%m%d_%H%M%S}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(ARCHIVO_LOG, encoding="utf-8"),
    ],
)


def leer_argumentos():
    parser = argparse.ArgumentParser(description="Ejecuta sp_carga_etl en SQL Server.")
    parser.add_argument(
        "--servidor",
        default=os.environ.get("ETL_SERVIDOR", r"LAPTOP-NNHMBL3E"),
        help="Servidor SQL Server (o variable de entorno ETL_SERVIDOR).",
    )
    parser.add_argument(
        "--base-dm",
        default=os.environ.get("ETL_BASE_DM", "DM_Ventas_Libreria"),
        help="Base del Data Mart donde esta sp_carga_etl.",
    )
    return parser.parse_args()


def elegir_driver():
    drivers = pyodbc.drivers()
    for nombre in ("ODBC Driver 18 for SQL Server", "ODBC Driver 17 for SQL Server"):
        if nombre in drivers:
            return nombre
    raise RuntimeError("No se encontro ODBC Driver 17 ni 18.")


def ejecutar_etl(servidor, base_dm):
    conexion = None
    try:
        logging.info("Iniciando ETL en %s / %s", servidor, base_dm)

        conexion = pyodbc.connect(
            f"DRIVER={{{elegir_driver()}}};"
            f"SERVER={servidor};"
            f"DATABASE={base_dm};"
            "Trusted_Connection=yes;"
            "TrustServerCertificate=yes;",
            autocommit=True,  # la transaccion la maneja el procedimiento
            timeout=20,
        )
        cursor = conexion.cursor()
        logging.info("Conexion establecida con %s", servidor)

        # Toda la logica del ETL esta en el procedimiento almacenado.
        cursor.execute("EXEC dbo.sp_carga_etl")
        while cursor.nextset():
            pass

        # Resultado registrado por el procedimiento en etl_log.
        cursor.execute(
            """
            SELECT TOP 1 estado, lineas_origen, lineas_destino, lineas_rechazadas,
                   transacciones_destino, ventas_destino, costo_destino,
                   utilidad_destino, duracion_ms, mensaje
            FROM dbo.etl_log
            ORDER BY id_log DESC
            """
        )
        fila = cursor.fetchone()

        if fila is None or fila.estado != "EXITOSO":
            raise RuntimeError("sp_carga_etl no registro una ejecucion exitosa en etl_log.")

        logging.info(
            "ETL EXITOSO: %s lineas, %s transacciones (rechazadas: %s)",
            fila.lineas_destino, fila.transacciones_destino, fila.lineas_rechazadas,
        )
        logging.info(
            "Ventas: S/ %s | Costo: S/ %s | Utilidad: S/ %s",
            fila.ventas_destino, fila.costo_destino, fila.utilidad_destino,
        )
        filas_por_seg = (
            fila.lineas_destino / (fila.duracion_ms / 1000) if fila.duracion_ms else 0
        )
        logging.info("Duracion: %s ms (%.0f filas/s)", fila.duracion_ms, filas_por_seg)
        logging.info(fila.mensaje)
        return 0

    except Exception as error:
        # Si el procedimiento fallo, ya hizo ROLLBACK y registro el error en etl_log.
        logging.error("La carga se cancelo. Detalle: %s", error)
        return 1

    finally:
        if conexion is not None:
            conexion.close()
        logging.info("Registro guardado en: %s", ARCHIVO_LOG)


if __name__ == "__main__":
    args = leer_argumentos()
    sys.exit(ejecutar_etl(args.servidor, args.base_dm))