USE [master]
GO
/****** Object:  Database [Apollo_SmartFleet]    Script Date: 28.04.2026 10:46:13 ******/
CREATE DATABASE [Apollo_SmartFleet]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Apollo_SmartFleet', FILENAME = N'D:\MSSQL\2017\Data\Apollo_SmartFleet.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Apollo_SmartFleet_log', FILENAME = N'D:\MSSQL\2017\Log\Apollo_SmartFleet_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Apollo_SmartFleet] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Apollo_SmartFleet].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Apollo_SmartFleet] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET ARITHABORT OFF a
GO
ALTER DATABASE [Apollo_SmartFleet] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Apollo_SmartFleet] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Apollo_SmartFleet] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Apollo_SmartFleet] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Apollo_SmartFleet] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [Apollo_SmartFleet] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET RECOVERY FULL 
GO
ALTER DATABASE [Apollo_SmartFleet] SET  MULTI_USER 
GO
ALTER DATABASE [Apollo_SmartFleet] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Apollo_SmartFleet] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Apollo_SmartFleet] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Apollo_SmartFleet] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Apollo_SmartFleet] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Apollo_SmartFleet', N'ON'
GO
ALTER DATABASE [Apollo_SmartFleet] SET QUERY_STORE = OFF
GO
USE [Apollo_SmartFleet]
GO
/****** Object:  User [smartfleet]    Script Date: 28.04.2026 10:46:13 ******/
CREATE USER [smartfleet] FOR LOGIN [smartfleet] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [smartfleet]
GO
/****** Object:  Schema [data]    Script Date: 28.04.2026 10:46:13 ******/
CREATE SCHEMA [data]
GO
/****** Object:  Schema [plan]    Script Date: 28.04.2026 10:46:13 ******/
CREATE SCHEMA [plan]
GO
/****** Object:  Schema [track]    Script Date: 28.04.2026 10:46:13 ******/
CREATE SCHEMA [track]
GO
/****** Object:  UserDefinedFunction [dbo].[IsValidDate]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsValidDate](
  @Date datetime,
  @From datetime,
  @To datetime
)
RETURNS bit AS
BEGIN
  RETURN iif(@From<=@Date and (@Date<@To or @To is null),1,0)
END

GO
/****** Object:  UserDefinedFunction [plan].[GetPlanMatrix]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [plan].[GetPlanMatrix] (@PlanVersionId INT)
RETURNS @t TABLE
(
  StartId int NOT NULL,
  EndId int NOT NULL,
  [FromDepot] bit NOT NULL,
  [ToDepot] bit NOT NULL
)
AS
BEGIN

  WITH
  points AS
  (
    SELECT PointId, IsDepot FROM [plan].[GetPlanPoints] (@PlanVersionId)
  )
  INSERT INTO @t(StartId, EndId, FromDepot, ToDepot)
  SELECT [start].PointId as StartId, [end].PointId as EndId, [start].IsDepot as FromDepot, [end].IsDepot as ToDepot
  FROM points [start]
    INNER JOIN points [end] ON [start].PointId != [end].PointId

  RETURN
END

--DROP FUNCTION [plan].[GetPlanMatrix]

--SELECT * FROM [plan].[GetPlanMatrix](1)
GO
/****** Object:  UserDefinedFunction [plan].[GetPlanPoints]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [plan].[GetPlanPoints] (@PlanVersionId INT)
RETURNS @t TABLE
(
  PointId int NOT NULL,
  IsDepot bit NOT NULL,
  [Location] geography NOT NULL
)
AS
BEGIN

  WITH
  points AS
  (
    SELECT p.Depot_Id as PointId, 1 as IsDepot
    FROM [plan].PlanVersion p
    WHERE p.Id = @PlanVersionId
    UNION ALL 
    SELECT Outlet_Id as PointId, 0 as IsDepot
    FROM [plan].OutletDay
    WHERE PlanVersion_Id = @PlanVersionId
  )
  INSERT INTO @t(PointId, IsDepot, [Location])
  SELECT p.PointId, p.IsDepot, a.[Location]
  FROM points p
    INNER JOIN [data].[Address] a ON p.PointId = a.Id;

  RETURN
END 

--DROP FUNCTION [plan].[GetPlanPoints]

--SELECT * FROM [plan].[GetPlanPoints](1)

GO
/****** Object:  UserDefinedFunction [plan].[GetVehicleMatrix]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [plan].[GetVehicleMatrix] (@planVersionId int, @vehicleId int)
RETURNS @t TABLE
(
  StartId int NOT NULL,
  StartLocation [geography] NULL,
  EndId int NOT NULL,
  EndLocation [geography] NULL,
  [IsFromDepot] bit NOT NULL,
  [IsToDepot] bit NOT NULL
)
AS
BEGIN

  WITH
  points AS
  (
    SELECT PointId, [Location], IsDepot FROM [plan].GetVehiclePoints (@planVersionId, @vehicleId)
  )
  INSERT INTO @t(StartId, StartLocation, EndId, EndLocation, IsFromDepot, IsToDepot)
  SELECT 
    [start].PointId as StartId, [start].[Location] as StartLocation, 
    [end].PointId as EndId, [end].[Location] as EndLocation, 
    CASE WHEN [start].IsDepot = 1 THEN 1 ELSE 0 END as FromDepot,
    CASE WHEN [end].IsDepot = 1 THEN 1 ELSE 0 END as ToDepot
  FROM points [start]
    INNER JOIN points [end] ON [start].PointId != [end].PointId

  RETURN
END



GO
/****** Object:  UserDefinedFunction [plan].[GetVehiclePoints]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [plan].[GetVehiclePoints] (@planVersionId int, @vehicleId int)
RETURNS @t TABLE
(
  PointId int NOT NULL,
  [Location] [geography] NULL,
  IsDepot bit NOT NULL
)
AS
BEGIN
  
  WITH
  points AS
  (
    SELECT Outlet_Id as PointId, STRING_AGG(BinaryConstraint_Id, ',')  WITHIN GROUP ( ORDER BY BinaryConstraint_Id ASC) as BinaryConstraints, 0 as IsDepot
    FROM
    (
      SELECT od.Outlet_Id, BinaryConstraint_Id as BinaryConstraint_Id
      FROM [plan].OutletDay od
        LEFT JOIN [plan].OutletDayBinaryConstraint bc ON od.Outlet_Id = bc.Outlet_Id
          AND od.PlanVersion_Id = bc.PlanVersion_Id AND bc.IsValid = 1
      WHERE od.PlanVersion_Id = @planVersionId  
    ) q
    GROUP BY Outlet_Id
    UNION 
    SELECT p.Depot_Id as PointId, NULL as BinaryConstraints, 1 as IsDepot
    FROM [plan].PlanVersion p
    WHERE p.Id = @planVersionId
  ),
  vehicles AS 
  (
    SELECT @vehicleid as VehicleId, ISNULL(STRING_AGG(BinaryConstraint_Id, ',')  WITHIN GROUP ( ORDER BY BinaryConstraint_Id ASC), '')  as BinaryConstraints
    FROM [plan].VehicleDay vd
      LEFT JOIN [plan].VehicleDayBinaryConstraint bc ON vd.Vehicle_Id = bc.Vehicle_Id
          AND vd.PlanVersion_Id = bc.PlanVersion_Id AND bc.IsValid = 1
    WHERE vd.PlanVersion_Id = @planVersionId AND @vehicleid = vd.Vehicle_Id
  )
  INSERT INTO @t(PointId, [Location], IsDepot)
  SELECT o.PointId, a.Location, o.IsDepot -- v.VehicleId
  FROM points o
    CROSS JOIN vehicles v
    INNER JOIN [data].[Address] a ON o.PointId = a.Id
  WHERE (o.BinaryConstraints IS NULL OR v.BinaryConstraints LIKE '%' + o.BinaryConstraints + '%')
  
  RETURN

END
GO
/****** Object:  UserDefinedFunction [plan].[GetVehicleRoutes]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [plan].[GetVehicleRoutes](@planVersionId int, @MapProviderId int, @vehicleiD int) 
RETURNS @t TABLE
(
  [AddressStart_Id] [int] NOT NULL,
  [AddressEnd_Id] [int] NOT NULL,
  [MapProvider_Id] [int] NOT NULL,
  [Distance] [int] NOT NULL,
  [Duration] [int] NOT NULL,
  [Score] [int] NULL,
  [LastUpdate] [datetime2](7) NOT NULL,
  [GpsRouteXML] [xml] NULL
)
AS
BEGIN
  
  INSERT INTO @t([AddressStart_Id], [AddressEnd_Id], [MapProvider_Id], [Distance], [Duration], [Score], [LastUpdate], [GpsRouteXML])
  SELECT m.StartId as [AddressStart_Id], m.EndId as [AddressEnd_Id],
    CASE WHEN r.[MapProvider_Id] IS NOT NULL THEN r.[MapProvider_Id] ELSE 0 END as [MapProvider_Id],
    CASE WHEN r.[Distance] IS NOT NULL THEN r.[Distance] ELSE ROUND(m.[StartLocation].STDistance(m.[EndLocation]), 0) END as [Distance],
    CASE WHEN r.Duration IS NOT NULL THEN r.Duration ELSE ROUND(0.06 * m.[StartLocation].STDistance(m.[EndLocation]), 0) END as Duration,
    CASE WHEN r.[Score] IS NOT NULL THEN r.[Score] ELSE  ROUND(m.[StartLocation].STDistance(m.[EndLocation]), 0) END as [Score],
    CASE WHEN r.[LastUpdate] IS NOT NULL THEN r.[LastUpdate] ELSE GETDATE() END as [LastUpdate],
    NULL AS [GpsRouteXML]
  FROM [plan].GetVehicleMatrix(@planVersionId, @vehicleiD) m
    LEFT JOIN dbo.[Route] r ON m.StartId = r.AddressStart_Id AND m.EndId = r.AddressEnd_Id
      AND r.MapProvider_Id = @MapProviderId
  
  RETURN

END
GO
/****** Object:  UserDefinedFunction [track].[GetLocation]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [track].[GetLocation](
	@LocationX	FLOAT NULL,
	@LocationY	FLOAT NULL,
	@LocationZ	FLOAT NULL
)
RETURNS GEOGRAPHY AS
BEGIN
	DECLARE @strX NVARCHAR(18) = CASE WHEN @LocationX IS NULL THEN NULL ELSE LTRIM(STR(@LocationX, 18, 13)) END;
	DECLARE @strY NVARCHAR(18) = CASE WHEN @LocationY IS NULL THEN NULL ELSE LTRIM(STR(@LocationY, 18, 13)) END;
	DECLARE @strZ NVARCHAR(18) = CASE WHEN @LocationZ IS NULL THEN NULL ELSE LTRIM(STR(@LocationZ, 5, 1)) END;

	IF @strX IS NOT NULL AND @strY IS NOT NULL AND @strZ IS NOT NULL
	BEGIN
		RETURN geography::STGeomFromText('POINT('+@strX+' '+@strY+' '+@strZ+')', 4326)
	END
	ELSE IF @strX IS NOT NULL AND @strY IS NOT NULL AND @strZ IS NULL
	BEGIN
		RETURN geography::STGeomFromText('POINT('+@strX+' '+@strY+')', 4326)
	END

	RETURN NULL
END
GO
/****** Object:  Table [dbo].[Route]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Route](
	[AddressStart_Id] [int] NOT NULL,
	[AddressEnd_Id] [int] NOT NULL,
	[MapProvider_Id] [int] NOT NULL,
	[Distance] [int] NOT NULL,
	[Duration] [int] NOT NULL,
	[Score] [int] NULL,
	[LastUpdate] [datetime2](7) NOT NULL,
	[GpsRouteXML] [xml] NULL,
 CONSTRAINT [PK_Route] PRIMARY KEY CLUSTERED 
(
	[AddressStart_Id] ASC,
	[AddressEnd_Id] ASC,
	[MapProvider_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [plan].[GetPlanRoutes]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [plan].[GetPlanRoutes] (
    @PlanVersionId INT,
    @MapProviderId INT,
	@ObsoletionDate Datetime2
)
RETURNS TABLE
AS
RETURN
SELECT [AddressStart_Id], [AddressEnd_Id], [MapProvider_Id], [Distance], [Duration], [Score], [LastUpdate], 
	CASE WHEN LastUpdate>=@ObsoletionDate THEN [GpsRouteXML] ELSE NULL END as[GpsRouteXML]
FROM 
  (SELECT StartId, EndId FROM [plan].[GetPlanMatrix] (@PlanVersionId)) as matrix
  INNER JOIN dbo.[Route] r ON matrix.StartId = r.AddressStart_Id AND matrix.EndId = r.AddressEnd_Id
    AND MapProvider_Id = @MapProviderId
	
--DROP FUNCTION [plan].[GetPlanRoutes]
GO
/****** Object:  Table [data].[Address]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Address](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Street] [nvarchar](100) NOT NULL,
	[ZIPCode] [nvarchar](5) NOT NULL,
	[City] [nvarchar](100) NOT NULL,
	[Location] [geography] NULL,
 CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [data].[BinaryConstraint]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[BinaryConstraint](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Instance_Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_BinaryConstraint] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Category]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Category](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Instance_Id] [int] NOT NULL,
	[MapCategory_Id] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Customer]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Customer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Instance_Id] [int] NOT NULL,
	[ExternalId] [nvarchar](36) NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Delivery]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Delivery](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Order_Id] [int] NOT NULL,
	[DeliveryDate] [date] NOT NULL,
	[DeliveryNumber] [nvarchar](10) NOT NULL,
	[TimeFrom] [time](7) NOT NULL,
	[TimeTo] [time](7) NOT NULL,
	[TotalWeight] [real] NOT NULL,
	[TotalVolume] [real] NOT NULL,
	[TotalWeightReturn] [real] NOT NULL,
	[TotalVolumeReturn] [real] NOT NULL,
 CONSTRAINT [PK_Delivery] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Depot]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Depot](
	[Id] [int] NOT NULL,
	[Instance_Id] [int] NOT NULL,
 CONSTRAINT [PK_Depot] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[DepotConfiguration]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[DepotConfiguration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Depot_Id] [int] NOT NULL,
	[FixArrivalTimeSeconds] [int] NOT NULL,
	[FixDepartureTimeSeconds] [int] NOT NULL,
	[FixEndOfDateTimeSeconds] [int] NOT NULL,
	[LoadingSlotsCount] [int] NOT NULL,
	[UnloadingSlotsCount] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_DepotConfiguration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[DepotDriver]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[DepotDriver](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Depot_Id] [int] NOT NULL,
	[Driver_Id] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_DepotDriver] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[DepotTimeFrame]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[DepotTimeFrame](
	[Depot_Id] [int] NOT NULL,
	[TimeFrame_Id] [int] NOT NULL,
 CONSTRAINT [PK_DepotTimeFrame] PRIMARY KEY CLUSTERED 
(
	[Depot_Id] ASC,
	[TimeFrame_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[DepotUser]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[DepotUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationUser_Id] [int] NOT NULL,
	[Depot_Id] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_DepotUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[DepotVehicle]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[DepotVehicle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Depot_Id] [int] NOT NULL,
	[Vehicle_Id] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_DepotVehicle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Driver]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Driver](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Instance_Id] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Driver] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[DriverVehicle]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[DriverVehicle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Driver_Id] [int] NOT NULL,
	[Vehicle_Id] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_DriverVehicle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Order]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Order](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Outlet_Id] [int] NOT NULL,
	[Depot_Id] [int] NOT NULL,
	[DeliveryDate] [date] NOT NULL,
	[OrderNumber] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Outlet]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Outlet](
	[Id] [int] NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[ExternalId] [nvarchar](36) NOT NULL,
	[IC] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Outlet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[OutletBinaryConstraint]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[OutletBinaryConstraint](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Outlet_Id] [int] NOT NULL,
	[BinaryConstraint_Id] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_OutletBinaryConstraint] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[OutletConfiguration]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[OutletConfiguration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Outlet_Id] [int] NOT NULL,
	[FixArrivalTimeSeconds] [int] NOT NULL,
	[FixDepartureTimeSeconds] [int] NOT NULL,
	[CustomerLoadingRatio] [int] NOT NULL,
	[CustomerUnloadingRatio] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_OutletConfiguration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[OutletTimeFrame]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[OutletTimeFrame](
	[Outlet_Id] [int] NOT NULL,
	[TimeFrame_Id] [int] NOT NULL,
 CONSTRAINT [PK_OutletTimeFrame] PRIMARY KEY CLUSTERED 
(
	[Outlet_Id] ASC,
	[TimeFrame_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Product]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ExternalId] [nvarchar](36) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](255) NOT NULL,
	[Volume] [real] NOT NULL,
	[Weight] [real] NOT NULL,
	[IsReturnablePackage] [bit] NOT NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[TimeFrame]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[TimeFrame](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DayOfWeek] [int] NOT NULL,
	[TimeFrom] [time](7) NOT NULL,
	[TimeTo] [time](7) NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_TimeFrame] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[TimeFrameVehicle]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[TimeFrameVehicle](
	[TimeFrame_Id] [int] NOT NULL,
	[Vehicle_Id] [int] NOT NULL,
 CONSTRAINT [PK_TimeFrameVehicle] PRIMARY KEY CLUSTERED 
(
	[TimeFrame_Id] ASC,
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[Vehicle]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[Vehicle](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Instance_Id] [int] NOT NULL,
	[Manufacturer_Id] [int] NULL,
	[Model_Id] [int] NULL,
	[ExternalId] [nvarchar](36) NOT NULL,
	[LicensePlate] [nvarchar](20) NOT NULL,
	[Vin] [nvarchar](17) NOT NULL,
	[CargoAreaHeight] [real] NOT NULL,
	[CargoAreaLenght] [real] NOT NULL,
	[CargoAreaWidth] [real] NOT NULL,
	[Position] [int] NOT NULL,
	[Note] [nvarchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Vehicle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[VehicleBinaryConstraint]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[VehicleBinaryConstraint](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Vehicle_Id] [int] NOT NULL,
	[BinaryConstraint_Id] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_VehicleBinaryConstraint] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [data].[VehicleConfiguration]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [data].[VehicleConfiguration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Vehicle_Id] [int] NOT NULL,
	[DepotLoadingTimeSeconds] [int] NOT NULL,
	[DepotUnloadingTimeSeconds] [int] NOT NULL,
	[CargoCapacityVolume] [real] NOT NULL,
	[CargoCapacityWeight] [real] NOT NULL,
	[PalletsCount] [int] NOT NULL,
	[LoadingAcceleration] [int] NOT NULL,
	[UnloadingAcceleration] [int] NOT NULL,
	[MovementAcceleration] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
	[CostPerCrew] [decimal](6, 2) NOT NULL,
	[CostPerHour] [decimal](6, 2) NOT NULL,
	[CostPerKm] [decimal](6, 2) NOT NULL,
 CONSTRAINT [PK_VehicleConfiguration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeliveryStatus]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveryStatus](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_DeliveryStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Instance]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Instance](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Instance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Manufacturer]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Manufacturer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Manufacturer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MapCategory]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MapCategory](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_MapCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MapProvider]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MapProvider](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_MapProvider] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Model]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Model](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Manufacturer_Id] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Model] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[NormalizedName] [nvarchar](256) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleClaim]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleClaim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Role_Id] [int] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_RoleClaim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Language] [nchar](5) NOT NULL,
	[UserName] [nvarchar](256) NULL,
	[NormalizedUserName] [nvarchar](256) NULL,
	[Email] [nvarchar](256) NULL,
	[NormalizedEmail] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEnd] [datetimeoffset](7) NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserClaim]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserClaim](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_UserClaim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserLogin]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLogin](
	[LoginProvider] [nvarchar](450) NOT NULL,
	[ProviderKey] [nvarchar](450) NOT NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
	[User_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserLogin] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[User_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC,
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserToken]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserToken](
	[User_Id] [int] NOT NULL,
	[LoginProvider] [nvarchar](450) NOT NULL,
	[Name] [nvarchar](450) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_UserToken] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC,
	[LoginProvider] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkerJob]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkerJob](
	[Id] [uniqueidentifier] NOT NULL,
	[Status] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateStarted] [datetime2](7) NULL,
	[DateCompleted] [datetime2](7) NULL,
	[Param] [nvarchar](max) NOT NULL,
	[Result] [nvarchar](max) NULL,
 CONSTRAINT [PK_WorkerJob] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [plan].[DeliveryDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[DeliveryDay](
	[Delivery_Id] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[DeliveryStatus_Id] [int] NOT NULL,
	[DeliveryDate] [date] NOT NULL,
	[DeliveryNumber] [nvarchar](10) NOT NULL,
	[TimeFrom] [time](7) NOT NULL,
	[TimeTo] [time](7) NOT NULL,
	[TotalWeight] [real] NOT NULL,
	[TotalVolume] [real] NOT NULL,
	[TotalWeightReturn] [real] NOT NULL,
	[TotalVolumeReturn] [real] NOT NULL,
 CONSTRAINT [PK_DeliveryDay] PRIMARY KEY CLUSTERED 
(
	[Delivery_Id] ASC,
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[DeliveryStep]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[DeliveryStep](
	[Delivery_Id] [int] NOT NULL,
	[Step_Id] [int] NOT NULL,
 CONSTRAINT [PK_DeliveryStep] PRIMARY KEY CLUSTERED 
(
	[Delivery_Id] ASC,
	[Step_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[DepotDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[DepotDay](
	[Depot_Id] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[FixArrivalTimeSeconds] [int] NOT NULL,
	[FixDepartureTimeSeconds] [int] NOT NULL,
	[FixEndOfDateTimeSeconds] [int] NOT NULL,
	[LoadingSlotsCount] [int] NOT NULL,
	[UnloadingSlotsCount] [int] NOT NULL,
	[TimeFrom] [time](7) NOT NULL,
	[TimeTo] [time](7) NOT NULL,
 CONSTRAINT [PK_DepotDay] PRIMARY KEY CLUSTERED 
(
	[Depot_Id] ASC,
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[OutletDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[OutletDay](
	[Outlet_Id] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[CustomerLoadingRatio] [int] NOT NULL,
	[CustomerUnloadingRatio] [int] NOT NULL,
	[FixArrivalTimeSeconds] [int] NOT NULL,
	[FixDepartureTimeSeconds] [int] NOT NULL,
	[TimeFrom] [time](7) NOT NULL,
	[TimeTo] [time](7) NOT NULL,
 CONSTRAINT [PK_OutletDay] PRIMARY KEY CLUSTERED 
(
	[Outlet_Id] ASC,
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[OutletDayBinaryConstraint]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[OutletDayBinaryConstraint](
	[Outlet_Id] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[BinaryConstraint_Id] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
 CONSTRAINT [PK_OutletDayBinaryConstraint] PRIMARY KEY CLUSTERED 
(
	[Outlet_Id] ASC,
	[PlanVersion_Id] ASC,
	[BinaryConstraint_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[Plan]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[Plan](
	[Version] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Distance] [float] NOT NULL,
	[Duration] [float] NOT NULL,
	[Score] [float] NOT NULL,
 CONSTRAINT [PK_Plan] PRIMARY KEY CLUSTERED 
(
	[Version] ASC,
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[PlanVersion]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[PlanVersion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Instance_Id] [int] NOT NULL,
	[Depot_Id] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Date] [date] NOT NULL,
	[Created] [datetime2](7) NOT NULL,
	[Modified] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PlanVersion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[Route]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[Route](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[Vehicle_Id] [int] NOT NULL,
	[Distance] [float] NOT NULL,
	[Duration] [float] NOT NULL,
	[Score] [float] NOT NULL,
	[Position] [int] NOT NULL,
	[End] [datetime2](7) NOT NULL,
	[Start] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Route] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[Step]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[Step](
	[AddressStart_Id] [int] NOT NULL,
	[AddressEnd_Id] [int] NOT NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Route_Id] [int] NOT NULL,
	[Position] [int] NOT NULL,
	[Distance] [float] NOT NULL,
	[Duration] [float] NOT NULL,
	[Score] [float] NOT NULL,
	[GpsRouteXML] [xml] NULL,
	[DriveEnd] [datetime2](7) NOT NULL,
	[DriveStart] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Step] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [plan].[UnServicedDelivery]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[UnServicedDelivery](
	[Delivery_Id] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[Version] [int] NOT NULL,
 CONSTRAINT [PK_UnServicedDelivery] PRIMARY KEY CLUSTERED 
(
	[Delivery_Id] ASC,
	[PlanVersion_Id] ASC,
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[VehicleDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[VehicleDay](
	[Vehicle_Id] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[Driver_Id] [int] NOT NULL,
	[DriverAssistant_Id] [int] NULL,
	[Category_Id] [int] NOT NULL,
	[DepotLoadingTimeSeconds] [int] NOT NULL,
	[DepotUnloadingTimeSeconds] [int] NOT NULL,
	[CargoCapacityVolume] [real] NOT NULL,
	[CargoCapacityWeight] [real] NOT NULL,
	[PalletsCount] [int] NOT NULL,
	[LoadingAcceleration] [int] NOT NULL,
	[UnloadingAcceleration] [int] NOT NULL,
	[MovementAcceleration] [int] NOT NULL,
	[TimeFrom] [time](7) NOT NULL,
	[TimeTo] [time](7) NOT NULL,
	[Position] [int] NOT NULL,
	[Preload] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CostPerCrew] [decimal](6, 2) NOT NULL,
	[CostPerHour] [decimal](6, 2) NOT NULL,
	[CostPerKm] [decimal](6, 2) NOT NULL,
 CONSTRAINT [PK_VehicleDay] PRIMARY KEY CLUSTERED 
(
	[Vehicle_Id] ASC,
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [plan].[VehicleDayBinaryConstraint]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [plan].[VehicleDayBinaryConstraint](
	[Vehicle_Id] [int] NOT NULL,
	[PlanVersion_Id] [int] NOT NULL,
	[BinaryConstraint_Id] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
 CONSTRAINT [PK_VehicleDayBinaryConstraint] PRIMARY KEY CLUSTERED 
(
	[Vehicle_Id] ASC,
	[PlanVersion_Id] ASC,
	[BinaryConstraint_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [track].[Tracker]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [track].[Tracker](
	[IMEI] [bigint] NOT NULL,
 CONSTRAINT [PK_Tracker] PRIMARY KEY CLUSTERED 
(
	[IMEI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [track].[Tracking]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [track].[Tracking](
	[Vehicle_Id] [int] NULL,
	[Tracker_IMEI] [bigint] NOT NULL,
	[Location] [geography] NULL,
	[TrackingDateUtc] [datetime2](7) NOT NULL,
	[DataJSON] [nvarchar](max) NOT NULL,
	[Version] [nvarchar](20) NOT NULL,
	[Angle] [smallint] NULL,
	[CreateDateUtc] [datetime2](7) NOT NULL,
	[Satellites] [tinyint] NULL,
	[Speed] [smallint] NULL,
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Ignition] [bit] NULL,
	[Movement] [bit] NULL,
 CONSTRAINT [PK_Tracking] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [track].[VehicleTracker]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [track].[VehicleTracker](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Vehicle_Id] [int] NOT NULL,
	[Tracker_IMEI] [bigint] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NULL,
 CONSTRAINT [PK_VehicleTracker] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_BinaryConstraint_Instance_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_BinaryConstraint_Instance_Id] ON [data].[BinaryConstraint]
(
	[Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Category_Instance_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Category_Instance_Id] ON [data].[Category]
(
	[Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Category_MapCategory_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Category_MapCategory_Id] ON [data].[Category]
(
	[MapCategory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_Instance_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Customer_Instance_Id] ON [data].[Customer]
(
	[Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Delivery_Order_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Delivery_Order_Id] ON [data].[Delivery]
(
	[Order_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Depot_Instance_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Depot_Instance_Id] ON [data].[Depot]
(
	[Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotConfiguration_Depot_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotConfiguration_Depot_Id] ON [data].[DepotConfiguration]
(
	[Depot_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotDriver_Depot_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotDriver_Depot_Id] ON [data].[DepotDriver]
(
	[Depot_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotDriver_Driver_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotDriver_Driver_Id] ON [data].[DepotDriver]
(
	[Driver_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotTimeFrame_TimeFrame_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotTimeFrame_TimeFrame_Id] ON [data].[DepotTimeFrame]
(
	[TimeFrame_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotUser_ApplicationUser_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotUser_ApplicationUser_Id] ON [data].[DepotUser]
(
	[ApplicationUser_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotUser_Depot_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotUser_Depot_Id] ON [data].[DepotUser]
(
	[Depot_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotVehicle_Depot_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotVehicle_Depot_Id] ON [data].[DepotVehicle]
(
	[Depot_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotVehicle_Vehicle_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotVehicle_Vehicle_Id] ON [data].[DepotVehicle]
(
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Driver_Instance_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Driver_Instance_Id] ON [data].[Driver]
(
	[Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DriverVehicle_Driver_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DriverVehicle_Driver_Id] ON [data].[DriverVehicle]
(
	[Driver_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DriverVehicle_Vehicle_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DriverVehicle_Vehicle_Id] ON [data].[DriverVehicle]
(
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Order_Depot_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Order_Depot_Id] ON [data].[Order]
(
	[Depot_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Order_Outlet_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Order_Outlet_Id] ON [data].[Order]
(
	[Outlet_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Outlet_Customer_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Outlet_Customer_Id] ON [data].[Outlet]
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OutletBinaryConstraint_BinaryConstraint_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_OutletBinaryConstraint_BinaryConstraint_Id] ON [data].[OutletBinaryConstraint]
(
	[BinaryConstraint_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OutletBinaryConstraint_Outlet_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_OutletBinaryConstraint_Outlet_Id] ON [data].[OutletBinaryConstraint]
(
	[Outlet_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OutletConfiguration_Outlet_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_OutletConfiguration_Outlet_Id] ON [data].[OutletConfiguration]
(
	[Outlet_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OutletTimeFrame_TimeFrame_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_OutletTimeFrame_TimeFrame_Id] ON [data].[OutletTimeFrame]
(
	[TimeFrame_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TimeFrameVehicle_Vehicle_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_TimeFrameVehicle_Vehicle_Id] ON [data].[TimeFrameVehicle]
(
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Vehicle_Instance_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Vehicle_Instance_Id] ON [data].[Vehicle]
(
	[Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Vehicle_Manufacturer_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Vehicle_Manufacturer_Id] ON [data].[Vehicle]
(
	[Manufacturer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Vehicle_Model_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Vehicle_Model_Id] ON [data].[Vehicle]
(
	[Model_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleBinaryConstraint_BinaryConstraint_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleBinaryConstraint_BinaryConstraint_Id] ON [data].[VehicleBinaryConstraint]
(
	[BinaryConstraint_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleBinaryConstraint_Vehicle_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleBinaryConstraint_Vehicle_Id] ON [data].[VehicleBinaryConstraint]
(
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleConfiguration_Vehicle_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleConfiguration_Vehicle_Id] ON [data].[VehicleConfiguration]
(
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Model_Manufacturer_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Model_Manufacturer_Id] ON [dbo].[Model]
(
	[Manufacturer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [RoleNameIndex]    Script Date: 28.04.2026 10:46:13 ******/
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex] ON [dbo].[Role]
(
	[NormalizedName] ASC
)
WHERE ([NormalizedName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RoleClaim_Role_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_RoleClaim_Role_Id] ON [dbo].[RoleClaim]
(
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Route_AddressEnd_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Route_AddressEnd_Id] ON [dbo].[Route]
(
	[AddressEnd_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Route_MapProvider_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Route_MapProvider_Id] ON [dbo].[Route]
(
	[MapProvider_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [EmailIndex]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [EmailIndex] ON [dbo].[User]
(
	[NormalizedEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UserNameIndex]    Script Date: 28.04.2026 10:46:13 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[User]
(
	[NormalizedUserName] ASC
)
WHERE ([NormalizedUserName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserClaim_User_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_UserClaim_User_Id] ON [dbo].[UserClaim]
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserLogin_User_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_UserLogin_User_Id] ON [dbo].[UserLogin]
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserRole_Role_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_UserRole_Role_Id] ON [dbo].[UserRole]
(
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DeliveryDay_DeliveryStatus_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DeliveryDay_DeliveryStatus_Id] ON [plan].[DeliveryDay]
(
	[DeliveryStatus_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DeliveryDay_PlanVersion_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DeliveryDay_PlanVersion_Id] ON [plan].[DeliveryDay]
(
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DeliveryStep_Step_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DeliveryStep_Step_Id] ON [plan].[DeliveryStep]
(
	[Step_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DepotDay_PlanVersion_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_DepotDay_PlanVersion_Id] ON [plan].[DepotDay]
(
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OutletDay_PlanVersion_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_OutletDay_PlanVersion_Id] ON [plan].[OutletDay]
(
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OutletDayBinaryConstraint_BinaryConstraint_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_OutletDayBinaryConstraint_BinaryConstraint_Id] ON [plan].[OutletDayBinaryConstraint]
(
	[BinaryConstraint_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OutletDayBinaryConstraint_PlanVersion_Id_IsValid]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_OutletDayBinaryConstraint_PlanVersion_Id_IsValid] ON [plan].[OutletDayBinaryConstraint]
(
	[PlanVersion_Id] ASC,
	[IsValid] ASC
)
INCLUDE([Outlet_Id],[BinaryConstraint_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Plan_PlanVersion_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Plan_PlanVersion_Id] ON [plan].[Plan]
(
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PlanVersion_Depot_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_PlanVersion_Depot_Id] ON [plan].[PlanVersion]
(
	[Depot_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PlanVersion_Instance_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_PlanVersion_Instance_Id] ON [plan].[PlanVersion]
(
	[Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Route_Vehicle_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Route_Vehicle_Id] ON [plan].[Route]
(
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Route_Version_PlanVersion_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Route_Version_PlanVersion_Id] ON [plan].[Route]
(
	[Version] ASC,
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Step_AddressEnd_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Step_AddressEnd_Id] ON [plan].[Step]
(
	[AddressEnd_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Step_AddressStart_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Step_AddressStart_Id] ON [plan].[Step]
(
	[AddressStart_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Step_Route_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Step_Route_Id] ON [plan].[Step]
(
	[Route_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnServicedDelivery_Version_PlanVersion_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_UnServicedDelivery_Version_PlanVersion_Id] ON [plan].[UnServicedDelivery]
(
	[Version] ASC,
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleDay_Category_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleDay_Category_Id] ON [plan].[VehicleDay]
(
	[Category_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleDay_Driver_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleDay_Driver_Id] ON [plan].[VehicleDay]
(
	[Driver_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleDay_DriverAssistant_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleDay_DriverAssistant_Id] ON [plan].[VehicleDay]
(
	[DriverAssistant_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleDay_PlanVersion_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleDay_PlanVersion_Id] ON [plan].[VehicleDay]
(
	[PlanVersion_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleDayBinaryConstraint_BinaryConstraint_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleDayBinaryConstraint_BinaryConstraint_Id] ON [plan].[VehicleDayBinaryConstraint]
(
	[BinaryConstraint_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleDayBinaryConstraint_PlanVersion_Id_IsValid]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleDayBinaryConstraint_PlanVersion_Id_IsValid] ON [plan].[VehicleDayBinaryConstraint]
(
	[PlanVersion_Id] ASC,
	[IsValid] ASC
)
INCLUDE([Vehicle_Id],[BinaryConstraint_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Tracking_Tracker_IMEI]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Tracking_Tracker_IMEI] ON [track].[Tracking]
(
	[Tracker_IMEI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Tracking_Vehicle_Id_Tracker_IMEI_TrackingDateUtc]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_Tracking_Vehicle_Id_Tracker_IMEI_TrackingDateUtc] ON [track].[Tracking]
(
	[Vehicle_Id] ASC,
	[Tracker_IMEI] ASC,
	[TrackingDateUtc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleTracker_Tracker_IMEI]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleTracker_Tracker_IMEI] ON [track].[VehicleTracker]
(
	[Tracker_IMEI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_VehicleTracker_Vehicle_Id]    Script Date: 28.04.2026 10:46:13 ******/
CREATE NONCLUSTERED INDEX [IX_VehicleTracker_Vehicle_Id] ON [track].[VehicleTracker]
(
	[Vehicle_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [data].[VehicleConfiguration] ADD  DEFAULT ((0.0)) FOR [CostPerCrew]
GO
ALTER TABLE [data].[VehicleConfiguration] ADD  DEFAULT ((0.0)) FOR [CostPerHour]
GO
ALTER TABLE [data].[VehicleConfiguration] ADD  DEFAULT ((0.0)) FOR [CostPerKm]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT (N'') FOR [FirstName]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT (N'') FOR [LastName]
GO
ALTER TABLE [plan].[Route] ADD  DEFAULT ((0)) FOR [Position]
GO
ALTER TABLE [plan].[Route] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [End]
GO
ALTER TABLE [plan].[Route] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [Start]
GO
ALTER TABLE [plan].[Step] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [DriveEnd]
GO
ALTER TABLE [plan].[Step] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [DriveStart]
GO
ALTER TABLE [plan].[VehicleDay] ADD  DEFAULT ((0.0)) FOR [CostPerCrew]
GO
ALTER TABLE [plan].[VehicleDay] ADD  DEFAULT ((0.0)) FOR [CostPerHour]
GO
ALTER TABLE [plan].[VehicleDay] ADD  DEFAULT ((0.0)) FOR [CostPerKm]
GO
ALTER TABLE [track].[Tracking] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [CreateDateUtc]
GO
ALTER TABLE [data].[BinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_BinaryConstraint_Instance_Instance_Id] FOREIGN KEY([Instance_Id])
REFERENCES [dbo].[Instance] ([Id])
GO
ALTER TABLE [data].[BinaryConstraint] CHECK CONSTRAINT [FK_BinaryConstraint_Instance_Instance_Id]
GO
ALTER TABLE [data].[Category]  WITH CHECK ADD  CONSTRAINT [FK_Category_Instance_Instance_Id] FOREIGN KEY([Instance_Id])
REFERENCES [dbo].[Instance] ([Id])
GO
ALTER TABLE [data].[Category] CHECK CONSTRAINT [FK_Category_Instance_Instance_Id]
GO
ALTER TABLE [data].[Category]  WITH CHECK ADD  CONSTRAINT [FK_Category_MapCategory_MapCategory_Id] FOREIGN KEY([MapCategory_Id])
REFERENCES [dbo].[MapCategory] ([Id])
GO
ALTER TABLE [data].[Category] CHECK CONSTRAINT [FK_Category_MapCategory_MapCategory_Id]
GO
ALTER TABLE [data].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Instance_Instance_Id] FOREIGN KEY([Instance_Id])
REFERENCES [dbo].[Instance] ([Id])
GO
ALTER TABLE [data].[Customer] CHECK CONSTRAINT [FK_Customer_Instance_Instance_Id]
GO
ALTER TABLE [data].[Delivery]  WITH CHECK ADD  CONSTRAINT [FK_Delivery_Order_Order_Id] FOREIGN KEY([Order_Id])
REFERENCES [data].[Order] ([Id])
GO
ALTER TABLE [data].[Delivery] CHECK CONSTRAINT [FK_Delivery_Order_Order_Id]
GO
ALTER TABLE [data].[Depot]  WITH CHECK ADD  CONSTRAINT [FK_Depot_Address_Id] FOREIGN KEY([Id])
REFERENCES [data].[Address] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[Depot] CHECK CONSTRAINT [FK_Depot_Address_Id]
GO
ALTER TABLE [data].[Depot]  WITH CHECK ADD  CONSTRAINT [FK_Depot_Instance_Instance_Id] FOREIGN KEY([Instance_Id])
REFERENCES [dbo].[Instance] ([Id])
GO
ALTER TABLE [data].[Depot] CHECK CONSTRAINT [FK_Depot_Instance_Instance_Id]
GO
ALTER TABLE [data].[DepotConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_DepotConfiguration_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
GO
ALTER TABLE [data].[DepotConfiguration] CHECK CONSTRAINT [FK_DepotConfiguration_Depot_Depot_Id]
GO
ALTER TABLE [data].[DepotDriver]  WITH CHECK ADD  CONSTRAINT [FK_DepotDriver_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
GO
ALTER TABLE [data].[DepotDriver] CHECK CONSTRAINT [FK_DepotDriver_Depot_Depot_Id]
GO
ALTER TABLE [data].[DepotDriver]  WITH CHECK ADD  CONSTRAINT [FK_DepotDriver_Driver_Driver_Id] FOREIGN KEY([Driver_Id])
REFERENCES [data].[Driver] ([Id])
GO
ALTER TABLE [data].[DepotDriver] CHECK CONSTRAINT [FK_DepotDriver_Driver_Driver_Id]
GO
ALTER TABLE [data].[DepotTimeFrame]  WITH CHECK ADD  CONSTRAINT [FK_DepotTimeFrame_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[DepotTimeFrame] CHECK CONSTRAINT [FK_DepotTimeFrame_Depot_Depot_Id]
GO
ALTER TABLE [data].[DepotTimeFrame]  WITH CHECK ADD  CONSTRAINT [FK_DepotTimeFrame_TimeFrame_TimeFrame_Id] FOREIGN KEY([TimeFrame_Id])
REFERENCES [data].[TimeFrame] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[DepotTimeFrame] CHECK CONSTRAINT [FK_DepotTimeFrame_TimeFrame_TimeFrame_Id]
GO
ALTER TABLE [data].[DepotUser]  WITH CHECK ADD  CONSTRAINT [FK_DepotUser_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
GO
ALTER TABLE [data].[DepotUser] CHECK CONSTRAINT [FK_DepotUser_Depot_Depot_Id]
GO
ALTER TABLE [data].[DepotUser]  WITH CHECK ADD  CONSTRAINT [FK_DepotUser_User_ApplicationUser_Id] FOREIGN KEY([ApplicationUser_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [data].[DepotUser] CHECK CONSTRAINT [FK_DepotUser_User_ApplicationUser_Id]
GO
ALTER TABLE [data].[DepotVehicle]  WITH CHECK ADD  CONSTRAINT [FK_DepotVehicle_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
GO
ALTER TABLE [data].[DepotVehicle] CHECK CONSTRAINT [FK_DepotVehicle_Depot_Depot_Id]
GO
ALTER TABLE [data].[DepotVehicle]  WITH CHECK ADD  CONSTRAINT [FK_DepotVehicle_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
GO
ALTER TABLE [data].[DepotVehicle] CHECK CONSTRAINT [FK_DepotVehicle_Vehicle_Vehicle_Id]
GO
ALTER TABLE [data].[Driver]  WITH CHECK ADD  CONSTRAINT [FK_Driver_Instance_Instance_Id] FOREIGN KEY([Instance_Id])
REFERENCES [dbo].[Instance] ([Id])
GO
ALTER TABLE [data].[Driver] CHECK CONSTRAINT [FK_Driver_Instance_Instance_Id]
GO
ALTER TABLE [data].[DriverVehicle]  WITH CHECK ADD  CONSTRAINT [FK_DriverVehicle_Driver_Driver_Id] FOREIGN KEY([Driver_Id])
REFERENCES [data].[Driver] ([Id])
GO
ALTER TABLE [data].[DriverVehicle] CHECK CONSTRAINT [FK_DriverVehicle_Driver_Driver_Id]
GO
ALTER TABLE [data].[DriverVehicle]  WITH CHECK ADD  CONSTRAINT [FK_DriverVehicle_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
GO
ALTER TABLE [data].[DriverVehicle] CHECK CONSTRAINT [FK_DriverVehicle_Vehicle_Vehicle_Id]
GO
ALTER TABLE [data].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
GO
ALTER TABLE [data].[Order] CHECK CONSTRAINT [FK_Order_Depot_Depot_Id]
GO
ALTER TABLE [data].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Outlet_Outlet_Id] FOREIGN KEY([Outlet_Id])
REFERENCES [data].[Outlet] ([Id])
GO
ALTER TABLE [data].[Order] CHECK CONSTRAINT [FK_Order_Outlet_Outlet_Id]
GO
ALTER TABLE [data].[Outlet]  WITH CHECK ADD  CONSTRAINT [FK_Outlet_Address_Id] FOREIGN KEY([Id])
REFERENCES [data].[Address] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[Outlet] CHECK CONSTRAINT [FK_Outlet_Address_Id]
GO
ALTER TABLE [data].[Outlet]  WITH CHECK ADD  CONSTRAINT [FK_Outlet_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [data].[Customer] ([Id])
GO
ALTER TABLE [data].[Outlet] CHECK CONSTRAINT [FK_Outlet_Customer_Customer_Id]
GO
ALTER TABLE [data].[OutletBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_OutletBinaryConstraint_BinaryConstraint_BinaryConstraint_Id] FOREIGN KEY([BinaryConstraint_Id])
REFERENCES [data].[BinaryConstraint] ([Id])
GO
ALTER TABLE [data].[OutletBinaryConstraint] CHECK CONSTRAINT [FK_OutletBinaryConstraint_BinaryConstraint_BinaryConstraint_Id]
GO
ALTER TABLE [data].[OutletBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_OutletBinaryConstraint_Outlet_Outlet_Id] FOREIGN KEY([Outlet_Id])
REFERENCES [data].[Outlet] ([Id])
GO
ALTER TABLE [data].[OutletBinaryConstraint] CHECK CONSTRAINT [FK_OutletBinaryConstraint_Outlet_Outlet_Id]
GO
ALTER TABLE [data].[OutletConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_OutletConfiguration_Outlet_Outlet_Id] FOREIGN KEY([Outlet_Id])
REFERENCES [data].[Outlet] ([Id])
GO
ALTER TABLE [data].[OutletConfiguration] CHECK CONSTRAINT [FK_OutletConfiguration_Outlet_Outlet_Id]
GO
ALTER TABLE [data].[OutletTimeFrame]  WITH CHECK ADD  CONSTRAINT [FK_OutletTimeFrame_Outlet_Outlet_Id] FOREIGN KEY([Outlet_Id])
REFERENCES [data].[Outlet] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[OutletTimeFrame] CHECK CONSTRAINT [FK_OutletTimeFrame_Outlet_Outlet_Id]
GO
ALTER TABLE [data].[OutletTimeFrame]  WITH CHECK ADD  CONSTRAINT [FK_OutletTimeFrame_TimeFrame_TimeFrame_Id] FOREIGN KEY([TimeFrame_Id])
REFERENCES [data].[TimeFrame] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[OutletTimeFrame] CHECK CONSTRAINT [FK_OutletTimeFrame_TimeFrame_TimeFrame_Id]
GO
ALTER TABLE [data].[TimeFrameVehicle]  WITH CHECK ADD  CONSTRAINT [FK_TimeFrameVehicle_TimeFrame_TimeFrame_Id] FOREIGN KEY([TimeFrame_Id])
REFERENCES [data].[TimeFrame] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[TimeFrameVehicle] CHECK CONSTRAINT [FK_TimeFrameVehicle_TimeFrame_TimeFrame_Id]
GO
ALTER TABLE [data].[TimeFrameVehicle]  WITH CHECK ADD  CONSTRAINT [FK_TimeFrameVehicle_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [data].[TimeFrameVehicle] CHECK CONSTRAINT [FK_TimeFrameVehicle_Vehicle_Vehicle_Id]
GO
ALTER TABLE [data].[Vehicle]  WITH CHECK ADD  CONSTRAINT [FK_Vehicle_Instance_Instance_Id] FOREIGN KEY([Instance_Id])
REFERENCES [dbo].[Instance] ([Id])
GO
ALTER TABLE [data].[Vehicle] CHECK CONSTRAINT [FK_Vehicle_Instance_Instance_Id]
GO
ALTER TABLE [data].[Vehicle]  WITH CHECK ADD  CONSTRAINT [FK_Vehicle_Manufacturer_Manufacturer_Id] FOREIGN KEY([Manufacturer_Id])
REFERENCES [dbo].[Manufacturer] ([Id])
GO
ALTER TABLE [data].[Vehicle] CHECK CONSTRAINT [FK_Vehicle_Manufacturer_Manufacturer_Id]
GO
ALTER TABLE [data].[Vehicle]  WITH CHECK ADD  CONSTRAINT [FK_Vehicle_Model_Model_Id] FOREIGN KEY([Model_Id])
REFERENCES [dbo].[Model] ([Id])
GO
ALTER TABLE [data].[Vehicle] CHECK CONSTRAINT [FK_Vehicle_Model_Model_Id]
GO
ALTER TABLE [data].[VehicleBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_VehicleBinaryConstraint_BinaryConstraint_BinaryConstraint_Id] FOREIGN KEY([BinaryConstraint_Id])
REFERENCES [data].[BinaryConstraint] ([Id])
GO
ALTER TABLE [data].[VehicleBinaryConstraint] CHECK CONSTRAINT [FK_VehicleBinaryConstraint_BinaryConstraint_BinaryConstraint_Id]
GO
ALTER TABLE [data].[VehicleBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_VehicleBinaryConstraint_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
GO
ALTER TABLE [data].[VehicleBinaryConstraint] CHECK CONSTRAINT [FK_VehicleBinaryConstraint_Vehicle_Vehicle_Id]
GO
ALTER TABLE [data].[VehicleConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_VehicleConfiguration_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
GO
ALTER TABLE [data].[VehicleConfiguration] CHECK CONSTRAINT [FK_VehicleConfiguration_Vehicle_Vehicle_Id]
GO
ALTER TABLE [dbo].[Model]  WITH CHECK ADD  CONSTRAINT [FK_Model_Manufacturer_Manufacturer_Id] FOREIGN KEY([Manufacturer_Id])
REFERENCES [dbo].[Manufacturer] ([Id])
GO
ALTER TABLE [dbo].[Model] CHECK CONSTRAINT [FK_Model_Manufacturer_Manufacturer_Id]
GO
ALTER TABLE [dbo].[RoleClaim]  WITH CHECK ADD  CONSTRAINT [FK_RoleClaim_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [dbo].[Role] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RoleClaim] CHECK CONSTRAINT [FK_RoleClaim_Role_Role_Id]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Address_AddressEnd_Id] FOREIGN KEY([AddressEnd_Id])
REFERENCES [data].[Address] ([Id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [FK_Route_Address_AddressEnd_Id]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Address_AddressStart_Id] FOREIGN KEY([AddressStart_Id])
REFERENCES [data].[Address] ([Id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [FK_Route_Address_AddressStart_Id]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_MapProvider_MapProvider_Id] FOREIGN KEY([MapProvider_Id])
REFERENCES [dbo].[MapProvider] ([Id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [FK_Route_MapProvider_MapProvider_Id]
GO
ALTER TABLE [dbo].[UserClaim]  WITH CHECK ADD  CONSTRAINT [FK_UserClaim_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserClaim] CHECK CONSTRAINT [FK_UserClaim_User_User_Id]
GO
ALTER TABLE [dbo].[UserLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserLogin_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserLogin] CHECK CONSTRAINT [FK_UserLogin_User_User_Id]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role_Role_Id]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User_User_Id]
GO
ALTER TABLE [dbo].[UserToken]  WITH CHECK ADD  CONSTRAINT [FK_UserToken_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserToken] CHECK CONSTRAINT [FK_UserToken_User_User_Id]
GO
ALTER TABLE [plan].[DeliveryDay]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryDay_Delivery_Delivery_Id] FOREIGN KEY([Delivery_Id])
REFERENCES [data].[Delivery] ([Id])
GO
ALTER TABLE [plan].[DeliveryDay] CHECK CONSTRAINT [FK_DeliveryDay_Delivery_Delivery_Id]
GO
ALTER TABLE [plan].[DeliveryDay]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryDay_DeliveryStatus_DeliveryStatus_Id] FOREIGN KEY([DeliveryStatus_Id])
REFERENCES [dbo].[DeliveryStatus] ([Id])
GO
ALTER TABLE [plan].[DeliveryDay] CHECK CONSTRAINT [FK_DeliveryDay_DeliveryStatus_DeliveryStatus_Id]
GO
ALTER TABLE [plan].[DeliveryDay]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryDay_PlanVersion_PlanVersion_Id] FOREIGN KEY([PlanVersion_Id])
REFERENCES [plan].[PlanVersion] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[DeliveryDay] CHECK CONSTRAINT [FK_DeliveryDay_PlanVersion_PlanVersion_Id]
GO
ALTER TABLE [plan].[DeliveryStep]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryStep_Delivery_Delivery_Id] FOREIGN KEY([Delivery_Id])
REFERENCES [data].[Delivery] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[DeliveryStep] CHECK CONSTRAINT [FK_DeliveryStep_Delivery_Delivery_Id]
GO
ALTER TABLE [plan].[DeliveryStep]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryStep_Step_Step_Id] FOREIGN KEY([Step_Id])
REFERENCES [plan].[Step] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[DeliveryStep] CHECK CONSTRAINT [FK_DeliveryStep_Step_Step_Id]
GO
ALTER TABLE [plan].[DepotDay]  WITH CHECK ADD  CONSTRAINT [FK_DepotDay_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
GO
ALTER TABLE [plan].[DepotDay] CHECK CONSTRAINT [FK_DepotDay_Depot_Depot_Id]
GO
ALTER TABLE [plan].[DepotDay]  WITH CHECK ADD  CONSTRAINT [FK_DepotDay_PlanVersion_PlanVersion_Id] FOREIGN KEY([PlanVersion_Id])
REFERENCES [plan].[PlanVersion] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[DepotDay] CHECK CONSTRAINT [FK_DepotDay_PlanVersion_PlanVersion_Id]
GO
ALTER TABLE [plan].[OutletDay]  WITH CHECK ADD  CONSTRAINT [FK_OutletDay_Outlet_Outlet_Id] FOREIGN KEY([Outlet_Id])
REFERENCES [data].[Outlet] ([Id])
GO
ALTER TABLE [plan].[OutletDay] CHECK CONSTRAINT [FK_OutletDay_Outlet_Outlet_Id]
GO
ALTER TABLE [plan].[OutletDay]  WITH CHECK ADD  CONSTRAINT [FK_OutletDay_PlanVersion_PlanVersion_Id] FOREIGN KEY([PlanVersion_Id])
REFERENCES [plan].[PlanVersion] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[OutletDay] CHECK CONSTRAINT [FK_OutletDay_PlanVersion_PlanVersion_Id]
GO
ALTER TABLE [plan].[OutletDayBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_OutletDayBinaryConstraint_BinaryConstraint_BinaryConstraint_Id] FOREIGN KEY([BinaryConstraint_Id])
REFERENCES [data].[BinaryConstraint] ([Id])
GO
ALTER TABLE [plan].[OutletDayBinaryConstraint] CHECK CONSTRAINT [FK_OutletDayBinaryConstraint_BinaryConstraint_BinaryConstraint_Id]
GO
ALTER TABLE [plan].[OutletDayBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_OutletDayBinaryConstraint_OutletDay_Outlet_Id_PlanVersion_Id] FOREIGN KEY([Outlet_Id], [PlanVersion_Id])
REFERENCES [plan].[OutletDay] ([Outlet_Id], [PlanVersion_Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[OutletDayBinaryConstraint] CHECK CONSTRAINT [FK_OutletDayBinaryConstraint_OutletDay_Outlet_Id_PlanVersion_Id]
GO
ALTER TABLE [plan].[Plan]  WITH CHECK ADD  CONSTRAINT [FK_Plan_PlanVersion_PlanVersion_Id] FOREIGN KEY([PlanVersion_Id])
REFERENCES [plan].[PlanVersion] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[Plan] CHECK CONSTRAINT [FK_Plan_PlanVersion_PlanVersion_Id]
GO
ALTER TABLE [plan].[PlanVersion]  WITH CHECK ADD  CONSTRAINT [FK_PlanVersion_Depot_Depot_Id] FOREIGN KEY([Depot_Id])
REFERENCES [data].[Depot] ([Id])
GO
ALTER TABLE [plan].[PlanVersion] CHECK CONSTRAINT [FK_PlanVersion_Depot_Depot_Id]
GO
ALTER TABLE [plan].[PlanVersion]  WITH CHECK ADD  CONSTRAINT [FK_PlanVersion_Instance_Instance_Id] FOREIGN KEY([Instance_Id])
REFERENCES [dbo].[Instance] ([Id])
GO
ALTER TABLE [plan].[PlanVersion] CHECK CONSTRAINT [FK_PlanVersion_Instance_Instance_Id]
GO
ALTER TABLE [plan].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Plan_Version_PlanVersion_Id] FOREIGN KEY([Version], [PlanVersion_Id])
REFERENCES [plan].[Plan] ([Version], [PlanVersion_Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[Route] CHECK CONSTRAINT [FK_Route_Plan_Version_PlanVersion_Id]
GO
ALTER TABLE [plan].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
GO
ALTER TABLE [plan].[Route] CHECK CONSTRAINT [FK_Route_Vehicle_Vehicle_Id]
GO
ALTER TABLE [plan].[Step]  WITH CHECK ADD  CONSTRAINT [FK_Step_Address_AddressEnd_Id] FOREIGN KEY([AddressEnd_Id])
REFERENCES [data].[Address] ([Id])
GO
ALTER TABLE [plan].[Step] CHECK CONSTRAINT [FK_Step_Address_AddressEnd_Id]
GO
ALTER TABLE [plan].[Step]  WITH CHECK ADD  CONSTRAINT [FK_Step_Address_AddressStart_Id] FOREIGN KEY([AddressStart_Id])
REFERENCES [data].[Address] ([Id])
GO
ALTER TABLE [plan].[Step] CHECK CONSTRAINT [FK_Step_Address_AddressStart_Id]
GO
ALTER TABLE [plan].[Step]  WITH CHECK ADD  CONSTRAINT [FK_Step_Route_Route_Id] FOREIGN KEY([Route_Id])
REFERENCES [plan].[Route] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[Step] CHECK CONSTRAINT [FK_Step_Route_Route_Id]
GO
ALTER TABLE [plan].[UnServicedDelivery]  WITH CHECK ADD  CONSTRAINT [FK_UnServicedDelivery_Delivery_Delivery_Id] FOREIGN KEY([Delivery_Id])
REFERENCES [data].[Delivery] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[UnServicedDelivery] CHECK CONSTRAINT [FK_UnServicedDelivery_Delivery_Delivery_Id]
GO
ALTER TABLE [plan].[UnServicedDelivery]  WITH CHECK ADD  CONSTRAINT [FK_UnServicedDelivery_Plan_Version_PlanVersion_Id] FOREIGN KEY([Version], [PlanVersion_Id])
REFERENCES [plan].[Plan] ([Version], [PlanVersion_Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[UnServicedDelivery] CHECK CONSTRAINT [FK_UnServicedDelivery_Plan_Version_PlanVersion_Id]
GO
ALTER TABLE [plan].[VehicleDay]  WITH CHECK ADD  CONSTRAINT [FK_VehicleDay_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [data].[Category] ([Id])
GO
ALTER TABLE [plan].[VehicleDay] CHECK CONSTRAINT [FK_VehicleDay_Category_Category_Id]
GO
ALTER TABLE [plan].[VehicleDay]  WITH CHECK ADD  CONSTRAINT [FK_VehicleDay_Driver_Driver_Id] FOREIGN KEY([Driver_Id])
REFERENCES [data].[Driver] ([Id])
GO
ALTER TABLE [plan].[VehicleDay] CHECK CONSTRAINT [FK_VehicleDay_Driver_Driver_Id]
GO
ALTER TABLE [plan].[VehicleDay]  WITH CHECK ADD  CONSTRAINT [FK_VehicleDay_Driver_DriverAssistant_Id] FOREIGN KEY([DriverAssistant_Id])
REFERENCES [data].[Driver] ([Id])
GO
ALTER TABLE [plan].[VehicleDay] CHECK CONSTRAINT [FK_VehicleDay_Driver_DriverAssistant_Id]
GO
ALTER TABLE [plan].[VehicleDay]  WITH CHECK ADD  CONSTRAINT [FK_VehicleDay_PlanVersion_PlanVersion_Id] FOREIGN KEY([PlanVersion_Id])
REFERENCES [plan].[PlanVersion] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[VehicleDay] CHECK CONSTRAINT [FK_VehicleDay_PlanVersion_PlanVersion_Id]
GO
ALTER TABLE [plan].[VehicleDay]  WITH CHECK ADD  CONSTRAINT [FK_VehicleDay_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
GO
ALTER TABLE [plan].[VehicleDay] CHECK CONSTRAINT [FK_VehicleDay_Vehicle_Vehicle_Id]
GO
ALTER TABLE [plan].[VehicleDayBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_VehicleDayBinaryConstraint_BinaryConstraint_BinaryConstraint_Id] FOREIGN KEY([BinaryConstraint_Id])
REFERENCES [data].[BinaryConstraint] ([Id])
GO
ALTER TABLE [plan].[VehicleDayBinaryConstraint] CHECK CONSTRAINT [FK_VehicleDayBinaryConstraint_BinaryConstraint_BinaryConstraint_Id]
GO
ALTER TABLE [plan].[VehicleDayBinaryConstraint]  WITH CHECK ADD  CONSTRAINT [FK_VehicleDayBinaryConstraint_VehicleDay_Vehicle_Id_PlanVersion_Id] FOREIGN KEY([Vehicle_Id], [PlanVersion_Id])
REFERENCES [plan].[VehicleDay] ([Vehicle_Id], [PlanVersion_Id])
ON DELETE CASCADE
GO
ALTER TABLE [plan].[VehicleDayBinaryConstraint] CHECK CONSTRAINT [FK_VehicleDayBinaryConstraint_VehicleDay_Vehicle_Id_PlanVersion_Id]
GO
ALTER TABLE [track].[Tracking]  WITH CHECK ADD  CONSTRAINT [FK_Tracking_Tracker_Tracker_IMEI] FOREIGN KEY([Tracker_IMEI])
REFERENCES [track].[Tracker] ([IMEI])
ON DELETE CASCADE
GO
ALTER TABLE [track].[Tracking] CHECK CONSTRAINT [FK_Tracking_Tracker_Tracker_IMEI]
GO
ALTER TABLE [track].[Tracking]  WITH CHECK ADD  CONSTRAINT [FK_Tracking_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
GO
ALTER TABLE [track].[Tracking] CHECK CONSTRAINT [FK_Tracking_Vehicle_Vehicle_Id]
GO
ALTER TABLE [track].[VehicleTracker]  WITH CHECK ADD  CONSTRAINT [FK_VehicleTracker_Tracker_Tracker_IMEI] FOREIGN KEY([Tracker_IMEI])
REFERENCES [track].[Tracker] ([IMEI])
ON DELETE CASCADE
GO
ALTER TABLE [track].[VehicleTracker] CHECK CONSTRAINT [FK_VehicleTracker_Tracker_Tracker_IMEI]
GO
ALTER TABLE [track].[VehicleTracker]  WITH CHECK ADD  CONSTRAINT [FK_VehicleTracker_Vehicle_Vehicle_Id] FOREIGN KEY([Vehicle_Id])
REFERENCES [data].[Vehicle] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [track].[VehicleTracker] CHECK CONSTRAINT [FK_VehicleTracker_Vehicle_Vehicle_Id]
GO
/****** Object:  StoredProcedure [plan].[CreatePlanVersion]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [plan].[CreatePlanVersion]
  @Instance_Id int,
  @Depot_Id int,
  @Date date,
  @Name nvarchar(100),
  @PlanVersionId int OUTPUT
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  SET NOCOUNT ON;
  SELECT @PlanVersionId = p.Id
  FROM [plan].PlanVersion p
  WHERE p.Instance_Id = @Instance_Id AND p.Depot_Id = @Depot_Id
    AND p.Name = @Name AND p.Date = @Date

  DECLARE 
    @weekDay int, 
    @now datetime

  SET DATEFIRST 1
  SELECT @now = GETDATE(), @weekDay = DATEPART(WEEKDAY, @Date)

  BEGIN TRAN
  
  BEGIN TRY
    IF (@PlanVersionId IS NULL)
    BEGIN
      INSERT INTO [plan].PlanVersion (Instance_Id,Depot_Id,[Name],[Date],Created,Modified)
      VALUES (@Instance_Id, @Depot_Id, @Name, @Date, @now, @now)

      SELECT @PlanVersionId = SCOPE_IDENTITY() 
    END

    EXEC [plan].[CreatePlanVersion_DepotDay] @PlanVersion_Id = @PlanVersionId, @Date = @Date

    EXEC [plan].[CreatePlanVersion_VehicleDay] @PlanVersion_Id = @PlanVersionId, @Date = @Date

    EXEC [plan].[CreatePlanVersion_OutletDay] @PlanVersion_Id = @PlanVersionId, @Date = @Date
    
    EXEC [plan].[CreatePlanVersion_DeliveryDay] @PlanVersion_Id = @PlanVersionId, @Date = @Date

    COMMIT TRANSACTION
    print 'Commit tran'
    RETURN 1
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION
   RETURN -1
  END CATCH
END

GO
/****** Object:  StoredProcedure [plan].[CreatePlanVersion_DeliveryDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [plan].[CreatePlanVersion_DeliveryDay]
  @PlanVersion_Id int,
  @Date date
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  SET NOCOUNT ON;
  
  declare @Id int

  SET DATEFIRST 1
  DECLARE
    @weekDay int = DATEPART(WEEKDAY, @Date)


  DECLARE @tmpDeliveryDay AS TABLE 
  --CREATE TABLE #tmpDeliveryDay -- lepsi, kvuli indexu
  (
    [Delivery_Id] [int] NOT NULL,
    [PlanVersion_Id] [int] NOT NULL,
    [DeliveryDate] [date] NOT NULL,
    [DeliveryNumber] [nvarchar](10) NOT NULL,
    [TimeFrom] [time](7) NOT NULL,
    [TimeTo] [time](7) NOT NULL,
    [TotalWeight] [real] NOT NULL,
    [TotalVolume] [real] NOT NULL,
    [TotalWeightReturn] [real] NOT NULL,
    [TotalVolumeReturn] [real] NOT NULL
    --CONSTRAINT [PK_DeliveryDay] PRIMARY KEY CLUSTERED 
    --(
     -- [Delivery_Id] ASC,
     -- [PlanVersion_Id] ASC
    --)
  ) 

  INSERT INTO @tmpDeliveryDay([Delivery_Id], [PlanVersion_Id], [DeliveryDate], [DeliveryNumber], 
    [TimeFrom], [TimeTo], 
    [TotalWeight], [TotalVolume], [TotalWeightReturn], [TotalVolumeReturn])
  SELECT 
    d.Id as [Delivery_Id], p.Id as [PlanVersion_Id], d.DeliveryDate, d.DeliveryNumber,
    d.TimeFrom, d.TimeTo,
    d.[TotalWeight], d.[TotalVolume], d.[TotalWeightReturn], d.[TotalVolumeReturn]
  FROM [plan].PlanVersion p
    INNER JOIN [plan].[OutletDay] od ON p.Id = od.[PlanVersion_Id]
    INNER JOIN [data].[Order] o on p.Depot_Id = o.Depot_Id AND od.Outlet_Id = o.Outlet_Id 
    INNER JOIN [data].Delivery d on o.Id = d.Order_Id 
  WHERE p.Id = @PlanVersion_Id AND d.DeliveryDate = @Date

  --aktualizace stavajicich
  UPDATE dd SET
    [DeliveryStatus_Id] = 1, 
    [DeliveryDate] = t.[DeliveryDate], 
    [DeliveryNumber] = t.[DeliveryNumber], 
    [TimeFrom] = t.[TimeFrom], 
    [TimeTo] = t.[TimeTo], 
    [TotalWeight] = t.[TotalWeight], 
    [TotalVolume] = t.[TotalVolume], 
    [TotalWeightReturn] = t.[TotalWeightReturn], 
    [TotalVolumeReturn] = t.[TotalVolumeReturn]
  FROM @tmpDeliveryDay t
    INNER JOIN [plan].DeliveryDay dd ON t.[Delivery_Id] = dd.[Delivery_Id] AND t.[PlanVersion_Id] = dd.[PlanVersion_Id]

  --pridani novych
  INSERT INTO [plan].DeliveryDay ([Delivery_Id], [PlanVersion_Id], 
    [DeliveryStatus_Id], [DeliveryDate], [DeliveryNumber], 
    [TimeFrom], [TimeTo], 
    [TotalWeight], [TotalVolume], [TotalWeightReturn], [TotalVolumeReturn])
  SELECT
    t.[Delivery_Id], t.[PlanVersion_Id], 1, t.[DeliveryDate], t.[DeliveryNumber], 
    t.[TimeFrom], t.[TimeTo], 
    t.[TotalWeight], t.[TotalVolume], t.[TotalWeightReturn], t.[TotalVolumeReturn]
  FROM @tmpDeliveryDay t
    LEFT JOIN [plan].DeliveryDay dd ON t.[Delivery_Id] = dd.[Delivery_Id] AND t.[PlanVersion_Id] = dd.[PlanVersion_Id]
  WHERE dd.Delivery_Id IS NULL

  --deaktivuji ty, ktere tam jsou navic
  DELETE dd
  --UPDATE dd SET IsActive = 0
  FROM [plan].DeliveryDay dd
    LEFT JOIN @tmpDeliveryDay t ON t.[Delivery_Id] = dd.[Delivery_Id] AND t.[PlanVersion_Id] = dd.[PlanVersion_Id]
  WHERE dd.PlanVersion_Id = @PlanVersion_Id AND t.[Delivery_Id] IS NULL 

  RETURN 1
END

GO
/****** Object:  StoredProcedure [plan].[CreatePlanVersion_DepotDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [plan].[CreatePlanVersion_DepotDay]
  @PlanVersion_Id int,
  @Date date
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  SET NOCOUNT ON;
  
  declare @Id int

  SET DATEFIRST 1
  DECLARE
    @weekDay int = DATEPART(WEEKDAY, @Date)


  DECLARE @tmpDepotDay AS TABLE 
  --CREATE TABLE #tmpDepotDay -- lepsi, kvuli indexu
  (
    [Depot_Id] [int] NOT NULL,
    [PlanVersion_Id] [int] NOT NULL,
    [FixArrivalTimeSeconds] [int] NOT NULL,
    [FixDepartureTimeSeconds] [int] NOT NULL,
    [FixEndOfDateTimeSeconds] [int] NOT NULL,
    [LoadingSlotsCount] [int] NOT NULL,
    [UnloadingSlotsCount] [int] NOT NULL,
    [TimeFrom] [time](7) NOT NULL,
    [TimeTo] [time](7) NOT NULL
    --CONSTRAINT [PK_DepotDay] PRIMARY KEY CLUSTERED 
    --(
     -- [Depot_Id] ASC,
     -- [PlanVersion_Id] ASC
    --)
  )

  INSERT INTO @tmpDepotDay([Depot_Id], [PlanVersion_Id], 
    [FixArrivalTimeSeconds], [FixDepartureTimeSeconds], [FixEndOfDateTimeSeconds], [LoadingSlotsCount], [UnloadingSlotsCount], 
    [TimeFrom], [TimeTo])
  SELECT 
    d.Id as [Depot_Id], 
    p.Id as [PlanVersion_Id], 
    dc.[FixArrivalTimeSeconds], dc.[FixDepartureTimeSeconds], dc.[FixEndOfDateTimeSeconds], dc.[LoadingSlotsCount], dc.[UnloadingSlotsCount],
    tf.[TimeFrom], tf.[TimeTo]
  FROM [plan].PlanVersion p
    INNER JOIN [data].Depot d ON p.Depot_Id = d.Id 
    INNER JOIN [data].DepotConfiguration dc on d.Id = dc.Depot_Id AND dbo.IsValidDate(p.Date, dc.ValidFrom, dc.ValidTo) = 1 
    INNER JOIN [data].DepotTimeFrame tfd on d.Id = tfd.Depot_Id 
    INNER JOIN [data].TimeFrame tf on tfd.TimeFrame_Id = tf.Id and tf.DayOfWeek = @weekDay AND dbo.IsValidDate(p.Date, tf.ValidFrom, tf.ValidTo) = 1 
  WHERE p.Id = @PlanVersion_Id

  --aktualizace stavajicich
  UPDATE dd SET
    [FixArrivalTimeSeconds] = t.[FixArrivalTimeSeconds], 
    [FixDepartureTimeSeconds] = t.[FixDepartureTimeSeconds], 
    [FixEndOfDateTimeSeconds] = t.[FixEndOfDateTimeSeconds], 
    [LoadingSlotsCount] = t.[LoadingSlotsCount], 
    [UnloadingSlotsCount] = t.[UnloadingSlotsCount], 
    [TimeFrom] = t.[TimeFrom], 
    [TimeTo] = t.[TimeTo]
  FROM @tmpDepotDay t
    INNER JOIN [plan].DepotDay dd ON t.[Depot_Id] = dd.[Depot_Id] AND t.[PlanVersion_Id] = dd.[PlanVersion_Id]

  --pridani novych
  INSERT INTO [plan].[DepotDay] ([Depot_Id], [PlanVersion_Id], 
    [FixArrivalTimeSeconds], [FixDepartureTimeSeconds], [FixEndOfDateTimeSeconds], [LoadingSlotsCount], [UnloadingSlotsCount], 
    [TimeFrom], [TimeTo])
  SELECT
    t.[Depot_Id], t.[PlanVersion_Id], 
    t.[FixArrivalTimeSeconds], t.[FixDepartureTimeSeconds], t.[FixEndOfDateTimeSeconds], t.[LoadingSlotsCount], t.[UnloadingSlotsCount], 
    t.[TimeFrom], t.[TimeTo]
  FROM @tmpDepotDay t
    LEFT JOIN [plan].DepotDay dd ON t.[Depot_Id] = dd.[Depot_Id] AND t.[PlanVersion_Id] = dd.[PlanVersion_Id]
  WHERE dd.Depot_Id IS NULL

  RETURN 1
END

GO
/****** Object:  StoredProcedure [plan].[CreatePlanVersion_OutletDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [plan].[CreatePlanVersion_OutletDay]
  @PlanVersion_Id int,
  @Date date
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  SET NOCOUNT ON;
  
  declare @Id int

  SET DATEFIRST 1
  DECLARE
    @weekDay int = DATEPART(WEEKDAY, @Date)


  DECLARE @tmpOutletDay AS TABLE 
  --CREATE TABLE #tmpOutletDay -- lepsi, kvuli indexu
  (
    [Outlet_Id] [int] NOT NULL,
    [PlanVersion_Id] [int] NOT NULL,
    [FixArrivalTimeSeconds] [int] NOT NULL,
    [FixDepartureTimeSeconds] [int] NOT NULL,
    [CustomerLoadingRatio] [int] NOT NULL,
    [CustomerUnloadingRatio] [int] NOT NULL,
    [TimeFrom] [time](7) NOT NULL,
    [TimeTo] [time](7) NOT NULL
    --CONSTRAINT [PK_OutletDay] PRIMARY KEY CLUSTERED 
    --(
     -- [Outlet_Id] ASC,
     -- [PlanVersion_Id] ASC
    --)
  )

  INSERT INTO @tmpOutletDay([Outlet_Id], [PlanVersion_Id], 
    [FixArrivalTimeSeconds], [FixDepartureTimeSeconds], CustomerLoadingRatio, CustomerUnloadingRatio,
    [TimeFrom], [TimeTo])
  SELECT DISTINCT 
    ot.Id as [Outlet_Id], 
    p.Id as [PlanVersion_Id], 
    oc.[FixArrivalTimeSeconds], oc.[FixDepartureTimeSeconds], oc.CustomerLoadingRatio, oc.CustomerUnloadingRatio,
    tf.[TimeFrom], tf.[TimeTo]
  FROM [plan].PlanVersion p
    INNER JOIN [data].[Order] o on p.Depot_Id = o.Depot_Id
    INNER JOIN [data].Outlet ot ON o.Outlet_Id = ot.Id 
    INNER JOIN [data].OutletConfiguration oc on ot.Id = oc.Outlet_Id AND dbo.IsValidDate(p.Date, oc.ValidFrom, oc.ValidTo) = 1 
    INNER JOIN [data].OutletTimeFrame tfo on ot.Id = tfo.Outlet_Id 
    INNER JOIN [data].TimeFrame tf on tfo.TimeFrame_Id = tf.Id and tf.DayOfWeek = @weekDay AND dbo.IsValidDate(p.Date, tf.ValidFrom, tf.ValidTo) = 1 
  WHERE p.Id = @PlanVersion_Id AND o.DeliveryDate = @Date

  --aktualizace stavajicich
  UPDATE od SET
    [FixArrivalTimeSeconds] = t.[FixArrivalTimeSeconds], 
    [FixDepartureTimeSeconds] = t.[FixDepartureTimeSeconds], 
    CustomerLoadingRatio = t.CustomerLoadingRatio, 
    CustomerUnloadingRatio = t.CustomerUnloadingRatio,
    [TimeFrom] = t.[TimeFrom], 
    [TimeTo] = t.[TimeTo]
  FROM @tmpOutletDay t
    INNER JOIN [plan].OutletDay od ON t.[Outlet_Id] = od.[Outlet_Id] AND t.[PlanVersion_Id] = od.[PlanVersion_Id]

  --pridani novych
  INSERT INTO [plan].[OutletDay] ([Outlet_Id], [PlanVersion_Id], 
    [FixArrivalTimeSeconds], [FixDepartureTimeSeconds], CustomerLoadingRatio, CustomerUnloadingRatio,
    [TimeFrom], [TimeTo])
  SELECT
    t.[Outlet_Id], t.[PlanVersion_Id], 
    t.[FixArrivalTimeSeconds], t.[FixDepartureTimeSeconds], t.CustomerLoadingRatio, t.CustomerUnloadingRatio,
    t.[TimeFrom], t.[TimeTo]
  FROM @tmpOutletDay t
    LEFT JOIN [plan].OutletDay od ON t.[Outlet_Id] = od.[Outlet_Id] AND t.[PlanVersion_Id] = od.[PlanVersion_Id]
  WHERE od.Outlet_Id IS NULL

  --deaktivuji ty, ktere tam jsou navic
  DELETE od
  --UPDATE dd SET IsActive = 0
  FROM [plan].OutletDay od
    LEFT JOIN @tmpOutletDay t ON t.[Outlet_Id] = od.[Outlet_Id] AND t.[PlanVersion_Id] = od.[PlanVersion_Id]
  WHERE od.PlanVersion_Id = @PlanVersion_Id AND t.[Outlet_Id] IS NULL 

  DECLARE @tmpBinaryConstraint AS TABLE 
  --CREATE TABLE #tmpBinaryConstraint -- lepsi, kvuli indexu
  (
    [Outlet_Id] [int] NOT NULL,
    [PlanVersion_Id] int NOT NULL,
    [BinaryConstraint_Id] [int] NOT NULL,
    [IsValid] [bit] NOT NULL
    --CONSTRAINT [PK_BinaryConstraint] PRIMARY KEY CLUSTERED 
    --(
      -- [Outlet_Id] ASC,
      -- [BinaryConstraint_Id] ASC
    --)
  ) 
  
  INSERT INTO @tmpBinaryConstraint(Outlet_Id, PlanVersion_Id, BinaryConstraint_Id, IsValid)
  SELECT 
    od.Outlet_Id,
    od.PlanVersion_Id,
    bc.Id as BinaryConstraint_Id,
    IIF(obc.Id is null, 0, 1) as IsValid
  FROM [plan].OutletDay od
    INNER JOIN [plan].PlanVersion p on od.PlanVersion_Id = p.Id
    INNER JOIN [data].BinaryConstraint bc on p.Instance_Id = bc.Instance_Id
    LEFT JOIN [data].OutletBinaryConstraint obc on od.Outlet_Id = obc.Outlet_Id AND bc.Id = obc.BinaryConstraint_Id AND dbo.IsValidDate(p.Date, obc.ValidFrom, obc.ValidTo) = 1 
  WHERE od.PlanVersion_Id = @PlanVersion_Id

  --aktualizace stavajicich
  UPDATE od SET
    [IsValid] = t.[IsValid]
  FROM @tmpBinaryConstraint t
    INNER JOIN [plan].OutletDayBinaryConstraint od ON t.Outlet_Id = od.Outlet_Id AND t.PlanVersion_Id = od.PlanVersion_Id AND t.BinaryConstraint_Id = od.BinaryConstraint_Id

  --pridani novych
  INSERT INTO [plan].OutletDayBinaryConstraint (Outlet_Id, PlanVersion_Id, BinaryConstraint_Id, IsValid)
  SELECT
    t.Outlet_Id, t.PlanVersion_Id, t.BinaryConstraint_Id, t.IsValid
  FROM @tmpBinaryConstraint t
    LEFT JOIN [plan].OutletDayBinaryConstraint od ON t.Outlet_Id = od.Outlet_Id AND t.PlanVersion_Id = od.PlanVersion_Id AND t.BinaryConstraint_Id = od.BinaryConstraint_Id
  WHERE od.Outlet_Id IS NULL

  --deaktivuji ty, ktere tam jsou navic
  --DELETE d
  UPDATE od SET IsValid = 0
  FROM [plan].OutletDayBinaryConstraint od
    LEFT JOIN @tmpBinaryConstraint t ON t.Outlet_Id = od.Outlet_Id AND t.PlanVersion_Id = od.PlanVersion_Id AND t.BinaryConstraint_Id = od.BinaryConstraint_Id
  WHERE t.Outlet_Id IS NULL 

  RETURN 1
END


GO
/****** Object:  StoredProcedure [plan].[CreatePlanVersion_VehicleDay]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [plan].[CreatePlanVersion_VehicleDay]
  @PlanVersion_Id int,
  @Date date
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  SET NOCOUNT ON;
  
  declare @Id int

  SET DATEFIRST 1
  DECLARE
    @weekDay int = DATEPART(WEEKDAY, @Date)


  DECLARE @tmpVehicleDay AS TABLE 
  --CREATE TABLE #tmpVehicleDay -- lepsi, kvuli indexu
  (
    [Vehicle_Id] [int] NOT NULL,
    [PlanVersion_Id] [int] NOT NULL,
    [Driver_Id] [int] NOT NULL,
    [DriverAssistant_Id] [int] NULL,
    [Category_Id] [int] NOT NULL,
    [DepotLoadingTimeSeconds] [int] NOT NULL,
    [DepotUnloadingTimeSeconds] [int] NOT NULL,
    [CargoCapacityVolume] [real] NOT NULL,
    [CargoCapacityWeight] [real] NOT NULL,
    [PalletsCount] [int] NOT NULL,
    [LoadingAcceleration] [int] NOT NULL,
    [UnloadingAcceleration] [int] NOT NULL,
    [MovementAcceleration] [int] NOT NULL,
    [TimeFrom] [time](7) NOT NULL,
    [TimeTo] [time](7) NOT NULL,
    [Position] [int] NOT NULL,
    [Preload] [bit] NOT NULL,
    [IsActive] [bit] NOT NULL
    --CONSTRAINT [PK_VehicleDay] PRIMARY KEY CLUSTERED 
    --(
      -- [Vehicle_Id] ASC,
      -- [PlanVersion_Id] ASC
    --)
  ) 

  INSERT INTO @tmpVehicleDay([Vehicle_Id], [PlanVersion_Id], [Driver_Id], [DriverAssistant_Id], [Category_Id], 
    [DepotLoadingTimeSeconds], [DepotUnloadingTimeSeconds], [CargoCapacityVolume], [CargoCapacityWeight], [PalletsCount], [LoadingAcceleration], [UnloadingAcceleration], [MovementAcceleration], 
    [TimeFrom], [TimeTo], [Position], [Preload], [IsActive])
  SELECT 
    v.Id as [Vehicle_Id], 
    p.Id as [PlanVersion_Id], 
    driver.Driver_Id, 
    NULL as [DriverAssistant_Id], 
    1 as [Category_Id],
    vc.[DepotLoadingTimeSeconds], vc.[DepotUnloadingTimeSeconds], vc.[CargoCapacityVolume], vc.[CargoCapacityWeight], vc.[PalletsCount], vc.[LoadingAcceleration], vc.[UnloadingAcceleration], vc.[MovementAcceleration],
    tf.[TimeFrom], tf.[TimeTo],
    v.Position, 0 as Preload, v.IsActive
  FROM [plan].PlanVersion p
    INNER JOIN [data].DepotVehicle dv ON p.Depot_Id = dv.Depot_Id AND dbo.IsValidDate(p.Date, dv.ValidFrom, dv.ValidTo) = 1 
    INNER JOIN [data].Vehicle v on dv.Vehicle_Id = v.Id
    INNER JOIN [data].VehicleConfiguration vc on v.Id = vc.Vehicle_Id AND dbo.IsValidDate(p.Date, vc.ValidFrom, vc.ValidTo) = 1 
    INNER JOIN [data].TimeFrameVehicle tfv on v.Id = tfv.Vehicle_Id 
    INNER JOIN [data].TimeFrame tf on tfv.TimeFrame_Id = tf.Id and tf.DayOfWeek = @weekDay AND dbo.IsValidDate(p.Date, tf.ValidFrom, tf.ValidTo) = 1 
    INNER JOIN [data].DriverVehicle driver on v.Id = driver.Vehicle_Id
  WHERE p.Id = @PlanVersion_Id

  --aktualizace stavajicich
  UPDATE vd SET
    [Driver_Id] = t.[Driver_Id],
    [DriverAssistant_Id] = t.[DriverAssistant_Id], 
    [Category_Id] = t.[Category_Id], 
    [DepotLoadingTimeSeconds] = t.[DepotLoadingTimeSeconds], 
    [DepotUnloadingTimeSeconds] = t.[DepotUnloadingTimeSeconds], 
    [CargoCapacityVolume] = t.[CargoCapacityVolume], 
    [CargoCapacityWeight] = t.[CargoCapacityWeight], 
    [PalletsCount] = t.[PalletsCount], 
    [LoadingAcceleration] = t.[LoadingAcceleration], 
    [UnloadingAcceleration] = t.[UnloadingAcceleration], 
    [MovementAcceleration] = t.[MovementAcceleration], 
    [TimeFrom] = t.[TimeFrom], 
    [TimeTo] = t.[TimeTo], 
    [Position] = t.[Position], 
    [Preload] = t.[Preload], 
    [IsActive] = t.[IsActive]
  FROM @tmpVehicleDay t
    INNER JOIN [plan].VehicleDay vd ON t.[Vehicle_Id] = vd.[Vehicle_Id] AND t.[PlanVersion_Id] = vd.[PlanVersion_Id]

  --pridani novych
  INSERT INTO [plan].[VehicleDay] ([Vehicle_Id], [PlanVersion_Id], [Driver_Id], [DriverAssistant_Id], [Category_Id], 
    [DepotLoadingTimeSeconds], [DepotUnloadingTimeSeconds], [CargoCapacityVolume], [CargoCapacityWeight], [PalletsCount], [LoadingAcceleration], [UnloadingAcceleration], [MovementAcceleration], 
    [TimeFrom], [TimeTo], [Position], [Preload], [IsActive])
  SELECT
    t.[Vehicle_Id], t.[PlanVersion_Id], t.[Driver_Id], t.[DriverAssistant_Id], t.[Category_Id], 
    t.[DepotLoadingTimeSeconds], t.[DepotUnloadingTimeSeconds], t.[CargoCapacityVolume], t.[CargoCapacityWeight], t.[PalletsCount], t.[LoadingAcceleration], t.[UnloadingAcceleration], t.[MovementAcceleration], 
    t.[TimeFrom], t.[TimeTo], t.[Position], t.[Preload], t.[IsActive]
  FROM @tmpVehicleDay t
    LEFT JOIN [plan].VehicleDay vd ON t.[Vehicle_Id] = vd.[Vehicle_Id] AND t.[PlanVersion_Id] = vd.[PlanVersion_Id]
  WHERE vd.Vehicle_Id IS NULL

  --deaktivuji ty, ktere tam jsou navic
  --DELETE d
  UPDATE vd SET IsActive = 0
  FROM [plan].VehicleDay vd
    LEFT JOIN @tmpVehicleDay t ON t.[Vehicle_Id] = vd.[Vehicle_Id] AND t.[PlanVersion_Id] = vd.[PlanVersion_Id]
  WHERE vd.PlanVersion_Id = @PlanVersion_Id AND t.[Vehicle_Id] IS NULL 

  DECLARE @tmpBinaryConstraint AS TABLE 
  --CREATE TABLE #tmpBinaryConstraint -- lepsi, kvuli indexu
  (
    [Vehicle_Id] [int] NOT NULL,
    [PlanVersion_Id] int NOT NULL,
    [BinaryConstraint_Id] [int] NOT NULL,
    [IsValid] [bit] NOT NULL
    --CONSTRAINT [PK_BinaryConstraint] PRIMARY KEY CLUSTERED 
    --(
      -- [Vehicle_Id] ASC,
      -- [BinaryConstraint_Id] ASC
    --)
  ) 
  
  INSERT INTO @tmpBinaryConstraint([Vehicle_Id], PlanVersion_Id, BinaryConstraint_Id, IsValid)
  SELECT 
    'Vehicle_Id' = vd.Vehicle_Id,
    'PlanVersion_Id' = vd.PlanVersion_Id,
    'BinaryConstraint_Id' = bc.Id,
    'IsValid' = IIF(vbc.Id is null, 0, 1)
  FROM [plan].VehicleDay vd
    INNER JOIN [plan].PlanVersion p on vd.PlanVersion_Id = p.Id
    INNER JOIN [data].BinaryConstraint bc on p.Instance_Id = bc.Instance_Id
    LEFT JOIN [data].VehicleBinaryConstraint vbc on vd.Vehicle_Id = vbc.Vehicle_Id and bc.Id = vbc.BinaryConstraint_Id and dbo.IsValidDate(p.Date, vbc.ValidFrom, vbc.ValidTo) = 1 
  WHERE vd.PlanVersion_Id = @PlanVersion_Id

  --aktualizace stavajicich
  UPDATE vd SET
    [IsValid] = t.[IsValid]
  FROM @tmpBinaryConstraint t
    INNER JOIN [plan].VehicleDayBinaryConstraint vd ON t.[Vehicle_Id] = vd.[Vehicle_Id] AND t.PlanVersion_Id = vd.PlanVersion_Id AND t.BinaryConstraint_Id = vd.BinaryConstraint_Id

  --pridani novych
  INSERT INTO [plan].VehicleDayBinaryConstraint ([Vehicle_Id], PlanVersion_Id, BinaryConstraint_Id, IsValid)
  SELECT
    t.[Vehicle_Id], t.PlanVersion_Id, t.BinaryConstraint_Id, t.IsValid
  FROM @tmpBinaryConstraint t
    LEFT JOIN [plan].VehicleDayBinaryConstraint vd ON t.[Vehicle_Id] = vd.[Vehicle_Id] AND t.PlanVersion_Id = vd.PlanVersion_Id AND t.BinaryConstraint_Id = vd.BinaryConstraint_Id
  WHERE vd.Vehicle_Id IS NULL

  --deaktivuji ty, ktere tam jsou navic
  --DELETE d
  UPDATE vd SET IsValid = 0
  FROM [plan].VehicleDayBinaryConstraint vd
    LEFT JOIN @tmpBinaryConstraint t ON t.[Vehicle_Id] = vd.[Vehicle_Id] AND t.PlanVersion_Id = vd.PlanVersion_Id AND t.BinaryConstraint_Id = vd.BinaryConstraint_Id
  WHERE t.[Vehicle_Id] IS NULL 

  RETURN 1
END

GO
/****** Object:  StoredProcedure [track].[InsertTracking]    Script Date: 28.04.2026 10:46:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [track].[InsertTracking]( 
	@VehicleId			INT NULL,
	@TrackerIMEI		BIGINT,
	@TrackingDateUtc	DATETIME2,
	@LocationX			FLOAT NULL,
	@LocationY			FLOAT NULL,
	@LocationZ			FLOAT NULL,
	@Speed				SMALLINT NULL,
	@Angle				SMALLINT NULL,
	@Satellites			TINYINT NULL,
	@Ignition			BIT NULL,
	@Movement			BIT NULL,
	@CreateDateUtc		DATETIME2,
	@DataJSON			NVARCHAR(MAX),
	@Version			NVARCHAR(20)
)
AS
BEGIN 
     SET NOCOUNT ON

	 DECLARE @LocationResult GEOGRAPHY = track.GetLocation(@LocationX, @LocationY, @LocationZ);

     INSERT INTO track.Tracking
	 (
		Vehicle_Id,
		Tracker_IMEI,
		TrackingDateUtc,
		[Location],
		Speed,
		Angle,
		Satellites,
		Ignition,
		Movement,
		CreateDateUtc,
		DataJSON,
		[Version]
	)
    VALUES
	(
		@VehicleId,
		@TrackerIMEI,
		@TrackingDateUtc,
		@LocationResult,
		@Speed,
		@Angle,
		@Satellites,
		@Ignition,
		@Movement,
		@CreateDateUtc,
		@DataJSON,
		@Version
	)

	RETURN SCOPE_IDENTITY();
END 
GO
USE [master]
GO
ALTER DATABASE [Apollo_SmartFleet] SET  READ_WRITE 
GO
