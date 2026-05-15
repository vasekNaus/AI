# Instrukce pro návrh MSSQL databáze
## Kompaktní průvodce pro EF Core projekty

> Verze: 2026-04  
> Platí pro: SQL Server 2017–2022, EF Core 7+, ASP.NET Core, C# 10+

---

## ► KROK 0 — Checklist před prvním CREATE TABLE

```
□ Definované domény (bounded contexts)?
□ Jasný tenant model (single vs. multi-tenant)?
□ Dědičnostní hierarchie (IS-A vs. HAS-A vs. 1:1)?
□ Přístupové vzory (kdo dotazuje co, jak často, s jakými filtry)?
□ Platnostní data (ValidFrom/ValidTo)? Nebo auditní trail (Temporal)?
□ EF Core strategie (TPC / TPT / TPH / 1:1)?
□ Jak se generují ID (IDENTITY, Sequence, HiLo, GUID)?
```

---

## ► KONFIGURACE DATABÁZE (povinné)

```sql
ALTER DATABASE [DB] SET AUTO_SHRINK OFF;                    -- nikdy nezapínat
ALTER DATABASE [DB] SET AUTO_CLOSE OFF;                     -- nikdy nezapínat
ALTER DATABASE [DB] SET READ_COMMITTED_SNAPSHOT ON;         -- klíčové pro EF Core
ALTER DATABASE [DB] SET PAGE_VERIFY CHECKSUM;
ALTER DATABASE [DB] SET RECOVERY FULL;
ALTER DATABASE [DB] SET TARGET_RECOVERY_TIME = 60 SECONDS;
ALTER DATABASE [DB] SET COMPATIBILITY_LEVEL = 160;          -- 140=SQL17, 150=SQL19, 160=SQL22

ALTER DATABASE [DB] SET QUERY_STORE = ON WITH (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO
);
```

---

## ► SCHÉMATA

```
dbo        → infrastruktura sdílená přes domény (User, Role, Tenant, File, Log)
{domain}   → jeden bounded context (helpdesk, billing, hr, crm, ...)
cfg        → sdílené číselníky a konfigurace
```

**Pravidla:**
- 1 doména = 1 schéma
- Cross-schema FK jsou povoleny, ale dokumentovat
- `dbo` NIKDY pro doménové tabulky

---

## ► NAMING KONVENCE

| Prvek | Pravidlo | Příklad | ❌ Zakázáno |
|---|---|---|---|
| Tabulka | PascalCase, singulár | `Ticket` | `tickets`, `tbl_Ticket` |
| Sloupec | PascalCase | `FirstName` | `first_name` |
| PK | vždy `Id INT IDENTITY(1,1)` | `[Id] INT IDENTITY(1,1) NOT NULL` | `TicketId`, `ID` |
| FK | `{Tabulka}_Id` | `Customer_Id` | `CustomerId` |
| Boolean | prefix `Is` | `IsActive` | `Active`, `Flag` |
| Platnostní | `ValidFrom` / `ValidTo` | nullable `ValidTo` = stále platné | `DateFrom` |
| Soft delete | `DeletedAt datetime2 NULL` | NULL = aktivní | `IsDeleted bit` |
| PK constraint | `PK_{Tabulka}` | `PK_Ticket` | — |
| FK constraint | `FK_{Tabulka}_{Ref}_{Sloupec}` | `FK_Ticket_Customer_Id` | volně pojmenované |
| Index | `IX_{Tabulka}_{Sloupce}` | `IX_Ticket_Customer_Id` | `idx1` |
| Unique index | `UX_{Tabulka}_{Sloupce}` | `UX_User_Login` | — |
| Views | `v{Název}` | `vTicketSummary` | `View_Ticket` |
| Stored proc. | `{schema}.{Akce}{Entita}` | `billing.CreateInvoice` | `sp_`, `usp_` |
| Sequence | `{schema}.{Entita}IdSequence` | `hr.ActivityIdSequence` | — |
| Junction tabulka | konkatenace | `CustomerCategory` | `Customer_Category` |

---

## ► DATOVÉ TYPY

