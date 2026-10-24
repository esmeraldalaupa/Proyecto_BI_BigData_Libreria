# Cómo ejecutar el ETL (paso a paso)

Este programa copia las ventas de la base de datos original a la base de datos de análisis (el Data Mart) y revisa que todo haya quedado bien.

## Antes de empezar, necesitas
- SQL Server (o SQL Server Express) abierto y funcionando.
- Las dos bases de datos ya creadas: `dbVentasLibreria` y `DM_Ventas_Libreria`.
- Python instalado en tu computadora.

---

## Paso 1: Instalar la herramienta que conecta Python con SQL Server

1. Abre **PowerShell** (búscalo en el menú Inicio).
2. Escribe esto y pulsa Enter:

   ```
   python -m pip install pyodbc
   ```

   Si no funciona, usa la ruta completa de tu Python:

   ```
   & "C:\Users\Usuario\AppData\Local\Programs\Python\Python314\python.exe" -m pip install pyodbc
   ```

> Si más adelante ves el error `No module named 'pyodbc'`, significa que te saltaste este paso.

---

## Paso 2: Escribir el nombre de TU servidor

Los dos programas (`probar_conexion.py` y `automatizar_etl.py`) necesitan saber cómo se llama el SQL Server de tu computadora.

1. Abre **SQL Server Management Studio (SSMS)**.
2. Mira el recuadro **"Server name"** de la ventana de conexión. Ese es tu nombre. Por ejemplo: `MI-PC\SQLEXPRESS`.
3. Abre los dos archivos `.py` y busca esta línea:

   ```
   SERVIDOR = r"TU-PC\SQLEXPRESS"
   ```

4. Cambia lo que está entre comillas por tu nombre. No borres la letra `r` que está antes de las comillas.

> Si ves el error `El servidor no se encuentra o no es accesible`, el nombre está mal escrito.

---

## Paso 3: Probar que todo está conectado

Ejecuta el archivo `probar_conexion.py`.

Si todo está bien, verás:

```
Conexión exitosa con SQL Server
```

Si no sale ese mensaje, vuelve al paso 1 o al paso 2.

---

## Paso 4: Poner cada archivo en su lugar

El programa necesita encontrar el archivo `CARGA_ETL_libreria.sql`. Tienes dos opciones:

**Opción A (recomendada):** ordena tus carpetas así, y no cambies nada del código:

```
proyecto/
├── scripts/
│   └── automatizar_etl.py
└── sql/
    └── bi/
        └── CARGA_ETL_libreria.sql
```

**Opción B:** deja el archivo `.sql` en la misma carpeta que `automatizar_etl.py` y cambia esta línea dentro del programa:

```
ARCHIVO_SQL = Path(__file__).resolve().parent / "CARGA_ETL_libreria.sql"
```

> Si ves el error `No se encontro el archivo ... CARGA_ETL_libreria.sql`, el archivo no está donde el programa lo busca.

---

## Paso 5: Ejecutar el ETL

Ejecuta el archivo `automatizar_etl.py`.

Si todo sale bien, verás el mensaje:

```
ETL EXITOSO
```

Además, se guarda un registro de lo que pasó en la carpeta `logs/`. Cada vez que lo ejecutes se crea un archivo nuevo.

---

## ¿Algo falló?

| Lo que ves | Qué significa | Qué hacer |
| --- | --- | --- |
| `No module named 'pyodbc'` | Falta la herramienta de conexión | Haz el paso 1 |
| `El servidor no se encuentra o no es accesible` | El nombre del servidor está mal | Revisa el paso 2 |
| `No se encontro el archivo ... .sql` | El archivo SQL no está en su lugar | Revisa el paso 4 |