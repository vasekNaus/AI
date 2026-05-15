USE [master]
GO
/****** Object:  Database [Apollo_HelpDesk]    Script Date: 28.04.2026 10:44:57 ******/
CREATE DATABASE [Apollo_HelpDesk]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HelpDesk3', FILENAME = N'D:\MSSQL\2017\Data\Apollo_HelpDesk.mdf' , SIZE = 3409856KB , MAXSIZE = UNLIMITED, FILEGROWTH = 80KB ), 
 FILEGROUP [FS_File] CONTAINS FILESTREAM 
( NAME = N'FS_File', FILENAME = N'd:\MSSQL\2017\FileStream\Apollo_Helpdesk\FS_File' , MAXSIZE = UNLIMITED), 
 FILEGROUP [FS_HDAttachment] CONTAINS FILESTREAM  DEFAULT
( NAME = N'FS_HDAttachment', FILENAME = N'd:\MSSQL\2017\FileStream\Apollo_Helpdesk\FS_HDAttachment' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'HelpDesk3_log', FILENAME = N'D:\MSSQL\2017\Log\Apollo_HelpDesk.ldf' , SIZE = 1536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
GO
ALTER DATABASE [Apollo_HelpDesk] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Apollo_HelpDesk].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [Apollo_HelpDesk] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET ARITHABORT OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET AUTO_SHRINK ON 
GO
ALTER DATABASE [Apollo_HelpDesk] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Apollo_HelpDesk] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Apollo_HelpDesk] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET RECURSIVE_TRIGGERS ON 
GO
ALTER DATABASE [Apollo_HelpDesk] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Apollo_HelpDesk] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Apollo_HelpDesk] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET RECOVERY FULL 
GO
ALTER DATABASE [Apollo_HelpDesk] SET  MULTI_USER 
GO
ALTER DATABASE [Apollo_HelpDesk] SET PAGE_VERIFY TORN_PAGE_DETECTION  
GO
ALTER DATABASE [Apollo_HelpDesk] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Apollo_HelpDesk] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Apollo_HelpDesk] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [Apollo_HelpDesk] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Apollo_HelpDesk', N'ON'
GO
ALTER DATABASE [Apollo_HelpDesk] SET QUERY_STORE = OFF
GO
USE [Apollo_HelpDesk]
GO
/****** Object:  User [KARIN\Administrator]    Script Date: 28.04.2026 10:44:57 ******/
CREATE USER [KARIN\Administrator] FOR LOGIN [KARIN\Administrator] WITH DEFAULT_SCHEMA=[KARIN\Administrator]
GO
/****** Object:  User [helpdeskRep]    Script Date: 28.04.2026 10:44:57 ******/
CREATE USER [helpdeskRep] FOR LOGIN [helpdeskRep] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [helpdesk]    Script Date: 28.04.2026 10:44:57 ******/
CREATE USER [helpdesk] FOR LOGIN [helpdesk] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [KARIN\Administrator]
GO
ALTER ROLE [db_owner] ADD MEMBER [helpdesk]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [helpdesk]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [helpdesk]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [helpdesk]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [helpdesk]
GO
ALTER ROLE [db_datareader] ADD MEMBER [helpdesk]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [helpdesk]
GO
/****** Object:  Schema [acc]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [acc]
GO
/****** Object:  Schema [cfg]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [cfg]
GO
/****** Object:  Schema [crm]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [crm]
GO
/****** Object:  Schema [frm]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [frm]
GO
/****** Object:  Schema [helpdesk]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [helpdesk]
GO
/****** Object:  Schema [hr]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [hr]
GO
/****** Object:  Schema [KARIN\Administrator]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [KARIN\Administrator]
GO
/****** Object:  Schema [report]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [report]
GO
/****** Object:  Schema [wf]    Script Date: 28.04.2026 10:44:57 ******/
CREATE SCHEMA [wf]
GO
/****** Object:  UserDefinedTableType [dbo].[intTable]    Script Date: 28.04.2026 10:44:57 ******/
CREATE TYPE [dbo].[intTable] AS TABLE(
	[code] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[StateChange]    Script Date: 28.04.2026 10:44:57 ******/
CREATE TYPE [dbo].[StateChange] AS TABLE(
	[StateId] [int] NOT NULL,
	[StateNextId] [int] NOT NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[fceSelectAggregatePeriods]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fceSelectAggregatePeriods] (@sourcePeriod int, @sourceQuotient int, @targetQuotient int)
RETURNS varchar(6)
AS
BEGIN

  --IF (@sourceQuotient = @targetQuotient)
  --  RETURN  @sourcePeriod 
  --ELSE IF (@sourceQuotient < @targetQuotient)
  --  RETURN NULL 
  --ELSE
  --BEGIN
    DECLARE
      @period varchar(6);

    SET @period = CASE 
                    WHEN @targetQuotient = 1 THEN LEFT(@sourcePeriod, 4)
                    WHEN @targetQuotient = 4 AND RIGHT(@sourcePeriod, 2) IN (1, 2, 3) THEN '01'
                    WHEN @targetQuotient = 4 AND RIGHT(@sourcePeriod, 2) IN (4, 5, 6) THEN '02'
                    WHEN @targetQuotient = 4 AND RIGHT(@sourcePeriod, 2) IN (7, 8, 9) THEN '03'
                    WHEN @targetQuotient = 4 AND RIGHT(@sourcePeriod, 2) IN (10, 11, 12) THEN  '04'
                    WHEN @targetQuotient = 12 THEN RIGHT(@sourcePeriod, 2)
                    ELSE NULL
                  END 
    RETURN @period
  --END

  --RETURN NULL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fceSelectDays]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fceSelectDays] (@fromDate date, @toDate date, @onlyWorkDay bit)
RETURNS @t TABLE ([Day] date, IsWorkDay bit)
AS
BEGIN
  
  --korekce pondeli jakozto prvniho dne v tydnu
  --https://stackoverflow.com/a/54577134
  DECLARE
    @WeekStartDay int = 1
  

  IF (@fromDate <= @toDate)
  BEGIN
    WITH
    allDays AS
    (
      --prvni den
      SELECT @fromDate as DateValue 
      UNION ALL
      --dalsi den
      SELECT  DATEADD(day, 1, DateValue) as DateValue
      FROM    allDays
      WHERE   DATEADD(day, 1, DateValue) <= @toDate
    ),
    days AS
    (
      SELECT DateValue, 
        CASE WHEN ((DATEPART(dw, DateValue) + @@DATEFIRST + 6 - @WeekStartDay) % 7 + 1) IN (6, 7) THEN CAST(1 as bit) ELSE CAST(0 as bit) END as IsWeekend,
        CASE WHEN f.Day IS NOT NULL THEN CAST(1 as bit) ELSE CAST(0 as bit) END as IsFreeDay
      FROM allDays
        LEFT JOIN FreeDay f ON allDays.DateValue = f.Day
    )
    INSERT INTO @t ([day], IsWorkDay)
    SELECT DateValue, ~(IsWeekend | IsFreeDay)
    FROM days
    WHERE (@onlyWorkDay = 0) OR (@onlyWorkDay = 1 AND IsWeekend = 0 AND IsFreeDay = 0)
    OPTION (MAXRECURSION 0)
  END

  RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fceSelectNextWorkDate]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[fceSelectNextWorkDate] (@fromDate datetime, @diffSec int)
RETURNS datetime
AS
BEGIN

  DECLARE
    @d datetime;

  WITH dayTicks 
  AS
  (
    --prvni den
    SELECT CAST(@fromDate as date) as DateValue, DATEDIFF(ss, @fromDate, CAST(@fromDate+1 as date)) as ticks
    UNION ALL
    --dalsi den
    SELECT  DATEADD(day, 1, DateValue), DATEDIFF(ss, DATEADD(day, 1, DateValue), DATEADD(day, 2, DateValue)) as ticks
    FROM    dayTicks   
    WHERE   DATEADD(day, 1, DateValue) < DATEADD(year, 1, @fromDate)
  ),
  workDaysTicks
  AS
  (
    SELECT  DateValue, ticks, Sum(ticks) Over(Order By DateValue ASC Rows Between Unbounded Preceding And Current Row) As sumTicks
    FROM    dayTicks
    WHERE DATEPART(dw, DateValue) IN (1, 2, 3, 4, 5)
      AND NOT EXISTS (SELECT 1
                      FROM FreeDay f
                      WHERE f.Day = DateValue)
  )
  SELECT TOP 1 @d = DATEADD(ss, -sumTicks + @diffSec, CAST(DateValue as datetime) + 1) --odectu ty sekundy, ale od data o jeden vice...
  FROM workDaysTicks
  WHERE sumTicks >= @diffSec
  OPTION (MAXRECURSION 0)

  RETURN @d

END
GO
/****** Object:  UserDefinedFunction [dbo].[fceSelectPeriod]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fceSelectPeriod] (@date datetime, @yearQuotient int)
RETURNS int
AS
BEGIN

  DECLARE
    @period int;

  SET @period = CAST( CASE 
                        WHEN @yearQuotient = 12 THEN  RTRIM(DATEPART(YEAR, @date)) + RIGHT('0' + RTRIM(DATEPART(MONTH, @date)), 2)
                        WHEN @yearQuotient = 4 THEN   RTRIM(DATEPART(YEAR, @date)) + RIGHT('0' + RTRIM(DATEPART(QUARTER, @date)), 2)
                        WHEN @yearQuotient = 1 THEN   RTRIM(DATEPART(YEAR, @date))
                      END as int)

  RETURN @period

END
GO
/****** Object:  UserDefinedFunction [dbo].[fceSelectPeriods]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fceSelectPeriods] (@fromDate date, @toDate date, @YearQuotient int)
RETURNS @t TABLE ([Day] date, YearQuotient int, [Period] int)
AS
BEGIN

  INSERT INTO @t ([Day], [YearQuotient], [Period])
  SELECT
    d.day as [Day], @YearQuotient,
    dbo.[fceSelectPeriod](d.Day, @YearQuotient) as [Period]
  FROM [dbo].[fceSelectDays] (@fromDate, @toDate, 0) d

  RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fceSelectPrevWorkDate]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[fceSelectPrevWorkDate] (@fromDate datetime, @diffSec int)
RETURNS datetime
AS
BEGIN

  DECLARE
    @d datetime;

  WITH dayTicks  
  AS
  (
    --prvni den
    SELECT CAST(@fromDate as date) as DateValue, DATEDIFF(ss, CAST(@fromDate as date), @fromDate) as ticks
    UNION ALL
    --dalsi den
    SELECT  DATEADD(day, -1, DateValue), DATEDIFF(ss, DATEADD(day, -2, DateValue), DATEADD(day, -1, DateValue)) as ticks
    FROM    dayTicks   
    WHERE   DATEADD(day, -1, DateValue) > DATEADD(year, -1, @fromDate)
  ),
  workDaysTicks
  AS
  (
    SELECT  DateValue, ticks, Sum(ticks) Over(Order By DateValue DESC Rows Between Unbounded Preceding And Current Row) As sumTicks
    FROM    dayTicks
    WHERE DATEPART(dw, DateValue) IN (1, 2, 3, 4, 5)
      AND NOT EXISTS (SELECT 1
                      FROM FreeDay f
                      WHERE f.Day = DateValue)
  )
  SELECT TOP 1 @d = DATEADD(ss, sumTicks - @diffSec, CAST(DateValue as datetime)) --odectu ty sekundy, 
  FROM workDaysTicks
  WHERE sumTicks >= @diffSec
  OPTION (MAXRECURSION 0)

  RETURN @d

END
GO
/****** Object:  UserDefinedFunction [helpdesk].[fceGetNextTicketStatusFull]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [helpdesk].[fceGetNextTicketStatusFull] (
  @ticketId int,
  @date datetime,
  @stateId int,
  @count int
)
RETURNS @t TABLE (Id int, UserId int, ChangeDateSys datetime)
AS
BEGIN
  
  INSERT INTO @t (Id, UserId, ChangeDateSys)
  SELECT TOP (@count) ts.Id, ts.User_id, ts.ChangeDateSys
  FROM TicketStatus ts
    INNER JOIN TicketStatusFull tsf ON ts.Id = tsf.TicketStatus_id
  WHERE ts.Ticket_id = @ticketId AND ts.ChangeDateSys > @date AND tsf.State_id = @stateId

  RETURN
END
GO
/****** Object:  UserDefinedFunction [helpdesk].[fceGetSolutionTime]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [helpdesk].[fceGetSolutionTime] (
  @fromDate datetime,
  @toDate datetime,
  @timeFrom time,
  @timeTo time
)
RETURNS @t TABLE (netTime int, roughTime int)
AS
BEGIN
  
  IF (@fromDate IS NULL OR @toDate IS NULL OR @fromDate > @toDate)
  BEGIN
    INSERT INTO @t (netTime, roughTime)
		VALUES (0, 0)
  END
  ELSE IF (CAST(@fromDate as date) = CAST(@toDate as date))
  BEGIN
    INSERT INTO @t (netTime, roughTime)
		VALUES (DATEDIFF(ss, @fromDate, @toDate), DATEDIFF(ss, @fromDate, @toDate))
  END
  ELSE
  BEGIN
    WITH dayTicks 
    AS
    (
      --prvni den
      SELECT CAST(@fromDate as date) as DateValue,
        -- @fromDate as [From], CAST(CAST(@fromDate as date) as datetime) + CAST(@timeTo as datetime) as [To],
        CASE
          WHEN @fromDate > CAST(CAST(@fromDate as date) as datetime) + CAST(@timeTo as datetime) THEN 0
          ELSE DATEDIFF(ss, @fromDate, CAST(CAST(@fromDate as date) as datetime) + CAST(@timeTo as datetime)) 
        END as ticks
      UNION ALL
      --dalsi den
      SELECT  DATEADD(day, 1, DateValue), 
        --CAST(DATEADD(day, 1, DateValue) as datetime) + CAST(@timeFrom as datetime) as [From], CAST(DATEADD(day, 1, DateValue) as datetime) + CAST(@timeTo as datetime) as [To],
        CASE
          WHEN DATEADD(day, 1, DateValue) = CAST(@toDate as date) AND CAST(DATEADD(day, 1, DateValue) as datetime) + CAST(@timeFrom as datetime) >= @toDate THEN 0
          WHEN DATEADD(day, 1, DateValue) = CAST(@toDate as date) AND CAST(DATEADD(day, 1, DateValue) as datetime) + CAST(@timeFrom as datetime) < @toDate THEN DATEDIFF(ss, CAST(DATEADD(day, 1, DateValue) as datetime) + CAST(@timeFrom as datetime), @toDate) 
          ELSE DATEDIFF(ss, CAST(DATEADD(day, 1, DateValue) as datetime) + CAST(@timeFrom as datetime), CAST(DATEADD(day, 1, DateValue) as datetime) + CAST(@timeTo as datetime)) 
        END as ticks
      FROM  dayTicks
      WHERE DATEADD(day, 1, DateValue) <= @toDate
    )
    INSERT INTO @t (netTime, roughTime)
    SELECT 
      SUM(ticks) as NetTime, 
      DATEDIFF(ss, @fromDate, @toDate) as RoughTime
    FROM dayTicks
    WHERE DATEPART(dw, DateValue) IN (1, 2, 3, 4, 5)
        AND NOT EXISTS (SELECT 1
                        FROM FreeDay f
                        WHERE f.Day = DateValue)
    OPTION (MAXRECURSION 0)
  END

  RETURN
END
GO
/****** Object:  UserDefinedFunction [helpdesk].[ProjectTree]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [helpdesk].[ProjectTree] (
  @id int,
  @MaxHierarchyLevel int = NULL,
  @upDirection bit = 1
)
RETURNS @t TABLE (Id int, ParentId int, HierarchyLevel int)
AS
BEGIN
  IF (@upDirection = 1)
  BEGIN
    WITH Tree(Id, ParentId, HierarchyLevel)
    AS
    (
      SELECT p.id, p.[Project_id] as ParentId, 1 as HierarchyLevel
      FROM helpdesk.[Project] p
      WHERE p.id = @id
      UNION ALL
      SELECT p.id, p.[Project_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
      FROM helpdesk.[Project] p
        INNER JOIN Tree t ON p.id = t.ParentId 
    )
    INSERT INTO @t(Id, ParentId, HierarchyLevel)
    SELECT Id, ParentId, HierarchyLevel
    FROM Tree 
    WHERE (@MaxHierarchyLevel IS NULL OR HierarchyLevel <= @MaxHierarchyLevel)
    ORDER BY HierarchyLevel
  END
  ELSE
  BEGIN
    WITH Tree(Id, ParentId, HierarchyLevel)
    AS
    (
      SELECT p.id, p.[Project_id] as ParentId, 1 as HierarchyLevel
      FROM helpdesk.[Project] p
      WHERE p.id = @id
      UNION ALL
      SELECT p.id, p.[Project_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
      FROM helpdesk.[Project] p
        INNER JOIN Tree t ON p.[Project_id] = t.id 
    )
    INSERT INTO @t(Id, ParentId, HierarchyLevel)
    SELECT Id, ParentId, HierarchyLevel
    FROM Tree 
    WHERE (@MaxHierarchyLevel IS NULL OR HierarchyLevel <= @MaxHierarchyLevel)
    ORDER BY HierarchyLevel
  END
  
  RETURN
END
GO
/****** Object:  UserDefinedFunction [hr].[fceSelectAttendance]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [hr].[fceSelectAttendance] (@userIds dbo.intTable READONLY, @from	date, @to date)
RETURNS @t TABLE (UserId int, [Date] date, [Attendance] varchar(3), WorkedFund int, DayFund int) 
AS
BEGIN

  INSERT INTO @t (UserId, [Date], [Attendance], WorkedFund, DayFund)
	SELECT u.Id as UserId, d.day,
		CASE 
			WHEN d.IsWorkDay = 0 THEN ''
      WHEN h.Date IS NOT NULL THEN CASE 
                                      WHEN h.TotalHours > ISNULL(uHr.WorkFundHours, 8)/2 THEN 'D' 
                                      WHEN w.Date IS NULL AND toff.Date IS NULL THEN 'A/2'
                                      ELSE 'D/2'
                                    END
			WHEN w.Date IS NULL AND toff.Date IS NULL THEN 'A'
      ELSE '8'
    END as [Attendance],
    CASE 
			WHEN d.IsWorkDay = 0 THEN 0
      WHEN h.Date IS NOT NULL THEN CASE 
                                      WHEN h.TotalHours > ISNULL(uHr.WorkFundHours, 8) THEN ISNULL(uHr.WorkFundHours, 8) 
                                      WHEN w.Date IS NULL AND toff.Date IS NULL THEN ISNULL(uHr.WorkFundHours, 8) / 2
                                      ELSE ISNULL(uHr.WorkFundHours, 8)
                                    END
			WHEN w.Date IS NULL AND toff.Date IS NULL THEN 0
      ELSE ISNULL(uHr.WorkFundHours, 8)
    END as WorkedFund,
    CASE 
			WHEN d.IsWorkDay = 0 THEN 0
      ELSE ISNULL(uHr.WorkFundHours, 8)
    END as DayFund
  FROM dbo.[User] u
    INNER JOIN hr.[User] uHr ON u.Id = uHr.User_Id
    INNER JOIN @userIds ids ON u.Id = ids.Code
    CROSS JOIN [dbo].[fceSelectDays] (@from, @to, 0) d 
		LEFT JOIN ( SELECT act.User_id as UserId, Date
                FROM [hr].[Work] w 
                  INNER JOIN hr.Activity act ON w.Activity_Id = act.Id
                GROUP BY act.User_id, act.Date) w ON u.Id = w.UserId AND d.day = w.Date
    LEFT JOIN ( SELECT act.User_id as UserId, Date, SUM(Hours) as TotalHours
                FROM [hr].Holiday h 
                  INNER JOIN hr.Activity act ON h.Activity_Id = act.Id
                GROUP BY act.User_id, act.Date) h ON u.Id = h.UserId AND d.day = h.Date
    LEFT JOIN ( SELECT act.User_id as UserId, Date
                FROM [hr].TimeOff toff
                  INNER JOIN hr.Activity act ON toff.Activity_Id = act.Id
                GROUP BY act.User_id, act.Date) toff ON u.Id = toff.UserId AND d.day = toff.Date 

  RETURN
END
GO
/****** Object:  UserDefinedFunction [hr].[fceSelectMonthFund]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [hr].[fceSelectMonthFund](@fromDate date, @toDate date, @dayFund decimal(2,1))
RETURNS @t TABLE ([Year] int, [Month] int, [DaysCount] int, [Fund] decimal)
AS
BEGIN

  INSERT INTO @t ([Year], [Month], [DaysCount], [Fund])
  SELECT YEAR([day]) as [Year], Month([day]) as [Month], COUNT(*) as DaysCount, COUNT(*) * @dayFund as Fund 
  FROM dbo.fceSelectDays(@fromDate, @toDate, 1)
  GROUP BY YEAR([day]), Month([day])

  RETURN
END
GO
/****** Object:  Table [dbo].[User]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[Customer_Id] [int] NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](150) NOT NULL,
	[Login] [varchar](150) NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[IsGroup] [bit] NOT NULL,
	[Room] [varchar](500) NOT NULL,
	[Building] [varchar](500) NOT NULL,
	[Note] [varchar](max) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsRoot] [bit] NOT NULL,
	[Phone] [varchar](13) NOT NULL,
	[Mobil] [varchar](13) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[Version] [timestamp] NOT NULL,
	[NormalizedUserName] [nvarchar](256) NULL,
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
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomerUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomerUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
	[Project_Id] [int] NULL,
	[Category_Id] [int] NULL,
	[DeviceKey_Id] [int] NULL,
	[UserKey_Id] [int] NULL,
 CONSTRAINT [PK_CUSTOMERUSER] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Category]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Category](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Idx] [smallint] NOT NULL,
	[IsGroup] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[Help] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomerCategory]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomerCategory](
	[Customer_Id] [int] NOT NULL,
	[Category_Id] [int] NOT NULL,
 CONSTRAINT [PK_CustomerCategory] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC,
	[Category_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerGroup_Id] [int] NULL,
	[CustomerDepartment_Id] [int] NULL,
	[Country_Id] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Name] [varchar](150) NOT NULL,
	[Street] [varchar](100) NOT NULL,
	[City] [varchar](50) NOT NULL,
	[IC] [varchar](8) NOT NULL,
	[DIC] [varchar](10) NOT NULL,
	[Theme] [varchar](15) NOT NULL,
	[TextResources] [xml] NOT NULL,
	[Note] [varchar](max) NOT NULL,
	[Language] [char](5) NOT NULL,
	[UserPattern] [varchar](100) NOT NULL,
	[DevicePattern] [varchar](100) NOT NULL,
	[Code] [varchar](15) NOT NULL,
	[Contact] [varchar](200) NOT NULL,
	[Gps] [geography] NULL,
	[PostalCode] [varchar](5) NOT NULL,
 CONSTRAINT [PK_CUSTOMER] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vCategoryCustomerUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [helpdesk].[vCategoryCustomerUser]
AS
SELECT c.Id as CategoryId, 
  cus.Id as CustomerId, cus.Name as CustomerName, 
  u.Id as UserId, u.LastName, u.FirstName
FROM helpdesk.Category c
  INNER JOIN helpdesk.CustomerCategory cc ON c.Id = cc.Category_id
  INNER JOIN dbo.Customer cus ON cc.Customer_id = cus.Id
  LEFT JOIN helpdesk.CustomerUser cu ON c.Id = cu.Category_id
  LEFT JOIN dbo.[User] u ON cu.User_id = u.Id


GO
/****** Object:  Table [hr].[WorkDetail]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[WorkDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Work_Id] [int] NOT NULL,
	[Customer_Id] [int] NULL,
	[Project_Id] [int] NULL,
	[SolutionTime] [float] NOT NULL,
	[IsPreSales] [bit] NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[Task_Id] [int] NULL,
	[WorkType_Id] [int] NULL,
	[SolutionTimeTransport] [float] NULL,
	[SolutionTimeWork]  AS (isnull([SolutionTime]-[SolutionTimeTransport],(0))) PERSISTED NOT NULL,
 CONSTRAINT [PK_WorkDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [hr].[ProjectDepartment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[ProjectDepartment](
	[Project_Id] [int] NOT NULL,
	[Department_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserDepartmentHR] PRIMARY KEY CLUSTERED 
(
	[Project_Id] ASC,
	[Department_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Project]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Project](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Project_Id] [int] NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[Billing] [varchar](max) NOT NULL,
	[Started] [date] NULL,
	[Finished] [date] NULL,
	[Deadline] [date] NULL,
	[TargetHours] [int] NULL,
	[ProjectType_Id] [char](1) NOT NULL,
	[ServiceEffort_Id] [int] NULL,
	[EndOfWarranty] [date] NULL,
	[IsNotForReport] [bit] NOT NULL,
	[Order]  AS (isnull([Project_id],[Id])*(10000)+isnull([Project_id],(0))) PERSISTED NOT NULL,
	[IsForHelpdesk]  AS (case when [ProjectType_id]='P' then CONVERT([bit],(1),(0)) else CONVERT([bit],(0),(0)) end) PERSISTED NOT NULL,
	[IsForTimeSheet]  AS (case when [ProjectType_id]='I' OR [ProjectType_id]='O' OR [ProjectType_id]='S' OR [ProjectType_id]='C' then CONVERT([bit],(1),(0)) else CONVERT([bit],(0),(0)) end) PERSISTED NOT NULL,
 CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [hr].[Department]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Department](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [hr].[vProjectDepartment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [hr].[vProjectDepartment]
AS
WITH Tree --(Id, ParentId, HierarchyLevel)
AS
(
  SELECT p.id as ProjectId, p.[Project_id] as ParentId, pd.Department_Id as DepartmentId,
    1 as HierarchyLevel
  FROM helpdesk.Project p
    INNER JOIN hr.ProjectDepartment pd ON p.Id = pd.Project_id
  UNION ALL
  SELECT p.id as ProjectId, p.[Project_id] as ParentId, 
    t.DepartmentId,
    t.HierarchyLevel + 1 AS HierarchyLevel
  FROM helpdesk.Project p
    INNER JOIN Tree t ON p.Project_id = t.ProjectId 
),
Project
AS
(
  SELECT t.ProjectId, Max(HierarchyLevel) as MaxLevel  --OVER (PARTITION BY projectId)
  FROM Tree t
  GROUP BY t.ProjectId
)
SELECT t.ProjectId, t.DepartmentId, d.Name as DepartmentName--, t.HierarchyLevel
FROM Project p
  INNER JOIN Tree t ON t.ProjectId = p.ProjectId AND t.HierarchyLevel = p.MaxLevel
  INNER JOIN hr.Department d ON t.DepartmentId = d.Id
GO
/****** Object:  View [helpdesk].[vProject]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [helpdesk].[vProject]
AS
WITH Tree --(Id, ParentId, HierarchyLevel)
AS
(
  SELECT p.id as projectId, p.id, p.[Project_id] as ParentId, 
    CAST(p.Code as varchar(MAX)) as Code, 
    CAST(p.Name as varchar(MAX)) as Name, 
    CASE 
      WHEN ProjectType_id = 'P' THEN p.Id
      ELSE NULL
    END as ParentProjectId,
    CASE 
      WHEN ProjectType_id = 'O' THEN p.Id
      ELSE NULL
    END as ParentOrderId,
    CASE 
      WHEN ProjectType_id = 'S' THEN p.Id
      ELSE NULL
    END as ParentServiceId,
    CASE 
      WHEN ProjectType_id = 'C' THEN p.Id
      ELSE NULL
    END as ParentContinueId,
    1 as HierarchyLevel
  FROM helpdesk.Project p
  UNION ALL
  SELECT t.projectId, p.id, p.[Project_id] as ParentId, 
    CAST(p.Code as varchar(MAX)) + ' / ' + t.Code as Code, 
    CAST(p.Name as varchar(MAX)) + ' / ' + t.Name as Name, 
    CASE 
      WHEN t.ParentProjectId IS NOT NULL THEN t.ParentProjectId
      WHEN ProjectType_id = 'P' THEN p.Id
      ELSE NULL
    END as ParentProjectId,
    CASE 
      WHEN t.ParentOrderId IS NOT NULL THEN t.ParentOrderId
      WHEN ProjectType_id = 'O' THEN p.Id
      ELSE NULL
    END as ParentOrderId,
    CASE 
      WHEN t.ParentServiceId IS NOT NULL THEN t.ParentServiceId 
      WHEN ProjectType_id = 'S' THEN p.Id
      ELSE NULL
    END as ParentServiceId,
    CASE 
      WHEN t.ParentContinueId IS NOT NULL THEN t.ParentContinueId 
      WHEN ProjectType_id = 'C' THEN p.Id
      ELSE NULL
    END as ParentContinueId,
    t.HierarchyLevel + 1 AS HierarchyLevel
  FROM helpdesk.Project p
    INNER JOIN Tree t ON p.id = t.ParentId 
), Project
AS
(
  SELECT t.*, Max(HierarchyLevel) OVER (PARTITION BY projectId) as MaxLevel
  FROM Tree t
)
SELECT p.Id, p.Customer_id as CustomerId, p.IsActive, ISNULL(p.IsForHelpdesk, 0) as IsForHelpdesk, ISNULL(p.IsForTimeSheet, 0) as IsForTimeSheet, ISNULL(t.Code, '') as Code, ISNULL(t.Name, '') as Name,
  c.Code + ' / ' + ISNULL(t.Code, '') as FullCode, t.HierarchyLevel,
  p.Started, p.Finished, p.TargetHours, p.Deadline,
  STUFF(( SELECT ', ' + u.LastName + ' ' + u.FirstName
			    FROM helpdesk.CustomerUser cu
            INNER JOIN dbo.[User] u ON cu.[User_id] = u.id 
          WHERE cu.Project_id = p.id AND cu.Role_id = 4
			    FOR XML PATH('')), 1, 2, '') AS [Managers],
  STUFF(( SELECT ', ' + u.LastName + ' ' + u.FirstName
			    FROM helpdesk.CustomerUser cu
            INNER JOIN dbo.[User] u ON cu.[User_id] = u.id 
          WHERE cu.Project_id = p.id AND cu.Role_id = 11
			    FOR XML PATH('')), 1, 2, '') AS Supervisors,
  STUFF(( SELECT ',' + CAST(u.Id as varchar(5))
			    FROM helpdesk.CustomerUser cu
            INNER JOIN dbo.[User] u ON cu.[User_id] = u.id 
          WHERE cu.Project_id = p.id AND cu.Role_id = 11
			    FOR XML PATH('')), 1, 1, '') AS SupervisorIds,
  CASE 
    WHEN ProjectType_id = 'P' THEN CAST(1 as bit)
    ELSE CAST(0 as bit)
   END as IsProject,
  CASE 
    WHEN ProjectType_id = 'O' THEN CAST(1 as bit)
    ELSE CAST(0 as bit)
   END as IsOrder,
  CASE 
    WHEN ProjectType_id = 'I' THEN CAST(1 as bit)
    ELSE CAST(0 as bit)
   END as IsItem,
  CASE 
    WHEN ProjectType_id = 'S' THEN CAST(1 as bit)
    ELSE CAST(0 as bit)
   END as IsService,
  CASE 
    WHEN ProjectType_id = 'C' THEN CAST(1 as bit)
    ELSE CAST(0 as bit)
   END as IsContinue,
   ProjectType_id as ProjectTypeId,
   t.ParentProjectId,
   t.ParentOrderId,
   t.ParentServiceId,
   ISNULL(d.Department_id, pd.DepartmentId) as DepartmentId,
   p.EndOfWarranty, p.IsNotForReport
FROM helpdesk.Project p 
  INNER JOIN dbo.Customer c ON p.Customer_id = c.Id
  LEFT JOIN Project t ON t.projectId = p.Id
  LEFT JOIN
  (
    SELECT pd.Project_id, MAX(pd.Department_id) AS Department_id
    FROM hr.ProjectDepartment pd
    GROUP BY pd.Project_id
  ) d ON p.Id = d.Project_id
  LEFT JOIN hr.vProjectDepartment pd ON p.Id = pd.ProjectId
WHERE t.HierarchyLevel = t.MaxLevel 
GO
/****** Object:  View [helpdesk].[vProjectOpen]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [helpdesk].[vProjectOpen] AS
SELECT  p.Id, p.IsActive, p.Code, p.Name, p.FullCode, p.Started, p.Finished, p.TargetHours, p.Deadline, p.Managers, p.Supervisors, SUM(wd.SolutionTime) AS SolutionTime
FROM helpdesk.vProject p
 CROSS APPLY [helpdesk].[ProjectTree](p.Id, NULL, 0) t
 LEFT JOIN hr.WorkDetail wd ON t.Id = wd.Project_id
WHERE 
 Finished is null AND--přidáno
 IsOrder = 1 --přidáno
GROUP BY p.Id, p.IsActive, p.Code, p.Name, p.FullCode, p.Started, p.Finished, p.TargetHours, p.Deadline, p.Managers, p.Supervisors
GO
/****** Object:  Table [hr].[Activity]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Activity](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[SysDate] [datetime] NOT NULL,
	[IsClosed] [bit] NOT NULL,
	[Note] [varchar](500) NULL,
	[ActivityTemplate_Id] [int] NULL,
 CONSTRAINT [PK_Activity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Work]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Work](
	[Activity_Id] [int] NOT NULL,
	[From] [time](0) NOT NULL,
	[To] [time](0) NOT NULL,
	[IsHomeOffice] [bit] NOT NULL,
	[Department_Id] [int] NOT NULL,
 CONSTRAINT [PK_Work] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [hr].[vWorkTime]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [hr].[vWorkTime]
AS
WITH
x AS
(
  SELECT 
    a.User_id,
    a.Date,
    w.[Department_Id],
    SUM(CASE WHEN w.IsHomeOffice = 1 
             THEN DATEDIFF(MINUTE, w.[From], w.[To]) 
             ELSE 0 END) AS HomeOfficeMinutes,
    SUM(CASE WHEN w.IsHomeOffice = 0 
             THEN DATEDIFF(MINUTE, w.[From], w.[To]) 
             ELSE 0 END) AS OfficeMinutes
  FROM hr.Work w
    INNER JOIN hr.Activity a ON w.Activity_Id = a.Id
  GROUP BY a.User_id, a.Date, [Department_Id]
)
SELECT 
  x.User_id as UserId,
  x.Date,
  x.[Department_Id] as DepartmentId,
  x.HomeOfficeMinutes,
  x.OfficeMinutes,
  x.HomeOfficeMinutes + x.OfficeMinutes AS TotalMinutes,
  CASE WHEN (x.HomeOfficeMinutes + x.OfficeMinutes) = 0 THEN 0 ELSE CAST(HomeOfficeMinutes as decimal) / CAST((x.HomeOfficeMinutes + x.OfficeMinutes) as decimal) END as HomeOfficePercentage,
  CASE WHEN (x.HomeOfficeMinutes + x.OfficeMinutes) = 0 THEN 0 ELSE CAST(OfficeMinutes as decimal) / CAST((x.HomeOfficeMinutes + x.OfficeMinutes) as decimal) END as OfficePercentage,
  CASE WHEN OfficeMinutes = 0 THEN 0 ELSE CAST(HomeOfficeMinutes as decimal) / CAST(OfficeMinutes as decimal) END as HomeOfficeRatio
FROM x
GO
/****** Object:  View [hr].[vWorkDetail]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [hr].[vWorkDetail]
AS
SELECT 
  CONVERT(date, a.[Date], 104) as [Date],
  a.[User_Id] as UserId,
  wd.[Customer_Id] as CustomerId,
  wd.[Project_id] as ProjectId,
  wd.IsPreSales,
  SUM(wd.SolutionTime) as SolutionTime,
  COUNT_BIG(*) as Cnt
FROM hr.WorkDetail wd
  INNER JOIN hr.Activity a ON wd.Work_id = a.Id
WHERE CONVERT(date, a.[Date], 104) >= CONVERT(date, '1.8.2018', 104) 
GROUP BY CONVERT(date, a.[Date], 104), a.[User_Id], wd.[Customer_Id], wd.[Project_id], wd.IsPreSales
GO
/****** Object:  View [dbo].[vUserParents]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vUserParents]
AS
WITH Tree(Id, ParentId, HierarchyLevel, Ids)
AS
(
  SELECT u.id, u.[User_id] as ParentId, 1 as HierarchyLevel, CAST('' as varchar(MAX))  as Ids
  FROM dbo.[User] u
  WHERE u.User_id IS NULL
  UNION ALL
  SELECT u.id, u.[User_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel, t.Ids + 
    CASE 
      WHEN u.User_id IS NULL THEN '' 
      ELSE ',' + CAST(u.[User_id] as varchar(MAX)) 
    END as Ids
  FROM dbo.[User] u
    INNER JOIN Tree t ON t.id = u.User_id  
)
SELECT t.Id as UserId, t.ParentId as UserParentId, parent.User_id as UserParentParentId, SUBSTRING(Ids,2, LEN(Ids)) as ParentIds
FROM Tree t
  LEFT JOIN dbo.[User] parent ON t.ParentId = parent.Id


GO
/****** Object:  View [hr].[vWorkSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [hr].[vWorkSummary] --with schemabinding
AS
WITH work 
AS 
(
  SELECT [Date], [UserId], [CustomerId], [ProjectId], [IsPreSales], [SolutionTime], [Cnt]
  FROM hr.vWorkDetail
)
SELECT work.[Date], work.UserId, work.CustomerId, work.ProjectId, work.IsPreSales, work.SolutionTime, work.Cnt,
  u.UserParentId, u.UserParentParentId, u.ParentIds,
  p.ParentProjectId, p.ParentOrderId, p.ParentServiceId
FROM work
  INNER JOIN dbo.vUserParents u ON work.UserId = u.UserId
  INNER JOIN [helpdesk].[vProject] p ON work.ProjectId = p.Id
GO
/****** Object:  Table [hr].[Illness]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Illness](
	[Activity_Id] [int] NOT NULL,
 CONSTRAINT [PK_ILLNESS] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Holiday]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Holiday](
	[Activity_Id] [int] NOT NULL,
	[IsHalfDay] [bit] NOT NULL,
	[Hours] [int] NOT NULL,
 CONSTRAINT [PK_Holiday] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[WorkShop]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[WorkShop](
	[Activity_Id] [int] NOT NULL,
	[From] [time](0) NOT NULL,
	[To] [time](0) NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_WORKSHOP] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[SickDay]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[SickDay](
	[Activity_Id] [int] NOT NULL,
 CONSTRAINT [PK_SICKDAY] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Doctor]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Doctor](
	[Activity_Id] [int] NOT NULL,
	[From] [time](0) NOT NULL,
	[To] [time](0) NOT NULL,
 CONSTRAINT [PK_DOCTOR] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [hr].[vActivitySummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [hr].[vActivitySummary]
AS
SELECT [Type], [Date], UserId, TotalDuration
FROM
(
  SELECT
    'work' as [Type], 
	  a.[Date],
	  a.[User_Id] as UserId,
    SUM(DATEDIFF(SECOND, w.[From], w.[To]) / 3600.0) as TotalDuration
  FROM hr.Activity a
    INNER JOIN hr.Work w ON a.Id = w.Activity_Id  
  GROUP BY a.[Date], a.[User_Id]
  UNION
  SELECT
    'doctor' as [Type], 
	  a.[Date],
	  a.[User_Id] as UserId,
    SUM(DATEDIFF(SECOND, d.[From], d.[To]) / 3600.0) as TotalDuration
  FROM hr.Activity a
    INNER JOIN hr.Doctor d ON a.Id = d.Activity_Id  
  GROUP BY a.[Date], a.[User_Id]
  UNION
  SELECT
    'holiday' as [Type], 
	  a.[Date],
	  a.[User_Id] as UserId,
    SUM(CASE WHEN h.IsHalfDay = 1 THEN 4 ELSE 8 END) as TotalDuration
  FROM hr.Activity a
    INNER JOIN hr.Holiday h ON a.Id = h.Activity_Id  
  GROUP BY a.[Date], a.[User_Id]
  UNION
  SELECT
    'illness' as [Type], 
	  a.[Date],
	  a.[User_Id] as UserId,
    8 as TotalDuration
  FROM hr.Activity a
    INNER JOIN hr.Illness i ON a.Id = i.Activity_Id  
  GROUP BY a.[Date], a.[User_Id]
  UNION
  SELECT
    'sickdays' as [Type], 
	  a.[Date],
	  a.[User_Id] as UserId,
    8 as TotalDuration
  FROM hr.Activity a
    INNER JOIN hr.SickDay s ON a.Id = s.Activity_Id  
  GROUP BY a.[Date], a.[User_Id]
  UNION
  SELECT
    'workshop' as [Type], 
	  a.[Date],
	  a.[User_Id] as UserId,
    SUM(DATEDIFF(SECOND, ws.[From], ws.[To]) / 3600.0) as TotalDuration
  FROM hr.Activity a
    INNER JOIN hr.WorkShop ws ON a.Id = ws.Activity_Id  
  GROUP BY a.[Date], a.[User_Id]
) v
WHERE v.[Date] >= '1.8.2018'
GO
/****** Object:  Table [helpdesk].[TicketStatus]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[ChangeDateSys] [datetime2](7) NOT NULL,
	[Response] [varchar](max) NOT NULL,
	[IsExternal] [bit] NOT NULL,
	[ResponseOriginal] [varchar](max) NOT NULL,
	[ResponseInternal] [varchar](max) NOT NULL,
	[ChangeDate] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_TicketStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[WatchDogMail]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[WatchDogMail](
	[WatchDog_Id] [int] NOT NULL,
	[Role_Id] [int] NULL,
	[UserGroup_Id] [int] NULL,
 CONSTRAINT [PK_WATCHDOGMAIL] PRIMARY KEY CLUSTERED 
(
	[WatchDog_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[TicketAlert]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketAlert](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[TicketStatus_Id] [int] NOT NULL,
	[WatchDog_Id] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
 CONSTRAINT [PK_TICKETALERT] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Ticket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Ticket](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsChanged] [bit] NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[Title] [varchar](300) NOT NULL,
	[RequestUser] [varchar](100) NOT NULL,
	[Project_Id] [int] NULL,
	[Classification_Id] [int] NULL,
	[Category_Id] [int] NULL,
	[iSablona_id] [int] NULL,
	[StatusTicketLast_Id] [int] NULL,
	[StatusTicketFirst_Id] [int] NULL,
	[CustomField1] [varchar](500) NULL,
	[CustomField2] [varchar](500) NULL,
	[CustomerDepartment_Id] [int] NULL,
	[NumberEx] [varchar](20) NULL,
 CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vTicketAlertMail]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [helpdesk].[vTicketAlertMail] with schemabinding
AS
SELECT 
  t.id as TicketID,
  tsLast.id TicketStatusID,
  COUNT_BIG(*) as Counts
FROM helpdesk.Ticket t
  INNER JOIN helpdesk.TicketStatus tsLast ON t.StatusTicketLast_id = tsLast.Id
  INNER JOIN helpdesk.TicketAlert ta ON tsLast.id = ta.TicketStatus_id
  INNER JOIN helpdesk.WatchDogMail wd ON ta.WatchDog_id = wd.WatchDog_id
GROUP BY t.id, tsLast.Id
GO
/****** Object:  Table [helpdesk].[WatchDogState]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[WatchDogState](
	[WatchDog_Id] [int] NOT NULL,
	[StateNew_Id] [int] NOT NULL,
 CONSTRAINT [PK_WATCHDOGSTATE] PRIMARY KEY CLUSTERED 
(
	[WatchDog_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vTicketAlertState]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [helpdesk].[vTicketAlertState] with schemabinding
AS
SELECT 
  t.id as TicketID,
  tsLast.id TicketStatusID,
  COUNT_BIG(*) as Counts
FROM helpdesk.Ticket t
  INNER JOIN helpdesk.TicketStatus tsLast ON t.StatusTicketLast_id = tsLast.Id
  INNER JOIN helpdesk.TicketAlert ta ON tsLast.id = ta.TicketStatus_id
  INNER JOIN helpdesk.WatchDogState wd ON ta.WatchDog_id = wd.WatchDog_id
GROUP BY t.id, tsLast.Id
GO
/****** Object:  Table [helpdesk].[TicketUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TicketStatus_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[Role_Id] [int] NOT NULL,
	[UserExt] [varchar](100) NULL,
	[IsGuarantor] [bit] NOT NULL,
	[ReadDate] [datetime2](0) NULL,
 CONSTRAINT [PK_TicketUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vTicketActRead]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [helpdesk].[vTicketActRead]
AS
SELECT t.Id as TicketId, ISNULL(tu.User_id, ts.User_id) as UserId, MIN(CASE WHEN ISNULL(tu.User_id, ts.User_id) = ts.[User_Id]  THEN ts.ChangeDateSys ELSE tu.ReadDate END) as ReadDate
FROM [helpdesk].[Ticket] t
  INNER JOIN [helpdesk].[TicketStatus] ts ON t.StatusTicketLast_id = ts.Id 
  LEFT JOIN [helpdesk].[TicketUser] tu ON t.StatusTicketLast_id = tu.TicketStatus_id
WHERE tu.User_id IS NOT NULL --AND tu.ReadDate IS NOT NULL 
GROUP BY t.Id, tu.User_Id, ts.User_id
GO
/****** Object:  View [helpdesk].[vTicketStatusActRead]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [helpdesk].[vTicketStatusActRead]
AS
SELECT ts.Ticket_Id as TicketId, ts.Id as TicketStatusId, ISNULL(tu.User_id, ts.User_id) as UserId, MIN(CASE WHEN ISNULL(tu.User_id, ts.User_id) = ts.[User_Id]  THEN ts.ChangeDateSys ELSE tu.ReadDate END) as ReadDate
FROM [helpdesk].[TicketStatus] ts 
  LEFT JOIN [helpdesk].[TicketUser] tu ON ts.Id = tu.TicketStatus_id
WHERE tu.User_id IS NOT NULL --AND tu.ReadDate IS NOT NULL 
GROUP BY ts.Ticket_Id, ts.Id, tu.User_Id, ts.User_id
GO
/****** Object:  View [helpdesk].[vTicketStatusSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [helpdesk].[vTicketStatusSummary] with schemabinding
AS
SELECT 
  ts.Ticket_id as TicketID,
  ts.Id as TicketStatusID,
  STUFF((  SELECT ', ' + ISNULL(u.LastName + ' ' + u.FirstName, tu.UserExt)
			          FROM helpdesk.TicketUser tu
                  LEFT JOIN dbo.[User] u ON tu.[User_id] = u.id 
                WHERE tu.TicketStatus_id = ts.id AND tu.Role_id = 0
			          FOR XML PATH('')), 1, 1, '') AS [SolveUsers],
  STUFF((  SELECT ', ' + ISNULL(u.LastName + ' ' + u.FirstName, tu.UserExt)
			          FROM helpdesk.TicketUser tu
                  LEFT JOIN dbo.[User] u ON tu.[User_id] = u.id 
                WHERE tu.TicketStatus_id = ts.id AND tu.Role_id = 1
			          FOR XML PATH('')), 1, 1, '') AS [InformUsers]
FROM helpdesk.TicketStatus ts
GO
/****** Object:  Table [helpdesk].[TicketStatusFull]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketStatusFull](
	[TicketStatus_Id] [int] NOT NULL,
	[State_Id] [int] NOT NULL,
	[SubState_Id] [int] NULL,
	[Priority_Id] [int] NOT NULL,
	[RequestDate] [datetime] NULL,
	[EstimatedDate] [datetime] NULL,
	[SolutionTime] [float] NOT NULL,
	[StateNext_Id] [int] NULL,
 CONSTRAINT [PK_TicketStatusFull] PRIMARY KEY CLUSTERED 
(
	[TicketStatus_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DeviceTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DeviceTicket](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[Device_Id] [int] NULL,
	[DeviceName] [varchar](100) NOT NULL,
	[IsSolved] [bit] NOT NULL,
	[SolveNote] [varchar](100) NOT NULL,
 CONSTRAINT [PK_DEVICETICKET] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Device]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Device](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Device_Id] [int] NULL,
	[Customer_Id] [int] NOT NULL,
	[DeviceType_Id] [int] NULL,
	[DeviceTpl_Id] [int] NULL,
	[Name] [varchar](300) NOT NULL,
	[IsGroup] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Note] [varchar](max) NOT NULL,
	[SerialNumber] [varchar](50) NOT NULL,
	[Room] [varchar](50) NOT NULL,
	[Building] [varchar](50) NOT NULL,
	[InventaryNumber] [varchar](50) NOT NULL,
	[HasDeviceBook] [bit] NOT NULL,
 CONSTRAINT [PK_Device] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vTicketSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [helpdesk].[vTicketSummary] 
AS
SELECT 
  t.id as TicketID,
  SumSolutionTime,
  ISNULL(taMail.Counts, 0) as TicketAlertsMail,
  ISNULL(taState.Counts, 0) as TicketAlertsState,
  STUFF((  SELECT ', ' + ISNULL(u.LastName + ' ' + u.FirstName, tu.UserExt)
			          FROM helpdesk.TicketUser tu
                  LEFT JOIN dbo.[User] u ON tu.[User_id] = u.id 
                WHERE tu.TicketStatus_id = tsLast.id AND tu.Role_id IN (0, 7)
			          FOR XML PATH('')), 1, 1, '') AS [SolveUsers],
  STUFF((  SELECT ', ' + ISNULL(u.LastName + ' ' + u.FirstName, tu.UserExt)
			          FROM helpdesk.TicketUser tu
                  LEFT JOIN dbo.[User] u ON tu.[User_id] = u.id 
                WHERE tu.TicketStatus_id = tsLast.id AND tu.Role_id = 1
			          FOR XML PATH('')), 1, 1, '') AS [InformUsers],
  STUFF((  SELECT ',' + CAST(tu.User_id as varchar(100))
			          FROM helpdesk.TicketUser tu
                WHERE tu.TicketStatus_id = tsLast.id AND tu.Role_id = 0 AND tu.User_id IS NOT NULL
			          FOR XML PATH('')), 1, 1, '') AS [TicketSolveIds],
  STUFF((  SELECT ',' + CAST(tu.User_id as varchar(100))
			          FROM helpdesk.TicketUser tu
                WHERE tu.TicketStatus_id = tsLast.id AND tu.Role_id = 7 AND tu.User_id IS NOT NULL
			          FOR XML PATH('')), 1, 1, '') AS [TicketHandOverIds],
  STUFF((  SELECT ',' + CAST(tu.User_id as varchar(100))
			          FROM helpdesk.TicketUser tu
                WHERE tu.TicketStatus_id = tsLast.id AND tu.Role_id = 1 AND tu.User_id IS NOT NULL
			          FOR XML PATH('')), 1, 1, '') AS [TicketInformIds],
  STUFF((  SELECT ', ' + ISNULL(d.Name, dt.DeviceName)
			          FROM helpdesk.DeviceTicket dt
                  LEFT JOIN dbo.Device d ON dt.Device_id = d.id
                WHERE dt.Ticket_id = t.id
			          FOR XML PATH('')), 1, 1, '') AS [DeviceText]
FROM helpdesk.Ticket t
  INNER JOIN helpdesk.TicketStatus tsLast ON t.StatusTicketLast_id = tsLast.Id
/*  INNER JOIN helpdesk.TicketStatusFull tsFull ON tsLast.Id = tsFull.TicketStatus_Id*/
  LEFT JOIN helpdesk.vTicketAlertMail taMail ON t.Id = taMail.TicketID
  LEFT JOIN helpdesk.vTicketAlertState taState ON t.Id = taState.TicketID
  INNER JOIN (SELECT ts.Ticket_id, SUM(tsf.SolutionTime) as SumSolutionTime
              FROM helpdesk.TicketStatusFull tsf
                INNER JOIN helpdesk.TicketStatus ts ON tsf.TicketStatus_id = ts.id
              GROUP BY Ticket_id) s ON t.id = s.Ticket_id
