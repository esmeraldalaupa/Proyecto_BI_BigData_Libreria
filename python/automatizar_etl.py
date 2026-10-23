import logging
import re
import sys
from datetime import datetime
from decimal import Decimal
from pathlib import Path

import pyodbc

# CONFIGURACION
SERVIDOR = r"LAPTOP-NNHMBL3E"
BASE_DM = "DM_Ventas_Libreria"
BASE_OLTP = "dbVentasLibreria"

ARCHIVO_SQL = Path(__file__).resolve().parent / "CARGA_ETL_libreria.sql"

CARPETA_LOGS = Path(__file__).resolve().parent / "logs"
CARPETA_LOGS.mkdir(exist_ok=True)

ARCHIVO_LOG = CARPETA_LOGS / f"etl_{datetime.now():%Y%m%d_%H%M%S}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(ARCHIVO_LOG, encoding="utf-8")
    ]
)

# CONSULTAR DATOS
def consultar_resumen(cursor, origen):

    if origen:
        cursor.execute(f"""
            SELECT
                COUNT(*) AS lineas,
                COUNT(DISTINCT V.idVenta) AS transacciones,

                COALESCE(SUM(D.cantidad * D.precioVenta), 0)
                    AS ventas,

                COALESCE(SUM(D.cantidad * D.costoUnitario), 0)
                    AS costo,

                COALESCE(
                    SUM(D.cantidad *
                        (D.precioVenta - D.costoUnitario)), 0
                ) AS utilidad,

                COALESCE(SUM(
                    CASE
                        WHEN D.cantidad IS NULL
                          OR D.cantidad <= 0
                          OR D.precioVenta IS NULL
                          OR D.precioVenta <= 0
                          OR D.costoUnitario IS NULL
                          OR D.costoUnitario < 0
                        THEN 1 ELSE 0
                    END
                ), 0) AS invalidos

            FROM {BASE_OLTP}.dbo.venta V
            INNER JOIN {BASE_OLTP}.dbo.ventaDetalle D
                ON D.fkVenta = V.idVenta

            WHERE V.estado = 'COMPLETADO'
        """)

    else:
        cursor.execute("""
            SELECT
                COUNT(*) AS lineas,
                COUNT(DISTINCT pk_venta) AS transacciones,
                COALESCE(SUM(subTotal), 0) AS ventas,
                COALESCE(SUM(costo), 0) AS costo,
                COALESCE(SUM(utilidad), 0) AS utilidad,

                COALESCE(SUM(
                    CASE
                        WHEN id_cliente IS NULL
                          OR id_producto IS NULL
                          OR id_vendedor IS NULL
                          OR id_metodoP IS NULL
                          OR fecha IS NULL
                          OR pk_venta IS NULL
                          OR cantidad IS NULL
                          OR cantidad <= 0
                          OR subTotal IS NULL
                          OR costo IS NULL
                          OR utilidad IS NULL
                        THEN 1 ELSE 0
                    END
                ), 0) AS invalidos

            FROM dbo.fac_ventas
        """)

    return cursor.fetchone()

# VALIDAR DATOS ORIGINALES
def validar_origen(cursor):

    # Ventas completadas sin detalles
    cursor.execute(f"""
        SELECT COUNT(*)
        FROM {BASE_OLTP}.dbo.venta V
        WHERE V.estado = 'COMPLETADO'
          AND NOT EXISTS (
              SELECT 1
              FROM {BASE_OLTP}.dbo.ventaDetalle D
              WHERE D.fkVenta = V.idVenta
          )
    """)

    if cursor.fetchone()[0]:
        raise ValueError(
            "Hay ventas completadas sin detalle en el OLTP."
        )

    # Comprobar relaciones entre tablas
    cursor.execute(f"""
        SELECT COUNT(*)

        FROM {BASE_OLTP}.dbo.venta V

        JOIN {BASE_OLTP}.dbo.ventaDetalle D
            ON D.fkVenta = V.idVenta

        LEFT JOIN {BASE_OLTP}.dbo.cliente C
            ON C.idCliente = V.fkCliente

        LEFT JOIN {BASE_OLTP}.dbo.producto P
            ON P.idProducto = D.fkProducto

        LEFT JOIN {BASE_OLTP}.dbo.categoria CAT
            ON CAT.idCategoria = P.fkCategoria

        LEFT JOIN {BASE_OLTP}.dbo.usuario U
            ON U.idUsuario = V.fkUsuario

        LEFT JOIN {BASE_OLTP}.dbo.metodoPago MP
            ON MP.idMetodoPago = V.fkMetodoPago

        WHERE V.estado = 'COMPLETADO'
          AND (
              C.idCliente IS NULL
              OR P.idProducto IS NULL
              OR CAT.idCategoria IS NULL
              OR U.idUsuario IS NULL
              OR U.rol IS NULL
              OR U.rol <> 'VENDEDOR'
              OR MP.idMetodoPago IS NULL
          )
    """)

    if cursor.fetchone()[0]:
        raise ValueError(
            "Hay ventas con relaciones faltantes o vendedor incorrecto."
        )

