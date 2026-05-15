# ApolloHelpdesk — Plán upgrade a modernizace
## Prioritizovaná doporučení pro soulad s db-design-rules

> Datum analýzy: 2026-04  
> Zdrojový skript: `ApolloHelpdesk.sql`  
> Referenční dokumenty: `db-design-rules.md`, `db-design-instructions.md`, `mssql-design.md`

---

## PŘEHLED PRIORIT

| Priorita | Oblast | Důvod |
|---|---|---|
| 🔴 **KRITICKÁ** | Konfigurace DB | AUTO_SHRINK ON, COMPAT 100, RCSI OFF |
| 🔴 **KRITICKÁ** | Dědičnost TPC | hr.Activity, dbo.Message, helpdesk.TicketAlert |
| 🟡 **VYSOKÁ** | Indexy chybějící | FK bez indexů |
| 🟡 **VYSOKÁ** | Datové typy | GETDATE(), varchar vs. nvarchar |
| 🟢 **STŘEDNÍ** | Query Store | OFF na obou DB |
| 🟢 **STŘEDNÍ** | Pojmenování | `Order` computed column, reserved words |
| ⚪ **NÍZKÁ** | Modernizace | XML → JSON, FILESTREAM, computed columns |

---

## 🔴 BLOK 1 — KRITICKÁ: Konfigurace databáze

### 1.1 AUTO_SHRINK vypnout (IHNED)

**Problém:** `AUTO_SHRINK ON` způsobuje fragmentaci indexů, výkonnostní propady a zbytečné I/O.  
**MSDN:** Anti-pattern, nikdy nezapínat.

```sql
-- Spustit okamžitě, nevyžaduje výpadek
ALTER DATABASE [Apollo_HelpDesk] SET AUTO_SHRINK OFF;
```

### 1.2 READ_COMMITTED_SNAPSHOT zapnout

**Problém:** RCSI OFF → SELECT blokuje nebo je blokován INSERT/UPDATE. Kritické pro EF Core.  
**Upozornění:** Vyžaduje maintenance window (krátce exkluzivní přístup k DB) + zvýší tlak na tempdb.

```sql
-- Spustit v maintenance window
-- Před spuštěním: monitorovat tempdb volné místo (nutné min. 20–30 % volného místa)
ALTER DATABASE [Apollo_HelpDesk] SET READ_COMMITTED_SNAPSHOT ON;
```

### 1.3 Compatibility Level zvýšit

**Problém:** `COMPATIBILITY_LEVEL = 100` = SQL Server 2008 mód — starší optimizer, chybějící funkce.  
**Postup:** Nejdřív otestovat na dev/staging s Query Tuning Assistant (QTA).

```sql
-- Zkontrolovat aktuální verzi serveru
SELECT @@VERSION;

-- Pro SQL Server 2017 (max 140):
ALTER DATABASE [Apollo_HelpDesk] SET COMPATIBILITY_LEVEL = 140;

-- Pro SQL Server 2019+ (max 150):
-- ALTER DATABASE [Apollo_HelpDesk] SET COMPATIBILITY_LEVEL = 150;

-- Po upgradu: spustit QTA pro detekci regresí plánů
-- SSMS → Management → Query Store → Query Tuning Assistant
```

### 1.4 PAGE_VERIFY a TARGET_RECOVERY_TIME

```sql
ALTER DATABASE [Apollo_HelpDesk] SET PAGE_VERIFY CHECKSUM;
ALTER DATABASE [Apollo_HelpDesk] SET TARGET_RECOVERY_TIME = 60 SECONDS;
```

### 1.5 Query Store zapnout

**Problém:** Query Store OFF → žádný přehled o výkonu dotazů, nelze sledovat regrese.

```sql
ALTER DATABASE [Apollo_HelpDesk] SET QUERY_STORE = ON
WITH (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO
);
```

---

## 🔴 BLOK 2 — KRITICKÁ: Dědičnost → TPC migrace

> ⚠️ Toto je největší architektonická změna. Provádět jako součást EF Core integrace, ne jako samostatný SQL upgrade.

### 2.1 hr.Activity → TPC

**Stávající stav:** TPT (Activity_Id jako PK+FK v subtyp tabulkách)  
**Doporučení:** TPC — každý typ má vlastní tabulku se všemi sloupci

