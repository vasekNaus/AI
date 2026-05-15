# Pravidla a instrukce pro návrh databází (MSSQL + EF Core)

> Obecný průvodce platný pro všechny nové databázové projekty.  
> Vychází z analýzy Apollo projektů a ověřených best practices.

---

## PRAVIDLO 0 — Než začneš kódovat

> **Databázový design je nejdražší věc na změnu. Udělej ho správně hned.**

Checklist před psaním prvního `CREATE TABLE`:

- [ ] Mám definované **domény** (bounded contexts)?
- [ ] Vím, kdo je **tenant** (multi-tenant nebo single)?
- [ ] Mám jasné **dědičnostní hierarchie** (IS-A vs HAS-A)?
- [ ] Mám jasné **obchodní pravidla** (nullable, unique, rozsahy)?
- [ ] Mám definované **přístupové vzory** (kdo dotazuje co a jak)?
- [ ] Vím, která data mají **platnostní rozsah** (ValidFrom/ValidTo)?
- [ ] Mám plán pro **EF Core integraci** (TPC/TPT/TPH, migrations)?

---

## 1. KONFIGURACE DATABÁZE

### 1.1 Povinná nastavení pro každou novou databázi

```sql
-- Vždy pro nové databáze (nebo opravit na stávajících):
ALTER DATABASE [MojeDB] SET AUTO_SHRINK OFF;              -- nikdy nezapínat
ALTER DATABASE [MojeDB] SET AUTO_CLOSE OFF;               -- nikdy nezapínat
ALTER DATABASE [MojeDB] SET READ_COMMITTED_SNAPSHOT ON;   -- klíčové pro EF Core
ALTER DATABASE [MojeDB] SET PAGE_VERIFY CHECKSUM;         -- detekce poškození
ALTER DATABASE [MojeDB] SET RECOVERY FULL;                -- pro prod s zálohami
ALTER DATABASE [MojeDB] SET TARGET_RECOVERY_TIME = 60 SECONDS;
ALTER DATABASE [MojeDB] SET COMPATIBILITY_LEVEL = 160;    -- SQL 2022; přizpůsob verzi

ALTER DATABASE [MojeDB] SET QUERY_STORE = ON
WITH (
    OPERATION_MODE           = READ_WRITE,
    CLEANUP_POLICY           = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    MAX_STORAGE_SIZE_MB      = 1000,
    QUERY_CAPTURE_MODE       = AUTO
);
```

### 1.2 Compatibility level dle verze SQL Server

| SQL Server verze | Max. COMPATIBILITY_LEVEL |
|---|---|
| SQL Server 2016 | 130 |
| SQL Server 2017 | **140** |
| SQL Server 2019 | 150 |
| SQL Server 2022 | **160** |
| Azure SQL | 160 |

> ⚠️ `AUTO_SHRINK ON` — nikdy. Způsobuje fragmentaci indexů a výkonnostní propady.  
> ⚠️ `READ_COMMITTED_SNAPSHOT OFF` — bez RCSI blokují SELECT a INSERT/UPDATE navzájem.

### 1.3 Filegroups pro velké projekty

```sql
-- Separace dat a indexů (výkonnostní benefit na různých discích)
ALTER DATABASE [MojeDB] ADD FILEGROUP [INDEXES];
ALTER DATABASE [MojeDB] ADD FILE (
    NAME = N'MojeDB_Indexes',
    FILENAME = N'E:\MSSQL\Indexes\MojeDB_Indexes.ndf',
    SIZE = 512MB, FILEGROWTH = 256MB
) TO FILEGROUP [INDEXES];

-- Tabulka na PRIMARY, indexy na INDEXES
CREATE TABLE ... ON [PRIMARY];
CREATE NONCLUSTERED INDEX ... ON [INDEXES];
```

---

## 2. SCHÉMATA — DOMÉNOVÁ ORGANIZACE

### 2.1 Pravidlo: 1 doména = 1 schéma

```
MojeDB
├── dbo          – infrastruktura: User, Role, Tenant, File, Log
├── {domain1}    – první bounded context (např. helpdesk, order, billing)
├── {domain2}    – druhý bounded context
└── cfg          – sdílené číselníky a konfigurace
```

**Pravidla:**
- Schéma = doménová hranice; tabulky stejné domény patří do jednoho schématu
- Cross-schema FK jsou povoleny, ale zaznamenat je v dokumentaci
- `dbo` schéma = pouze infrastruktura sdílená přes domény
- Nikdy nepoužívat `dbo` pro doménové tabulky

### 2.2 Vytváření schémat

```sql
CREATE SCHEMA [helpdesk] AUTHORIZATION [dbo];
CREATE SCHEMA [billing]  AUTHORIZATION [dbo];
CREATE SCHEMA [cfg]      AUTHORIZATION [dbo];
```

---

## 3. NAMING KONVENCE

### 3.1 Kompletní tabulka konvencí

| Prvek | Pravidlo | Příklad | Zakázáno |
|---|---|---|---|
| **Tabulky** | PascalCase, singulár | `Ticket`, `VehicleDay` | `tickets`, `tbl_Ticket` |
| **Sloupce** | PascalCase | `FirstName`, `CreatedAt` | `first_name`, `firstName` |
| **PK** | vždy `Id` INT IDENTITY(1,1) | `[Id] [int] IDENTITY(1,1) NOT NULL` | `TicketId`, `ID` |
| **FK** | `{Tabulka}_Id` | `Customer_Id`, `Ticket_Id` | `CustomerId`, `cust_id` |
| **Boolean** | prefix `Is` | `IsActive`, `IsGroup` | `Active`, `Flag` |
| **Datetime** | popisné jméno + přípona | `CreatedAt`, `ValidFrom`, `ResolvedAt` | `Date1`, `DateX` |
| **Platnostní** | `ValidFrom` / `ValidTo` | nullable `ValidTo` = stále platné | `DateFrom` |
| **Discriminator** | `{Entita}Type` nebo `{Entita}Type_Id` | `ProjectType_Id` | `type`, `kind` |
| **Soft delete** | `DeletedAt datetime2 NULL` | NULL = aktivní | `IsDeleted bit` |
| **Tenant** | `{Tenant}_Id` | `Customer_Id`, `Instance_Id` | `TenantId` |
| **PK constraint** | `PK_{Tabulka}` | `PK_Ticket` | `pk1`, `PrimaryKey` |
| **FK constraint** | `FK_{Tabulka}_{RefTabulka}_{Sloupec}` | `FK_Ticket_Customer_Id` | volně pojmenované |
| **Index** | `IX_{Tabulka}_{Sloupce}` | `IX_Ticket_Customer_Id` | `idx1` |
| **Unique index** | `UX_{Tabulka}_{Sloupce}` | `UX_User_Login` | — |
| **Views** | `v{Název}` | `vTicketSummary` | `View_Ticket` |
| **Stored proc.** | `{schema}.{Akce}{Entita}` | `billing.CreateInvoice` | `sp_`, `usp_` |
| **Funkce** | `{schema}.Get{Výsledek}` nebo `{schema}.fn{Název}` | `plan.GetPlanPoints` | `func1` |
| **Sequences** | `{schema}.{Entita}IdSequence` | `hr.ActivityIdSequence` | — |
| **Junction tabulky** | konkatenace obou entit bez oddělovače | `CustomerCategory`, `DepotVehicle` | `Customer_Category` |

### 3.2 Klíčové příklady