GO
/****** Object:  Table [frm].[TaskGroup]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[TaskGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Customer_Id] [int] NOT NULL,
 CONSTRAINT [PK_TaskGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[TaskGroupUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[TaskGroupUser](
	[TaskGroup_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
 CONSTRAINT [PK_TASKGROUPUSER] PRIMARY KEY CLUSTERED 
(
	[TaskGroup_Id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[TaskGroupUserGroup]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[TaskGroupUserGroup](
	[TaskGroup_Id] [int] NOT NULL,
	[UserGroup_Id] [int] NOT NULL,
 CONSTRAINT [PK_TASKGROUPUSERGROUP] PRIMARY KEY CLUSTERED 
(
	[TaskGroup_Id] ASC,
	[UserGroup_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[Form]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[Form](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[VariantName] [varchar](50) NOT NULL,
	[DateName] [varchar](50) NOT NULL,
	[ControlId] [varchar](100) NOT NULL,
 CONSTRAINT [PK_FORM] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[FormTaskGroup]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[FormTaskGroup](
	[Form_Id] [int] NOT NULL,
	[TaskGroup_Id] [int] NOT NULL,
 CONSTRAINT [PK_FORMTASKGROUP] PRIMARY KEY CLUSTERED 
(
	[Form_Id] ASC,
	[TaskGroup_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[UserGroupMember]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[UserGroupMember](
	[UserGroup_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserGroupMember] PRIMARY KEY CLUSTERED 
(
	[UserGroup_Id] ASC,
	[User_Id] ASC,
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [frm].[vFormUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [frm].[vFormUser]
AS
SELECT f.Id as FormId, tg.Id as TaskGroupId, u.Id as UserId, u.FirstName, u.LastName, 0 as RoleId
FROM frm.Form f 
  INNER JOIN frm.FormTaskGroup ftg ON f.Id = ftg.Form_id
  INNER JOIN frm.TaskGroup tg ON ftg.TaskGroup_id = tg.Id
  INNER JOIN frm.TaskGroupUser tgu ON tg.Id = tgu.TaskGroup_id
  INNER JOIN dbo.[User] u ON tgu.User_id = u.Id
UNION 
SELECT f.Id as FormId, tg.Id as TaskGroupId, u.Id as UserId, u.FirstName, u.LastName, ugm.Role_id as RoleId
FROM frm.Form f 
  INNER JOIN frm.FormTaskGroup ftg ON f.Id = ftg.Form_id
  INNER JOIN frm.TaskGroup tg ON ftg.TaskGroup_id = tg.Id
  INNER JOIN frm.TaskGroupUserGroup tgug ON tg.Id = tgug.TaskGroup_id
  INNER JOIN helpdesk.UserGroupMember ugm ON tgug.UserGroup_id = ugm.UserGroup_id
  INNER JOIN dbo.[User] u ON ugm.User_id = u.Id
GO
/****** Object:  View [helpdesk].[vTicketUserSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [helpdesk].[vTicketUserSummary]
AS
SELECT t.Id as TicketId, u.LastName, u.FirstName, 
  ISNULL(tu.User_id, 0) as User_id, tu.UserExt, tu.IsGuarantor, tu.Role_id
FROM [helpdesk].[Ticket] t
  INNER JOIN [helpdesk].[TicketStatus] ts ON t.StatusTicketLast_id = ts.Id 
  INNER JOIN [helpdesk].[TicketUser] tu ON ts.Id = tu.TicketStatus_id
  LEFT JOIN [dbo].[User] u ON tu.User_id = u.Id
GO
/****** Object:  Table [helpdesk].[Customer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Customer](
	[Customer_Id] [int] NOT NULL,
	[Smstype_Id] [int] NULL,
	[EmailType_Id] [int] NULL,
	[TrimSms] [bit] NOT NULL,
	[HtmlMail] [bit] NOT NULL,
	[RecursivePermission] [bit] NOT NULL,
	[HasDefaultCategories] [bit] NOT NULL,
	[HasDefaultClassifications] [bit] NOT NULL,
	[DefaultRequiredDate] [int] NULL,
	[DefaultEstimatedDate] [int] NULL,
	[IsCategoryRequired] [bit] NOT NULL,
	[AttachmentForUser] [bit] NOT NULL,
	[InfoOnlyLastTicketState] [bit] NOT NULL,
	[IsDeviceRequired] [bit] NOT NULL,
	[HasBoard] [bit] NOT NULL,
	[HasRanking] [bit] NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vCustomerSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create VIEW [helpdesk].[vCustomerSummary] with schemabinding
AS
SELECT c.Customer_Id as CustomerId, tsf.State_id as StateId, COUNT_BIG(*) as TicketCount 
FROM helpdesk.Customer c
  INNER JOIN helpdesk.Ticket t ON c.Customer_Id = t.Customer_id
  INNER JOIN helpdesk.TicketStatus ts ON t.StatusTicketLast_id = ts.id
  INNER JOIN helpdesk.TicketStatusFull tsf ON ts.id = tsf.TicketStatus_id
GROUP BY c.Customer_Id, tsf.State_id
GO
/****** Object:  Table [hr].[ServiceEffort]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[ServiceEffort](
	[Id] [int] NOT NULL,
	[Name] [varchar](20) NOT NULL,
	[YearQuotient] [int] NOT NULL,
 CONSTRAINT [PK_ServiceEffort] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Classification]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Classification](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[ShortName] [varchar](10) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Idx] [smallint] NOT NULL,
	[IsGroup] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[IsGratis] [bit] NOT NULL,
 CONSTRAINT [PK_Classification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vProjectOngoing]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [helpdesk].[vProjectOngoing]
AS
WITH workdetails
AS
(
  SELECT [Date], [ProjectId], SUM(SolutionTime) AS SolutionTime
  FROM hr.vWorkDetail
  GROUP BY [Date], [ProjectId]
),
helpdeskdetails
AS
(
  SELECT t.Project_id as ProjectId, CAST(ts.ChangeDateSys as date) as [Date], 
    SUM(CASE WHEN c.IsGratis = 0 THEN tsf.SolutionTime ELSE 0 END) AS SolutionTimePay,
    SUM(CASE WHEN c.IsGratis = 1 THEN tsf.SolutionTime ELSE 0 END) AS SolutionTimeGratis,
    SUM(CASE WHEN c.Id IS NULL THEN tsf.SolutionTime ELSE 0 END) AS SolutionTimeWithoutClassification
  FROM helpdesk.TicketStatusFull tsf
    INNER JOIN helpdesk.TicketStatus ts ON tsf.TicketStatus_id = ts.Id
    INNER JOIN helpdesk.Ticket t ON ts.Ticket_id = t.Id
    LEFT JOIN helpdesk.[Classification] c ON t.Classification_id = c.Id
  WHERE t.Project_id IS NOT NULL AND tsf.SolutionTime > 0
  GROUP BY t.Project_id, CAST(ts.ChangeDateSys as date)
  --ORDER BY CAST(ts.ChangeDateSys as date) DESC
),
projects
AS
(
  SELECT vp.CustomerId, vp.Id, vp.IsActive, vp.Code, vp.Name, vp.FullCode, vp.Started, vp.Finished, vp.TargetHours, vp.Deadline, vp.Managers, vp.Supervisors, vp.ParentProjectId,
    se.YearQuotient,
    d.MinDate, d.MaxDate
  FROM helpdesk.vProject vp
    INNER JOIN helpdesk.Project p ON vp.Id = p.Id
    INNER JOIN hr.ServiceEffort se ON p.ServiceEffort_id = se.Id
    LEFT JOIN ( SELECT [ProjectId], MIN([Date]) as MinDate, MAX([Date]) as MaxDate
                FROM hr.vWorkDetail
                GROUP BY [ProjectId]) d ON vp.Id = d.ProjectId
  WHERE 
    IsContinue = 1 --přidáno
),
result
as
(
  SELECT projects.CustomerId, projects.Id, projects.IsActive, projects.Code, projects.Name, projects.FullCode, projects.Started, projects.Finished, projects.TargetHours, 
    projects.Deadline, projects.Managers, projects.Supervisors, projects.YearQuotient, 
    per.Period, 
    SUM(wd.SolutionTime) AS SolutionTime,
    SUM(hd.SolutionTimePay) AS SolutionTimeHDPaid,
    SUM(hd.SolutionTimeGratis) AS SolutionTimeHDGratis,
    SUM(hd.SolutionTimeWithoutClassification) AS SolutionTimeHDWithoutClassification 
  FROM projects
    --vygeneruju rastr period od zacatku projektu (pokud neni, tak od prvnih vykazani) do konce (pokud neni, tak do konce roku, kde je vykaz
    CROSS APPLY [dbo].[fceSelectPeriods](
      ISNULL(projects.Started, projects.MinDate), 
      --COALESCE(projects.Finished, DATEFROMPARTS(YEAR(projects.MaxDate),12,31), DATEFROMPARTS(YEAR(GETDATE()), 12, 31)), projects.YearQuotient) per
      COALESCE(projects.Finished, projects.MaxDate, GETDATE()), projects.YearQuotient) per
    LEFT JOIN workdetails wd ON projects.Id = wd.[ProjectId] AND per.[Day] = wd.[Date] 
    LEFT JOIN helpdeskdetails hd ON projects.ParentProjectId = hd.[ProjectId] AND per.[Day] = hd.[Date] 
  GROUP BY projects.CustomerId, projects.Id, projects.IsActive, projects.Code, projects.Name, projects.FullCode, projects.Started, projects.Finished, projects.TargetHours, 
    projects.Deadline, projects.Managers, projects.Supervisors, projects.YearQuotient, 
    projects.Deadline, projects.Managers, projects.Supervisors, projects.YearQuotient, 
    per.Period
)
SELECT CAST(result.Id as varchar(MAX)) + CAST(result.Period as varchar(MAX)) as Id, 
    result.Id as ProjectId, 
    result.CustomerId, result.IsActive, result.Code, result.Name, result.FullCode, result.Started, result.Finished,
    --, result.TargetHours, 
    result.Deadline, result.Managers, result.Supervisors,
    --result.YearQuotient, 
    result.Period,  
    [dbo].[fceSelectAggregatePeriods] (result.Period, result.YearQuotient, 1) as PeriodY,
    [dbo].[fceSelectAggregatePeriods] (result.Period, result.YearQuotient, 4) as  PeriodQ,
    [dbo].[fceSelectAggregatePeriods] (result.Period, result.YearQuotient, 12) as  PeriodM,
    ISNULL(result.SolutionTime, 0) as SolutionTime, 
    ISNULL(result.SolutionTimeHDPaid, 0) as SolutionTimeHDPaid, 
    ISNULL(result.SolutionTimeHDGratis, 0) as SolutionTimeHDGratis, 
    ISNULL(result.SolutionTimeHDWithoutClassification, 0) as SolutionTimeHDWithoutClassification,
    ISNULL(result.SolutionTimeHDPaid, 0) + ISNULL(result.SolutionTimeHDGratis, 0) + ISNULL(result.SolutionTimeHDWithoutClassification, 0) as SolutionTimeHD,
    ISNULL(result.SolutionTime, 0) - ISNULL(result.SolutionTimeHDPaid, 0) as SolutionTimeCoveredByFee  
FROM result
GO
/****** Object:  View [helpdesk].[vProjectService]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [helpdesk].[vProjectService]
AS
WITH workdetails
AS
(
  SELECT [Date], [ProjectId], SUM(SolutionTime) AS SolutionTime
  FROM hr.vWorkDetail
  GROUP BY [Date], [ProjectId]
),
helpdeskdetails
AS
(
  SELECT t.Project_id as ProjectId, CAST(ts.ChangeDateSys as date) as [Date], 
    SUM(CASE WHEN c.IsGratis = 0 THEN tsf.SolutionTime ELSE 0 END) AS SolutionTimePay,
    SUM(CASE WHEN c.IsGratis = 1 THEN tsf.SolutionTime ELSE 0 END) AS SolutionTimeGratis,
    SUM(CASE WHEN c.Id IS NULL THEN tsf.SolutionTime ELSE 0 END) AS SolutionTimeWithoutClassification
  FROM helpdesk.TicketStatusFull tsf
    INNER JOIN helpdesk.TicketStatus ts ON tsf.TicketStatus_id = ts.Id
    INNER JOIN helpdesk.Ticket t ON ts.Ticket_id = t.Id
    LEFT JOIN helpdesk.[Classification] c ON t.Classification_id = c.Id
  WHERE t.Project_id IS NOT NULL AND tsf.SolutionTime > 0
  GROUP BY t.Project_id, CAST(ts.ChangeDateSys as date)
  --ORDER BY CAST(ts.ChangeDateSys as date) DESC
),
projects
AS
(
  SELECT vp.CustomerId, vp.Id, vp.IsActive, vp.Code, vp.Name, vp.FullCode, vp.Started, vp.Finished, vp.TargetHours, vp.Deadline, vp.Managers, vp.Supervisors, vp.ParentProjectId,
    se.YearQuotient,
    d.MinDate, d.MaxDate
  FROM helpdesk.vProject vp
    INNER JOIN helpdesk.Project p ON vp.Id = p.Id
    INNER JOIN hr.ServiceEffort se ON p.ServiceEffort_id = se.Id
    LEFT JOIN ( SELECT [ProjectId], MIN([Date]) as MinDate, MAX([Date]) as MaxDate
                FROM hr.vWorkDetail
                GROUP BY [ProjectId]) d ON vp.Id = d.ProjectId
  WHERE 
    IsService = 1 --přidáno
),
result
as
(
  SELECT projects.CustomerId, projects.Id, projects.IsActive, projects.Code, projects.Name, projects.FullCode, projects.Started, projects.Finished, projects.TargetHours, 
    projects.Deadline, projects.Managers, projects.Supervisors, projects.YearQuotient, 
    per.Period, 
    SUM(wd.SolutionTime) AS SolutionTime,
    SUM(hd.SolutionTimePay) AS SolutionTimeHDPaid,
    SUM(hd.SolutionTimeGratis) AS SolutionTimeHDGratis,
    SUM(hd.SolutionTimeWithoutClassification) AS SolutionTimeHDWithoutClassification 
  FROM projects
    --vygeneruju rastr period od zacatku projektu (pokud neni, tak od prvnih vykazani) do konce (pokud neni, tak do konce roku, kde je vykaz
    CROSS APPLY [dbo].[fceSelectPeriods](
      ISNULL(projects.Started, projects.MinDate), 
      --COALESCE(projects.Finished, DATEFROMPARTS(YEAR(projects.MaxDate),12,31), DATEFROMPARTS(YEAR(GETDATE()), 12, 31)), projects.YearQuotient) per
      COALESCE(projects.Finished, projects.MaxDate, GETDATE()), projects.YearQuotient) per
    LEFT JOIN workdetails wd ON projects.Id = wd.[ProjectId] AND per.[Day] = wd.[Date] 
    LEFT JOIN helpdeskdetails hd ON projects.ParentProjectId = hd.[ProjectId] AND per.[Day] = hd.[Date] 
  GROUP BY projects.CustomerId, projects.Id, projects.IsActive, projects.Code, projects.Name, projects.FullCode, projects.Started, projects.Finished, projects.TargetHours, 
    projects.Deadline, projects.Managers, projects.Supervisors, projects.YearQuotient, 
    projects.Deadline, projects.Managers, projects.Supervisors, projects.YearQuotient, 
    per.Period
)
SELECT CAST(result.Id as varchar(MAX)) + CAST(result.Period as varchar(MAX)) as Id, result.Id as ProjectId, result.CustomerId, result.IsActive, result.Code, result.Name, result.FullCode, result.Started, result.Finished, result.TargetHours, 
    result.Deadline, result.Managers, result.Supervisors, result.YearQuotient, 
    result.Period,  
    [dbo].[fceSelectAggregatePeriods] (result.Period, result.YearQuotient, 1) as PeriodY,
    [dbo].[fceSelectAggregatePeriods] (result.Period, result.YearQuotient, 4) as  PeriodQ,
    [dbo].[fceSelectAggregatePeriods] (result.Period, result.YearQuotient, 12) as  PeriodM,
    ISNULL(result.SolutionTime, 0) as SolutionTime, 
    ISNULL(result.SolutionTimeHDPaid, 0) as SolutionTimeHDPaid, 
    ISNULL(result.SolutionTimeHDGratis, 0) as SolutionTimeHDGratis, 
    ISNULL(result.SolutionTimeHDWithoutClassification, 0) as SolutionTimeHDWithoutClassification,
    ISNULL(result.SolutionTimeHDPaid, 0) + ISNULL(result.SolutionTimeHDGratis, 0) + ISNULL(result.SolutionTimeHDWithoutClassification, 0) as SolutionTimeHD,
    ISNULL(result.SolutionTime, 0) - ISNULL(result.SolutionTimeHDPaid, 0) as SolutionTimeCoveredByFee  
FROM result
GO
/****** Object:  View [helpdesk].[vProjectDone]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [helpdesk].[vProjectDone] AS
SELECT  p.Id, p.IsActive, p.Code, p.Name, p.FullCode, p.Started, p.Finished, p.TargetHours, p.Deadline, p.Managers, p.Supervisors, SUM(wd.SolutionTime) AS SolutionTime
FROM helpdesk.vProject p
 CROSS APPLY [helpdesk].[ProjectTree](p.Id, NULL, 0) t
 LEFT JOIN hr.WorkDetail wd ON t.Id = wd.Project_id
WHERE 
 Finished is not null AND--přidáno
 IsOrder = 1 --přidáno
GROUP BY p.Id, p.IsActive, p.Code, p.Name, p.FullCode, p.Started, p.Finished, p.TargetHours, p.Deadline, p.Managers, p.Supervisors
GO
/****** Object:  Table [crm].[Ticket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[Ticket](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[Title] [varchar](300) NOT NULL,
	[Category_Id] [int] NULL,
	[StatusTicketLast_Id] [int] NULL,
	[StatusTicketFirst_Id] [int] NULL,
	[RequestUser] [varchar](100) NOT NULL,
	[IsReminder] [bit] NOT NULL,
 CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[TicketUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[TicketUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TicketStatus_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[Role_Id] [int] NOT NULL,
	[UserExt] [varchar](50) NULL,
	[IsGuarantor] [bit] NOT NULL,
 CONSTRAINT [PK_TicketUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[TicketStatus]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[TicketStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[State_Id] [int] NOT NULL,
	[Priority_Id] [int] NOT NULL,
	[ChangeDate] [datetime] NOT NULL,
	[ChangeDateSys] [datetime] NOT NULL,
	[RequestDate] [datetime] NOT NULL,
	[ReminderDate] [date] NULL,
	[SolutionTime] [float] NOT NULL,
	[IsReminder] [bit] NOT NULL,
	[Response] [varchar](max) NOT NULL,
	[ResponseInternal] [varchar](max) NOT NULL,
	[Status]  AS (case when [RequestDate]<=getdate() then 'Z' when [ReminderDate]<=getdate() then 'U' else '' end),
 CONSTRAINT [PK_TicketStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [crm].[vTicketSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [crm].[vTicketSummary] with schemabinding
AS
SELECT 
  t.id as TicketID,
  SumSolutionTime,
  STUFF((  SELECT ', ' + ISNULL(u.LastName + ' ' + u.FirstName, tu.UserExt)
			          FROM crm.TicketUser tu
                  LEFT JOIN dbo.[User] u ON tu.[User_id] = u.id 
                WHERE tu.TicketStatus_id = tsLast.id AND tu.Role_id = 0
			          FOR XML PATH('')), 1, 1, '') AS [SolveUsers],
  STUFF((  SELECT ',' + CAST(tu.User_id as varchar(MAX))
			          FROM crm.TicketUser tu
                WHERE tu.TicketStatus_id = tsLast.id AND tu.User_id IS NOT NULL
			          FOR XML PATH('')), 1, 1, '') AS [TicketUserIds]
FROM crm.Ticket t
  INNER JOIN crm.TicketStatus tsLast ON t.StatusTicketLast_id = tsLast.Id
  INNER JOIN (SELECT Ticket_id, SUM(SolutionTime) as SumSolutionTime
              FROM crm.TicketStatus
              GROUP BY Ticket_id) s ON t.id = s.Ticket_id
GO
/****** Object:  Table [helpdesk].[ServiceList]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[ServiceList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ticket_Id] [int] NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[UserTake_Id] [int] NOT NULL,
	[RepairType_Id] [int] NOT NULL,
	[IsRepeat] [bit] NOT NULL,
	[OrderNumber] [varchar](10) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ToRepairDate] [date] NOT NULL,
	[Category_Id] [int] NOT NULL,
 CONSTRAINT [PK_SERVICELIST] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DeviceServiceList]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DeviceServiceList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ServiceList_Id] [int] NOT NULL,
	[Device_Id] [int] NOT NULL,
	[Count] [int] NOT NULL,
	[Description] [varchar](500) NOT NULL,
 CONSTRAINT [PK_DEVICESERVICELIST] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [helpdesk].[vServiceListSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [helpdesk].[vServiceListSummary] with schemabinding
AS
SELECT 
  sl.Id as ServiceListID,
  ISNULL(STUFF((  SELECT ', ' + d.Name
			          FROM helpdesk.DeviceServiceList dSl
                  INNER JOIN dbo.Device d ON dSl.Device_id = d.id
                WHERE sl.Id = dSl.ServiceList_id
			          FOR XML PATH('')), 1, 1, ''), '') AS [DeviceText],
  c.Name AS [CategoryText]
FROM helpdesk.ServiceList sl
  INNER JOIN helpdesk.Category c ON Sl.Category_id = c.id
GO
/****** Object:  View [hr].[vUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [hr].[vUser]
AS
SELECT u.Id, u.User_id, u.Customer_id, u.FirstName, u.LastName, u.[Login], u.[Email], u.IsGroup, u.IsActive,
  p.ParentIds, CASE WHEN wd.Cnt > 0 THEN CAST(1 as bit) ELSE CAST(0 as bit) END as HasWorkDetail
FROM dbo.[User] u
  INNER JOIN dbo.vUserParents p ON u.id = p.UserId
  LEFT JOIN (SELECT a.[User_Id] as UserId, COUNT(*) as Cnt
              FROM hr.WorkDetail wd
                INNER JOIN hr.Activity a ON wd.Work_id = a.Id
              GROUP BY a.[User_id]) wd ON u.Id = wd.UserId
GO
/****** Object:  View [helpdesk].[vCategorySummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [helpdesk].[vCategorySummary]
AS
  SELECT c.Id, COUNT(cc.Customer_id) as CustomersCount, COUNT(cu.Id) as SolveUsersCount
  FROM helpdesk.Category c
    LEFT JOIN helpdesk.CustomerCategory cc ON c.Id = cc.Customer_id
    LEFT JOIN helpdesk.CustomerUser cu ON c.Id = cu.Category_id AND Role_id = 0
  GROUP BY c.Id

GO
/****** Object:  Table [acc].[Customer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[Customer](
	[Customer_Id] [int] NOT NULL,
	[Period_Id] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[InvoiceName] [varchar](100) NOT NULL,
	[Note] [varchar](2000) NOT NULL,
 CONSTRAINT [PK_CUSTOMER] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[CustomerInvoice]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[CustomerInvoice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
 CONSTRAINT [PK_CustomerInvoice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[HourlyRate]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[HourlyRate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RateType_Id] [int] NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[HourlyRateBeyond_Id] [int] NULL,
	[Rate] [money] NOT NULL,
	[Discount] [decimal](3, 0) NOT NULL,
	[FreeHours] [decimal](3, 0) NULL,
	[Note] [varchar](200) NOT NULL,
	[ValidFrom] [datetime] NOT NULL,
	[ValidTo] [datetime] NULL,
 CONSTRAINT [PK_HOURLYRATE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[HourlyRateClassification]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[HourlyRateClassification](
	[HourlyRate_Id] [int] NOT NULL,
	[Classification_Id] [int] NOT NULL,
 CONSTRAINT [PK_HOURLYRATECLASSIFICATION] PRIMARY KEY CLUSTERED 
(
	[HourlyRate_Id] ASC,
	[Classification_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[HourlyRateDevice]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[HourlyRateDevice](
	[HourlyRate_Id] [int] NOT NULL,
	[Device_Id] [int] NOT NULL,
 CONSTRAINT [PK_HOURLYRATEDEVICE] PRIMARY KEY CLUSTERED 
(
	[HourlyRate_Id] ASC,
	[Device_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[HourlyRateProject]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[HourlyRateProject](
	[HourlyRate_Id] [int] NOT NULL,
	[Project_Id] [int] NOT NULL,
 CONSTRAINT [PK_HOURLYRATEPROJECT] PRIMARY KEY CLUSTERED 
(
	[HourlyRate_Id] ASC,
	[Project_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[HourlyRateUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[HourlyRateUser](
	[HourlyRate_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
 CONSTRAINT [PK_HourlyRateUser] PRIMARY KEY CLUSTERED 
(
	[HourlyRate_Id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[Period]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[Period](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_PERIOD] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [acc].[RateType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [acc].[RateType](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_RATETYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [cfg].[BlackList]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[BlackList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Minutes] [int] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_BLACKLIST] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [cfg].[OutOfOffice]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[OutOfOffice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Text] [varchar](500) NOT NULL,
	[Compare] [varchar](10) NOT NULL,
	[Type] [varchar](10) NOT NULL,
 CONSTRAINT [PK_OUTOFOFFICE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [cfg].[Theme]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[Theme](
	[SysName] [varchar](10) NOT NULL,
	[Name] [varchar](10) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_Theme] PRIMARY KEY CLUSTERED 
(
	[SysName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[Category]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[Category](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[CategoryUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[CategoryUser](
	[Category_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
	[IsGuarantor] [bit] NOT NULL,
 CONSTRAINT [PK_CategoryUser] PRIMARY KEY CLUSTERED 
(
	[Category_Id] ASC,
	[User_Id] ASC,
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[Customer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[Customer](
	[Customer_Id] [int] NOT NULL,
 CONSTRAINT [PK_CUSTOMER] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[DeletedTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[DeletedTicket](
	[Ticket_id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[DeleteTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DeletedTicket] PRIMARY KEY CLUSTERED 
(
	[Ticket_id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[Message]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[Message](
	[Guid] [uniqueidentifier] NOT NULL,
	[Message_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[TicketStatus_Id] [int] NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[UserExt] [varchar](100) NULL,
	[Role_Id] [int] NOT NULL,
	[IsExclude] [bit] NOT NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Message_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[Role]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[Role](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ROLE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[Session]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[Session](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[UserCreate_Id] [int] NOT NULL,
	[UserRequest_Id] [int] NULL,
	[Category_Id] [int] NOT NULL,
	[Subject] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime2](0) NOT NULL,
	[RequestUser] [nvarchar](64) NOT NULL,
	[SessionContactLast_Id] [int] NULL,
	[SessionContactFirst_Id] [int] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[SessionAttachment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[SessionAttachment](
	[File_Id] [int] NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Session_Id] [int] NOT NULL,
	[SessionContact_Id] [int] NOT NULL,
	[Note] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_SessionAttachment] PRIMARY KEY CLUSTERED 
(
	[File_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[SessionContact]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[SessionContact](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Session_Id] [int] NOT NULL,
	[UserCreate_Id] [int] NOT NULL,
	[CreatedDate] [datetime2](0) NOT NULL,
	[ContactDate] [datetime2](0) NOT NULL,
	[NotificationDate] [datetime2](0) NULL,
	[Note] [nvarchar](max) NOT NULL,
	[ResolutionTime] [time](0) NOT NULL,
 CONSTRAINT [PK_SessionContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [crm].[SessionContactUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[SessionContactUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SessionContact_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[Role_Id] [int] NOT NULL,
	[UserExt] [varchar](50) NOT NULL,
 CONSTRAINT [PK_SessionContactUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[State]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[State](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[StateMatrix]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[StateMatrix](
	[State_Id] [int] NOT NULL,
	[StateNext_Id] [int] NOT NULL,
 CONSTRAINT [PK_StateMatrix] PRIMARY KEY CLUSTERED 
(
	[State_Id] ASC,
	[StateNext_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [crm].[TicketAttachment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [crm].[TicketAttachment](
	[File_Id] [int] NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[TicketStatus_Id] [int] NOT NULL,
	[Note] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_TicketAttachment] PRIMARY KEY CLUSTERED 
(
	[File_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ActivityReport]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivityReport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LoginReport_Id] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Method] [varchar](10) NOT NULL,
	[IsAjax] [bit] NOT NULL,
	[Page] [varchar](200) NOT NULL,
	[QueryString] [varchar](500) NOT NULL,
 CONSTRAINT [PK_ACTIVITYREPORT] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Attachment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attachment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Message_Id] [int] NOT NULL,
	[FileName] [varchar](255) NOT NULL,
 CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BlackList]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlackList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Address] [varchar](100) NOT NULL,
	[InsertDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_BLACKLIST] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Board]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Board](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NOT NULL,
	[InsertDate] [datetime] NOT NULL,
	[From] [datetime] NOT NULL,
	[To] [datetime] NOT NULL,
	[Subject] [varchar](100) NOT NULL,
	[Text] [varchar](max) NOT NULL,
	[IsInfoMessage] [bit] NOT NULL,
	[IsHighlight] [bit] NOT NULL,
 CONSTRAINT [PK_BOARD] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[Id] [int] NOT NULL,
	[ShortName] [varchar](2) NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerBoard]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerBoard](
	[Customer_Id] [int] NOT NULL,
	[Board_Id] [int] NOT NULL,
 CONSTRAINT [PK_CustomerBoard] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC,
	[Board_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerDomain]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerDomain](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Domain] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_CustomerDomain] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeviceDepartment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeviceDepartment](
	[Customer_Id] [int] NOT NULL,
	[Device_Id] [int] NOT NULL,
 CONSTRAINT [PK_DeviceDepartmen] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC,
	[Device_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeviceKind]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeviceKind](
	[Id] [int] NOT NULL,
	[DeviceType_Id] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_DEVICEKIND] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DevicePart]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DevicePart](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Device_Id] [int] NOT NULL,
	[DevicePartTpl_Id] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[Name] [varchar](300) NOT NULL,
 CONSTRAINT [PK_DEVICEPART] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DevicePartTpl]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DevicePartTpl](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DeviceTpl_Id] [int] NOT NULL,
	[Name] [varchar](300) NOT NULL,
 CONSTRAINT [PK_DEVICEPARTTPL] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeviceTpl]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeviceTpl](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DeviceType_Id] [int] NOT NULL,
	[Name] [varchar](300) NOT NULL,
 CONSTRAINT [PK_DEVICETPL] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeviceType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeviceType](
	[Id] [int] NOT NULL,
	[Name] [varchar](300) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_DEVICETYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[File]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[File](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FileId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Data] [varbinary](max) FILESTREAM  NULL,
	[Name] [varchar](255) NOT NULL,
	[ContentType] [varchar](255) NOT NULL,
 CONSTRAINT [PK_File] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY] FILESTREAM_ON [FS_File],
 CONSTRAINT [IX_File_FileId] UNIQUE NONCLUSTERED 
(
	[FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] FILESTREAM_ON [FS_File]
GO
/****** Object:  Table [dbo].[FreeDay]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FreeDay](
	[Day] [date] NOT NULL,
 CONSTRAINT [PK_FREEDAY] PRIMARY KEY CLUSTERED 
(
	[Day] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LoginReport]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoginReport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[UserLogin] [varchar](100) NULL,
	[LoginDate] [datetime] NOT NULL,
	[LogoutDate] [datetime] NOT NULL,
	[PublicIP] [varchar](30) NOT NULL,
	[LocalIP] [varchar](30) NOT NULL,
	[Browser] [varchar](500) NOT NULL,
 CONSTRAINT [PK_LOGINREPORT] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MailMessage]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailMessage](
	[Message_Id] [int] NOT NULL,
	[Subject] [varchar](300) NOT NULL,
	[AlternateText] [varchar](max) NOT NULL,
 CONSTRAINT [PK_MailMessage] PRIMARY KEY CLUSTERED 
(
	[Message_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Message]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Message](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[IsSend] [bit] NULL,
	[ErrorMessage] [varchar](255) NULL,
	[TextMessage] [varchar](max) NOT NULL,
	[Type] [int] NOT NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OutOfOffice]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OutOfOffice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NOT NULL,
	[From] [date] NOT NULL,
	[To] [date] NULL,
 CONSTRAINT [PK_OUTOFOFFICE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Priority]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Priority](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Priority] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[Id] [int] NOT NULL,
	[RoleGroup_Id] [int] NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[SysName] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[NormalizedName] [nvarchar](256) NOT NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleClaim]    Script Date: 28.04.2026 10:44:57 ******/
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
/****** Object:  Table [dbo].[RoleGroup]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleGroup](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[SysName] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsReport] [bit] NOT NULL,
 CONSTRAINT [PK_RoleGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SmsMessage]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SmsMessage](
	[Message_Id] [int] NOT NULL,
 CONSTRAINT [PK_SmsMessage] PRIMARY KEY CLUSTERED 
(
	[Message_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserAssociation]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserAssociation](
	[UserSenior_Id] [int] NOT NULL,
	[UserJunior_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserAssociation] PRIMARY KEY CLUSTERED 
(
	[UserSenior_Id] ASC,
	[UserJunior_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserClaim]    Script Date: 28.04.2026 10:44:57 ******/
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
/****** Object:  Table [dbo].[UserFilter]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFilter](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[Name] [varchar](100) NOT NULL,
	[Value] [xml] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Type] [varchar](20) NOT NULL,
	[Color] [varchar](7) NOT NULL,
	[Order] [int] NOT NULL,
	[SubType] [varchar](10) NOT NULL,
 CONSTRAINT [PK_UserFilter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserFilterEmailSettings]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFilterEmailSettings](
	[UserFilter_Id] [int] NOT NULL,
	[RepeatPeriod] [int] NOT NULL,
	[IsMonday] [bit] NOT NULL,
	[IsTuesday] [bit] NOT NULL,
	[IsWednesday] [bit] NOT NULL,
	[IsThursday] [bit] NOT NULL,
	[IsFriday] [bit] NOT NULL,
	[IsSaturday] [bit] NOT NULL,
	[IsSunday] [bit] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
	[LastGenerated] [datetime] NULL,
	[RepeatFormatDate] [varchar](12) NOT NULL,
 CONSTRAINT [PK_UserFilterEmailSettings] PRIMARY KEY CLUSTERED 
(
	[UserFilter_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserFilterRole]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFilterRole](
	[UserFilter_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserFilterRole] PRIMARY KEY CLUSTERED 
(
	[UserFilter_Id] ASC,
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserLogin]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLogin](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
	[User_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserLogin] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
	[Customer_Id] [int] NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserSettings]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSettings](
	[User_Id] [int] NOT NULL,
	[Theme] [varchar](15) NOT NULL,
	[DefaultCustomer] [int] NULL,
	[Language] [char](5) NOT NULL,
	[ActivityFrom] [time](0) NULL,
	[ActivityTo] [time](0) NULL,
 CONSTRAINT [PK_USERSETTINGS] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserToken]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserToken](
	[User_Id] [int] NOT NULL,
	[LoginProvider] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[IssueDateTime] [datetime2](7) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_UserToken] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC,
	[LoginProvider] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [frm].[Customer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[Customer](
	[Customer_Id] [int] NOT NULL,
 CONSTRAINT [PK_CUSTOMER] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[DeletedFormInstance]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[DeletedFormInstance](
	[FormInstance_id] [int] NOT NULL,
	[Form_id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[DeleteTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DeletedFormInstance] PRIMARY KEY CLUSTERED 
(
	[FormInstance_id] ASC,
	[Form_id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[FormInstance]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[FormInstance](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FormVariant_Id] [int] NOT NULL,
	[UserCreate_Id] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[CreateDate] [datetime2](0) NOT NULL,
	[StaticFormXml] [xml] NULL,
	[Note] [varchar](max) NOT NULL,
	[FormState_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[Customer_Id] [int] NULL,
 CONSTRAINT [PK_FORMINSTANCE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [frm].[FormState]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[FormState](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_FormState] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[FormVariant]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[FormVariant](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Form_Id] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_FormVariant] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[Message]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[Message](
	[Message_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[FormInstance_Id] [int] NOT NULL,
	[Guid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Message_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[Task]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[Task](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TaskGroup_Id] [int] NOT NULL,
	[Order] [int] NOT NULL,
	[DeadlineFrom] [int] NULL,
	[DeadlineTo] [int] NULL,
	[IsNoteRequired] [bit] NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[IsAdHoc] [bit] NOT NULL,
 CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [frm].[TaskFormVariant]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[TaskFormVariant](
	[Task_Id] [int] NOT NULL,
	[Form_Id] [int] NOT NULL,
	[Variant_Id] [int] NOT NULL,
	[ValidFrom] [date] NULL,
	[ValidTo] [date] NULL,
 CONSTRAINT [PK_TaskFormVariant] PRIMARY KEY CLUSTERED 
(
	[Task_Id] ASC,
	[Form_Id] ASC,
	[Variant_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[TaskInstance]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[TaskInstance](
	[FormInstance_Id] [int] NOT NULL,
	[Task_Id] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[DeadlineFrom] [date] NULL,
	[DeadlineTo] [date] NULL,
	[CreateDate] [datetime2](0) NOT NULL,
	[Order] [int] NOT NULL,
	[TaskState_Id] [int] NOT NULL,
	[Note] [varchar](500) NOT NULL,
 CONSTRAINT [PK_TaskInstance] PRIMARY KEY CLUSTERED 
(
	[FormInstance_Id] ASC,
	[Task_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [frm].[TaskState]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [frm].[TaskState](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_TaskState] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Application]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Application](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_APPLICATION] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Attachment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Attachment](
	[File_Id] [int] NOT NULL,
	[Faq_Id] [int] NULL,
	[ServiceList_Id] [int] NULL,
	[Customer_Id] [int] NULL,
	[Note] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED 
(
	[File_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomerApplication]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomerApplication](
	[Customer_id] [int] NOT NULL,
	[Application_Id] [int] NOT NULL,
 CONSTRAINT [PK_CUSTOMERAPPLICATION] PRIMARY KEY CLUSTERED 
(
	[Customer_id] ASC,
	[Application_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomerClassification]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomerClassification](
	[Customer_Id] [int] NOT NULL,
	[Classification_Id] [int] NOT NULL,
 CONSTRAINT [PK_CustomerClassification] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC,
	[Classification_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomerCustomField]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomerCustomField](
	[Customer_Id] [int] NOT NULL,
	[CustomField_Id] [int] NOT NULL,
 CONSTRAINT [PK_CustomerCustomField] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC,
	[CustomField_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomField]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomField](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomFieldType_Id] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[DataTyp] [varchar](20) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Order] [smallint] NOT NULL,
	[Description] [varchar](500) NOT NULL,
	[Title] [varchar](50) NOT NULL,
	[Length] [smallint] NOT NULL,
	[NumericPrecision] [tinyint] NULL,
	[NumericScale] [tinyint] NULL,
	[Mandatory] [bit] NOT NULL,
	[Regex] [varchar](50) NOT NULL,
 CONSTRAINT [PK_CustomField] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomFieldCategory]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomFieldCategory](
	[Category_Id] [int] NOT NULL,
	[CustomField_Id] [int] NOT NULL,
 CONSTRAINT [PK_CustomFieldCategory] PRIMARY KEY CLUSTERED 
(
	[Category_Id] ASC,
	[CustomField_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomFieldClassification]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomFieldClassification](
	[Classification_Id] [int] NOT NULL,
	[CustomField_Id] [int] NOT NULL,
 CONSTRAINT [PK_CustomFieldClassification] PRIMARY KEY CLUSTERED 
(
	[Classification_Id] ASC,
	[CustomField_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomFieldCodeList]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomFieldCodeList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomField_Id] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_CustomFieldCodeList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomFieldState]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomFieldState](
	[State_Id] [int] NOT NULL,
	[CustomField_Id] [int] NOT NULL,
 CONSTRAINT [PK_CustomFieldState] PRIMARY KEY CLUSTERED 
(
	[State_Id] ASC,
	[CustomField_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[CustomFieldType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[CustomFieldType](
	[Id] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_CustomFieldType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DefaultResponse]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DefaultResponse](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[Customer_Id] [int] NULL,
	[Name] [varchar](100) NOT NULL,
	[Text] [varchar](max) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_DefaultResponse] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DefaultSettings]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DefaultSettings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[SettingsXML] [xml] NOT NULL,
 CONSTRAINT [PK_DEFAULTSETTINGS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DefaultTicketUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DefaultTicketUser](
	[User_Id] [int] NOT NULL,
	[UserSelect_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
 CONSTRAINT [PK_DefaultTicketUser] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC,
	[UserSelect_Id] ASC,
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DeletedTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DeletedTicket](
	[Ticket_id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[DeleteTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DeletedTicket] PRIMARY KEY CLUSTERED 
(
	[Ticket_id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DeviceBook]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DeviceBook](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Device_Id] [int] NOT NULL,
	[DeviceBookCategory_Id] [int] NULL,
	[Date] [date] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[IsCompleted] [bit] NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[DurationTicks] [bigint] NOT NULL,
 CONSTRAINT [PK_DEVICEBOOK] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DeviceBookCategory]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DeviceBookCategory](
	[Id] [int] NOT NULL,
	[Title] [varchar](50) NOT NULL,
 CONSTRAINT [PK_DEVICEBOOKCATEGORY] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DevicePartServiceList]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DevicePartServiceList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DeviceServiceList_Id] [int] NOT NULL,
	[DevicePart_Id] [int] NOT NULL,
	[Reason_Id] [int] NOT NULL,
	[Count] [int] NOT NULL,
	[SerialNumber] [varchar](20) NOT NULL,
	[Description] [varchar](500) NOT NULL,
 CONSTRAINT [PK_DevicePartServiceList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[DomainTicketUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[DomainTicketUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerDomain_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[IsInformed] [bit] NOT NULL,
 CONSTRAINT [PK_DomainTicketUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[EmailType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[EmailType](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_EMAILTYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[FAQ]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[FAQ](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Category_Id] [int] NOT NULL,
	[Question] [varchar](max) NOT NULL,
	[Answer] [varchar](max) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_FAQ] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[MailTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[MailTicket](
	[FileId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Ticket_Id] [int] NULL,
	[User_Id] [int] NULL,
	[ServerId] [varchar](50) NOT NULL,
	[MessageId] [varchar](250) NOT NULL,
	[Subject] [varchar](300) NOT NULL,
	[Date] [datetime] NOT NULL,
	[From] [varchar](500) NOT NULL,
	[IsProcess] [bit] NOT NULL,
	[Note] [varchar](max) NOT NULL,
	[Mail] [varbinary](max) FILESTREAM  NULL,
 CONSTRAINT [PK_MailTicket] PRIMARY KEY CLUSTERED 
(
	[FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] FILESTREAM_ON [FS_HDAttachment],
 CONSTRAINT [UQ_MailTicket] UNIQUE NONCLUSTERED 
(
	[FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY] FILESTREAM_ON [FS_HDAttachment]
GO
/****** Object:  Table [helpdesk].[Message]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Message](
	[Guid] [uniqueidentifier] NOT NULL,
	[Message_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[TicketStatus_Id] [int] NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[UserExt] [varchar](100) NULL,
	[Role_Id] [int] NOT NULL,
	[IsExclude] [bit] NOT NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Message_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[ProjectType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[ProjectType](
	[Id] [char](1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_PROJECTTYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Ranking]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Ranking](
	[Ticket_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[Date] [datetime2](0) NOT NULL,
	[Score] [tinyint] NOT NULL,
	[Text] [varchar](max) NOT NULL,
 CONSTRAINT [PK_RANKING] PRIMARY KEY CLUSTERED 
(
	[Ticket_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Reason]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Reason](
	[Id] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_REASON] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[RepairType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[RepairType](
	[Id] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_REPAIRTYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Role]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Role](
	[Id] [int] NOT NULL,
	[Idx] [int] NOT NULL,
	[HasMailingSettings] [bit] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ROLE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Routine]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Routine](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[RepeatPeriod] [int] NOT NULL,
	[IsMonday] [bit] NOT NULL,
	[IsTuesday] [bit] NOT NULL,
	[IsWednesday] [bit] NOT NULL,
	[IsThursday] [bit] NOT NULL,
	[IsFriday] [bit] NOT NULL,
	[IsSaturday] [bit] NOT NULL,
	[IsSunday] [bit] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[IsLinking] [bit] NOT NULL,
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
	[RoutineXml] [xml] NULL,
	[LastGenerated] [datetime] NULL,
	[RepeatFormatDate] [varchar](12) NOT NULL,
 CONSTRAINT [PK_ROUTINE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[RoutineTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[RoutineTicket](
	[Ticket_Id] [int] NOT NULL,
	[Routine_Id] [int] NOT NULL,
 CONSTRAINT [PK_ROUTINETICKET] PRIMARY KEY CLUSTERED 
(
	[Ticket_Id] ASC,
	[Routine_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[ServiceProvided]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[ServiceProvided](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ServiceList_Id] [int] NOT NULL,
	[Text] [varchar](max) NOT NULL,
	[PriceMaterial] [money] NOT NULL,
	[PriceWork] [money] NOT NULL,
	[PriceTransport] [money] NOT NULL,
 CONSTRAINT [PK_SERVICEPROVIDED] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[Settings]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[Settings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[CanChangeAllDevice] [bit] NOT NULL,
	[CanSubstituteSolve] [bit] NOT NULL,
	[CanChangeClasification] [bit] NOT NULL,
	[CanChangeProject] [bit] NOT NULL,
	[CanAddSolveUser] [bit] NOT NULL,
	[CanRemoveSolveUser] [bit] NOT NULL,
	[CanAddInformUser] [bit] NOT NULL,
	[CanRemoveInformUser] [bit] NOT NULL,
	[CanChangePriority] [bit] NOT NULL,
	[CanChangeRequestUser] [bit] NOT NULL,
	[CanChangeRequestDate] [bit] NOT NULL,
	[CanChangeEstimatedDate] [bit] NOT NULL,
	[IsFullSolver] [bit] NOT NULL,
	[DefaultSolutionTime] [float] NULL,
	[CanFillResponse] [bit] NOT NULL,
	[CanViewSolveUser] [bit] NOT NULL,
	[CanViewInformUser] [bit] NOT NULL,
 CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_CustomerUser] UNIQUE NONCLUSTERED 
(
	[User_Id] ASC,
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[SettingsInfo]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[SettingsInfo](
	[Settings_Id] [int] NOT NULL,
	[State_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
	[Sms] [bit] NOT NULL,
	[Email] [bit] NOT NULL,
	[OnChange] [bit] NOT NULL,
 CONSTRAINT [PK_SettingsInfo] PRIMARY KEY CLUSTERED 
(
	[Settings_Id] ASC,
	[State_Id] ASC,
	[Role_Id] ASC,
	[Sms] ASC,
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[SettingsState]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[SettingsState](
	[Settings_Id] [int] NOT NULL,
	[State_Id] [int] NOT NULL,
 CONSTRAINT [PK_SETTINGSSTATE] PRIMARY KEY CLUSTERED 
(
	[Settings_Id] ASC,
	[State_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[SMSType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[SMSType](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_SMSType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[State]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[State](
	[Id] [int] NOT NULL,
	[Idx] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [UNIQUE_Idx] UNIQUE NONCLUSTERED 
(
	[Idx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[StateMatrix]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[StateMatrix](
	[State_Id] [int] NOT NULL,
	[StateNext_Id] [int] NOT NULL,
 CONSTRAINT [PK_StateMatrix] PRIMARY KEY CLUSTERED 
(
	[State_Id] ASC,
	[StateNext_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[TicketAttachment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketAttachment](
	[File_Id] [int] NOT NULL,
	[Ticket_Id] [int] NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[TicketStatus_Id] [int] NOT NULL,
	[Note] [varchar](100) NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsSent] [bit] NOT NULL,
	[ContentId] [varchar](255) NOT NULL,
 CONSTRAINT [PK_TicketAttachment] PRIMARY KEY CLUSTERED 
(
	[File_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[TicketComment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketComment](
	[TicketStatus_Id] [int] NOT NULL,
 CONSTRAINT [PK_TicketComment] PRIMARY KEY CLUSTERED 
(
	[TicketStatus_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[TicketEx]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketEx](
	[Ticket_Id] [int] NOT NULL,
	[Ciselnik1] [int] NOT NULL,
	[Jmeno] [varchar](20) NOT NULL,
	[Prijmeni] [int] NOT NULL,
	[Textovepole] [varchar](50) NULL,
	[Pozdrav] [int] NOT NULL,
 CONSTRAINT [PK_TicketEx] PRIMARY KEY CLUSTERED 
(
	[Ticket_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[TicketLink]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TicketLink](
	[Ticket_Id] [int] NOT NULL,
	[TicketParent_Id] [int] NOT NULL,
 CONSTRAINT [PK_TicketLink] PRIMARY KEY CLUSTERED 
(
	[Ticket_Id] ASC,
	[TicketParent_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[TmpAttachment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[TmpAttachment](
	[File_Id] [int] NOT NULL,
	[Ticket_Id] [int] NULL,
	[PageGuid] [uniqueidentifier] NOT NULL,
	[User_Id] [int] NOT NULL,
	[TmpName] [varchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TmpAttachment] PRIMARY KEY CLUSTERED 
(
	[File_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[UserDevice]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[UserDevice](
	[Device_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserDevice] PRIMARY KEY CLUSTERED 
(
	[Device_Id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[UserGroup]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[UserGroup](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[SelectAll] [bit] NOT NULL,
	[AutomaticallyAdd] [bit] NOT NULL,
 CONSTRAINT [PK_UserGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[UserGroupCategory]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[UserGroupCategory](
	[UserGroup_Id] [int] NOT NULL,
	[Category_Id] [int] NOT NULL,
 CONSTRAINT [PK_USERGROUPCATEGORY] PRIMARY KEY CLUSTERED 
(
	[UserGroup_Id] ASC,
	[Category_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[WatchDog]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[WatchDog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[State_Id] [int] NOT NULL,
	[SubState_Id] [int] NULL,
	[PropertyName] [varchar](50) NOT NULL,
	[PeriodeTicks] [bigint] NOT NULL,
	[IsAlert] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[OnlyWorkDay] [bit] NOT NULL,
	[TextResources] [xml] NOT NULL,
	[UseSystemMessage] [bit] NOT NULL,
 CONSTRAINT [PK_WATCHDOG] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[WorkDetailTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[WorkDetailTicket](
	[Ticket_Id] [int] NOT NULL,
	[WorkDetail_Id] [int] NOT NULL,
 CONSTRAINT [PK_WorkDetailTicket] PRIMARY KEY CLUSTERED 
(
	[Ticket_Id] ASC,
	[WorkDetail_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [helpdesk].[WorkDetailTicketStatus]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [helpdesk].[WorkDetailTicketStatus](
	[TicketStatus_Id] [int] NOT NULL,
	[WorkDetail_Id] [int] NOT NULL,
 CONSTRAINT [PK_WorkDetailTicketStatus] PRIMARY KEY CLUSTERED 
(
	[TicketStatus_Id] ASC,
	[WorkDetail_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[CareOf]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[CareOf](
	[Activity_Id] [int] NOT NULL,
 CONSTRAINT [PK_CareOf] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Company]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Company](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Customer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Customer](
	[Customer_Id] [int] NOT NULL,
	[ActivityFrom] [time](0) NULL,
	[ActivityTo] [time](0) NULL,
 CONSTRAINT [PK_CUSTOMER] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Message]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Message](
	[Message_Id] [int] NOT NULL,
	[User_Id] [int] NULL,
	[SummaryDate] [date] NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Message_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Position]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Position](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Position] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[StudyLeave]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[StudyLeave](
	[Activity_Id] [int] NOT NULL,
	[IsHalfDay] [bit] NOT NULL,
	[Hours] [int] NOT NULL,
 CONSTRAINT [PK_StudyLeave] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[Task]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[Task](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NOT NULL,
	[Project_Id] [int] NOT NULL,
	[WorkType_Id] [int] NOT NULL,
	[Title] [varchar](100) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [hr].[TimeOff]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[TimeOff](
	[Activity_Id] [int] NOT NULL,
 CONSTRAINT [PK_TIMEOFF] PRIMARY KEY CLUSTERED 
(
	[Activity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[User]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[User](
	[User_Id] [int] NOT NULL,
	[Company_Id] [int] NULL,
	[PersonalNumber] [int] NULL,
	[Position_Id] [int] NULL,
	[PositionText] [varchar](500) NOT NULL,
	[WorkFundHours] [int] NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[UserDepartment]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[UserDepartment](
	[User_Id] [int] NOT NULL,
	[Department_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserDepartment] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC,
	[Department_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[UserTask]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[UserTask](
	[User_Id] [int] NOT NULL,
	[Task_Id] [int] NOT NULL,
 CONSTRAINT [PK_UserTask] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC,
	[Task_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[WorkStart]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[WorkStart](
	[User_Id] [int] NOT NULL,
	[Start] [datetime] NOT NULL,
 CONSTRAINT [PK_WorkStart] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hr].[WorkType]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hr].[WorkType](
	[Id] [int] NOT NULL,
	[Name] [varchar](30) NOT NULL,
	[WorkType_Id] [int] NULL,
	[Department_Id] [int] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_WorkType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [report].[DataSource]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[DataSource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReportView_Id] [int] NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[SubReportName] [varchar](50) NULL,
 CONSTRAINT [PK_DATASOURCE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [report].[EntityDataSource]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[EntityDataSource](
	[id] [int] NOT NULL,
	[Assembly] [varchar](100) NOT NULL,
	[Instance] [varchar](100) NOT NULL,
	[Method] [varchar](100) NOT NULL,
	[Filter] [varchar](max) NULL,
	[Includes] [varchar](max) NULL,
 CONSTRAINT [PK_EntityDataSource] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [report].[Output]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[Output](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Report_Id] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[FileName] [varchar](150) NOT NULL,
	[File] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_OUTPUT] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [report].[Report]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[Report](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[ReportFileName] [varchar](255) NOT NULL,
	[ResourceFileName] [varchar](255) NOT NULL,
	[SysName] [varchar](50) NOT NULL,
	[ReportFile] [varbinary](max) NULL,
 CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [report].[ReportRole]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[ReportRole](
	[Report_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
 CONSTRAINT [PK_REPORTROLE] PRIMARY KEY CLUSTERED 
(
	[Report_Id] ASC,
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [report].[ReportView]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[ReportView](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Report_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Generated] [datetime] NULL,
	[Hash] [varchar](32) NOT NULL,
	[Parameters] [xml] NULL,
	[Filter] [varchar](max) NOT NULL,
 CONSTRAINT [PK_REPORTVIEW] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [report].[SqlDataSource]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[SqlDataSource](
	[DataSource_Id] [int] NOT NULL,
	[CommandText] [varchar](max) NOT NULL,
	[CommandType] [varchar](20) NOT NULL,
	[Parameters] [varchar](max) NULL,
 CONSTRAINT [PK_SQLDATASOURCE] PRIMARY KEY CLUSTERED 
(
	[DataSource_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [report].[SubReport]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [report].[SubReport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Report_Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[ReportFileName] [varchar](255) NOT NULL,
	[ResourceFileName] [varchar](255) NOT NULL,
	[ReportFile] [varbinary](max) NULL,
 CONSTRAINT [PK_SubReport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [wf].[ApproveUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[ApproveUser](
	[Workflow_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Level] [int] NOT NULL,
 CONSTRAINT [PK_ApproveUser] PRIMARY KEY CLUSTERED 
(
	[Workflow_Id] ASC,
	[User_Id] ASC,
	[Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [wf].[Message]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[Message](
	[Guid] [uniqueidentifier] NOT NULL,
	[Message_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Task_Id] [int] NULL,
	[Request_Id] [int] NOT NULL,
	[Role_Id] [int] NOT NULL,
	[IsExclude] [bit] NOT NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Message_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [wf].[Request]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[Request](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Workflow_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ActLevel] [int] NOT NULL,
	[IsApproved] [bit] NULL,
	[IsClosed] [bit] NOT NULL,
	[Description] [varchar](max) NOT NULL,
 CONSTRAINT [PK_REQUEST] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [wf].[RequestDevice]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[RequestDevice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Request_Id] [int] NOT NULL,
	[DeviceType_Id] [int] NOT NULL,
	[DeviceKind_Id] [int] NOT NULL,
	[Count] [int] NOT NULL,
	[Reason] [varchar](2000) NOT NULL,
	[OldItemNote] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_REQUESTDEVICE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [wf].[Role]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[Role](
	[Id] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ROLE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [wf].[Task]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[Task](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Request_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[Level] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[Date] [datetime] NULL,
	[IsApproved] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[Description] [varchar](max) NOT NULL,
 CONSTRAINT [PK_TASK] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [wf].[Workflow]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[Workflow](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Customer_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[WorkflowXml] [xml] NULL,
 CONSTRAINT [PK_WORKFLOW] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [wf].[WorkflowUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wf].[WorkflowUser](
	[Workflow_Id] [int] NOT NULL,
	[User_Id] [int] NOT NULL,
 CONSTRAINT [PK_WORKFLOWUSER] PRIMARY KEY CLUSTERED 
(
	[Workflow_Id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idxFkPozadavek]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxFkPozadavek] ON [crm].[TicketStatus]
(
	[Ticket_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [idxFkPriorita]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxFkPriorita] ON [crm].[TicketStatus]
(
	[Priority_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [idxFkStav]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxFkStav] ON [crm].[TicketStatus]
(
	[State_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [idxFkUzivatel]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxFkUzivatel] ON [crm].[TicketStatus]
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [idxFkStavPozadavku]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxFkStavPozadavku] ON [crm].[TicketUser]
(
	[TicketStatus_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [idxFkUzivatel]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxFkUzivatel] ON [crm].[TicketUser]
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [idxNaVedomi]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxNaVedomi] ON [crm].[TicketUser]
(
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxCustomer]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxCustomer] ON [dbo].[Customer]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxCustomer_CustomerGroup]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxCustomer_CustomerGroup] ON [dbo].[Customer]
(
	[CustomerGroup_Id] ASC
)
INCLUDE([CustomerDepartment_Id],[Country_Id],[IsActive],[Name],[Street],[City],[IC],[DIC],[Theme],[TextResources],[Note],[Language],[UserPattern],[DevicePattern],[Code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxCustomer_IsActiveDepartment]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxCustomer_IsActiveDepartment] ON [dbo].[Customer]
(
	[CustomerDepartment_Id] ASC,
	[IsActive] ASC
)
INCLUDE([Id],[Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxDevice_Customer]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxDevice_Customer] ON [dbo].[Device]
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxMessage_Date]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxMessage_Date] ON [dbo].[Message]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxMessageIsSend]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxMessageIsSend] ON [dbo].[Message]
(
	[IsSend] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxUser_IsGroupIsActiveUserId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxUser_IsGroupIsActiveUserId] ON [dbo].[User]
(
	[IsGroup] ASC,
	[IsActive] ASC,
	[User_Id] ASC
)
INCLUDE([Id],[Customer_Id],[FirstName],[LastName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxUser_Login]    Script Date: 28.04.2026 10:44:57 ******/
CREATE UNIQUE NONCLUSTERED INDEX [idxUser_Login] ON [dbo].[User]
(
	[Login] ASC
)
WHERE ([IsGroup]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxUserFilter_UserId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxUserFilter_UserId] ON [dbo].[UserFilter]
(
	[User_Id] ASC
)
INCLUDE([Id],[Name],[Value],[IsActive],[Type],[Color],[Order]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxMailTicket]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxMailTicket] ON [helpdesk].[MailTicket]
(
	[From] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxMailTicket_TicketId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxMailTicket_TicketId] ON [helpdesk].[MailTicket]
