# MSSQL Design — Komplexní průvodce pro Apollo projekty

> Zpracováno na základě analýzy `ApolloHelpdesk.sql` a `ApolloSmartFleet.sql`  
> Datum: 2026-04-28

---

## Executive Summary

Tento dokument pokrývá všechna klíčová témata návrhu MSSQL databáze pro systémy Apollo — od konfigurace databáze, přes schémata a naming konvence, indexy, dědičnost, EF Core integraci, až po konkrétní doporučení vycházející přímo ze stávajícího kódu. SmartFleet je modernější databáze (compatibility level 140, READ_COMMITTED_SNAPSHOT ON, EF Migrations), zatímco HelpDesk nese znaky starší architektury (level 100, AUTO_SHRINK ON) a vyžaduje modernizaci.

---

## 1. Konfigurace databáze

### 1.1 Comparison: HelpDesk vs SmartFleet

| Nastavení | ApolloHelpdesk | ApolloSmartFleet | Doporučení |
|---|---|---|---|
| `COMPATIBILITY_LEVEL` | **100** (SQL 2008!) | **140** (SQL 2017) | Zvýšit HD na **140** (max pro SQL 2017) |
| `AUTO_SHRINK` | **ON** ⚠️ | OFF ✅ | Vypnout HD! |
| `AUTO_CLOSE` | OFF ✅ | OFF ✅ | OK |
| `READ_COMMITTED_SNAPSHOT` | **OFF** | **ON** ✅ | Zapnout HD! |
| `PAGE_VERIFY` | TORN_PAGE_DETECTION | **CHECKSUM** ✅ | Upgradovat HD |
| `RECOVERY` | FULL ✅ | FULL ✅ | OK |
| `TARGET_RECOVERY_TIME` | 0 (legacy) | **60 SECONDS** ✅ | Nastavit HD |
| `BROKER` | DISABLED | ENABLED | Dle potřeby |
| `FILESTREAM` | Ano (soubory) | Ne | HD specifické |
| `FULL-TEXT` | Vypnut | Vypnut | Dle potřeby |
| `QUERY_STORE` | OFF ⚠️ | OFF ⚠️ | Zapnout v prod! |

### 1.2 Kritické opravy pro HelpDesk

```sql
-- 1. Vypnout AUTO_SHRINK (fragmentuje data, způsobuje výkonnostní problémy)
ALTER DATABASE [Apollo_HelpDesk] SET AUTO_SHRINK OFF;

-- 2. Zapnout RCSI (optimistická souběžnost, eliminuje většinu blokování čtení)
-- ⚠️  Provádět v maintenance window — vyžaduje krátce exkluzivní přístup k DB.
--     Zvyšuje využití tempdb (verzování řádků). Monitorovat tempdb po zapnutí.
ALTER DATABASE [Apollo_HelpDesk] SET READ_COMMITTED_SNAPSHOT ON;

-- 3. Zvýšit compatibility level (max pro SQL Server 2017 je 140; pro 150 nutný upgrade na SQL 2019+)
ALTER DATABASE [Apollo_HelpDesk] SET COMPATIBILITY_LEVEL = 140;

-- 4. Lepší page verification (detekuje více typů poškození)
ALTER DATABASE [Apollo_HelpDesk] SET PAGE_VERIFY CHECKSUM;

-- 5. Zapnout Query Store (sledování výkonu dotazů)
ALTER DATABASE [Apollo_HelpDesk] SET QUERY_STORE = ON
WITH (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO
);

-- 6. Modern target recovery time
ALTER DATABASE [Apollo_HelpDesk] SET TARGET_RECOVERY_TIME = 60 SECONDS;
```

### 1.3 Doporučená SmartFleet konfigurace (jako vzor)

```sql
-- SmartFleet má správně nastaveny:
ALTER DATABASE [Apollo_SmartFleet] SET AUTO_SHRINK OFF;
ALTER DATABASE [Apollo_SmartFleet] SET READ_COMMITTED_SNAPSHOT ON;  -- klíčové!
ALTER DATABASE [Apollo_SmartFleet] SET PAGE_VERIFY CHECKSUM;
ALTER DATABASE [Apollo_SmartFleet] SET TARGET_RECOVERY_TIME = 60 SECONDS;
```

> **Proč READ_COMMITTED_SNAPSHOT?** Bez RCSI každé čtení (`SELECT`) blokuje nebo je blokováno souběžnými zápisy. S RCSI čtení vždy vidí poslední committed verzi bez blokování zápisu. To je zásadní pro EF Core aplikace.

---

## 2. Schémata — doménová organizace

### 2.1 ApolloHelpdesk schémata

```
Apollo_HelpDesk
├── dbo          – infrastruktura: Customer (tenant), User+Identity, Device, Message, File
├── helpdesk     – ticketing: Ticket, Project, Category, WatchDog, ServiceList
├── hr           – docházka: Activity hierarchie (Work, Holiday, Illness...)
├── frm          – formuláře: Form, FormInstance, TaskGroup
├── acc          – fakturace: HourlyRate, CustomerInvoice
├── crm          – CRM: Session, Ticket (jiný od helpdesk!), State
├── cfg          – konfigurace: BlackList, OutOfOffice, Theme
└── wf           – workflow (reserved/future)
```

### 2.2 ApolloSmartFleet schémata

```
Apollo_SmartFleet
├── dbo          – infrastruktura: Instance (tenant), User+Identity, Manufacturer, Route, WorkerJob
├── data         – doménová data: Address, Depot, Outlet, Vehicle, Driver, Order, Delivery
├── plan         – plánování: PlanVersion, Plan, Route, Step, VehicleDay, DeliveryDay
└── track        – GPS tracking: Tracker, Tracking, VehicleTracker
```

### 2.3 Vytvoření schémat

```sql
-- HelpDesk schémata
CREATE SCHEMA [helpdesk];
CREATE SCHEMA [hr];
CREATE SCHEMA [frm];
CREATE SCHEMA [acc];
CREATE SCHEMA [crm];
CREATE SCHEMA [cfg];

-- SmartFleet schémata
CREATE SCHEMA [data];
CREATE SCHEMA [plan];
CREATE SCHEMA [track];
```

> **Best practice**: Schéma = doménová bounded context. Tabulky stejné domény patří do jednoho schématu. Cross-schema FK jsou povoleny, ale měly by být vědomé a zdokumentované.

---

## 3. Naming konvence

### 3.1 Standardní konvence (ze stávajících databází)

| Prvek | Konvence | Příklad | Poznámka |
|---|---|---|---|
| Tabulky | PascalCase | `TicketStatus`, `VehicleDay` | Singulár |
| Sloupce | PascalCase | `FirstName`, `ChangeDateSys` | — |
| Primární klíč | `Id` INT IDENTITY(1,1) | `[Id] [int] IDENTITY(1,1)` | Vždy `Id`, ne `TableId` |
| Cizí klíč | `{Tabulka}_Id` | `Customer_Id`, `Ticket_Id` | Podtržítko odděluje tabulku od Id |
| Boolean sloupce | prefix `Is` | `IsActive`, `IsGroup`, `IsHalfDay` | Vždy bit, ne int |
| Platnostní sloupce | `ValidFrom` / `ValidTo` | `ValidFrom datetime NOT NULL` | nullable ValidTo = aktuálně platný |
| Datetime | `datetime2` / `date` / `time` | `datetime2(0)`, `date`, `time(7)` | Nikdy starý `datetime` |
| Index | `IX_{Table}_{Column}` | `IX_Vehicle_Instance_Id` | — |
| Unique index | `UX_{Table}_{Column}` | `UX_User_Login` | nebo `IX_` s UNIQUE |
| PK constraint | `PK_{TableName}` | `PK_Vehicle`, `PK_Ticket` | — |
| FK constraint | `FK_{Table}_{RefTable}_{Column}` | `FK_Depot_Address_Id` | ze SmartFleet |
| Junction tabulky | Konkatenace bez oddělovače | `CustomerCategory`, `DepotVehicle` | Abecedně nebo logicky |
| Views | prefix `v` + název | `vProject`, `vTicketSummary` | — |
| Uložené procedury | `{schema}.{Akce}{Entita}` | `plan.CreatePlanVersion` | — |
| Funkce | `{schema}.{fce/get}{Název}` | `hr.fceSelectAttendance` | nebo `Get...` |
| Sequences | `{schema}.{Entita}IdSequence` | `hr.ActivityIdSequence` | pro TPC |