```sql
CREATE TABLE [helpdesk].[Ticket](
    [Id]                [int]           IDENTITY(1,1)   NOT NULL,  -- PK: vždy Id
    [Customer_Id]       [int]                           NOT NULL,  -- FK: {Tabulka}_Id
    [Title]             [nvarchar](300)                 NOT NULL,
    [IsActive]          [bit]                           NOT NULL    DEFAULT(1),   -- bool: Is prefix
    [CreatedAt]         [datetime2](0)                  NOT NULL    DEFAULT(SYSUTCDATETIME()),
    [ResolvedAt]        [datetime2](0)                  NULL,       -- NULL = nevyřešeno
    CONSTRAINT [PK_Ticket]              PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Ticket_Customer_Id]  FOREIGN KEY ([Customer_Id]) REFERENCES [dbo].[Customer]([Id])
);
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket] ([Customer_Id]);
```

---

## 4. DATOVÉ TYPY

### 4.1 Standardní mapování

| SQL typ | Kdy použít | Nikdy nepoužívat pro |
|---|---|---|
| `int` | PK, FK, čítače (do ~2 mld) | velká čísla (IMEI, hash) |
| `bigint` | IMEI, velké čítače, snowflake ID | zbytečně na malé číselníky |
| `uniqueidentifier` | GUID klíče (API, external systems) | výkonnostně kritické PK (fragmentace) |
| `nvarchar(n)` | **všechny textové řetězce** (nový design) | krátké hodnoty: použít konkrétní délku |
| `varchar(n)` | ASCII kódy, systémové hodnoty | uživatelský text (multilingual!) |
| `nvarchar(max)` | dlouhé texty, JSON, XML jako string | jako náhrada pro krátké texty |
| `char(1)` / `nchar(n)` | fixní kódy diskriminátoru | variabilní text |
| `bit` | boolean | `int` nebo `tinyint` pro bool! |
| `datetime2(0)` | časové značky (přesnost na sekundy) | starý `datetime` (nikdy) |
| `datetime2(7)` | vysoká přesnost (auditing) | — |
| `date` | pouze datum | `datetime2` pokud nepotřeba čas |
| `time(0)` | pouze čas dne | `varchar` pro čas! |
| `decimal(p,s)` | peněžní hodnoty, sazby, podíly | `float`/`real` pro peníze! |
| `float` / `real` | fyzikální hodnoty (vzdálenosti, váhy) | peníze, kurzy |
| `geography` | GPS souřadnice, geometrie | `varchar` pro GPS! |
| `rowversion` / `timestamp` | optimistická souběžnost (EF) | pro datetime! |
| `xml` | strukturované XML (zvážit JSON) | obecný text |

### 4.2 Zakázané kombinace

```
❌ float pro peníze     → zaokrouhlovací chyby
❌ varchar pro GPS      → nelze počítat vzdálenosti
❌ int pro boolean      → používat bit
❌ datetime (starý)     → datetime2 vždy
❌ nvarchar(max) všude  → konkrétní délka pro indexovatelnost
❌ NULL jako default flag → použít konkrétní boolean sloupec
```

### 4.3 Správné typy pro časové operace

```sql
-- Správně:
[CreatedAt]     [datetime2](0)  NOT NULL    DEFAULT(SYSUTCDATETIME()),  -- UTC!
[ValidFrom]     [datetime2](0)  NOT NULL,
[ValidTo]       [datetime2](0)  NULL,   -- NULL = platí dodnes
[WorkDate]      [date]          NOT NULL,   -- jen datum
[ShiftStart]    [time](0)       NOT NULL,   -- jen čas

-- Špatně:
[CreatedAt]     [datetime]      ...         -- starý typ, nepřesný
[CreatedAt]     [datetime2](0)  DEFAULT(GETDATE())  -- lokální čas serveru!
```

> ⚠️ **Vždy UTC**: defaulty `SYSUTCDATETIME()`, ne `GETDATE()`. V EF Core `DateTime.UtcNow`.  
> Lokální čas serveru způsobuje problémy při letním/zimním čase a migraci serverů.

---

## 5. PRIMÁRNÍ KLÍČE

### 5.1 Pravidla pro PK

```
✅ INT IDENTITY(1,1) — standardní volba, rychlý clustered index
✅ BIGINT IDENTITY — pokud tabulka přesáhne 2 mld řádků
✅ UNIQUEIDENTIFIER s NEWSEQUENTIALID() — pro GUID požadované API (sekvenční = méně fragmentace)
✅ DB Sequence (HiLo) — pro TPC dědičnost (EF Core UseHiLo)
⚠️ Composite PK — jen pro junction tabulky nebo specifické případy
❌ NEWID() jako clustered PK — náhodné GUID → masivní fragmentace indexu
❌ Přirozené klíče (Email, RČ, IČ) jako PK — mění se, způsobují problémy
```

### 5.2 PK pro různé scénáře

```sql
-- Standardní (99% případů)
[Id] [int] IDENTITY(1,1) NOT NULL,
CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)

-- Pro velké tabulky (tracking, logy)
[Id] [bigint] IDENTITY(1,1) NOT NULL,
CONSTRAINT [PK_Tracking] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)

-- GUID pro API-facing entity (sekvenční!)
[Id] [uniqueidentifier] NOT NULL DEFAULT(NEWSEQUENTIALID()),
CONSTRAINT [PK_WorkerJob] PRIMARY KEY CLUSTERED ([Id] ASC)

-- Composite PK pro junction tabulku
CONSTRAINT [PK_CustomerCategory] PRIMARY KEY ([Customer_Id] ASC, [Category_Id] ASC)

-- TPC hierarchie — sequence místo IDENTITY
[Id] [int] NOT NULL DEFAULT(NEXT VALUE FOR [hr].[ActivityIdSequence]),
CONSTRAINT [PK_Work] PRIMARY KEY ([Id])
```

---

## 6. CIZÍ KLÍČE A REFERENČNÍ INTEGRITA

### 6.1 Pravidla

```
✅ VŽDY definovat FK constraint — databáze je poslední obranná linie integrity
✅ VŽDY indexovat FK sloupec (IX_{Tabulka}_{Sloupec})
✅ Explicitně specifikovat ON DELETE akci
✅ ON DELETE CASCADE — jen pro silnou kompozici (Depot → Address)
✅ ON DELETE RESTRICT / NO ACTION — pro slabé vazby (Ticket → Customer)
✅ ON DELETE SET NULL — pro volitelné vazby
❌ Nikdy nezakazovat FK pro "výkon" — indexování FK vyřeší výkon
❌ Nikdy nespoléhat jen na aplikační vrstvu pro RI
```

### 6.2 Ukázka správných FK

```sql
-- Silná kompozice: smazání Address smaže Depot (ON DELETE CASCADE)
CONSTRAINT [FK_Depot_Address_Id]
    FOREIGN KEY ([Id]) REFERENCES [data].[Address]([Id]) ON DELETE CASCADE

-- Slabá vazba: nelze smazat Customer, pokud má Tickety (default NO ACTION)
CONSTRAINT [FK_Ticket_Customer_Id]
    FOREIGN KEY ([Customer_Id]) REFERENCES [dbo].[Customer]([Id])

-- Volitelná vazba: smazání Projektu nulluje reference v Ticketu
CONSTRAINT [FK_Ticket_Project_Id]
    FOREIGN KEY ([Project_Id]) REFERENCES [helpdesk].[Project]([Id]) ON DELETE SET NULL

-- Self-referencing (hierarchie)
CONSTRAINT [FK_Project_Parent_Id]
    FOREIGN KEY ([Project_Id]) REFERENCES [helpdesk].[Project]([Id]) ON DELETE NO ACTION
```

### 6.3 Povinný index ke každému FK

```sql
-- Po každém FK constraint přidat index:
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id]   ON [helpdesk].[Ticket] ([Customer_Id]);
CREATE NONCLUSTERED INDEX [IX_Ticket_Project_Id]    ON [helpdesk].[Ticket] ([Project_Id]);
CREATE NONCLUSTERED INDEX [IX_Work_User_Id_Date]    ON [hr].[Work] ([User_Id], [Date] DESC);
```

---

## 7. INDEXY