**Kroky migrace:**

```sql
-- KROK 1: Zjistit max. existující ID (sequence musí startovat výše!)
SELECT MAX(Id) FROM [hr].[Activity];  -- např. vrátí 15420

-- KROK 2: Vytvořit sequence s dostatečným odstupem
CREATE SEQUENCE [hr].[ActivityIdSequence]
    AS INT
    START WITH 16000      -- MAX(Id) + rezerva
    INCREMENT BY 10       -- HiLo blok pro EF
    NO MAXVALUE;

-- KROK 3: Vytvořit nové TPC tabulky (příklad pro Work)
CREATE TABLE [hr].[Work_New] (
    -- Sloupce z hr.Activity (bázové)
    [Id]                    [int]           NOT NULL,
    [User_Id]               [int]           NOT NULL,
    [Date]                  [date]          NOT NULL,
    [SysDate]               [datetime2](0)  NOT NULL    DEFAULT(SYSUTCDATETIME()),
    [IsClosed]              [bit]           NOT NULL    DEFAULT(0),
    [Note]                  [nvarchar](max) NULL,
    [ActivityTemplate_Id]   [int]           NULL,
    -- Sloupce specifické pro Work
    [From]                  [time](0)       NOT NULL,
    [To]                    [time](0)       NOT NULL,
    [IsHomeOffice]          [bit]           NOT NULL    DEFAULT(0),
    [Department_Id]         [int]           NULL,
    CONSTRAINT [PK_Work] PRIMARY KEY CLUSTERED ([Id])
);

-- KROK 4: Migrovat data z TPT (JOIN Activity + Work)
INSERT INTO [hr].[Work_New]
SELECT
    a.Id, a.User_Id, a.Date, a.SysDate, a.IsClosed, a.Note, a.ActivityTemplate_Id,
    w.[From], w.[To], w.IsHomeOffice, w.Department_Id
FROM [hr].[Activity] a
JOIN [hr].[Work] w ON a.Id = w.Activity_Id;

-- KROK 5: Přidat FK a indexy na nové tabulce
ALTER TABLE [hr].[Work_New] ADD
    CONSTRAINT [FK_Work_User_Id]
        FOREIGN KEY ([User_Id]) REFERENCES [dbo].[User]([Id]),
    CONSTRAINT [FK_Work_ActivityTemplate_Id]
        FOREIGN KEY ([ActivityTemplate_Id]) REFERENCES [hr].[ActivityTemplate]([Id]),
    CONSTRAINT [FK_Work_Department_Id]
        FOREIGN KEY ([Department_Id]) REFERENCES [hr].[Department]([Id]);

CREATE NONCLUSTERED INDEX [IX_Work_User_Id_Date]
    ON [hr].[Work_New] ([User_Id], [Date]);
CREATE NONCLUSTERED INDEX [IX_Work_ActivityTemplate_Id]
    ON [hr].[Work_New] ([ActivityTemplate_Id])
    WHERE [ActivityTemplate_Id] IS NOT NULL;

-- KROK 6: Přejmenovat (po ověření dat a EF integrace)
EXEC sp_rename '[hr].[Work]', '[Work_Old]';
EXEC sp_rename '[hr].[Work_New]', '[Work]';

-- KROK 7: Po ověření v produkci — zahodit staré tabulky
-- DROP TABLE [hr].[Work_Old];
-- DROP TABLE [hr].[Activity];  -- až jsou všechny subtypy migrovány
```

**Stejný postup opakovat pro:** `hr.Holiday`, `hr.Illness`, `hr.WorkShop`, `hr.SickDay`, `hr.Doctor`

### 2.2 dbo.Message → TPC

**Stávající stav:** `dbo.MailMessage` a `dbo.SmsMessage` jako TPT nad `dbo.Message`  
**Doporučení:** TPC — typy jsou vždy dotazovány odděleně

