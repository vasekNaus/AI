# 05 — Cizí klíče a indexy

> Každý FK = povinný index · covering index eliminuje lookup · filtered index šetří místo

---

## Cizí klíče — pravidla

```sql
-- Vzor: FK constraint + index vždy společně
ALTER TABLE [helpdesk].[Ticket] ADD
    CONSTRAINT [FK_Ticket_Customer_Id]
        FOREIGN KEY ([Customer_Id])
        REFERENCES [dbo].[Customer]([Id])
        ON DELETE NO ACTION    -- výchozí, preferovaný
        ON UPDATE NO ACTION;

CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id]
    ON [helpdesk].[Ticket] ([Customer_Id]);
```

### ON DELETE volby

| Volba | Kdy použít |
|---|---|
| `NO ACTION` | **Výchozí** — explicitně definuj chování v aplikaci |
| `CASCADE` | Výjimečně — jen pokud child nemá smysl bez parenta (log záznamy, detaily objednávky) |
| `SET NULL` | Pro volitelné vazby (Device_Id může být NULL po smazání zařízení) |
| `SET DEFAULT` | Vzácně — nutné mít smysluplnou default hodnotu |

> ⚠️ `CASCADE` na víceúrovňových hierarchiích = riziko hromadného mazání dat. Vždy ověřit všechny cesty.

---

## Indexy — typy a kdy použít

### Nonclustered index (nejčastější)

```sql
-- Základní: jeden sloupec FK
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id]
    ON [helpdesk].[Ticket] ([Customer_Id]);

-- Composite: více sloupců — od nejselektivnějšího k nejméně selektivnímu
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id_CreatedAt]
    ON [helpdesk].[Ticket] ([Customer_Id], [CreatedAt] DESC);
```

### Covering index (INCLUDE)

```sql
-- Eliminuje key lookup — dotaz vyřešen přímo z indexu
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Covering]
    ON [helpdesk].[Ticket] ([Customer_Id], [CreatedAt] DESC)
    INCLUDE ([Title], [ResolvedAt], [IsActive]);
-- Vhodné pokud SELECT vždy čte tyto sloupce společně s filtrem na Customer_Id
```

### Filtered index (subset dat)

```sql
-- Index jen na aktivní záznamy — menší, rychlejší, nižší maintenance
CREATE NONCLUSTERED INDEX [IX_Ticket_Active]
    ON [helpdesk].[Ticket] ([Customer_Id], [CreatedAt] DESC)
    WHERE [ResolvedAt] IS NULL;  -- jen otevřené tickety

-- Unique constraint s výjimkou NULL (email musí být unikátní, ale může být NULL)
CREATE UNIQUE NONCLUSTERED INDEX [UX_User_Email]
    ON [dbo].[User] ([Email])
    WHERE [Email] IS NOT NULL;
```

### Columnstore index (OLAP / reporting)

```sql
-- Pro tabulky s analytickými dotazy (10× rychlejší čtení, 7× komprese)
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_Ticket_Columnstore]
    ON [helpdesk].[Ticket] ([Customer_Id], [CreatedAt], [ResolvedAt], [IsActive]);
-- Nepřidávat na OLTP tabulky s vysokým zápisem!
```

---

## MSDN pravidla pro indexy

1. **OLTP** → úzké rowstore indexy cílené na nejkritičtější dotazy
2. **OLAP/DWH** → clustered columnstore index
3. **Každý FK = povinný nonclustered index** — vždy, bez výjimky
4. **Raději rozšiř existující index** (`INCLUDE`) než vytvoř nový podobný
5. **Nepřeindexovat** — každý index zpomaluje INSERT / UPDATE / DELETE / MERGE
6. **Filtered index** pro well-defined subset (IsActive, IsDeleted, ValidTo IS NULL)
7. **NIKDY skalární UDF ve WHERE/JOIN** — způsobuje row-by-row scan, ignoruje indexy
8. **NIKDY funkce na indexovaném sloupci** — `YEAR([CreatedAt]) = 2024` = table scan

```sql
-- ❌ Špatně — index na CreatedAt se nepoužije
WHERE YEAR([CreatedAt]) = 2024

-- ✅ Správně — index seek
WHERE [CreatedAt] >= '2024-01-01' AND [CreatedAt] < '2025-01-01'
```

---

## Index Maintenance

```sql
-- Zjistit fragmentaci (MSDN doporučení: REBUILD > 30 %, REORGANIZE 10–30 %)
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

-- Rebuild (online = bez výpadku, Enterprise edice)
ALTER INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket]
    REBUILD WITH (ONLINE = ON, DATA_COMPRESSION = PAGE);

-- Reorganize (vždy online, méně zdrojů)
ALTER INDEX [IX_Ticket_Customer_Id] ON [helpdesk].[Ticket] REORGANIZE;
```

---

## Chybějící indexy — doporučení DMV

```sql
-- Indexy doporučené SQL Server query optimizerem
SELECT TOP 10
    mid.statement AS TableName,
    migs.avg_user_impact AS EstimatedImprovement,
    migs.user_seeks + migs.user_scans AS Usage,
    'CREATE INDEX [IX_Missing] ON ' + mid.statement
        + ' (' + ISNULL(mid.equality_columns, '')
        + ISNULL(', ' + mid.inequality_columns, '') + ')'
        + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS Script
FROM sys.dm_db_missing_index_details mid
JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
ORDER BY migs.avg_user_impact DESC;
```

> ⚠️ DMV doporučení jsou jen tipy — nevytvářej každý navrhovaný index slepě. Vždy ověř execution plánem a zatížením.