| Typ | Použití | ❌ Nikdy |
|---|---|---|
| `int` | PK, FK | — |
| `bigint` | IMEI, snowflake ID | jako FK pro malé číselníky |
| `uniqueidentifier` | GUID, external API | výkonnostně kritické PK (fragmentace) |
| `nvarchar(n)` | všechny uživatelské texty | `varchar` pro multilingual |
| `nvarchar(max)` | JSON, XML jako string, dlouhé texty | jako náhrada krátkých textů |
| `char(1)` | diskriminátor, fixní kódy | variabilní text |
| `bit` | boolean | `int` pro boolean |
| `datetime2(0)` | časové značky (sekundy) | starý `datetime` — NIKDY |
| `date` | pouze datum | `datetime2` pokud nepotřebuješ čas |
| `decimal(p,s)` | peníze, sazby | `float` / `real` pro peníze — NIKDY |
| `geography` | GPS, geometrie | `varchar` pro GPS — NIKDY |
| `rowversion` | EF optimistická souběžnost | pro datetime |

**Vždy UTC:** `DEFAULT(SYSUTCDATETIME())` — NIKDY `GETDATE()` (vrací lokální čas serveru)

---

## ► PRIMÁRNÍ KLÍČE

```sql
[Id] INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Tabulka] PRIMARY KEY CLUSTERED
```

- Standard: `INT IDENTITY(1,1)` — nejrychlejší clustered index
- GUID: použít `NEWSEQUENTIALID()` jako default — nikdy `NEWID()` (náhodné = fragmentace)
- TPC hierarchie: použít `SEQUENCE` + EF `UseHiLo()` pro globálně unikátní ID
- Maximálně 32 sloupců v PK, max. délka klíče 900 B

---

## ► CIZÍ KLÍČE A INDEXY

```sql
-- Každý FK musí mít index!
CONSTRAINT [FK_Ticket_Customer_Id] FOREIGN KEY ([Customer_Id])
    REFERENCES [dbo].[Customer]([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket] ([Customer_Id]);
```

- `ON DELETE CASCADE` — VÝJIMEČNĚ, jen u 1:N kde child nemá smysl bez parent
- `ON DELETE SET NULL` — pro volitelné vazby
- `ON DELETE NO ACTION` — výchozí (explicit je lepší)
- Composite index: řadit sloupce od nejselektivnějšího po nejméně selektivní
- INCLUDE sloupce: pro covering index (eliminuje key lookup)
- Filtered index: pro well-defined subset (`WHERE IsActive = 1`)

---

## ► DĚDIČNOSTNÍ ROZHODOVÁNÍ (TPC / TPT / TPH)

### Rozhodovací strom

```
Je hierarchie IS-A?
├── NE → 1:1 relace (WithOne/HasOne)
└── ANO → 
    Dotazuješ se na konkrétní typy samostatně?
    ├── ANO, většinou → TPC (Table Per Concrete)
    │   ├── Každý concrete typ = vlastní tabulka se VŠEMI sloupci
    │   ├── Polymorfní dotaz = UNION ALL (nebo view)
    │   └── ID generovat přes Sequence/HiLo (globálně unikátní!)
    └── NE → 
        Hodně sdílených sloupců a polymorfní dotazy?
        ├── ANO + malá hierarchie → TPH (Table Per Hierarchy)
        │   └── Jedna tabulka + discriminator sloupec
        └── ANO + FK target z jiných tabulek → TPT (Table Per Type)
            └── Base tabulka jako FK target, subtabulky s vlastními sloupci
```

### Stručné pravidlo

| Strategie | Kdy | EF Core |
|---|---|---|
| **TPC** ✅ (preferováno) | Typy vždy dotazovány samostatně | `UseTpcMappingStrategy()` + Sequence |
| **TPH** | Diskriminátor v jedné tabulce, polymorfní dotazy | `HasDiscriminator()` |
| **TPT** | Base tabulka je FK target z jiných tabulek | `ToTable()` na každém subtypu |
| **1:1** | Per-domain konfigurace, rozšíření (není IS-A) | `HasOne().WithOne()` |

### TPC — kritické detaily

```sql
-- Sequence pro globální ID (start výše než MAX existujících ID!)
CREATE SEQUENCE [hr].[ActivityIdSequence]
    AS INT START WITH 1000 INCREMENT BY 10 NO MAXVALUE;

-- Každá TPC tabulka musí mít vlastní FK + indexy (nedědí se z abstraktní třídy!)
ALTER TABLE [hr].[Work] ADD CONSTRAINT [FK_Work_User_Id]
    FOREIGN KEY ([User_Id]) REFERENCES [dbo].[User]([Id]);
CREATE NONCLUSTERED INDEX [IX_Work_User_Id] ON [hr].[Work] ([User_Id]);
```