### 7.1 Základní pravidla

```
Pravidlo 1: Clustered index = PK (automaticky u PRIMARY KEY CLUSTERED)
Pravidlo 2: Každý FK sloupec má nonclustered index
Pravidlo 3: Každý frequently-filtered sloupec (WHERE, JOIN) má index
Pravidlo 4: Covering index (INCLUDE) pro frequently-read sloupce bez SELECT *
Pravidlo 5: Filtered index pro podmíněné dotazy (IsActive = 1, DeletedAt IS NULL)
Pravidlo 6: FILLFACTOR 70-90 pro tabulky s vysokým INSERT/UPDATE
Pravidlo 7: Max ~10 indexů na tabulku — každý index zpomaluje zápis
```

### 7.2 Typy indexů a kdy je použít

```sql
-- Nonclustered (nejčastější): FK a WHERE sloupce
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id]
ON [helpdesk].[Ticket] ([Customer_Id] ASC)
WITH (FILLFACTOR = 90, ONLINE = ON);   -- ONLINE = bez blokování produkce

-- Covering index: přidat INCLUDE pro sloupce vracené SELECT
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id_Cover]
ON [helpdesk].[Ticket] ([Customer_Id] ASC, [CreatedAt] DESC)
INCLUDE ([Title], [IsActive], [ResolvedAt]);   -- zabraňuje key lookup

-- Filtered index: specifická podmínka (méně dat = rychlejší, menší)
CREATE NONCLUSTERED INDEX [IX_Ticket_Active]
ON [helpdesk].[Ticket] ([Customer_Id] ASC, [CreatedAt] DESC)
WHERE [ResolvedAt] IS NULL;   -- jen aktivní tickety

-- Unique index (alternativa k UNIQUE constraint)
CREATE UNIQUE NONCLUSTERED INDEX [UX_User_Login]
ON [dbo].[User] ([Login] ASC)
WHERE [Login] IS NOT NULL;    -- NULL hodnoty ignorovány

-- Composite index: pořadí záleží! (selektivnější sloupec první)
CREATE NONCLUSTERED INDEX [IX_Tracking_Vehicle_Date]
ON [track].[Tracking] ([Vehicle_Id] ASC, [TrackingDateUtc] DESC);
-- Dotaz: WHERE Vehicle_Id = X AND TrackingDateUtc > Y → ideální

-- Spatial index pro geography sloupce
CREATE SPATIAL INDEX [SIX_Address_Location]
ON [data].[Address] ([Location])
USING GEOGRAPHY_GRID
WITH (GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM), CELLS_PER_OBJECT = 16);
```

### 7.3 Anti-patterns v indexování

```
❌ Index na nízko-selektivní sloupce samotné (bit, status s 3 hodnotami)
❌ Příliš mnoho indexů → zpomalení INSERT/UPDATE/DELETE
❌ Indexy na sloupce v computed expressions v WHERE (nepoužitelné)
❌ Nepoužívané indexy → zbytečná zátěž
❌ Chybějící index na FK → tabulkový scan při JOIN a DELETE
```

### 7.4 Monitoring a údržba

```sql
-- Nepoužívané indexy (kandidáti ke smazání)
SELECT OBJECT_NAME(i.object_id) AS TableName, i.name AS IndexName,
    ius.user_seeks, ius.user_scans, ius.user_updates
FROM sys.indexes i
    LEFT JOIN sys.dm_db_index_usage_stats ius 
        ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE i.type > 0
    AND (ius.user_seeks IS NULL OR ius.user_seeks + ius.user_scans < 10)
    AND ius.user_updates > 1000   -- hodně update, žádné čtení
ORDER BY ius.user_updates DESC;

-- Fragmentace (pravidelně spouštět a reagovat)
SELECT OBJECT_NAME(ips.object_id) AS TableName, i.name AS IndexName,
    ips.avg_fragmentation_in_percent, ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10 AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- < 30% → REORGANIZE (online); > 30% → REBUILD
ALTER INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket] REBUILD WITH (ONLINE = ON);
```

---

## 8. DĚDIČNOSTNÍ VZORY (TPC / TPT / TPH)

### 8.1 Rozhodovací strom

```
Je to IS-A vztah?
├── NE → 1:1 relace (ne dědičnost)
└── ANO → Kolik typů?
    ├── 1-3 typy, sdílené dotazy → TPH (1 tabulka, diskriminátor)
    ├── Typy dotazovány společně, potřeba JOIN s jinými tabulkami → TPT
    └── Typy dotazovány samostatně, bez cross-type JOIN → TPC (preferováno)
```

### 8.2 TPC — Table Per Concrete Type (preferovaná strategie)

**Kdy:** Typy vždy dotazovány samostatně; žádné polymorfní FK z jiných tabulek.

```sql
-- 1. Sequence pro globálně unikátní ID přes všechny concrete tabulky
-- ⚠️  Na existující databázi: START WITH > MAX(existující Id) + buffer
CREATE SEQUENCE [hr].[ActivityIdSequence]
    AS INT START WITH 1 INCREMENT BY 50 NO MAXVALUE;

-- 2. Každá concrete tabulka = kompletní set sloupců + FK + indexy
CREATE TABLE [hr].[Work](
    [Id]            [int]   NOT NULL    DEFAULT(NEXT VALUE FOR [hr].[ActivityIdSequence]),
    -- sdílené sloupce (kopie z abstraktní třídy)
    [User_Id]       [int]   NOT NULL,
    [Date]          [date]  NOT NULL,
    [IsClosed]      [bit]   NOT NULL    DEFAULT(0),
    -- specifické sloupce
    [From]          [time](0) NOT NULL,
    [To]            [time](0) NULL,
    CONSTRAINT [PK_Work]        PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Work_User_Id] FOREIGN KEY ([User_Id]) REFERENCES [dbo].[User]([Id])
);
CREATE NONCLUSTERED INDEX [IX_Work_User_Id_Date] ON [hr].[Work] ([User_Id], [Date] DESC);
-- Každá concrete tabulka MUSÍ mít vlastní FK a indexy (nejsou zděděny)!

-- 3. Polymorfní dotaz přes všechny typy = UNION ALL (není JOIN)
CREATE VIEW [hr].[vActivity] AS
    SELECT Id, User_Id, [Date], IsClosed, 'Work'     AS ActivityType FROM [hr].[Work]
    UNION ALL
    SELECT Id, User_Id, [Date], IsClosed, 'Holiday'  AS ActivityType FROM [hr].[Holiday]
    UNION ALL
    SELECT Id, User_Id, [Date], IsClosed, 'Illness'  AS ActivityType FROM [hr].[Illness];
```

```csharp
// EF Core konfigurace TPC
modelBuilder.Entity<Activity>(b => {
    b.UseTpcMappingStrategy();
    b.Property(a => a.Id).UseHiLo("ActivityIdSequence", "hr");
    b.Property(a => a.UserId).HasColumnName("User_Id");  // legacy naming!
});
modelBuilder.Entity<Work>().ToTable("Work", "hr");
modelBuilder.Entity<Holiday>().ToTable("Holiday", "hr");
```

### 8.3 TPT — Table Per Type (pro sdílené FK cíle)

**Kdy:** Abstraktní třída je FK cílem z jiných tabulek (nelze mít FK na konkrétní typ).

```sql
-- Bázová tabulka (FK target pro ostatní tabulky)
CREATE TABLE [data].[Address](
    [Id]        [int]   IDENTITY(1,1)   NOT NULL,
    [Name]      [nvarchar](100)         NOT NULL,
    [Location]  [geography]             NULL,
    CONSTRAINT [PK_Address] PRIMARY KEY ([Id])
);

-- Odvozená tabulka — Id NENÍ IDENTITY (přebírá z Address)
CREATE TABLE [data].[Depot](
    [Id]            [int]   NOT NULL,  -- PK = FK na Address
    [Instance_Id]   [int]   NOT NULL,
    CONSTRAINT [PK_Depot] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Depot_Address_Id] FOREIGN KEY ([Id]) REFERENCES [data].[Address]([Id]) ON DELETE CASCADE
);

-- Jiné tabulky mohou odkazovat na Address (ne přímo na Depot)
-- plan.Route → AddressStart_Id → data.Address → může být Depot nebo Outlet
```

