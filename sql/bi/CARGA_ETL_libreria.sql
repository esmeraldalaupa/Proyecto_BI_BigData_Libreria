USE DM_Ventas_Libreria;
GO
--limpieza
DELETE FROM fac_ventas;
GO
DELETE FROM dim_cliente;
DELETE FROM dim_producto;
DELETE FROM dim_vendedor;
DELETE FROM dim_metodoPago;
DELETE FROM dim_tiempo;
GO
DBCC CHECKIDENT ('dim_cliente', RESEED, 0);
DBCC CHECKIDENT ('dim_producto', RESEED, 0);
DBCC CHECKIDENT ('dim_vendedor', RESEED, 0);
DBCC CHECKIDENT ('dim_metodoPago', RESEED, 0);
DBCC CHECKIDENT ('fac_ventas', RESEED, 0);
GO
---

--DIMENSION CLIENTE
INSERT INTO dim_cliente
(pk_cliente, dni, nombre, telefono)
SELECT
idCliente,
dni,
nombre + ' ' + apellido,
telefono
FROM dbVentasLibreria.dbo.cliente;
GO
--DIMENSION PRODUCTO
INSERT INTO dim_producto
(pk_producto, codigo, nombre, categoria)
SELECT
p.idProducto,
p.codigo,
p.nombre,
c.nombre
FROM dbVentasLibreria.dbo.producto p
INNER JOIN dbVentasLibreria.dbo.categoria c
ON p.fkCategoria = c.idCategoria;
GO

--DIMENSION VENDEDOR
INSERT INTO dim_vendedor
(pk_vendedor, nombre, usuario)
SELECT
idUsuario,
nombre + ' ' + apellido,
usuario
FROM dbVentasLibreria.dbo.usuario
WHERE rol = 'VENDEDOR';
GO

--DIMENSION METODO DE PAGO
INSERT INTO dim_metodoPago
(pk_metodoP, nombreMetodo)
SELECT
idMetodoPago,
nombre
FROM dbVentasLibreria.dbo.metodoPago;
GO

--DIMENSION TIEMPO
DECLARE @fechaInicio DATE;
DECLARE @fechaFin DATE;
SELECT
@fechaInicio = MIN(CAST(fecha AS DATE)),
@fechaFin = MAX(CAST(fecha AS DATE))
FROM dbVentasLibreria.dbo.venta;
WHILE @fechaInicio <= @fechaFin
BEGIN
INSERT INTO dim_tiempo
(fecha, anio, mes, diaMes, diaSemana, trimestre)
VALUES
(@fechaInicio,
 YEAR(@fechaInicio),
 MONTH(@fechaInicio),
 DAY(@fechaInicio),
 DATENAME(WEEKDAY, @fechaInicio),
 DATEPART(QUARTER, @fechaInicio));
SET @fechaInicio = DATEADD(DAY, 1, @fechaInicio);
END;
GO

--CARGAR EN LA TABLA DE HECHOS
INSERT INTO fac_ventas
(id_cliente,
id_producto,
id_vendedor,
id_metodoP,
fecha,
pk_venta,
cantidad,
subTotal,
costo,
utilidad)
SELECT
DC.id_cliente,
 DP.id_producto,
DV.id_vendedor,
DM.id_metodoP,
CAST(V.fecha AS DATE),
V.idVenta,
D.cantidad,
D.cantidad * D.precioVenta,
D.cantidad * D.costoUnitario,
D.cantidad * (D.precioVenta - D.costoUnitario)
FROM dbVentasLibreria.dbo.venta V
INNER JOIN dbVentasLibreria.dbo.ventaDetalle D
ON V.idVenta = D.fkVenta
INNER JOIN dim_cliente DC
ON DC.pk_cliente = V.fkCliente
INNER JOIN dim_producto DP
ON DP.pk_producto = D.fkProducto
INNER JOIN dim_vendedor DV
ON DV.pk_vendedor = V.fkUsuario
INNER JOIN dim_metodoPago DM
ON DM.pk_metodoP = V.fkMetodoPago
WHERE V.estado = 'COMPLETADO';
GO
