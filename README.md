# Solución BI y Big Data — Librería Escolar

Este repositorio contiene los scripts SQL, los programas en Python, los datasets sintéticos y el notebook de Databricks necesarios para reproducir de extremo a extremo la solución de **Inteligencia de Negocios (SQL Server + Python + Power BI)** y la solución **Big Data (Databricks + Apache Spark / PySpark)** para una librería escolar.

---

## Antes de empezar, necesitas

* **Para la Parte A (Solución BI):**
  * SQL Server (2019 / 2022 / 2025 o SQL Server Express) abierto y funcionando.
  * SQL Server Management Studio (SSMS).
  * Python 3.10+ instalado en tu computadora y ODBC Driver 17 o 18 para SQL Server.
  * Power BI Desktop (para visualizar el reporte ejecutivo).
* **Para la Parte B (Solución Big Data):**
  * Cuenta activa en **Databricks** (Free Edition / Community / Workspace con Unity Catalog) y un cómputo activo (Serverless o All-Purpose Compute).

---

## PARTE A: Solución BI (SQL Server + ETL en Python)

Este flujo crea la base de datos transaccional, construye el modelo estrella analítico y ejecuta el proceso ETL automatizado que copia y valida las ventas `COMPLETADO` hacia el Data Mart.

### Paso A1: Crear las bases de datos y el modelo estrella en SQL Server

1. Abre **SQL Server Management Studio (SSMS)** y conéctate a tu instancia local (por ejemplo, `.` o `localhost` o `TU-PC\SQLEXPRESS`).
2. Abre y ejecuta los scripts en este **orden estricto**:
   1. `1_creacionOLTP.sql` → Crea la base de datos transaccional `dbVentasLibreria` con sus 7 tablas (`categoria`, `cliente`, `metodoPago`, `producto`, `usuario`, `venta`, `ventaDetalle`).
   2. `2_dataset.original.sql` → Carga los datos originales de la librería en `dbVentasLibreria`.
   3. `1_crearDataMart.sql` → Crea la base analítica `DM_Ventas_Libreria` con su esquema estrella (`dim_cliente`, `dim_metodoPago`, `dim_producto`, `dim_tiempo`, `dim_vendedor`, `fac_ventas` y `etl_log`).
   4. `CARGA_ETL_libreria.sql` → Crea el procedimiento almacenado encargado de la extracción, validación, cálculo de costo/utilidad y carga transaccional.

### Paso A2: Instalar la herramienta que conecta Python con SQL Server

1. Abre **PowerShell** (búscalo en el menú Inicio).
2. Escribe esto y pulsa Enter:

   ```powershell
   python -m pip install pyodbc
   ```

   Si no funciona, usa la ruta completa de tu Python:

   ```powershell
   & "C:\Users\Usuario\AppData\Local\Programs\Python\Python314\python.exe" -m pip install pyodbc
   ```

> Si más adelante ves el error `No module named 'pyodbc'`, significa que te saltaste este paso.

### Paso A3: Escribir el nombre de TU servidor

Los dos programas (`probar_conexion.py` y `automatizar_etl.py`) necesitan saber cómo se llama el SQL Server de tu computadora.

1. Abre **SQL Server Management Studio (SSMS)**.
2. Mira el recuadro **"Server name"** de la ventana de conexión. Ese es tu nombre (por ejemplo: `.` o `MI-PC\SQLEXPRESS`).
3. Abre los dos archivos `.py` y busca esta línea:

   ```python
   SERVIDOR = r"TU-PC\SQLEXPRESS"
   ```

4. Cambia lo que está entre comillas por tu nombre. **No borres la letra `r`** que está antes de las comillas.

> Si ves el error `El servidor no se encuentra o no es accesible`, el nombre está mal escrito.

### Paso A4: Probar que todo está conectado y verificar rutas

1. Ejecuta el archivo `probar_conexion.py`. Si todo está bien, verás:

   ```text
   Conexión exitosa con SQL Server
   ```

2. Asegúrate de mantener cada archivo en su lugar (`scripts/automatizar_etl.py` y `sql/bi/CARGA_ETL_libreria.sql`). Si dejas el archivo `.sql` en la misma carpeta que `automatizar_etl.py`, cambia esta línea dentro del programa:

   ```python
   ARCHIVO_SQL = Path(__file__).resolve().parent / "CARGA_ETL_libreria.sql"
   ```

### Paso A5: Ejecutar el ETL