(
	[Ticket_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxMessage_GuidTicketId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxMessage_GuidTicketId] ON [helpdesk].[Message]
(
	[Guid] ASC,
	[Ticket_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxMessage_TicketId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxMessage_TicketId] ON [helpdesk].[Message]
(
	[Ticket_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxMessage_TSF]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxMessage_TSF] ON [helpdesk].[Message]
(
	[TicketStatus_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxSettings_Customer]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxSettings_Customer] ON [helpdesk].[Settings]
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxTicket_CustomerId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicket_CustomerId] ON [helpdesk].[Ticket]
(
	[Customer_Id] ASC,
	[Title] ASC
)
INCLUDE([Id],[IsChanged],[User_Id],[RequestUser],[Project_Id],[Classification_Id],[Category_Id],[iSablona_id],[StatusTicketLast_Id],[StatusTicketFirst_Id],[CustomField1],[CustomField2],[CustomerDepartment_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicket_Last]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicket_Last] ON [helpdesk].[Ticket]
(
	[StatusTicketLast_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicket_ProjectIdServiceView]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicket_ProjectIdServiceView] ON [helpdesk].[Ticket]
(
	[Project_Id] ASC
)
INCLUDE([Classification_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketAttachment_TicketIdIsActive]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketAttachment_TicketIdIsActive] ON [helpdesk].[TicketAttachment]
(
	[Ticket_Id] ASC,
	[IsActive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketAttachment_TicketStatus]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketAttachment_TicketStatus] ON [helpdesk].[TicketAttachment]
(
	[TicketStatus_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketStatus_TicketId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketStatus_TicketId] ON [helpdesk].[TicketStatus]
(
	[Ticket_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketStatusChangeDate]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketStatusChangeDate] ON [helpdesk].[TicketStatus]
(
	[ChangeDateSys] ASC
)
INCLUDE([Id],[User_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketStatusFull_SolutionTimeServiceView]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketStatusFull_SolutionTimeServiceView] ON [helpdesk].[TicketStatusFull]
(
	[SolutionTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketStatusFull_StateId]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketStatusFull_StateId] ON [helpdesk].[TicketStatusFull]
(
	[State_Id] ASC
)
INCLUDE([TicketStatus_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketUser_RoleUserIsGuarantor]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketUser_RoleUserIsGuarantor] ON [helpdesk].[TicketUser]
(
	[Role_Id] ASC,
	[User_Id] ASC,
	[IsGuarantor] ASC
)
INCLUDE([TicketStatus_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketUser_TicketStatusUser]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketUser_TicketStatusUser] ON [helpdesk].[TicketUser]
(
	[TicketStatus_Id] ASC,
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxTicketUser_UserRead]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxTicketUser_UserRead] ON [helpdesk].[TicketUser]
(
	[User_Id] ASC,
	[ReadDate] ASC
)
INCLUDE([TicketStatus_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxActivity_Date]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxActivity_Date] ON [hr].[Activity]
(
	[Date] ASC
)
INCLUDE([User_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxWorkDetail_CustPrj]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxWorkDetail_CustPrj] ON [hr].[WorkDetail]
(
	[Customer_Id] ASC,
	[Project_Id] ASC
)
INCLUDE([Work_Id],[SolutionTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxWorkDetail_ProjectIdServiceView]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxWorkDetail_ProjectIdServiceView] ON [hr].[WorkDetail]
(
	[Project_Id] ASC
)
INCLUDE([Work_Id],[Customer_Id],[IsPreSales]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxWorkDetail_Work]    Script Date: 28.04.2026 10:44:57 ******/
CREATE NONCLUSTERED INDEX [idxWorkDetail_Work] ON [hr].[WorkDetail]
(
	[Work_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [crm].[Session] ADD  CONSTRAINT [DF_Session_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [crm].[Session] ADD  DEFAULT ('') FOR [RequestUser]
GO
ALTER TABLE [crm].[Session] ADD  DEFAULT (CONVERT([bit],(1),0)) FOR [IsActive]
GO
ALTER TABLE [crm].[SessionContact] ADD  CONSTRAINT [DF_SessionContact_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Device] ADD  DEFAULT ((0)) FOR [HasDeviceBook]
GO
ALTER TABLE [dbo].[Role] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RoleGroup] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT ((0)) FOR [EmailConfirmed]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT ((0)) FOR [PhoneNumberConfirmed]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT ((0)) FOR [TwoFactorEnabled]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT ((0)) FOR [LockoutEnabled]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT ((0)) FOR [AccessFailedCount]
GO
ALTER TABLE [dbo].[UserFilter] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[UserToken] ADD  DEFAULT (getdate()) FOR [IssueDateTime]
GO
ALTER TABLE [helpdesk].[Category] ADD  DEFAULT ((0)) FOR [Idx]
GO
ALTER TABLE [helpdesk].[Category] ADD  DEFAULT ((0)) FOR [IsGroup]
GO
ALTER TABLE [helpdesk].[Category] ADD  DEFAULT ((1)) FOR [IsDefault]
GO
ALTER TABLE [helpdesk].[Category] ADD  CONSTRAINT [DF_KategorieProblemu_tNapoveda]  DEFAULT ('') FOR [Help]
GO
ALTER TABLE [helpdesk].[Classification] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [helpdesk].[Classification] ADD  DEFAULT ((0)) FOR [Idx]
GO
ALTER TABLE [helpdesk].[Classification] ADD  DEFAULT ((0)) FOR [IsGroup]
GO
ALTER TABLE [helpdesk].[Classification] ADD  DEFAULT ((1)) FOR [IsDefault]
GO
ALTER TABLE [helpdesk].[DefaultResponse] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [helpdesk].[FAQ] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [helpdesk].[MailTicket] ADD  CONSTRAINT [DF_MailTicket]  DEFAULT (newid()) FOR [FileId]
GO
ALTER TABLE [helpdesk].[Routine] ADD  DEFAULT ('') FOR [RepeatFormatDate]
GO
ALTER TABLE [helpdesk].[State] ADD  CONSTRAINT [DF_Idx]  DEFAULT ((0)) FOR [Idx]
GO
ALTER TABLE [helpdesk].[Ticket] ADD  CONSTRAINT [DF_IsChanged]  DEFAULT ((0)) FOR [IsChanged]
GO
ALTER TABLE [helpdesk].[TicketStatus] ADD  DEFAULT ((0)) FOR [IsExternal]
GO
ALTER TABLE [helpdesk].[UserGroup] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [acc].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [acc].[Customer] CHECK CONSTRAINT [FK_Customer_Customer_Customer_Id]
GO
ALTER TABLE [acc].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Period_Period_Id] FOREIGN KEY([Period_Id])
REFERENCES [acc].[Period] ([Id])
GO
ALTER TABLE [acc].[Customer] CHECK CONSTRAINT [FK_Customer_Period_Period_Id]
GO
ALTER TABLE [acc].[CustomerInvoice]  WITH CHECK ADD  CONSTRAINT [FK_CustomerInvoice_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [acc].[Customer] ([Customer_Id])
GO
ALTER TABLE [acc].[CustomerInvoice] CHECK CONSTRAINT [FK_CustomerInvoice_Customer_Customer_Id]
GO
ALTER TABLE [acc].[HourlyRate]  WITH CHECK ADD  CONSTRAINT [FK_HourlyRate_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [acc].[Customer] ([Customer_Id])
ON DELETE CASCADE
GO
ALTER TABLE [acc].[HourlyRate] CHECK CONSTRAINT [FK_HourlyRate_Customer_Customer_Id]
GO
ALTER TABLE [acc].[HourlyRate]  WITH CHECK ADD  CONSTRAINT [FK_HourlyRate_HourlyRate_HourlyRateBeyond_Id] FOREIGN KEY([HourlyRateBeyond_Id])
REFERENCES [acc].[HourlyRate] ([Id])
GO
ALTER TABLE [acc].[HourlyRate] CHECK CONSTRAINT [FK_HourlyRate_HourlyRate_HourlyRateBeyond_Id]
GO
ALTER TABLE [acc].[HourlyRate]  WITH CHECK ADD  CONSTRAINT [FK_HourlyRate_RateType_RateType_Id] FOREIGN KEY([RateType_Id])
REFERENCES [acc].[RateType] ([Id])
GO
ALTER TABLE [acc].[HourlyRate] CHECK CONSTRAINT [FK_HourlyRate_RateType_RateType_Id]
GO
ALTER TABLE [acc].[HourlyRateClassification]  WITH CHECK ADD  CONSTRAINT [rHourlyRateClassification_Classification] FOREIGN KEY([Classification_Id])
REFERENCES [helpdesk].[Classification] ([Id])
GO
ALTER TABLE [acc].[HourlyRateClassification] CHECK CONSTRAINT [rHourlyRateClassification_Classification]
GO
ALTER TABLE [acc].[HourlyRateClassification]  WITH CHECK ADD  CONSTRAINT [rHourlyRateClassification_HourlyRate] FOREIGN KEY([HourlyRate_Id])
REFERENCES [acc].[HourlyRate] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [acc].[HourlyRateClassification] CHECK CONSTRAINT [rHourlyRateClassification_HourlyRate]
GO
ALTER TABLE [acc].[HourlyRateDevice]  WITH CHECK ADD  CONSTRAINT [rHourlyRateDevice_Device] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [acc].[HourlyRateDevice] CHECK CONSTRAINT [rHourlyRateDevice_Device]
GO
ALTER TABLE [acc].[HourlyRateDevice]  WITH CHECK ADD  CONSTRAINT [rHourlyRateDevice_HourlyRate] FOREIGN KEY([HourlyRate_Id])
REFERENCES [acc].[HourlyRate] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [acc].[HourlyRateDevice] CHECK CONSTRAINT [rHourlyRateDevice_HourlyRate]
GO
ALTER TABLE [acc].[HourlyRateProject]  WITH CHECK ADD  CONSTRAINT [rHourlyRateProject_HourlyRate] FOREIGN KEY([HourlyRate_Id])
REFERENCES [acc].[HourlyRate] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [acc].[HourlyRateProject] CHECK CONSTRAINT [rHourlyRateProject_HourlyRate]
GO
ALTER TABLE [acc].[HourlyRateProject]  WITH CHECK ADD  CONSTRAINT [rHourlyRateProject_Project] FOREIGN KEY([Project_Id])
REFERENCES [helpdesk].[Project] ([Id])
GO
ALTER TABLE [acc].[HourlyRateProject] CHECK CONSTRAINT [rHourlyRateProject_Project]
GO
ALTER TABLE [acc].[HourlyRateUser]  WITH CHECK ADD  CONSTRAINT [rHourlyRateUser_HourlyRate] FOREIGN KEY([HourlyRate_Id])
REFERENCES [acc].[HourlyRate] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [acc].[HourlyRateUser] CHECK CONSTRAINT [rHourlyRateUser_HourlyRate]
GO
ALTER TABLE [acc].[HourlyRateUser]  WITH CHECK ADD  CONSTRAINT [rHourlyRateUser_User] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [acc].[HourlyRateUser] CHECK CONSTRAINT [rHourlyRateUser_User]
GO
ALTER TABLE [crm].[CategoryUser]  WITH CHECK ADD  CONSTRAINT [FK_CategoryUser_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [crm].[Category] ([Id])
GO
ALTER TABLE [crm].[CategoryUser] CHECK CONSTRAINT [FK_CategoryUser_Category_Category_Id]
GO
ALTER TABLE [crm].[CategoryUser]  WITH CHECK ADD  CONSTRAINT [FK_CategoryUser_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [crm].[Role] ([Id])
GO
ALTER TABLE [crm].[CategoryUser] CHECK CONSTRAINT [FK_CategoryUser_Role_Role_Id]
GO
ALTER TABLE [crm].[CategoryUser]  WITH CHECK ADD  CONSTRAINT [FK_CategoryUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[CategoryUser] CHECK CONSTRAINT [FK_CategoryUser_User_User_Id]
GO
ALTER TABLE [crm].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [crm].[Customer] CHECK CONSTRAINT [FK_Customer_Customer_Customer_Id]
GO
ALTER TABLE [crm].[DeletedTicket]  WITH CHECK ADD  CONSTRAINT [FK_DeletedTicket_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[DeletedTicket] CHECK CONSTRAINT [FK_DeletedTicket_User_User_Id]
GO
ALTER TABLE [crm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [crm].[Message] CHECK CONSTRAINT [FK_Message_Message_Id]
GO
ALTER TABLE [crm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [crm].[Role] ([Id])
GO
ALTER TABLE [crm].[Message] CHECK CONSTRAINT [FK_Message_Role_Role_Id]
GO
ALTER TABLE [crm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [crm].[Ticket] ([Id])
GO
ALTER TABLE [crm].[Message] CHECK CONSTRAINT [FK_Message_Ticket_Ticket_Id]
GO
ALTER TABLE [crm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_TicketStatus_TicketStatus_Id] FOREIGN KEY([TicketStatus_Id])
REFERENCES [crm].[TicketStatus] ([Id])
GO
ALTER TABLE [crm].[Message] CHECK CONSTRAINT [FK_Message_TicketStatus_TicketStatus_Id]
GO
ALTER TABLE [crm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[Message] CHECK CONSTRAINT [FK_Message_User_User_Id]
GO
ALTER TABLE [crm].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [crm].[Category] ([Id])
GO
ALTER TABLE [crm].[Session] CHECK CONSTRAINT [FK_Session_Category_Category_Id]
GO
ALTER TABLE [crm].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [crm].[Customer] ([Customer_Id])
GO
ALTER TABLE [crm].[Session] CHECK CONSTRAINT [FK_Session_Customer_Customer_Id]
GO
ALTER TABLE [crm].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_SessionContact_SessionContactFirst_Id] FOREIGN KEY([SessionContactFirst_Id])
REFERENCES [crm].[SessionContact] ([Id])
GO
ALTER TABLE [crm].[Session] CHECK CONSTRAINT [FK_Session_SessionContact_SessionContactFirst_Id]
GO
ALTER TABLE [crm].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_SessionContact_SessionContactLast_Id] FOREIGN KEY([SessionContactLast_Id])
REFERENCES [crm].[SessionContact] ([Id])
GO
ALTER TABLE [crm].[Session] CHECK CONSTRAINT [FK_Session_SessionContact_SessionContactLast_Id]
GO
ALTER TABLE [crm].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_User_UserCreate_Id] FOREIGN KEY([UserCreate_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[Session] CHECK CONSTRAINT [FK_Session_User_UserCreate_Id]
GO
ALTER TABLE [crm].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_User_UserRequest_Id] FOREIGN KEY([UserRequest_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[Session] CHECK CONSTRAINT [FK_Session_User_UserRequest_Id]
GO
ALTER TABLE [crm].[SessionAttachment]  WITH CHECK ADD  CONSTRAINT [FK_SessionAttachment_File_File_Id] FOREIGN KEY([File_Id])
REFERENCES [dbo].[File] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [crm].[SessionAttachment] CHECK CONSTRAINT [FK_SessionAttachment_File_File_Id]
GO
ALTER TABLE [crm].[SessionAttachment]  WITH CHECK ADD  CONSTRAINT [FK_SessionAttachment_Session_Session_Id] FOREIGN KEY([Session_Id])
REFERENCES [crm].[Session] ([Id])
GO
ALTER TABLE [crm].[SessionAttachment] CHECK CONSTRAINT [FK_SessionAttachment_Session_Session_Id]
GO
ALTER TABLE [crm].[SessionAttachment]  WITH CHECK ADD  CONSTRAINT [FK_SessionAttachment_SessionContact_SessionContact_Id] FOREIGN KEY([SessionContact_Id])
REFERENCES [crm].[SessionContact] ([Id])
GO
ALTER TABLE [crm].[SessionAttachment] CHECK CONSTRAINT [FK_SessionAttachment_SessionContact_SessionContact_Id]
GO
ALTER TABLE [crm].[SessionContact]  WITH CHECK ADD  CONSTRAINT [FK_SessionContact_Session_Session_Id] FOREIGN KEY([Session_Id])
REFERENCES [crm].[Session] ([Id])
GO
ALTER TABLE [crm].[SessionContact] CHECK CONSTRAINT [FK_SessionContact_Session_Session_Id]
GO
ALTER TABLE [crm].[SessionContact]  WITH CHECK ADD  CONSTRAINT [FK_SessionContact_User_UserCreate_Id] FOREIGN KEY([UserCreate_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[SessionContact] CHECK CONSTRAINT [FK_SessionContact_User_UserCreate_Id]
GO
ALTER TABLE [crm].[SessionContactUser]  WITH CHECK ADD  CONSTRAINT [FK_SessionContactUser_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [crm].[Role] ([Id])
GO
ALTER TABLE [crm].[SessionContactUser] CHECK CONSTRAINT [FK_SessionContactUser_Role_Role_Id]
GO
ALTER TABLE [crm].[SessionContactUser]  WITH CHECK ADD  CONSTRAINT [FK_SessionContactUser_SessionContact_SessionContact_Id] FOREIGN KEY([SessionContact_Id])
REFERENCES [crm].[SessionContact] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [crm].[SessionContactUser] CHECK CONSTRAINT [FK_SessionContactUser_SessionContact_SessionContact_Id]
GO
ALTER TABLE [crm].[SessionContactUser]  WITH CHECK ADD  CONSTRAINT [FK_SessionContactUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[SessionContactUser] CHECK CONSTRAINT [FK_SessionContactUser_User_User_Id]
GO
ALTER TABLE [crm].[StateMatrix]  WITH CHECK ADD  CONSTRAINT [rStateMatrix_State] FOREIGN KEY([State_Id])
REFERENCES [crm].[State] ([Id])
GO
ALTER TABLE [crm].[StateMatrix] CHECK CONSTRAINT [rStateMatrix_State]
GO
ALTER TABLE [crm].[StateMatrix]  WITH CHECK ADD  CONSTRAINT [rStateMatrix_StateNext] FOREIGN KEY([StateNext_Id])
REFERENCES [crm].[State] ([Id])
GO
ALTER TABLE [crm].[StateMatrix] CHECK CONSTRAINT [rStateMatrix_StateNext]
GO
ALTER TABLE [crm].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [crm].[Category] ([Id])
GO
ALTER TABLE [crm].[Ticket] CHECK CONSTRAINT [FK_Ticket_Category_Category_Id]
GO
ALTER TABLE [crm].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [crm].[Customer] ([Customer_Id])
GO
ALTER TABLE [crm].[Ticket] CHECK CONSTRAINT [FK_Ticket_Customer_Customer_Id]
GO
ALTER TABLE [crm].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_TicketStatus_StatusTicketFirst_Id] FOREIGN KEY([StatusTicketFirst_Id])
REFERENCES [crm].[TicketStatus] ([Id])
GO
ALTER TABLE [crm].[Ticket] CHECK CONSTRAINT [FK_Ticket_TicketStatus_StatusTicketFirst_Id]
GO
ALTER TABLE [crm].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_TicketStatus_StatusTicketLast_Id] FOREIGN KEY([StatusTicketLast_Id])
REFERENCES [crm].[TicketStatus] ([Id])
GO
ALTER TABLE [crm].[Ticket] CHECK CONSTRAINT [FK_Ticket_TicketStatus_StatusTicketLast_Id]
GO
ALTER TABLE [crm].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[Ticket] CHECK CONSTRAINT [FK_Ticket_User_User_Id]
GO
ALTER TABLE [crm].[TicketAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TicketAttachment_File_File_Id] FOREIGN KEY([File_Id])
REFERENCES [dbo].[File] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [crm].[TicketAttachment] CHECK CONSTRAINT [FK_TicketAttachment_File_File_Id]
GO
ALTER TABLE [crm].[TicketAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TicketAttachment_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [crm].[Ticket] ([Id])
GO
ALTER TABLE [crm].[TicketAttachment] CHECK CONSTRAINT [FK_TicketAttachment_Ticket_Ticket_Id]
GO
ALTER TABLE [crm].[TicketAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TicketAttachment_TicketStatus_TicketStatus_Id] FOREIGN KEY([TicketStatus_Id])
REFERENCES [crm].[TicketStatus] ([Id])
GO
ALTER TABLE [crm].[TicketAttachment] CHECK CONSTRAINT [FK_TicketAttachment_TicketStatus_TicketStatus_Id]
GO
ALTER TABLE [crm].[TicketStatus]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatus_Priority_Priority_Id] FOREIGN KEY([Priority_Id])
REFERENCES [dbo].[Priority] ([Id])
GO
ALTER TABLE [crm].[TicketStatus] CHECK CONSTRAINT [FK_TicketStatus_Priority_Priority_Id]
GO
ALTER TABLE [crm].[TicketStatus]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatus_State_State_Id] FOREIGN KEY([State_Id])
REFERENCES [crm].[State] ([Id])
GO
ALTER TABLE [crm].[TicketStatus] CHECK CONSTRAINT [FK_TicketStatus_State_State_Id]
GO
ALTER TABLE [crm].[TicketStatus]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatus_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [crm].[Ticket] ([Id])
GO
ALTER TABLE [crm].[TicketStatus] CHECK CONSTRAINT [FK_TicketStatus_Ticket_Ticket_Id]
GO
ALTER TABLE [crm].[TicketStatus]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatus_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [crm].[TicketStatus] CHECK CONSTRAINT [FK_TicketStatus_User_User_Id]
GO
ALTER TABLE [crm].[TicketUser]  WITH CHECK ADD  CONSTRAINT [FK_TicketUser_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [crm].[Role] ([Id])
GO
ALTER TABLE [crm].[TicketUser] CHECK CONSTRAINT [FK_TicketUser_Role_Role_Id]
GO
ALTER TABLE [crm].[TicketUser]  WITH CHECK ADD  CONSTRAINT [FK_TicketUser_TicketStatus_TicketStatus_Id] FOREIGN KEY([TicketStatus_Id])
REFERENCES [crm].[TicketStatus] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [crm].[TicketUser] CHECK CONSTRAINT [FK_TicketUser_TicketStatus_TicketStatus_Id]
GO
ALTER TABLE [crm].[TicketUser]  WITH CHECK ADD  CONSTRAINT [FK_TicketUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [crm].[TicketUser] CHECK CONSTRAINT [FK_TicketUser_User_User_Id]
GO
ALTER TABLE [dbo].[ActivityReport]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReport_LoginReport_LoginReport_Id] FOREIGN KEY([LoginReport_Id])
REFERENCES [dbo].[LoginReport] ([Id])
GO
ALTER TABLE [dbo].[ActivityReport] CHECK CONSTRAINT [FK_ActivityReport_LoginReport_LoginReport_Id]
GO
ALTER TABLE [dbo].[Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Attachment_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Attachment] CHECK CONSTRAINT [FK_Attachment_Message_Message_Id]
GO
ALTER TABLE [dbo].[Board]  WITH CHECK ADD  CONSTRAINT [FK_Board_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Board] CHECK CONSTRAINT [FK_Board_User_User_Id]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Country_Country_Id] FOREIGN KEY([Country_Id])
REFERENCES [dbo].[Country] ([Id])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_Country_Country_Id]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer_CustomerDepartment_Id] FOREIGN KEY([CustomerDepartment_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_Customer_CustomerDepartment_Id]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer_CustomerGroup_Id] FOREIGN KEY([CustomerGroup_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_Customer_CustomerGroup_Id]
GO
ALTER TABLE [dbo].[CustomerBoard]  WITH CHECK ADD  CONSTRAINT [rCustomerBoard_Board] FOREIGN KEY([Board_Id])
REFERENCES [dbo].[Board] ([Id])
GO
ALTER TABLE [dbo].[CustomerBoard] CHECK CONSTRAINT [rCustomerBoard_Board]
GO
ALTER TABLE [dbo].[CustomerBoard]  WITH CHECK ADD  CONSTRAINT [rCustomerBoard_Customer] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[CustomerBoard] CHECK CONSTRAINT [rCustomerBoard_Customer]
GO
ALTER TABLE [dbo].[CustomerDomain]  WITH CHECK ADD  CONSTRAINT [FK_CustomerDomain_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[CustomerDomain] CHECK CONSTRAINT [FK_CustomerDomain_Customer_Customer_Id]
GO
ALTER TABLE [dbo].[Device]  WITH CHECK ADD  CONSTRAINT [FK_Device_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_Device_Customer_Customer_Id]
GO
ALTER TABLE [dbo].[Device]  WITH CHECK ADD  CONSTRAINT [FK_Device_Device_Device_Id] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_Device_Device_Device_Id]
GO
ALTER TABLE [dbo].[Device]  WITH CHECK ADD  CONSTRAINT [FK_Device_Device_DeviceTpl_Id] FOREIGN KEY([DeviceTpl_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_Device_Device_DeviceTpl_Id]
GO
ALTER TABLE [dbo].[Device]  WITH CHECK ADD  CONSTRAINT [FK_Device_DeviceType_DeviceType_Id] FOREIGN KEY([DeviceType_Id])
REFERENCES [dbo].[DeviceType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_Device_DeviceType_DeviceType_Id]
GO
ALTER TABLE [dbo].[DeviceDepartment]  WITH CHECK ADD  CONSTRAINT [rDeviceDepartment_Customer] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[DeviceDepartment] CHECK CONSTRAINT [rDeviceDepartment_Customer]
GO
ALTER TABLE [dbo].[DeviceDepartment]  WITH CHECK ADD  CONSTRAINT [rDeviceDepartment_Device] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [dbo].[DeviceDepartment] CHECK CONSTRAINT [rDeviceDepartment_Device]
GO
ALTER TABLE [dbo].[DeviceKind]  WITH CHECK ADD  CONSTRAINT [FK_DeviceKind_DeviceType_DeviceType_Id] FOREIGN KEY([DeviceType_Id])
REFERENCES [dbo].[DeviceType] ([Id])
GO
ALTER TABLE [dbo].[DeviceKind] CHECK CONSTRAINT [FK_DeviceKind_DeviceType_DeviceType_Id]
GO
ALTER TABLE [dbo].[DevicePart]  WITH CHECK ADD  CONSTRAINT [FK_DevicePart_Device_Device_Id] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DevicePart] CHECK CONSTRAINT [FK_DevicePart_Device_Device_Id]
GO
ALTER TABLE [dbo].[DevicePart]  WITH CHECK ADD  CONSTRAINT [FK_DevicePart_DevicePart_DevicePartTpl_Id] FOREIGN KEY([DevicePartTpl_Id])
REFERENCES [dbo].[DevicePart] ([Id])
GO
ALTER TABLE [dbo].[DevicePart] CHECK CONSTRAINT [FK_DevicePart_DevicePart_DevicePartTpl_Id]
GO
ALTER TABLE [dbo].[DevicePartTpl]  WITH CHECK ADD  CONSTRAINT [FK_DevicePartTpl_DeviceTpl_DeviceTpl_Id] FOREIGN KEY([DeviceTpl_Id])
REFERENCES [dbo].[DeviceTpl] ([Id])
GO
ALTER TABLE [dbo].[DevicePartTpl] CHECK CONSTRAINT [FK_DevicePartTpl_DeviceTpl_DeviceTpl_Id]
GO
ALTER TABLE [dbo].[DeviceTpl]  WITH CHECK ADD  CONSTRAINT [FK_DeviceTpl_DeviceType_DeviceType_Id] FOREIGN KEY([DeviceType_Id])
REFERENCES [dbo].[DeviceType] ([Id])
GO
ALTER TABLE [dbo].[DeviceTpl] CHECK CONSTRAINT [FK_DeviceTpl_DeviceType_DeviceType_Id]
GO
ALTER TABLE [dbo].[LoginReport]  WITH CHECK ADD  CONSTRAINT [FK_LoginReport_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[LoginReport] CHECK CONSTRAINT [FK_LoginReport_User_User_Id]
GO
ALTER TABLE [dbo].[MailMessage]  WITH CHECK ADD  CONSTRAINT [FK_MailMessage_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailMessage] CHECK CONSTRAINT [FK_MailMessage_Message_Message_Id]
GO
ALTER TABLE [dbo].[OutOfOffice]  WITH CHECK ADD  CONSTRAINT [FK_OutOfOffice_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[OutOfOffice] CHECK CONSTRAINT [FK_OutOfOffice_User_User_Id]
GO
ALTER TABLE [dbo].[Role]  WITH CHECK ADD  CONSTRAINT [FK_Role_RoleGroup_RoleGroup_Id] FOREIGN KEY([RoleGroup_Id])
REFERENCES [dbo].[RoleGroup] ([Id])
GO
ALTER TABLE [dbo].[Role] CHECK CONSTRAINT [FK_Role_RoleGroup_RoleGroup_Id]
GO
ALTER TABLE [dbo].[RoleClaim]  WITH CHECK ADD  CONSTRAINT [FK_RoleClaim_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[RoleClaim] CHECK CONSTRAINT [FK_RoleClaim_Role_Role_Id]
GO
ALTER TABLE [dbo].[SmsMessage]  WITH CHECK ADD  CONSTRAINT [FK_SmsMessage_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SmsMessage] CHECK CONSTRAINT [FK_SmsMessage_Message_Message_Id]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Customer_Customer_Id]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_User_User_Id]
GO
ALTER TABLE [dbo].[UserAssociation]  WITH CHECK ADD  CONSTRAINT [rUserAssociation_UserJunior] FOREIGN KEY([UserJunior_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserAssociation] CHECK CONSTRAINT [rUserAssociation_UserJunior]
GO
ALTER TABLE [dbo].[UserAssociation]  WITH CHECK ADD  CONSTRAINT [rUserAssociation_UserSenior] FOREIGN KEY([UserSenior_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserAssociation] CHECK CONSTRAINT [rUserAssociation_UserSenior]
GO
ALTER TABLE [dbo].[UserClaim]  WITH CHECK ADD  CONSTRAINT [FK_UserClaim_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserClaim] CHECK CONSTRAINT [FK_UserClaim_User_User_Id]
GO
ALTER TABLE [dbo].[UserFilter]  WITH CHECK ADD  CONSTRAINT [FK_UserFilter_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserFilter] CHECK CONSTRAINT [FK_UserFilter_User_User_Id]
GO
ALTER TABLE [dbo].[UserFilterEmailSettings]  WITH CHECK ADD  CONSTRAINT [FK_UserFilterEmailSettings_UserFilter_UserFilter_Id] FOREIGN KEY([UserFilter_Id])
REFERENCES [dbo].[UserFilter] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserFilterEmailSettings] CHECK CONSTRAINT [FK_UserFilterEmailSettings_UserFilter_UserFilter_Id]
GO
ALTER TABLE [dbo].[UserFilterRole]  WITH CHECK ADD  CONSTRAINT [rUserFilterRole_Role] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [dbo].[UserFilterRole] CHECK CONSTRAINT [rUserFilterRole_Role]
GO
ALTER TABLE [dbo].[UserFilterRole]  WITH CHECK ADD  CONSTRAINT [rUserFilterRole_UserFilter] FOREIGN KEY([UserFilter_Id])
REFERENCES [dbo].[UserFilter] ([Id])
GO
ALTER TABLE [dbo].[UserFilterRole] CHECK CONSTRAINT [rUserFilterRole_UserFilter]
GO
ALTER TABLE [dbo].[UserLogin]  WITH CHECK ADD  CONSTRAINT [FK_UserLogin_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserLogin] CHECK CONSTRAINT [FK_UserLogin_User_User_Id]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Customer_Customer_Id]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role_Role_Id]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User_User_Id]
GO
ALTER TABLE [dbo].[UserSettings]  WITH CHECK ADD  CONSTRAINT [FK_UserSettings_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserSettings] CHECK CONSTRAINT [FK_UserSettings_User_User_Id]
GO
ALTER TABLE [dbo].[UserToken]  WITH CHECK ADD  CONSTRAINT [FK_UserToken_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserToken] CHECK CONSTRAINT [FK_UserToken_User_User_Id]
GO
ALTER TABLE [frm].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [frm].[Customer] CHECK CONSTRAINT [FK_Customer_Customer_Customer_Id]
GO
ALTER TABLE [frm].[DeletedFormInstance]  WITH CHECK ADD  CONSTRAINT [FK_DeletedFormInstance_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [frm].[DeletedFormInstance] CHECK CONSTRAINT [FK_DeletedFormInstance_User_User_Id]
GO
ALTER TABLE [frm].[Form]  WITH CHECK ADD  CONSTRAINT [FK_Form_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [frm].[Customer] ([Customer_Id])
GO
ALTER TABLE [frm].[Form] CHECK CONSTRAINT [FK_Form_Customer_Customer_Id]
GO
ALTER TABLE [frm].[FormInstance]  WITH CHECK ADD  CONSTRAINT [FK_FormInstance_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [frm].[FormInstance] CHECK CONSTRAINT [FK_FormInstance_Customer_Customer_Id]
GO
ALTER TABLE [frm].[FormInstance]  WITH CHECK ADD  CONSTRAINT [FK_FormInstance_FormState_FormState_Id] FOREIGN KEY([FormState_Id])
REFERENCES [frm].[FormState] ([Id])
GO
ALTER TABLE [frm].[FormInstance] CHECK CONSTRAINT [FK_FormInstance_FormState_FormState_Id]
GO
ALTER TABLE [frm].[FormInstance]  WITH CHECK ADD  CONSTRAINT [FK_FormInstance_FormVariant_FormVariant_Id] FOREIGN KEY([FormVariant_Id])
REFERENCES [frm].[FormVariant] ([Id])
GO
ALTER TABLE [frm].[FormInstance] CHECK CONSTRAINT [FK_FormInstance_FormVariant_FormVariant_Id]
GO
ALTER TABLE [frm].[FormInstance]  WITH CHECK ADD  CONSTRAINT [FK_FormInstance_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [frm].[FormInstance] CHECK CONSTRAINT [FK_FormInstance_User_User_Id]
GO
ALTER TABLE [frm].[FormInstance]  WITH CHECK ADD  CONSTRAINT [FK_FormInstance_User_UserCreate_Id] FOREIGN KEY([UserCreate_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [frm].[FormInstance] CHECK CONSTRAINT [FK_FormInstance_User_UserCreate_Id]
GO
ALTER TABLE [frm].[FormTaskGroup]  WITH CHECK ADD  CONSTRAINT [rFormTaskGroup_Form] FOREIGN KEY([Form_Id])
REFERENCES [frm].[Form] ([Id])
GO
ALTER TABLE [frm].[FormTaskGroup] CHECK CONSTRAINT [rFormTaskGroup_Form]
GO
ALTER TABLE [frm].[FormTaskGroup]  WITH CHECK ADD  CONSTRAINT [rFormTaskGroup_TaskGroup] FOREIGN KEY([TaskGroup_Id])
REFERENCES [frm].[TaskGroup] ([Id])
GO
ALTER TABLE [frm].[FormTaskGroup] CHECK CONSTRAINT [rFormTaskGroup_TaskGroup]
GO
ALTER TABLE [frm].[FormVariant]  WITH CHECK ADD  CONSTRAINT [FK_FormVariant_Form_Form_Id] FOREIGN KEY([Form_Id])
REFERENCES [frm].[Form] ([Id])
GO
ALTER TABLE [frm].[FormVariant] CHECK CONSTRAINT [FK_FormVariant_Form_Form_Id]
GO
ALTER TABLE [frm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_FormInstance_FormInstance_Id] FOREIGN KEY([FormInstance_Id])
REFERENCES [frm].[FormInstance] ([Id])
GO
ALTER TABLE [frm].[Message] CHECK CONSTRAINT [FK_Message_FormInstance_FormInstance_Id]
GO
ALTER TABLE [frm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [frm].[Message] CHECK CONSTRAINT [FK_Message_Message_Id]
GO
ALTER TABLE [frm].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [frm].[Message] CHECK CONSTRAINT [FK_Message_User_User_Id]
GO
ALTER TABLE [frm].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_TaskGroup_TaskGroup_Id] FOREIGN KEY([TaskGroup_Id])
REFERENCES [frm].[TaskGroup] ([Id])
GO
ALTER TABLE [frm].[Task] CHECK CONSTRAINT [FK_Task_TaskGroup_TaskGroup_Id]
GO
ALTER TABLE [frm].[TaskFormVariant]  WITH CHECK ADD  CONSTRAINT [FK_TaskFormVariant_Form_Form_Id] FOREIGN KEY([Form_Id])
REFERENCES [frm].[Form] ([Id])
GO
ALTER TABLE [frm].[TaskFormVariant] CHECK CONSTRAINT [FK_TaskFormVariant_Form_Form_Id]
GO
ALTER TABLE [frm].[TaskFormVariant]  WITH CHECK ADD  CONSTRAINT [FK_TaskFormVariant_FormVariant_Variant_Id] FOREIGN KEY([Variant_Id])
REFERENCES [frm].[FormVariant] ([Id])
GO
ALTER TABLE [frm].[TaskFormVariant] CHECK CONSTRAINT [FK_TaskFormVariant_FormVariant_Variant_Id]
GO
ALTER TABLE [frm].[TaskFormVariant]  WITH CHECK ADD  CONSTRAINT [FK_TaskFormVariant_Task_Task_Id] FOREIGN KEY([Task_Id])
REFERENCES [frm].[Task] ([Id])
GO
ALTER TABLE [frm].[TaskFormVariant] CHECK CONSTRAINT [FK_TaskFormVariant_Task_Task_Id]
GO
ALTER TABLE [frm].[TaskGroup]  WITH CHECK ADD  CONSTRAINT [FK_TaskGroup_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [frm].[Customer] ([Customer_Id])
GO
ALTER TABLE [frm].[TaskGroup] CHECK CONSTRAINT [FK_TaskGroup_Customer_Customer_Id]
GO
ALTER TABLE [frm].[TaskGroupUser]  WITH CHECK ADD  CONSTRAINT [rTaskGroupUser_TaskGroup] FOREIGN KEY([TaskGroup_Id])
REFERENCES [frm].[TaskGroup] ([Id])
GO
ALTER TABLE [frm].[TaskGroupUser] CHECK CONSTRAINT [rTaskGroupUser_TaskGroup]
GO
ALTER TABLE [frm].[TaskGroupUser]  WITH CHECK ADD  CONSTRAINT [rTaskGroupUser_User] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [frm].[TaskGroupUser] CHECK CONSTRAINT [rTaskGroupUser_User]
GO
ALTER TABLE [frm].[TaskGroupUserGroup]  WITH CHECK ADD  CONSTRAINT [rTaskGroupUserGroup_TaskGroup] FOREIGN KEY([TaskGroup_Id])
REFERENCES [frm].[TaskGroup] ([Id])
GO
ALTER TABLE [frm].[TaskGroupUserGroup] CHECK CONSTRAINT [rTaskGroupUserGroup_TaskGroup]
GO
ALTER TABLE [frm].[TaskGroupUserGroup]  WITH CHECK ADD  CONSTRAINT [rTaskGroupUserGroup_UserGroup] FOREIGN KEY([UserGroup_Id])
REFERENCES [helpdesk].[UserGroup] ([Id])
GO
ALTER TABLE [frm].[TaskGroupUserGroup] CHECK CONSTRAINT [rTaskGroupUserGroup_UserGroup]
GO
ALTER TABLE [frm].[TaskInstance]  WITH CHECK ADD  CONSTRAINT [FK_TaskInstance_FormInstance_FormInstance_Id] FOREIGN KEY([FormInstance_Id])
REFERENCES [frm].[FormInstance] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [frm].[TaskInstance] CHECK CONSTRAINT [FK_TaskInstance_FormInstance_FormInstance_Id]
GO
ALTER TABLE [frm].[TaskInstance]  WITH CHECK ADD  CONSTRAINT [FK_TaskInstance_Task_Task_Id] FOREIGN KEY([Task_Id])
REFERENCES [frm].[Task] ([Id])
GO
ALTER TABLE [frm].[TaskInstance] CHECK CONSTRAINT [FK_TaskInstance_Task_Task_Id]
GO
ALTER TABLE [frm].[TaskInstance]  WITH CHECK ADD  CONSTRAINT [FK_TaskInstance_TaskState_TaskState_Id] FOREIGN KEY([TaskState_Id])
REFERENCES [frm].[TaskState] ([Id])
GO
ALTER TABLE [frm].[TaskInstance] CHECK CONSTRAINT [FK_TaskInstance_TaskState_TaskState_Id]
GO
ALTER TABLE [helpdesk].[Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Attachment_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[Attachment] CHECK CONSTRAINT [FK_Attachment_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Attachment_FAQ_Faq_Id] FOREIGN KEY([Faq_Id])
REFERENCES [helpdesk].[FAQ] ([Id])
GO
ALTER TABLE [helpdesk].[Attachment] CHECK CONSTRAINT [FK_Attachment_FAQ_Faq_Id]
GO
ALTER TABLE [helpdesk].[Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Attachment_File_File_Id] FOREIGN KEY([File_Id])
REFERENCES [dbo].[File] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[Attachment] CHECK CONSTRAINT [FK_Attachment_File_File_Id]
GO
ALTER TABLE [helpdesk].[Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Attachment_ServiceList_ServiceList_Id] FOREIGN KEY([ServiceList_Id])
REFERENCES [helpdesk].[ServiceList] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[Attachment] CHECK CONSTRAINT [FK_Attachment_ServiceList_ServiceList_Id]
GO
ALTER TABLE [helpdesk].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [helpdesk].[Customer] CHECK CONSTRAINT [FK_Customer_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_EmailType_EmailType_Id] FOREIGN KEY([EmailType_Id])
REFERENCES [helpdesk].[EmailType] ([Id])
GO
ALTER TABLE [helpdesk].[Customer] CHECK CONSTRAINT [FK_Customer_EmailType_EmailType_Id]
GO
ALTER TABLE [helpdesk].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_SMSType_Smstype_Id] FOREIGN KEY([Smstype_Id])
REFERENCES [helpdesk].[SMSType] ([Id])
GO
ALTER TABLE [helpdesk].[Customer] CHECK CONSTRAINT [FK_Customer_SMSType_Smstype_Id]
GO
ALTER TABLE [helpdesk].[CustomerApplication]  WITH CHECK ADD  CONSTRAINT [rCustomerApplication_Application] FOREIGN KEY([Application_Id])
REFERENCES [helpdesk].[Application] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerApplication] CHECK CONSTRAINT [rCustomerApplication_Application]
GO
ALTER TABLE [helpdesk].[CustomerApplication]  WITH CHECK ADD  CONSTRAINT [rCustomerApplication_Customer] FOREIGN KEY([Customer_id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[CustomerApplication] CHECK CONSTRAINT [rCustomerApplication_Customer]
GO
ALTER TABLE [helpdesk].[CustomerCategory]  WITH CHECK ADD  CONSTRAINT [rCustomerCategory_Category] FOREIGN KEY([Category_Id])
REFERENCES [helpdesk].[Category] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerCategory] CHECK CONSTRAINT [rCustomerCategory_Category]
GO
ALTER TABLE [helpdesk].[CustomerCategory]  WITH CHECK ADD  CONSTRAINT [rCustomerCategory_Customer] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[CustomerCategory] CHECK CONSTRAINT [rCustomerCategory_Customer]
GO
ALTER TABLE [helpdesk].[CustomerClassification]  WITH CHECK ADD  CONSTRAINT [rCustomerClassification_Classification] FOREIGN KEY([Classification_Id])
REFERENCES [helpdesk].[Classification] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerClassification] CHECK CONSTRAINT [rCustomerClassification_Classification]
GO
ALTER TABLE [helpdesk].[CustomerClassification]  WITH CHECK ADD  CONSTRAINT [rCustomerClassification_Customer] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[CustomerClassification] CHECK CONSTRAINT [rCustomerClassification_Customer]
GO
ALTER TABLE [helpdesk].[CustomerCustomField]  WITH CHECK ADD  CONSTRAINT [rCustomerCustomField_CustomerHD] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[CustomerCustomField] CHECK CONSTRAINT [rCustomerCustomField_CustomerHD]
GO
ALTER TABLE [helpdesk].[CustomerCustomField]  WITH CHECK ADD  CONSTRAINT [rCustomerCustomField_CustomField] FOREIGN KEY([CustomField_Id])
REFERENCES [helpdesk].[CustomField] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerCustomField] CHECK CONSTRAINT [rCustomerCustomField_CustomField]
GO
ALTER TABLE [helpdesk].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_CustomerUser_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [helpdesk].[Category] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerUser] CHECK CONSTRAINT [FK_CustomerUser_Category_Category_Id]
GO
ALTER TABLE [helpdesk].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_CustomerUser_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[CustomerUser] CHECK CONSTRAINT [FK_CustomerUser_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_CustomerUser_Device_DeviceKey_Id] FOREIGN KEY([DeviceKey_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerUser] CHECK CONSTRAINT [FK_CustomerUser_Device_DeviceKey_Id]
GO
ALTER TABLE [helpdesk].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_CustomerUser_Project_Project_Id] FOREIGN KEY([Project_Id])
REFERENCES [helpdesk].[Project] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerUser] CHECK CONSTRAINT [FK_CustomerUser_Project_Project_Id]
GO
ALTER TABLE [helpdesk].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_CustomerUser_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerUser] CHECK CONSTRAINT [FK_CustomerUser_Role_Role_Id]
GO
ALTER TABLE [helpdesk].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_CustomerUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerUser] CHECK CONSTRAINT [FK_CustomerUser_User_User_Id]
GO
ALTER TABLE [helpdesk].[CustomerUser]  WITH CHECK ADD  CONSTRAINT [FK_CustomerUser_User_UserKey_Id] FOREIGN KEY([UserKey_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[CustomerUser] CHECK CONSTRAINT [FK_CustomerUser_User_UserKey_Id]
GO
ALTER TABLE [helpdesk].[CustomField]  WITH CHECK ADD  CONSTRAINT [FK_CustomField_CustomFieldType_CustomFieldType_Id] FOREIGN KEY([CustomFieldType_Id])
REFERENCES [helpdesk].[CustomFieldType] ([Id])
GO
ALTER TABLE [helpdesk].[CustomField] CHECK CONSTRAINT [FK_CustomField_CustomFieldType_CustomFieldType_Id]
GO
ALTER TABLE [helpdesk].[CustomFieldCategory]  WITH CHECK ADD  CONSTRAINT [rCustomFieldCategory_Category] FOREIGN KEY([Category_Id])
REFERENCES [helpdesk].[Category] ([Id])
GO
ALTER TABLE [helpdesk].[CustomFieldCategory] CHECK CONSTRAINT [rCustomFieldCategory_Category]
GO
ALTER TABLE [helpdesk].[CustomFieldCategory]  WITH CHECK ADD  CONSTRAINT [rCustomFieldCategory_CustomField] FOREIGN KEY([CustomField_Id])
REFERENCES [helpdesk].[CustomField] ([Id])
GO
ALTER TABLE [helpdesk].[CustomFieldCategory] CHECK CONSTRAINT [rCustomFieldCategory_CustomField]
GO
ALTER TABLE [helpdesk].[CustomFieldClassification]  WITH CHECK ADD  CONSTRAINT [rCustomFieldClassification_Classification] FOREIGN KEY([Classification_Id])
REFERENCES [helpdesk].[Classification] ([Id])
GO
ALTER TABLE [helpdesk].[CustomFieldClassification] CHECK CONSTRAINT [rCustomFieldClassification_Classification]
GO
ALTER TABLE [helpdesk].[CustomFieldClassification]  WITH CHECK ADD  CONSTRAINT [rCustomFieldClassification_CustomField] FOREIGN KEY([CustomField_Id])
REFERENCES [helpdesk].[CustomField] ([Id])
GO
ALTER TABLE [helpdesk].[CustomFieldClassification] CHECK CONSTRAINT [rCustomFieldClassification_CustomField]
GO
ALTER TABLE [helpdesk].[CustomFieldCodeList]  WITH CHECK ADD  CONSTRAINT [FK_CustomFieldCodeList_CustomField_CustomField_Id] FOREIGN KEY([CustomField_Id])
REFERENCES [helpdesk].[CustomField] ([Id])
GO
ALTER TABLE [helpdesk].[CustomFieldCodeList] CHECK CONSTRAINT [FK_CustomFieldCodeList_CustomField_CustomField_Id]
GO
ALTER TABLE [helpdesk].[CustomFieldState]  WITH CHECK ADD  CONSTRAINT [rCustomFieldState_CustomField] FOREIGN KEY([CustomField_Id])
REFERENCES [helpdesk].[CustomField] ([Id])
GO
ALTER TABLE [helpdesk].[CustomFieldState] CHECK CONSTRAINT [rCustomFieldState_CustomField]
GO
ALTER TABLE [helpdesk].[CustomFieldState]  WITH CHECK ADD  CONSTRAINT [rCustomFieldState_State] FOREIGN KEY([State_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[CustomFieldState] CHECK CONSTRAINT [rCustomFieldState_State]
GO
ALTER TABLE [helpdesk].[DefaultResponse]  WITH CHECK ADD  CONSTRAINT [FK_DefaultResponse_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[DefaultResponse] CHECK CONSTRAINT [FK_DefaultResponse_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[DefaultResponse]  WITH CHECK ADD  CONSTRAINT [FK_DefaultResponse_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[DefaultResponse] CHECK CONSTRAINT [FK_DefaultResponse_User_User_Id]
GO
ALTER TABLE [helpdesk].[DefaultTicketUser]  WITH CHECK ADD  CONSTRAINT [FK_DefaultTicketUser_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [helpdesk].[DefaultTicketUser] CHECK CONSTRAINT [FK_DefaultTicketUser_Role_Role_Id]
GO
ALTER TABLE [helpdesk].[DefaultTicketUser]  WITH CHECK ADD  CONSTRAINT [FK_DefaultTicketUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[DefaultTicketUser] CHECK CONSTRAINT [FK_DefaultTicketUser_User_User_Id]
GO
ALTER TABLE [helpdesk].[DefaultTicketUser]  WITH CHECK ADD  CONSTRAINT [FK_DefaultTicketUser_User_UserSelect_Id] FOREIGN KEY([UserSelect_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[DefaultTicketUser] CHECK CONSTRAINT [FK_DefaultTicketUser_User_UserSelect_Id]
GO
ALTER TABLE [helpdesk].[DeletedTicket]  WITH CHECK ADD  CONSTRAINT [FK_DeletedTicket_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[DeletedTicket] CHECK CONSTRAINT [FK_DeletedTicket_User_User_Id]
GO
ALTER TABLE [helpdesk].[DeviceBook]  WITH CHECK ADD  CONSTRAINT [FK_DeviceBook_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[DeviceBook] CHECK CONSTRAINT [FK_DeviceBook_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[DeviceBook]  WITH CHECK ADD  CONSTRAINT [FK_DeviceBook_Device_Device_Id] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [helpdesk].[DeviceBook] CHECK CONSTRAINT [FK_DeviceBook_Device_Device_Id]
GO
ALTER TABLE [helpdesk].[DeviceBook]  WITH CHECK ADD  CONSTRAINT [FK_DeviceBook_DeviceBookCategory_DeviceBookCategory_Id] FOREIGN KEY([DeviceBookCategory_Id])
REFERENCES [helpdesk].[DeviceBookCategory] ([Id])
GO
ALTER TABLE [helpdesk].[DeviceBook] CHECK CONSTRAINT [FK_DeviceBook_DeviceBookCategory_DeviceBookCategory_Id]
GO
ALTER TABLE [helpdesk].[DeviceBook]  WITH CHECK ADD  CONSTRAINT [FK_DeviceBook_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[DeviceBook] CHECK CONSTRAINT [FK_DeviceBook_User_User_Id]
GO
ALTER TABLE [helpdesk].[DevicePartServiceList]  WITH CHECK ADD  CONSTRAINT [FK_DevicePartServiceList_DevicePart_DevicePart_Id] FOREIGN KEY([DevicePart_Id])
REFERENCES [dbo].[DevicePart] ([Id])
GO
ALTER TABLE [helpdesk].[DevicePartServiceList] CHECK CONSTRAINT [FK_DevicePartServiceList_DevicePart_DevicePart_Id]
GO
ALTER TABLE [helpdesk].[DevicePartServiceList]  WITH CHECK ADD  CONSTRAINT [FK_DevicePartServiceList_DeviceServiceList_DeviceServiceList_Id] FOREIGN KEY([DeviceServiceList_Id])
REFERENCES [helpdesk].[DeviceServiceList] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[DevicePartServiceList] CHECK CONSTRAINT [FK_DevicePartServiceList_DeviceServiceList_DeviceServiceList_Id]
GO
ALTER TABLE [helpdesk].[DevicePartServiceList]  WITH CHECK ADD  CONSTRAINT [FK_DevicePartServiceList_Reason_Reason_Id] FOREIGN KEY([Reason_Id])
REFERENCES [helpdesk].[Reason] ([Id])
GO
ALTER TABLE [helpdesk].[DevicePartServiceList] CHECK CONSTRAINT [FK_DevicePartServiceList_Reason_Reason_Id]
GO
ALTER TABLE [helpdesk].[DeviceServiceList]  WITH CHECK ADD  CONSTRAINT [FK_DeviceServiceList_Device_Device_Id] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [helpdesk].[DeviceServiceList] CHECK CONSTRAINT [FK_DeviceServiceList_Device_Device_Id]
GO
ALTER TABLE [helpdesk].[DeviceServiceList]  WITH CHECK ADD  CONSTRAINT [FK_DeviceServiceList_ServiceList_ServiceList_Id] FOREIGN KEY([ServiceList_Id])
REFERENCES [helpdesk].[ServiceList] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[DeviceServiceList] CHECK CONSTRAINT [FK_DeviceServiceList_ServiceList_ServiceList_Id]
GO
ALTER TABLE [helpdesk].[DeviceTicket]  WITH CHECK ADD  CONSTRAINT [FK_DeviceTicket_Device_Device_Id] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
GO
ALTER TABLE [helpdesk].[DeviceTicket] CHECK CONSTRAINT [FK_DeviceTicket_Device_Device_Id]
GO
ALTER TABLE [helpdesk].[DeviceTicket]  WITH CHECK ADD  CONSTRAINT [FK_DeviceTicket_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[DeviceTicket] CHECK CONSTRAINT [FK_DeviceTicket_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[DomainTicketUser]  WITH CHECK ADD  CONSTRAINT [FK_DomainTicketUser_CustomerDomain_CustomerDomain_Id] FOREIGN KEY([CustomerDomain_Id])
REFERENCES [dbo].[CustomerDomain] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[DomainTicketUser] CHECK CONSTRAINT [FK_DomainTicketUser_CustomerDomain_CustomerDomain_Id]
GO
ALTER TABLE [helpdesk].[DomainTicketUser]  WITH CHECK ADD  CONSTRAINT [FK_DomainTicketUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[DomainTicketUser] CHECK CONSTRAINT [FK_DomainTicketUser_User_User_Id]
GO
ALTER TABLE [helpdesk].[FAQ]  WITH CHECK ADD  CONSTRAINT [FK_FAQ_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [helpdesk].[Category] ([Id])
GO
ALTER TABLE [helpdesk].[FAQ] CHECK CONSTRAINT [FK_FAQ_Category_Category_Id]
GO
ALTER TABLE [helpdesk].[MailTicket]  WITH CHECK ADD  CONSTRAINT [FK_MailTicket_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[MailTicket] CHECK CONSTRAINT [FK_MailTicket_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[MailTicket]  WITH CHECK ADD  CONSTRAINT [FK_MailTicket_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[MailTicket] CHECK CONSTRAINT [FK_MailTicket_User_User_Id]
GO
ALTER TABLE [helpdesk].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[Message] CHECK CONSTRAINT [FK_Message_Message_Id]
GO
ALTER TABLE [helpdesk].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [helpdesk].[Message] CHECK CONSTRAINT [FK_Message_Role_Role_Id]
GO
ALTER TABLE [helpdesk].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[Message] CHECK CONSTRAINT [FK_Message_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_TicketStatus_TicketStatus_Id] FOREIGN KEY([TicketStatus_Id])
REFERENCES [helpdesk].[TicketStatus] ([Id])
GO
ALTER TABLE [helpdesk].[Message] CHECK CONSTRAINT [FK_Message_TicketStatus_TicketStatus_Id]
GO
ALTER TABLE [helpdesk].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[Message] CHECK CONSTRAINT [FK_Message_User_User_Id]
GO
ALTER TABLE [helpdesk].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[Project] CHECK CONSTRAINT [FK_Project_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Project_Project_Id] FOREIGN KEY([Project_Id])
REFERENCES [helpdesk].[Project] ([Id])
GO
ALTER TABLE [helpdesk].[Project] CHECK CONSTRAINT [FK_Project_Project_Project_Id]
GO
ALTER TABLE [helpdesk].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_ProjectType_ProjectType_Id] FOREIGN KEY([ProjectType_Id])
REFERENCES [helpdesk].[ProjectType] ([Id])
GO
ALTER TABLE [helpdesk].[Project] CHECK CONSTRAINT [FK_Project_ProjectType_ProjectType_Id]
GO
ALTER TABLE [helpdesk].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_ServiceEffort_ServiceEffort_Id] FOREIGN KEY([ServiceEffort_Id])
REFERENCES [hr].[ServiceEffort] ([Id])
GO
ALTER TABLE [helpdesk].[Project] CHECK CONSTRAINT [FK_Project_ServiceEffort_ServiceEffort_Id]
GO
ALTER TABLE [helpdesk].[Ranking]  WITH CHECK ADD  CONSTRAINT [FK_Ranking_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[Ranking] CHECK CONSTRAINT [FK_Ranking_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[Ranking]  WITH CHECK ADD  CONSTRAINT [FK_Ranking_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[Ranking] CHECK CONSTRAINT [FK_Ranking_User_User_Id]
GO
ALTER TABLE [helpdesk].[Routine]  WITH CHECK ADD  CONSTRAINT [FK_Routine_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[Routine] CHECK CONSTRAINT [FK_Routine_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[Routine]  WITH CHECK ADD  CONSTRAINT [FK_Routine_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[Routine] CHECK CONSTRAINT [FK_Routine_User_User_Id]
GO
ALTER TABLE [helpdesk].[RoutineTicket]  WITH CHECK ADD  CONSTRAINT [rRoutineTicket_Routine] FOREIGN KEY([Routine_Id])
REFERENCES [helpdesk].[Routine] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[RoutineTicket] CHECK CONSTRAINT [rRoutineTicket_Routine]
GO
ALTER TABLE [helpdesk].[RoutineTicket]  WITH CHECK ADD  CONSTRAINT [rRoutineTicket_Ticket] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[RoutineTicket] CHECK CONSTRAINT [rRoutineTicket_Ticket]
GO
ALTER TABLE [helpdesk].[ServiceList]  WITH CHECK ADD  CONSTRAINT [FK_ServiceList_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [helpdesk].[Category] ([Id])
GO
ALTER TABLE [helpdesk].[ServiceList] CHECK CONSTRAINT [FK_ServiceList_Category_Category_Id]
GO
ALTER TABLE [helpdesk].[ServiceList]  WITH CHECK ADD  CONSTRAINT [FK_ServiceList_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [helpdesk].[ServiceList] CHECK CONSTRAINT [FK_ServiceList_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[ServiceList]  WITH CHECK ADD  CONSTRAINT [FK_ServiceList_RepairType_RepairType_Id] FOREIGN KEY([RepairType_Id])
REFERENCES [helpdesk].[RepairType] ([Id])
GO
ALTER TABLE [helpdesk].[ServiceList] CHECK CONSTRAINT [FK_ServiceList_RepairType_RepairType_Id]
GO
ALTER TABLE [helpdesk].[ServiceList]  WITH CHECK ADD  CONSTRAINT [FK_ServiceList_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[ServiceList] CHECK CONSTRAINT [FK_ServiceList_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[ServiceList]  WITH CHECK ADD  CONSTRAINT [FK_ServiceList_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[ServiceList] CHECK CONSTRAINT [FK_ServiceList_User_User_Id]
GO
ALTER TABLE [helpdesk].[ServiceList]  WITH CHECK ADD  CONSTRAINT [FK_ServiceList_User_UserTake_Id] FOREIGN KEY([UserTake_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[ServiceList] CHECK CONSTRAINT [FK_ServiceList_User_UserTake_Id]
GO
ALTER TABLE [helpdesk].[ServiceProvided]  WITH CHECK ADD  CONSTRAINT [FK_ServiceProvided_ServiceList_ServiceList_Id] FOREIGN KEY([ServiceList_Id])
REFERENCES [helpdesk].[ServiceList] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[ServiceProvided] CHECK CONSTRAINT [FK_ServiceProvided_ServiceList_ServiceList_Id]
GO
ALTER TABLE [helpdesk].[Settings]  WITH CHECK ADD  CONSTRAINT [FK_Settings_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[Settings] CHECK CONSTRAINT [FK_Settings_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[Settings]  WITH CHECK ADD  CONSTRAINT [FK_Settings_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[Settings] CHECK CONSTRAINT [FK_Settings_User_User_Id]
GO
ALTER TABLE [helpdesk].[SettingsInfo]  WITH CHECK ADD  CONSTRAINT [FK_SettingsInfo_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [helpdesk].[SettingsInfo] CHECK CONSTRAINT [FK_SettingsInfo_Role_Role_Id]
GO
ALTER TABLE [helpdesk].[SettingsInfo]  WITH CHECK ADD  CONSTRAINT [FK_SettingsInfo_Settings_Settings_Id] FOREIGN KEY([Settings_Id])
REFERENCES [helpdesk].[Settings] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[SettingsInfo] CHECK CONSTRAINT [FK_SettingsInfo_Settings_Settings_Id]
GO
ALTER TABLE [helpdesk].[SettingsInfo]  WITH CHECK ADD  CONSTRAINT [FK_SettingsInfo_State_State_Id] FOREIGN KEY([State_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[SettingsInfo] CHECK CONSTRAINT [FK_SettingsInfo_State_State_Id]
GO
ALTER TABLE [helpdesk].[SettingsState]  WITH CHECK ADD  CONSTRAINT [rSettingsState_Settings] FOREIGN KEY([Settings_Id])
REFERENCES [helpdesk].[Settings] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[SettingsState] CHECK CONSTRAINT [rSettingsState_Settings]
GO
ALTER TABLE [helpdesk].[SettingsState]  WITH CHECK ADD  CONSTRAINT [rSettingsState_State] FOREIGN KEY([State_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[SettingsState] CHECK CONSTRAINT [rSettingsState_State]
GO
ALTER TABLE [helpdesk].[StateMatrix]  WITH CHECK ADD  CONSTRAINT [rStateMatrix_State] FOREIGN KEY([State_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[StateMatrix] CHECK CONSTRAINT [rStateMatrix_State]
GO
ALTER TABLE [helpdesk].[StateMatrix]  WITH CHECK ADD  CONSTRAINT [rStateMatrix_StateNext] FOREIGN KEY([StateNext_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[StateMatrix] CHECK CONSTRAINT [rStateMatrix_StateNext]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Category_Category_Id] FOREIGN KEY([Category_Id])
REFERENCES [helpdesk].[Category] ([Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_Category_Category_Id]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Classification_Classification_Id] FOREIGN KEY([Classification_Id])
REFERENCES [helpdesk].[Classification] ([Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_Classification_Classification_Id]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Customer_CustomerDepartment_Id] FOREIGN KEY([CustomerDepartment_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_Customer_CustomerDepartment_Id]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Project_Project_Id] FOREIGN KEY([Project_Id])
REFERENCES [helpdesk].[Project] ([Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_Project_Project_Id]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_TicketStatusFull_StatusTicketFirst_Id] FOREIGN KEY([StatusTicketFirst_Id])
REFERENCES [helpdesk].[TicketStatusFull] ([TicketStatus_Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_TicketStatusFull_StatusTicketFirst_Id]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_TicketStatusFull_StatusTicketLast_Id] FOREIGN KEY([StatusTicketLast_Id])
REFERENCES [helpdesk].[TicketStatusFull] ([TicketStatus_Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_TicketStatusFull_StatusTicketLast_Id]
GO
ALTER TABLE [helpdesk].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[Ticket] CHECK CONSTRAINT [FK_Ticket_User_User_Id]
GO
ALTER TABLE [helpdesk].[TicketAlert]  WITH CHECK ADD  CONSTRAINT [FK_TicketAlert_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketAlert] CHECK CONSTRAINT [FK_TicketAlert_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[TicketAlert]  WITH CHECK ADD  CONSTRAINT [FK_TicketAlert_TicketStatus_TicketStatus_Id] FOREIGN KEY([TicketStatus_Id])
REFERENCES [helpdesk].[TicketStatus] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketAlert] CHECK CONSTRAINT [FK_TicketAlert_TicketStatus_TicketStatus_Id]
GO
ALTER TABLE [helpdesk].[TicketAlert]  WITH CHECK ADD  CONSTRAINT [FK_TicketAlert_WatchDog_WatchDog_Id] FOREIGN KEY([WatchDog_Id])
REFERENCES [helpdesk].[WatchDog] ([Id])
GO
ALTER TABLE [helpdesk].[TicketAlert] CHECK CONSTRAINT [FK_TicketAlert_WatchDog_WatchDog_Id]
GO
ALTER TABLE [helpdesk].[TicketAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TicketAttachment_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[TicketAttachment] CHECK CONSTRAINT [FK_TicketAttachment_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[TicketAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TicketAttachment_File_File_Id] FOREIGN KEY([File_Id])
REFERENCES [dbo].[File] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketAttachment] CHECK CONSTRAINT [FK_TicketAttachment_File_File_Id]
GO
ALTER TABLE [helpdesk].[TicketAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TicketAttachment_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[TicketAttachment] CHECK CONSTRAINT [FK_TicketAttachment_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[TicketAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TicketAttachment_TicketStatus_TicketStatus_Id] FOREIGN KEY([TicketStatus_Id])
REFERENCES [helpdesk].[TicketStatus] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketAttachment] CHECK CONSTRAINT [FK_TicketAttachment_TicketStatus_TicketStatus_Id]
GO
ALTER TABLE [helpdesk].[TicketComment]  WITH CHECK ADD  CONSTRAINT [rTicketComment_TicketStatus] FOREIGN KEY([TicketStatus_Id])
REFERENCES [helpdesk].[TicketStatus] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketComment] CHECK CONSTRAINT [rTicketComment_TicketStatus]
GO
ALTER TABLE [helpdesk].[TicketEx]  WITH CHECK ADD  CONSTRAINT [FK_TicketEx_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[TicketEx] CHECK CONSTRAINT [FK_TicketEx_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[TicketLink]  WITH CHECK ADD  CONSTRAINT [rTicketLink_Ticket] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[TicketLink] CHECK CONSTRAINT [rTicketLink_Ticket]
GO
ALTER TABLE [helpdesk].[TicketLink]  WITH CHECK ADD  CONSTRAINT [rTicketLink_TicketParent] FOREIGN KEY([TicketParent_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[TicketLink] CHECK CONSTRAINT [rTicketLink_TicketParent]
GO
ALTER TABLE [helpdesk].[TicketStatus]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatus_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[TicketStatus] CHECK CONSTRAINT [FK_TicketStatus_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[TicketStatus]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatus_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[TicketStatus] CHECK CONSTRAINT [FK_TicketStatus_User_User_Id]
GO
ALTER TABLE [helpdesk].[TicketStatusFull]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatusFull_Priority_Priority_Id] FOREIGN KEY([Priority_Id])
REFERENCES [dbo].[Priority] ([Id])
GO
ALTER TABLE [helpdesk].[TicketStatusFull] CHECK CONSTRAINT [FK_TicketStatusFull_Priority_Priority_Id]
GO
ALTER TABLE [helpdesk].[TicketStatusFull]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatusFull_State_State_Id] FOREIGN KEY([State_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[TicketStatusFull] CHECK CONSTRAINT [FK_TicketStatusFull_State_State_Id]
GO
ALTER TABLE [helpdesk].[TicketStatusFull]  WITH CHECK ADD  CONSTRAINT [FK_TicketStatusFull_State_StateNext_Id] FOREIGN KEY([StateNext_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[TicketStatusFull] CHECK CONSTRAINT [FK_TicketStatusFull_State_StateNext_Id]
GO
ALTER TABLE [helpdesk].[TicketStatusFull]  WITH CHECK ADD  CONSTRAINT [rTicketStatusFull_TicketStatus] FOREIGN KEY([TicketStatus_Id])
REFERENCES [helpdesk].[TicketStatus] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketStatusFull] CHECK CONSTRAINT [rTicketStatusFull_TicketStatus]
GO
ALTER TABLE [helpdesk].[TicketUser]  WITH CHECK ADD  CONSTRAINT [FK_TicketUser_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [helpdesk].[TicketUser] CHECK CONSTRAINT [FK_TicketUser_Role_Role_Id]
GO
ALTER TABLE [helpdesk].[TicketUser]  WITH CHECK ADD  CONSTRAINT [FK_TicketUser_TicketStatus_TicketStatus_Id] FOREIGN KEY([TicketStatus_Id])
REFERENCES [helpdesk].[TicketStatus] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketUser] CHECK CONSTRAINT [FK_TicketUser_TicketStatus_TicketStatus_Id]
GO
ALTER TABLE [helpdesk].[TicketUser]  WITH CHECK ADD  CONSTRAINT [FK_TicketUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TicketUser] CHECK CONSTRAINT [FK_TicketUser_User_User_Id]
GO
ALTER TABLE [helpdesk].[TmpAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TmpAttachment_File_File_Id] FOREIGN KEY([File_Id])
REFERENCES [dbo].[File] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[TmpAttachment] CHECK CONSTRAINT [FK_TmpAttachment_File_File_Id]
GO
ALTER TABLE [helpdesk].[TmpAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TmpAttachment_Ticket_Ticket_Id] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[TmpAttachment] CHECK CONSTRAINT [FK_TmpAttachment_Ticket_Ticket_Id]
GO
ALTER TABLE [helpdesk].[TmpAttachment]  WITH CHECK ADD  CONSTRAINT [FK_TmpAttachment_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[TmpAttachment] CHECK CONSTRAINT [FK_TmpAttachment_User_User_Id]
GO
ALTER TABLE [helpdesk].[UserDevice]  WITH CHECK ADD  CONSTRAINT [rUserDevice_Device] FOREIGN KEY([Device_Id])
REFERENCES [dbo].[Device] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[UserDevice] CHECK CONSTRAINT [rUserDevice_Device]
GO
ALTER TABLE [helpdesk].[UserDevice]  WITH CHECK ADD  CONSTRAINT [rUserDevice_User] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[UserDevice] CHECK CONSTRAINT [rUserDevice_User]
GO
ALTER TABLE [helpdesk].[UserGroup]  WITH CHECK ADD  CONSTRAINT [FK_UserGroup_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[UserGroup] CHECK CONSTRAINT [FK_UserGroup_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[UserGroupCategory]  WITH CHECK ADD  CONSTRAINT [rUserGroupCategory_Category] FOREIGN KEY([Category_Id])
REFERENCES [helpdesk].[Category] ([Id])
GO
ALTER TABLE [helpdesk].[UserGroupCategory] CHECK CONSTRAINT [rUserGroupCategory_Category]
GO
ALTER TABLE [helpdesk].[UserGroupCategory]  WITH CHECK ADD  CONSTRAINT [rUserGroupCategory_UserGroup] FOREIGN KEY([UserGroup_Id])
REFERENCES [helpdesk].[UserGroup] ([Id])
GO
ALTER TABLE [helpdesk].[UserGroupCategory] CHECK CONSTRAINT [rUserGroupCategory_UserGroup]
GO
ALTER TABLE [helpdesk].[UserGroupMember]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupMember_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [helpdesk].[UserGroupMember] CHECK CONSTRAINT [FK_UserGroupMember_Role_Role_Id]
GO
ALTER TABLE [helpdesk].[UserGroupMember]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupMember_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [helpdesk].[UserGroupMember] CHECK CONSTRAINT [FK_UserGroupMember_User_User_Id]
GO
ALTER TABLE [helpdesk].[UserGroupMember]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupMember_UserGroup_UserGroup_Id] FOREIGN KEY([UserGroup_Id])
REFERENCES [helpdesk].[UserGroup] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[UserGroupMember] CHECK CONSTRAINT [FK_UserGroupMember_UserGroup_UserGroup_Id]
GO
ALTER TABLE [helpdesk].[WatchDog]  WITH CHECK ADD  CONSTRAINT [FK_WatchDog_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [helpdesk].[WatchDog] CHECK CONSTRAINT [FK_WatchDog_Customer_Customer_Id]
GO
ALTER TABLE [helpdesk].[WatchDog]  WITH CHECK ADD  CONSTRAINT [FK_WatchDog_State_State_Id] FOREIGN KEY([State_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[WatchDog] CHECK CONSTRAINT [FK_WatchDog_State_State_Id]
GO
ALTER TABLE [helpdesk].[WatchDog]  WITH CHECK ADD  CONSTRAINT [FK_WatchDog_State_SubState_Id] FOREIGN KEY([SubState_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[WatchDog] CHECK CONSTRAINT [FK_WatchDog_State_SubState_Id]
GO
ALTER TABLE [helpdesk].[WatchDogMail]  WITH CHECK ADD  CONSTRAINT [FK_WatchDogMail_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [helpdesk].[WatchDogMail] CHECK CONSTRAINT [FK_WatchDogMail_Role_Role_Id]
GO
ALTER TABLE [helpdesk].[WatchDogMail]  WITH CHECK ADD  CONSTRAINT [FK_WatchDogMail_UserGroup_UserGroup_Id] FOREIGN KEY([UserGroup_Id])
REFERENCES [helpdesk].[UserGroup] ([Id])
GO
ALTER TABLE [helpdesk].[WatchDogMail] CHECK CONSTRAINT [FK_WatchDogMail_UserGroup_UserGroup_Id]
GO
ALTER TABLE [helpdesk].[WatchDogMail]  WITH CHECK ADD  CONSTRAINT [FK_WatchDogMail_WatchDog_WatchDog_Id] FOREIGN KEY([WatchDog_Id])
REFERENCES [helpdesk].[WatchDog] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[WatchDogMail] CHECK CONSTRAINT [FK_WatchDogMail_WatchDog_WatchDog_Id]
GO
ALTER TABLE [helpdesk].[WatchDogState]  WITH CHECK ADD  CONSTRAINT [FK_WatchDogState_State_StateNew_Id] FOREIGN KEY([StateNew_Id])
REFERENCES [helpdesk].[State] ([Id])
GO
ALTER TABLE [helpdesk].[WatchDogState] CHECK CONSTRAINT [FK_WatchDogState_State_StateNew_Id]
GO
ALTER TABLE [helpdesk].[WatchDogState]  WITH CHECK ADD  CONSTRAINT [FK_WatchDogState_WatchDog_WatchDog_Id] FOREIGN KEY([WatchDog_Id])
REFERENCES [helpdesk].[WatchDog] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[WatchDogState] CHECK CONSTRAINT [FK_WatchDogState_WatchDog_WatchDog_Id]
GO
ALTER TABLE [helpdesk].[WorkDetailTicket]  WITH CHECK ADD  CONSTRAINT [rWorkDetailTicket_Ticket] FOREIGN KEY([Ticket_Id])
REFERENCES [helpdesk].[Ticket] ([Id])
GO
ALTER TABLE [helpdesk].[WorkDetailTicket] CHECK CONSTRAINT [rWorkDetailTicket_Ticket]
GO
ALTER TABLE [helpdesk].[WorkDetailTicket]  WITH CHECK ADD  CONSTRAINT [rWorkDetailTicket_WorkDetail] FOREIGN KEY([WorkDetail_Id])
REFERENCES [hr].[WorkDetail] ([Id])
GO
ALTER TABLE [helpdesk].[WorkDetailTicket] CHECK CONSTRAINT [rWorkDetailTicket_WorkDetail]
GO
ALTER TABLE [helpdesk].[WorkDetailTicketStatus]  WITH CHECK ADD  CONSTRAINT [rWorkDetailTicketStatus_TicketStatus] FOREIGN KEY([TicketStatus_Id])
REFERENCES [helpdesk].[TicketStatus] ([Id])
GO
ALTER TABLE [helpdesk].[WorkDetailTicketStatus] CHECK CONSTRAINT [rWorkDetailTicketStatus_TicketStatus]
GO
ALTER TABLE [helpdesk].[WorkDetailTicketStatus]  WITH CHECK ADD  CONSTRAINT [rWorkDetailTicketStatus_WorkDetail] FOREIGN KEY([WorkDetail_Id])
REFERENCES [hr].[WorkDetail] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [helpdesk].[WorkDetailTicketStatus] CHECK CONSTRAINT [rWorkDetailTicketStatus_WorkDetail]
GO
ALTER TABLE [hr].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_Activity_ActivityTemplate_Id] FOREIGN KEY([ActivityTemplate_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[Activity] CHECK CONSTRAINT [FK_Activity_Activity_ActivityTemplate_Id]
GO
ALTER TABLE [hr].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [hr].[Activity] CHECK CONSTRAINT [FK_Activity_User_User_Id]
GO
ALTER TABLE [hr].[CareOf]  WITH CHECK ADD  CONSTRAINT [rCareOf_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[CareOf] CHECK CONSTRAINT [rCareOf_Activity]
GO
ALTER TABLE [hr].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [hr].[Customer] ([Customer_Id])
GO
ALTER TABLE [hr].[Company] CHECK CONSTRAINT [FK_Company_Customer_Customer_Id]
GO
ALTER TABLE [hr].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [hr].[Customer] CHECK CONSTRAINT [FK_Customer_Customer_Customer_Id]
GO
ALTER TABLE [hr].[Department]  WITH CHECK ADD  CONSTRAINT [FK_Department_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [hr].[Customer] ([Customer_Id])
GO
ALTER TABLE [hr].[Department] CHECK CONSTRAINT [FK_Department_Customer_Customer_Id]
GO
ALTER TABLE [hr].[Doctor]  WITH CHECK ADD  CONSTRAINT [rDoctor_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[Doctor] CHECK CONSTRAINT [rDoctor_Activity]
GO
ALTER TABLE [hr].[Holiday]  WITH CHECK ADD  CONSTRAINT [rHoliday_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[Holiday] CHECK CONSTRAINT [rHoliday_Activity]
GO
ALTER TABLE [hr].[Illness]  WITH CHECK ADD  CONSTRAINT [rIllness_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[Illness] CHECK CONSTRAINT [rIllness_Activity]
GO
ALTER TABLE [hr].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [hr].[Message] CHECK CONSTRAINT [FK_Message_Message_Id]
GO
ALTER TABLE [hr].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [hr].[Message] CHECK CONSTRAINT [FK_Message_User_User_Id]
GO
ALTER TABLE [hr].[Position]  WITH CHECK ADD  CONSTRAINT [FK_Position_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [hr].[Position] CHECK CONSTRAINT [FK_Position_Customer_Customer_Id]
GO
ALTER TABLE [hr].[ProjectDepartment]  WITH CHECK ADD  CONSTRAINT [rProjectDepartment_Department] FOREIGN KEY([Department_Id])
REFERENCES [hr].[Department] ([Id])
GO
ALTER TABLE [hr].[ProjectDepartment] CHECK CONSTRAINT [rProjectDepartment_Department]
GO
ALTER TABLE [hr].[ProjectDepartment]  WITH CHECK ADD  CONSTRAINT [rProjectDepartment_Project] FOREIGN KEY([Project_Id])
REFERENCES [helpdesk].[Project] ([Id])
GO
ALTER TABLE [hr].[ProjectDepartment] CHECK CONSTRAINT [rProjectDepartment_Project]
GO
ALTER TABLE [hr].[SickDay]  WITH CHECK ADD  CONSTRAINT [rSickDay_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[SickDay] CHECK CONSTRAINT [rSickDay_Activity]
GO
ALTER TABLE [hr].[StudyLeave]  WITH CHECK ADD  CONSTRAINT [rStudyLeave_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[StudyLeave] CHECK CONSTRAINT [rStudyLeave_Activity]
GO
ALTER TABLE [hr].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Project_Project_Id] FOREIGN KEY([Project_Id])
REFERENCES [helpdesk].[Project] ([Id])
GO
ALTER TABLE [hr].[Task] CHECK CONSTRAINT [FK_Task_Project_Project_Id]
GO
ALTER TABLE [hr].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [hr].[User] ([User_Id])
GO
ALTER TABLE [hr].[Task] CHECK CONSTRAINT [FK_Task_User_User_Id]
GO
ALTER TABLE [hr].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_WorkType_WorkType_Id] FOREIGN KEY([WorkType_Id])
REFERENCES [hr].[WorkType] ([Id])
GO
ALTER TABLE [hr].[Task] CHECK CONSTRAINT [FK_Task_WorkType_WorkType_Id]
GO
ALTER TABLE [hr].[TimeOff]  WITH CHECK ADD  CONSTRAINT [rTimeOff_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[TimeOff] CHECK CONSTRAINT [rTimeOff_Activity]
GO
ALTER TABLE [hr].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Company_Company_Id] FOREIGN KEY([Company_Id])
REFERENCES [hr].[Company] ([Id])
GO
ALTER TABLE [hr].[User] CHECK CONSTRAINT [FK_User_Company_Company_Id]
GO
ALTER TABLE [hr].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Position_Position_Id] FOREIGN KEY([Position_Id])
REFERENCES [hr].[Position] ([Id])
GO
ALTER TABLE [hr].[User] CHECK CONSTRAINT [FK_User_Position_Position_Id]
GO
ALTER TABLE [hr].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [hr].[User] CHECK CONSTRAINT [FK_User_User_User_Id]
GO
ALTER TABLE [hr].[UserDepartment]  WITH CHECK ADD  CONSTRAINT [rUserDepartment_Department] FOREIGN KEY([Department_Id])
REFERENCES [hr].[Department] ([Id])
GO
ALTER TABLE [hr].[UserDepartment] CHECK CONSTRAINT [rUserDepartment_Department]
GO
ALTER TABLE [hr].[UserDepartment]  WITH CHECK ADD  CONSTRAINT [rUserDepartment_User] FOREIGN KEY([User_Id])
REFERENCES [hr].[User] ([User_Id])
GO
ALTER TABLE [hr].[UserDepartment] CHECK CONSTRAINT [rUserDepartment_User]
GO
ALTER TABLE [hr].[UserTask]  WITH CHECK ADD  CONSTRAINT [rUserTask_Task] FOREIGN KEY([Task_Id])
REFERENCES [hr].[Task] ([Id])
GO
ALTER TABLE [hr].[UserTask] CHECK CONSTRAINT [rUserTask_Task]
GO
ALTER TABLE [hr].[UserTask]  WITH CHECK ADD  CONSTRAINT [rUserTask_User] FOREIGN KEY([User_Id])
REFERENCES [hr].[User] ([User_Id])
GO
ALTER TABLE [hr].[UserTask] CHECK CONSTRAINT [rUserTask_User]
GO
ALTER TABLE [hr].[Work]  WITH CHECK ADD  CONSTRAINT [FK_Work_Department_Department_Id] FOREIGN KEY([Department_Id])
REFERENCES [hr].[Department] ([Id])
GO
ALTER TABLE [hr].[Work] CHECK CONSTRAINT [FK_Work_Department_Department_Id]
GO
ALTER TABLE [hr].[Work]  WITH CHECK ADD  CONSTRAINT [rWork_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [hr].[Work] CHECK CONSTRAINT [rWork_Activity]
GO
ALTER TABLE [hr].[WorkDetail]  WITH CHECK ADD  CONSTRAINT [FK_WorkDetail_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [helpdesk].[Customer] ([Customer_Id])
GO
ALTER TABLE [hr].[WorkDetail] CHECK CONSTRAINT [FK_WorkDetail_Customer_Customer_Id]
GO
ALTER TABLE [hr].[WorkDetail]  WITH CHECK ADD  CONSTRAINT [FK_WorkDetail_Project_Project_Id] FOREIGN KEY([Project_Id])
REFERENCES [helpdesk].[Project] ([Id])
GO
ALTER TABLE [hr].[WorkDetail] CHECK CONSTRAINT [FK_WorkDetail_Project_Project_Id]
GO
ALTER TABLE [hr].[WorkDetail]  WITH CHECK ADD  CONSTRAINT [FK_WorkDetail_Task_Task_Id] FOREIGN KEY([Task_Id])
REFERENCES [hr].[Task] ([Id])
GO
ALTER TABLE [hr].[WorkDetail] CHECK CONSTRAINT [FK_WorkDetail_Task_Task_Id]
GO
ALTER TABLE [hr].[WorkDetail]  WITH CHECK ADD  CONSTRAINT [FK_WorkDetail_Work_Work_Id] FOREIGN KEY([Work_Id])
REFERENCES [hr].[Work] ([Activity_Id])
ON DELETE CASCADE
GO
ALTER TABLE [hr].[WorkDetail] CHECK CONSTRAINT [FK_WorkDetail_Work_Work_Id]
GO
ALTER TABLE [hr].[WorkDetail]  WITH CHECK ADD  CONSTRAINT [FK_WorkDetail_WorkType_WorkType_Id] FOREIGN KEY([WorkType_Id])
REFERENCES [hr].[WorkType] ([Id])
GO
ALTER TABLE [hr].[WorkDetail] CHECK CONSTRAINT [FK_WorkDetail_WorkType_WorkType_Id]
GO
ALTER TABLE [hr].[WorkShop]  WITH CHECK ADD  CONSTRAINT [rWorkShop_Activity] FOREIGN KEY([Activity_Id])
REFERENCES [hr].[Activity] ([Id])
GO
ALTER TABLE [hr].[WorkShop] CHECK CONSTRAINT [rWorkShop_Activity]
GO
ALTER TABLE [hr].[WorkStart]  WITH CHECK ADD  CONSTRAINT [FK_WorkStart_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [hr].[WorkStart] CHECK CONSTRAINT [FK_WorkStart_User_User_Id]
GO
ALTER TABLE [hr].[WorkType]  WITH CHECK ADD  CONSTRAINT [FK_WorkType_Department_Department_Id] FOREIGN KEY([Department_Id])
REFERENCES [hr].[Department] ([Id])
GO
ALTER TABLE [hr].[WorkType] CHECK CONSTRAINT [FK_WorkType_Department_Department_Id]
GO
ALTER TABLE [hr].[WorkType]  WITH CHECK ADD  CONSTRAINT [FK_WorkType_WorkType_WorkType_Id] FOREIGN KEY([WorkType_Id])
REFERENCES [hr].[WorkType] ([Id])
GO
ALTER TABLE [hr].[WorkType] CHECK CONSTRAINT [FK_WorkType_WorkType_WorkType_Id]
GO
ALTER TABLE [report].[DataSource]  WITH CHECK ADD  CONSTRAINT [FK_DataSource_ReportView_ReportView_Id] FOREIGN KEY([ReportView_Id])
REFERENCES [report].[ReportView] ([Id])
GO
ALTER TABLE [report].[DataSource] CHECK CONSTRAINT [FK_DataSource_ReportView_ReportView_Id]
GO
ALTER TABLE [report].[EntityDataSource]  WITH CHECK ADD  CONSTRAINT [refEntityDataSource_DataSource] FOREIGN KEY([id])
REFERENCES [report].[DataSource] ([Id])
GO
ALTER TABLE [report].[EntityDataSource] CHECK CONSTRAINT [refEntityDataSource_DataSource]
GO
ALTER TABLE [report].[Output]  WITH CHECK ADD  CONSTRAINT [FK_Output_Report_Report_Id] FOREIGN KEY([Report_Id])
REFERENCES [report].[Report] ([Id])
GO
ALTER TABLE [report].[Output] CHECK CONSTRAINT [FK_Output_Report_Report_Id]
GO
ALTER TABLE [report].[ReportRole]  WITH CHECK ADD  CONSTRAINT [refReportRole_Report] FOREIGN KEY([Report_Id])
REFERENCES [report].[Report] ([Id])
GO
ALTER TABLE [report].[ReportRole] CHECK CONSTRAINT [refReportRole_Report]
GO
ALTER TABLE [report].[ReportRole]  WITH CHECK ADD  CONSTRAINT [refReportRole_Role] FOREIGN KEY([Role_Id])
REFERENCES [helpdesk].[Role] ([Id])
GO
ALTER TABLE [report].[ReportRole] CHECK CONSTRAINT [refReportRole_Role]
GO
ALTER TABLE [report].[ReportView]  WITH CHECK ADD  CONSTRAINT [FK_ReportView_Report_Report_Id] FOREIGN KEY([Report_Id])
REFERENCES [report].[Report] ([Id])
GO
ALTER TABLE [report].[ReportView] CHECK CONSTRAINT [FK_ReportView_Report_Report_Id]
GO
ALTER TABLE [report].[ReportView]  WITH CHECK ADD  CONSTRAINT [FK_ReportView_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [report].[ReportView] CHECK CONSTRAINT [FK_ReportView_User_User_Id]
GO
ALTER TABLE [report].[SqlDataSource]  WITH CHECK ADD  CONSTRAINT [refSqlDataSource_DataSource] FOREIGN KEY([DataSource_Id])
REFERENCES [report].[DataSource] ([Id])
GO
ALTER TABLE [report].[SqlDataSource] CHECK CONSTRAINT [refSqlDataSource_DataSource]
GO
ALTER TABLE [report].[SubReport]  WITH CHECK ADD  CONSTRAINT [FK_SubReport_Report_Report_Id] FOREIGN KEY([Report_Id])
REFERENCES [report].[Report] ([Id])
GO
ALTER TABLE [report].[SubReport] CHECK CONSTRAINT [FK_SubReport_Report_Report_Id]
GO
ALTER TABLE [wf].[ApproveUser]  WITH CHECK ADD  CONSTRAINT [FK_ApproveUser_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [wf].[ApproveUser] CHECK CONSTRAINT [FK_ApproveUser_User_User_Id]
GO
ALTER TABLE [wf].[ApproveUser]  WITH CHECK ADD  CONSTRAINT [FK_ApproveUser_Workflow_Workflow_Id] FOREIGN KEY([Workflow_Id])
REFERENCES [wf].[Workflow] ([Id])
GO
ALTER TABLE [wf].[ApproveUser] CHECK CONSTRAINT [FK_ApproveUser_Workflow_Workflow_Id]
GO
ALTER TABLE [wf].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Message_Id] FOREIGN KEY([Message_Id])
REFERENCES [dbo].[Message] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [wf].[Message] CHECK CONSTRAINT [FK_Message_Message_Id]
GO
ALTER TABLE [wf].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Request_Request_Id] FOREIGN KEY([Request_Id])
REFERENCES [wf].[Request] ([Id])
GO
ALTER TABLE [wf].[Message] CHECK CONSTRAINT [FK_Message_Request_Request_Id]
GO
ALTER TABLE [wf].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Role_Role_Id] FOREIGN KEY([Role_Id])
REFERENCES [wf].[Role] ([Id])
GO
ALTER TABLE [wf].[Message] CHECK CONSTRAINT [FK_Message_Role_Role_Id]
GO
ALTER TABLE [wf].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_Task_Task_Id] FOREIGN KEY([Task_Id])
REFERENCES [wf].[Task] ([Id])
GO
ALTER TABLE [wf].[Message] CHECK CONSTRAINT [FK_Message_Task_Task_Id]
GO
ALTER TABLE [wf].[Message]  WITH CHECK ADD  CONSTRAINT [FK_Message_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [wf].[Message] CHECK CONSTRAINT [FK_Message_User_User_Id]
GO
ALTER TABLE [wf].[Request]  WITH CHECK ADD  CONSTRAINT [FK_Request_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [wf].[Request] CHECK CONSTRAINT [FK_Request_User_User_Id]
GO
ALTER TABLE [wf].[Request]  WITH CHECK ADD  CONSTRAINT [FK_Request_Workflow_Workflow_Id] FOREIGN KEY([Workflow_Id])
REFERENCES [wf].[Workflow] ([Id])
GO
ALTER TABLE [wf].[Request] CHECK CONSTRAINT [FK_Request_Workflow_Workflow_Id]
GO
ALTER TABLE [wf].[RequestDevice]  WITH CHECK ADD  CONSTRAINT [FK_RequestDevice_DeviceKind_DeviceKind_Id] FOREIGN KEY([DeviceKind_Id])
REFERENCES [dbo].[DeviceKind] ([Id])
GO
ALTER TABLE [wf].[RequestDevice] CHECK CONSTRAINT [FK_RequestDevice_DeviceKind_DeviceKind_Id]
GO
ALTER TABLE [wf].[RequestDevice]  WITH CHECK ADD  CONSTRAINT [FK_RequestDevice_DeviceType_DeviceType_Id] FOREIGN KEY([DeviceType_Id])
REFERENCES [dbo].[DeviceType] ([Id])
GO
ALTER TABLE [wf].[RequestDevice] CHECK CONSTRAINT [FK_RequestDevice_DeviceType_DeviceType_Id]
GO
ALTER TABLE [wf].[RequestDevice]  WITH CHECK ADD  CONSTRAINT [FK_RequestDevice_Request_Request_Id] FOREIGN KEY([Request_Id])
REFERENCES [wf].[Request] ([Id])
GO
ALTER TABLE [wf].[RequestDevice] CHECK CONSTRAINT [FK_RequestDevice_Request_Request_Id]
GO
ALTER TABLE [wf].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Request_Request_Id] FOREIGN KEY([Request_Id])
REFERENCES [wf].[Request] ([Id])
GO
ALTER TABLE [wf].[Task] CHECK CONSTRAINT [FK_Task_Request_Request_Id]
GO
ALTER TABLE [wf].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [wf].[Task] CHECK CONSTRAINT [FK_Task_User_User_Id]
GO
ALTER TABLE [wf].[Workflow]  WITH CHECK ADD  CONSTRAINT [FK_Workflow_Customer_Customer_Id] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [wf].[Workflow] CHECK CONSTRAINT [FK_Workflow_Customer_Customer_Id]
GO
ALTER TABLE [wf].[Workflow]  WITH CHECK ADD  CONSTRAINT [FK_Workflow_User_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [wf].[Workflow] CHECK CONSTRAINT [FK_Workflow_User_User_Id]
GO
ALTER TABLE [wf].[WorkflowUser]  WITH CHECK ADD  CONSTRAINT [rWorkflowUser_User] FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [wf].[WorkflowUser] CHECK CONSTRAINT [rWorkflowUser_User]
GO
ALTER TABLE [wf].[WorkflowUser]  WITH CHECK ADD  CONSTRAINT [rWorkflowUser_Workflow] FOREIGN KEY([Workflow_Id])
REFERENCES [wf].[Workflow] ([Id])
GO
ALTER TABLE [wf].[WorkflowUser] CHECK CONSTRAINT [rWorkflowUser_Workflow]
GO
/****** Object:  StoredProcedure [crm].[procDeleteTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [crm].[procDeleteTicket]
  @ticketId int,
  @loggedUserId int = NULL
AS 
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRAN
  --nastavim prvni a posledni na NULL
    UPDATE crm.Ticket 
      SET StatusTicketFirst_id = NULL, StatusTicketLast_id = NULL
    WHERE id = @ticketId

    --odeslane zpravy
    DELETE m
      FROM dbo.[Message] m
      INNER JOIN crm.[Message] hdm ON m.Id = hdm.Message_id
    WHERE hdm.Ticket_id = @ticketId

    --prilohy
    DELETE f
    FROM dbo.[File] f
      INNER JOIN crm.TicketAttachment ta ON f.Id = ta.[File_id]
    WHERE ta.Ticket_id = @ticketId

    --stavy
    DELETE 
    FROM crm.TicketStatus
    WHERE Ticket_id = @ticketId

    --ticket
    DELETE 
    FROM crm.Ticket
    WHERE Id = @ticketId

    if (@loggedUserId IS NOT NULL)
    BEGIN
      INSERT INTO crm.DeletedTicket(Ticket_id, [User_id], DeleteTime)
      VALUES (@ticketId, @loggedUserId, GETDATE())
    END
    


  COMMIT
END

GO
/****** Object:  StoredProcedure [dbo].[procClearTables]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procClearTables]
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRAN

  --text orig. textu
  UPDATE helpdesk.TicketStatus SET ResponseOriginal = ''
  WHERE ChangeDateSys < DATEADD(MONTH, -3, GETDATE()) AND DATALENGTH(ResponseOriginal) > 0

  --zpracovane prijate maily, starsi 3mesicu - vynuluju ten prijaty email
  UPDATE mt 
    SET mt.Mail = NULL
  FROM helpdesk.MailTicket mt
    INNER JOIN helpdesk.Ticket t ON mt.Ticket_id = t.Id
    INNER JOIN helpdesk.TicketStatus ts ON t.StatusTicketFirst_id = ts.Id AND ts.ChangeDateSys < DATEADD(MONTH, -3, GETDATE())
  WHERE DATALENGTH(mt.Mail) > 0

  --NEzpracovane prijate maily, starsi 12mesicu - vynuluju ten prijaty email
  UPDATE mt 
    SET mt.Mail = NULL
  FROM helpdesk.MailTicket mt
  WHERE Ticket_id IS NULL AND Date < DATEADD(MONTH, -12, GETDATE()) AND DATALENGTH(mt.Mail) > 0

  --odeslane vyrazene, starsi 3mesicu mazu
  DELETE m
  FROM helpdesk.[Message] hdM
    INNER JOIN dbo.[Message] m ON hdM.Message_id = m.Id AND m.[Date] < DATEADD(MONTH, -3, GETDATE())
  WHERE hdM.IsExclude = 1

  --odeslane nevyrazene, starsi 3mesicu vynuluju text
  UPDATE m
    SET m.TextMessage = ''
  FROM helpdesk.[Message] hdM
    INNER JOIN dbo.[Message] m ON hdM.Message_id = m.Id AND m.[Date] < DATEADD(MONTH, -3, GETDATE())
  WHERE hdM.IsExclude = 0 AND DATALENGTH(m.TextMessage) > 0

  UPDATE mailM
    SET mailM.AlternateText = ''
  FROM helpdesk.[Message] hdM
    INNER JOIN dbo.[Message] m ON hdM.Message_id = m.Id AND m.[Date] < DATEADD(MONTH, -3, GETDATE())
    INNER JOIN dbo.MailMessage mailM ON m.Id = mailM.Message_id
  WHERE hdM.IsExclude = 0 AND DATALENGTH(mailM.AlternateText) > 0

  --CRM
  --odeslane vyrazene, starsi 3mesicu mazu
  DELETE m
  FROM crm.[Message] crmM
    INNER JOIN dbo.[Message] m ON crmM.Message_id = m.Id AND m.[Date] < DATEADD(MONTH, -3, GETDATE())
  WHERE crmM.IsExclude = 1

  --odeslane nevyrazene, starsi 3mesicu vynuluju text
  UPDATE m
    SET m.TextMessage = ''
  FROM crm.[Message] crmM
    INNER JOIN dbo.[Message] m ON crmM.Message_id = m.Id AND m.[Date] < DATEADD(MONTH, -3, GETDATE())
  WHERE crmM.IsExclude = 0 AND DATALENGTH(m.TextMessage) > 0

  UPDATE mailM
    SET mailM.AlternateText = ''
  FROM crm.[Message] crmM
    INNER JOIN dbo.[Message] m ON crmM.Message_id = m.Id AND m.[Date] < DATEADD(MONTH, -3, GETDATE())
    INNER JOIN dbo.MailMessage mailM ON m.Id = mailM.Message_id
  WHERE crmM.IsExclude = 0 AND DATALENGTH(mailM.AlternateText) > 0

  COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateDeviceFromTpl]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateDeviceFromTpl]
  @tplId int,
  @cusId int,
  @newDeviceId INT OUT
AS
BEGIN

  INSERT INTO dbo.Device(Device_id, Customer_id, DeviceType_id, DeviceTpl_id, Name, IsGroup, IsActive, Note, SerialNumber, Room, Building, InventaryNumber, HasDeviceBook)
  SELECT d.id, @cusId, d.DeviceType_id, tpl.Id, tpl.Name, 0, 1, '', '', '', '', '', ''
  FROM dbo.Device d
    FULL JOIN dbo.Device tpl ON tpl.Id = @tplId
  WHERE d.Customer_id = @cusId AND d.Device_id IS NULL

  SET @newDeviceId = SCOPE_IDENTITY()
  --zkopirovat dily
  INSERT INTO dbo.DevicePart(Device_id, DevicePartTpl_id, IsActive, Name)
  SELECT @newDeviceId, Id, 1, Name
  FROM dbo.DevicePart
  WHERE Device_id = @tplId

END
GO
/****** Object:  StoredProcedure [dbo].[procDeleteCustomer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procDeleteCustomer]
  @id int,
  @delTickets bit,
  @loggedUserId int = NULL
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRAN
    IF (@delTickets = 1)
    BEGIN
      --pozadavky v HD
      DECLARE @cur CURSOR
  
      SET @cur = CURSOR FOR
        SELECT t.id
        FROM helpdesk.Ticket t
        WHERE Customer_id = @id

      OPEN @cur
      DECLARE 
        @ticketId int

      FETCH NEXT FROM @cur INTO @ticketId
      WHILE @@FETCH_STATUS = 0
      BEGIN
        EXEC helpdesk.procDeleteTicket @ticketId = @ticketId, @loggedUserId = @loggedUserId

        FETCH NEXT FROM @cur INTO @ticketId
      END

      CLOSE @cur;
      DEALLOCATE @cur;
    END
   
    --muze se stat, ze ma uzivatele, kteri maji nekde jinde pozadavek...
    UPDATE u SET Customer_Id = t.Customer_Id, User_Id = uRoot.Id
    FROM dbo.[User] u
      INNER JOIN helpdesk.Ticket t ON u.Id = t.User_Id
      INNER JOIN dbo.[User] uRoot ON uRoot.Customer_Id = t.Customer_Id AND uRoot.User_Id IS NULL
    WHERE u.Customer_Id = @id;

    UPDATE u SET Customer_Id = t.Customer_Id, User_Id = uRoot.Id
    FROM dbo.[User] u
      INNER JOIN helpdesk.MailTicket mt ON u.Id = mt.[User_Id]
      INNER JOIN helpdesk.Ticket t ON mt.Ticket_Id = t.Id
      INNER JOIN dbo.[User] uRoot ON uRoot.Customer_Id = t.Customer_Id AND uRoot.User_Id IS NULL
    WHERE u.Customer_Id = @id;

    UPDATE u SET Customer_Id = t.Customer_Id, User_Id = uRoot.Id
    FROM dbo.[User] u
      INNER JOIN helpdesk.[Message] m ON u.Id = m.[User_Id]
      INNER JOIN helpdesk.Ticket t ON m.Ticket_Id = t.Id
      INNER JOIN dbo.[User] uRoot ON uRoot.Customer_Id = t.Customer_Id AND uRoot.User_Id IS NULL
    WHERE u.Customer_Id = @id;

    --tedka jsem mozná rozbil strom nadrizenosti, tak je vsechny prendam pod root
    UPDATE u SET User_Id = uRoot.Id
    FROM dbo.[User] u
      INNER JOIN dbo.[User] uRoot ON uRoot.Customer_Id = u.Customer_Id AND uRoot.User_Id IS NULL
    WHERE u.Customer_Id = @id AND u.User_Id IS NOT NULL;
  
    DELETE 
    FROM dbo.UserRole 
    WHERE Customer_id = @id;

    DELETE 
    FROM helpdesk.CustomerUser 
    WHERE Customer_id = @id;

    --skupiny uzivatelu
    DELETE 
    FROM helpdesk.UserGroup
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.Project
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.CustomerClassification
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.CustomerCategory
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.DefaultResponse
    WHERE Customer_id = @id

    DELETE 
    FROM dbo.CustomerBoard
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.DeviceBook
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.Routine
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.Settings
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.WatchDog
    WHERE Customer_id = @id

    DELETE 
    FROM helpdesk.CustomerCustomField
    WHERE Customer_id = @id

    --prilohy
    DELETE f
    FROM dbo.[File] f
      INNER JOIN helpdesk.Attachment a ON f.Id = a.[File_id]
      INNER JOIN helpdesk.ServiceList s ON a.ServiceList_id = s.Id
    WHERE s.Customer_id = @ticketId

    DELETE 
    FROM helpdesk.ServiceList
    WHERE Customer_id = @id

    DELETE 
    FROM dbo.CustomerDomain
    WHERE Customer_id = @id;
    
    --zarizeni ze stromu - podle levelu
    WITH deviceTree(DeviceId, HierarchyLevel)
    AS
    (
      SELECT d.Id, 1 as HierarchyLevel
      FROM Device d
      WHERE d.Customer_id = @id  AND d.Device_id IS NULL
      UNION ALL
      SELECT d.Id, t.HierarchyLevel + 1 AS HierarchyLevel
      FROM Device d
        INNER JOIN deviceTree t ON t.DeviceId = d.Device_id
    )
    DELETE d
    FROM Device d
    WHERE d.Id IN ( SELECT TOP 100000 t.DeviceId
                    FROM deviceTree t
                    ORDER BY t.HierarchyLevel DESC)

    
    UPDATE helpdesk.MailTicket
      SET User_id = NULL
    WHERE User_id IN (SELECT id FROM dbo.[User] WHERE Customer_id = @id)
    
    DELETE ar
    FROM dbo.ActivityReport ar
      INNER JOIN dbo.LoginReport lr ON ar.LoginReport_id = lr.Id
      INNER JOIN dbo.[User] u ON lr.User_id = u.Id
    WHERE u.Customer_id = @id

    DELETE lr
    FROM dbo.LoginReport lr
      INNER JOIN dbo.[User] u ON lr.User_id = u.Id
    WHERE u.Customer_id = @id;

    --uzivatele ze stromu - podle levelu
    WITH userTree(UserId, HierarchyLevel)
    AS
    (
      SELECT u.Id, 1 as HierarchyLevel
      FROM [User] u
      WHERE u.Customer_id = @id  AND u.[User_id] IS NULL
      UNION ALL
      SELECT u.Id, t.HierarchyLevel + 1 AS HierarchyLevel
      FROM [User] u
        INNER JOIN userTree t ON t.UserId = u.[User_id]
    )
    DELETE u
    FROM dbo.[User] u
    WHERE u.Id IN ( SELECT TOP 100000 t.UserId
                    FROM userTree t
                    ORDER BY t.HierarchyLevel DESC)

    --prilohy
    DELETE f
    FROM dbo.[File] f
      INNER JOIN helpdesk.Attachment a ON f.Id = a.[File_id]
    WHERE a.Customer_id = @ticketId

    DELETE 
    FROM crm.Customer
    WHERE Customer_Id = @id

    DELETE 
    FROM helpdesk.Customer
    WHERE Customer_Id = @id

    DELETE 
    FROM dbo.Customer
    WHERE Id = @id
  COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[procGenFreeDays]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procGenFreeDays] 
  @year int
AS
BEGIN

  DECLARE
    @fromDate date = DATEFROMPARTS(@year, 1, 1),
    @toDate date = EOMONTH(DATEFROMPARTS(@year, 12, 1))

  DECLARE @Dates TABLE 
  (
    dt date
  );

  --máme v DB jen ty volné dny, nikoliv víkendy
  --INSERT INTO @Dates ([dt])
  --SELECT f.[Day] 
  --FROM [dbo].[fceSelectDays] (@fromDate, @toDate, 0) f
  --WHERE f.IsWorkDay = 0

  --ostatni svatky (DD.MM.RRRR): 
  --novy rok 
  INSERT INTO @Dates(dt) VALUES(@fromDate) 
  --svatek prace 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 5, 1)) 
  --Den vitezstvi 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 5, 8)) 
  --Cyril a Metodej 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 7, 5)) 
  --Jan Hus 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 7, 6)) 
  --sv.Vaclav 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 9, 28)) 
  --den statnosti 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 10, 28)) 
  --den boje za svobodu 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 11, 17)) 
  --vanoce 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 12, 24)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 12, 25)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(@year, 12, 26)) 


  PRINT 'Velikonoce!' 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2026, 4, 3)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2026, 4, 6)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2027, 3, 26)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2027, 3, 29)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2028, 4, 10)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2028, 4, 17)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2029, 3, 31)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2029, 4, 2)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2030, 4, 19)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2030, 4, 22)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2031, 4, 11)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2031, 4, 14)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2032, 3, 26)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2032, 3, 29)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2033, 4, 15)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2033, 4, 18)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2035, 3, 23)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2035, 3, 26)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2036, 4, 11)) 
  INSERT INTO @Dates(dt) VALUES(DATEFROMPARTS(2036, 4, 14)) 

  INSERT INTO dbo.FreeDay ([Day])
  SELECT DISTINCT d.[dt] 
  FROM @Dates d
    LEFT JOIN dbo.FreeDay fd ON d.[dt] = fd.[Day]
  WHERE fd.[Day] IS NULL

END
GO
/****** Object:  StoredProcedure [dbo].[procImportUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[procImportUser]
  @firstName varchar(50),
  @lastName varchar(150),
  @email varchar(50),
  @customerId int
AS
BEGIN
  DECLARE
    @rootUser int,
    @id int

  SELECT @id = id FROM dbo.[User] WHERE Email = @email
  IF (@id IS NULL)
  BEGIN
    SELECT @rootUser = id FROM dbo.[User] WHERE Customer_id = @customerId AND User_id IS NULL

    INSERT INTO dbo.[User] (User_id, Customer_id, FirstName, LastName, [Login], Email, [Password], IsGroup, Room, Building, Note, IsActive, IsRoot, Phone, Mobil, IsImported)
    VALUES (@rootUser, @customerId, @firstName, @lastName, @email, @email, NEWID(), 0, '', '', '', 1, 0, '', '', 0)

    SET @id = SCOPE_IDENTITY()

    INSERT INTO dbo.[UserSettings] (User_id, Theme, DefaultCustomer, [Language])
    VALUES (@id, 'rainbow', NULL, 'cs-CZ')

  END
  ELSE
    UPDATE dbo.[User] 
      SET FirstName = @firstName, LastName = @lastName
    WHERE Id = @id
END
GO
/****** Object:  StoredProcedure [dbo].[procInsertDevicePartTpl]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[procInsertDevicePartTpl]
  @deviceTplId int,
  @id int,
  @name varchar(300)
AS
BEGIN

  INSERT INTO dbo.DevicePart(Device_id, DevicePartTpl_id, IsActive, Name)
  SELECT d.Id, @id, 1, @name 
  FROM Device d
  WHERE d.DeviceTpl_id = @deviceTplId
END
GO
/****** Object:  StoredProcedure [dbo].[procMergeUsers]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procMergeUsers]
  @oldId int,
  @newId int
AS
BEGIN

  BEGIN TRAN

    UPDATE hr.[Activity] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE dbo.[Board] SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM crm.CategoryUser o
      INNER JOIN crm.CategoryUser n ON o.Category_id = n.Category_id AND o.Role_id = n.Role_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE crm.CategoryUser  SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [helpdesk].[CustomerUser] o
      INNER JOIN [helpdesk].[CustomerUser] n ON o.Customer_id = n.Customer_id
        AND o.Role_id = n.Role_id AND o.Project_id = n.Project_id
        AND o.Category_id = n.Category_id AND o.DeviceKey_id = n.DeviceKey_id
        AND o.UserKey_id = n.UserKey_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [helpdesk].[CustomerUser] SET [User_id] = @newId WHERE [User_id] = @oldId
    
    UPDATE [helpdesk].[DefaultResponse] SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [helpdesk].[DefaultTicketUser] o
      INNER JOIN [helpdesk].[DefaultTicketUser] n ON o.UserSelect_id = n.UserSelect_id
        AND o.Role_id = n.Role_id 
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [helpdesk].[DefaultTicketUser] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE frm.FormInstance SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [acc].[HourlyRateUser] o
      INNER JOIN [acc].[HourlyRateUser] n ON o.HourlyRate_id = n.HourlyRate_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [acc].[HourlyRateUser] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE dbo.[LoginReport] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE helpdesk.MailTicket SET [User_id] = @newId WHERE [User_id] = @oldId
    
    UPDATE crm.[Message] SET [User_id] = @newId WHERE [User_id] = @oldId
    
    UPDATE helpdesk.[Message] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE hr.[Message] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE dbo.OutOfOffice SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE [helpdesk].[Ranking] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE [report].[ReportView] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE [helpdesk].[Routine] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE [helpdesk].ServiceList SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE crm.[Session] SET [UserCreate_id] = @newId WHERE [UserCreate_id] = @oldId
    UPDATE crm.[Session] SET [UserRequest_id] = @newId WHERE [UserRequest_id] = @oldId

    UPDATE crm.[Session] SET [UserCreate_id] = @newId WHERE [UserCreate_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [crm].[SessionContactUser] o
      INNER JOIN [crm].[SessionContactUser] n ON o.SessionContact_id = n.SessionContact_id
        AND o.Role_id = n.Role_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [crm].[SessionContactUser] SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [helpdesk].[Settings] o
      INNER JOIN [helpdesk].[Settings] n ON o.Customer_id = n.Customer_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [helpdesk].[Settings] SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [frm].[TaskGroupUser] o
      INNER JOIN [frm].[TaskGroupUser] n ON o.TaskGroup_id = n.TaskGroup_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [frm].[TaskGroupUser] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE helpdesk.[Ticket] SET [User_id] = @newId WHERE [User_id] = @oldId
    UPDATE crm.[Ticket] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE helpdesk.[TicketStatus] SET [User_id] = @newId WHERE [User_id] = @oldId
    UPDATE crm.[TicketStatus] SET [User_id] = @newId WHERE [User_id] = @oldId
  
    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [crm].[TicketUser] o
      INNER JOIN [crm].[TicketUser] n ON o.TicketStatus_id = n.TicketStatus_id
        AND o.Role_id = n.Role_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [crm].[TicketUser] SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM helpdesk.[TicketUser] o
      INNER JOIN helpdesk.[TicketUser] n ON o.TicketStatus_id = n.TicketStatus_id
        AND o.Role_id = n.Role_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE helpdesk.[TicketUser] SET [User_id] = @newId WHERE [User_id] = @oldId

    UPDATE helpdesk.TmpAttachment SET [User_id] = @newId WHERE [User_id] = @oldId

    --strom
    UPDATE o SET User_id = @newId FROM dbo.[User] o WHERE User_id = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [dbo].[UserAssociation] o
      INNER JOIN [dbo].[UserAssociation] n ON o.UserSenior_id = n.UserSenior_id
    WHERE o.UserJunior_id = @oldId AND n.UserJunior_id = @newId
    UPDATE [dbo].[UserAssociation] SET UserJunior_id = @newId WHERE UserJunior_id = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [dbo].[UserAssociation] o
      INNER JOIN [dbo].[UserAssociation] n ON o.UserJunior_id = n.UserJunior_id
    WHERE o.UserSenior_id = @oldId AND n.UserSenior_id = @newId
    UPDATE [dbo].[UserAssociation] SET UserSenior_id = @newId WHERE UserSenior_id = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [helpdesk].[UserDevice] o
      INNER JOIN [helpdesk].[UserDevice] n ON o.Device_id = n.Device_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [helpdesk].[UserDevice] SET User_id = @newId WHERE User_id = @oldId
    
    UPDATE [dbo].[UserFilter] SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [helpdesk].[UserGroupMember] o
      INNER JOIN [helpdesk].[UserGroupMember] n ON o.UserGroup_id = n.UserGroup_id
        AND o.Role_id = n.Role_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [helpdesk].[UserGroupMember] SET User_id = @newId WHERE User_id = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [dbo].[UserRole] o
      INNER JOIN [dbo].[UserRole] n ON o.Customer_id = n.Customer_id
        AND o.Role_id = n.Role_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [dbo].[UserRole] SET User_id = @newId WHERE User_id = @oldId

    UPDATE [wf].[Workflow] SET [User_id] = @newId WHERE [User_id] = @oldId
    
    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [wf].[WorkflowUser] o
      INNER JOIN [wf].[WorkflowUser] n ON o.Workflow_id = n.Workflow_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [wf].[WorkflowUser] SET User_id = @newId WHERE User_id = @oldId

    UPDATE [hr].[Task] SET [User_id] = @newId WHERE [User_id] = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [hr].[UserTask] o
      INNER JOIN [hr].[UserTask] n ON o.Task_id = n.Task_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [hr].[UserTask] SET User_id = @newId WHERE User_id = @oldId

    --M:N ty, které už tam jsou smažu
    DELETE o
    FROM [hr].[UserDepartment] o
      INNER JOIN [hr].[UserDepartment] n ON o.Department_id = n.Department_id
    WHERE o.User_id = @oldId AND n.User_id = @newId
    UPDATE [hr].[UserDepartment] SET User_id = @newId WHERE User_id = @oldId

    DELETE FROM dbo.[User] WHERE id = @oldId

  COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[procMoveCustomer]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procMoveCustomer]
  @sourceId int,
  @targetId int,
  @ticket bit,
  @devBook bit,
  @routine bit,
  @serList bit,
  @domain bit,
  @device bit,
  @user bit,
  @department bit,
  @forms bit
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON
  BEGIN TRAN
    IF (@ticket = 1)
    BEGIN
      UPDATE helpdesk.Ticket
        SET Customer_id = @targetId
      WHERE Customer_id = @sourceId
      UPDATE ts SET
        ts.User_id = (SELECT id FROM dbo.[User] uu WHERE uu.Customer_id = @targetId AND uu.User_id IS NULL)
      FROM helpdesk.TicketStatus ts
        INNER JOIN helpdesk.Ticket t ON ts.Ticket_id = t.id
        INNER JOIN dbo.[User] u ON ts.User_id = u.id AND u.User_id IS NULL AND u.Customer_id != @targetId
      AND t.Customer_id = @targetId
      UPDATE ta
        SET ta.Customer_id = @targetId
      FROM helpdesk.TicketAttachment ta
      WHERE ta.Customer_id = @sourceId
    END;
    IF (@devBook = 1)
    BEGIN
      UPDATE helpdesk.DeviceBook
        SET Customer_id = @targetId
      WHERE Customer_id = @sourceId
    END;
    IF (@routine = 1)
    BEGIN
      UPDATE helpdesk.Routine
        SET Customer_id = @targetId
      WHERE Customer_id = @sourceId
    END;
    IF (@serList = 1)
    BEGIN
      UPDATE helpdesk.ServiceList
        SET Customer_id = @targetId
      WHERE Customer_id = @sourceId
    END;
    IF (@domain = 1)
    BEGIN
      UPDATE dbo.CustomerDomain
        SET Customer_id = @targetId
      WHERE Customer_id = @sourceId
    END;
    IF (@device = 1)
    BEGIN
      UPDATE d
        SET d.Customer_id = @targetId, d.Device_id =  CASE
                                                        WHEN d.Device_id = OldParent.id THEN newParent.id
                                                        ELSE d.Device_id
                                                      END
      FROM dbo.Device d
        CROSS JOIN (SELECT new.id
                    FROM dbo.Device new
                    WHERE new.Customer_id = @targetId AND new.Device_id IS NULL) newParent
        CROSS JOIN (SELECT old.id
                    FROM dbo.Device old
                    WHERE old.Customer_id = @sourceId AND old.Device_id IS NULL) OldParent
      WHERE d.Customer_id = @sourceId AND d.Device_id IS NOT NULL
    END;
    IF (@user = 1)
    BEGIN
      UPDATE u
        SET u.Customer_id = @targetId, u.[User_id] =  CASE
                                                        WHEN u.[User_id] = OldParent.id THEN newParent.id
                                                        ELSE u.[User_id]
                                                      END
      FROM dbo.[User] u
        CROSS JOIN (SELECT new.id
                    FROM dbo.[User] new
                    WHERE new.Customer_id = @targetId AND new.[User_id] IS NULL) newParent
        CROSS JOIN (SELECT old.id
                    FROM dbo.[User] old
                    WHERE old.Customer_id = @sourceId AND old.[User_id] IS NULL) OldParent
      WHERE u.Customer_id = @sourceId AND u.[User_id] IS NOT NULL
    END;
    IF (@department = 1)
    BEGIN
      --presun zakazniku
      UPDATE c
        SET c.CustomerDepartment_id = @targetId
      FROM dbo.Customer c
      WHERE c.CustomerDepartment_id = @sourceId
    END;
	IF (@forms = 1)
    BEGIN
      --presun zakazniku
      UPDATE f
        SET f.Customer_id = @targetId
      FROM frm.FormInstance f
      WHERE f.Customer_id = @sourceId
    END;
  /*
    DELETE
    FROM helpdesk.CustomerUser
    WHERE Customer_id = @id;
    --skupiny uzivatelu
    DELETE
    FROM helpdesk.UserGroup
    WHERE Customer_id = @id
    DELETE
    FROM helpdesk.Project
    WHERE Customer_id = @id
    DELETE
    FROM helpdesk.CustomerClassification
    WHERE Customer_id = @id
    DELETE
    FROM helpdesk.CustomerCategory
    WHERE Customer_id = @id
    DELETE
    FROM helpdesk.DefaultResponse
    WHERE Customer_id = @id
    DELETE
    FROM dbo.CustomerBoard
    WHERE Customer_id = @id
    */
  COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[procMoveUser]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[procMoveUser]
  @Id int,
  @NewCusId int,
  @NewUserId int
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRAN
    --prehodim toho jednoho uzivatele...
    UPDATE dbo.[User] 
      SET Customer_id = @NewCusId, User_id = @NewUserId
    WHERE id = @Id;

    --vsechny podrizene toho uzivatele, musim prendat take k tomu zakaznikovi
    WITH Tree(Id, ParentId, HierarchyLevel)
    AS
    (
      SELECT u.id, u.[User_id] as ParentId, 1 as HierarchyLevel
      FROM dbo.[User] u
      WHERE u.id = @Id
      UNION ALL
      SELECT u.id, u.[User_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
      FROM dbo.[User] u
        INNER JOIN Tree t ON u.User_id = t.id 
    )
    UPDATE u
      SET Customer_id = @NewCusId
    FROM [User] u
      INNER JOIN Tree t ON u.Id = t.Id
 
  COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[procSelectBlackListAddress]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procSelectBlackListAddress]
	@minutes int = NULL,
	@cnt int = NULL,
  @dt datetime = NULL
AS
BEGIN
  
  IF (@dt IS NULL)
    SET @dt = GETDATE()

  SELECT MAX([Count]) as [Count], Address
  FROM
  (
	  SELECT COUNT(i2.FileId) as [Count], i1.[From] as Address
	  FROM helpdesk.MailTicket i1
		  INNER JOIN helpdesk.MailTicket i2 ON i1.[From] = i2.[From] AND i2.[Date] < i1.[Date]	--jen ty pred timto
			  --je to Xminut zpet
			  AND DATEDIFF(MINUTE, i2.[Date], i1.[Date]) <= @minutes
      LEFT JOIN dbo.BlackList bl ON i1.[From] = bl.Address
	  WHERE i1.[Date] >= DATEADD(DAY, -1, @dt) AND bl.Address IS NULL
	  GROUP BY i1.FileId, i1.[From]
	  HAVING COUNT(i2.FileId) >= @cnt
  ) g
  GROUP BY Address
END
GO
/****** Object:  StoredProcedure [dbo].[procSelectDevices]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procSelectDevices]
  @Customer_id int,
  @IsActive bit = NULL
AS
BEGIN
  IF (@IsActive IS NULL)
  BEGIN
    SELECT d.Id, d.Customer_id, d.Device_id as DeviceId, d.Name, d.IsActive, d.IsGroup, ISNULL(dt.Name, '') as DeviceTypeName, d.SerialNumber, d.InventaryNumber
    FROM dbo.[Device] d 
      LEFT JOIN dbo.DeviceType dt ON d.DeviceType_id = dt.Id
    WHERE d.Customer_id = @Customer_id
  END
  ELSE
  BEGIN
    WITH Tree(Id, ParentId, HierarchyLevel)
    AS
    (
      SELECT d.id, d.[Device_id] as ParentId, 1 as HierarchyLevel
      FROM dbo.[Device] d
      WHERE d.Customer_id = @Customer_id AND d.IsGroup = 0 AND (@IsActive IS NULL OR d.IsActive = @IsActive)
      UNION ALL
      SELECT d.id, d.[Device_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
      FROM dbo.[Device] d
        INNER JOIN Tree t ON d.id = t.ParentId  
    )
    SELECT DISTINCT d.Id, d.Customer_id, d.Device_id as DeviceId, d.Name, d.IsActive, d.IsGroup, ISNULL(dt.Name, '') as DeviceTypeName, d.SerialNumber, d.InventaryNumber
    FROM Tree t
      INNER JOIN dbo.[Device] d ON t.Id = d.Id
      LEFT JOIN dbo.DeviceType dt ON d.DeviceType_id = dt.Id
  END
END
GO
/****** Object:  StoredProcedure [dbo].[procSelectTreeNodes]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[procSelectTreeNodes]
  @id int,
  @MaxHierarchyLevel int = NULL,
  @userTree bit = 1,
  @upDirection bit = 1
AS
BEGIN
  IF (@userTree = 1)
  BEGIN
    IF (@upDirection = 1)
      WITH Tree(Id, ParentId, HierarchyLevel)
      AS
      (
        SELECT u.id, u.[User_id] as ParentId, 1 as HierarchyLevel
        FROM dbo.[User] u
        WHERE u.id = @id
        UNION ALL
        SELECT u.id, u.[User_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
        FROM dbo.[User] u
          INNER JOIN Tree t ON u.id = t.ParentId 
      )
      SELECT *
      FROM Tree 
      WHERE (@MaxHierarchyLevel IS NULL OR HierarchyLevel <= @MaxHierarchyLevel)
      ORDER BY HierarchyLevel
    ELSE
      WITH Tree(Id, ParentId, HierarchyLevel)
      AS
      (
        SELECT u.id, u.[User_id] as ParentId, 1 as HierarchyLevel
        FROM dbo.[User] u
        WHERE u.id = @id
        UNION ALL
        SELECT u.id, u.[User_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
        FROM dbo.[User] u
          INNER JOIN Tree t ON u.User_id = t.id 
      )
      SELECT *
      FROM Tree 
      WHERE (@MaxHierarchyLevel IS NULL OR HierarchyLevel <= @MaxHierarchyLevel)
      ORDER BY HierarchyLevel
  END
  ELSE
  BEGIN
    IF (@upDirection = 1)
      WITH Tree(Id, ParentId, HierarchyLevel)
      AS
      (
        SELECT u.id, u.Device_id as ParentId, 1 as HierarchyLevel
        FROM dbo.[Device] u
        WHERE u.id = @id
        UNION ALL
        SELECT u.id, u.Device_id as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
        FROM dbo.[Device] u
          INNER JOIN Tree t ON u.id = t.ParentId 
      )
      SELECT *
      FROM Tree 
      WHERE (@MaxHierarchyLevel IS NULL OR HierarchyLevel <= @MaxHierarchyLevel)
      ORDER BY HierarchyLevel
    ELSE
        WITH Tree(Id, ParentId, HierarchyLevel)
        AS
        (
          SELECT u.id, u.Device_id as ParentId, 1 as HierarchyLevel
          FROM dbo.[Device] u
          WHERE u.id = @id
          UNION ALL
          SELECT u.id, u.Device_id as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
          FROM dbo.[Device] u
            INNER JOIN Tree t ON u.Device_id = t.Id
        )
        SELECT *
        FROM Tree 
        WHERE (@MaxHierarchyLevel IS NULL OR HierarchyLevel <= @MaxHierarchyLevel)
        ORDER BY HierarchyLevel
  END
END
GO
/****** Object:  StoredProcedure [dbo].[procSelectUsers]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procSelectUsers]
  @Customer_id int,
  @IsActive bit = NULL
AS
BEGIN
  IF (@IsActive IS NULL)
  BEGIN
    SELECT u.Id, u.User_id as UserId, u.[Login], u.[Password], u.Email, u.Mobil, u.FirstName, u.LastName, u.IsActive, u.IsGroup, u.IsRoot
    FROM dbo.[User] u 
    WHERE u.Customer_id = @Customer_id
  END
  ELSE
  BEGIN
    WITH Tree(Id, ParentId, HierarchyLevel)
    AS
    (
      SELECT u.id, u.[User_id] as ParentId, 1 as HierarchyLevel
      FROM dbo.[User] u
      WHERE u.Customer_id = @Customer_id AND u.IsGroup = 0 AND (@IsActive IS NULL OR u.IsActive = @IsActive)
      UNION ALL
      SELECT u.id, u.[User_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
      FROM dbo.[User] u
        INNER JOIN Tree t ON u.id = t.ParentId  
    )
    SELECT DISTINCT u.Id, u.User_id as UserId, u.[Login], u.[Password], u.Email, u.Mobil, u.FirstName, u.LastName, u.IsActive, u.IsGroup, u.IsRoot
    FROM Tree t
      INNER JOIN dbo.[User] u ON t.Id = u.Id
  END
END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateDevicePartTpl]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[procUpdateDevicePartTpl]
  @id int
AS
BEGIN

  UPDATE d
    SET d.Name = tpl.Name, d.IsActive = tpl.IsActive
  FROM dbo.DevicePart d
    INNER JOIN dbo.DevicePart tpl ON d.DevicePartTpl_id = tpl.Id AND tpl.Id = @id

END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateDeviceTpl]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[procUpdateDeviceTpl]
  @id int
AS
BEGIN

  UPDATE d
    SET d.Name = tpl.Name, d.DeviceType_id = tpl.DeviceType_id, d.IsActive = tpl.IsActive
  FROM dbo.Device d
    INNER JOIN dbo.Device tpl ON d.DeviceTpl_id = tpl.Id AND tpl.Id = @id

END
GO
/****** Object:  StoredProcedure [frm].[procDeleteFormInstance]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [frm].[procDeleteFormInstance]
  @FormInstanceId int,
  @loggedUserId int = NULL
AS 
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRAN
    if (@loggedUserId IS NOT NULL)
    BEGIN
      INSERT INTO frm.[DeletedFormInstance]([FormInstance_id], [Form_id], [User_id], DeleteTime)
      SELECT fi.id, fv.Form_id, @loggedUserId, GETDATE()
      FROM frm.FormInstance fi
        INNER JOIN frm.FormVariant fv ON fi.FormVariant_id = fv.Id
      WHERE fi.Id = @FormInstanceId
    END

    --odeslane zpravy
    DELETE m
      FROM dbo.[Message] m
      INNER JOIN frm.[Message] f ON m.Id = f.Message_id
    WHERE f.FormInstance_id = @FormInstanceId

    --ticket
    DELETE 
    FROM frm.FormInstance
    WHERE Id = @FormInstanceId

  COMMIT
END



GO
/****** Object:  StoredProcedure [helpdesk].[procDeleteTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [helpdesk].[procDeleteTicket]
  @ticketId int,
  @loggedUserId int = NULL
AS 
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRAN
  --nastavim prvni a posledni na NULL
    UPDATE helpdesk.Ticket 
      SET StatusTicketFirst_id = NULL, StatusTicketLast_id = NULL
    WHERE id = @ticketId

    --vykazy
    DELETE wts
    FROM [helpdesk].[WorkDetailTicketStatus] wts
      INNER JOIN [helpdesk].[TicketStatus] ts ON wts.TicketStatus_id = ts.Id
    WHERE ts.Ticket_id = @ticketId

    DELETE
    FROM [helpdesk].[WorkDetailTicket] 
    WHERE Ticket_id = @ticketId

    --odeslane zpravy
    DELETE m
      FROM dbo.[Message] m
      INNER JOIN helpdesk.[Message] hdm ON m.Id = hdm.Message_id
    WHERE hdm.Ticket_id = @ticketId

    --prijate zpravy necham, jen vyhodim reference
    UPDATE helpdesk.MailTicket
      SET Ticket_id = NULL, User_id = NULL, Note = Note + 'Smazán ' + FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm', 'cs-cz')
    WHERE Ticket_id = @ticketId

    --servisni listy
    DELETE 
    FROM helpdesk.ServiceList
    WHERE Ticket_id = @ticketId

    --prilohy
    DELETE f
    FROM dbo.[File] f
      INNER JOIN helpdesk.TicketAttachment ta ON f.Id = ta.[File_id]
    WHERE ta.Ticket_id = @ticketId

    --tmpPrilohy
    DELETE f
    FROM dbo.[File] f
      INNER JOIN helpdesk.TmpAttachment tmp ON f.Id = tmp.[File_id]
    WHERE tmp.Ticket_id = @ticketId

    --stavy
    DELETE 
    FROM helpdesk.TicketStatus
    WHERE Ticket_id = @ticketId

    --stavy
    DELETE 
    FROM helpdesk.TicketLink
    WHERE Ticket_id = @ticketId OR TicketParent_id = @ticketId

    --zarizei
    DELETE 
    FROM helpdesk.DeviceTicket
    WHERE Ticket_id = @ticketId

     --ticket
    DELETE 
    FROM helpdesk.TicketEx
    WHERE Ticket_id = @ticketId

    --ticketEx
    DELETE 
    FROM helpdesk.Ticket
    WHERE Id = @ticketId

    --rating
    DELETE 
    FROM helpdesk.Ranking
    WHERE Ticket_id = @ticketId

    if (@loggedUserId IS NOT NULL)
    BEGIN
      INSERT INTO helpdesk.DeletedTicket(Ticket_id, [User_id], DeleteTime)
      VALUES (@ticketId, @loggedUserId, GETDATE())
    END
    


  COMMIT
END
GO
/****** Object:  StoredProcedure [helpdesk].[procMergeTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [helpdesk].[procMergeTicket]
  @ticketId int,
  @loggedUserId int = NULL,
  @mergeIds dbo.intTable READONLY
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON

  BEGIN TRAN
 
  --kontrola, aby to nespojilo pozadavky jineho zakaznika, nebo sam sebe
  DECLARE
    @Ids dbo.intTable

  INSERT INTO @Ids (Code)
  SELECT m.code
  FROM @mergeIds m
    CROSS JOIN helpdesk.Ticket tt 
    INNER JOIN helpdesk.Ticket t ON m.code = t.id AND tt.Customer_id = t.Customer_id
  WHERE t.Id != @ticketId AND tt.id = @ticketId
    
  --odeslane zpravy
  UPDATE helpdesk.[Message] 
    SET Ticket_id = @ticketId 
  WHERE Ticket_id IN (SELECT Code FROM @Ids)
  
  --prijate zpravy necham, jen vyhodim reference
  UPDATE helpdesk.MailTicket
    SET Ticket_id = @ticketId
  WHERE Ticket_id IN (SELECT Code FROM @Ids)

  --servisni listy
  UPDATE helpdesk.ServiceList
    SET Ticket_id = @ticketId
  WHERE Ticket_id IN (SELECT Code FROM @Ids)

  --prilohy
  UPDATE helpdesk.TicketAttachment 
    SET Ticket_id = @ticketId
  WHERE Ticket_id IN (SELECT Code FROM @Ids)

  --stavy
  UPDATE helpdesk.TicketStatus
    SET Ticket_id = @ticketId
  WHERE Ticket_id IN (SELECT Code FROM @Ids)

  INSERT INTO helpdesk.TicketLink (Ticket_id, TicketParent_id)
  SELECT DISTINCT @ticketId, tl.TicketParent_id
  FROM helpdesk.TicketLink tl
    INNER JOIN @Ids i ON tl.Ticket_id = i.code
  WHERE NOT EXISTS (SELECT 1
                    FROM helpdesk.TicketLink tl2
                    WHERE tl2.Ticket_id = @ticketId AND tl2.TicketParent_id = tl.TicketParent_id)
INSERT INTO helpdesk.TicketLink (Ticket_id, TicketParent_id)
SELECT DISTINCT tl.Ticket_id, @ticketId
  FROM helpdesk.TicketLink tl
    INNER JOIN @Ids i ON tl.TicketParent_id = i.code
  WHERE NOT EXISTS (SELECT 1
                    FROM helpdesk.TicketLink tl2
                    WHERE tl2.TicketParent_id = @ticketId AND tl2.Ticket_id = tl.TicketParent_id)

  --pokud bych tam nahodou dal stejnou, tak 
  DELETE
  FROM helpdesk.TicketLink
  WHERE Ticket_id = TicketParent_id
  
  --tickety ke smazani
  DECLARE cur CURSOR FOR SELECT Code FROM @Ids
  DECLARE @t int
  OPEN cur

  FETCH NEXT FROM cur INTO @t;
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
       EXEC helpdesk.procDeleteTicket @ticketId = @t, @loggedUserId = @loggedUserId
       FETCH NEXT FROM cur INTO @t;
  END  
  CLOSE cur  
  DEALLOCATE cur 

  --nastavim posledni a prvni
  UPDATE helpdesk.Ticket
    SET StatusTicketFirst_id = (SELECT TOP 1 ts.id FROM helpdesk.TicketStatus ts WHERE ts.Ticket_id = @ticketId ORDER BY ts.ChangeDateSys ASC),
        StatusTicketLast_id = (SELECT TOP 1 ts.id FROM helpdesk.TicketStatus ts WHERE ts.Ticket_id = @ticketId ORDER BY ts.ChangeDateSys DESC)
  WHERE Id = @ticketId

  COMMIT
END
GO
/****** Object:  StoredProcedure [helpdesk].[procSelectStateChanges]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [helpdesk].[procSelectStateChanges]
  @tplIds dbo.intTable READONLY,
  @states dbo.StateChange READONLY,
  @countryId int = NULL,
  @cusIds dbo.intTable READONLY,
  @prjIds dbo.intTable READONLY,
  @catIds dbo.intTable READONLY,
  @claIds dbo.intTable READONLY,
  @solveUserIds dbo.intTable READONLY,
  @from datetime,
  @to datetime,
  @reportType int,

  @workingHoursFrom time = '08:00',
  @workingHoursTo time = '17:00',
  @SLASeconds int = NULL
AS
BEGIN

  DECLARE
    @IsTemplate bit,
    @IsCustomer bit,
		@IsCategory bit,
		@IsClassification bit,
		@IsSolveUserId bit,
    @IsProject bit
  
  IF ((SELECT COUNT(*) FROM @tplIds) > 0)
		SET @IsTemplate = 1
  ELSE
		SET @IsTemplate = 0

  IF ((SELECT COUNT(*) FROM @cusIds) > 0)
		SET @IsCustomer = 1
  ELSE
		SET @IsCustomer = 0

	IF ((SELECT COUNT(*) FROM @catIds) > 0)
    SET @IsCategory = 1
  ELSE
		SET @IsCategory = 0

  IF ((SELECT COUNT(*) FROM @claIds) > 0)
    SET @IsClassification = 1
  ELSE
		SET @IsClassification = 0

	IF ((SELECT COUNT(*) FROM @solveUserIds) > 0)
    SET @IsSolveUserId = 1
  ELSE
    SET @IsSolveUserId = 0;

  IF ((SELECT COUNT(*) FROM @prjIds) > 0)
    SET @IsProject = 1
  ELSE
    SET @IsProject = 0;
    
  DECLARE @tmp TABLE 
  (
    TsId int NOT NULL,
    TsUserId int NOT NULL,
    TicketId int NOT NULL,
    TicketTitle varchar(300) NOT NULL,
    CustomerId int NOT NULL,
    CustomerName varchar(150) NOT NULL,
    ChangeDateSys datetime NOT NULL,
    StateId int NOT NULL,
    NextStateId int NULL
  )

  INSERT INTO @tmp (TsId, TsUserId, TicketId, TicketTitle, CustomerId, CustomerName, ChangeDateSys, StateId, NextStateId)
  SELECT TsId, TsUserId, TicketId, TicketTitle, CustomerId, CustomerName, ChangeDateSys, tbl.StateId, NextStateId
  FROM
  (
    SELECT  
      ts.Id as TsId,
      ts.User_id as TsUserId,
      t.id as TicketId,
      t.Title as TicketTitle,
      t.Customer_id as CustomerId,
      c.Name as CustomerName,
      ts.ChangeDateSys as ChangeDateSys,
      tsf.State_id as StateId,
      LAG(tsf.State_id) OVER (PARTITION BY t.Id ORDER BY ts.ChangeDateSys DESC ) NextStateId
    FROM helpdesk.TicketStatus tsFirst
      INNER JOIN helpdesk.TicketStatusFull tsFirstFull ON tsFirst.Id = tsFirstFull.TicketStatus_id
      INNER JOIN helpdesk.Ticket t ON tsFirst.Id = t.StatusTicketFirst_id
      INNER JOIN dbo.Customer c ON t.Customer_id = c.Id
      --stavy ze kterych
      INNER JOIN helpdesk.TicketStatus ts ON ts.Ticket_id = t.Id
      INNER JOIN helpdesk.TicketStatusFull tsf ON ts.Id = tsf.TicketStatus_id
      WHERE (@from <= tsFirst.ChangeDateSys) AND (@to >= tsFirst.ChangeDateSys) AND 
        (@countryId IS NULL OR c.Country_id = @countryId) AND
        ((@IsTemplate = 0) OR (c.CustomerGroup_id IN (SELECT code FROM @tplIds))) AND
        ((@IsCustomer = 0) OR (t.Customer_id IN (SELECT code FROM @cusIds))) AND
        ((@IsCategory = 0) OR (t.Category_id IN (SELECT code FROM @catIds))) AND
        ((@IsProject = 0) OR (t.Project_id IN (SELECT code FROM @prjIds))) AND
        ((@IsClassification = 0) OR (t.Classification_id IN (SELECT code FROM @claIds))) AND
        ((@IsSolveUserId = 0) 
          --je resitelem u vychoziho
          OR (EXISTS (SELECT 1
                      FROM helpdesk.TicketUser tu
                        INNER JOIN @solveUserIds u ON tu.[User_id] = u.code
                      WHERE tu.TicketStatus_id = tsFirst.Id AND tu.Role_id = 0))
          --je resitelem u koncoveho
          OR (EXISTS (SELECT 1
                      FROM helpdesk.TicketUser tu
                        INNER JOIN @solveUserIds u ON tu.[User_id] = u.code
                      WHERE tu.TicketStatus_id = ts.Id AND tu.Role_id = 0))
          OR (tsFirst.[User_id] IN (SELECT Code FROM @solveUserIds))
          OR (ts.[User_id] IN (SELECT Code FROM @solveUserIds))
         ) 
    ) tbl
      INNER JOIN @states s ON s.StateId = tbl.StateId
    WHERE tbl.StateId != tbl.NextStateId

  IF (@reportType = 1)
  BEGIN
      SELECT 
        states.TicketId, states.TicketTitle,
        tbl.StateId, tbl.StateNextId,
        states.CustomerId, states.CustomerName,
        states.ChangeDateSys as ChangeDateSys,
        fceNext.ChangeDateSys as ChangeDateSysNext,
        DENSE_RANK() OVER (PARTITION BY states.CustomerId ORDER BY states.TicketId) as TicketCount,
        fceTime.NetTime as NetTime, fceTime.RoughTime as RoughTime,
        CAST(tbl.StateId * 100 + tbl.StateNextId as varchar(MAX)) as GroupId,
        fceTime.NetTime - @SLASeconds as OverTime
      FROM @tmp states
        INNER JOIN @states tbl ON states.StateId = tbl.StateId
        CROSS APPLY [helpdesk].[fceGetNextTicketStatusFull](states.TicketId, states.ChangeDateSys, tbl.StateNextId, 1) as fceNext
        CROSS APPLY [helpdesk].[fceGetSolutionTime] (states.ChangeDateSys, fceNext.ChangeDateSys, @workingHoursFrom, @workingHoursTo) as fceTime
  END
  ELSE IF (@reportType = 2)
  BEGIN
    SELECT 
      states.TicketId, states.TicketTitle,
      tbl.StateId, tbl.StateNextId,
      u.id as CustomerId, u.LastName + ' ' + u.FirstName as CustomerName,
      states.ChangeDateSys as ChangeDateSys,
      fceNext.ChangeDateSys as ChangeDateSysNext,
      DENSE_RANK() OVER (PARTITION BY states.CustomerId ORDER BY states.TicketId) as TicketCount,
      fceTime.NetTime as NetTime, fceTime.RoughTime as RoughTime,
      CAST(tbl.StateId * 100 + tbl.StateNextId as varchar(MAX)) as GroupId,
      fceTime.NetTime - @SLASeconds as OverTime
    FROM @tmp states
      INNER JOIN @states tbl ON states.StateId = tbl.StateId
      INNER JOIN dbo.[User] u ON u.Id = states.TsUserId

      CROSS APPLY [helpdesk].[fceGetNextTicketStatusFull](states.TicketId, states.ChangeDateSys, tbl.StateNextId, 1) as fceNext
      CROSS APPLY [helpdesk].[fceGetSolutionTime] (states.ChangeDateSys, fceNext.ChangeDateSys, @workingHoursFrom, @workingHoursTo) as fceTime
  END
  ELSE IF (@reportType = 3)
  BEGIN
    SELECT 
      states.TicketId, states.TicketTitle,
      tbl.StateId, tbl.StateNextId,
      u.id as CustomerId, u.LastName + ' ' + u.FirstName as CustomerName,
      states.ChangeDateSys as ChangeDateSys,
      fceNext.ChangeDateSys as ChangeDateSysNext,
      DENSE_RANK() OVER (PARTITION BY states.CustomerId ORDER BY states.TicketId) as TicketCount,
      fceTime.NetTime as NetTime, fceTime.RoughTime as RoughTime,
      CAST(tbl.StateId * 100 + tbl.StateNextId as varchar(MAX)) as GroupId,
      fceTime.NetTime - @SLASeconds as OverTime
    FROM @tmp states
      INNER JOIN @states tbl ON states.StateId = tbl.StateId
      CROSS APPLY [helpdesk].[fceGetNextTicketStatusFull](states.TicketId, states.ChangeDateSys, tbl.StateNextId, 1) as fceNext
      CROSS APPLY [helpdesk].[fceGetSolutionTime] (states.ChangeDateSys, fceNext.ChangeDateSys, @workingHoursFrom, @workingHoursTo) as fceTime
      INNER JOIN dbo.[User] u ON u.Id = fceNext.UserId
  END
END
GO
/****** Object:  StoredProcedure [helpdesk].[procSelectStateStats]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [helpdesk].[procSelectStateStats]
  @tplIds dbo.intTable READONLY,
  @stateId int,
  @countryId int,
  @cusIds dbo.intTable READONLY,
  @catIds dbo.intTable READONLY,
  @claIds dbo.intTable READONLY,
  @solveUserIds dbo.intTable READONLY,
  @from datetime,
  @to datetime
AS
BEGIN
  DECLARE
    @IsTemplate bit,
    @IsCustomer bit,
		@IsCategory bit,
		@IsClassification bit,
		@IsSolveUserId bit
    
  IF ((SELECT COUNT(*) FROM @tplIds) > 0)
		SET @IsTemplate = 1
  ELSE
		SET @IsTemplate = 0

  IF ((SELECT COUNT(*) FROM @cusIds) > 0)
		SET @IsCustomer = 1
  ELSE
		SET @IsCustomer = 0

	IF ((SELECT COUNT(*) FROM @catIds) > 0)
    SET @IsCategory = 1
  ELSE
		SET @IsCategory = 0

  IF ((SELECT COUNT(*) FROM @claIds) > 0)
    SET @IsClassification = 1
  ELSE
		SET @IsClassification = 0

	IF ((SELECT COUNT(*) FROM @solveUserIds) > 0)
    SET @IsSolveUserId = 1
  ELSE
    SET @IsSolveUserId = 0;

  SELECT  
    t.id as TicketId,
    t.Title as TicketTitle,
    t.Customer_id as CustomerId,
    c.Name as CustomerName,
    s.Id as ActStateId, s.Idx as ActStateIdx, s.Name as ActStateName,
    COUNT(*) OVER (PARTITION BY c.Id) as TicketCount
  FROM helpdesk.TicketStatus tsFirst
    INNER JOIN helpdesk.Ticket t ON tsFirst.Id = t.StatusTicketFirst_id
    INNER JOIN dbo.Customer c ON t.Customer_id = c.Id
    --posledni stav
    INNER JOIN helpdesk.TicketStatusFull tsLast ON t.StatusTicketLast_id = tsLast.TicketStatus_id
    INNER JOIN helpdesk.[State] s ON tsLast.State_id = s.Id
  WHERE (@from <= tsFirst.ChangeDateSys) AND (@to >= tsFirst.ChangeDateSys) AND 
    (@countryId IS NULL OR c.Country_id = @countryId) AND
    ((@IsTemplate = 0) OR (c.CustomerGroup_id IN (SELECT code FROM @tplIds))) AND
    ((@IsCustomer = 0) OR (t.Customer_id IN (SELECT code FROM @cusIds))) AND
    ((@IsCategory = 0) OR (t.Category_id IN (SELECT code FROM @catIds))) AND
    ((@IsClassification = 0) OR (t.Classification_id IN (SELECT code FROM @claIds))) AND
    EXISTS (SELECT 1
            FROM helpdesk.TicketStatus ts
              INNER JOIN helpdesk.TicketStatusFull tsf ON ts.Id = tsf.TicketStatus_id
            WHERE ts.Ticket_id = t.Id AND tsf.State_id = @stateId)

END
GO
/****** Object:  StoredProcedure [helpdesk].[procSelectTicketCountsSummary]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [helpdesk].[procSelectTicketCountsSummary]
  @countryId int,
  @cusIds dbo.intTable READONLY,
  @tplIds dbo.intTable READONLY,
  @catIds dbo.intTable READONLY,
  @claIds dbo.intTable READONLY,
  @prjIds dbo.intTable READONLY,
  @stateIds dbo.intTable READONLY,
  @deviceIds dbo.intTable READONLY,
  @toDate datetime,
  @from datetime,
  @to datetime,

  @workingHoursFrom time = '08:00',
  @workingHoursTo time = '17:00'
AS
BEGIN

  DECLARE
    @IsCustomer bit,
		@IsCategory bit,
		@IsClassification bit,
		@IsProject bit,
    @IsState bit,
    @IsDevice bit,
    @IsTemplate bit
    
  IF ((SELECT COUNT(*) FROM @cusIds) > 0)
		SET @IsCustomer = 1
  ELSE
		SET @IsCustomer = 0

	IF ((SELECT COUNT(*) FROM @catIds) > 0)
    SET @IsCategory = 1
  ELSE
		SET @IsCategory = 0

  IF ((SELECT COUNT(*) FROM @claIds) > 0)
    SET @IsClassification = 1
  ELSE
		SET @IsClassification = 0

  IF ((SELECT COUNT(*) FROM @prjIds) > 0)
    SET @IsProject = 1
  ELSE
		SET @IsProject = 0

  IF ((SELECT COUNT(*) FROM @stateIds) > 0)
    SET @IsState = 1
  ELSE
		SET @IsState = 0

  IF ((SELECT COUNT(*) FROM @deviceIds) > 0)
    SET @IsDevice = 1
  ELSE
		SET @IsDevice = 0

  IF ((SELECT COUNT(*) FROM @tplIds) > 0)
    SET @IsTemplate = 1
  ELSE
		SET @IsTemplate = 0
  
;WITH States (ChangeDateSys, TicketId, StateId, LastStateId)
AS
(
  SELECT 
    tsLast.ChangeDateSys,
    tsLast.Ticket_id as TicketId, 
    tsfLast.State_id as StateId,
    --posledni hodnota stavu
    LAST_VALUE(tsfLast.State_id) OVER (PARTITION BY tsLast.Ticket_id ORDER BY tsLast.ChangeDateSys ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as LastStateId
    --predchozi hodnota
    --LAG(tsfLast.State_id) OVER (PARTITION BY tsLast.Ticket_id ORDER BY tsLast.ChangeDateSys) as PrevStateId
    --DENSE_RANK() over (PARTITION BY tsLast.Ticket_id ORDER BY tsfLast.State_id DESC ) as Idx
    --,NTILE (10) over (PARTITION BY tsLast.Ticket_id ORDER BY tsfLast.State_id DESC ) as tile
    --,ROW_NUMBER() over (PARTITION BY tsLast.Ticket_id ORDER BY tsLast.ChangeDateSys DESC ) as Idx
  FROM helpdesk.TicketStatus tsLast
    INNER JOIN helpdesk.TicketStatusFull tsfLast ON tsLast.Id = tsfLast.TicketStatus_id
    INNER JOIN helpdesk.[State] s ON tsfLast.State_id = s.Id
    
    INNER JOIN helpdesk.Ticket t ON tsLast.Ticket_id = t.Id
    INNER JOIN helpdesk.TicketStatus tsFirst ON t.StatusTicketFirst_id = tsFirst.Id
    INNER JOIN dbo.Customer c ON t.Customer_id = c.Id
  WHERE tsLast.ChangeDateSys <= @toDate 
    AND (@from <= tsFirst.ChangeDateSys) AND (@to >= tsFirst.ChangeDateSys) 
    AND ((@countryId IS NULL) OR (c.Country_id = @countryId))
    AND ((@IsTemplate = 0) OR (c.CustomerGroup_id IN (SELECT code FROM @tplIds)))
    AND ((@IsCustomer = 0) OR (t.Customer_id IN (SELECT code FROM @cusIds))) 
    AND ((@IsCategory = 0) OR (t.Category_id IN (SELECT code FROM @catIds))) 
    AND ((@IsClassification = 0) OR (t.Classification_id IN (SELECT code FROM @claIds))) 
    AND ((@IsProject = 0) OR (t.Project_id IN (SELECT code FROM @prjIds))) 
    AND ((@IsState = 0) OR (tsfLast.State_id IN (SELECT code FROM @stateIds))) 
    AND ((@IsDevice = 0) OR (EXISTS (SELECT 1
                                      FROM helpdesk.DeviceTicket dt
                                      WHERE dt.Ticket_id = t.id AND dt.Device_id IN (SELECT code FROM @deviceIds))))
  --ORDER BY tsLast.Ticket_id, tsLast.ChangeDateSys
),
LastState AS
(
  SELECT TicketId, LastStateId
  FROM States
  GROUP BY TicketId, LastStateId
),
PrevState as
(
  SELECT TicketId, LastStateId
  FROM
  (
    SELECT s.TicketId,
      LAST_VALUE(s.StateId) OVER (PARTITION BY s.TicketId ORDER BY s.ChangeDateSys ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as LastStateId
    FROM LastState l
      INNER JOIN States s ON l.TicketId = s.TicketId 
    WHERE s.StateId != l.LastStateId --Idx = 1 AND s.LastStateId = l.LastStateId AND s.PrevStateId != l.LastStateId
  ) q
  GROUP BY TicketId, LastStateId
)
SELECT  
  t.id as TicketId,
  t.Title as TicketTitle,
  t.Customer_id as CustomerId,
  c.Name as CustomerName,
  t.Category_id as CategoryId,
  cat.Name as CategoryName,
  t.Classification_id as ClassificationId,
  cla.Name as ClassificationName,
  t.Project_id as ProjectId,
  prj.Name as ProjectName,
  s.Id as StateLastId, s.Name as StateLastName,
  p.LastStateId as PrevStateId,
  STUFF(( SELECT ', ' + ISNULL(CAST(dt.Device_id as varchar(10)), dt.DeviceName)
			      FROM helpdesk.DeviceTicket dt
            WHERE dt.Ticket_id = t.Id
			      FOR XML PATH('')), 1, 1, '') AS DeviceId, 
    STUFF(( SELECT ', ' + ISNULL(d.Name, dt.DeviceName)
			      FROM helpdesk.DeviceTicket dt
              LEFT JOIN dbo.Device d ON dt.Device_id = d.id
            WHERE dt.Ticket_id = t.Id
			      FOR XML PATH('')), 1, 1, '') AS DeviceName,
  CASE
    WHEN (CAST(tsFirst.ChangeDateSys as time) >= @workingHoursFrom AND CAST(tsFirst.ChangeDateSys as time) <= @workingHoursTo) THEN 1
    ELSE 0
  END as InWorkingHour
FROM LastState l
  INNER JOIN  PrevState p ON l.TicketId = p.TicketId 
  INNER JOIN helpdesk.Ticket t ON l.TicketId = t.Id
  INNER JOIN helpdesk.TicketStatus tsFirst ON tsFirst.Id = t.StatusTicketFirst_id
  INNER JOIN dbo.Customer c ON t.Customer_id = c.Id
  LEFT JOIN helpdesk.Category cat ON t.Category_id = cat.Id
  LEFT JOIN helpdesk.Classification cla ON t.Classification_id = cla.Id
  LEFT JOIN helpdesk.Project prj ON t.Project_id = prj.Id
  INNER JOIN helpdesk.[State] s ON l.LastStateId = s.Id
  
END
GO
/****** Object:  StoredProcedure [helpdesk].[procSelectTicketIntervals]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [helpdesk].[procSelectTicketIntervals]
  @tplIds dbo.intTable READONLY,
  @countryId int,
  @cusIds dbo.intTable READONLY,
  @catIds dbo.intTable READONLY,
  @claIds dbo.intTable READONLY,
  @prjIds dbo.intTable READONLY,
  @requestUserIds dbo.intTable READONLY,
  @deviceIds dbo.intTable READONLY,
  @from datetime,
  @to datetime,
  @reportTypeName varchar(50)
AS
BEGIN
  DECLARE
    @IsTemplate bit,
    @IsCustomer bit,
		@IsCategory bit,
		@IsClassification bit,
    @IsProjectId bit,
		@IsRequestUserId bit,
    @IsDeviceId bit
    
  IF ((SELECT COUNT(*) FROM @tplIds) > 0)
		SET @IsTemplate = 1
  ELSE
		SET @IsTemplate = 0
    
  IF ((SELECT COUNT(*) FROM @cusIds) > 0)
		SET @IsCustomer = 1
  ELSE
		SET @IsCustomer = 0

	IF ((SELECT COUNT(*) FROM @catIds) > 0)
    SET @IsCategory = 1
  ELSE
		SET @IsCategory = 0

  IF ((SELECT COUNT(*) FROM @claIds) > 0)
    SET @IsClassification = 1
  ELSE
		SET @IsClassification = 0

    IF ((SELECT COUNT(*) FROM @prjIds) > 0)
    SET @IsProjectId = 1
  ELSE
		SET @IsProjectId = 0

	IF ((SELECT COUNT(*) FROM @requestUserIds) > 0)
    SET @IsRequestUserId = 1
  ELSE
    SET @IsRequestUserId = 0;

  	IF ((SELECT COUNT(*) FROM @deviceIds) > 0)
    SET @IsDeviceId = 1
  ELSE
    SET @IsDeviceId = 0;

  IF (@reportTypeName = 'TicketInterval_Device')
  BEGIN
    --podle zarizeni
    SELECT 
      TicketId, TicketTitle, CustomerId, CustomerName, RequestUserId, RequestUserName, DeviceId, DeviceName,
      ChangeDateSys, PrevChangeDateSys, DATEDIFF(ss, PrevChangeDateSys, ChangeDateSys) as Diff
    FROM
    (
      SELECT  
        t.id as TicketId, t.Title as TicketTitle,
        t.Customer_id as CustomerId, c.Name as CustomerName,
        ISNULL(CAST(u.Id as varchar(100)), t.RequestUser) as RequestUserId, ISNULL(u.LastName + ' ' + u.FirstName, t.RequestUser) as RequestUserName,
        CAST(d.Id as varchar(10)) as DeviceId, d.Name as DeviceName,
        tsFirst.ChangeDateSys,
        LAG(tsFirst.ChangeDateSys) OVER (PARTITION BY t.Customer_id, dt.Device_id ORDER BY tsFirst.ChangeDateSys ASC ) PrevChangeDateSys
      FROM helpdesk.TicketStatus tsFirst
        INNER JOIN helpdesk.Ticket t ON tsFirst.Id = t.StatusTicketFirst_id
        LEFT JOIN dbo.[User] u ON t.[User_id] = u.Id
        LEFT JOIN helpdesk.DeviceTicket dt ON t.Id = dt.Ticket_id
        LEFT JOIN dbo.Device d ON dt.Device_id = d.Id
        INNER JOIN dbo.Customer c ON t.Customer_id = c.Id
      WHERE tsFirst.ChangeDateSys >= @from AND tsFirst.ChangeDateSys <= @to AND
        (@countryId IS NULL OR c.Country_id = @countryId) AND
        ((@IsTemplate = 0) OR (c.CustomerGroup_id IN (SELECT code FROM @tplIds))) AND
        ((@IsCustomer = 0) OR (t.Customer_id IN (SELECT code FROM @cusIds))) AND
        ((@IsCategory = 0) OR (t.Category_id IN (SELECT code FROM @catIds))) AND
        ((@IsClassification = 0) OR (t.Classification_id IN (SELECT code FROM @claIds))) AND
        ((@IsProjectId = 0) OR (t.Project_id IN (SELECT code FROM @prjIds))) AND
        ((@IsRequestUserId = 0) OR (t.User_id IN (SELECT code FROM @requestUserIds))) AND
        ((@IsDeviceId = 0) OR (d.Device_id IN (SELECT code FROM @deviceIds)))
      ) q
  END
  ELSE
  BEGIN
    --podle zarizeni
    SELECT 
      TicketId, TicketTitle, CustomerId, CustomerName, RequestUserId, RequestUserName, 
      STUFF(( SELECT ', ' + ISNULL(CAST(dt.Device_id as varchar(10)), dt.DeviceName)
			        FROM helpdesk.DeviceTicket dt
              WHERE dt.Ticket_id = q.TicketId
			        FOR XML PATH('')), 1, 1, '') AS DeviceId, 
      STUFF(( SELECT ', ' + ISNULL(d.Name, dt.DeviceName)
			        FROM helpdesk.DeviceTicket dt
                LEFT JOIN dbo.Device d ON dt.Device_id = d.id
              WHERE dt.Ticket_id = q.TicketId
			        FOR XML PATH('')), 1, 1, '') AS DeviceName,
      ChangeDateSys, PrevChangeDateSys, DATEDIFF(ss, PrevChangeDateSys, ChangeDateSys) as Diff
    FROM
    (
      SELECT  
        t.id as TicketId, t.Title as TicketTitle,
        t.Customer_id as CustomerId, c.Name as CustomerName,
        ISNULL(CAST(u.Id as varchar(100)), t.RequestUser) as RequestUserId, ISNULL(u.LastName + ' ' + u.FirstName, t.RequestUser) as RequestUserName,
        tsFirst.ChangeDateSys,
        LAG(tsFirst.ChangeDateSys) OVER (PARTITION BY t.Customer_id, u.Id ORDER BY tsFirst.ChangeDateSys ASC ) PrevChangeDateSys
      FROM helpdesk.TicketStatus tsFirst
        INNER JOIN helpdesk.Ticket t ON tsFirst.Id = t.StatusTicketFirst_id
        LEFT JOIN dbo.[User] u ON t.[User_id] = u.Id

        INNER JOIN dbo.Customer c ON t.Customer_id = c.Id
      WHERE tsFirst.ChangeDateSys >= @from AND tsFirst.ChangeDateSys <= @to AND
        (@countryId IS NULL OR c.Country_id = @countryId) AND
        ((@IsCustomer = 0) OR (t.Customer_id IN (SELECT code FROM @cusIds))) AND
        ((@IsCategory = 0) OR (t.Category_id IN (SELECT code FROM @catIds))) AND
        ((@IsClassification = 0) OR (t.Classification_id IN (SELECT code FROM @claIds))) AND
        ((@IsProjectId = 0) OR (t.Project_id IN (SELECT code FROM @prjIds))) AND
        ((@IsRequestUserId = 0) OR (t.User_id IN (SELECT code FROM @requestUserIds))) AND
        ((@IsDeviceId = 0) OR (EXISTS (SELECT 1
                                      FROM helpdesk.DeviceTicket dt
                                      WHERE dt.Ticket_id = t.id AND dt.Device_id IN (SELECT code FROM @deviceIds))))
      ) q
  END
END
GO
/****** Object:  StoredProcedure [helpdesk].[procSelectTicketReactionTime]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [helpdesk].[procSelectTicketReactionTime]
  @cusId int,
  @ticketIds intTable READONLY,

  @from datetime,
  @to datetime,

  @workingHoursFrom time = '08:00',
  @workingHoursTo time = '17:00'
AS
BEGIN
  DECLARE
	  @IsTicket bit
    
  IF ((SELECT COUNT(*) FROM @ticketIds) > 0)
    SET @IsTicket = 1
  ELSE
    SET @IsTicket = 0

  SELECT s.Id as TicketId, s.Title as TicketTitle, s.Customer_id as CustomerId, c.Name as CustomerName, 
    s.IsExternal, s.State_id as StateId, s.StateIdx, s.StateName, 
    s.PreviousValue, s.NextValue, s.ChangeDateSys, 
    fcePrev.NetTime as NetTimePrev, fcePrev.RoughTime as RoughTimePrev,
    fceNext.NetTime as NetTimeNext, fceNext.RoughTime as RoughTimeNext
  FROM
  (
    SELECT t.Id, t.Title, t.Customer_id, ts.IsExternal, 
      LAG(ts.ChangeDateSys) OVER (PARTITION BY t.Id ORDER BY ts.ChangeDateSys) PreviousValue, 
      LEAD(ts.ChangeDateSys) OVER (PARTITION BY t.Id ORDER BY ts.ChangeDateSys) NextValue, 
      ts.ChangeDateSys, tsf.State_id, s.Idx as StateIdx, s.Name as StateName
    FROM helpdesk.Ticket t
      INNER JOIN helpdesk.TicketStatus ts ON t.Id = ts.Ticket_id
      INNER JOIN helpdesk.TicketStatusFull tsf ON ts.Id = tsf.TicketStatus_id
      INNER JOIN helpdesk.[State] s ON tsf.State_id = s.Id

      --prvni pozadavek
      INNER JOIN helpdesk.TicketStatus tsFirst ON t.StatusTicketFirst_id = tsFirst.Id
        AND tsFirst.ChangeDateSys >= @From AND tsFirst.ChangeDateSys <= @To
    WHERE t.Customer_id = @cusId
      AND (@IsTicket = 0 OR t.Id IN (SELECT code FROM @ticketIds))
  ) s
    CROSS APPLY [helpdesk].[fceGetSolutionTime] (s.PreviousValue, s.ChangeDateSys, @workingHoursFrom, @workingHoursTo) as fcePrev
    CROSS APPLY [helpdesk].[fceGetSolutionTime] (s.ChangeDateSys, s.NextValue, @workingHoursFrom, @workingHoursTo) as fceNext
    INNER JOIN dbo.Customer c ON s.Customer_id = c.Id
END
GO
/****** Object:  StoredProcedure [helpdesk].[procUpdateTicketUser_ReadTicket]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [helpdesk].[procUpdateTicketUser_ReadTicket]
  @ticketId int,
  @userId int
AS 
BEGIN

  DECLARE
    @ticketUserIds dbo.intTable 

  INSERT INTO @ticketUserIds(code)
  SELECT tu.Id
  FROM [helpdesk].TicketUser tu
    INNER JOIN [helpdesk].Ticket t ON tu.TicketStatus_id = t.StatusTicketLast_id
  WHERE tu.User_id = @userId AND t.Id = @ticketId

  IF ((SELECT COUNT(*) FROM @ticketUserIds) > 0)
  BEGIN
    UPDATE tu SET ReadDate = GETDATE()
    FROM helpdesk.TicketUser tu
      INNER JOIN @ticketUserIds tmp ON tu.Id = tmp.code
    WHERE tu.ReadDate IS NULL
  END
  ELSE
  BEGIN
    INSERT INTO [helpdesk].[TicketUser]([TicketStatus_id], [User_id], [Role_id], [UserExt], [IsGuarantor], [ReadDate])
    SELECT t.StatusTicketLast_id, @userId, 12, '', 0, GETDATE()
    FROM helpdesk.Ticket t WHERE t.Id = @ticketId
  END
END
GO
/****** Object:  StoredProcedure [hr].[procCopyActivities]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hr].[procCopyActivities]
  @userId int,
  @date date,
  @users dbo.intTable READONLY
AS
BEGIN
  
  SET NOCOUNT ON
  SET XACT_ABORT ON

  IF NOT EXISTS ( SELECT 1
                  FROM hr.Activity a
                    INNER JOIN @users u ON u.code = a.User_id AND a.Date = @date)
  BEGIN

    BEGIN TRAN

    INSERT INTO hr.Activity(User_id, [Date], [SysDate], IsClosed, Note, ActivityTemplate_Id)
    SELECT u.code, a.[Date], GETDATE(), a.IsClosed, a.Note, a.Id
    FROM hr.Activity a 
      CROSS JOIN @users u
    WHERE User_id = @userId AND [Date] = @date

    --vsechny oddedene typy
    --work
    INSERT INTO [hr].[Work] ([Activity_Id], [From], [To], [IsHomeOffice], [Department_id])
    SELECT aNew.Id, w.[From], w.[To], w.[IsHomeOffice], w.[Department_id]
    FROM hr.Activity a 
      INNER JOIN hr.Work w ON a.Id = w.Activity_Id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --CareOf
    INSERT INTO [hr].CareOf ([Activity_Id])
    SELECT aNew.Id
    FROM hr.Activity a 
      INNER JOIN hr.CareOf c ON a.Id = c.Activity_Id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --Doctor
    INSERT INTO [hr].Doctor ([Activity_Id], [From], [To])
    SELECT aNew.Id, d.[From], d.[To]
    FROM hr.Activity a 
      INNER JOIN hr.Doctor d ON a.Id = d.Activity_Id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --Holiday
    INSERT INTO [hr].Holiday ([Activity_Id], [IsHalfDay])
    SELECT aNew.Id, h.[IsHalfDay]
    FROM hr.Activity a 
      INNER JOIN hr.Holiday h ON a.Id = h.Activity_Id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --Illness
    INSERT INTO [hr].Illness ([Activity_Id])
    SELECT aNew.Id
    FROM hr.Activity a 
      INNER JOIN hr.Illness i ON a.Id = i.Activity_Id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --SickDay
    INSERT INTO [hr].Illness ([Activity_Id])
    SELECT aNew.Id
    FROM hr.Activity a 
      INNER JOIN hr.SickDay s ON a.Id = s.Activity_Id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --TimeOff
    INSERT INTO [hr].TimeOff ([Activity_Id])
    SELECT aNew.Id
    FROM hr.Activity a 
      INNER JOIN hr.TimeOff t ON a.Id = t.Activity_Id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --detail prace
    INSERT INTO [hr].[WorkDetail]([Work_id],[Customer_id],[Project_id],[SolutionTime],[IsPreSales],[Description],[Task_id],[WorkType_id],[SolutionTimeTransport])
    SELECT wNew.Activity_Id, wd.[Customer_id],wd.[Project_id],wd.[SolutionTime],wd.[IsPreSales],wd.[Description],wd.[Task_id],wd.[WorkType_id],wd.[SolutionTimeTransport]
    FROM hr.Activity a 
      INNER JOIN hr.Work w ON a.Id = w.Activity_Id
      INNER JOIN hr.WorkDetail wd ON w.Activity_Id = wd.Work_id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
      INNER JOIN hr.Work wNew ON aNew.Id = wNew.Activity_Id
        AND w.Department_id = wNew.Department_id AND w.[From] = wNew.[From] AND w.[To] = wNew.[To] 
    WHERE a.User_id = @userId AND a.[Date] = @date

    --prideleny ticketStatu
    INSERT INTO [helpdesk].[WorkDetailTicketStatus](TicketStatus_id, WorkDetail_id)
    SELECT wdts.TicketStatus_id, wdNew.Id
    FROM hr.Activity a 
      INNER JOIN hr.Work w ON a.Id = w.Activity_Id
      INNER JOIN hr.WorkDetail wd ON w.Activity_Id = wd.Work_id
      INNER JOIN helpdesk.WorkDetailTicketStatus wdts ON wd.Id = wdts.WorkDetail_id
      INNER JOIN hr.Activity aNew ON aNew.ActivityTemplate_Id = a.Id 
      INNER JOIN @users u ON u.code = aNew.User_id 
      INNER JOIN hr.Work wNew ON aNew.Id = wNew.Activity_Id
        AND w.Department_id = wNew.Department_id AND w.[From] = wNew.[From] AND w.[To] = wNew.[To]
      INNER JOIN hr.WorkDetail wdNew ON wNew.Activity_Id = wdNew.Work_id
        AND wd.Customer_id = wdNew.Customer_id AND wd.Project_id = wdNew.Project_id AND wd.SolutionTime = wdNew.SolutionTime
        AND wd.Description = wdNew.Description
    WHERE a.User_id = @userId AND a.[Date] = @date

    COMMIT

    RETURN 1
  END
  ELSE
  BEGIN
    RETURN 0
  END
END
GO
/****** Object:  StoredProcedure [hr].[procSelectUserAttendance]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [hr].[procSelectUserAttendance]
  @userIds dbo.intTable READONLY,
  @from		date,
  @to		date
AS 
BEGIN

	DECLARE 
    @pivot nvarchar(MAX), 
    @pivotIsNull nvarchar(MAX),
	  @sql	nvarchar(MAX)

	SELECT @pivot = STUFF(( SELECT DISTINCT ',[' + CAST(Day AS nvarchar(MAX)) + ']' FROM [dbo].[fceSelectDays] (@from, @to, 0) FOR xml path('')), 1, 1, '');
  SELECT @pivotIsNull = STUFF(( SELECT DISTINCT ',ISNULL([' + CAST(Day AS nvarchar(MAX)) + '], ''A'') as [' + CAST(Day AS nvarchar(MAX)) + ']' FROM [dbo].[fceSelectDays] (@from, @to, 0) FOR xml path('')), 1, 1, '');
	print @pivot;
  print @pivotIsNull;

  --DECLARE
  --  @IsUser bit
  --IF ((SELECT COUNT(*) FROM @userIds) > 0)
		--SET @IsUser = 1
  --ELSE
		--SET @IsUser = 0
	   
	SET @sql = N'
;WITH
attendance (UserId, [Date], [Attendance], [WorkedFund], [DayFund]) as
(
  SELECT UserId, [Date], [Attendance], [WorkedFund], [DayFund]
  FROM [hr].[fceSelectAttendance](@userIds, @from, @to) a
),
fund (UserId, [WorkedFund], [DayFund]) as
(
  SELECT UserId, SUM(WorkedFund) as WorkedFund, SUM(DayFund) as DayFund
  FROM attendance
  GROUP BY UserId
)
SELECT hrUser.PersonalNumber, u.LastName, u.FirstName, hrUser.WorkFundHours, f.WorkedFund, f.DayFund, ' + @pivotIsNull + '
FROM 
(
  SELECT UserId, [Date], [Attendance]
  FROM attendance
) p
PIVOT
(
	MIN([Attendance]) --cokoliv, tabulka obsahuje pouze jednu hodnotu per den
	FOR Date IN (' + @pivot + ')
) piv
	INNER JOIN dbo.[User] u ON piv.UserId = u.id
	INNER JOIN hr.[User] hrUser on hrUser.User_Id = u.Id
  INNER JOIN fund f ON u.Id = f.UserId
ORDER BY u.LastName, u.FirstName'

	PRINT @sql
	exec sp_executesql @sql, N'@userIds	dbo.intTable READONLY, @from	date, @to	date', @userIds, @from, @to

END
GO
/****** Object:  StoredProcedure [wf].[procSelectUserWorkflows]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [wf].[procSelectUserWorkflows]
  @id int
AS
BEGIN
  WITH Tree(UserId, ParentId, HierarchyLevel)
  AS
  (
    SELECT u.id, u.[User_id] as ParentId, 1 as HierarchyLevel
    FROM dbo.[User] u
    WHERE u.id = @id
    UNION ALL
    SELECT u.id, u.[User_id] as ParentId, t.HierarchyLevel + 1 AS HierarchyLevel
    FROM dbo.[User] u
      INNER JOIN Tree t ON u.id = t.ParentId 
  )
  SELECT DISTINCT wu.Workflow_id as WorkflowId, w.Name as WorkflowName
  FROM Tree t
    INNER JOIN wf.WorkflowUser wu ON t.UserId = wu.[User_id]
    INNER JOIN wf.Workflow w ON wu.Workflow_id = w.Id AND w.IsActive = 1
END
GO
/****** Object:  StoredProcedure [wf].[procUpdateApproveUserLevel]    Script Date: 28.04.2026 10:44:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [wf].[procUpdateApproveUserLevel]
  @wfId int,
  @fromLevel int
AS
BEGIN
  UPDATE wf.ApproveUser SET [Level] = [Level] - 1 WHERE Workflow_id = @wfId AND [Level] >= @fromLevel
END
GO
USE [master]
GO
ALTER DATABASE [Apollo_HelpDesk] SET  READ_WRITE 
GO