```csharp
// EF Core TPT
modelBuilder.Entity<Address>().ToTable("Address", "data");
modelBuilder.Entity<Depot>()
    .ToTable("Depot", "data")
    .Property(d => d.Id).ValueGeneratedNever();  // NOT IDENTITY!
```

### 8.4 TPH — Table Per Hierarchy (pro malé uzavřené hierarchie)

**Kdy:** 2-5 typů, sdílené dotazy, málo NULL sloupců na typ.

```sql
CREATE TABLE [helpdesk].[Project](
    [Id]            [int]   IDENTITY(1,1)   NOT NULL,
    [ProjectType_Id][char](1)               NOT NULL,   -- diskriminátor: P, O, I, S, C
    -- sdílené sloupce
    [Name]          [nvarchar](100)         NOT NULL,
    -- ...
    CONSTRAINT [PK_Project] PRIMARY KEY ([Id])
);
```

```csharp
// EF Core TPH — VŠECHNY hodnoty diskriminátoru musí být namapovány!
modelBuilder.Entity<Project>()
    .HasDiscriminator<char>("ProjectType_Id")
    .HasValue<HelpDeskProject>('P')
    .HasValue<Order>('O')
    .HasValue<ProjectItem>('I')
    .HasValue<ServiceProject>('S')     // nesmí chybět
    .HasValue<ContinuationProject>('C'); // nesmí chybět
```

### 8.5 1:1 relace vs. dědičnost

```
❌ ŠPATNĚ: Customer v helpdesk schématu jako odvozená třída od dbo.Customer
✅ SPRÁVNĚ: helpdesk.Customer jako 1:1 rozšíření dbo.Customer (Customer_Id = PK + FK)

Pravidlo: Pokud doménové rozšíření není IS-A (je spíše "konfigurace pro doménu"),
          použij 1:1 relaci, ne dědičnost.
```

---

## 9. MULTI-TENANCY

### 9.1 Způsoby implementace

| Způsob | Popis | Vhodné pro |
|---|---|---|
| **Shared DB, shared schema** | Tenant_Id ve každé tabulce | SaaS s mnoha malými tenanty |
| **Shared DB, separate schema** | Schema per tenant | Střední počet tenantů |
| **Separate DB per tenant** | Každý tenant = vlastní DB | Velcí tenanti, vysoká izolace |

### 9.2 Shared schema pattern (Apollo vzor)

```sql
-- Tenant tabulka
CREATE TABLE [dbo].[Customer](
    [Id]        [int]   IDENTITY(1,1) NOT NULL,
    [Name]      [nvarchar](150)       NOT NULL,
    [IsActive]  [bit]                 NOT NULL DEFAULT(1),
    CONSTRAINT [PK_Customer] PRIMARY KEY ([Id])
);

-- Doménová tabulka s Tenant_Id
CREATE TABLE [helpdesk].[Ticket](
    [Id]            [int]   IDENTITY(1,1) NOT NULL,
    [Customer_Id]   [int]               NOT NULL,  -- tenant
    -- ...
    CONSTRAINT [PK_Ticket]              PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Ticket_Customer_Id]  FOREIGN KEY ([Customer_Id]) REFERENCES [dbo].[Customer]([Id])
);
-- Index na tenant FK je kritický
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket] ([Customer_Id]);
```

### 9.3 Row-Level Security (automatický tenant filter)

```sql
-- Predikátová funkce
CREATE FUNCTION [dbo].[fn_TenantFilter](@CustomerId int)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT 1 AS result
    WHERE @CustomerId = CAST(SESSION_CONTEXT(N'CustomerId') AS int)
       OR IS_MEMBER('db_owner') = 1;

-- Bezpečnostní politika (READ + WRITE)
CREATE SECURITY POLICY [TicketTenantPolicy]
ADD FILTER PREDICATE [dbo].[fn_TenantFilter]([Customer_Id]) ON [helpdesk].[Ticket],
ADD BLOCK PREDICATE  [dbo].[fn_TenantFilter]([Customer_Id]) ON [helpdesk].[Ticket] AFTER INSERT,
ADD BLOCK PREDICATE  [dbo].[fn_TenantFilter]([Customer_Id]) ON [helpdesk].[Ticket] AFTER UPDATE,
ADD BLOCK PREDICATE  [dbo].[fn_TenantFilter]([Customer_Id]) ON [helpdesk].[Ticket] BEFORE DELETE
WITH (STATE = ON);

-- Aplikace nastavuje context před každým dotazem
EXEC sp_set_session_context N'CustomerId', @CustomerId;
```

---

## 10. PLATNOSTNÍ VZOR (ValidFrom / ValidTo)

```sql
-- Standardní pattern pro historická data
CREATE TABLE [data].[VehicleConfiguration](
    [Id]            [int]           IDENTITY(1,1)   NOT NULL,
    [Vehicle_Id]    [int]                           NOT NULL,
    -- konfigurační data...
    [ValidFrom]     [datetime2](0)                  NOT NULL,
    [ValidTo]       [datetime2](0)                  NULL,  -- NULL = platí dodnes
    CONSTRAINT [PK_VehicleConfiguration] PRIMARY KEY ([Id])
);

-- Dotaz pro aktuálně platný záznam (inline predikát, ne skalární funkce!)
SELECT * FROM [data].[VehicleConfiguration]
WHERE Vehicle_Id = @VehicleId
  AND ValidFrom <= SYSUTCDATETIME()
  AND (ValidTo IS NULL OR ValidTo > SYSUTCDATETIME());

-- Index pro tento vzor
CREATE NONCLUSTERED INDEX [IX_VehicleConfiguration_Vehicle_Id_ValidFrom]
ON [data].[VehicleConfiguration] ([Vehicle_Id] ASC, [ValidFrom] ASC)
INCLUDE ([ValidTo]);
```

```csharp
// EF Core interface
public interface ITemporalValidity {
    DateTime ValidFrom { get; set; }
    DateTime? ValidTo { get; set; }
}

// Extension pro čisté queries
public static IQueryable<T> ValidAt<T>(this IQueryable<T> query, DateTime at)
    where T : ITemporalValidity
    => query.Where(e => e.ValidFrom <= at && (e.ValidTo == null || e.ValidTo > at));

// Použití
var config = await db.VehicleConfigurations
    .ValidAt(DateTime.UtcNow)
    .FirstAsync(c => c.VehicleId == vehicleId);
```

---

## 11. COMPUTED COLUMNS

```sql
-- PERSISTED: výsledek uložen fyzicky, lze indexovat
-- ⚠️  Nepsat NOT NULL za PERSISTED — nulovost SQL odvozuje z výrazu
[SolutionTimeWork]  AS (ISNULL([SolutionTime] - [SolutionTimeTransport], 0)) PERSISTED
[IsForHelpdesk]     AS (CASE WHEN [ProjectType_Id] = 'P' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END) PERSISTED
[FullName]          AS ([LastName] + N', ' + [FirstName]) PERSISTED

-- Index na computed column (jen PERSISTED!)
CREATE NONCLUSTERED INDEX [IX_Project_Order] ON [helpdesk].[Project] ([Order] ASC);
```

```csharp
// EF Core mapování computed column
modelBuilder.Entity<WorkDetail>()
    .Property(w => w.SolutionTimeWork)
    .HasComputedColumnSql("ISNULL([SolutionTime]-[SolutionTimeTransport], 0)", stored: true);
// stored: true = PERSISTED (fyzicky uložen, indexovatelný)
```