```sql
-- Sequence pro Message ID
CREATE SEQUENCE [dbo].[MessageIdSequence]
    AS INT
    START WITH (SELECT MAX(Id) + 1000 FROM [dbo].[Message])
    INCREMENT BY 10
    NO MAXVALUE;

-- Nová TPC tabulka MailMessage
CREATE TABLE [dbo].[MailMessage_New] (
    [Id]            [int]           NOT NULL,
    [Date]          [datetime2](0)  NOT NULL    DEFAULT(SYSUTCDATETIME()),
    [TextMessage]   [nvarchar](max) NULL,
    [IsSend]        [bit]           NOT NULL    DEFAULT(0),
    [ErrorMessage]  [nvarchar](max) NULL,
    -- Mail-specifické
    [Subject]       [nvarchar](500) NULL,
    [AlternateText] [nvarchar](max) NULL,
    CONSTRAINT [PK_MailMessage] PRIMARY KEY CLUSTERED ([Id])
);

-- Migrovat data
INSERT INTO [dbo].[MailMessage_New]
SELECT m.Id, m.Date, m.TextMessage, m.IsSend, m.ErrorMessage, mm.Subject, mm.AlternateText
FROM [dbo].[Message] m
JOIN [dbo].[MailMessage] mm ON m.Id = mm.Message_Id;

-- Stejně pro SmsMessage (žádné extra sloupce — jen bázové sloupce)
CREATE TABLE [dbo].[SmsMessage_New] (
    [Id]            [int]           NOT NULL,
    [Date]          [datetime2](0)  NOT NULL    DEFAULT(SYSUTCDATETIME()),
    [TextMessage]   [nvarchar](max) NULL,
    [IsSend]        [bit]           NOT NULL    DEFAULT(0),
    [ErrorMessage]  [nvarchar](max) NULL,
    CONSTRAINT [PK_SmsMessage] PRIMARY KEY CLUSTERED ([Id])
);

INSERT INTO [dbo].[SmsMessage_New]
SELECT m.Id, m.Date, m.TextMessage, m.IsSend, m.ErrorMessage
FROM [dbo].[Message] m
WHERE m.Type = 2;  -- SmsMessage typ
```

### 2.3 helpdesk.TicketAlert → TPC

**Stávající stav:** `WatchDogMail` a `WatchDogState` jako TPT nad `TicketAlert`

```sql
-- Nová TPC tabulka WatchDogMail
CREATE TABLE [helpdesk].[WatchDogMail_New] (
    [Id]            [int]   NOT NULL,
    [Ticket_Id]     [int]   NOT NULL,
    [AlertType]     [int]   NOT NULL,
    -- WatchDogMail-specifické
    [Role_Id]       [int]   NULL,
    [UserGroup_Id]  [int]   NULL,
    CONSTRAINT [PK_WatchDogMail] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_WatchDogMail_Ticket_Id]
        FOREIGN KEY ([Ticket_Id]) REFERENCES [helpdesk].[Ticket]([Id])
);

CREATE NONCLUSTERED INDEX [IX_WatchDogMail_Ticket_Id]
    ON [helpdesk].[WatchDogMail_New] ([Ticket_Id]);

-- Migrovat
INSERT INTO [helpdesk].[WatchDogMail_New]
SELECT ta.Id, ta.Ticket_Id, ta.AlertType, wm.Role_Id, wm.UserGroup_Id
FROM [helpdesk].[TicketAlert] ta
JOIN [helpdesk].[WatchDogMail] wm ON ta.Id = wm.WatchDog_Id;
```

---

## 🟡 BLOK 3 — VYSOKÁ: Chybějící indexy

### 3.1 Identifikované FK bez indexů (zkontrolovat a přidat)

```sql
-- Zjistit FK bez indexů v HelpDesk databázi
SELECT
    fk.name AS FKName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    WHERE ic.object_id = fkc.parent_object_id
      AND ic.column_id = fkc.parent_column_id
      AND ic.key_ordinal = 1
)
ORDER BY TableName;
```

**Prioritní indexy k přidání:**

