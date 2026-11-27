-- 01_crear_oltp.sql : SOLO ESTRUCTURA (base, tablas, restricciones, indices). Sin datos.
-- Ejecutar primero. Luego ejecutar 02_datos_originales.sql (o cargar el dataset sintetico).
USE [master]
GO
/****** Objeto: Database [dbVentasLibreria] Fecha de script: 6/10/2026 16:48:34 ******/
CREATE DATABASE [dbVentasLibreria]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dbVentasLibreria', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\dbVentasLibreria.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'dbVentasLibreria_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\dbVentasLibreria_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [dbVentasLibreria] SET COMPATIBILITY_LEVEL = 170
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [dbVentasLibreria].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [dbVentasLibreria] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET ARITHABORT OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [dbVentasLibreria] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [dbVentasLibreria] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET  ENABLE_BROKER 
GO
ALTER DATABASE [dbVentasLibreria] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [dbVentasLibreria] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET RECOVERY FULL 
GO
ALTER DATABASE [dbVentasLibreria] SET  MULTI_USER 
GO
ALTER DATABASE [dbVentasLibreria] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [dbVentasLibreria] SET DB_CHAINING OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [dbVentasLibreria] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [dbVentasLibreria] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [dbVentasLibreria] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [dbVentasLibreria] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'dbVentasLibreria', N'ON'
GO
ALTER DATABASE [dbVentasLibreria] SET QUERY_STORE = ON
GO
ALTER DATABASE [dbVentasLibreria] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [dbVentasLibreria]
GO
/****** Objeto: Table [dbo].[categoria] Fecha de script: 6/10/2026 16:48:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[categoria](
	[idCategoria] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](80) NOT NULL,
	[activo] [bit] NOT NULL,
 CONSTRAINT [PK_categoria] PRIMARY KEY CLUSTERED 
(
	[idCategoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[cliente] Fecha de script: 6/10/2026 16:48:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cliente](
	[idCliente] [int] IDENTITY(1,1) NOT NULL,
	[dni] [char](8) NOT NULL,
	[nombre] [varchar](80) NOT NULL,
	[apellido] [varchar](80) NOT NULL,
	[telefono] [varchar](15) NULL,
	[activo] [bit] NOT NULL,
 CONSTRAINT [PK_cliente] PRIMARY KEY CLUSTERED 
(
	[idCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[metodoPago] Fecha de script: 6/10/2026 16:48:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[metodoPago](
	[idMetodoPago] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) NOT NULL,
	[activo] [bit] NOT NULL,
 CONSTRAINT [PK_metodoPago] PRIMARY KEY CLUSTERED 
(
	[idMetodoPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[producto] Fecha de script: 6/10/2026 16:48:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[producto](
	[idProducto] [int] IDENTITY(1,1) NOT NULL,
	[codigo] [varchar](30) NOT NULL,
	[nombre] [varchar](120) NOT NULL,
	[fkCategoria] [int] NOT NULL,
	[stock] [int] NOT NULL,
	[costoCompra] [decimal](10, 2) NOT NULL,
	[precioVenta] [decimal](10, 2) NOT NULL,
	[activo] [bit] NOT NULL,
 CONSTRAINT [PK_producto] PRIMARY KEY CLUSTERED 
(
	[idProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[usuario] Fecha de script: 6/10/2026 16:48:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usuario](
	[idUsuario] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](80) NOT NULL,
	[apellido] [varchar](80) NOT NULL,
	[usuario] [varchar](50) NOT NULL,
	[contrasena] [varchar](255) NOT NULL,
	[rol] [varchar](20) NOT NULL,
	[activo] [bit] NOT NULL,
 CONSTRAINT [PK_usuario] PRIMARY KEY CLUSTERED 
(
	[idUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[venta] Fecha de script: 6/10/2026 16:48:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[venta](
	[idVenta] [int] IDENTITY(1,1) NOT NULL,
	[fkCliente] [int] NOT NULL,
	[fkUsuario] [int] NOT NULL,
	[fkMetodoPago] [int] NOT NULL,
	[fecha] [datetime] NOT NULL,
	[estado] [varchar](15) NOT NULL,
 CONSTRAINT [PK_venta] PRIMARY KEY CLUSTERED 
(
	[idVenta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[ventaDetalle] Fecha de script: 6/10/2026 16:48:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ventaDetalle](
	[idVentaDetalle] [int] IDENTITY(1,1) NOT NULL,
	[fkVenta] [int] NOT NULL,
	[fkProducto] [int] NOT NULL,
	[cantidad] [int] NOT NULL,
	[precioVenta] [decimal](10, 2) NOT NULL,
	[costoUnitario] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_ventaDetalle] PRIMARY KEY CLUSTERED 
(
	[idVentaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [UQ_categoria_nombre] Fecha de script: 6/10/2026 16:48:36 ******/
