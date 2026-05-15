# 03 — Schémata a naming konvence

> PascalCase všude · 1 doména = 1 schéma · žádné rezervovaná slova jako názvy

---

## Schémata — doménová organizace

```
DB
├── dbo          → infrastruktura sdílená přes domény (User, Role, Tenant, File, Log)
├── helpdesk     → ticketing bounded context
├── hr           → docházka bounded context
├── billing      → fakturace bounded context
├── crm          → CRM bounded context
└── cfg          → sdílené číselníky a konfigurace
```

### Pravidla schémat

- **1 doména = 1 schéma** — tabulky stejné domény patří do jednoho schématu
- **`dbo` = pouze infrastruktura** — User, Role, Tenant, File, Log — nikdy doménové tabulky
- **Cross-schema FK jsou povoleny** — ale vždy je zaznamenat v dokumentaci
- **`cfg`** — sdílené číselníky přístupné z více domén

```sql
-- Vytvoření schémat
CREATE SCHEMA [helpdesk] AUTHORIZATION [dbo];
CREATE SCHEMA [hr]       AUTHORIZATION [dbo];
CREATE SCHEMA [billing]  AUTHORIZATION [dbo];
CREATE SCHEMA [cfg]      AUTHORIZATION [dbo];
CREATE SCHEMA [security] AUTHORIZATION [dbo];  -- pro RLS funkce a politiky
```

---

## Naming konvence — kompletní přehled

| Prvek | Pravidlo | ✅ Příklad | ❌ Zakázáno |
|---|---|---|---|
| **Tabulka** | PascalCase, singulár | `Ticket`, `VehicleDay` | `tickets`, `tbl_Ticket`, `TICKET` |
| **Sloupec** | PascalCase | `FirstName`, `CreatedAt` | `first_name`, `firstName` |
| **PK** | vždy `Id INT IDENTITY(1,1)` | `[Id] INT IDENTITY(1,1) NOT NULL` | `TicketId`, `ID`, `ticket_id` |
| **FK** | `{Tabulka}_Id` | `Customer_Id`, `Ticket_Id` | `CustomerId`, `cust_id` |
| **Boolean** | prefix `Is` | `IsActive`, `IsGroup`, `IsClosed` | `Active`, `Flag`, `Enabled` |
| **Datetime** | popisné jméno | `CreatedAt`, `ValidFrom`, `ResolvedAt` | `Date1`, `DateX`, `TS` |
| **Platnostní** | `ValidFrom` / `ValidTo` | nullable `ValidTo` = stále platné | `DateFrom`, `From`, `To` |
| **Soft delete** | `DeletedAt datetime2 NULL` | NULL = aktivní | `IsDeleted bit` |
| **Discriminator** | `{Entita}Type` nebo `{Entita}Type_Id` | `ProjectType_Id` | `type`, `kind`, `disc` |
| **Tenant klíč** | `{Tenant}_Id` | `Customer_Id`, `Instance_Id` | `TenantId`, `tenant` |
| **PK constraint** | `PK_{Tabulka}` | `PK_Ticket` | `pk1`, `PrimaryKey` |
| **FK constraint** | `FK_{Tabulka}_{Ref}_{Sloupec}` | `FK_Ticket_Customer_Id` | volně pojmenované |
| **Index** | `IX_{Tabulka}_{Sloupce}` | `IX_Ticket_Customer_Id` | `idx1`, `index_ticket` |
| **Unique index** | `UX_{Tabulka}_{Sloupce}` | `UX_User_Login` | — |
| **Views** | `v{Název}` | `vTicketSummary`, `vWorkDetail` | `View_Ticket`, `vw_Ticket` |
| **Stored proc.** | `{schema}.{Akce}{Entita}` | `billing.CreateInvoice` | `sp_`, `usp_`, `proc_` |
| **Funkce** | `{schema}.Get{Výsledek}` | `plan.GetPlanPoints` | `func1`, `fn_` |
| **Sequence** | `{schema}.{Entita}IdSequence` | `hr.ActivityIdSequence` | — |
| **Junction tabulka** | konkatenace bez oddělovače | `CustomerCategory`, `DepotVehicle` | `Customer_Category` |

---

## Vzorová CREATE TABLE se správným pojmenováním

```sql
CREATE TABLE [helpdesk].[Ticket] (
    -- PK: vždy Id, vždy IDENTITY
    [Id]                [int]           IDENTITY(1,1)   NOT NULL,

    -- FK: {Tabulka}_Id s podtržítkem
    [Customer_Id]       [int]                           NOT NULL,
    [Device_Id]         [int]                           NULL,
    [Project_Id]        [int]                           NULL,

    -- Boolean: prefix Is
    [IsActive]          [bit]                           NOT NULL    DEFAULT(1),

    -- Datetime: UTC, datetime2
    [CreatedAt]         [datetime2](0)                  NOT NULL    DEFAULT(SYSUTCDATETIME()),
    [ResolvedAt]        [datetime2](0)                  NULL,       -- NULL = nevyřešeno

    -- Constraints: PK_{Tabulka}, FK_{Tabulka}_{Ref}_{Sloupec}
    CONSTRAINT [PK_Ticket]              PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Ticket_Customer_Id]  FOREIGN KEY ([Customer_Id])
        REFERENCES [dbo].[Customer]([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Ticket_Device_Id]    FOREIGN KEY ([Device_Id])
        REFERENCES [dbo].[Device]([Id])   ON DELETE NO ACTION
);

-- Index: IX_{Tabulka}_{Sloupce} — jeden po každém FK
CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id]
    ON [helpdesk].[Ticket] ([Customer_Id]);

CREATE NONCLUSTERED INDEX [IX_Ticket_Device_Id]
    ON [helpdesk].[Ticket] ([Device_Id])
    WHERE [Device_Id] IS NOT NULL;  -- filtered = méně řádků, menší index
```

---

## Rezervovaná SQL slova — vyhnout se jako názvům sloupců

Pokud musíš použít rezervované slovo, obal `[hranatými závorkemi]` a **zvaž přejmenování**:

```sql
-- Problematické názvy (konflikty se SQL klíčovými slovy):
[Order]    → přejmenovat na [ProjectOrder] nebo [OrderIndex]
[Group]    → přejmenovat na [GroupName]
[Key]      → přejmenovat na [ApiKey] nebo [LicenseKey]
[Date]     → přejmenovat na [EventDate] nebo [WorkDate]
[Name]     → přijatelné, ale specifičtější je lepší ([FullName], [CustomerName])
[Type]     → přijatelné jako [ActivityType], [ProjectType]
[Value]    → přijatelné jako [SettingValue], [FilterValue]
```
