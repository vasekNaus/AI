# 07 — Stored Procedures a transakce

> SET XACT_ABORT ON · THROW ne RETURN -1 · UPDLOCK proti race condition

---

## Bezpečný vzor stored procedure

```sql
CREATE OR ALTER PROCEDURE [schema].[NazevAkce]
    @Param1 INT,
    @Param2 NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- automatický ROLLBACK při jakékoliv chybě (i runtime)

    -- Validace parametrů PŘED transakcí (levné, bez zámků)
    IF @Param1 IS NULL OR @Param1 <= 0
    BEGIN
        THROW 50000, 'Param1 musí být kladné číslo.', 1;
        RETURN;
    END

    BEGIN TRAN;
        -- ⚠️ Kontrola existence UVNITŘ transakce s UPDLOCK, HOLDLOCK
        -- UPDLOCK: zabrání souběžnému čtení stejného záznamu
        -- HOLDLOCK: drží zámek po celou dobu transakce (serializable pro tento řádek)
        IF EXISTS (
            SELECT 1 FROM [dbo].[Tabulka] WITH (UPDLOCK, HOLDLOCK)
            WHERE [UniqueField] = @Param2
        )
        BEGIN
            ROLLBACK;
            THROW 50001, 'Záznam s tímto názvem již existuje.', 1;
            RETURN;
        END

        -- Vlastní operace
        INSERT INTO [dbo].[Tabulka] ([Field1], [CreatedAt])
        VALUES (@Param2, SYSUTCDATETIME());

    COMMIT;
END
```

---

## Klíčová pravidla

### SET XACT_ABORT ON (povinné)

```sql
SET XACT_ABORT ON;
-- Bez tohoto nastavení: runtime chyba (např. FK violation) může ponechat
-- transakci otevřenou. S XACT_ABORT ON je transakce automaticky rollbackována.
```

### THROW místo RETURN -1

```sql
-- ❌ Špatně — ztráta kontextu chyby
IF @@ERROR <> 0
BEGIN
    ROLLBACK;
    RETURN -1;  -- volající neví co se stalo
END

-- ✅ Správně — zachovává chybový kontext, volající dostane smysluplnou výjimku
THROW 50001, 'Popisná chybová zpráva.', 1;
-- nebo pro propagaci systémové chyby:
BEGIN CATCH
    ROLLBACK;
    THROW;  -- re-throw originální chyby se stacktrace
END CATCH
```

### Race condition — kontrola UVNITŘ transakce

```sql
-- ❌ Špatně — race condition: dva procesy projdou IF, oba se pokusí o INSERT
IF NOT EXISTS (SELECT 1 FROM [dbo].[T] WHERE [Name] = @Name)
BEGIN
    BEGIN TRAN;
        INSERT INTO [dbo].[T] ...
    COMMIT;
END

-- ✅ Správně — kontrola S zámkem UVNITŘ transakce
BEGIN TRAN;
    IF EXISTS (SELECT 1 FROM [dbo].[T] WITH (UPDLOCK, HOLDLOCK) WHERE [Name] = @Name)
    BEGIN
        ROLLBACK;
        THROW 50001, 'Duplicitní záznam.', 1;
        RETURN;
    END
    INSERT INTO [dbo].[T] ...
COMMIT;
```

---

## Vzor s TRY/CATCH (pro komplexní logiku)

```sql
CREATE OR ALTER PROCEDURE [billing].[CreateInvoice]
    @CustomerId INT,
    @Period     DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

            -- Zkontroluj existenci zákazníka
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Customer] WHERE [Id] = @CustomerId)
                THROW 50010, 'Zákazník neexistuje.', 1;

            -- Zkontroluj duplicitu faktury (UPDLOCK uvnitř transakce)
            IF EXISTS (
                SELECT 1 FROM [billing].[Invoice] WITH (UPDLOCK, HOLDLOCK)
                WHERE [Customer_Id] = @CustomerId AND [Period] = @Period
            )
                THROW 50011, 'Faktura pro toto období již existuje.', 1;

            INSERT INTO [billing].[Invoice] ([Customer_Id], [Period], [CreatedAt])
            VALUES (@CustomerId, @Period, SYSUTCDATETIME());

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;  -- re-throw — volající dostane původní chybu
    END CATCH
END
```

---

## Inline Table-Valued Functions (místo skalárních UDF)

```sql
-- ❌ Skalární UDF ve WHERE — row-by-row zpracování, žádný index seek
WHERE [dbo].[fn_IsValid]([ValidFrom], [ValidTo]) = 1

-- ✅ Inline predikát — optimizer může použít index
WHERE [ValidFrom] <= SYSUTCDATETIME()
  AND ([ValidTo] IS NULL OR [ValidTo] > SYSUTCDATETIME())

-- ✅ Inline TVF (pokud potřebuješ logiku sdílet)
CREATE FUNCTION [schema].[GetActiveItems](@Date DATETIME2)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT [Id], [Name], [ValidFrom], [ValidTo]
    FROM [schema].[Item]
    WHERE [ValidFrom] <= @Date
      AND ([ValidTo] IS NULL OR [ValidTo] > @Date);
-- Inline TVF = optimizer ji "rozbalí" a může použít indexy
```

---

## Naming konvence pro procedury a funkce

```sql
-- Stored procedures: {schema}.{Akce}{Entita}
[billing].[CreateInvoice]
[helpdesk].[AssignTicket]
[hr].[CloseActivity]

-- Inline TVF: {schema}.Get{Výsledek} nebo {schema}.fn{Název}
[plan].[GetActivePlanVersions]
[security].[fn_TenantFilter]

-- ❌ Zakázané prefixy
sp_NazevProcedury    -- rezervováno pro systémové procedury
usp_NazevProcedury   -- staré konvence, nepoužívat
```
