# 02 — Konfigurace databáze

> SQL Server 2017–2022 · Povinné nastavení pro každou novou i stávající databázi

---

## Povinná nastavení (spustit vždy)

```sql
-- Nahraď [DB] skutečným názvem databáze
ALTER DATABASE [DB] SET AUTO_SHRINK OFF;               -- nikdy nezapínat (fragmentace!)
ALTER DATABASE [DB] SET AUTO_CLOSE OFF;                -- nikdy nezapínat
ALTER DATABASE [DB] SET READ_COMMITTED_SNAPSHOT ON;    -- klíčové pro EF Core (bez blokování)
ALTER DATABASE [DB] SET PAGE_VERIFY CHECKSUM;          -- detekce poškození stránek
ALTER DATABASE [DB] SET RECOVERY FULL;                 -- pro produkci se zálohami
ALTER DATABASE [DB] SET TARGET_RECOVERY_TIME = 60 SECONDS;
```

> ⚠️ `READ_COMMITTED_SNAPSHOT ON` vyžaduje **maintenance window** — krátce vyžaduje exkluzivní přístup k DB.  
> Po zapnutí monitoruj tempdb (verzování řádků zvyšuje tlak na tempdb).

---

## Compatibility Level dle verze serveru

```sql
-- Zjisti verzi serveru
SELECT @@VERSION;

-- Nastav odpovídající level
ALTER DATABASE [DB] SET COMPATIBILITY_LEVEL = 160;  -- SQL 2022
-- ALTER DATABASE [DB] SET COMPATIBILITY_LEVEL = 150;  -- SQL 2019
-- ALTER DATABASE [DB] SET COMPATIBILITY_LEVEL = 140;  -- SQL 2017
-- ALTER DATABASE [DB] SET COMPATIBILITY_LEVEL = 130;  -- SQL 2016
```

| SQL Server | Max. COMPATIBILITY_LEVEL |
|---|---|
| 2016 | 130 |
| 2017 | **140** |
| 2019 | 150 |
| 2022 | **160** |
| Azure SQL | 160 |

> ⚠️ Při zvyšování levelu na existující DB: nejdřív otestuj na staging s **Query Tuning Assistant (QTA)** — SSMS → Management → Query Store → Query Tuning Assistant

---

## Query Store (povinné v produkci)

```sql
ALTER DATABASE [DB] SET QUERY_STORE = ON
WITH (
    OPERATION_MODE            = READ_WRITE,   -- nikdy READ_ONLY v produkci
    CLEANUP_POLICY            = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,        -- flush každých 15 min
    INTERVAL_LENGTH_MINUTES   = 60,
    MAX_STORAGE_SIZE_MB       = 1000,         -- min 500 MB pro produkci
    QUERY_CAPTURE_MODE        = AUTO,         -- SQL 2019+: zvážit CUSTOM
    SIZE_BASED_CLEANUP_MODE   = AUTO
);
```

**Proč Query Store?**
- Sleduje historii dotazů a execution plánů
- Detekuje regrese výkonu po deployi nebo upgradu
- Umožňuje `sp_query_store_force_plan` pro stabilizaci plánu

---

## Filegroups (pro velké projekty)

```sql
-- Separace dat a indexů na různé disky = výkonnostní benefit
ALTER DATABASE [DB] ADD FILEGROUP [INDEXES];
ALTER DATABASE [DB] ADD FILE (
    NAME = N'DB_Indexes',
    FILENAME = N'E:\MSSQL\Indexes\DB_Indexes.ndf',
    SIZE = 512MB, FILEGROWTH = 256MB
) TO FILEGROUP [INDEXES];

-- Tabulky na PRIMARY, indexy na INDEXES
CREATE TABLE [...] ON [PRIMARY];
CREATE NONCLUSTERED INDEX [...] ON [INDEXES];
```

---

## Zakázané nastavení

| Nastavení | Proč zakázáno |
|---|---|
| `AUTO_SHRINK ON` | Fragmentuje indexy, zbytečné I/O, výkonnostní propady |
| `AUTO_CLOSE ON` | Zavírá databázi po posledním odpojení — overhead při reconnectu |
| `QUERY_STORE = OFF` | V produkci nemáš žádný přehled o výkonu dotazů |
| `COMPATIBILITY_LEVEL` nižší než verze serveru | Starý optimizer, chybějící funkce, bezpečnostní díry |