---

## 12. STORED PROCEDURES — SPRÁVNÝ VZOR

```sql
CREATE PROCEDURE [helpdesk].[CreateTicket]
    @Customer_Id    int,
    @Title          nvarchar(300),
    @TicketId       int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;   -- při chybě automaticky rollback

    BEGIN TRANSACTION;
    BEGIN TRY

        INSERT INTO [helpdesk].[Ticket] ([Customer_Id], [Title], [CreatedAt])
        VALUES (@Customer_Id, @Title, SYSUTCDATETIME());

        SET @TicketId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;   -- znovu vyvolá původní chybu s plným kontextem
    END CATCH;
END;
```

**Pravidla pro stored procedures:**
```
✅ SET NOCOUNT ON — nevracet počty řádků
✅ SET XACT_ABORT ON — automatický rollback při chybě
✅ BEGIN TRAN + BEGIN TRY + COMMIT/CATCH THROW
✅ Kontrola existence uvnitř transakce s UPDLOCK, HOLDLOCK (anti race condition)
✅ SYSUTCDATETIME() pro všechny časové hodnoty
✅ SCOPE_IDENTITY() pro získání nového Id
❌ RETURN -1 pro chyby — ztrácíme kontext; THROW zachovává původní chybu
❌ Kontrola existence před BEGIN TRAN — race condition!
❌ GETDATE() — lokální čas serveru
```

---

## 13. USER DEFINED FUNCTIONS

### 13.1 Inline TVF (nejlepší výkon)

```sql
-- Inline TVF = jako parametrizovaný VIEW, optimalizátor ji inlinuje
CREATE FUNCTION [plan].[GetActiveOutlets] (@PlanVersionId INT)
RETURNS TABLE AS RETURN
    SELECT o.Id, o.Customer_Id, a.[Location]
    FROM [plan].[OutletDay] od
        INNER JOIN [data].[Outlet] o ON od.Outlet_Id = o.Id
        INNER JOIN [data].[Address] a ON o.Id = a.Id
    WHERE od.PlanVersion_Id = @PlanVersionId;
-- Použití: SELECT * FROM [plan].[GetActiveOutlets](1)
```

### 13.2 Skalární funkce — opatrně!

```sql
-- ⚠️  Skalární funkce v WHERE/JOIN způsobují row-by-row zpracování (žádný index seek)
-- Používat POUZE pro výpočty mimo WHERE a JOIN
CREATE FUNCTION [dbo].[FormatPhone](@Phone nvarchar(20))
RETURNS nvarchar(20) AS
BEGIN
    RETURN '+420 ' + RIGHT(@Phone, 9);
END;

-- ŠPATNĚ (skalární UDF v WHERE = anti-pattern):
WHERE [dbo].[IsValidDate](GETDATE(), ValidFrom, ValidTo) = 1

-- SPRÁVNĚ (inline predikát):
WHERE ValidFrom <= SYSUTCDATETIME() AND (ValidTo IS NULL OR ValidTo > SYSUTCDATETIME())
```

---

## 14. VIEWS

### 14.1 Standardní view

```sql
CREATE VIEW [helpdesk].[vTicketSummary] AS
SELECT
    t.Id AS TicketId,
    t.Customer_Id,
    t.Title,
    t.CreatedAt,
    t.ResolvedAt,
    DATEDIFF(HOUR, t.CreatedAt, ISNULL(t.ResolvedAt, SYSUTCDATETIME())) AS AgeHours
FROM [helpdesk].[Ticket] t
WHERE t.ResolvedAt IS NULL;  -- jen aktivní tickety
```

### 14.2 Indexed view (materializovaná)

```sql
-- WITH SCHEMABINDING je povinné pro indexed view
CREATE VIEW [helpdesk].[vTicketCountByCustomer] WITH SCHEMABINDING AS
SELECT
    t.Customer_Id,
    COUNT_BIG(*) AS TicketCount  -- COUNT_BIG (ne COUNT) je povinné
FROM [helpdesk].[Ticket] t
GROUP BY t.Customer_Id;

-- Materializovat jako clustered index
CREATE UNIQUE CLUSTERED INDEX [IX_vTicketCountByCustomer]
ON [helpdesk].[vTicketCountByCustomer] ([Customer_Id]);
-- Dotaz: SELECT Customer_Id, TicketCount FROM helpdesk.vTicketCountByCustomer
-- → SQL Server automaticky použije indexed view (bez NOEXPAND hintu)
```

---

## 20. MSDN BEST PRACTICES

> Tato sekce shrnuje officiální doporučení z Microsoft dokumentace (learn.microsoft.com).  
> Zdroje: Index Design Guide, Query Store, Temporal Tables, Data Compression, Dynamic Data Masking, RLS, PK/FK Constraints.

---

### 20.1 Index Design — Officiální doporučení

**Zdroj:** [SQL Server Index Design Guide](https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide)

#### Obecné zásady (MSDN)

| Pravidlo | Detail |
|---|---|
| **Understand the workload first** | OLTP → úzké rowstore indexy; OLAP/DWH → clustered columnstore |
| **Nepřeindexovat** | Každý index zpomaluje INSERT/UPDATE/DELETE/MERGE — vždy váž benefit vs. cenu |
| **Duplikáty jsou ztráta** | Raději přidej `INCLUDE` sloupce do existujícího indexu než vytvárej nový podobný |
| **Optimizer si vybere sám** | Index usage ≠ good performance; špatný index může být horší než žádný |
| **Narrow keys** | Indexový klíč = co nejméně sloupců; šířka klíče ovlivňuje paměť B+ stromu |
| **Experimentuj** | Indexy lze přidat/odebrat bez změny schématu — neboj se testovat |
| **Filtered index** | Pro well-defined subset (např. `WHERE IsDeleted = 0`) → menší index, rychlejší maintenance |

#### Typy indexů a kdy je použít

```sql
-- Clustered index: fyzické řazení dat — max. 1 na tabulku, typicky PK
CREATE CLUSTERED INDEX [IX_Order_Id] ON [dbo].[Order] ([Id]);

-- Nonclustered index: logický index s row locatorem → nejčastěji používaný typ
CREATE NONCLUSTERED INDEX [IX_Order_Customer_Id] ON [dbo].[Order] ([Customer_Id]);

-- INCLUDE sloupce: "covering index" — dotaz vyřešen z indexu bez lookup do heap/clustered
CREATE NONCLUSTERED INDEX [IX_Order_Customer_Id_Covering]
ON [dbo].[Order] ([Customer_Id])
INCLUDE ([Status], [CreatedAt], [TotalAmount]);

-- Filtered index: pouze subset řádků → menší, rychlejší pro specifické dotazy
CREATE NONCLUSTERED INDEX [IX_Order_Active]
ON [dbo].[Order] ([Customer_Id], [CreatedAt])
WHERE [Status] = 'Active';

-- Unique index: vynucení unikátnosti bez PK constraintu
CREATE UNIQUE NONCLUSTERED INDEX [UX_User_Email]
ON [dbo].[User] ([Email])
WHERE [Email] IS NOT NULL;  -- filtered unique = NULL povoleno opakovaně

-- Columnstore index: OLAP/reporty, 10× rychlejší čtení, 7× komprese
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_Order_Columnstore]
ON [dbo].[Order] ([Customer_Id], [CreatedAt], [TotalAmount], [Status]);
```

#### Klíčová MSDN pravidla pro indexy na computed columns

```sql
-- Index na computed column je možný POUZE pokud je výraz deterministický + PERSISTED
ALTER TABLE [dbo].[Order]
    ADD [YearMonth] AS CONVERT(CHAR(7), [CreatedAt], 126) PERSISTED;

-- Pak lze indexovat:
CREATE NONCLUSTERED INDEX [IX_Order_YearMonth]
ON [dbo].[Order] ([YearMonth]);
```