### 3.2 Ukázkové CREATE TABLE

```sql
CREATE TABLE [helpdesk].[Ticket](
    [Id]                    [int]           IDENTITY(1,1)   NOT NULL,
    [Customer_Id]           [int]                           NOT NULL,
    [User_Id]               [int]                           NULL,
    [Title]                 [nvarchar](300)                 NOT NULL,
    [Category_Id]           [int]                           NULL,
    [StatusTicketLast_Id]   [int]                           NULL,
    [IsActive]              [bit]                           NOT NULL    DEFAULT(1),
    [CreatedAt]             [datetime2](0)                  NOT NULL    DEFAULT(SYSUTCDATETIME()),
    CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED ([Id] ASC)
        WITH (FILLFACTOR = 90)
);

CREATE INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket] ([Customer_Id]);
CREATE INDEX [IX_Ticket_StatusTicketLast_Id] ON [helpdesk].[Ticket] ([StatusTicketLast_Id]);
```

---

## 4. Datové typy — doporučení

### 4.1 Standardní mapování

| SQL typ | Použití | Nikdy nepoužívat |
|---|---|---|
| `nvarchar(n)` | Textové řetězce (nový design) | `varchar` pro uživatelský text |
| `varchar(n)` | Kódy, systémové hodnoty (ASCII) | pro multilingual text |
| `int` | Primární a cizí klíče, čítače | `bigint` pokud nepotřeba |
| `bigint` | IMEI, velká čísla (track.Tracker) | zbytečně pro malé číselníky |
| `bit` | Boolean hodnoty | `int` pro bool! |
| `datetime2(0)` | Přesné časové značky | starý `datetime` |
| `date` | Pouze datum (bez času) | `datetime2` pokud nepotřeba čas |
| `time(7)` | Pouze čas | `varchar` pro čas! |
| `decimal(p,s)` | Peněžní hodnoty, podíly | `float` pro peníze! |
| `money` | Peněžní hodnoty (starší kód) | preferovat `decimal(18,4)` |
| `real` / `float` | Fyzikální hodnoty (vzdálenosti, váhy) | pro peníze |
| `geography` | GPS souřadnice | `varchar` pro koordináty! |
| `uniqueidentifier` | UUID klíče (WorkerJob, File) | jako PK u výkonnostně kritických tabulek |
| `nvarchar(max)` | Dlouhé texty, JSON | jako typ pro krátké texty |
| `xml` | XML data (TextResources, GpsRouteXML) | zvážit přechod na `nvarchar(max)` + JSON |
| `timestamp` / `rowversion` | Optimistická souběžnost | pro datetime! |
| `varbinary(max) FILESTREAM` | Velké binární soubory | pro malé binárky |

### 4.2 Konkrétní příklady z databází

```sql
-- GPS koordináty (SmartFleet, správně)
[Location] [geography] NULL

-- Tracker IMEI (big int, not identity)
[IMEI] [bigint] NOT NULL

-- WorkerJob ID (uniqueidentifier s default)
[Id] [uniqueidentifier] NOT NULL DEFAULT(NEWID())

-- Computed column (persisted = uložen fyzicky, rychlé čtení)
-- ⚠️  Computed columns nepodporují NOT NULL explicitně — nulovost je odvozena z výrazu.
--     Pokud výraz nikdy nevrátí NULL, SQL Server ji označí NOT NULL automaticky.
[SolutionTimeWork] AS (ISNULL([SolutionTime]-[SolutionTimeTransport], 0)) PERSISTED

-- RowVersion pro optimistickou souběžnost
[Version] [timestamp] NOT NULL  -- nebo [rowversion]

-- Platnostní pattern
[ValidFrom] [datetime2](0) NOT NULL,
[ValidTo]   [datetime2](0) NULL  -- NULL = platí dodnes
```

---

## 5. Indexy

### 5.1 Základní pravidla indexování

```sql
-- 1. Clustered index: vždy na PK (výchozí u PRIMARY KEY CLUSTERED)
-- 2. Nonclustered index: na každý FK sloupec
-- 3. Covering index: přidat INCLUDE pro časté dotazy
-- 4. Filtered index: WHERE podmínka pro specifické dotazy
-- 5. FILLFACTOR: 70-90 pro tabulky s vysokou mírou INSERT/UPDATE
```

### 5.2 Příklady indexů ze SmartFleet

```sql
-- Jednoduchý FK index
CREATE NONCLUSTERED INDEX [IX_Vehicle_Instance_Id] ON [data].[Vehicle]
    ([Instance_Id] ASC);

-- Kompozitní index (tracking queries)
CREATE NONCLUSTERED INDEX [IX_Tracking_Vehicle_Id_Tracker_IMEI_TrackingDateUtc] 
ON [track].[Tracking]
(
    [Vehicle_Id]        ASC,
    [Tracker_IMEI]      ASC,
    [TrackingDateUtc]   ASC
);

-- Covering index s INCLUDE (optimalizace pro plánování)
CREATE NONCLUSTERED INDEX [IX_OutletDayBinaryConstraint_PlanVersion_Id_IsValid] 
ON [plan].[OutletDayBinaryConstraint]
(
    [PlanVersion_Id]    ASC,
    [IsValid]           ASC
)
INCLUDE ([Outlet_Id], [BinaryConstraint_Id]);  -- zabraňuje key lookup

-- Filtered unique index (Identity)
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[User]
    ([NormalizedUserName] ASC)
WHERE ([NormalizedUserName] IS NOT NULL);  -- ignoruje NULL hodnoty
```

### 5.3 Doporučené indexy pro HelpDesk (chybějící)

```sql
-- Nejčastější dotaz: tickety zákazníka
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id_StatusTicketLast_Id]
ON [helpdesk].[Ticket] ([Customer_Id] ASC)
INCLUDE ([StatusTicketLast_Id], [Title], [IsActive]);

-- Timeline ticketu
CREATE NONCLUSTERED INDEX [IX_TicketStatus_Ticket_Id]
ON [helpdesk].[TicketStatus] ([Ticket_Id] ASC, [ChangeDateSys] DESC);

-- Docházkový přehled — po TPC migraci indexujeme přímo na concrete tabulky (ne hr.Activity)
CREATE NONCLUSTERED INDEX [IX_Work_User_Id_Date]
ON [hr].[Work] ([User_Id] ASC, [Date] DESC);
-- (Analogicky pro Holiday, Illness, WorkShop, SickDay, Doctor)

-- Výkazy práce
CREATE NONCLUSTERED INDEX [IX_WorkDetail_Work_Id_Project_Id]
ON [hr].[WorkDetail] ([Work_Id] ASC, [Project_Id] ASC)
INCLUDE ([SolutionTime], [Customer_Id]);
```

### 5.4 Index maintenance

```sql
-- Zjistit fragmentaci
SELECT 
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 5
    AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Rebuild vs Reorganize pravidlo:
-- < 30% fragmentace → REORGANIZE (online, nízká zátěž)
-- > 30% fragmentace → REBUILD (vyšší zátěž, ale kompletní)
ALTER INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket] REBUILD;
ALTER INDEX [IX_Tracking_Tracker_IMEI] ON [track].[Tracking] REORGANIZE;
```

