# EF Core: Dědičnost — TPH, TPT, TPC

> **Technologické zaměření:** .NET 10 / EF Core 10  
> **Zdroj:** Microsoft Learn (modeling/inheritance)

---

## Přehled strategií dědičnosti

EF Core podporuje tři strategie mapování dědičnosti. Výchozí a doporučená je **TPH**.

| Strategie | Název | Tabulky | Doporučení |
|---|---|---|---|
| **TPH** | Table Per Hierarchy | 1 tabulka pro celou hierarchii | ✅ Výchozí, doporučeno pro většinu scénářů |
| **TPT** | Table Per Type | 1 tabulka na typ | ❌ Explicitně nedoporučeno (nejhorší výkon) |
| **TPC** | Table Per Concrete Type | 1 tabulka na konkrétní typ | ⚠️ Pro leaf-heavy dotazy |

---

## TPH — Table Per Hierarchy (výchozí, doporučeno)

**Schéma:** Jedna tabulka pro celou hierarchii, sloupec diskriminátoru.

```csharp
// ✅ Preferovaný přístup — Data Annotations (EF Core 8+):
[Discriminator("blog_type")]
[DiscriminatorValue("blog_base")]
public class Blog { /* ... */ }

[DiscriminatorValue("blog_rss")]
public class RssBlog : Blog { /* ... */ }

// Fluent API — záložní možnost nebo pro pokročilou konfiguraci diskriminátoru:
modelBuilder.Entity<Blog>()
    .HasDiscriminator<string>("blog_type")
    .HasValue<Blog>("blog_base")
    .HasValue<RssBlog>("blog_rss");
```

| Aspekt | Hodnocení |
|---|---|
| Počet tabulek | 1 |
| Nullable sloupce | Sloupce odvozených typů jsou nullable pro řádky základní třídy |
| Výkon dotazů | ✅ Nejlepší — žádné JOINy |
| Výkon zápisů | ✅ Jeden zápis |
| Normalizace schématu | ❌ Denormalizované (nullable sloupce) |
| FK constraints | ✅ Jednoduché |

> **Oficální doporučení:** *„TPH is usually fine for most applications, and is a good default for a wide range of scenarios."*

---

## TPT — Table Per Type (explicitně nedoporučeno)

**Schéma:** Jedna tabulka na typ, odvozené tabulky mají FK na základní tabulku.

```csharp
modelBuilder.Entity<Blog>().ToTable("Blogs");
modelBuilder.Entity<RssBlog>().ToTable("RssBlogs");
// nebo zkratka:
modelBuilder.Entity<Blog>().UseTptMappingStrategy();
```

| Aspekt | Hodnocení |
|---|---|
| Normalizace schématu | ✅ Normalizované |
| Výkon dotazů | ❌ **Nejhorší** — JOINy pro každý dotaz |
| Výkon zápisů | ❌ Zápisy do více tabulek |
| Composite FK/indexy | ❌ Nelze vytvořit přes base+derived sloupce |

> **Oficální doporučení:** *„Use TPT only if constrained to do so by external factors."* — nejsilnější varování v officiálních docs.

---

## TPC — Table Per Concrete Type

**Schéma:** Jedna tabulka na každý **konkrétní** typ. Abstraktní typy nemají tabulky. Sloupce základní třídy jsou duplikovány.

```csharp
modelBuilder.Entity<Animal>().UseTpcMappingStrategy();
```

| Aspekt | Hodnocení |
|---|---|
| FK constraints na base | ❌ Nelze vytvořit |
| Výkon dotazů (single type) | ✅ Nejlepší — žádné JOINy, žádný discriminator filter |
| Výkon dotazů (polymorfní) | ⚠️ Vyžaduje UNION ALL |
| Generování klíčů | ❌ IDENTITY nefunguje — nutné sekvence nebo Hi-Lo |
| Normalizace | ❌ Duplikace base sloupců |

> **Oficální doporučení:** *„TPC is also a good mapping strategy to use when your code will mostly query for entities of a single leaf type."*

---

## Srovnávací matice dědičnosti

| Kritérium | TPH | TPT | TPC |
|---|---|---|---|
| **Výchozí / doporučeno** | ✅ Ano | ❌ Ne | Pro leaf-heavy dotazy |
| **Výkon (polymorfní dotaz)** | ✅ Nejlepší | ❌ Nejhorší | ⚠️ UNION ALL |
| **Výkon (single-type dotaz)** | ✅ Dobrý | ❌ JOINy | ✅ Nejlepší |
| **IDENTITY generování klíčů** | ✅ | ✅ | ❌ Nutné sekvence |
| **FK constraints na base** | ✅ Jednoduché | ✅ FK na base | ❌ Nelze |
| **Schémová čistota** | ❌ Nullable sloupce | ✅ Normalizované | ❌ Duplikace |
| **Použít když** | Obecné použití | Jen při externím omezení | Vysoký objem dotazů na single type |

---

## Doporučení pro výběr strategie

```
Potřebuješ polymorfní dotazy přes celou hierarchii?
├── ANO, výkon je priorita → TPH
├── ANO, ale DB je normalizovaná a výkon je sekundární → TPT (jen při externím omezení)
└── Dotazy jsou většinou na konkrétní leaf typ?
    ├── ANO → TPC (pozor: nutné sekvence pro klíče, nelze FK na base)
    └── NE → TPH (výchozí)
```

## Viz také

- [`01-konfigurace-modelu.md`](01-konfigurace-modelu.md) — Fluent API konfigurace dědičnosti
- [`05-owned-a-complex-types.md`](05-owned-a-complex-types.md) — Owned types nepodporují dědičnost