#### Index Maintenance (MSDN DMV dotaz)

```sql
-- Zjisti fragmentaci — Microsoft doporučuje rebuild nad 30 %, reorganize 10–30 %
SELECT
    OBJECT_NAME(ips.object_id)          AS TableName,
    i.name                              AS IndexName,
    ips.avg_fragmentation_in_percent    AS Fragmentation,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
  AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

---

### 20.2 Data Compression

**Zdroj:** [Data Compression](https://learn.microsoft.com/en-us/sql/relational-databases/data-compression/data-compression)

| Typ komprese | Kdy použít | Poznámka |
|---|---|---|
| **ROW compression** | Tabulky s variabilními typy (VARCHAR, NVARCHAR) | Odstraňuje padding fixed-length typů |
| **PAGE compression** | Velké tabulky s vysokou I/O zátěží | Zahrnuje ROW + prefix/dictionary compression |
| **COLUMNSTORE compression** | OLAP/reporty; columnstore indexy | Automaticky, není konfigurovatelné |
| **COLUMNSTORE_ARCHIVE** | Archivy s dlouhodobým uložením | Vyšší CPU, menší velikost |

```sql
-- PAGE komprese na tabulce (ONLINE = bez výpadku)
ALTER TABLE [dbo].[Order]
REBUILD WITH (DATA_COMPRESSION = PAGE, ONLINE = ON);

-- PAGE komprese na indexu
ALTER INDEX [IX_Order_Customer_Id] ON [dbo].[Order]
REBUILD WITH (DATA_COMPRESSION = PAGE, ONLINE = ON);

-- COLUMNSTORE ARCHIVE komprese na starých partition (pro historická data)
ALTER TABLE [dbo].[OrderArchive]
REBUILD PARTITION = 1 WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
```

> ⚠️ **MSDN upozornění:** Komprese je dostupná pouze v Enterprise/Developer edici SQL Server (ne Standard).  
> Off-row data (XML > 8060 B, LOB) se nekomprimují. MAX row size limit 8060 B stále platí.

---

### 20.3 Query Store — Best Practices

**Zdroj:** [Best practice with the Query Store](https://learn.microsoft.com/en-us/sql/relational-databases/performance/best-practice-with-the-query-store)

Query Store = "flight data recorder" pro databázi. Zaznamenává historii dotazů, plánů a statistik.

```sql
-- Povinná konfigurace (dle MSDN doporučení)
ALTER DATABASE [MojeDB] SET QUERY_STORE = ON
WITH (
    OPERATION_MODE           = READ_WRITE,          -- nikdy READ_ONLY v produkci
    CLEANUP_POLICY           = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,              -- flush každých 15 min
    MAX_STORAGE_SIZE_MB      = 1000,                -- min 500 MB pro prod
    QUERY_CAPTURE_MODE       = AUTO,                -- SQL 2019+: CUSTOM pro fine-tuning
    SIZE_BASED_CLEANUP_MODE  = AUTO                 -- čistí automaticky při plnění
);
```

#### Praktické MSDN použití

```sql
-- Top 10 dotazů podle průměrné doby CPU (regrese po deployi)
SELECT TOP 10
    q.query_id,
    qt.query_sql_text,
    rs.avg_cpu_time,
    rs.avg_duration,
    rs.count_executions
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
ORDER BY rs.avg_cpu_time DESC;

-- Force plan (fixní execution plan pro problematický dotaz)
EXEC sys.sp_query_store_force_plan @query_id = 42, @plan_id = 7;

-- Unforce plan po vyřešení problému
EXEC sys.sp_query_store_unforce_plan @query_id = 42, @plan_id = 7;
```

> **MSDN tip:** Po upgradu COMPATIBILITY_LEVEL použij **Query Tuning Assistant (QTA)** — pomáhá identifikovat regrese plánů a doporučuje force plan jako dočasnou stabilizaci.

---

### 20.4 Temporal Tables (System-Versioned)

**Zdroj:** [Temporal Tables](https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables)

Temporal tables = vestavěná auditní historie bez aplikační logiky. SQL Server automaticky uchovává každou verzi řádku.

```sql
-- Vytvoření temporal table (SQL Server 2016+)
CREATE TABLE [dbo].[Employee]
(
    [Id]            INT             NOT NULL CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED,
    [Name]          NVARCHAR(100)   NOT NULL,
    [Position]      VARCHAR(100)    NOT NULL,
    [Salary]        DECIMAL(10, 2)  NOT NULL,
    -- Systémové sloupce pro temporal (HIDDEN = skryté před SELECT *)
    [ValidFrom]     DATETIME2       GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    [ValidTo]       DATETIME2       GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[EmployeeHistory]));
```

#### Dotazy na historická data (FOR SYSTEM_TIME)

```sql
-- Stav k určitému okamžiku (point-in-time query)
SELECT * FROM [dbo].[Employee]
FOR SYSTEM_TIME AS OF '2024-01-01T00:00:00';

-- Vše co platilo v časovém rozsahu (BETWEEN)
SELECT * FROM [dbo].[Employee]
FOR SYSTEM_TIME BETWEEN '2024-01-01' AND '2024-12-31';

-- Kompletní historie řádku pro konkrétního zaměstnance (vč. aktuálního)
SELECT * FROM [dbo].[Employee]
FOR SYSTEM_TIME ALL
WHERE [Id] = 42
ORDER BY [ValidFrom];
```

#### Kdy použít Temporal vs. ValidFrom/ValidTo (dle MSDN)

| Scénář | Temporal Table | ValidFrom/ValidTo |
|---|---|---|
| Auditní trail (kdo co kdy změnil) | ✅ Ideální | ❌ Manuální logika |
| Point-in-time queries | ✅ Nativní syntax | ❌ Složité WHERE |
| Business validity (aktivní záznam) | ❌ Neudrží | ✅ Přímá logika |
| EF Core podpora | ⚠️ EF Core 6+ (UseTemporalTable) | ✅ Přímé |
| Archivace starých verzí | ✅ Automatická | ❌ Manuální |

---

### 20.5 Dynamic Data Masking (DDM)

**Zdroj:** [Dynamic Data Masking](https://learn.microsoft.com/en-us/sql/relational-databases/security/dynamic-data-masking)

DDM maskuje citlivá data pro neautorizované uživatele — **data v DB se nemění**, mění se jen výsledek SELECT.

```sql
-- Definice masek při CREATE TABLE
CREATE TABLE [dbo].[Customer]
(
    [Id]        INT             NOT NULL CONSTRAINT [PK_Customer] PRIMARY KEY,
    [Name]      NVARCHAR(100)   NOT NULL,
    -- Email: zobrazí pouze první písmeno + @XXXX.com
    [Email]     VARCHAR(200)    MASKED WITH (FUNCTION = 'email()') NULL,
    -- Telefon: plná maska (zobrazí jen XXXX)
    [Phone]     VARCHAR(20)     MASKED WITH (FUNCTION = 'default()') NULL,
    -- Rodné číslo: zobrazí pouze část
    [BirthId]   VARCHAR(11)     MASKED WITH (FUNCTION = 'partial(0,"XXXXXXX",4)') NULL,
    -- Věk: náhodné číslo v rozsahu místo skutečné hodnoty
    [Age]       INT             MASKED WITH (FUNCTION = 'random(1, 99)') NULL
);

-- Přidat masku na existující sloupec
ALTER TABLE [dbo].[Customer]
    ALTER COLUMN [Email] ADD MASKED WITH (FUNCTION = 'email()');

-- Odebrat masku
ALTER TABLE [dbo].[Customer]
    ALTER COLUMN [Email] DROP MASKED;