---

## 6. Dědičnostní vzory (Inheritance)

### 6.1 Přehled vzorů

| Vzor | SQL struktura | EF Core | Výhody | Nevýhody |
|---|---|---|---|---|
| **TPH** (Table Per Hierarchy) | 1 tabulka, diskriminátor | `UseTphMappingStrategy()` | Rychlý SELECT, jednoduchá struktura | NULL sloupce pro jiné typy |
| **TPT** (Table Per Type) | Bázová tabulka + JOIN pro každý typ | `UseTptMappingStrategy()` | Normalizace, FK lze sdílet | Pomalý (JOIN při každém dotazu) |
| **TPC** (Table Per Concrete) | Samostatná tabulka pro každý typ, vše duplikováno | `UseTpcMappingStrategy()` | Rychlé dotazy na concrete typ (žádné JOINy) | Dotazy přes bázi (polymorfní) = `UNION ALL`; duplikace sloupců; složité ID |

### 6.2 hr.Activity → TPC (doporučeno)

**Stávající SQL (TPT):**
```sql
-- Bázová tabulka
CREATE TABLE [hr].[Activity](
    [Id]                    [int]   IDENTITY(1,1) NOT NULL,
    [User_Id]               [int]   NOT NULL,
    [Date]                  [date]  NOT NULL,
    [SysDate]               [datetime2](0) NOT NULL,
    [IsClosed]              [bit]   NOT NULL,
    [Note]                  [varchar](max) NULL,
    [ActivityTemplate_Id]   [int]   NULL,
    CONSTRAINT [PK_Activity] PRIMARY KEY ([Id])
);

-- Odvozená tabulka (Activity_Id = PK + FK)
CREATE TABLE [hr].[Work](
    [Activity_Id]   [int]   NOT NULL,   -- PK a FK zároveň
    [From]          [time]  NOT NULL,
    [To]            [time]  NULL,
    [IsHomeOffice]  [bit]   NOT NULL,
    [Department_Id] [int]   NULL,
    CONSTRAINT [PK_Work] PRIMARY KEY ([Activity_Id]),
    CONSTRAINT [FK_Work_Activity] FOREIGN KEY ([Activity_Id]) REFERENCES [hr].[Activity]([Id])
);
```

**Nový SQL design (TPC) — každá tabulka je samostatná:**

```sql
-- Sequence pro globálně unikátní ID přes všechny TPC tabulky
CREATE SEQUENCE [hr].[ActivityIdSequence]
    AS INT
    START WITH 1
    INCREMENT BY 50  -- HiLo blok pro EF Core
    NO MAXVALUE;

-- hr.Work (obsahuje VŠECHNY sloupce Activity + vlastní)
CREATE TABLE [hr].[Work](
    [Id]                    [int]           NOT NULL    DEFAULT(NEXT VALUE FOR [hr].[ActivityIdSequence]),
    [User_Id]               [int]           NOT NULL,
    [Date]                  [date]          NOT NULL,
    [SysDate]               [datetime2](0)  NOT NULL,
    [IsClosed]              [bit]           NOT NULL    DEFAULT(0),
    [Note]                  [nvarchar](max) NULL,
    [ActivityTemplate_Id]   [int]           NULL,
    -- Work-specific
    [From]                  [time](0)       NOT NULL,
    [To]                    [time](0)       NULL,
    [IsHomeOffice]          [bit]           NOT NULL    DEFAULT(0),
    [Department_Id]         [int]           NULL,
    CONSTRAINT [PK_Work] PRIMARY KEY ([Id]),
    -- ⚠️  TPC: každá concrete tabulka musí mít vlastní FK constraints (nejsou zděděny)
    CONSTRAINT [FK_Work_User_Id]                FOREIGN KEY ([User_Id])               REFERENCES [dbo].[User]([Id]),
    CONSTRAINT [FK_Work_ActivityTemplate_Id]    FOREIGN KEY ([ActivityTemplate_Id])    REFERENCES [hr].[ActivityTemplate]([Id]),
    CONSTRAINT [FK_Work_Department_Id]          FOREIGN KEY ([Department_Id])          REFERENCES [hr].[Department]([Id])
);
CREATE NONCLUSTERED INDEX [IX_Work_User_Id_Date]         ON [hr].[Work] ([User_Id] ASC, [Date] DESC);
CREATE NONCLUSTERED INDEX [IX_Work_ActivityTemplate_Id]  ON [hr].[Work] ([ActivityTemplate_Id] ASC);
CREATE NONCLUSTERED INDEX [IX_Work_Department_Id]        ON [hr].[Work] ([Department_Id] ASC);

-- hr.Holiday (obsahuje VŠECHNY sloupce Activity + vlastní)
CREATE TABLE [hr].[Holiday](
    [Id]                    [int]           NOT NULL    DEFAULT(NEXT VALUE FOR [hr].[ActivityIdSequence]),
    [User_Id]               [int]           NOT NULL,
    [Date]                  [date]          NOT NULL,
    [SysDate]               [datetime2](0)  NOT NULL,
    [IsClosed]              [bit]           NOT NULL    DEFAULT(0),
    [Note]                  [nvarchar](max) NULL,
    [ActivityTemplate_Id]   [int]           NULL,
    -- Holiday-specific
    [IsHalfDay]             [bit]           NOT NULL    DEFAULT(0),
    [Hours]                 [decimal](4,1)  NOT NULL,
    CONSTRAINT [PK_Holiday] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Holiday_User_Id]             FOREIGN KEY ([User_Id])             REFERENCES [dbo].[User]([Id]),
    CONSTRAINT [FK_Holiday_ActivityTemplate_Id] FOREIGN KEY ([ActivityTemplate_Id]) REFERENCES [hr].[ActivityTemplate]([Id])
);
CREATE NONCLUSTERED INDEX [IX_Holiday_User_Id_Date]        ON [hr].[Holiday] ([User_Id] ASC, [Date] DESC);
CREATE NONCLUSTERED INDEX [IX_Holiday_ActivityTemplate_Id] ON [hr].[Holiday] ([ActivityTemplate_Id] ASC);

-- hr.Illness (žádné extra sloupce — jen sdílené)
CREATE TABLE [hr].[Illness](
    [Id]                    [int]           NOT NULL    DEFAULT(NEXT VALUE FOR [hr].[ActivityIdSequence]),
    [User_Id]               [int]           NOT NULL,
    [Date]                  [date]          NOT NULL,
    [SysDate]               [datetime2](0)  NOT NULL,
    [IsClosed]              [bit]           NOT NULL    DEFAULT(0),
    [Note]                  [nvarchar](max) NULL,
    [ActivityTemplate_Id]   [int]           NULL,
    CONSTRAINT [PK_Illness] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Illness_User_Id]             FOREIGN KEY ([User_Id])             REFERENCES [dbo].[User]([Id]),
    CONSTRAINT [FK_Illness_ActivityTemplate_Id] FOREIGN KEY ([ActivityTemplate_Id]) REFERENCES [hr].[ActivityTemplate]([Id])
);
CREATE NONCLUSTERED INDEX [IX_Illness_User_Id_Date]        ON [hr].[Illness] ([User_Id] ASC, [Date] DESC);
CREATE NONCLUSTERED INDEX [IX_Illness_ActivityTemplate_Id] ON [hr].[Illness] ([ActivityTemplate_Id] ASC);

-- Analogicky: hr.WorkShop, hr.SickDay, hr.Doctor (každá se stejnými FK + indexy)
```

