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

## Preferovaný přístup: Data Annotations

Data Annotations jsou preferovaným přístupem, protože:

- Konfigurace je **discoverable** — viditelná přímo u třídy, bez nutnosti přecházet do samostatného konfiguračního souboru
- **Méně ceremony** — žádná extra třída `IEntityTypeConfiguration<T>` pro základní nastavení
- Pro většinu běžných nastavení (název tabulky, sloupce, délka, klíče, FK, owned/complex typy, indexy, backing fields) **existuje Data Annotation atribut**

Fluent API je vždy dostupné pro pokročilá nastavení, která Data Annotations nepokrývají.

## Kdy použít Fluent API (neexistuje DA alternativa)

Fluent API použij **výhradně** pro konfiguraci, kterou nelze vyjádřit Data Annotations:

- Shadow properties (`.Property<T>("name")`)
- `OwnsMany` s detailní konfigurací (FK, klíče, column names)
- `ComplexProperty().ToJson()` — JSON mapování complex types
- `AutoInclude()` na navigacích
- `HasComputedColumnSql("sql")` — computed columns s SQL výrazem
- `HasDefaultValueSql("sql")` — výchozí SQL výrazy
- Value converters (`HasConversion<T>()`)
- Sekvence (`HasSequence()`)
- Table splitting (více entit na jednu tabulku)
- `UseTpcMappingStrategy()` / `UseTptMappingStrategy()`
- `HasCheckConstraint()`
- Víceúrovňové filtrované indexy (`HasIndex().HasFilter()`, included columns)
- Field-only properties (privátní pole bez CLR property)

## Doporučená organizace konfigurace

### Data Annotations — preferovaný přístup

```csharp
[Table("orders", Schema = "ordering")]
public class Order
{
    [Key]
    public int Id { get; set; }

    [Column("OrderDate")]
    public DateTime OrderDate { get; set; }

    [MaxLength(1000)]
    public string? Description { get; set; }
}
```

### `IEntityTypeConfiguration<T>` — pro konfiguraci bez DA alternativy

```csharp
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        // Pouze pro to, co DA neumí — např. shadow property nebo computed column:
        builder.Property<string>("_auditLog")
               .HasColumnName("AuditLog");

        builder.Property(o => o.OrderDate)
               .HasDefaultValueSql("GETUTCDATE()");
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

## Dostupné Data Annotations atributy

Kompletní přehled Data Annotations pro EF Core a jejich Fluent API ekvivalent:

| Atribut | Nahrazuje Fluent API |
|---|---|
| `[Table("name", Schema = "s")]` | `.ToTable("name", "s")` |
| `[Column("name")]` / `[Column(TypeName = "varchar(50)")]` | `.HasColumnName("name")` / `.HasColumnType(...)` |
| `[Key]` | `.HasKey(e => e.Id)` |
| `[Required]` | `.IsRequired()` (s NRT obvykle zbytečný) |
| `[MaxLength(n)]` / `[StringLength(n)]` | `.HasMaxLength(n)` |
| `[Precision(p, s)]` | `.HasPrecision(p, s)` (EF Core 6+) |
| `[Unicode(false)]` | `.IsUnicode(false)` (EF Core 6+) |
| `[NotMapped]` | `.Ignore(e => e.Prop)` |
| `[ForeignKey("Col_Id")]` | `.HasForeignKey("Col_Id")` |
| `[InverseProperty("NavName")]` | `.WithMany(...)` disambiguation |
| `[BackingField(nameof(_field))]` | `.HasField("_field")` |
| `[Owned]` | `builder.OwnsOne(...)` |
| `[ComplexType]` | `builder.ComplexProperty(...)` (EF Core 8+) |
| `[Index("ColA", "ColB")]` (na třídě) | `.HasIndex(e => new { e.ColA, e.ColB })` |
| `[Keyless]` | `.HasNoKey()` |
| `[Timestamp]` | `.IsRowVersion()` |
| `[ConcurrencyCheck]` | `.IsConcurrencyToken()` |
| `[DatabaseGenerated(DatabaseGeneratedOption.Identity)]` | `.ValueGeneratedOnAdd()` |
| `[Comment("text")]` | `.HasComment("text")` |
| `[DeleteBehavior(DeleteBehavior.Cascade)]` | `.OnDelete(DeleteBehavior.Cascade)` |
| `[EntityTypeConfiguration(typeof(TConfig))]` | ruční `modelBuilder.ApplyConfiguration(...)` |
| `[Discriminator("col")]` + `[DiscriminatorValue("val")]` | `.HasDiscriminator(...)` (EF Core 8+) |

## Viz také

- [`02-tvar-entit-backing-fields.md`](02-tvar-entit-backing-fields.md) — Kanonické vzory entit a backing fields
- [`07-nullable-reference-types.md`](07-nullable-reference-types.md) — Jak NRT eliminuje potřebu `[Required]`
