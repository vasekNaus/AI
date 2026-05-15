# 09 — Bezpečnost: RLS a Dynamic Data Masking

> Row-Level Security pro tenant izolaci · DDM pro GDPR · kombinovat vždy

---

## Row-Level Security (RLS) — multi-tenant izolace

RLS zajistí, že každý tenant vidí **pouze svá data** — i přes přímý přístup do DB.

### 1. Schéma pro bezpečnostní objekty

```sql
CREATE SCHEMA [security] AUTHORIZATION [dbo];
```

### 2. Predikátová funkce (Inline TVF — povinně)

```sql
-- ⚠️ MUSÍ být Inline TVF (ne skalární funkce — výkon)
-- ⚠️ MUSÍ mít WITH SCHEMABINDING
CREATE FUNCTION [security].[fn_TenantFilter](@TenantId INT)
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN
    SELECT 1 AS [Result]
    WHERE @TenantId = CAST(SESSION_CONTEXT(N'TenantId') AS INT)
       OR IS_ROLEMEMBER('db_owner') = 1;  -- db_owner a admini vidí vše
```

### 3. Security Policy (FILTER + všechny BLOCK predikáty)

```sql
-- ⚠️ Pro ÚPLNOU izolaci musí být FILTER + všechny 3 BLOCK predikáty!
CREATE SECURITY POLICY [security].[TenantPolicy]
    -- FILTER: omezuje SELECT, DELETE read, UPDATE read
    ADD FILTER PREDICATE [security].[fn_TenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket],

    -- BLOCK AFTER INSERT: zabrání vložení záznamu jiného tenanta
    ADD BLOCK PREDICATE [security].[fn_TenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket] AFTER INSERT,

    -- BLOCK AFTER UPDATE: zabrání přesunutí záznamu na jiného tenanta
    ADD BLOCK PREDICATE [security].[fn_TenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket] AFTER UPDATE,

    -- BLOCK BEFORE DELETE: zabrání mazání záznamů jiného tenanta
    ADD BLOCK PREDICATE [security].[fn_TenantFilter]([Customer_Id])
        ON [helpdesk].[Ticket] BEFORE DELETE

WITH (STATE = ON, SCHEMABINDING = ON);
```

### 4. Nastavení SESSION_CONTEXT z EF Core

```csharp
// DbContext — nastavit před každým dotazem/uložením
public class AppDbContext : DbContext
{
    private readonly int _currentTenantId;

    public AppDbContext(DbContextOptions options, ICurrentTenant tenant) : base(options)
    {
        _currentTenantId = tenant.Id;
    }

    // Nastavit session context při otevření spojení
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.AddInterceptors(new TenantSessionContextInterceptor(_currentTenantId));
    }
}

// Interceptor pro nastavení SESSION_CONTEXT
public class TenantSessionContextInterceptor : DbConnectionInterceptor
{
    private readonly int _tenantId;
    public TenantSessionContextInterceptor(int tenantId) => _tenantId = tenantId;

    public override async Task ConnectionOpenedAsync(DbConnection connection,
        ConnectionEndEventData eventData, CancellationToken ct)
    {
        using var cmd = connection.CreateCommand();
        cmd.CommandText = "EXEC sp_set_session_context N'TenantId', @tenantId";
        var p = cmd.CreateParameter();
        p.ParameterName = "@tenantId";
        p.Value = _tenantId;
        cmd.Parameters.Add(p);
        await cmd.ExecuteNonQueryAsync(ct);
    }
}
```

### BLOCK predikáty — přehled

| Typ | Blokuje |
|---|---|
| `AFTER INSERT` | INSERT záznamu s jiným TenantId |
| `AFTER UPDATE` | UPDATE který by přenesl záznam na jiného tenanta |
| `BEFORE UPDATE` | UPDATE záznamu patřícího jinému tenantovi |
| `BEFORE DELETE` | DELETE záznamu patřícího jinému tenantovi |

---

## Dynamic Data Masking (DDM) — ochrana citlivých dat

DDM maskuje citlivá data pro neprivilegované uživatele. **Data v DB se nemění** — mění se jen výsledek SELECT.

```sql
-- Typy masek:
-- default()   → plná maska dle datového typu (XXXX pro texty, 0 pro čísla)
-- email()     → první písmeno + @XXXX.com (aXXX@XXXX.com)
-- partial()   → zobrazí prefix + suffix, střed maskuje
-- random(a,b) → náhodné číslo v rozsahu (pro numerické sloupce)

-- Definice masek na existující tabulce
ALTER TABLE [dbo].[User]
    ALTER COLUMN [Email]  ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE [dbo].[User]
    ALTER COLUMN [Phone]  ADD MASKED WITH (FUNCTION = 'default()');

ALTER TABLE [dbo].[User]
    ALTER COLUMN [Mobil]  ADD MASKED WITH (FUNCTION = 'default()');

-- Rodné číslo — zobraz jen poslední 4 znaky
ALTER TABLE [dbo].[Customer]
    ALTER COLUMN [BirthId] ADD MASKED WITH (FUNCTION = 'partial(0,"XXXXXXX",4)');

-- Při CREATE TABLE
CREATE TABLE [dbo].[Customer] (
    [Id]        INT             NOT NULL,
    [Email]     VARCHAR(200)    MASKED WITH (FUNCTION = 'email()') NULL,
    [Phone]     VARCHAR(20)     MASKED WITH (FUNCTION = 'default()') NULL
);

-- Přidělit právo vidět nemasková data (privileged users)
GRANT UNMASK ON [dbo].[User] TO [AppAdmin];
GRANT UNMASK ON [dbo].[User] TO [SupportUser];

-- Odebrat masku
ALTER TABLE [dbo].[User]
    ALTER COLUMN [Email] DROP MASKED;
```

### Kdy použít DDM

- Citlivá osobní data (email, telefon, rodné číslo, bankovní údaje) — GDPR
- Různé role uživatelů potřebují různou úroveň přístupu
- Reporting aplikace kde junior analytik nesmí vidět osobní data

### Limitace DDM (dle MSDN)

> ⚠️ DDM **nenahrazuje** šifrování ani RLS. Je to prezentační vrstva.
> Uživatel s přímým přístupem k DB může obejít DDM přes inferenci dat.
> Kombinuj vždy: **DDM + RLS + Always Encrypted** pro citlivá data.

---

## Minimální oprávnění — princip least privilege

```sql
-- Aplikační účet (ne sa, ne db_owner!)
CREATE LOGIN [AppLogin] WITH PASSWORD = '...';
CREATE USER  [AppUser]  FOR LOGIN [AppLogin];

-- Jen nezbytná oprávnění
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[helpdesk] TO [AppUser];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[hr] TO [AppUser];
GRANT SELECT ON SCHEMA::[cfg] TO [AppUser];
-- DENY přístup k systémovým tabulkám (výchozí, ale explicitně je lepší)
DENY SELECT ON [sys].[sql_logins] TO [AppUser];

-- Reporting účet — jen čtení
CREATE USER [ReportUser] FOR LOGIN [ReportLogin];
GRANT SELECT ON SCHEMA::[helpdesk] TO [ReportUser];
GRANT UNMASK ON [dbo].[Customer] TO [ReportUser];  -- pokud smí vidět data
```