**EF Core konfigurace TPC:**
```csharp
public abstract class Activity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateOnly Date { get; set; }
    public DateTime SysDate { get; set; }
    public bool IsClosed { get; set; }
    public string? Note { get; set; }
    public int? ActivityTemplateId { get; set; }
}

public class Work : Activity
{
    public TimeOnly From { get; set; }
    public TimeOnly? To { get; set; }
    public bool IsHomeOffice { get; set; }
    public int? DepartmentId { get; set; }
    public ICollection<WorkDetail> WorkDetails { get; set; } = [];
}

// DbContext konfigurace
// ⚠️  Kvůli legacy názvu sloupců (User_Id vs UserId) je nutné explicitní HasColumnName
modelBuilder.Entity<Activity>(b => {
    b.UseTpcMappingStrategy();
    b.Property(a => a.Id).UseHiLo("ActivityIdSequence", "hr");
    b.Property(a => a.UserId).HasColumnName("User_Id");
    b.Property(a => a.ActivityTemplateId).HasColumnName("ActivityTemplate_Id");
});
modelBuilder.Entity<Work>(b => {
    b.ToTable("Work", "hr");
    b.Property(w => w.DepartmentId).HasColumnName("Department_Id");
    // FK constraints
    b.HasOne<User>().WithMany().HasForeignKey(w => w.UserId).OnDelete(DeleteBehavior.Restrict);
    b.HasIndex(w => w.UserId).HasDatabaseName("IX_Work_User_Id");
    b.HasIndex(w => w.Date).HasDatabaseName("IX_Work_Date");
});
modelBuilder.Entity<Holiday>().ToTable("Holiday", "hr");
modelBuilder.Entity<Illness>().ToTable("Illness", "hr");
modelBuilder.Entity<WorkShop>().ToTable("WorkShop", "hr");
modelBuilder.Entity<SickDay>().ToTable("SickDay", "hr");
modelBuilder.Entity<Doctor>().ToTable("Doctor", "hr");
```

### 6.3 dbo.Message → TPC (doporučeno)

```sql
CREATE SEQUENCE [dbo].[MessageIdSequence]
    AS INT START WITH 1 INCREMENT BY 50 NO MAXVALUE;

CREATE TABLE [dbo].[MailMessage](
    [Id]            [int]           NOT NULL    DEFAULT(NEXT VALUE FOR [dbo].[MessageIdSequence]),
    [Date]          [datetime2](0)  NOT NULL,
    [IsSend]        [bit]           NULL,
    [ErrorMessage]  [nvarchar](255) NULL,
    [TextMessage]   [nvarchar](max) NOT NULL,
    -- Mail-specific
    [Subject]       [nvarchar](300) NOT NULL,
    [AlternateText] [nvarchar](max) NOT NULL,
    CONSTRAINT [PK_MailMessage] PRIMARY KEY ([Id])
);

CREATE TABLE [dbo].[SmsMessage](
    [Id]            [int]           NOT NULL    DEFAULT(NEXT VALUE FOR [dbo].[MessageIdSequence]),
    [Date]          [datetime2](0)  NOT NULL,
    [IsSend]        [bit]           NULL,
    [ErrorMessage]  [nvarchar](255) NULL,
    [TextMessage]   [nvarchar](max) NOT NULL,
    CONSTRAINT [PK_SmsMessage] PRIMARY KEY ([Id])
);
```

### 6.4 data.Address / Depot / Outlet → TPT (zachovat)

Depot a Outlet jsou FK target z jiných tabulek (`plan.Step.AddressStart_Id`, `dbo.Route`). TPT je zde správnou volbou.

```sql
-- Bázová tabulka
CREATE TABLE [data].[Address](
    [Id]        [int]           IDENTITY(1,1)   NOT NULL,
    [Code]      [nvarchar](10)                  NOT NULL,
    [Name]      [nvarchar](100)                 NOT NULL,
    [Street]    [nvarchar](100)                 NOT NULL,
    [ZIPCode]   [nvarchar](5)                   NOT NULL,
    [City]      [nvarchar](100)                 NOT NULL,
    [Location]  [geography]                     NULL,
    CONSTRAINT [PK_Address] PRIMARY KEY ([Id])
);

-- Odvozené tabulky — Id NENÍ IDENTITY, přebírá z Address
CREATE TABLE [data].[Depot](
    [Id]            [int]   NOT NULL,  -- NOT IDENTITY! FK na Address
    [Instance_Id]   [int]   NOT NULL,
    CONSTRAINT [PK_Depot]   PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Depot_Address_Id] FOREIGN KEY ([Id]) REFERENCES [data].[Address]([Id]) ON DELETE CASCADE
);

CREATE TABLE [data].[Outlet](
    [Id]            [int]           NOT NULL,  -- NOT IDENTITY! FK na Address
    [Customer_Id]   [int]           NOT NULL,
    [ExternalId]    [nvarchar](50)  NULL,
    [IC]            [nvarchar](8)   NULL,
    CONSTRAINT [PK_Outlet]  PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Outlet_Address_Id] FOREIGN KEY ([Id]) REFERENCES [data].[Address]([Id]) ON DELETE CASCADE
);
```

**EF Core konfigurace TPT:**
```csharp
modelBuilder.Entity<Address>().ToTable("Address", "data");
modelBuilder.Entity<Depot>()
    .ToTable("Depot", "data")
    .Property(d => d.Id).ValueGeneratedNever();  // NOT IDENTITY
modelBuilder.Entity<Outlet>()
    .ToTable("Outlet", "data")
    .Property(o => o.Id).ValueGeneratedNever();
```

### 6.5 dbo.Customer — doménová rozšíření (1:1 relace, NE dědičnost)

```sql
-- HelpDesk rozšíření zákazníka (Customer_Id je PK i FK)
CREATE TABLE [helpdesk].[Customer](
    [Customer_Id]               [int]   NOT NULL,
    [TrimSms]                   [bit]   NOT NULL,
    [HtmlMail]                  [bit]   NOT NULL,
    [IsCategoryRequired]        [bit]   NOT NULL,
    -- ...
    CONSTRAINT [PK_Customer] PRIMARY KEY ([Customer_Id]),
    CONSTRAINT [FK_HelpdeskCustomer_Customer] FOREIGN KEY ([Customer_Id]) REFERENCES [dbo].[Customer]([Id])
);
```

**EF Core — 1:1 navigace (NE UseTpcMappingStrategy):**
```csharp
public class Customer {
    public int Id { get; set; }
    // Doménová rozšíření jako 1:1 owned/related entities
    public HelpdeskCustomer? HelpdeskSettings { get; set; }
    public AccountingCustomer? AccountingSettings { get; set; }
    public CrmCustomer? CrmSettings { get; set; }
    public FormsCustomer? FormsSettings { get; set; }
}

modelBuilder.Entity<Customer>()
    .HasOne(c => c.HelpdeskSettings)
    .WithOne()
    .HasForeignKey<HelpdeskCustomer>(h => h.CustomerId);
```

### 6.6 helpdesk.Project — TPH s diskriminátorem

```sql
CREATE TABLE [helpdesk].[Project](
    [Id]            [int]   IDENTITY(1,1)   NOT NULL,
    [Customer_Id]   [int]                   NOT NULL,
    [Project_Id]    [int]                   NULL,       -- self-reference (parent)
    [ProjectType_Id][char](1)               NOT NULL,   -- P=Project, O=Order, I=Item, S=Service, C=Continue
    [Name]          [varchar](100)          NOT NULL,
    -- Computed columns jako computed properties v EF
    [IsForHelpdesk]  AS (CASE WHEN [ProjectType_id]='P' THEN CAST(1 as bit) ELSE CAST(0 as bit) END) PERSISTED,
    [IsForTimeSheet] AS (CASE WHEN [ProjectType_id] IN ('I','O','S','C') THEN CAST(1 as bit) ELSE CAST(0 as bit) END) PERSISTED,
    [Order]          AS (ISNULL([Project_id],[Id])*(10000)+ISNULL([Project_id],0)) PERSISTED,
    CONSTRAINT [PK_Project] PRIMARY KEY ([Id])
);
```

