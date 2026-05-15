# 08 — ValidFrom/ValidTo a Temporal Tables

> Inline predikát (ne UDF) · UTC vždy · Temporal pro auditní trail

---

## ValidFrom/ValidTo pattern (business validity)

Používá se pro záznamy, které mají **obchodní platnost** v čase — sazby, konfigurace, přiřazení.

### Vzor sloupců

```sql
CREATE TABLE [acc].[HourlyRate] (
    [Id]        [int]           IDENTITY(1,1)   NOT NULL,
    [Rate]      [decimal](10,2)                 NOT NULL,
    -- Platnostní sloupce: ValidFrom povinný, ValidTo NULL = platí dosud
    [ValidFrom] [datetime2](0)                  NOT NULL,
    [ValidTo]   [datetime2](0)                  NULL,
    CONSTRAINT [PK_HourlyRate] PRIMARY KEY CLUSTERED ([Id]),
    -- Business rule: ValidTo musí být po ValidFrom
    CONSTRAINT [CK_HourlyRate_Validity] CHECK ([ValidTo] IS NULL OR [ValidTo] > [ValidFrom])
);

-- Index pro dotazy na aktuálně platné záznamy
CREATE NONCLUSTERED INDEX [IX_HourlyRate_ValidFrom_ValidTo]
    ON [acc].[HourlyRate] ([ValidFrom], [ValidTo])
    WHERE [ValidTo] IS NULL;  -- filtered index = jen aktuálně platné
```

### Správný WHERE predikát (NE skalární UDF!)

```sql
-- ✅ Inline predikát — optimizer může použít index
WHERE [ValidFrom] <= SYSUTCDATETIME()
  AND ([ValidTo] IS NULL OR [ValidTo] > SYSUTCDATETIME())

-- ❌ Skalární UDF — row-by-row scan, ignoruje index
WHERE [dbo].[fn_IsCurrentlyValid]([ValidFrom], [ValidTo]) = 1
```

### EF Core — extension method

```csharp
public interface ITemporalValidity
{
    DateTime ValidFrom { get; set; }
    DateTime? ValidTo  { get; set; }
}

// Extension method — použitelný na libovolnou entitu s ValidFrom/ValidTo
public static class QueryExtensions
{
    public static IQueryable<T> ValidNow<T>(this IQueryable<T> query)
        where T : ITemporalValidity
        => query.Where(e =>
            e.ValidFrom <= DateTime.UtcNow &&
            (e.ValidTo == null || e.ValidTo > DateTime.UtcNow));

    public static IQueryable<T> ValidAt<T>(this IQueryable<T> query, DateTime at)
        where T : ITemporalValidity
        => query.Where(e =>
            e.ValidFrom <= at &&
            (e.ValidTo == null || e.ValidTo > at));
}

// Použití
var currentRate = await context.HourlyRates.ValidNow().FirstOrDefaultAsync();
var rateAtDate  = await context.HourlyRates.ValidAt(someDate).FirstOrDefaultAsync();
```

---

## Temporal Tables — System-Versioned (auditní trail)

Používá se pro **úplnou historii změn** záznamu — SQL Server ukládá každou verzi automaticky.

### Vytvoření temporal table

```sql
CREATE TABLE [helpdesk].[Ticket] (
    [Id]            INT             NOT NULL CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED,
    [Title]         NVARCHAR(300)   NOT NULL,
    [Customer_Id]   INT             NOT NULL,
    [IsActive]      BIT             NOT NULL DEFAULT(1),
    -- Systémové sloupce (HIDDEN = neobjeví se v SELECT *)
    [ValidFrom]     DATETIME2(7)    GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
                    CONSTRAINT [DF_Ticket_ValidFrom] DEFAULT SYSUTCDATETIME(),
    [ValidTo]       DATETIME2(7)    GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
                    CONSTRAINT [DF_Ticket_ValidTo] DEFAULT '9999-12-31 23:59:59.9999999',
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [helpdesk].[TicketHistory]));
```

### Dotazy na historická data

```sql
-- Stav záznamu k určitému okamžiku
SELECT * FROM [helpdesk].[Ticket]
FOR SYSTEM_TIME AS OF '2024-06-01T00:00:00';

-- Vše co platilo v časovém rozsahu
SELECT * FROM [helpdesk].[Ticket]
FOR SYSTEM_TIME BETWEEN '2024-01-01' AND '2024-12-31';

-- Kompletní historie jednoho záznamu (včetně aktuálního stavu)
SELECT * FROM [helpdesk].[Ticket]
FOR SYSTEM_TIME ALL
WHERE [Id] = 42
ORDER BY [ValidFrom];
```

### EF Core 6+ podpora

```csharp
// Konfigurace v DbContext
modelBuilder.Entity<Ticket>()
    .ToTable("Ticket", "helpdesk", tb => tb.IsTemporal(t =>
    {
        t.HasPeriodStart("ValidFrom");
        t.HasPeriodEnd("ValidTo");
        t.UseHistoryTable("TicketHistory", "helpdesk");
    }));

// Point-in-time dotaz
var ticketInJune = await context.Tickets
    .TemporalAsOf(new DateTime(2024, 6, 1))
    .Where(t => t.Id == 42)
    .FirstOrDefaultAsync();

// Kompletní historia
var history = await context.Tickets
    .TemporalAll()
    .Where(t => t.Id == 42)
    .OrderBy(t => EF.Property<DateTime>(t, "ValidFrom"))
    .ToListAsync();
```

---

## Porovnání: ValidFrom/ValidTo vs. Temporal Tables

| Kritérium | ValidFrom/ValidTo | Temporal Table |
|---|---|---|
| **Business validity** (aktivní/neaktivní) | ✅ Přirozené | ❌ Není pro to určeno |
| **Auditní trail** (kdo co kdy změnil) | ❌ Manuální logika | ✅ Automaticky |
| **Point-in-time dotaz** | ❌ Složitý WHERE | ✅ `FOR SYSTEM_TIME AS OF` |
| **EF Core podpora** | ✅ Plná (interface + extension) | ✅ EF Core 6+ (UseTemporalTable) |
| **Overlap kontrola** | Manuální CHECK nebo SP | Automatická |
| **Přidání na existující tabulku** | Jednoduché ALTER TABLE | ALTER TABLE + maintenance window |
| **Dotaz na "aktuální" záznam** | `WHERE ValidTo IS NULL` | Přímý SELECT |

**Kdy co použít:**
- **ValidFrom/ValidTo** → sazby, konfigurace, přiřazení vozidel/řidičů, otevírací doby
- **Temporal Tables** → tickety, zákazníci, hodinové sazby kde chceš kompletní audit trail
