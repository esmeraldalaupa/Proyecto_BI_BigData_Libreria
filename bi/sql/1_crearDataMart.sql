-- entorno Data Mart (dimensiones, tabla de hechos y bitacora del ETL).

USE master;
GO

IF DB_ID('DM_Ventas_Libreria') IS NULL
    CREATE DATABASE DM_Ventas_Libreria;
GO

USE DM_Ventas_Libreria;
GO

IF OBJECT_ID('dbo.fac_ventas') IS NULL
BEGIN
    CREATE TABLE dim_cliente
    (
        id_cliente INT PRIMARY KEY IDENTITY,
        pk_cliente INT,
        dni CHAR(8),
        nombre VARCHAR(200),
        telefono VARCHAR(15)
    );

    CREATE TABLE dim_producto
    (
        id_producto INT PRIMARY KEY IDENTITY,
        pk_producto INT,
        codigo VARCHAR(30),
        nombre VARCHAR(200),
        categoria VARCHAR(80)
    );

    CREATE TABLE dim_tiempo
    (
        fecha DATE PRIMARY KEY,
        anio SMALLINT,
        mes SMALLINT,
        diaMes SMALLINT,
        diaSemana VARCHAR(15),
        trimestre SMALLINT
    );

    CREATE TABLE dim_vendedor
    (
        id_vendedor INT PRIMARY KEY IDENTITY,
        pk_vendedor INT,
        nombre VARCHAR(200),
        usuario VARCHAR(50)
    );

    CREATE TABLE dim_metodoPago
    (
        id_metodoP INT PRIMARY KEY IDENTITY,
        pk_metodoP INT,
        nombreMetodo VARCHAR(50)
    );

    CREATE TABLE fac_ventas
    (
        id_venta INT PRIMARY KEY IDENTITY,

        id_cliente INT REFERENCES dim_cliente,
        id_producto INT REFERENCES dim_producto,
        id_vendedor INT REFERENCES dim_vendedor,
        id_metodoP INT REFERENCES dim_metodoPago,
        fecha DATE REFERENCES dim_tiempo,

        pk_venta INT,

        cantidad INT,
        subTotal MONEY,
        costo MONEY,
        utilidad MONEY
    );
END
GO

-- Registro de logs
IF OBJECT_ID('dbo.etl_log') IS NULL
    CREATE TABLE dbo.etl_log
    (
        id_log INT IDENTITY PRIMARY KEY,
        fecha_inicio DATETIME2 NOT NULL,
        fecha_fin DATETIME2 NOT NULL,
        estado VARCHAR(10) NOT NULL,
        lineas_origen INT NULL,
        lineas_destino INT NULL,
        lineas_rechazadas INT NULL,
        transacciones_origen INT NULL,
        transacciones_destino INT NULL,
        ventas_origen DECIMAL(14,2) NULL,
        ventas_destino DECIMAL(14,2) NULL,
        costo_origen DECIMAL(14,2) NULL,
        costo_destino DECIMAL(14,2) NULL,
        utilidad_origen DECIMAL(14,2) NULL,
        utilidad_destino DECIMAL(14,2) NULL,
        duracion_ms INT NULL,
        mensaje NVARCHAR(500) NULL
    );
GO