-- Udělit právo vidět nemaskovná data (privileged user)
GRANT UNMASK ON [dbo].[Customer] TO [AppAdmin];
```

> ⚠️ **MSDN upozornění:** DDM **nenahrazuje** šifrování ani RLS. Je to prezentační vrstva, ne ochrana na úrovni uložení. Uživatel s přístupem k tabulce může obejít DDM přes inferenci. Kombinuj vždy s RLS + šifrováním pro citlivá data.

---

### 20.6 Row-Level Security — Kompletní vzor (MSDN)

**Zdroj:** [Row-Level Security](https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security)

```sql
-- 1. Predikátová funkce (INLINE TVF — ne skalární!)
CREATE FUNCTION [security].[fn_TenantFilter](@TenantId INT)
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN
    SELECT 1 AS [Result]
    WHERE @TenantId = CAST(SESSION_CONTEXT(N'TenantId') AS INT)
       OR IS_ROLEMEMBER('db_owner') = 1;  -- db_owner vidí vše
GO

-- 2. Security policy s FILTER + všemi BLOCK predikáty
CREATE SECURITY POLICY [security].[TenantPolicy]
    ADD FILTER PREDICATE [security].[fn_TenantFilter]([Tenant_Id])
        ON [dbo].[Order],
    ADD BLOCK PREDICATE [security].[fn_TenantFilter]([Tenant_Id])
        ON [dbo].[Order] AFTER INSERT,
    ADD BLOCK PREDICATE [security].[fn_TenantFilter]([Tenant_Id])
        ON [dbo].[Order] AFTER UPDATE,
    ADD BLOCK PREDICATE [security].[fn_TenantFilter]([Tenant_Id])
        ON [dbo].[Order] BEFORE DELETE
WITH (STATE = ON, SCHEMABINDING = ON);  -- SCHEMABINDING = ON je doporučené MSDN
```

#### MSDN Block predikáty — přehled

| Typ | Co blokuje | Použití |
|---|---|---|
| `AFTER INSERT` | INSERT nového řádku mimo tenant | Ochrana proti cross-tenant zápisu |
| `AFTER UPDATE` | UPDATE který by přesunul řádek mimo tenant | Ochrana při změně Tenant_Id |
| `BEFORE UPDATE` | UPDATE na řádcích mimo aktuální tenant | Ochrana čtení před zápisem |
| `BEFORE DELETE` | DELETE řádků mimo tenant | Ochrana proti mazání cizích dat |

> **MSDN:** Pro úplnou tenant izolaci musí být definovány **všechny čtyři** block predikáty + filter predikát.

---

### 20.7 Primary Key & Foreign Key — MSDN Limity

**Zdroj:** [Primary and Foreign Key Constraints](https://learn.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints)

| Omezení | Hodnota | Poznámka |
|---|---|---|
| Max. sloupců v PK | **32** | |
| Max. délka PK klíče | **900 bytes** | `NVARCHAR(450)` = 900 B; `NVARCHAR(451)` = chyba |
| Max. outgoing FK (z tabulky) | **253** | Počet FK z jedné tabulky na jiné |
| Max. incoming FK (na tabulku) | **10 000** | Od SQL Server 2016, compat. level 130+ |
| Incoming FK > 253 | Jen DELETE DML | UPDATE a MERGE nepodporují > 253 incoming |

```sql
-- PK key length test — klíč nesmí překročit 900 B
-- NVARCHAR(450) = 450 * 2 B = 900 B → limit přesně
CREATE TABLE [dbo].[Test]
(
    [Code] NVARCHAR(450) NOT NULL CONSTRAINT [PK_Test] PRIMARY KEY CLUSTERED
    -- NVARCHAR(451) by způsobilo warning nebo chybu při insertu s reálnými daty
);
```

---

### 20.8 Performance Monitoring — MSDN Nástroje

**Zdroj:** [Performance Monitoring and Tuning Tools](https://learn.microsoft.com/en-us/sql/relational-databases/performance/performance-monitoring-and-tuning-tools)

| Nástroj | Kdy použít |
|---|---|
| **Query Store** | Tracking regresí výkonu, force plan, post-upgrade analýza |
| **DMV** (`sys.dm_*`) | Real-time monitoring: blokování, I/O, CPU, cache |
| **Extended Events** | Lightweight tracing bez Profileru; produkce-safe |
| **Database Engine Tuning Advisor** | Doporučení chybějících indexů a partition |
| **Live Query Statistics** | Real-time execution plan při ladění |
| **Activity Monitor (SSMS)** | Ad-hoc pohled na procesy, blokování, čekání |

#### Klíčové DMV dotazy (MSDN)

```sql
-- Nejvytíženější dotazy dle CPU (od startu serveru)
SELECT TOP 10
    qs.total_worker_time / qs.execution_count AS avg_cpu_us,
    qs.execution_count,
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_us,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.text)
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY avg_cpu_us DESC;

-- Aktuální blokování (čekající sessions)
SELECT
    blocking_session_id AS BlockedBy,
    session_id,
    wait_type,
    wait_time / 1000.0 AS wait_sec,
    [sql_handle]
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0;

-- Chybějící indexy doporučené optimizerem
SELECT TOP 10
    mid.statement AS TableName,
    migs.avg_user_impact AS EstimatedImprovement,
    migs.user_seeks + migs.user_scans AS Usage,
    'CREATE INDEX [IX_Missing_' + OBJECT_NAME(mid.object_id) + ']'
        + ' ON ' + mid.statement
        + ' (' + ISNULL(mid.equality_columns, '') 
        + CASE WHEN mid.inequality_columns IS NOT NULL 
               THEN ISNULL(', ' + mid.inequality_columns, '') ELSE '' END + ')'
        + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS CreateIndexScript
FROM sys.dm_db_missing_index_details mid
JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
ORDER BY migs.avg_user_impact DESC;
```

---

### 20.9 MSDN Anti-patterns (Doplněk k sekci 18)

| Anti-pattern | MSDN reference | Řešení |
|---|---|---|
| Spekulativní indexy "pro jistotu" | Index Design Guide | Přidej index až po ověření query plánem |
| Clustered index na GUID (random) | Index Design Guide | Použij `NEWSEQUENTIALID()` nebo IDENTITY |
| Skalární UDF v WHERE/JOIN | — | Inline TVF nebo přepsat na predikát |
| SELECT * v production kódu | — | Vždy explicitní seznam sloupců |
| Funkce na indexovaném sloupci ve WHERE | — | `WHERE CreatedAt >= '2024-01-01'` (ne `YEAR(CreatedAt) = 2024`) |
| DDM jako jediná bezpečnostní vrstva | DDM docs | Kombinuj DDM + RLS + Always Encrypted |
| Query Store s malým MAX_STORAGE_SIZE_MB | Query Store best practice | Min. 500 MB pro prod, monitoruj fill rate |
| COMPATIBILITY_LEVEL pod verzí serveru | Compat. docs | Upgrade compat. level postupně (QTA) |
| `NOT IN (subquery)` s NULL hodnotami | — | Použij `NOT EXISTS` — NULL v IN listu = celý výsledek prázdný |
| Implicit type conversion ve WHERE | — | Typy operandů musí souhlasit (jinak index scan místo seek) |

---

## 15. ASP.NET IDENTITY INTEGRACE

### 15.1 Rozšíření IdentityUser (HelpDesk vzor)

```csharp
// Doménové rozšíření Identity — přidat jen aplikační sloupce
public class ApplicationUser : IdentityUser<int>
{
    public int CustomerId { get; set; }       // tenant
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    public bool IsActive { get; set; } = true;
    [Timestamp]
    public byte[] Version { get; set; } = []; // optimistická souběžnost
}

