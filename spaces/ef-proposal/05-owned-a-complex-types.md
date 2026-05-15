# EF Core: Owned Entities a Complex Types — Value Objects

> **Technologické zaměření:** .NET 10 / EF Core 10  
> **Zdroj:** Microsoft Learn (owned-entities, what-is-new/ef-core-8.0, what-is-new/ef-core-10.0)

---

## Tři kategorie mapovaných objektů v EF Core 8+

| Kategorie | Příklad | Má klíč? | EF typ |
|---|---|---|---|
| Primitivní typy | `int`, `Guid`, `string` | Ne | Skalární vlastnost |
| Entity typy | `Blog`, `Customer`, `Order` | ✅ Ano | Entity type |
| **Hodnotové objekty** | `Address`, `Money`, `PhoneNumber` | ❌ Ne | **Complex type (EF8+)** |

---

## Owned Entity Types

Owned entity jsou entity typy, které **existují pouze jako navigační vlastnosti jiné (owner) entity**. Jsou podobné DDD agregátům. Přestože nemají viditelný klíč, EF Core je interně sleduje přes hidden shadow key properties.

### Konfigurace

```csharp
// Konfigurace přes atribut:
[Owned]
public class StreetAddress
{
    public string Street { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
}

// Konfigurace přes Fluent API — OwnsOne:
modelBuilder.Entity<Order>().OwnsOne(o => o.ShippingAddress, sa =>
{
    sa.Property(p => p.Street).HasColumnName("ShipsToStreet");
    sa.Property(p => p.City).HasColumnName("ShipsToCity");
});

// Kolekce owned typů — OwnsMany:
modelBuilder.Entity<Distributor>().OwnsMany(p => p.ShippingCenters, a =>
{
    a.WithOwner().HasForeignKey("OwnerId");
    a.Property<int>("Id");
    a.HasKey("Id");
});
```

### Klíčová omezení Owned Types

- Nelze vytvořit `DbSet<T>` pro owned typy
- Instance **nelze sdílet** mezi více owners (způsobí `InvalidOperationException`)
- Nepodporují dědičnost
- Owned types **mohou mít** navigační vlastnosti na jiné entity (klíčový rozdíl od Complex Types)

---

## Complex Types (EF Core 8+) — pravé hodnotové objekty

Complex types jsou **bez klíče**, mají **value semantics** a lze je sdílet mezi více vlastnostmi.

### Konfigurace

```csharp
// Konfigurace přes atribut (MUSÍ být explicitní — neprobíhá discovery konvencemi):
[ComplexType]
public class Address
{
    public required string Line1 { get; set; }
    public string? Line2 { get; set; }
    public required string City { get; set; }
    public required string PostCode { get; set; }
}

// Konfigurace přes Fluent API:
modelBuilder.Entity<Customer>().ComplexProperty(e => e.Address);
```

### Doporučené .NET typy pro Complex Types (v pořadí preferencí)

```csharp
// Nejlepší: readonly record struct (C# 10)
[ComplexType]
public readonly record struct Money(decimal Amount, string Currency);

// Velmi dobré: record class
[ComplexType]
public record Address(string Line1, string? Line2, string City, string PostCode);

// Dobré: immutable class s primary constructor (C# 12)
[ComplexType]
public class Address(string line1, string city, string postCode)
{
    public string Line1 { get; } = line1;
    public string City { get; } = city;
    public string PostCode { get; } = postCode;
}

// Mutace přes 'with' výraz (bez vedlejších efektů na tracking):
customer.Address = customer.Address with { Line1 = "Nová ulice 1" };
```

---

## Novinky EF Core 10 pro Complex Types

| Funkce | EF Core 8 | EF Core 10 |
|---|---|---|
| Nullable/optional complex types | ❌ | ✅ |
| JSON column mapping (`ToJson()`) | ❌ | ✅ |
| Struct support | ❌ | ✅ |
| `ExecuteUpdateAsync` na JSON complex properties | ❌ | ✅ |

```csharp
// EF Core 10 — JSON mapping complex type:
modelBuilder.Entity<Customer>(b =>
{
    b.ComplexProperty(c => c.ShippingAddress, c => c.ToJson());
    b.ComplexProperty(c => c.BillingAddress, c => c.ToJson());  // nullable = nullable column
});
```

> **Oficální doporučení EF10:** *„These issues — as well as various others — make complex types the better choice for modeling JSON and table splitting, and users already using owned entity types for these are advised to switch to complex types."*

---

## Srovnání Owned Types vs Complex Types

| Vlastnost | Owned Entity Types | Complex Types (EF8+) |
|---|---|---|
| **Má klíč/identitu** | ✅ Hidden shadow key | ❌ Ne |
| **EF tracking semantics** | Entity semantics (by identity) | Value semantics (by content) |
| **Sdílení instancí** | ❌ Zakázáno (throws) | ✅ Povoleno |
| **Navigační vlastnosti** | ✅ Podporovány | ❌ Nepodporovány |
| **Kolekce (OwnsMany)** | ✅ | ✅ EF10 (pouze v JSON) |
| **Separate table** | ✅ `ToTable(...)` | ❌ Vždy inline nebo JSON |
| **JSON column** | ❌ | ✅ EF10 `ToJson()` |
| **Nullable** | ✅ | ✅ EF10 |
| **Doporučeno pro value objects** | ⚠️ Workaround před EF8 | ✅ Preferovaný přístup (EF8+) |

---

## Rozhodovací strom

```
Má objekt vlastní identitu a má být dotazován samostatně?
├── ANO → Entity Type (s DbSet<T>)
└── NE  → Potřebuje navigační vlastnosti na jiné entity?
          ├── ANO → Owned Entity Type (OwnsOne / OwnsMany)
          └── NE  → Hodnotový objekt:
                    ├── EF Core 8+: Complex Type [ComplexType] nebo ComplexProperty()
                    ├── Potřeba nullable? → EF Core 10+
                    ├── Potřeba JSON column? → EF Core 10+ s .ToJson()
                    └── Mapování na jeden sloupec? → Value Converter
```

## Viz také

- [`01-konfigurace-modelu.md`](01-konfigurace-modelu.md) — Fluent API konfigurace pro owned/complex types
- [`06-dedicnost-tph-tpt-tpc.md`](06-dedicnost-tph-tpt-tpc.md) — Owned types nepodporují dědičnost
