# 06 — Dědičnost: TPC / TPT / TPH

> TPC preferováno · TPT pro FK target · TPH pro diskriminátor · 1:1 pro per-domain rozšíření

---

## Rozhodovací strom

```
Je to IS-A vztah? (Pes JE Zvíře)
│
├── NE → Použij 1:1 relaci (HasOne/WithOne)
│        Typické: per-domain konfigurace (HelpdeskCustomer, BillingCustomer)
│
└── ANO →
    │
    ├── Dotazuješ se vždy na konkrétní typ (ne na bázi)?
    │   └── ANO → TPC ✅ (preferováno)
    │              • Každý concrete typ = vlastní tabulka se VŠEMI sloupci
    │              • Polymorfní dotaz = UNION ALL
    │              • ID: Sequence + HiLo (globálně unikátní!)
    │
    ├── Polymorfní dotazy + malá hierarchie + hodně NULL sloupců?
    │   └── ANO → TPH
    │              • Jedna tabulka + discriminator sloupec
    │              • Subtypy mají nullable sloupce (NULL pokud jiný typ)
    │
    └── Base tabulka je FK target z jiných tabulek?
        └── ANO → TPT
                   • Base tabulka = FK target
                   • Subtabulky mají vlastní PK = FK na base
```

---

## TPC — Table Per Concrete (preferováno)

Každý concrete typ = samostatná tabulka se **všemi** sloupci (base + vlastní).

```sql
-- Příklad: hr.Activity hierarchie (Work, Holiday, Illness, …)
-- Každá tabulka je kompletní — žádná abstraktní tabulka Activity neexistuje!

CREATE SEQUENCE [hr].[ActivityIdSequence]
    AS INT START WITH 1000 INCREMENT BY 10 NO MAXVALUE;

CREATE TABLE [hr].[Work] (
    -- Sloupce z bázové třídy Activity
    [Id]                    [int]           NOT NULL,
    [User_Id]               [int]           NOT NULL,
    [Date]                  [date]          NOT NULL,
    [SysDate]               [datetime2](0)  NOT NULL DEFAULT(SYSUTCDATETIME()),
    [IsClosed]              [bit]           NOT NULL DEFAULT(0),
    [Note]                  [nvarchar](max) NULL,
    [ActivityTemplate_Id]   [int]           NULL,
    -- Sloupce specifické pro Work
    [From]                  [time](0)       NOT NULL,
    [To]                    [time](0)       NOT NULL,
    [IsHomeOffice]          [bit]           NOT NULL DEFAULT(0),
    [Department_Id]         [int]           NULL,
    CONSTRAINT [PK_Work] PRIMARY KEY CLUSTERED ([Id])
);

-- ⚠️ Každá TPC tabulka MUSÍ mít vlastní FK a indexy — nedědí se!
ALTER TABLE [hr].[Work] ADD
    CONSTRAINT [FK_Work_User_Id]
        FOREIGN KEY ([User_Id]) REFERENCES [dbo].[User]([Id]),
    CONSTRAINT [FK_Work_ActivityTemplate_Id]
        FOREIGN KEY ([ActivityTemplate_Id]) REFERENCES [hr].[ActivityTemplate]([Id]);

CREATE NONCLUSTERED INDEX [IX_Work_User_Id_Date]
    ON [hr].[Work] ([User_Id], [Date]);
```

```csharp
// EF Core TPC konfigurace
modelBuilder.Entity<Activity>().UseTpcMappingStrategy();
modelBuilder.Entity<Activity>()
    .Property(a => a.Id)
    .UseHiLo("ActivityHiLoSequence", "hr");  // sdílená sequence

modelBuilder.Entity<Work>().ToTable("Work", "hr");
modelBuilder.Entity<Holiday>().ToTable("Holiday", "hr");
modelBuilder.Entity<Illness>().ToTable("Illness", "hr");

// Polymorfní dotaz přes všechny typy = UNION ALL (automaticky přes base set)
var allToday = context.Set<Activity>()   // generuje UNION ALL
    .Where(a => a.Date == DateOnly.FromDateTime(DateTime.Today))
    .ToList();
```

**TPC kritické detaily:**
- `START WITH` v Sequence musí být **vyšší než MAX(existujících Id)** při migraci
- Každá concrete tabulka = vlastní FK constraints + indexy (nejsou děděny)
- Polymorfní dotazy = `UNION ALL` (pomalejší — zvážit view)
- Abstraktní bázová třída **nemá vlastní tabulku v DB**