ALTER TABLE [dbo].[categoria] ADD  CONSTRAINT [UQ_categoria_nombre] UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [UQ_cliente_dni] Fecha de script: 6/10/2026 16:48:36 ******/
ALTER TABLE [dbo].[cliente] ADD  CONSTRAINT [UQ_cliente_dni] UNIQUE NONCLUSTERED 
(
	[dni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [UQ_metodoPago_nombre] Fecha de script: 6/10/2026 16:48:36 ******/
ALTER TABLE [dbo].[metodoPago] ADD  CONSTRAINT [UQ_metodoPago_nombre] UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [UQ_producto_codigo] Fecha de script: 6/10/2026 16:48:36 ******/
ALTER TABLE [dbo].[producto] ADD  CONSTRAINT [UQ_producto_codigo] UNIQUE NONCLUSTERED 
(
	[codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_producto_fkCategoria] Fecha de script: 6/10/2026 16:48:36 ******/
CREATE NONCLUSTERED INDEX [IX_producto_fkCategoria] ON [dbo].[producto]
(
	[fkCategoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [UQ_usuario_usuario] Fecha de script: 6/10/2026 16:48:36 ******/
ALTER TABLE [dbo].[usuario] ADD  CONSTRAINT [UQ_usuario_usuario] UNIQUE NONCLUSTERED 
(
	[usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [IX_venta_fecha_estado] Fecha de script: 6/10/2026 16:48:36 ******/
CREATE NONCLUSTERED INDEX [IX_venta_fecha_estado] ON [dbo].[venta]
(
	[fecha] ASC,
	[estado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_venta_fkCliente] Fecha de script: 6/10/2026 16:48:36 ******/
CREATE NONCLUSTERED INDEX [IX_venta_fkCliente] ON [dbo].[venta]
(
	[fkCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_venta_fkMetodoPago] Fecha de script: 6/10/2026 16:48:36 ******/
CREATE NONCLUSTERED INDEX [IX_venta_fkMetodoPago] ON [dbo].[venta]
(
	[fkMetodoPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_venta_fkUsuario] Fecha de script: 6/10/2026 16:48:36 ******/
CREATE NONCLUSTERED INDEX [IX_venta_fkUsuario] ON [dbo].[venta]
(
	[fkUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [UQ_ventaDetalle_venta_producto] Fecha de script: 6/10/2026 16:48:36 ******/
ALTER TABLE [dbo].[ventaDetalle] ADD  CONSTRAINT [UQ_ventaDetalle_venta_producto] UNIQUE NONCLUSTERED 
(
	[fkVenta] ASC,
	[fkProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_ventaDetalle_fkProducto] Fecha de script: 6/10/2026 16:48:36 ******/
CREATE NONCLUSTERED INDEX [IX_ventaDetalle_fkProducto] ON [dbo].[ventaDetalle]
(
	[fkProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[categoria] ADD  CONSTRAINT [DF_categoria_activo]  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[cliente] ADD  CONSTRAINT [DF_cliente_activo]  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[metodoPago] ADD  CONSTRAINT [DF_metodoPago_activo]  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[producto] ADD  CONSTRAINT [DF_producto_stock]  DEFAULT ((0)) FOR [stock]
GO
ALTER TABLE [dbo].[producto] ADD  CONSTRAINT [DF_producto_activo]  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[usuario] ADD  CONSTRAINT [DF_usuario_activo]  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[venta] ADD  CONSTRAINT [DF_venta_fecha]  DEFAULT (getdate()) FOR [fecha]
GO
ALTER TABLE [dbo].[venta] ADD  CONSTRAINT [DF_venta_estado]  DEFAULT ('PENDIENTE') FOR [estado]
GO
ALTER TABLE [dbo].[producto]  WITH CHECK ADD  CONSTRAINT [FK_producto_categoria] FOREIGN KEY([fkCategoria])
REFERENCES [dbo].[categoria] ([idCategoria])
GO
ALTER TABLE [dbo].[producto] CHECK CONSTRAINT [FK_producto_categoria]
GO
ALTER TABLE [dbo].[venta]  WITH CHECK ADD  CONSTRAINT [FK_venta_cliente] FOREIGN KEY([fkCliente])
REFERENCES [dbo].[cliente] ([idCliente])
GO
ALTER TABLE [dbo].[venta] CHECK CONSTRAINT [FK_venta_cliente]
GO
ALTER TABLE [dbo].[venta]  WITH CHECK ADD  CONSTRAINT [FK_venta_metodoPago] FOREIGN KEY([fkMetodoPago])
REFERENCES [dbo].[metodoPago] ([idMetodoPago])
GO
ALTER TABLE [dbo].[venta] CHECK CONSTRAINT [FK_venta_metodoPago]
GO
ALTER TABLE [dbo].[venta]  WITH CHECK ADD  CONSTRAINT [FK_venta_usuario] FOREIGN KEY([fkUsuario])
REFERENCES [dbo].[usuario] ([idUsuario])
GO
ALTER TABLE [dbo].[venta] CHECK CONSTRAINT [FK_venta_usuario]
GO
ALTER TABLE [dbo].[ventaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ventaDetalle_producto] FOREIGN KEY([fkProducto])
REFERENCES [dbo].[producto] ([idProducto])
GO
ALTER TABLE [dbo].[ventaDetalle] CHECK CONSTRAINT [FK_ventaDetalle_producto]
GO
ALTER TABLE [dbo].[ventaDetalle]  WITH CHECK ADD  CONSTRAINT [FK_ventaDetalle_venta] FOREIGN KEY([fkVenta])
REFERENCES [dbo].[venta] ([idVenta])
GO
ALTER TABLE [dbo].[ventaDetalle] CHECK CONSTRAINT [FK_ventaDetalle_venta]
GO
ALTER TABLE [dbo].[cliente]  WITH CHECK ADD  CONSTRAINT [CK_cliente_dni] CHECK  ((NOT [dni] like '%[^0-9]%' AND len([dni])=(8)))
GO
ALTER TABLE [dbo].[cliente] CHECK CONSTRAINT [CK_cliente_dni]
GO
ALTER TABLE [dbo].[producto]  WITH CHECK ADD  CONSTRAINT [CK_producto_costo] CHECK  (([costoCompra]>=(0)))
GO
ALTER TABLE [dbo].[producto] CHECK CONSTRAINT [CK_producto_costo]
GO
ALTER TABLE [dbo].[producto]  WITH CHECK ADD  CONSTRAINT [CK_producto_precio] CHECK  (([precioVenta]>=(0)))
GO
ALTER TABLE [dbo].[producto] CHECK CONSTRAINT [CK_producto_precio]
GO
ALTER TABLE [dbo].[producto]  WITH CHECK ADD  CONSTRAINT [CK_producto_stock] CHECK  (([stock]>=(0)))
GO
ALTER TABLE [dbo].[producto] CHECK CONSTRAINT [CK_producto_stock]
GO
ALTER TABLE [dbo].[usuario]  WITH CHECK ADD  CONSTRAINT [CK_usuario_rol] CHECK  (([rol]='VENDEDOR' OR [rol]='ADMIN'))
GO
ALTER TABLE [dbo].[usuario] CHECK CONSTRAINT [CK_usuario_rol]
GO
ALTER TABLE [dbo].[venta]  WITH CHECK ADD  CONSTRAINT [CK_venta_estado] CHECK  (([estado]='CANCELADO' OR [estado]='COMPLETADO' OR [estado]='PENDIENTE'))
GO
ALTER TABLE [dbo].[venta] CHECK CONSTRAINT [CK_venta_estado]
GO
ALTER TABLE [dbo].[ventaDetalle]  WITH CHECK ADD  CONSTRAINT [CK_ventaDetalle_cantidad] CHECK  (([cantidad]>(0)))
GO
ALTER TABLE [dbo].[ventaDetalle] CHECK CONSTRAINT [CK_ventaDetalle_cantidad]
GO
ALTER TABLE [dbo].[ventaDetalle]  WITH CHECK ADD  CONSTRAINT [CK_ventaDetalle_costo] CHECK  (([costoUnitario]>=(0)))
GO
ALTER TABLE [dbo].[ventaDetalle] CHECK CONSTRAINT [CK_ventaDetalle_costo]
GO
ALTER TABLE [dbo].[ventaDetalle]  WITH CHECK ADD  CONSTRAINT [CK_ventaDetalle_precio] CHECK  (([precioVenta]>=(0)))
GO
ALTER TABLE [dbo].[ventaDetalle] CHECK CONSTRAINT [CK_ventaDetalle_precio]
GO
USE [master]
GO
ALTER DATABASE [dbVentasLibreria] SET  READ_WRITE 
GO