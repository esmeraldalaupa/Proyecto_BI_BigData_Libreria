import pyodbc

# Reemplaza por el nombre del servidor usado
SERVIDOR = r"LAPTOP-NNHMBL3E"

conexion = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={SERVIDOR};"
    "DATABASE=DM_Ventas_Libreria;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;",
    timeout=10
)

cursor = conexion.cursor()

cursor.execute("SELECT DB_NAME()")
base_datos = cursor.fetchone()[0]

print("Conexión exitosa con SQL Server")
print("Base de datos:", base_datos)

conexion.close()
