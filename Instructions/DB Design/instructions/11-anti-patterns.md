# 11 — Anti-patterns

> Co nikdy nedělat · proč · jak opravit

---

## Kritické anti-patterns (okamžitě opravit)

| Anti-pattern | Proč je špatný | Řešení |
|---|---|---|
| **`AUTO_SHRINK ON`** | Fragmentuje indexy, zbytečné I/O, výkonnostní propady | `ALTER DATABASE SET AUTO_SHRINK OFF` |
| **`GETDATE()` jako default** | Lokální čas serveru — závisí na timezone a DST | `DEFAULT(SYSUTCDATETIME())` |
| **`COMPATIBILITY_LEVEL` nižší než server** | Starý optimizer, chybějící funkce | Zvýšit na max. dle verze serveru (QTA) |
| **Skalární UDF ve WHERE/JOIN** | Row-by-row scan, ignoruje indexy | Inline predikát nebo Inline TVF |
| **FK bez indexu** | Pomalé DELETE a JOIN na rodičovské tabulce | `CREATE NONCLUSTERED INDEX` po každém FK |
| **`SELECT *` v produkci** | Zbytečné přenosy dat, skryté změny schématu | Explicitní seznam sloupců |

---

## Výkonnostní anti-patterns

| Anti-pattern | Proč je špatný | Řešení |
|---|---|---|
| **Funkce na indexovaném sloupci ve WHERE** | Optimizer nemůže použít index (table scan) | Přepsat na přímé porovnání hodnot |
| **`NOT IN (subquery)` s NULL** | NULL v podsestavu → celý výsledek prázdný | Použít `NOT EXISTS` |
| **Spekulativní indexy "pro jistotu"** | Každý index zpomaluje INSERT/UPDATE/DELETE | Index až po ověření execution plánem |
| **GUID clustered PK s `NEWID()`** | Náhodné GUID = 50% page splits = fragmentace | `NEWSEQUENTIALID()` nebo INT IDENTITY |
| **`nvarchar(max)` všude** | Nelze indexovat, přetíží paměť | Konkrétní délka (`nvarchar(300)`) |
| **Implicit type conversion ve WHERE** | Různé typy = konverze = table scan (ne index seek) | Stejné typy na obou stranách porovnání |
| **Over-normalizace číselníků** | JOIN navíc pro každý dotaz | Denormalizovat pokud hodnota se nemění |

```sql
-- ❌ Funkce na indexovaném sloupci
WHERE YEAR([CreatedAt]) = 2024
WHERE MONTH([WorkDate]) = 6

-- ✅ Správně — index seek
WHERE [CreatedAt] >= '2024-01-01' AND [CreatedAt] < '2025-01-01'
WHERE [WorkDate] >= '2024-06-01' AND [WorkDate] < '2024-07-01'

-- ❌ NOT IN s NULL — vrátí prázdnou sadu pokud subquery obsahuje NULL
SELECT * FROM [Orders] WHERE [Customer_Id] NOT IN (SELECT [Id] FROM [Customers])

-- ✅ NOT EXISTS — bezpečné s NULL
SELECT * FROM [Orders] o
WHERE NOT EXISTS (SELECT 1 FROM [Customers] c WHERE c.[Id] = o.[Customer_Id])
```

---

## Datové anti-patterns

| Anti-pattern | Proč je špatný | Řešení |
|---|---|---|
| **`float`/`real` pro peníze** | Zaokrouhlovací chyby IEEE 754 | `decimal(18,4)` nebo `decimal(10,2)` |
| **`varchar` pro multilingual text** | Ztráta diakritiky a speciálních znaků | `nvarchar(n)` |
| **`varchar` pro GPS souřadnice** | Nelze počítat vzdálenosti | `geography` typ + NetTopologySuite |
| **`int` pro boolean** | Nedává sémantiku, možné neplatné hodnoty | `bit` |
| **`datetime` (starý typ)** | Zaokrouhluje na 3ms, 2038 limit | `datetime2(0)` vždy |
| **NULL jako příznak stavu** | Nejednoznačné — NULL = neznámý nebo neplatný? | Explicitní `bit` nebo enum sloupec |
| **Uložit JSON jako `xml`** | Špatný datový typ, pomalejší parsing | `nvarchar(max)` s `ISJSON()` validací |

---

## Bezpečnostní anti-patterns

| Anti-pattern | Proč je špatný | Řešení |
|---|---|---|
| **RLS jen s FILTER predikátem** | BLOCK chybí → tenant může INSERT/UPDATE/DELETE cizí data | FILTER + AFTER INSERT + AFTER UPDATE + BEFORE DELETE |
| **DDM jako jediná bezpečnostní vrstva** | Uživatel s přístupem k DB může data inferovat | DDM + RLS + Always Encrypted pro citlivá data |
| **Aplikace běží pod sa nebo db_owner** | Kompromitace aplikace = kompromitace celé DB | Minimální oprávnění — jen potřebná schémata |
| **Hesla v connection stringu v appsettings.json** | Commitnuto do gitu, logováno | Azure Key Vault, Secret Manager, environment variables |

---

## Migrační anti-patterns

| Anti-pattern | Proč je špatný | Řešení |
|---|---|---|
| **NOT NULL sloupec jedním krokem** | Chyba při deployi na neprázdnou tabulku | 3 kroky: nullable → backfill → NOT NULL |
| **DROP TABLE v produkci bez zálohy** | Nevratná ztráta dat | Soft delete → archiv → DROP po ověření |
| **Migrace bez transakce** | Částečně aplikovaná migrace = nekonzistentní DB | EF Core migrace jsou automaticky v transakci |
| **TPC Sequence od START WITH 1** | Kolize PK s existujícími daty při migraci z TPT | START WITH MAX(existující Id) + rezerva |

---

## Stored procedure anti-patterns

| Anti-pattern | Proč je špatný | Řešení |
|---|---|---|
| **Kontrola existence PŘED transakcí** | Race condition — dva procesy projdou IF | Kontrola uvnitř transakce s `UPDLOCK, HOLDLOCK` |
| **`RETURN -1` místo `THROW`** | Volající neví co se stalo, ztráta kontextu | `THROW 50001, 'Popis chyby.', 1` |
| **Chybí `SET XACT_ABORT ON`** | Runtime chyba ponechá transakci otevřenou | `SET XACT_ABORT ON` na začátku každé SP |
| **Skalární UDF v SELECT/WHERE** | Row-by-row zpracování, žádný paralelismus | Inline TVF nebo přepsat logiku do dotazu |
| **Dynamické SQL bez parametrizace** | SQL injection | `sp_executesql` s parametry |

```sql
-- ❌ SQL injection — dynamické SQL bez parametrizace
DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM Users WHERE Name = ''' + @Name + ''''
EXEC(@sql)

-- ✅ Bezpečně — parametrizované dynamické SQL
DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM Users WHERE Name = @Name'
EXEC sp_executesql @sql, N'@Name NVARCHAR(200)', @Name = @Name
```