# COMPARAR ORIGEN Y DESTINO
def validar_coincidencia(oltp, dm):

    if oltp.invalidos or dm.invalidos:
        raise ValueError(
            "Se encontraron cantidades, importes o relaciones invalidas."
        )

    for nombre in ("lineas", "transacciones"):

        if getattr(oltp, nombre) != getattr(dm, nombre):
            raise ValueError(
                f"No coinciden las {nombre} del OLTP y el Data Mart."
            )

    for nombre in ("ventas", "costo", "utilidad"):

        diferencia = abs(
            Decimal(str(getattr(oltp, nombre))) -
            Decimal(str(getattr(dm, nombre)))
        )

        if diferencia > Decimal("0.01"):
            raise ValueError(
                f"No coincide el importe de {nombre}. "
                f"Diferencia: {diferencia}"
            )

# EJECUTAR ETL
def ejecutar_etl():

    conexion = None

    try:
        logging.info("Iniciando ETL para %s", BASE_DM)

        # Verificar existencia del archivo SQL
        if not ARCHIVO_SQL.is_file():
            raise FileNotFoundError(
                f"No se encontro el archivo: {ARCHIVO_SQL}"
            )

        # Buscar el controlador ODBC instalado
        drivers = pyodbc.drivers()

        driver = next(
            (
                d for d in (
                    "ODBC Driver 18 for SQL Server",
                    "ODBC Driver 17 for SQL Server"
                )
                if d in drivers
            ),
            None
        )

        if driver is None:
            raise RuntimeError(
                "No se encontro ODBC Driver 17 ni 18."
            )

        # Conectar a SQL Server
        conexion = pyodbc.connect(
            f"DRIVER={{{driver}}};"
            f"SERVER={SERVIDOR};"
            f"DATABASE={BASE_DM};"
            "Trusted_Connection=yes;"
            "TrustServerCertificate=yes;",
            autocommit=False,
            timeout=20
        )

        cursor = conexion.cursor()
        cursor.execute("SET XACT_ABORT ON; SET NOCOUNT ON;")

        logging.info(
            "Conexion establecida con %s", SERVIDOR
        )

        # Leer y validar datos de origen
        origen = consultar_resumen(cursor, origen=True)

        logging.info(
            "OLTP: %s lineas, %s transacciones, S/ %s",
            origen.lineas,
            origen.transacciones,
            origen.ventas
        )

        if origen.lineas == 0 or origen.invalidos:
            raise ValueError(
                "El OLTP no tiene ventas completadas validas."
            )

        validar_origen(cursor)

        # Leer archivo ETL original
        texto = ARCHIVO_SQL.read_text(
            encoding="utf-8-sig"
        )

        # Dividir instrucciones GO del archivo SQL
        lotes = re.split(
            r"(?im)^\s*GO\s*(?:--[^\r\n]*)?$",
            texto
        )

        logging.info(
            "Ejecutando archivo: %s",
            ARCHIVO_SQL.name
        )

        # Ejecutar instrucciones SQL
        for lote in lotes:

            if lote.strip():
                cursor.execute(lote)

                while cursor.nextset():
                    pass

        # Comprobar datos cargados
        destino = consultar_resumen(cursor, origen=False)

        validar_coincidencia(origen, destino)

        # Confirmar carga
        conexion.commit()

        logging.info(
            "ETL EXITOSO: %s lineas, %s transacciones",
            destino.lineas,
            destino.transacciones
        )

        logging.info(
            "Ventas: S/ %s | Costo: S/ %s | Utilidad: S/ %s",
            destino.ventas,
            destino.costo,
            destino.utilidad
        )

        logging.info(
            "OLTP y Data Mart coinciden. Carga confirmada."
        )

        return 0

    except Exception as error:

        # Cancelar cambios si ocurre un error
        if conexion is not None:
            try:
                conexion.rollback()
                logging.error(
                    "La carga se cancelo para evitar datos incompletos."
                )
            except Exception:
                logging.error(
                    "No se pudo comprobar la cancelacion."
                )

        logging.exception(
            "ERROR durante el ETL: %s", error
        )

        return 1

    finally:

        if conexion is not None:
            conexion.close()

        logging.info(
            "Registro guardado en: %s", ARCHIVO_LOG
        )

# INICIAR PROGRAMA
if __name__ == "__main__":
    sys.exit(ejecutar_etl())
