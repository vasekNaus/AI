# EF Core: Konfigurace modelu — tři úrovně priority

> **Technologické zaměření:** .NET 10 / EF Core 10  
> **Zdroj:** Microsoft Learn, .NET Microservices Architecture Guide

---

## Tři úrovně konfigurace

EF Core podporuje tři úrovně konfigurace; vyšší úroveň přepisuje nižší.

| Úroveň | Mechanismus | Priorita |
|---|---|---|
| Konvence | Automatická heuristika EF Core | Nejnižší |
| Data Annotations | `[Table]`, `[Key]`, `[Required]`, `[BackingField]` apod. | Střední |
| Fluent API | `OnModelCreating` / `IEntityTypeConfiguration<T>` | **Nejvyšší** ✅ |

## Proč Fluent API nad Data Annotations

Komunita (Jon P Smith, Ardalis, Microsoft .NET Microservices book) se shoduje na použití Fluent API, protože Data Annotations **„kontaminují doménový model infrastrukturními obavami"**:

- Doménové entity by neměly záviset na jmenném prostoru `System.ComponentModel.DataAnnotations`
- Fluent API konfiguraci lze centralizovat mimo doménové objekty
- Fluent API nabízí plnou expressivitu pro pokročilá mapování (backing fields, owned types, TPC/TPH/TPT apod.)

## Doporučená organizace konfigurace

### `IEntityTypeConfiguration<T>` — jedna třída na entitu

```csharp
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.ToTable("orders", "ordering");

        builder.Property<DateTime>("_orderDate")
               .UsePropertyAccessMode(PropertyAccessMode.Field)
               .HasColumnName("OrderDate")
               .IsRequired();

        builder.Property(o => o.Description)
               .HasMaxLength(1000);
    }
}
```

### Registrace v DbContext

```csharp
// Jediný řádek zaregistruje všechny IEntityTypeConfiguration<T> z assembly:
modelBuilder.ApplyConfigurationsFromAssembly(typeof(OrderConfiguration).Assembly);
```

> ✅ **Preferovaný přístup** — žádné ruční přidávání každé konfigurace.

### Atribut `[EntityTypeConfiguration]` (EF Core 6+)

Alternativa k `ApplyConfigurationsFromAssembly` — konfiguraci přiřadíš přímo na třídu entity:

```csharp
[EntityTypeConfiguration(typeof(BookConfiguration))]
public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
}
```

> ⚠️ Tento přístup mírně naruší separaci doménové třídy od infrastrukturního jmenného prostoru — zvaž, zda je to pro tvůj projekt akceptabilní.

## Kdy výjimečně akceptovat Data Annotations

| Atribut | Akceptovatelné použití |
|---|---|
| `[Owned]` | Označení owned entity — žádný infrastrukturní vliv na doménu |
| `[ComplexType]` | Označení complex type (EF Core 8+) — výhoda: discoverable bez Fluent API |
| `[NotMapped]` | Explicitní vyloučení vlastnosti z mapování |
| `[BackingField]` | Výjimečně, pokud nemáš přístup k Fluent API konfiguraci |

## Viz také

- [`02-tvar-entit-backing-fields.md`](02-tvar-entit-backing-fields.md) — Kanonické vzory entit a backing fields
- [`07-nullable-reference-types.md`](07-nullable-reference-types.md) — Jak NRT eliminuje potřebu `[Required]`