**EF Core TPH s diskriminátorem:**
```csharp
public abstract class Project {
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public int? ParentProjectId { get; set; }
    public string Name { get; set; }
}
public class HelpDeskProject : Project { } // Type = 'P'
public class ServiceProject : Project { }   // Type = 'S'
public class ContinuationProject : Project {} // Type = 'C'
public class Order : Project { }            // Type = 'O'
public class ProjectItem : Project { }      // Type = 'I'

// ⚠️  Všechny diskriminátorové hodnoty MUSÍ být namapovány (P, O, I, S, C).
//     Jinak EF Core shodí výjimku na neznámý diskriminátor při materializaci.
modelBuilder.Entity<Project>(b => {
    b.Property(p => p.CustomerId).HasColumnName("Customer_Id");
    b.Property(p => p.ParentProjectId).HasColumnName("Project_Id");
    b.HasDiscriminator<char>("ProjectType_Id")
        .HasValue<HelpDeskProject>('P')
        .HasValue<Order>('O')
        .HasValue<ProjectItem>('I')
        .HasValue<ServiceProject>('S')
        .HasValue<ContinuationProject>('C');
});
```

---

## 7. ASP.NET Identity integrace

### 7.1 HelpDesk — sloučená tabulka (TPH nad IdentityUser)

```sql
CREATE TABLE [dbo].[User](
    [Id]                    [int]           IDENTITY(1,1)   NOT NULL,
    -- Aplikační sloupce
    [Customer_Id]           [int]                           NOT NULL,
    [FirstName]             [varchar](50)                   NOT NULL,
    [LastName]              [varchar](150)                  NOT NULL,
    [Login]                 [varchar](150)                  NOT NULL,
    [IsGroup]               [bit]                           NOT NULL,
    [IsActive]              [bit]                           NOT NULL,
    [IsRoot]                [bit]                           NOT NULL,
    [Version]               [timestamp]                     NOT NULL,  -- RowVersion
    -- ASP.NET Identity sloupce
    [NormalizedUserName]    [nvarchar](256)                 NULL,
    [PasswordHash]          [nvarchar](max)                 NULL,
    [SecurityStamp]         [nvarchar](max)                 NULL,
    [ConcurrencyStamp]      [nvarchar](max)                 NULL,
    [LockoutEnd]            [datetimeoffset](7)             NULL,
    [LockoutEnabled]        [bit]                           NOT NULL,
    [AccessFailedCount]     [int]                           NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY ([Id]) WITH (FILLFACTOR = 90)
);
```

**EF Core:**
```csharp
public class ApplicationUser : IdentityUser<int>
{
    public int CustomerId { get; set; }
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    // ⚠️  Login slouží jako aplikační přihlašovací jméno (může být doménové jméno nebo jiné).
    //     Identity framework používá UserName + NormalizedUserName pro autentizaci.
    //     Pokud se Login rovná UserName, naplnit obě pole při registraci:
    //     user.UserName = user.Login = loginValue;
    public string Login { get; set; } = "";
    public bool IsGroup { get; set; }
    public bool IsActive { get; set; }
    public bool IsRoot { get; set; }
    [Timestamp]
    public byte[] Version { get; set; } = [];  // timestamp → byte[]
}

// DbContext: namapovat na existující tabulku a legacy názvy sloupců
modelBuilder.Entity<ApplicationUser>(b => {
    b.ToTable("User", "dbo");
    b.Property(u => u.CustomerId).HasColumnName("Customer_Id");
});

// Rozšíření UserRole o Customer_Id (tenant-scoped role)
public class ApplicationUserRole : IdentityUserRole<int>
{
    public int? CustomerId { get; set; }
}
```

### 7.2 SmartFleet — čistý Identity (doporučovaný vzor)

```sql
CREATE TABLE [dbo].[User](
    [Id]        [nvarchar](450) NOT NULL,  -- string Id (GUID)
    [IsActive]  [bit]           NOT NULL    DEFAULT(1),
    [Language]  [nvarchar](10)  NOT NULL    DEFAULT(N'cs-CZ'),
    [FirstName] [nvarchar](50)  NOT NULL    DEFAULT(N''),
    [LastName]  [nvarchar](50)  NOT NULL    DEFAULT(N''),
    -- Standard Identity columns...
    CONSTRAINT [PK_User] PRIMARY KEY ([Id])
);
```

---

## 8. Geolokace (Geography)

### 8.1 SQL Server spatial typy

```sql
-- Uložení GPS bodu
[Location] [geography] NULL

-- Výpočet vzdálenosti v metrech (STDistance)
SELECT 
    a1.Name as From,
    a2.Name as To,
    a1.[Location].STDistance(a2.[Location]) as DistanceMeters
FROM [data].[Address] a1
    CROSS JOIN [data].[Address] a2
WHERE a1.Id != a2.Id;

-- Konverze z X,Y,Z souřadnic (SmartFleet pattern)
CREATE FUNCTION [track].[GetLocation](
    @LocationX  FLOAT NULL,
    @LocationY  FLOAT NULL,
    @LocationZ  FLOAT NULL
)
RETURNS GEOGRAPHY AS
BEGIN
    -- SRID 4326 = WGS84 (standard GPS)
    IF @LocationX IS NOT NULL AND @LocationY IS NOT NULL AND @LocationZ IS NOT NULL
        RETURN geography::STGeomFromText(
            'POINT(' + LTRIM(STR(@LocationX,18,13)) + ' ' + LTRIM(STR(@LocationY,18,13)) + ' ' + LTRIM(STR(@LocationZ,5,1)) + ')',
            4326
        );
    IF @LocationX IS NOT NULL AND @LocationY IS NOT NULL
        RETURN geography::STGeomFromText(
            'POINT(' + LTRIM(STR(@LocationX,18,13)) + ' ' + LTRIM(STR(@LocationY,18,13)) + ')',
            4326
        );
    RETURN NULL;
END;

-- Spatial index (nutný pro STDistance výkon)
CREATE SPATIAL INDEX [SIX_Address_Location] ON [data].[Address]([Location])
USING GEOGRAPHY_GRID
WITH (GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM), CELLS_PER_OBJECT = 16);
```

**EF Core + NetTopologySuite:**
```csharp
// Program.cs
builder.Services.AddDbContext<SmartFleetDb>(o =>
    o.UseSqlServer(conn, sql => sql.UseNetTopologySuite()));

// Entity
using NetTopologySuite.Geometries;
public class Address {
    public int Id { get; set; }
    public Point? Location { get; set; }  // geography → Point (SRID 4326)
}

// Dotaz přes vzdálenost
var depot = new Point(14.4378, 50.0755) { SRID = 4326 };  // Praha
var nearbyOutlets = await db.Outlets
    .Where(o => o.Location != null && o.Location.Distance(depot) < 50000)  // 50 km
    .OrderBy(o => o.Location!.Distance(depot))
    .ToListAsync();
```

---

## 9. Speciální vzory

### 9.1 FILESTREAM (dbo.File v HelpDesk)

```sql
-- Databáze musí mít FILESTREAM filegroup
CREATE DATABASE ... FILEGROUP [FS_File] CONTAINS FILESTREAM ...

-- Tabulka s FILESTREAM sloupcem
CREATE TABLE [dbo].[File](
    [Id]            [int]               IDENTITY(1,1)   NOT NULL,
    [FileId]        [uniqueidentifier]  ROWGUIDCOL      NOT NULL    DEFAULT(NEWSEQUENTIALID()),
    [Data]          [varbinary](max)    FILESTREAM      NULL,  -- ukládáno do filesystem!
    [Name]          [nvarchar](255)                     NOT NULL,
    [ContentType]   [nvarchar](255)                     NOT NULL,
    CONSTRAINT [PK_File] PRIMARY KEY ([Id]),
    CONSTRAINT [UX_File_FileId] UNIQUE ([FileId])
) FILESTREAM_ON [FS_File];
```