```csharp
// EF Core TPC konfigurace
modelBuilder.Entity<Activity>().UseTpcMappingStrategy();
modelBuilder.Entity<Activity>().Property(a => a.Id).UseHiLo("ActivityHiLoSequence", "hr");
modelBuilder.Entity<Work>().ToTable("Work", "hr");
modelBuilder.Entity<Holiday>().ToTable("Holiday", "hr");
```

---

## ► STORED PROCEDURES — BEZPEČNÝ VZOR

```sql
CREATE OR ALTER PROCEDURE [schema].[DoSomething] @Param INT AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- automatický rollback při chybě

    BEGIN TRAN;
        -- Kontrola existence UVNITŘ transakce s UPDLOCK, HOLDLOCK (anti race-condition)
        IF EXISTS (SELECT 1 FROM [dbo].[Tabulka] WITH (UPDLOCK, HOLDLOCK) WHERE ...)
        BEGIN
            ROLLBACK;
            THROW 50001, 'Záznam již existuje.', 1;  -- ne RETURN -1 !
            RETURN;
        END

        -- operace
    COMMIT;
END
```

---

## ► VALIDFROM / VALIDTO PATTERN

```sql
-- Inline predikát (NE skalární UDF — způsobuje row-by-row scan!)
WHERE ValidFrom <= SYSUTCDATETIME()
  AND (ValidTo IS NULL OR ValidTo > SYSUTCDATETIME())

-- Index pro tento pattern
CREATE NONCLUSTERED INDEX [IX_Tabulka_ValidFrom_ValidTo]
ON [schema].[Tabulka] ([ValidFrom], [ValidTo])
WHERE [ValidTo] IS NULL;  -- filtered = jen aktuálně platné
```

```csharp
// EF Core extension method
public static IQueryable<T> ValidNow<T>(this IQueryable<T> q) where T : ITemporalValidity
    => q.Where(e => e.ValidFrom <= DateTime.UtcNow && (e.ValidTo == null || e.ValidTo > DateTime.UtcNow));
```

---

## ► ROW-LEVEL SECURITY (multi-tenant)

```sql
CREATE FUNCTION [security].[fn_TenantFilter](@TenantId INT)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT 1 AS [Result]
    WHERE @TenantId = CAST(SESSION_CONTEXT(N'TenantId') AS INT)
       OR IS_ROLEMEMBER('db_owner') = 1;

CREATE SECURITY POLICY [security].[TenantPolicy]
    ADD FILTER PREDICATE [security].[fn_TenantFilter]([Tenant_Id]) ON [dbo].[Order],
    ADD BLOCK PREDICATE  [security].[fn_TenantFilter]([Tenant_Id]) ON [dbo].[Order] AFTER INSERT,
    ADD BLOCK PREDICATE  [security].[fn_TenantFilter]([Tenant_Id]) ON [dbo].[Order] AFTER UPDATE,
    ADD BLOCK PREDICATE  [security].[fn_TenantFilter]([Tenant_Id]) ON [dbo].[Order] BEFORE DELETE
WITH (STATE = ON, SCHEMABINDING = ON);
```

---

## ► INDEXY — PRAVIDLA (MSDN)

1. **OLTP** → úzké rowstore indexy; **OLAP/DWH** → clustered columnstore
2. Každý FK = povinný index
3. Raději přidej `INCLUDE` do existujícího než vytvářej nový podobný
4. Filtered index pro well-defined subset dat
5. Nepřeindexovat: každý index zpomaluje INSERT/UPDATE/DELETE
6. Max. fragmentace: REBUILD > 30 %, REORGANIZE 10–30 %
7. NIKDY: skalární UDF ve WHERE/JOIN (→ row-by-row scan)
8. NIKDY: funkce na indexovaném sloupci ve WHERE (`YEAR(CreatedAt)` = no seek)

---

## ► EF CORE — MIGRACE BEZPEČNÝ VZOR