Ejecuta el archivo `automatizar_etl.py`. Si todo sale bien, verás el mensaje:

```text
ETL EXITOSO
```

Además, se guarda un registro de lo que pasó en la carpeta `logs/` y en la tabla `dbo.etl_log` dentro de `DM_Ventas_Libreria`.

---

## PARTE B: Solución Big Data (Databricks + PySpark)

Este flujo procesa de forma distribuida tres volúmenes sintéticos en formato **Apache Parquet** (`BD01`: 10,000 ventas, `BD02`: 50,000 ventas y `BD03`: 100,000 ventas), eliminando duplicados y calculando indicadores comerciales y tiempos de carga.

### Paso B1: Crear el catálogo, esquema y volumen en Databricks

1. Inicia sesión en **Databricks** y abre el **SQL Editor** o una celda SQL de un notebook.
2. Ejecuta las siguientes instrucciones para habilitar la ruta de almacenamiento en Unity Catalog:

   ```sql
   CREATE CATALOG IF NOT EXISTS solucion_bd;
   CREATE SCHEMA IF NOT EXISTS solucion_bd.datos_bd;
   CREATE VOLUME IF NOT EXISTS solucion_bd.datos_bd.datos_libreria;
   ```

   Esto habilitará la ruta: `/Volumes/solucion_bd/datos_bd/datos_libreria`.

### Paso B2: Subir los datasets Parquet al Volume

1. Descomprime los datasets sintéticos del repositorio si están comprimidos (`datos sintacticos.rar`).
2. En el menú lateral izquierdo de Databricks, entra a **Catalog → `solucion_bd` → `datos_bd` → `datos_libreria`**.
3. Crea tres carpetas dentro del volumen con los nombres exactos: `BD01`, `BD02` y `BD03`.
4. Dentro de cada carpeta, sube (**Upload to this volume**) sus dos archivos Parquet correspondientes:
   * `venta_sintetica.parquet`
   * `ventaDetalle_sintetico.parquet`

### Paso B3: Importar y ejecutar el notebook `Pruebas_Spark_Libreria.ipynb`

1. En el menú lateral izquierdo de Databricks, ve a **Workspace**, entra a tu carpeta de usuario, haz clic en **Import** e importa el archivo `Pruebas_Spark_Libreria.ipynb`.
2. Conecta el notebook a un clúster o cómputo **Serverless** en la esquina superior derecha (**Connect**).
3. Verifica que la primera celda tenga configurada la ruta de tu volumen:

   ```python
   BASE_PATH = "/Volumes/solucion_bd/datos_bd/datos_libreria"
   ```

   *(Si creaste el esquema y volumen dentro de otro catálogo como `workspace` o `main`, actualiza únicamente esta ruta).*

4. Haz clic en **Run all** para ejecutar todo el flujo (exploración, eliminación de duplicados con `dropDuplicates()`, unión de tablas, cálculo de KPIs, pruebas de escalabilidad y gráficos del dashboard **Evidencias**).

### Resultados esperados en Databricks

| Escenario | Ventas limpias | Detalles limpios | Ventas completadas | Unidades vendidas | Importe total (S/) | Utilidad total (S/) | Tiempo ref. (s) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **BD01** | 9,805 | 29,188 | 8,602 | 75,315 | 1,404,655.30 | 574,402.70 | 1.8208 |
| **BD02** | 49,015 | 147,123 | 43,028 | 381,148 | 7,043,626.70 | 2,882,894.30 | 2.0118 |
| **BD03** | 98,032 | 294,130 | 85,978 | 763,100 | 14,118,414.10 | 5,773,798.00 | 2.3500 |

---

## ¿Algo falló?

| Lo que ves | Qué significa | Qué hacer |
| :--- | :--- | :--- |
| `No module named 'pyodbc'` | Falta la herramienta de conexión | Haz el **Paso A2** |
| `El servidor no se encuentra o no es accesible` | El nombre del servidor está mal | Revisa el **Paso A3** |
| `No se encontro el archivo ... .sql` | El archivo SQL no está en su lugar | Revisa el **Paso A4** |
| `PATH_NOT_FOUND` en Databricks | Las carpetas `BD01`–`BD03` o los `.parquet` no coinciden con `BASE_PATH` | Verifica mayúsculas/minúsculas en el Volume (**Paso B2**) |
| Error de permisos creando catálogo en Databricks | Tu cuenta no permite crear catálogos nuevos | Crea el esquema y volumen dentro de `workspace` o `main` y actualiza `BASE_PATH` |