```sql
-- helpdesk schema — klíčové dotazovací vzory
CREATE NONCLUSTERED INDEX [IX_TicketStatus_Ticket_Id]
    ON [helpdesk].[TicketStatus] ([Ticket_Id]);

CREATE NONCLUSTERED INDEX [IX_TicketStatus_ChangeDate]
    ON [helpdesk].[TicketStatus] ([ChangeDate] DESC);

CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id_Project_Id]
    ON [helpdesk].[Ticket] ([Customer_Id], [Project_Id]);

CREATE NONCLUSTERED INDEX [IX_Ticket_Device_Id]
    ON [helpdesk].[Ticket] ([Device_Id])
    WHERE [Device_Id] IS NOT NULL;

-- hr schema
CREATE NONCLUSTERED INDEX [IX_Activity_User_Id_Date]
    ON [hr].[Activity] ([User_Id], [Date]);

-- acc schema
CREATE NONCLUSTERED INDEX [IX_HourlyRate_ValidFrom_ValidTo]
    ON [acc].[HourlyRate] ([ValidFrom], [ValidTo])
    WHERE [ValidTo] IS NULL;

-- dbo schema
CREATE NONCLUSTERED INDEX [IX_UserRole_Customer_Id]
    ON [dbo].[UserRole] ([Customer_Id])
    WHERE [Customer_Id] IS NOT NULL;
```

---

## 🟡 BLOK 4 — VYSOKÁ: Datové typy a defaults

### 4.1 GETDATE() → SYSUTCDATETIME()

**Problém:** `GETDATE()` vrací lokální čas serveru. Při změně timezone nebo DST = nekonzistentní data.

```sql
-- Zjistit všechny výskyty GETDATE() v defaultech
SELECT
    t.name AS TableName,
    c.name AS ColumnName,
    dc.definition AS DefaultDef
FROM sys.default_constraints dc
JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
JOIN sys.tables t ON c.object_id = t.object_id
WHERE dc.definition LIKE '%getdate%'
ORDER BY TableName, ColumnName;

-- Pro každý nalezený default: DROP starý a ADD nový
-- Příklad pro helpdesk.Ticket.CreatedAt:
ALTER TABLE [helpdesk].[Ticket] DROP CONSTRAINT [DF_Ticket_CreatedAt];
ALTER TABLE [helpdesk].[Ticket] ADD CONSTRAINT [DF_Ticket_CreatedAt]
    DEFAULT(SYSUTCDATETIME()) FOR [CreatedAt];
```

### 4.2 Computed column Order → přejmenovat

**Problém:** `helpdesk.Project` má sloupec `Order` (computed) — konflikt s SQL klíčovým slovem.  
**Řešení:** Přejmenovat na `ProjectOrder` nebo `OrderIndex`.

```sql
-- Nejdřív zahodit computed column
ALTER TABLE [helpdesk].[Project] DROP COLUMN [Order];

-- Přidat s novým názvem (uprav výraz dle původní definice)
ALTER TABLE [helpdesk].[Project]
    ADD [ProjectOrder] AS (/* původní výraz */) PERSISTED;

-- Aktualizovat EF konfiguraci:
-- modelBuilder.Entity<Project>().Property(p => p.ProjectOrder).HasColumnName("ProjectOrder");
```

### 4.3 Computed columns — PERSISTED syntax

**Problém:** Computed columns nesmí mít `NOT NULL` za `PERSISTED` — neplatná syntaxe.

```sql
-- Špatně:
-- [Order] AS (...) PERSISTED NOT NULL

-- Správně:
[ProjectOrder] AS (...) PERSISTED
-- Nulovost SQL Server odvozuje z výrazu automaticky
```

---

## 🟢 BLOK 5 — STŘEDNÍ: EF Core integrace

### 5.1 Explicitní HasColumnName pro legacy sloupce

EF Core **nebude automaticky** mapovat sloupce s podtržítkem (`Customer_Id`) na C# vlastnosti (`CustomerId`).

```csharp
// Povinné pro každý FK sloupec s legacy pojmenováním!
modelBuilder.Entity<Ticket>()
    .Property(t => t.CustomerId)
    .HasColumnName("Customer_Id");

modelBuilder.Entity<Ticket>()
    .Property(t => t.ProjectId)
    .HasColumnName("Project_Id");

modelBuilder.Entity<Ticket>()
    .Property(t => t.DeviceId)
    .HasColumnName("Device_Id");

// Identity tabulky
modelBuilder.Entity<ApplicationUser>()
    .ToTable("User", "dbo");

modelBuilder.Entity<ApplicationRole>()
    .ToTable("Role", "dbo");
```

### 5.2 ApplicationUser — Login vs. UserName

```csharp
public class ApplicationUser : IdentityUser<int>
{
    public string Login { get; set; }  // vlastní Login sloupec v DB
    // UserName = Identity standard (normalizace, validace)
}

// Při registraci nastavit obě:
var user = new ApplicationUser { Login = loginValue, UserName = loginValue };
await _userManager.CreateAsync(user, password);
```