**EF Core:**
```csharp
public class File {
    public int Id { get; set; }
    public Guid FileId { get; set; }
    [NotMapped]  // FILESTREAM nelze jednoduše mapovat přes EF
    public byte[]? Data { get; set; }
    public string Name { get; set; }
    public string ContentType { get; set; }
}
// Pro přístup k FILESTREAM dat: použít SqlFileStream API nebo Azure Blob Storage
```

### 9.2 Computed Columns

```sql
-- PERSISTED: výsledek uložen fyzicky, indexovatelný
-- ⚠️  Computed columns nepodporují NOT NULL explicitně — SQL Server odvozuje nulovost z výrazu.
[SolutionTimeWork] AS (ISNULL([SolutionTime]-[SolutionTimeTransport], 0)) PERSISTED

-- Project ordering (HelpDesk)
[Order] AS (ISNULL([Project_id],[Id])*(10000)+ISNULL([Project_id],0)) PERSISTED

-- Computed boolean z diskriminátoru
[IsForHelpdesk] AS (CASE WHEN [ProjectType_id]='P' THEN CAST(1 as bit) ELSE CAST(0 as bit) END) PERSISTED
```

**EF Core:**
```csharp
modelBuilder.Entity<WorkDetail>()
    .Property(w => w.SolutionTimeWork)
    .HasComputedColumnSql("ISNULL([SolutionTime]-[SolutionTimeTransport], 0)", stored: true);
// stored: true = PERSISTED
```

### 9.3 ValidFrom/ValidTo pattern (temporální platnost)

```sql
-- Pattern z SmartFleet (VehicleConfiguration, DepotVehicle, atd.)
CREATE TABLE [data].[VehicleConfiguration](
    [Id]            [int]           IDENTITY(1,1)   NOT NULL,
    [Vehicle_Id]    [int]                           NOT NULL,
    -- ...konfigurační data...
    [ValidFrom]     [datetime2](0)                  NOT NULL,
    [ValidTo]       [datetime2](0)                  NULL,  -- NULL = platí dodnes
    CONSTRAINT [PK_VehicleConfiguration] PRIMARY KEY ([Id])
);

-- Funkce pro ověření platnosti (ze SmartFleet)
CREATE FUNCTION [dbo].[IsValidDate](@Date datetime, @From datetime, @To datetime)
RETURNS bit AS
BEGIN
    RETURN IIF(@From <= @Date AND (@Date < @To OR @To IS NULL), 1, 0)
END;

-- Použití — ⚠️  Skalární UDF v WHERE způsobuje row-by-row vyhodnocování (žádný index seek).
--             Preferovat inline predikát:
SELECT * FROM [data].[VehicleConfiguration]
WHERE ValidFrom <= SYSUTCDATETIME()
  AND (ValidTo IS NULL OR ValidTo > SYSUTCDATETIME())
  AND Vehicle_Id = @VehicleId;
```

**EF Core interface:**
```csharp
public interface ITemporalValidity {
    DateTime ValidFrom { get; set; }
    DateTime? ValidTo { get; set; }
}

// Extension pro EF query
public static IQueryable<T> ValidAt<T>(this IQueryable<T> query, DateTime at)
    where T : ITemporalValidity
    => query.Where(e => e.ValidFrom <= at && (e.ValidTo == null || e.ValidTo > at));

// Použití
var config = await db.VehicleConfigurations
    .ValidAt(DateTime.UtcNow)
    .FirstAsync(c => c.VehicleId == vehicleId);
```

### 9.4 WorkerJob pattern (background jobs)

```sql
CREATE TABLE [dbo].[WorkerJob](
    [Id]            [uniqueidentifier]  NOT NULL    DEFAULT(NEWID()),
    [Status]        [nvarchar](50)      NOT NULL,   -- Pending, Running, Completed, Failed
    [DateCreated]   [datetime2](0)      NOT NULL    DEFAULT(SYSUTCDATETIME()),
    [DateStarted]   [datetime2](0)      NULL,
    [DateCompleted] [datetime2](0)      NULL,
    [Param]         [nvarchar](max)     NULL,       -- JSON vstupní parametry
    [Result]        [nvarchar](max)     NULL,       -- JSON výsledek
    CONSTRAINT [PK_WorkerJob] PRIMARY KEY ([Id])
);
```

### 9.5 Composite PK v plan.Plan

```sql
-- plan.Plan má netradiční composite PK
CREATE TABLE [plan].[Plan](
    [Version]           [int]   NOT NULL,   -- verze optimalizace
    [PlanVersion_Id]    [int]   NOT NULL,   -- FK na PlanVersion
    -- data...
    CONSTRAINT [PK_Plan] PRIMARY KEY ([Version], [PlanVersion_Id]),
    CONSTRAINT [FK_Plan_PlanVersion] FOREIGN KEY ([PlanVersion_Id]) 
        REFERENCES [plan].[PlanVersion]([Id]) ON DELETE CASCADE
);

-- plan.Route odkazuje na plan.Plan přes composite FK
CONSTRAINT [FK_Route_Plan] FOREIGN KEY ([Version], [PlanVersion_Id])
    REFERENCES [plan].[Plan] ([Version], [PlanVersion_Id]) ON DELETE CASCADE;
```

### 9.6 Self-referencing tabulky

```sql
-- Hierarchie projektů
CREATE TABLE [helpdesk].[Project](
    [Id]            [int]   IDENTITY(1,1)   NOT NULL,
    [Project_Id]    [int]                   NULL,   -- parent (NULL = kořenový projekt)
    -- ...
);

-- CTE pro procházení stromu (ze stávajícího kódu)
CREATE FUNCTION [helpdesk].[ProjectTree](@id int, @MaxHierarchyLevel int = NULL, @upDirection bit = 1)
RETURNS @t TABLE (Id int, ParentId int, HierarchyLevel int)
AS BEGIN
    WITH Tree(Id, ParentId, HierarchyLevel) AS (
        SELECT p.id, p.[Project_id], 1
        FROM helpdesk.[Project] p WHERE p.id = @id
        UNION ALL
        SELECT p.id, p.[Project_id], t.HierarchyLevel + 1
        FROM helpdesk.[Project] p
            INNER JOIN Tree t ON p.[Project_id] = t.id  -- směr dolů
    )
    INSERT INTO @t SELECT Id, ParentId, HierarchyLevel FROM Tree
        WHERE (@MaxHierarchyLevel IS NULL OR HierarchyLevel <= @MaxHierarchyLevel);
    RETURN;
END;
```

---

## 10. User Defined Functions (UDF)

### 10.1 Table-valued functions ze SmartFleet

```sql
-- Inline TVF (nejvýkonnější — jako VIEW s parametry)
CREATE FUNCTION [plan].[GetPlanRoutes](@PlanVersionId INT, @MapProviderId INT, @ObsoletionDate datetime2)
RETURNS TABLE AS RETURN
    SELECT r.*
    FROM [plan].[GetPlanMatrix](@PlanVersionId) m
        INNER JOIN dbo.[Route] r ON m.StartId = r.AddressStart_Id AND m.EndId = r.AddressEnd_Id
            AND r.MapProvider_Id = @MapProviderId;

-- Multi-statement TVF (pomalejší, ale složitější logika)
CREATE FUNCTION [plan].[GetPlanPoints](@PlanVersionId INT)
RETURNS @t TABLE (PointId int NOT NULL, IsDepot bit NOT NULL, [Location] geography NOT NULL)
AS BEGIN
    WITH points AS (
        SELECT Depot_Id as PointId, 1 as IsDepot FROM [plan].PlanVersion WHERE Id = @PlanVersionId
        UNION ALL
        SELECT Outlet_Id, 0 FROM [plan].OutletDay WHERE PlanVersion_Id = @PlanVersionId
    )
    INSERT INTO @t
    SELECT p.PointId, p.IsDepot, a.[Location]
    FROM points p INNER JOIN [data].[Address] a ON p.PointId = a.Id;
    RETURN;
END;
```