---

## TPH — Table Per Hierarchy

Jedna tabulka pro celou hierarchii + discriminator sloupec.

```sql
-- Příklad: helpdesk.Project s diskriminátorem ProjectType_Id
CREATE TABLE [helpdesk].[Project] (
    [Id]                [int]           IDENTITY(1,1) NOT NULL,
    [ProjectType_Id]    [char](1)       NOT NULL,   -- diskriminátor: P, O, I, S, C
    [Name]              [nvarchar](200) NOT NULL,
    -- Sloupce specifické pro subtypy (NULL pro ostatní typy)
    [ServiceCode]       [nvarchar](50)  NULL,       -- jen pro ServiceProject (S)
    [ContractId]        [int]           NULL,       -- jen pro ContinuationProject (C)
    CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([Id])
);
```

```csharp
// EF Core TPH — VŠECHNY typy MUSÍ být registrovány
// Chybějící typ → InvalidOperationException při materializaci!
modelBuilder.Entity<Project>()
    .HasDiscriminator<string>("ProjectType_Id")
    .HasValue<InternalProject>("I")
    .HasValue<OutsourcedProject>("O")
    .HasValue<ServiceProject>("S")
    .HasValue<ContinuationProject>("C")
    .HasValue<Project>("P");
```

---

## TPT — Table Per Type

Base tabulka = FK target. Subtabulky s vlastními sloupci, PK = FK na base.

```sql
-- Příklad: data.Address/Depot/Outlet (Address je FK z jiných tabulek!)
CREATE TABLE [data].[Address] (
    [Id]        [int]           IDENTITY(1,1) NOT NULL,
    [Name]      [nvarchar](200) NOT NULL,
    [Street]    [nvarchar](200) NULL,
    [City]      [nvarchar](100) NULL,
    [Location]  [geography]     NULL,
    CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED ([Id])
);

CREATE TABLE [data].[Depot] (
    [Id]            [int] NOT NULL,   -- NOT IDENTITY — FK na Address.Id
    [Instance_Id]   [int] NOT NULL,
    CONSTRAINT [PK_Depot]           PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Depot_Address]   FOREIGN KEY ([Id])
        REFERENCES [data].[Address]([Id]) ON DELETE CASCADE
);
```

```csharp
// EF Core TPT
modelBuilder.Entity<Address>().ToTable("Address", "data");
modelBuilder.Entity<Depot>()
    .ToTable("Depot", "data")
    .Property(d => d.Id).ValueGeneratedNever(); // NOT IDENTITY!
```

---

## 1:1 Relace (není dědičnost)

Pro per-domain konfigurační rozšíření — každá doména má vlastní tabulku s `Customer_Id` jako PK+FK.

```csharp
// dbo.Customer je hlavní entita
// helpdesk.Customer, billing.Customer, crm.Customer jsou rozšíření — NENÍ IS-A!
modelBuilder.Entity<Customer>()
    .HasOne(c => c.HelpdeskSettings)
    .WithOne()
    .HasForeignKey<HelpdeskCustomer>(h => h.Customer_Id);

modelBuilder.Entity<Customer>()
    .HasOne(c => c.BillingSettings)
    .WithOne()
    .HasForeignKey<BillingCustomer>(b => b.Customer_Id);
```

---

## Srovnávací tabulka

| | TPC | TPH | TPT | 1:1 |
|---|---|---|---|---|
| **SQL tabulky** | Jedna per concrete typ | Jedna pro vše | Base + subtabulky | Dvě oddělené |
| **NULL sloupce** | Žádné | Mnoho (pro jiné typy) | Žádné | Žádné |
| **Dotaz na concrete typ** | ✅ Rychlý (přímý SELECT) | ✅ Rychlý (WHERE discriminator) | ⚠️ JOIN na base | N/A |
| **Polymorfní dotaz** | ⚠️ UNION ALL | ✅ SELECT vše | ✅ JOIN | N/A |
| **FK target možný** | ❌ Složité | ✅ Ano | ✅ Ano (base) | ✅ Ano |
| **EF Core podpora** | EF Core 7+ | Plná | Plná | Plná |
| **Preferováno** | ✅ Pro typované dotazy | Pro malé hierarchie | Pokud FK target | Per-domain rozšíření |