// DbContext
public class AppDbContext : IdentityDbContext<ApplicationUser, ApplicationRole, int>
{
    protected override void OnModelCreating(ModelBuilder b) {
        base.OnModelCreating(b);  // MUSÍ být voláno!
        b.Entity<ApplicationUser>(e => {
            e.ToTable("User", "dbo");
            e.Property(u => u.CustomerId).HasColumnName("Customer_Id");
            // UserName a Login: nastavit obě při registraci!
            // user.UserName = user.Login = loginValue;
        });
    }
}
```

### 15.2 Tenant-scoped role (rozšíření UserRole)

```csharp
// Rozšíření: uživatel má roli V KONTEXTU zákazníka
public class ApplicationUserRole : IdentityUserRole<int>
{
    public int? CustomerId { get; set; }  // null = globální role
}

// Konfigurace
b.Entity<ApplicationUserRole>(e => {
    e.ToTable("UserRole", "dbo");
    e.Property(r => r.CustomerId).HasColumnName("Customer_Id");
});
```

---

## 16. EF CORE MIGRATIONS — BEST PRACTICES

### 16.1 Pravidla

```
✅ Code-first s Migrations pro nové projekty
✅ Jeden DbContext per databáze (nebo per schéma pro velké projekty)
✅ Migrations v separátním projektu (MojeApp.Migrations)
✅ Nullable sloupce → backfill → NOT NULL pro tabulky s daty
✅ Sequence inicializovat výše než MAX(existující Id) při TPC migraci
✅ Každou migraci testovat na kopii produkčních dat
✅ ONLINE operace kde možné (REBUILD WITH (ONLINE = ON))
❌ Nikdy DropTable bez zálohy dat
❌ Nikdy AddColumn<T>(nullable: false) na neprázdnou tabulku bez defaultu
❌ Nikdy CREATE SEQUENCE START WITH 1 na databázi s existujícími daty
```

### 16.2 Bezpečný vzor pro NOT NULL sloupec s existujícími daty

```csharp
public partial class AddTicketPriority : Migration
{
    protected override void Up(MigrationBuilder mb)
    {
        // 1. Přidat jako nullable
        mb.AddColumn<int>("Priority_Id", "Ticket", schema: "helpdesk", nullable: true);

        // 2. Naplnit data (default hodnota)
        mb.Sql("UPDATE helpdesk.Ticket SET Priority_Id = 1 WHERE Priority_Id IS NULL;");

        // 3. Změnit na NOT NULL
        mb.AlterColumn<int>("Priority_Id", "Ticket", schema: "helpdesk",
            nullable: false, defaultValue: 1);

        // 4. FK a index
        mb.Sql("ALTER TABLE helpdesk.Ticket ADD CONSTRAINT FK_Ticket_Priority_Id " +
               "FOREIGN KEY (Priority_Id) REFERENCES dbo.Priority(Id);");
        mb.CreateIndex("IX_Ticket_Priority_Id", "Ticket", "Priority_Id", schema: "helpdesk");
    }
}
```

---

## 17. BEZPEČNOST

### 17.1 Principy minimálního přístupu

```sql
-- Aplikační uživatel: jen co potřebuje, nikdy db_owner!
CREATE USER [app_user] FOR LOGIN [app_login] WITH DEFAULT_SCHEMA=[dbo];

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[helpdesk] TO [app_user];
GRANT SELECT ON SCHEMA::[cfg] TO [app_user];
GRANT EXECUTE ON SCHEMA::[helpdesk] TO [app_user];   -- stored procedures

-- Read-only pro reporting
CREATE USER [report_user] FOR LOGIN [report_login] WITH DEFAULT_SCHEMA=[dbo];
GRANT SELECT ON SCHEMA::[helpdesk] TO [report_user];
GRANT SELECT ON SCHEMA::[hr] TO [report_user];
-- VIEW DEFINITION pro debugging
GRANT VIEW DEFINITION ON SCHEMA::[helpdesk] TO [report_user];
```

### 17.2 Checklist bezpečnosti

```
❌ db_owner pro aplikační účet (existující anti-pattern v HelpDesk)
❌ Přihlašovací jméno/heslo v connection stringu v kódu
❌ SA účet pro aplikace
✅ Minimální oprávnění per schéma
✅ Separátní read-only účet pro reporting
✅ Connection string v Azure Key Vault nebo environment variables
✅ Row-Level Security pro multi-tenant (viz sekce 9.3)
✅ Šifrování citlivých dat (Always Encrypted pro PII)
```

---

## 18. ANTI-PATTERNS — KOMPLETNÍ SEZNAM

| Anti-pattern | Proč je špatný | Správné řešení |
|---|---|---|
| `AUTO_SHRINK ON` | Fragmentace indexů, výkonnostní propady | `AUTO_SHRINK OFF` |
| `GETDATE()` v defaultech | Lokální čas serveru | `SYSUTCDATETIME()` |
| Skalární UDF ve WHERE | Row-by-row zpracování, žádný index seek | Inline predikát |
| `SELECT *` v produkci | Zbytečný I/O, nestabilní schéma | Explicitní sloupce |
| `float` pro peníze | Zaokrouhlovací chyby | `decimal(18,4)` |
| `varchar` pro text | Problémy s diakritikou, multilingual | `nvarchar` |
| `datetime` (starý typ) | Nepřesný, range do 2079 | `datetime2` |
| FK bez indexu | Tabulkový scan při JOIN a DELETE | `IX_{Table}_{FK}` |
| `db_owner` pro aplikaci | Security breach risk | Granulární oprávnění |
| `NEWID()` jako clustered PK | Masivní fragmentace indexu | `NEWSEQUENTIALID()` |
| Kontrola existence před BEGIN TRAN | Race condition | Check uvnitř transakce s UPDLOCK |
| `RETURN -1` v CATCH | Ztráta chybového kontextu | `THROW` |
| RLS jen s `AFTER INSERT` | Neúplná tenant izolace | + `AFTER UPDATE`, `BEFORE DELETE` |
| `NOT NULL` na computed column | Neplatná SQL syntaxe | Jen `PERSISTED` |
| TPC sequence od 1 na existující DB | Kolize ID | `START WITH > MAX(Id) + buffer` |
| `AddColumn(nullable: false)` na plnou tabulku | Migration selže | Nullable → backfill → NOT NULL |

---

## 19. CHECKLIST PŘED NASAZENÍM

### Nová tabulka
- [ ] PK je `Id INT IDENTITY` nebo sequence
- [ ] Všechny FK mají constraint a index
- [ ] Boolean sloupce jsou `bit`, ne `int`
- [ ] Datetime sloupce jsou `datetime2`, ne `datetime`
- [ ] Defaulty používají `SYSUTCDATETIME()`, ne `GETDATE()`
- [ ] Computed columns nemají `NOT NULL` za `PERSISTED`
- [ ] Tenantský sloupec (`Customer_Id` / `Instance_Id`) je přítomen a indexován

### Migrace existující tabulky
- [ ] NOT NULL sloupce přidávány přes nullable → backfill → NOT NULL
- [ ] TPC sequence inicializována výše než MAX(Id)
- [ ] Migrace testována na kopii produkčních dat
- [ ] ONLINE operace kde možné

### Nový DbContext / EF model
- [ ] Legacy sloupce (`User_Id`) mají `HasColumnName()`
- [ ] TPH: všechny hodnoty diskriminátoru namapovány
- [ ] TPC: `UseHiLo()` nebo sequence, `HasColumnName()` pro sdílené sloupce
- [ ] Identity: `base.OnModelCreating(b)` voláno
- [ ] Computed columns: `HasComputedColumnSql(..., stored: true)`
- [ ] Geography: `UseNetTopologySuite()` v `UseSqlServer()`

### Bezpečnost
- [ ] Aplikační uživatel nemá `db_owner`
- [ ] RLS politika má FILTER + INSERT + UPDATE + DELETE predikáty
- [ ] Connection string není v kódu
