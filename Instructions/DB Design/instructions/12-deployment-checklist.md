# 12 — Deployment Checklist

> Zkontroluj před každým nasazením do produkce

---

## Konfigurace databáze

```
□ AUTO_SHRINK OFF
□ AUTO_CLOSE OFF
□ READ_COMMITTED_SNAPSHOT ON
    → Otestována na staging
    → Připravena maintenance window
    → Tempdb má dostatek místa (min. 20–30 % volného)

□ COMPATIBILITY_LEVEL odpovídá verzi serveru
    → Otestováno na staging s Query Tuning Assistant (QTA)
    → Žádné regrese execution plánů

□ PAGE_VERIFY = CHECKSUM
□ RECOVERY = FULL (produkce se zálohami)
□ TARGET_RECOVERY_TIME = 60 SECONDS

□ QUERY_STORE = ON
    → OPERATION_MODE = READ_WRITE
    → MAX_STORAGE_SIZE_MB >= 500 MB
    → QUERY_CAPTURE_MODE = AUTO
```

---

## Schéma a datový model

```
□ Každá doména má vlastní schéma (žádné doménové tabulky v dbo)
□ PK: vždy Id INT IDENTITY(1,1) (nebo Sequence pro TPC)
□ FK: pojmenování {Tabulka}_Id (s podtržítkem)
□ KAŽDÝ FK má nonclustered index
□ Datetime defaults: SYSUTCDATETIME() (ne GETDATE())
□ Boolean sloupce: bit (ne int)
□ Peněžní sloupce: decimal(p,s) (ne float/real)
□ Textové sloupce: nvarchar (ne varchar pro uživatelský text)
□ Computed columns: PERSISTED bez NOT NULL (neplatná syntaxe)
□ Žádná SQL rezervovaná slova jako názvy sloupců bez escapování
```

---

## Indexy

```
□ Každý FK má index (automaticky ověřit DMV dotazem)
□ Žádné duplicitní nebo velmi podobné indexy
□ Covering indexy (INCLUDE) pro nejčastější dotazy
□ Filtered indexy pro well-defined subsets (IsActive, ValidTo IS NULL)
□ Žádné skalární UDF ve WHERE klauzulích
□ Žádné funkce na indexovaných sloupcích ve WHERE
```

DMV ověření FK bez indexu:
```sql
SELECT fk.name AS FKName, OBJECT_NAME(fk.parent_object_id) AS TableName,
       COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS Column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE NOT EXISTS (
    SELECT 1 FROM sys.index_columns ic
    JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    WHERE ic.object_id = fkc.parent_object_id
      AND ic.column_id = fkc.parent_column_id AND ic.key_ordinal = 1
);
```

---

## TPC dědičnost

```
□ Sequence existuje a startuje správně (MAX existujících Id + rezerva)
□ Každá concrete tabulka má vlastní FK constraints (nedědí se!)
□ Každá concrete tabulka má vlastní indexy (nedědí se!)
□ EF Core: UseTpcMappingStrategy() + UseHiLo() nakonfigurováno
□ Polymorfní dotaz přes bázi testován (UNION ALL)
□ Abstraktní base třída nemá tabulku v DB
□ Pro TPC s migrací z TPT: data migrována a ověřena
```

---

## Stored Procedures

```
□ Každá SP má SET XACT_ABORT ON
□ Každá SP má SET NOCOUNT ON
□ Žádné RETURN -1 pro chybové stavy (použít THROW)
□ Kontroly existence UVNITŘ transakce s UPDLOCK, HOLDLOCK
□ Žádné skalární UDF v dotazech uvnitř SP
□ Dynamické SQL parametrizováno (sp_executesql)
```

---

## Bezpečnost

```
□ Aplikační účet NENÍ sa ani db_owner
□ Aplikační účet má jen nezbytná oprávnění (SELECT/INSERT/UPDATE/DELETE per schéma)
□ RLS nasazena na klíčové tabulky (pokud multi-tenant)
    → FILTER predikát
    → AFTER INSERT block predikát
    → AFTER UPDATE block predikát
    → BEFORE DELETE block predikát
□ SESSION_CONTEXT nastavován z EF Core před každým dotazem
□ DDM nasazena na citlivé sloupce (email, telefon, rodné číslo)
□ Connection string neobsahuje heslo v plain textu
    → Azure Key Vault / Secret Manager / Environment variables
```

---

## EF Core a migrace

```
□ Všechny FK sloupce s podtržítkem mají HasColumnName()
□ Identity tabulky mají explicitní ToTable() mapování
□ Všechny TPH diskriminátor hodnoty jsou namapovány (žádná chybějící hodnota)
□ NOT NULL sloupce přidávány ve 3 krocích (nullable → backfill → NOT NULL)
□ Migrace otestovány na kopii produkční DB (ne jen na prázdné)
□ Rollback plán připraven pro každou destruktivní migraci
□ EF Core migrace v transakci (výchozí chování — neobcházet)
```

---

## Výkon a monitoring

```
□ Query Store zapnut a nakonfigurován
□ Baseline výkonu zachycena před nasazením (Query Store snapshoty)
□ Index fragmentace ověřena (< 30 % pro klíčové tabulky)
□ Execution plán pro top 10 nejčastějších dotazů zkontrolován
□ Tempdb má dostatek místa (zejména při RCSI ON)
□ Záloha provedena před nasazením
```

---

## Po nasazení (první hodina)

```
□ Query Store — zkontrolovat nové regrese (SSMS → Query Store → Regressed Queries)
□ Activity Monitor — žádné blokování > 5 sec
□ Error log — žádné nové chyby
□ Tempdb — sledovat růst (sys.dm_db_file_space_usage)
□ Aplikační logy — žádné EF Core mapping chyby
□ Smoke testy klíčových funkcionalit
```
