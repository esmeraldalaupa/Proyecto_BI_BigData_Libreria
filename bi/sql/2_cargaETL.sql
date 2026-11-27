-- carga etl

USE DM_Ventas_Libreria;
GO

CREATE OR ALTER PROCEDURE dbo.sp_carga_etl
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @inicio DATETIME2 = SYSDATETIME();

    -- Resumen del origen (OLTP)
    DECLARE @lin_o INT = NULL, @trx_o INT = NULL, @inv INT = NULL;
    DECLARE @ven_o DECIMAL(14,2) = NULL, @cos_o DECIMAL(14,2) = NULL, @uti_o DECIMAL(14,2) = NULL;

    -- Resumen del destino (Data Mart)
    DECLARE @lin_d INT = NULL, @trx_d INT = NULL, @inv_d INT = NULL;
    DECLARE @ven_d DECIMAL(14,2) = NULL, @cos_d DECIMAL(14,2) = NULL, @uti_d DECIMAL(14,2) = NULL;

    -- Conteos de dimensiones (origen vs destino)
    DECLARE @n_cli_o INT, @n_cli_d INT, @n_pro_o INT, @n_pro_d INT;
    DECLARE @n_ven_o INT, @n_ven_d INT, @n_met_o INT, @n_met_d INT;
    DECLARE @n_dias_o INT, @n_dias_d INT;

    DECLARE @msg NVARCHAR(500);

    BEGIN TRY

        --validacion del origen
        SELECT
            @lin_o = COUNT(*),
            @trx_o = COUNT(DISTINCT V.idVenta),
            @ven_o = COALESCE(SUM(D.cantidad * D.precioVenta), 0),
            @cos_o = COALESCE(SUM(D.cantidad * D.costoUnitario), 0),
            @uti_o = COALESCE(SUM(D.cantidad * (D.precioVenta - D.costoUnitario)), 0),
            @inv   = COALESCE(SUM(CASE
                        WHEN D.cantidad IS NULL OR D.cantidad <= 0
                          OR D.precioVenta IS NULL OR D.precioVenta <= 0
                          OR D.costoUnitario IS NULL OR D.costoUnitario < 0
                        THEN 1 ELSE 0 END), 0)
        FROM dbVentasLibreria.dbo.venta V
        INNER JOIN dbVentasLibreria.dbo.ventaDetalle D
            ON D.fkVenta = V.idVenta
        WHERE V.estado = 'COMPLETADO';

        IF @lin_o = 0
            THROW 50001, 'El OLTP no tiene ventas completadas validas (origen vacio).', 1;

        IF @inv > 0
            THROW 50002, 'El OLTP tiene lineas con cantidades, precios o costos invalidos.', 1;

        IF EXISTS (
            SELECT 1
            FROM dbVentasLibreria.dbo.venta V
            WHERE V.estado = 'COMPLETADO'
              AND NOT EXISTS (SELECT 1
                              FROM dbVentasLibreria.dbo.ventaDetalle D
                              WHERE D.fkVenta = V.idVenta)
        )
            THROW 50003, 'Hay ventas completadas sin detalle en el OLTP.', 1;

        IF EXISTS (
            SELECT 1
            FROM dbVentasLibreria.dbo.venta V
            INNER JOIN dbVentasLibreria.dbo.ventaDetalle D ON D.fkVenta = V.idVenta
            LEFT JOIN dbVentasLibreria.dbo.cliente C     ON C.idCliente = V.fkCliente
            LEFT JOIN dbVentasLibreria.dbo.producto P    ON P.idProducto = D.fkProducto
            LEFT JOIN dbVentasLibreria.dbo.categoria CAT ON CAT.idCategoria = P.fkCategoria
            LEFT JOIN dbVentasLibreria.dbo.usuario U     ON U.idUsuario = V.fkUsuario
            LEFT JOIN dbVentasLibreria.dbo.metodoPago MP ON MP.idMetodoPago = V.fkMetodoPago
            WHERE V.estado = 'COMPLETADO'
              AND (C.idCliente IS NULL OR P.idProducto IS NULL OR CAT.idCategoria IS NULL
                   OR U.idUsuario IS NULL OR U.rol <> 'VENDEDOR' OR MP.idMetodoPago IS NULL)
        )
            THROW 50004, 'Hay ventas con relaciones faltantes o con un usuario que no es VENDEDOR.', 1;

        -- Una venta completada no puede tener fecha futura.
        IF EXISTS (
            SELECT 1
            FROM dbVentasLibreria.dbo.venta V
            WHERE V.estado = 'COMPLETADO'
              AND V.fecha > SYSDATETIME()
        )
            THROW 50011, 'Hay ventas completadas con fecha futura en el OLTP.', 1;

        -- Carga
        BEGIN TRANSACTION;

        -- 1. limpieza
        DELETE FROM fac_ventas;
        DELETE FROM dim_cliente;
        DELETE FROM dim_producto;
        DELETE FROM dim_vendedor;
        DELETE FROM dim_metodoPago;
        DELETE FROM dim_tiempo;

        DBCC CHECKIDENT ('dim_cliente', RESEED, 0) WITH NO_INFOMSGS;
        DBCC CHECKIDENT ('dim_producto', RESEED, 0) WITH NO_INFOMSGS;
        DBCC CHECKIDENT ('dim_vendedor', RESEED, 0) WITH NO_INFOMSGS;
        DBCC CHECKIDENT ('dim_metodoPago', RESEED, 0) WITH NO_INFOMSGS;
        DBCC CHECKIDENT ('fac_ventas', RESEED, 0) WITH NO_INFOMSGS;

        -- 2. ordenar datos
        INSERT INTO dim_cliente (pk_cliente, dni, nombre, telefono)
        SELECT idCliente, dni, nombre + ' ' + apellido, telefono
        FROM dbVentasLibreria.dbo.cliente;

        INSERT INTO dim_producto (pk_producto, codigo, nombre, categoria)
        SELECT p.idProducto, p.codigo, p.nombre, c.nombre
        FROM dbVentasLibreria.dbo.producto p
        INNER JOIN dbVentasLibreria.dbo.categoria c
            ON p.fkCategoria = c.idCategoria;

        INSERT INTO dim_vendedor (pk_vendedor, nombre, usuario)
        SELECT idUsuario, nombre + ' ' + apellido, usuario
        FROM dbVentasLibreria.dbo.usuario
        WHERE rol = 'VENDEDOR';

        INSERT INTO dim_metodoPago (pk_metodoP, nombreMetodo)
        SELECT idMetodoPago, nombre
        FROM dbVentasLibreria.dbo.metodoPago;

        DECLARE @fechaInicio DATE, @fechaFin DATE;
        SELECT @fechaInicio = MIN(CAST(fecha AS DATE)),
               @fechaFin    = MAX(CAST(fecha AS DATE))
        FROM dbVentasLibreria.dbo.venta;

        SET @n_dias_o = DATEDIFF(DAY, @fechaInicio, @fechaFin) + 1;   -- dias esperados en dim_tiempo

        WHILE @fechaInicio <= @fechaFin
        BEGIN
            INSERT INTO dim_tiempo (fecha, anio, mes, diaMes, diaSemana, trimestre)
            VALUES (@fechaInicio,
                    YEAR(@fechaInicio),
                    MONTH(@fechaInicio),
                    DAY(@fechaInicio),
                    DATENAME(WEEKDAY, @fechaInicio),
                    DATEPART(QUARTER, @fechaInicio));
            SET @fechaInicio = DATEADD(DAY, 1, @fechaInicio);
        END;

        -- Tabla de hechos (solo ventas COMPLETADAS)
        INSERT INTO fac_ventas
            (id_cliente, id_producto, id_vendedor, id_metodoP, fecha,
             pk_venta, cantidad, subTotal, costo, utilidad)
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
        INNER JOIN dbVentasLibreria.dbo.ventaDetalle D ON V.idVenta = D.fkVenta
        INNER JOIN dim_cliente DC    ON DC.pk_cliente = V.fkCliente
        INNER JOIN dim_producto DP   ON DP.pk_producto = D.fkProducto
        INNER JOIN dim_vendedor DV   ON DV.pk_vendedor = V.fkUsuario
        INNER JOIN dim_metodoPago DM ON DM.pk_metodoP = V.fkMetodoPago
        WHERE V.estado = 'COMPLETADO';

        -- 3. conciliacion origen vs destino
        SELECT
            @lin_d = COUNT(*),
            @trx_d = COUNT(DISTINCT pk_venta),
            @ven_d = COALESCE(SUM(subTotal), 0),
            @cos_d = COALESCE(SUM(costo), 0),
            @uti_d = COALESCE(SUM(utilidad), 0),
            @inv_d = COALESCE(SUM(CASE
                        WHEN id_cliente IS NULL OR id_producto IS NULL
                          OR id_vendedor IS NULL OR id_metodoP IS NULL
                          OR fecha IS NULL OR pk_venta IS NULL
                          OR cantidad IS NULL OR cantidad <= 0
                          OR subTotal IS NULL OR costo IS NULL OR utilidad IS NULL
                          OR subTotal <= 0 OR costo < 0
                          OR ABS(utilidad - (subTotal - costo)) > 0.01
                        THEN 1 ELSE 0 END), 0)
        FROM dbo.fac_ventas;

        IF @inv_d > 0
            THROW 50005, 'El Data Mart tiene registros con nulos, cantidades o importes invalidos.', 1;

        IF @lin_o <> @lin_d
            THROW 50006, 'No coinciden las lineas del OLTP y del Data Mart.', 1;

        IF @trx_o <> @trx_d
            THROW 50007, 'No coinciden las transacciones del OLTP y del Data Mart.', 1;

        IF ABS(@ven_o - @ven_d) > 0.01 OR ABS(@cos_o - @cos_d) > 0.01 OR ABS(@uti_o - @uti_d) > 0.01
            THROW 50008, 'No coinciden los importes (ventas, costo o utilidad) del OLTP y del Data Mart.', 1;

        IF EXISTS (
            SELECT 1
            FROM dbo.fac_ventas
            GROUP BY pk_venta, id_producto
            HAVING COUNT(*) > 1
        )
            THROW 50010, 'El Data Mart tiene lineas duplicadas (misma venta y producto).', 1;

        -- Conciliacion de dimensiones: filas cargadas vs filas del origen.
        SELECT @n_cli_o = COUNT(*) FROM dbVentasLibreria.dbo.cliente;
        SELECT @n_pro_o = COUNT(*) FROM dbVentasLibreria.dbo.producto;
        SELECT @n_ven_o = COUNT(*) FROM dbVentasLibreria.dbo.usuario WHERE rol = 'VENDEDOR';
        SELECT @n_met_o = COUNT(*) FROM dbVentasLibreria.dbo.metodoPago;

        SELECT @n_cli_d = COUNT(*) FROM dbo.dim_cliente;
        SELECT @n_pro_d = COUNT(*) FROM dbo.dim_producto;
        SELECT @n_ven_d = COUNT(*) FROM dbo.dim_vendedor;
        SELECT @n_met_d = COUNT(*) FROM dbo.dim_metodoPago;
        SELECT @n_dias_d = COUNT(*) FROM dbo.dim_tiempo;

        IF @n_cli_o <> @n_cli_d OR @n_pro_o <> @n_pro_d OR @n_ven_o <> @n_ven_d
           OR @n_met_o <> @n_met_d OR @n_dias_o <> @n_dias_d
            THROW 50009, 'No coinciden las filas de las dimensiones del Data Mart con las del OLTP.', 1;

        COMMIT TRANSACTION;

        -- 4. registrar resultado
        INSERT INTO dbo.etl_log
            (fecha_inicio, fecha_fin, estado,
             lineas_origen, lineas_destino, lineas_rechazadas,
             transacciones_origen, transacciones_destino,
             ventas_origen, ventas_destino, costo_origen, costo_destino,
             utilidad_origen, utilidad_destino, duracion_ms, mensaje)
        VALUES
            (@inicio, SYSDATETIME(), 'EXITOSO',
             @lin_o, @lin_d, @lin_o - @lin_d,
             @trx_o, @trx_d,
             @ven_o, @ven_d, @cos_o, @cos_d,
             @uti_o, @uti_d, DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()),
             CONCAT(N'OLTP y Data Mart coinciden. Dimensiones cargadas: cliente ', @n_cli_d,
                    N', producto ', @n_pro_d, N', vendedor ', @n_ven_d,
                    N', metodoPago ', @n_met_d, N', tiempo ', @n_dias_d,
                    N'. Carga confirmada.'));

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @msg = LEFT(ERROR_MESSAGE(), 500);

        INSERT INTO dbo.etl_log
            (fecha_inicio, fecha_fin, estado,
             lineas_origen, lineas_destino, lineas_rechazadas,
             transacciones_origen, transacciones_destino,
             ventas_origen, ventas_destino, costo_origen, costo_destino,
             utilidad_origen, utilidad_destino, duracion_ms, mensaje)
        VALUES
            (@inicio, SYSDATETIME(), 'ERROR',
             @lin_o, @lin_d, NULL,
             @trx_o, @trx_d,
             @ven_o, @ven_d, @cos_o, @cos_d,
             @uti_o, @uti_d, DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()),
             @msg);

        THROW;

    END CATCH
END
GO