### 5.3 UserRole s Customer_Id rozšířením

```csharp
// HelpDesk má nestandardní UserRole s Customer_Id
public class ApplicationUserRole : IdentityUserRole<int>
{
    public int? Customer_Id { get; set; }
    public Customer? Customer { get; set; }
}

// EF konfigurace
modelBuilder.Entity<ApplicationUserRole>()
    .ToTable("UserRole", "dbo")
    .Property(r => r.Customer_Id).HasColumnName("Customer_Id");
```

### 5.4 helpdesk.Project — TPH diskriminátor (kompletní)

**Problém:** TPH diskriminátor `ProjectType_Id` musí mít namapovány **všechny** typy — jinak EF hodí výjimku při materializaci.

```csharp
// Všechny typy MUSÍ být registrovány — P, O, I, S, C
modelBuilder.Entity<Project>()
    .HasDiscriminator<string>("ProjectType_Id")
    .HasValue<InternalProject>("I")
    .HasValue<OutsourcedProject>("O")
    .HasValue<ServiceProject>("S")
    .HasValue<ContinuationProject>("C")
    .HasValue<Project>("P");  // base type
```

### 5.5 dbo.File — FILESTREAM

```csharp
public class File
{
    public int Id { get; set; }
    public Guid FileId { get; set; }  // ROWGUIDCOL
    public string Name { get; set; }
    public string ContentType { get; set; }
    public long Size { get; set; }

    [NotMapped]  // FILESTREAM data - načítat raw SQL nebo file storage
    public byte[]? Data { get; set; }
}

modelBuilder.Entity<File>()
    .Property(f => f.FileId)
    .ValueGeneratedOnAdd()  // ROWGUIDCOL
    .HasDefaultValueSql("NEWID()");
```

### 5.6 XML sloupce jako string

```csharp
// dbo.Customer.TextResources, frm.FormInstance.StaticFormXml, dbo.UserFilter.Value
modelBuilder.Entity<Customer>()
    .Property(c => c.TextResources)
    .HasColumnType("xml");  // uloženo jako xml, čteno jako string v C#

// Do budoucna zvážit: migrace z xml na nvarchar(max) s JSON
```

---

## 🟢 BLOK 6 — STŘEDNÍ: Row-Level Security (multi-tenant)

HelpDesk je multi-tenant systém s `Customer_Id` jako tenant klíčem. Pokud EF Core neřeší tenant izolaci na aplikační vrstvě, přidej RLS jako pojistku.

```sql
-- Tenant filter funkce
CREATE FUNCTION [security].[fn_HelpdeskTenantFilter](@CustomerId INT)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT 1 AS [Result]
    WHERE @CustomerId = CAST(SESSION_CONTEXT(N'CustomerId') AS INT)
       OR IS_ROLEMEMBER('db_owner') = 1;

-- Policy na klíčové tabulky
CREATE SECURITY POLICY [security].[HelpdeskTenantPolicy]
    ADD FILTER PREDICATE [security].[fn_HelpdeskTenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket],
    ADD BLOCK PREDICATE [security].[fn_HelpdeskTenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket] AFTER INSERT,
    ADD BLOCK PREDICATE [security].[fn_HelpdeskTenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket] AFTER UPDATE,
    ADD BLOCK PREDICATE [security].[fn_HelpdeskTenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket] BEFORE DELETE
WITH (STATE = ON, SCHEMABINDING = ON);
```

```csharp
// EF Core DbContext — nastavit session context před každým dotazem
public override async Task<int> SaveChangesAsync(CancellationToken ct = default)
{
    await Database.ExecuteSqlRawAsync(
        "EXEC sp_set_session_context N'CustomerId', {0}", _currentTenantId);
    return await base.SaveChangesAsync(ct);
}
```

---

## ⚪ BLOK 7 — NÍZKÁ: Modernizace (long-term)

### 7.1 XML → JSON migrace

**Kandidáti:** `dbo.Customer.TextResources`, `frm.FormInstance.StaticFormXml`, `dbo.UserFilter.Value`