### 10.2 Scalar functions

```sql
-- Jednoduchá skalární funkce
CREATE FUNCTION [dbo].[IsValidDate](@Date datetime, @From datetime, @To datetime)
RETURNS bit AS
BEGIN
    RETURN IIF(@From <= @Date AND (@Date < @To OR @To IS NULL), 1, 0)
END;
```

> **Pozor**: Skalární funkce v WHERE klauzuli způsobují row-by-row vyhodnocování. Preferovat inline logiku nebo inline TVF. EF Core `HasDbFunction()` mapuje skalární funkce.

---

## 11. Stored Procedures

### 11.1 SmartFleet pattern (transakce + error handling)

```sql
CREATE PROCEDURE [plan].[CreatePlanVersion]
    @Instance_Id    int,
    @Depot_Id       int,
    @Date           date,
    @Name           nvarchar(100),
    @PlanVersionId  int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- ⚠️  SET XACT_ABORT ON: automaticky rollbackuje transakci při chybě, spolehlivější než ruční CATCH
    SET XACT_ABORT ON;

    BEGIN TRAN
    BEGIN TRY
        -- Kontrola existence uvnitř transakce s UPDLOCK+HOLDLOCK (eliminuje race condition)
        SELECT @PlanVersionId = p.Id
        FROM [plan].PlanVersion p WITH (UPDLOCK, HOLDLOCK)
        WHERE p.Instance_Id = @Instance_Id AND p.Depot_Id = @Depot_Id
            AND p.Name = @Name AND p.Date = @Date;

        IF (@PlanVersionId IS NULL)
        BEGIN
            INSERT INTO [plan].PlanVersion (Instance_Id, Depot_Id, [Name], [Date], Created, Modified)
            VALUES (@Instance_Id, @Depot_Id, @Name, @Date, SYSUTCDATETIME(), SYSUTCDATETIME());
            SELECT @PlanVersionId = SCOPE_IDENTITY();
        END

        -- Volání sub-procedur
        EXEC [plan].[CreatePlanVersion_DepotDay]    @PlanVersion_Id = @PlanVersionId, @Date = @Date;
        EXEC [plan].[CreatePlanVersion_VehicleDay]  @PlanVersion_Id = @PlanVersionId, @Date = @Date;

        COMMIT TRANSACTION;
        RETURN 1;
    END TRY
    BEGIN CATCH
        -- ⚠️  THROW znovu vyvolá původní chybu s plným kontextem (místo RETURN -1 bez diagnostiky)
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

---

## 12. Views

### 12.1 Standardní views

```sql
-- Schemabinding view (umožňuje indexaci)
CREATE VIEW [helpdesk].[vCustomerSummary] WITH SCHEMABINDING AS
SELECT 
    c.Customer_Id as CustomerId, 
    tsf.State_id as StateId, 
    COUNT_BIG(*) as TicketCount  -- COUNT_BIG je povinné pro indexed view
FROM helpdesk.Customer c
    INNER JOIN helpdesk.Ticket t ON c.Customer_Id = t.Customer_id
    INNER JOIN helpdesk.TicketStatus ts ON t.StatusTicketLast_id = ts.id
    INNER JOIN helpdesk.TicketStatusFull tsf ON ts.id = tsf.TicketStatus_id
GROUP BY c.Customer_Id, tsf.State_id;

-- Indexed view (materializovaný clustered index)
CREATE UNIQUE CLUSTERED INDEX [IX_vCustomerSummary] 
ON [helpdesk].[vCustomerSummary] ([CustomerId], [StateId]);
```

### 12.2 View nad TPC hierarchií (hr.vWorkDetail)

Po TPC migraci tabulka `hr.Activity` neexistuje. View musí používat `UNION ALL` přes concrete tabulky:

```sql
-- ⚠️  Po TPC přechodu hr.Activity NEEXISTUJE — view musí agregovat přes UNION ALL
CREATE VIEW [hr].[vWorkDetail] AS
SELECT wd.Id, w.User_Id, w.[Date], wd.Project_Id, wd.SolutionTime
FROM hr.WorkDetail wd
    INNER JOIN hr.Work w ON wd.Work_Id = w.Id;
-- Pokud potřebujeme všechny typy Activity (pro přehled docházky):
-- CREATE VIEW [hr].[vActivity] AS
--     SELECT Id, User_Id, [Date], IsClosed, 'Work' AS ActivityType FROM hr.Work
--     UNION ALL SELECT Id, User_Id, [Date], IsClosed, 'Holiday'  FROM hr.Holiday
--     UNION ALL SELECT Id, User_Id, [Date], IsClosed, 'Illness'  FROM hr.Illness
--     UNION ALL SELECT Id, User_Id, [Date], IsClosed, 'WorkShop' FROM hr.WorkShop
--     UNION ALL SELECT Id, User_Id, [Date], IsClosed, 'SickDay'  FROM hr.SickDay
--     UNION ALL SELECT Id, User_Id, [Date], IsClosed, 'Doctor'   FROM hr.Doctor;
```

---

## 13. Security model

### 13.1 Database users a roles (ze stávajícího kódu)

```sql
-- HelpDesk: db_owner pro aplikační uživatel (anti-pattern pro produkci!)
ALTER ROLE [db_owner] ADD MEMBER [helpdesk];

-- Doporučení: minimální oprávnění
CREATE USER [helpdesk_app] FOR LOGIN [helpdesk_app] WITH DEFAULT_SCHEMA=[dbo];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[helpdesk] TO [helpdesk_app];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[hr] TO [helpdesk_app];
GRANT EXECUTE ON SCHEMA::[helpdesk] TO [helpdesk_app];  -- stored procedures

-- Read-only uživatel pro reporting
CREATE USER [helpdeskRep] FOR LOGIN [helpdeskRep] WITH DEFAULT_SCHEMA=[dbo];
GRANT SELECT ON SCHEMA::[helpdesk] TO [helpdeskRep];
GRANT SELECT ON SCHEMA::[hr] TO [helpdeskRep];
```

### 13.2 Row-Level Security (pro multi-tenant)

```sql
-- Predikátová funkce (filtruje řádky per Customer_Id)
CREATE FUNCTION [dbo].[fn_TicketTenantFilter](@CustomerId int)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN
    SELECT 1 AS result
    WHERE @CustomerId = CAST(SESSION_CONTEXT(N'CustomerId') AS int)
        OR IS_MEMBER('db_owner') = 1;

-- Bezpečnostní politika
-- ⚠️  AFTER INSERT blokuje jen vkládání. Pro úplný tenant isolation doplnit AFTER UPDATE a BEFORE DELETE.
CREATE SECURITY POLICY [TicketTenantPolicy]
ADD FILTER PREDICATE [dbo].[fn_TicketTenantFilter]([Customer_Id])
    ON [helpdesk].[Ticket],
ADD BLOCK PREDICATE [dbo].[fn_TicketTenantFilter]([Customer_Id])
    ON [helpdesk].[Ticket] AFTER INSERT,
ADD BLOCK PREDICATE [dbo].[fn_TicketTenantFilter]([Customer_Id])
    ON [helpdesk].[Ticket] AFTER UPDATE,
ADD BLOCK PREDICATE [dbo].[fn_TicketTenantFilter]([Customer_Id])
    ON [helpdesk].[Ticket] BEFORE DELETE
WITH (STATE = ON);