```csharp
// NOT NULL sloupec na plnou tabulku — nikdy jedním krokem!
// Krok 1: přidat jako nullable s default
migrationBuilder.AddColumn<string>("Status", "Ticket", nullable: true, defaultValue: "Open");
// Krok 2: backfill dat (raw SQL)
migrationBuilder.Sql("UPDATE helpdesk.Ticket SET Status = 'Open' WHERE Status IS NULL");
// Krok 3: NOT NULL constraint
migrationBuilder.AlterColumn<string>("Status", "Ticket", nullable: false);
```

---

## ► ASP.NET IDENTITY VZOR

```csharp
// Vždy explicitní mapování legacy sloupců s podtržítkem
modelBuilder.Entity<ApplicationUser>()
    .ToTable("User", "dbo")
    .Property(u => u.Id).HasColumnName("Id");

// Login vs. UserName — nastavit obě při registraci
user.UserName = user.Login = loginValue;

// UserRole s rozšiřujícím sloupcem
public class ApplicationUserRole : IdentityUserRole<int> {
    public int Customer_Id { get; set; }
}
```

---

## ► QUERY STORE — POVINNÁ KONFIGURACE

```sql
ALTER DATABASE [DB] SET QUERY_STORE = ON WITH (
    OPERATION_MODE = READ_WRITE,      -- nikdy READ_ONLY v produkci
    MAX_STORAGE_SIZE_MB = 1000,       -- min 500 MB pro prod
    QUERY_CAPTURE_MODE = AUTO,        -- SQL 2019+: CUSTOM
    SIZE_BASED_CLEANUP_MODE = AUTO,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30)
);
-- Po upgradu COMPATIBILITY_LEVEL: použít Query Tuning Assistant (QTA)
```

---

## ► DATA COMPRESSION (pro velké tabulky)

```sql
ALTER TABLE [dbo].[Order] REBUILD WITH (DATA_COMPRESSION = PAGE, ONLINE = ON);
ALTER INDEX [IX_Order_Customer_Id] ON [dbo].[Order] REBUILD WITH (DATA_COMPRESSION = PAGE, ONLINE = ON);
-- ⚠️ Pouze Enterprise/Developer edice. Off-row data (LOB, XML) se nekomprimují.
```

---

## ► TOP 15 ANTI-PATTERNS

| Anti-pattern | Řešení |
|---|---|
| `AUTO_SHRINK ON` | Vypnout okamžitě |
| `GETDATE()` jako default | `SYSUTCDATETIME()` (UTC) |
| Skalární UDF ve WHERE | Inline TVF nebo přepsat na predikát |
| Funkce na indexovaném sloupci | `WHERE CreatedAt >= '2024-01-01'` (ne `YEAR(CreatedAt)=2024`) |
| `NOT IN (subquery)` s NULL | `NOT EXISTS` — NULL v IN = prázdný výsledek |
| `SELECT *` v produkci | Explicitní seznam sloupců |
| `float` pro peníze | `decimal(p,s)` |
| GUID jako clustered PK s `NEWID()` | `NEWSEQUENTIALID()` nebo IDENTITY |
| Spekulativní indexy "pro jistotu" | Index až po ověření plánem |
| FK bez indexu | Vždy `CREATE INDEX` po `CREATE FK` |
| Implicit type conversion ve WHERE | Stejné typy operandů (jinak = scan) |
| `varchar` pro multilingual text | `nvarchar` |
| NOT NULL migration jedním krokem | 3 kroky: nullable → backfill → NOT NULL |
| RLS jen s FILTER predikátem | FILTER + všechny 3 BLOCK predikáty |
| Absence XACT_ABORT v stored proc | `SET XACT_ABORT ON` vždy |

---

## ► DEPLOYMENT CHECKLIST

```
□ AUTO_SHRINK OFF, AUTO_CLOSE OFF
□ READ_COMMITTED_SNAPSHOT ON (maintenance window!)
□ COMPATIBILITY_LEVEL nastaveno dle verze serveru
□ QUERY_STORE ON s dostatečným MAX_STORAGE_SIZE_MB
□ Každý FK má index
□ Všechny defaults používají SYSUTCDATETIME()
□ Žádné skalární UDF ve WHERE klauzulích
□ TPC tabulky mají vlastní FK + indexy
□ Stored procedures mají SET XACT_ABORT ON
□ RLS policy má FILTER + AFTER INSERT + AFTER UPDATE + BEFORE DELETE
□ EF Core migrations: NOT NULL přidávána ve 3 krocích
□ Identity: explicitní HasColumnName() pro legacy sloupce s podtržítkem
```