```sql
-- Nový sloupec JSON
ALTER TABLE [dbo].[Customer] ADD [TextResourcesJson] NVARCHAR(MAX) NULL;

-- Migrovat obsah (pokud struktura je jednoduchá)
UPDATE [dbo].[Customer]
SET [TextResourcesJson] = [TextResources]  -- nebo přes aplikaci
WHERE [TextResources] IS NOT NULL;

-- Ověřit validitu JSON
SELECT Id FROM [dbo].[Customer]
WHERE ISJSON([TextResourcesJson]) = 0 AND [TextResourcesJson] IS NOT NULL;

-- Zahodit starý XML sloupec (po ověření)
-- ALTER TABLE [dbo].[Customer] DROP COLUMN [TextResources];
-- EXEC sp_rename '[dbo].[Customer].[TextResourcesJson]', 'TextResources', 'COLUMN';
```

### 7.2 varchar → nvarchar (postupně)

Pro sloupce, které mohou obsahovat vícejazyčné znaky (jména, adresy, poznámky):

```sql
-- Zjistit varchar sloupce (kandidáti na změnu)
SELECT t.name AS TableName, c.name AS ColumnName, tp.name AS DataType, c.max_length
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.types tp ON c.user_type_id = tp.user_type_id
WHERE tp.name = 'varchar'
  AND t.is_ms_shipped = 0
ORDER BY TableName, ColumnName;
```

### 7.3 Dynamic Data Masking pro citlivá data

```sql
-- Ochrana osobních dat (GDPR)
ALTER TABLE [dbo].[User]
    ALTER COLUMN [Email] ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE [dbo].[User]
    ALTER COLUMN [Phone] ADD MASKED WITH (FUNCTION = 'default()');

ALTER TABLE [dbo].[User]
    ALTER COLUMN [Mobil] ADD MASKED WITH (FUNCTION = 'default()');

-- Privileged users (admini vidí nemasky)
GRANT UNMASK ON [dbo].[User] TO [AppAdmin];
```

### 7.4 Temporal Tables pro auditní trail

Zvážit pro klíčové tabulky kde je potřeba kompletní změnová historie:

```sql
-- Kandidáti: dbo.Customer, helpdesk.Ticket, acc.HourlyRate
ALTER TABLE [helpdesk].[Ticket]
    ADD [ValidFrom] DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
                   CONSTRAINT [DF_Ticket_ValidFrom] DEFAULT SYSUTCDATETIME(),
        [ValidTo]   DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
                   CONSTRAINT [DF_Ticket_ValidTo] DEFAULT '9999-12-31 23:59:59.9999999',
        PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo]);

ALTER TABLE [helpdesk].[Ticket]
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [helpdesk].[TicketHistory]));
```

> ⚠️ Temporal tables a EF Core: vyžaduje EF Core 6+ s `UseTemporalTable()`. Pozor na kompatibilitu s existujícími migracemi.

---

## SOUHRN — Pořadí implementace

```
Fáze 1 (OKAMŽITĚ — bez výpadku):
  □ AUTO_SHRINK OFF
  □ PAGE_VERIFY CHECKSUM
  □ TARGET_RECOVERY_TIME = 60 SECONDS
  □ Query Store zapnout

Fáze 2 (Maintenance window — krátký výpadek):
  □ READ_COMMITTED_SNAPSHOT ON
  □ COMPATIBILITY_LEVEL = 140 (po testování na staging)

Fáze 3 (S EF Core integrací):
  □ Chybějící indexy na FK
  □ GETDATE() → SYSUTCDATETIME() na nových objektech
  □ HasColumnName() pro legacy FK sloupce
  □ UserRole s Customer_Id rozšířením
  □ Project TPH — doplnit typy S a C

Fáze 4 (TPC migrace — major change):
  □ hr.Activity → TPC (Work, Holiday, Illness, WorkShop, SickDay, Doctor)
  □ dbo.Message → TPC (MailMessage, SmsMessage)
  □ helpdesk.TicketAlert → TPC (WatchDogMail, WatchDogState)

Fáze 5 (Long-term modernizace):
  □ XML → JSON pro TextResources, UserFilter.Value
  □ varchar → nvarchar pro vícejazyčné sloupce
  □ Dynamic Data Masking pro GDPR data
  □ Temporal Tables pro auditní trail (Ticket, Customer, HourlyRate)
  □ Row-Level Security pro tenant izolaci
```