-- Nastavení kontextu v aplikaci (před každým dotazem)
EXEC sp_set_session_context N'CustomerId', @CustomerId;
```

---

## 14. Anti-patterns ze stávajících databází a jejich řešení

| Anti-pattern | Kde | Doporučené řešení |
|---|---|---|
| `AUTO_SHRINK ON` | HelpDesk | `ALTER DATABASE SET AUTO_SHRINK OFF` |
| `COMPATIBILITY_LEVEL = 100` | HelpDesk | Zvýšit na **140** (max pro SQL Server 2017; 150 vyžaduje SQL 2019+) |
| `READ_COMMITTED_SNAPSHOT OFF` | HelpDesk | Zapnout RCSI |
| `db_owner` pro app user | Oba | Minimální granulární oprávnění |
| `varchar` místo `nvarchar` | HelpDesk | Standardizovat na `nvarchar` |
| `xml` místo JSON | Oba (`TextResources`, `UserFilter.Value`) | Zvážit `nvarchar(max)` + JSON |
| Smíšené `float`/`real` pro peněžní hodnoty | HelpDesk (`SolutionTime float`) | `decimal(10,2)` pro peníze |
| Chybějící indexy na FK | HelpDesk | Přidat IX_ indexy |
| `QUERY_STORE OFF` | Oba | Zapnout pro monitoring výkonu |
| `ANSI_NULLS OFF`, `ANSI_WARNINGS OFF` | Oba | Zapnout pro SQL standard |
| Skalární UDF v WHERE | HelpDesk (fceSelectDays) | Inline TVF nebo přepsat jako sadu |
| `PAGE_VERIFY TORN_PAGE_DETECTION` | HelpDesk | Upgradovat na CHECKSUM |

---

## 15. EF Core Migrations best practices

### 15.1 SmartFleet (již používá EF Migrations)

```sql
-- Existující tabulka (ze SmartFleet)
CREATE TABLE [dbo].[__EFMigrationsHistory](
    [MigrationId]    [nvarchar](150) NOT NULL,
    [ProductVersion] [nvarchar](32)  NOT NULL,
    CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
);
```

### 15.2 Doporučená migrace pro TPC hierarchii

```csharp
// Migration pro přechod z TPT na TPC (hr.Activity)
// ⚠️  Toto je vícefázová migrace. Provádět v maintenance window.
public partial class ActivityTpcMigration : Migration
{
    protected override void Up(MigrationBuilder mb)
    {
        // 1. Zjistit aktuální MAX(Id) z Activity a nastavit sequence VÝŠE než existující data
        //    (provést ručně před spuštěním migrace a dosadit správnou hodnotu)
        mb.Sql(@"
            DECLARE @maxId int = (SELECT ISNULL(MAX(Id), 0) + 100 FROM hr.Activity);
            DECLARE @sql nvarchar(500) = 
                'CREATE SEQUENCE [hr].[ActivityIdSequence] AS INT START WITH ' 
                + CAST(@maxId AS nvarchar) + ' INCREMENT BY 50 NO MAXVALUE;';
            EXEC sp_executesql @sql;
        ");

        // 2. Přidat sdílené sloupce do hr.Work JAKO NULLABLE (povinné pro tabulky s daty!)
        mb.AddColumn<int>("User_Id", "Work", schema: "hr", nullable: true);
        mb.AddColumn<DateOnly>("Date", "Work", schema: "hr", nullable: true);
        mb.AddColumn<DateTime>("SysDate", "Work", schema: "hr", nullable: true);
        mb.AddColumn<bool>("IsClosed", "Work", schema: "hr", nullable: true);
        mb.AddColumn<string>("Note", "Work", schema: "hr", nullable: true);
        mb.AddColumn<int>("ActivityTemplate_Id", "Work", schema: "hr", nullable: true);

        // 3. Migrovat data (JOIN Activity → Work)
        mb.Sql(@"
            UPDATE w SET
                w.User_Id           = a.User_Id,
                w.Date              = a.Date,
                w.SysDate           = a.SysDate,
                w.IsClosed          = a.IsClosed,
                w.Note              = a.Note,
                w.ActivityTemplate_Id = a.ActivityTemplate_Id
            FROM hr.Work w
                INNER JOIN hr.Activity a ON w.Activity_Id = a.Id;
        ");

        // 4. Teprve po naplnění dat změnit nullable → NOT NULL
        mb.AlterColumn<int>("User_Id", "Work", schema: "hr", nullable: false);
        mb.AlterColumn<DateOnly>("Date", "Work", schema: "hr", nullable: false);
        mb.AlterColumn<DateTime>("SysDate", "Work", schema: "hr", nullable: false);
        mb.AlterColumn<bool>("IsClosed", "Work", schema: "hr", nullable: false, defaultValue: false);

        // 5. Přejmenovat PK sloupec Activity_Id → Id
        mb.RenameColumn("Activity_Id", "Work", "Id", schema: "hr");

        // 6. Nastavit DEFAULT pro sequence (nové záznamy)
        mb.Sql("ALTER TABLE hr.Work ADD CONSTRAINT DF_Work_Id DEFAULT (NEXT VALUE FOR hr.ActivityIdSequence) FOR Id;");

        // 7. Přidat FK constraints a indexy
        mb.Sql("ALTER TABLE hr.Work ADD CONSTRAINT FK_Work_User_Id FOREIGN KEY (User_Id) REFERENCES dbo.[User](Id);");
        mb.Sql("CREATE NONCLUSTERED INDEX IX_Work_User_Id_Date ON hr.Work (User_Id, [Date] DESC);");

        // 8. Opakovat kroky 2-7 pro Holiday, Illness, WorkShop, SickDay, Doctor
        // (každá konkrétní tabulka je samostatná fáze migrace)

        // 9. Smazat hr.Activity tabulku AŽ POTÉ, co jsou VŠECHNY typy migrovány
        // mb.DropTable("Activity", schema: "hr");
    }
}
```

---

## 16. Shrnutí doporučení

### Priorita 1 — Kritické (HelpDesk)
1. `AUTO_SHRINK OFF`
2. `READ_COMMITTED_SNAPSHOT ON`
3. Přidat chybějící FK indexy

### Priorita 2 — Důležité
4. `COMPATIBILITY_LEVEL 140` (max pro SQL 2017)
5. `QUERY_STORE ON`
6. `PAGE_VERIFY CHECKSUM`
7. Minimalizovat db_owner přístup

### Priorita 3 — Architekturální
8. hr.Activity → TPC migrace
9. dbo.Message → TPC migrace
10. `varchar` → `nvarchar` standardizace
11. `xml` → JSON (`nvarchar(max)`) standardizace
12. Spatial index pro `geography` sloupce

---

## Footnotes

[^1]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloHelpdesk.sql:15` — `COMPATIBILITY_LEVEL = 100`
[^2]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloHelpdesk.sql:34` — `AUTO_SHRINK ON`
[^3]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloSmartFleet.sql:11` — `COMPATIBILITY_LEVEL = 140`
[^4]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloSmartFleet.sql:58` — `READ_COMMITTED_SNAPSHOT ON`
[^5]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloSmartFleet.sql:310-336` — `track.GetLocation()` funkce pro geography
[^6]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloSmartFleet.sql:382-399` — `data.Address` s geography sloupcem
[^7]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloHelpdesk.sql:584-619` — `dbo.User` sloučený s Identity
[^8]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloHelpdesk.sql:741` — computed column `SolutionTimeWork PERSISTED`
[^9]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloHelpdesk.sql:785-787` — `helpdesk.Project` computed columns
[^10]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloSmartFleet.sql:101-109` — `dbo.IsValidDate` funkce
[^11]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloSmartFleet.sql:1762-1786` — composite tracking index
[^12]: `c:\Users\nava\source\GitHub\AI\SQL-Sample\ApolloSmartFleet.sql:2234-2288` — `plan.CreatePlanVersion` stored procedure
[^13]: `c:\Users\nava\.copilot\session-state\621994c8-00a1-454c-acf0-01bbdfad75bc\research\db-analysis-ef-design.md` — kompletní analýza dědičnostních vzorů
