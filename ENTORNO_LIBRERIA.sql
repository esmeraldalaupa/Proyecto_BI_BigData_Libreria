USE master;
GO

CREATE DATABASE DM_Ventas_Libreria;
GO

USE DM_Ventas_Libreria;
GO


CREATE TABLE dim_cliente
(
    id_cliente INT PRIMARY KEY IDENTITY,
    pk_cliente INT,
    dni CHAR(8),
    nombre VARCHAR(200),
    telefono VARCHAR(15)
);
GO

CREATE TABLE dim_producto
(
    id_producto INT PRIMARY KEY IDENTITY,
    pk_producto INT,
    codigo VARCHAR(30),
    nombre VARCHAR(200),
    categoria VARCHAR(80)
);
GO

CREATE TABLE dim_tiempo
(
    fecha DATE PRIMARY KEY,
    anio SMALLINT,
    mes SMALLINT,
    diaMes SMALLINT,
    diaSemana VARCHAR(15),
    trimestre SMALLINT
);
GO


CREATE TABLE dim_vendedor
(
    id_vendedor INT PRIMARY KEY IDENTITY,
    pk_vendedor INT,
    nombre VARCHAR(200),
    usuario VARCHAR(50)
);
GO


CREATE TABLE dim_metodoPago
(
    id_metodoP INT PRIMARY KEY IDENTITY,
    pk_metodoP INT,
    nombreMetodo VARCHAR(50)
);
GO

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
GO