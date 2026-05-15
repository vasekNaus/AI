# 04 — Datové typy a primární klíče

> Správný typ = správný výkon · UTC všude · IDENTITY jako standard

---

## Datové typy — přehled

| SQL typ | Kdy použít | ❌ Nikdy použít pro |
|---|---|---|
| `int` | PK, FK, čítače (do ~2 mld) | velká čísla (IMEI, hash) |
| `bigint` | IMEI, snowflake ID, velké čítače | zbytečně na malé číselníky |
| `uniqueidentifier` | GUID pro API, external systems | výkonnostně kritické PK (fragmentace!) |
| `nvarchar(n)` | **všechny uživatelské texty** (multilingual) | krátké systémové kódy |
| `varchar(n)` | ASCII systémové hodnoty, kódy | uživatelský text (vícejazyčné znaky!) |
| `nvarchar(max)` | JSON, XML jako string, dlouhé texty | jako náhrada krátkých textů (nelze indexovat) |
| `char(1)` / `nchar(n)` | diskriminátor TPH, fixní kódy | variabilní text |
| `bit` | boolean | `int`, `tinyint` pro boolean! |
| `datetime2(0)` | časové značky (přesnost sekundy) | starý `datetime` — **NIKDY** |
| `datetime2(7)` | audit timestamp (vysoká přesnost) | — |
| `date` | pouze datum (bez času) | `datetime2` pokud nepotřebuješ čas |
| `time(0)` | pouze čas dne | `varchar` pro čas! |
| `decimal(p,s)` | peníze, sazby, podíly | `float`/`real` pro peníze — **NIKDY** |
| `float` / `real` | fyzikální hodnoty (vzdálenosti, váhy) | peníze, měnové kurzy |
| `geography` | GPS souřadnice, geometrie | `varchar` pro GPS — **NIKDY** |
| `rowversion` | EF Core optimistická souběžnost | pro datetime |
| `xml` | strukturované XML (zvážit JSON místo) | obecný text |

---

## Časové typy — pravidla

```sql
-- ✅ SPRÁVNĚ — vždy UTC
[CreatedAt]     [datetime2](0)  NOT NULL    DEFAULT(SYSUTCDATETIME()),
[ValidFrom]     [datetime2](0)  NOT NULL,
[ValidTo]       [datetime2](0)  NULL,       -- NULL = platí dodnes
[WorkDate]      [date]          NOT NULL,   -- jen datum, bez UTC konverze
[ShiftStart]    [time](0)       NOT NULL,   -- jen čas dne

-- ❌ ŠPATNĚ
[CreatedAt]     [datetime]      ...                     -- starý typ, zaokrouhluje na 3ms
[CreatedAt]     [datetime2](0)  DEFAULT(GETDATE())      -- lokální čas serveru, ne UTC!
[ValidTo]       [datetime2](0)  NOT NULL DEFAULT('9999-12-31')  -- raději NULL pro "platí stále"
```

> **`SYSUTCDATETIME()`** = UTC čas serveru (správně)  
> **`GETDATE()`** = lokální čas serveru (špatně — závisí na nastavení serveru a DST)

---

## Zakázané kombinace (rychlý přehled)

```
❌ float / real pro peníze       → zaokrouhlovací chyby, nepoužívat pro finance
❌ varchar pro uživatelský text   → při vícejazyčných znacích ztráta dat
❌ varchar pro GPS souřadnice    → nelze počítat vzdálenosti, nelze indexovat
❌ int pro boolean               → používat bit
❌ datetime (starý typ)          → datetime2 vždy, všude
❌ nvarchar(max) všude           → konkrétní délka pro indexovatelnost
❌ NULL jako příznak stavu       → použít konkrétní bit nebo enum sloupec
❌ GETDATE() jako default        → SYSUTCDATETIME() (UTC)
```

---

## Primární klíče

### Standard — INT IDENTITY

```sql
-- Vždy tento vzor pro nové tabulky
[Id] INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED

-- MSDN limity:
-- • Max. 32 sloupců v PK
-- • Max. délka klíče 900 bytů (nvarchar(450) = přesně 900 B)
```

### GUID primární klíč

```sql
-- ✅ GUID bez fragmentace: NEWSEQUENTIALID() = sekvenční GUID
[Id] UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWSEQUENTIALID())
     CONSTRAINT [PK_Entity] PRIMARY KEY CLUSTERED

-- ❌ Nikdy NEWID() jako clustered PK — náhodné GUID = 50% page splits = fragmentace
```

### TPC hierarchie — Sequence + HiLo

```sql
-- Všechny concrete tabulky sdílí jednu sequence pro globálně unikátní ID
CREATE SEQUENCE [hr].[ActivityIdSequence]
    AS INT
    START WITH 1000          -- při migraci: MAX(existujícího Id) + rezerva!
    INCREMENT BY 10          -- HiLo blok (EF alokuje bloky po 10)
    NO MAXVALUE;

-- EF Core konfigurace
modelBuilder.Entity<Activity>()
    .Property(a => a.Id)
    .UseHiLo("ActivityHiLoSequence", "hr");
```

> ⚠️ Při migraci existujících dat: Sequence musí startovat **výše** než `MAX(Id)` v existujících tabulkách — jinak vznikají kolize PK!

### Nestandardní PK (legacy / externe systémy)

```csharp
// IMEI jako bigint PK (ne IDENTITY)
modelBuilder.Entity<Tracker>()
    .HasKey(t => t.IMEI);
modelBuilder.Entity<Tracker>()
    .Property(t => t.IMEI)
    .ValueGeneratedNever();

// Kompozitní PK
modelBuilder.Entity<Plan>()
    .HasKey(p => new { p.Version, p.PlanVersionId });
```

---

## Computed columns

```sql
-- PERSISTED: výraz se uloží fyzicky (lze indexovat)
-- ⚠️ PERSISTED NOT NULL je NEPLATNÁ syntaxe — nulovost SQL Server odvodí sám z výrazu
[FullName] AS ([FirstName] + ' ' + [LastName]) PERSISTED

-- Indexování computed column — výraz musí být deterministický
CREATE NONCLUSTERED INDEX [IX_User_FullName]
ON [dbo].[User] ([FullName]);
```

```csharp
// EF Core mapování computed column
modelBuilder.Entity<User>()
    .Property(u => u.FullName)
    .HasComputedColumnSql("[FirstName] + ' ' + [LastName]", stored: true);
```
