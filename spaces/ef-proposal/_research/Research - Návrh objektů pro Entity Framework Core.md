# Rešerše: Návrh objektů pro Entity Framework Core

> **Technologické zaměření:** .NET 10 / EF Core 10 (LTS, podpora do listopadu 2028)  
> **Charakter výstupu:** Analytický přehled variant a trade-offů  
> **Zdroje:** Microsoft Learn, EF Core source, Context7, komunitní odborníci

---

## Abstrakt

Entity Framework Core (EF Core) od verze 3 výrazně posílil podporu pro DDD-přátelský návrh objektů. Klíčovými pilíři jsou: konfigurace výhradně přes Fluent API, backing fields pro zapouzdření, konstruktory pro vynucení invariantů, owned entity types pro navigovatelné hodnotové objekty a complex types (nové v EF Core 8, výrazně rozšířené v EF Core 10) pro pravé hodnotové objekty bez identity. Oblast nullable reference types má tři oficiálně dokumentované přístupy, přičemž pattern s privátní nullable backing field a non-null public property s `?? throw` je explicitně uveden v Microsoft dokumentaci jako „striktnější alternativa" k `null!` suppressor patternu. Každý přístup nese jiné trade-offy z hlediska bezpečnosti za běhu, výpovědní hodnoty chybových zpráv a kompatibility se serializací.

---

## 1. Konfigurace modelu — tři úrovně priority

EF Core podporuje tři úrovně konfigurace; vyšší úroveň přepisuje nižší.[^1]

| Úroveň | Mechanismus | Priorita |
|---|---|---|
| Konvence | Automatická heuristika EF Core | Nejnižší |
| Data Annotations | `[Table]`, `[Key]`, `[Required]`, `[BackingField]` apod. | Střední |
| Fluent API | `OnModelCreating` / `IEntityTypeConfiguration<T>` | **Nejvyšší** ✅ |

### Doporučovaný způsob organizace

Komunita (Jon P Smith, Ardalis, Microsoft .NET Microservices book) se shoduje na použití Fluent API přes Data Annotations, protože Data Annotations „kontaminují doménový model infrastrukturními obavami" [^2]:

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
    }
}

// Registrace v DbContext — jediný řádek pro celé assembly:
modelBuilder.ApplyConfigurationsFromAssembly(typeof(OrderConfiguration).Assembly);
```

### Attribute `[EntityTypeConfiguration]` (EF Core 6+)

```csharp
[EntityTypeConfiguration(typeof(BookConfiguration))]
public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
}
```

---

## 2. Tvar entit — základní vzory

### 2.1 Kanonický vzor (Context7 / MS docs)

Context7 (`context7.com/dotnet/efcore`) nevytváří vlastní doporučení — agreguje oficiální Microsoft dokumentaci. Kanonický vzor z Context7:[^3]

```csharp
public class Blog
{
    public int BlogId { get; set; }
    public string Url { get; set; } = string.Empty;      // NRT: nenullový výchozí stav
    public string Title { get; set; } = string.Empty;
    public List<Post> Posts { get; set; } = new();        // Kolekce: nikdy null
}

public class Post
{
    public int PostId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public int BlogId { get; set; }
    public Blog Blog { get; set; } = null!;               // Povinná navigace: null-forgiving
}
```

### 2.2 Tvar pro zapouzdřenou (DDD) entitu (eShopOnContainers / Microsoft)

```csharp
public class Order : Entity, IAggregateRoot
{
    private DateTime _orderDate;                          // backing field pro scalar
    public Address Address { get; private set; }         // private setter pro value object
    private int? _buyerId;                               // pouze FK — žádná navigace na Buyer
    public OrderStatus OrderStatus { get; private set; }
    private readonly List<OrderItem> _orderItems;
    public IReadOnlyCollection<OrderItem> OrderItems => _orderItems;

    protected Order() { }                               // pro EF Core — protected brání zneužití

    public Order(int buyerId, int paymentMethodId, Address address)
    {
        _buyerId = buyerId;
        _orderItems = new List<OrderItem>();
    }

    public void AddOrderItem(int productId, string productName,
                             decimal unitPrice, decimal discount,
                             string pictureUrl, int units = 1)
    {
        _orderItems.Add(new OrderItem(productId, productName, unitPrice,
                                      discount, pictureUrl, units));
    }
}
```
[^4]

### 2.3 Typy vlastností podporované EF Core

| Typ | Popis | Poznámka |
|---|---|---|
| Skalární vlastnost (public getter/setter) | Standardní, auto-discovered | Výchozí a nejjednodušší |
| Vlastnost s private setter | EF Core ji vidí jako read-write | Vhodné pro zapouzdření |
| Vlastnost s backing field | EF přistupuje přes field, ne přes getter/setter | Viz sekce 3 |
| Field-only property | Žádná CLR property, jen private field | Potřeba explicitní Fluent konfigurace |
| Shadow property | Žádná CLR přítomnost vůbec | Pro metadata (audit, tenant ID) |

---

## 3. Backing Fields — podpora a konfigurace

### 3.1 Automatická detekce (konvence, pořadí priorit)

EF Core automaticky hledá backing field k property `Url` v tomto pořadí:[^5]

| Vzor | Příklad |
|---|---|
| `<camelCasedPropertyName>` | `url` |
| `_<camelCasedPropertyName>` | `_url` ✅ nejčastější |
| `_<PropertyName>` | `_Url` |
| `m_<camelCasedPropertyName>` | `m_url` |
| `m_<PropertyName>` | `m_Url` |

### 3.2 Explicitní konfigurace

```csharp
// Přes atribut:
[BackingField(nameof(_validatedUrl))]
public string Url { get { return _validatedUrl; } }

// Přes Fluent API:
modelBuilder.Entity<Blog>()
    .Property(b => b.Url)
    .HasField("_validatedUrl")
    .UsePropertyAccessMode(PropertyAccessMode.PreferFieldDuringConstruction);
```

### 3.3 `PropertyAccessMode` — enum hodnoty

> **Výchozí hodnota od EF Core 3.0: `PreferField`** (před EF Core 3.0 byl výchozí `PreferFieldDuringConstruction`)[^6]

| Hodnota | Int | Chování při materializaci z DB | Chování při čtení v kódu |
|---|---|---|---|
| `Field` | 0 | Vždy field | Vždy field |
| `FieldDuringConstruction` | 1 | Field | Property getter |
| `Property` | 2 | Property setter | Property getter |
| **`PreferField`** | **3** | **Field pokud existuje, jinak property** | **Field pokud existuje, jinak property** ← DEFAULT |
| `PreferFieldDuringConstruction` | 4 | Field | Property getter |
| `PreferProperty` | 5 | Property setter | Property getter |

### 3.4 Field-only property (bez CLR property)

```csharp
public class Blog
{
    private string _validatedUrl;

    public string GetUrl() => _validatedUrl;
    public void SetUrl(string url) { _validatedUrl = url; }
}

// Konfigurace:
modelBuilder.Entity<Blog>().Property("_validatedUrl");

// LINQ přistup:
var blogs = db.Blogs.OrderBy(b => EF.Property<string>(b, "_validatedUrl"));
```

---

## 4. Konstruktory, Factory Metody, `required`, `init`

### 4.1 Čtyři typy konstruktorů podporované EF Core [^7]

#### Typ 1: Výchozí bezparametrický konstruktor

```csharp
public class Blog
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<Post> Posts { get; } = new List<Post>();
}
```

#### Typ 2: Parametrizovaný konstruktor (binding na properties)

EF Core zavolá konstruktor, jehož parametry se **názvem a typem shodují s mappovanými properties** (case-insensitive):

```csharp
public class Blog
{
    public Blog(int id, string name, string author)
    {
        Id = id; Name = name; Author = author;
    }
    public int Id { get; set; }
    public string Name { get; set; }
    public string Author { get; set; }
    public ICollection<Post> Posts { get; } = new List<Post>();
}
```

> ⚠️ **Navigační vlastnosti nelze nastavit přes konstruktor** — EF Core je neumí přes constructor injection bindovat.

#### Typ 3: Read-only vlastnosti s private setters

```csharp
public class Blog
{
    public Blog(int id, string name, string author)
    {
        Id = id; Name = name; Author = author;
    }
    public int Id { get; private set; }        // EF Core vidí private setter jako read-write
    public string Name { get; private set; }
    public string Author { get; private set; }
}
```

#### Typ 4: Pravé read-only vlastnosti s field-only klíčem

```csharp
public class Blog
{
    private int _id;  // field-only PK — NESMÍ být readonly (store-generated klíče potřebují zápis)

    public Blog(string name, string author)
    {
        Name = name; Author = author;
    }

    public string Name { get; }   // skutečně read-only
    public string Author { get; }
}

// OnModelCreating:
modelBuilder.Entity<Blog>(b =>
{
    b.HasKey("_id");
    b.Property(e => e.Author);
    b.Property(e => e.Name);
});
```
> ⚠️ Compiler warning CS0169 „field never used" — lze bezpečně ignorovat; EF Core přistupuje přes reflection.

### 4.2 Factory metody a Named Constructor Pattern

Všichni odborníci (Jon P Smith, Ardalis, Khorikov, Microsoft eShopOnContainers) se shodují: **veřejný bezparametrický konstruktor je anti-pattern** pro DDD entity — umožňuje vytvoření neplatného stavu.[^8]

**Doporučený vzor:**

```csharp
// Private/protected ctor pro EF Core
protected Order() { }

// Veřejný pojmenovaný konstruktor — vynucuje platný výchozí stav
public Order(int buyerId, int paymentMethodId, Address address)
{
    if (buyerId <= 0) throw new ArgumentException("Invalid buyer", nameof(buyerId));
    _buyerId = buyerId;
    _orderItems = new List<OrderItem>();
}

// Statická factory — může vracet Result<T> místo vyhazování výjimky
public static Result<Book> Create(string title, ICollection<Author> authors)
{
    if (string.IsNullOrWhiteSpace(title))
        return Result.Failure<Book>("Title is required");
    return Result.Success(new Book(title, authors));
}
```

### 4.3 `required` modifier (C# 11+ — preferovaný přístup pro EF Core 8+)

```csharp
public class Customer
{
    public int Id { get; set; }
    public required string Name { get; set; }   // ✅ Kompilátor vynucuje inicializaci
}
```

EF Core 7+ automaticky obchází `required` constraint při materializaci z DB (interně používá reflection/expression trees). Kolekce `required` + `init` tvoří preferovaný vzor pro immutable scalar properties:[^9]

```csharp
public class Person
{
    public Person() { }

    [SetsRequiredMembers]
    public Person(string firstName) => FirstName = firstName;

    public required string FirstName { get; init; }  // init: immutable po konstrukci
}
```

> ⚠️ `required` ≠ non-nullable: `required string? Name` je syntakticky platné. Pro NOT NULL sloupce kombinujte `required string` (non-nullable required).

### 4.4 `init` accessor v EF Core entitách

EF Core podporuje `init` vlastnosti — materializace z DB se považuje za „object construction", takže EF může `init` vlastnosti nastavit. Avšak:[^10]

- EF Core **nemůže** aktualizovat `init` vlastnost po zahájení trackingu (což je pro immutable value properties obvykle žádoucí)
- Pro navigační vlastnosti je nutný setter (ne jen `init`): *"Reference navigations must have a setter, although it does not need to be public."*

---

## 5. Navigační Vlastnosti a Kolekce

### 5.1 Reference navigace — pravidla NRT [^11]

```csharp
// ✅ Povinná navigace (required relationship, non-nullable):
public Blog TheBlog { get; set; } = null!;

// ✅ Volitelná navigace (optional relationship, musí být nullable):
public Blog? TheBlog { get; set; }

// ❌ Anti-pattern — inicializace na nenullovou hodnotu:
public Blog TheBlog { get; set; } = new Blog();  // Zakrývá chybějící navigaci
```

### 5.2 Kolekce — pravidla a typy

> **Pravidlo:** *„Collection navigations, which contain references to multiple related entities, should always be non-nullable. An empty collection means no related entities exist, but the list itself should never be null."* [^12]

**Podporované vzory (od nejslabšího po nejsilnější zapouzdření):**

```csharp
// ❌ Anti-pattern — žádné zapouzdření
public List<Post> Posts { get; set; }
public ICollection<Post> Posts { get; set; }

// ✅ Eager init — eliminuje null check (nejběžnější)
public ICollection<Post> Posts { get; } = new List<Post>();

// ✅ Lazy init
private ICollection<Post>? _posts;
public ICollection<Post> Posts => _posts ??= new List<Post>();

// ❌ Anti-pattern — expression body vytváří nový seznam při každém přístupu!
public ICollection<Post> Posts => new List<Post>();

// ✅ DDD zapouzdření (Microsoft eShopOnContainers — doporučeno)
private readonly List<Post> _posts = new();
public IReadOnlyCollection<Post> Posts => _posts;          // readonly pohled
public void AddPost(Post post) => _posts.Add(post);        // kontrolovaná mutace

// ✅ Varianta Ardalis — .AsReadOnly() nemůže být přetypováno na IList<T>
public IEnumerable<Post> Posts => _posts.AsReadOnly();

// ✅ Defenzivní kopie (maximální ochrana, větší overhead)
public IEnumerable<Post> Posts => _posts.ToList();
```

### 5.3 HashSet pro velké kolekce [^13]

```csharp
// MUSÍ použít ReferenceEqualityComparer — entity používají referenční rovnost
public ICollection<Post> Posts { get; } =
    new HashSet<Post>(ReferenceEqualityComparer.Instance);
```

Dle EF Core docs: `List<T>` je efektivní pro malý počet entit a zachovává pořadí; `HashSet<T>` je lepší pro velké kolekce (efektivní vyhledávání, ale bez stabilního pořadí).

### 5.4 Srovnání kolekčních typů

| Typ | Zapouzdření | EF Core podpora | Poznámka |
|---|---|---|---|
| `public List<T>` | ❌ Žádné | ✅ Nativní | Anti-pattern pro DDD |
| `public ICollection<T>` | ❌ Žádné | ✅ Nativní | Anti-pattern pro DDD |
| `IReadOnlyCollection<T>` (backed by `List<T>`) | ✅ Dobré | ✅ S Fluent API | **Doporučení Microsoft/eShopOnContainers** |
| `IEnumerable<T> => _list.AsReadOnly()` | ✅ Dobré | ✅ S Fluent API | **Doporučení Ardalis** |
| `IEnumerable<T> => _list.ToList()` | ✅ Nejlepší | ✅ S Fluent API | Overhead při každém přístupu |

### 5.5 `AutoInclude` — povinné automatické načítání

```csharp
// Navigace vždy includována — eliminuje riziko zapomenutého Include()
modelBuilder.Entity<Order>()
    .Navigation(e => e.Customer)
    .AutoInclude();
```

---

## 6. Owned Entities a Complex Types — Value Objects

### 6.1 Tři kategorie mapovaných objektů v EF Core 8+

| Kategorie | Příklad | Má klíč? | EF typ |
|---|---|---|---|
| Primitivní typy | `int`, `Guid`, `string` | Ne | Skalární vlastnost |
| Entity typy | `Blog`, `Customer`, `Order` | ✅ Ano | Entity type |
| **Hodnotové objekty** | `Address`, `Money`, `PhoneNumber` | ❌ Ne | **Complex type (EF8+)** |

### 6.2 Owned Entity Types

Owned entity jsou entity typy, které **existují pouze jako navigační vlastnosti jiné (owner) entity**. Jsou podobné DDD agregátům. Přestože nemají viditelný klíč, EF Core je interně sleduje přes hidden shadow key properties.[^14]

```csharp
// Konfigurace přes atribut:
[Owned]
public class StreetAddress
{
    public string Street { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
}

// Konfigurace přes Fluent API:
modelBuilder.Entity<Order>().OwnsOne(o => o.ShippingAddress, sa =>
{
    sa.Property(p => p.Street).HasColumnName("ShipsToStreet");
    sa.Property(p => p.City).HasColumnName("ShipsToCity");
});

// Kolekce owned typů:
modelBuilder.Entity<Distributor>().OwnsMany(p => p.ShippingCenters, a =>
{
    a.WithOwner().HasForeignKey("OwnerId");
    a.Property<int>("Id");
    a.HasKey("Id");
});
```

**Klíčová omezení Owned Types:**
- Nelze vytvořit `DbSet<T>` pro owned typy
- Instance **nelze sdílet** mezi více owners (způsobí `InvalidOperationException`)
- Nepodporují dědičnost
- Owned types **mohou mít** navigační vlastnosti na jiné entity (klíčový rozdíl od Complex Types)

### 6.3 Complex Types (EF Core 8+) — pravé hodnotové objekty

Complex types jsou **bez klíče**, mají **value semantics** a lze je sdílet mezi více vlastnostmi.[^15]

```csharp
// Konfigurace přes atribut (MUSÍ být explicitní — neprobíhá discovery konvencí):
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

**Doporučené .NET typy pro Complex Types (v pořadí preferencí):**

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

### 6.4 Novinky EF Core 10 pro Complex Types [^16]

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

> **Oficální doporučení EF10:** *"These issues — as well as various others — make complex types the better choice for modeling JSON and table splitting, and users already using owned entity types for these are advised to switch to complex types."*

### 6.5 Srovnání Owned Types vs Complex Types

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

### 6.6 Rozhodovací strom

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

---

## 7. Dědičnost — TPH, TPT, TPC

### 7.1 TPH — Table Per Hierarchy (výchozí, doporučeno) [^17]

**Schéma:** Jedna tabulka pro celou hierarchii, sloupec diskriminátoru.

```csharp
// Výchozí — žádná konfigurace není potřeba, pokud jsou typy registrovány
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

### 7.2 TPT — Table Per Type (explicitně nedoporučeno)

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

> **Oficální doporučení:** *„Use TPT only if constrained to do so by external factors."* — nejsilnější varování v officálních docs.

### 7.3 TPC — Table Per Concrete Type

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

### 7.4 Srovnávací matice dědičnosti

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

## 8. Nullable Reference Types (NRT) v EF Core entitách

### 8.1 Jak EF Core využívá NRT anotace

Při povolení NRT (`<Nullable>enable</Nullable>`) EF Core čte C# nullability anotace přímo pro odvozování optionality DB sloupců — eliminuje potřebu redundantních `[Required]` atributů nebo Fluent API volání.[^18]

| C# typ | NRT disabled | NRT enabled |
|---|---|---|
| `string` | Optional | **Required** |
| `string?` | Optional | Optional |
| `int` | Required | Required |
| `int?` | Optional | Optional |

> **Oficální doporučení:** *„Using nullable reference types is recommended since it flows the nullability expressed in C# code to EF Core's model and to the database, and obviates the use of the Fluent API or Data Annotations to express the same concept twice."*

> ⚠️ **Varování při migraci:** *„Exercise caution when enabling nullable reference types on an existing project: reference type properties which were previously configured as optional will now be configured as required, unless they are explicitly annotated to be nullable."*

### 8.2 CS8618 — tři oficiální řešení

Při povolení NRT tento běžný vzor vyvolá **CS8618** (uninitialized non-nullable property):[^19]

```csharp
public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; } // ⚠️ CS8618
}
```

#### Řešení A: `required` modifier (C# 11+ — preferované pro EF Core 8+)

```csharp
public required string Name { get; set; }
```

#### Řešení B: Constructor binding (C# 8/9/10)

```csharp
public class Customer
{
    public string Name { get; set; }

    public Customer(string name) { Name = name; }
}
```

> Omezení: Navigační vlastnosti **nelze inicializovat přes konstruktor**.

#### Řešení C: `null!` null-forgiving operator (nejčastěji pro navigace)

```csharp
public Product Product { get; set; } = null!;
```

> `!` nemá žádný runtime efekt — pouze mění null-stav v statické analýze kompilátoru.

### 8.3 Filozofie pro required navigace — tři přístupy [^20]

#### Filosofie 1: Non-nullable navigace (null! suppressor)

```csharp
public Customer Customer { get; set; } = null!;
```

> *„Should be non-nullable if it is considered a programmer error to access a navigation when it is not loaded."*
> Přístup k nenačtené navigaci → `NullReferenceException` (bez popisu kontextu).

#### Filosofie 2: Nullable navigace

```csharp
public Customer? Customer { get; set; }
```

> *„Should be nullable if it is acceptable for application code to check the navigation to determine whether or not the relationship is loaded."*
> DB sloupec je stále NOT NULL — nullabilita platí pouze pro in-memory loaded/unloaded stav.

#### Filosofie 3: Stricter approach — nullable backing field + non-null property s `?? throw`

Viz sekce 9 níže — **tento přístup je explicitně zdokumentován v Microsoft dokumentaci**.

### 8.4 Kolekční navigace — vždy non-null

```csharp
// ✅ Vždy inicializovat inline:
public ICollection<Post> Posts { get; } = new List<Post>();

// ✅ Lazy init (také platné):
private ICollection<Post>? _posts;
public ICollection<Post> Posts => _posts ??= new List<Post>();
```

### 8.5 DbSet vlastnosti v DbContext

```csharp
// EF Core 7+: CS8618 automaticky potlačeno přes reflection
public DbSet<Customer> Customers { get; set; }

// EF Core < 7.0 — dvě možnosti:
public DbSet<Customer> Customers => Set<Customer>();  // expression body
// nebo:
public DbSet<Customer> Customers { get; set; } = null!;  // null! suppressor
```

### 8.6 `MemberNotNull` atribut pro helper inicializaci

```csharp
[MemberNotNull(nameof(Major))]
private void SetMajor(string? major = default)
{
    Major = major ?? "Undeclared";  // garantuje non-null po návratu
}
```

---

## 9. Pattern: Privátní Nullable Backing Field + Non-null Public Property s `?? throw`

### 9.1 Popis patternu

```csharp
private Customer? _customer;

public Customer Customer
{
    set => _customer = value;
    get => _customer
           ?? throw new InvalidOperationException("Uninitialized property: " + nameof(Customer));
}
```

### 9.2 Dokumentace Microsoftu — explicitní

**ANO — Microsoft tento pattern explicitně dokumentuje.**

Zdroj: `learn.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types`, sekce *„Required navigation properties"*[^21]

Microsoftův popis (doslova):
> *„If you'd like a stricter approach, you can have a non-nullable property with a nullable backing field. As long as the navigation is properly loaded, the dependent will be accessible via the property. If, however, the property is accessed without first properly loading the related entity, an `InvalidOperationException` is thrown, since the API contract has been used incorrectly."*

### 9.3 Chování C# NRT analyzátoru

Roslyn NRT flow analyzátor **správně vidí vlastnost jako non-null** na všech call sites:[^22]

- Backing field `_customer?` je typován jako `Customer?` (nullable)
- Property `Customer` je typována jako `Customer` (non-nullable)
- Výraz `?? throw` je C# *throw expression* — Roslyn ví, že každá větvě, která dosáhne returnu, musí mít nenullový `_customer` (tzv. „null divergence" analýza)
- Na call sites: `order.Customer.Name` — kompilátor nevydá žádné CS8602 upozornění
- Setter `set => _customer = value` — přijímá `Customer` (non-nullable), přiřazení `null` je kompilační chyba

### 9.4 Chování EF Core při materializaci

**Pattern funguje správně s výchozím nastavením EF Core.**

Výchozí `PropertyAccessMode.PreferField` (od EF Core 3.0) způsobuje, že EF Core při materializaci entity z DB:[^23]

1. Najde backing field konvencí (např. `_customer` pro property `Customer`)
2. **Zapíše přímo do backing field** přes reflection, zcela obchází property getter
3. `?? throw` getter **není nikdy volán** při DB materializaci — volá ho pouze aplikační kód

| PropertyAccessMode | Při materializaci z DB | Riziko s `?? throw` |
|---|---|---|
| `PreferField` **(výchozí)** | Zapisuje do `_customer` přímo | **Pattern funguje správně** |
| `Field` | Zapisuje do `_customer` přímo | **Pattern funguje správně** |
| `FieldDuringConstruction` | Zapisuje do field | **Pattern funguje správně** |
| `Property` | Volá property setter | **Funguje pokud setter není null-guarded** |

### 9.5 Runtime rizika — kdy dojde k neočekávané výjimce

#### Riziko 1: Serializace přes `System.Text.Json` nebo Newtonsoft.Json (🔴 VYSOKÉ)

`System.Text.Json` serializuje voláním property getterů. Pokud navigace nebyla includována:

```
System.InvalidOperationException: Uninitialized property: Customer
```

**Mitigace:**
- `[JsonIgnore]` na navigační vlastnosti
- Používat DTO/projekce místo serializace entit přímo
- Zajistit include všech navigací před serializací

#### Riziko 2: Detached entity (🔴 VYSOKÉ)

```csharp
context.Entry(order).State = EntityState.Detached;
var name = order.Customer.Name; // THROWS pokud Customer nebyl načten
```

**Mitigace:** `AsNoTracking()` s explicitním `Include()`, nebo zajistit načtení před detach.

#### Riziko 3: Navigation Fixup non-determinismus (🟡 STŘEDNÍ)

EF Core change tracker „fixup" naplní navigace, pokud jsou related entity v trackeru. Chování `?? throw` patternu může být nedeterministické — v některých kontextech neprovede throw (fixup proběhl), v jiných ano:

```csharp
// Customer je v change trackeru z předchozího dotazu:
var orders = context.Orders.ToList(); // Customer IS fixed up → no throw
// vs.
var orders = context.Orders.AsNoTracking().ToList(); // NO fixup → throw on access
```

#### Riziko 4: Chybějící ThenInclude v kaskádě (🟡 STŘEDNÍ)

```csharp
var orders = await context.Orders
    .Include(o => o.Customer)
    // .ThenInclude(c => c.Address)  ← zapomenuto!
    .ToListAsync();
var city = orders[0].Customer.Address.City; // THROWS: "Uninitialized property: Address"
```

Chybová zpráva je výmluvná — přesně identifikuje chybějící článek kaskády.

#### Riziko 5: Lazy loading s detached entitami (🔴 VYSOKÉ)

Lazy loading interceptor načte navigaci před voláním gettera — ale pouze pokud je entita tracked a loader je dostupný. Pro detached entity interceptor nic nedělá a getter hodí výjimku místo vrácení `null`.[^24]

### 9.6 Kompatibilita s Lazy Loading Proxies

- **Vyžaduje `virtual` vlastnost** — Castle DynamicProxy může interceptovat pouze `virtual` metody
- **Funguje pokud entita je tracked a kontext je dostupný** — loader načte navigaci PŘED voláním gettera
- **Selhává pro detached entity** — hodí `InvalidOperationException` místo vrácení `null`
- **Mění detached contract**: `null!` suppressor vrací `null` pro detached navigace (null-check funguje); `?? throw` hodí výjimku (null-check nelze použít)

### 9.7 Srovnání variant pro required navigace

| Aspekt | `null!` Suppressor | `?? throw` Pattern | `Customer?` Nullable |
|---|---|---|---|
| **Syntaxe** | `= null!` | Backing field + property | `Customer? Customer` |
| **Compiler warningy** | ✅ Žádné | ✅ Žádné | ⚠️ Nutné null-checky |
| **Runtime při nenačtené navigaci** | `NullReferenceException` (bez popisu) | `InvalidOperationException` s popisem | Vrátí `null` |
| **Kvalita chybové zprávy** | ❌ Bez kontextu | ✅ „Uninitialized property: X" | ✅ Žádná výjimka |
| **Verbose kód** | ✅ Nízká | ❌ Střední | ✅ Nízká |
| **EF Core materializace** | ✅ Funguje | ✅ Funguje (field bypass) | ✅ Funguje |
| **Serializace** | ❌ NRE pokud nenačteno | ❌ IOE pokud nenačteno | ✅ Serializuje null |
| **Lazy loading** | ✅ S `virtual` | ✅ S `virtual`, riziko pro detached | ✅ S `virtual` |
| **Dokumentováno Microsoftem?** | ✅ „Simple option" | ✅ „Stricter option" | ✅ „If acceptable to check" |

### 9.8 Komunita — sentiment

| Skupina | Postoj |
|---|---|
| DDD zastánci | **Silně pozitivní** — „nevystavuj surové null z domény" |
| Architekti service layer | **Pozitivní** — lepší chybová zpráva vs. tichý NRE |
| API/serializační týmy | **Negativní** — způsobuje neočekávaná serializační selhání |
| Lazy loading uživatelé | **Opatrný** — nutné `virtual`, riziko pro detached entity |
| „Simple is better" škola | **Preferuje `null!`** — méně ceremonie, stejný výsledek |

### 9.9 Komunitní terminologie

Pattern nemá formální jméno v Microsoft docs. V komunitních diskusích je označován jako:
- **„Nullable backing field pattern"** (nejčastěji)
- **„Throw-on-access navigation"**
- **„Strict navigation property"**
- **„Guarded navigation"**

V kontextu funkcionálního programování jde o variaci **Maybe monady** (viz GitHub issue #22504).

### 9.10 Mitigace rizik patternu

```csharp
// Mitigace 1: AutoInclude — eliminuje riziko zapomenutého Include()
modelBuilder.Entity<Order>()
    .Navigation(e => e.Customer)
    .AutoInclude();

// Mitigace 2: JsonIgnore — zabraňuje serializačním chybám
[JsonIgnore]
public Customer Customer
{
    get => _customer ?? throw new InvalidOperationException("Customer not loaded");
    set => _customer = value;
}

// Mitigace 3: Používat DTOs/projekce místo přímé serializace entit
var dto = new OrderDto(order.Id, order.OrderItems.Select(i => i.ProductName));
```

---

## 10. Anti-Patterny v EF Core Entity Design

Souhrn anti-patternů ze zdrojů (Microsoft, Jon P Smith, Ardalis, Khorikov, Arthur Vickers):[^25]

| Anti-Pattern | Proč je špatný | Správné řešení |
|---|---|---|
| `public List<T>` navigační kolekce | Umožňuje obejít metody aggregate root | `private readonly List<T>` + `IReadOnlyCollection<T>` |
| Veřejný bezparametrický konstruktor na DDD entitě | Umožňuje vytvoření v neplatném stavu | Protected/private ctor pro EF + pojmenovaný public konstruktor |
| Data Annotations na doménových entitách | Kontaminuje doménový model infrastrukturními obavami | Výhradně Fluent API |
| Anemic domain model (gettery/settery pro vše) | Logika fragmentována do service vrstvy | Metody a chování na entitách (pro komplexní domény) |
| Inicializace reference navigace na non-null default: `= new Blog()` | Zakrývá chybějící navigaci | `null!` nebo `?? throw` nebo `Customer?` |
| Expression-bodied kolekce `=> new List<T>()` | Vytváří nový seznam při každém přístupu | `{ get; } = new List<T>()` nebo backing field |
| `IsValid()` vzor (entita musí vstoupit do neplatného stavu pro validaci) | Porušuje invarianty | CanExecute/Execute vzor nebo always-valid model |
| Přímá navigace na jiné agregáty (reference, ne FK) | Porušuje aggregate boundary | Pouze FK pole mezi agregáty |
| DbContext injection do metod entity | Přímá vazba entity na EF Core | Hodnoty předávat jako parametry, nebo přijmout DM completeness kompromis |

---

## 11. Kontroverzní Oblasti — Kde se Komunita Neshoduje

### 1. DbContext injection do entity metod

- **Jon P Smith**: Akceptuje — injektuje `DbContext` do `AddReview(DbContext context)` pro správu agregátů
- **Ardalis**: „entity jsou těsně svázány s EF Core — to není dobré"
- **Khorikov**: Silně odmítá — volí domain model purity nad completeness

### 2. Repository pattern

- **Jon P Smith, Rob Conery**: Proti generickému repository nad EF Core
- **Ardalis, Microsoft official**: Pro custom repositories (se specification pattern)

### 3. `IReadOnlyCollection<T>` vs `IEnumerable<T>` pro kolekce

- **Microsoft/eShopOnContainers**: `IReadOnlyCollection<T>` — poskytuje `Count` + read přístup
- **Ardalis**: `IEnumerable<T>` s `.AsReadOnly()` — bezpečnější proti přetypování
- **Arthur Vickers (EF team)**: Obojí je podporováno; defenzivní `.ToList()` kopie je nejbezpečnější, ale s overhead

### 4. Separátní persistence model vs. přímé ORM mapování

- **Striktní DDD puristé**: Pro — doménové objekty mají být persistence-agnostické
- **Khorikov (2016)**: Proti — příliš drahé; EF Core/NHibernate umí mapovat rich domain modely přímo
- **Praktický konsenzus (2024)**: EF Core Fluent API + backing fields je dostatečné; separátní model je vzácně ospravedlnitelný

---

## 12. Confidence Assessment

| Oblast | Jistota | Poznámka |
|---|---|---|
| EF Core dokumentace (MS Learn) | **Vysoká** | Přímo načteno z Microsoft Learn |
| `PropertyAccessMode` enum | **Vysoká** | Ověřeno z MS Learn + EF Core source |
| `?? throw` pattern dokumentace | **Vysoká** | Explicitně citován v MS NRT docs |
| EF Core 10 Complex Types | **Vysoká** | Z EF10 What's New |
| Lazy loading interceptor chování | **Střední** | Z EF Core source kódu (může se lišit verzí) |
| Context7 vlastní guidelines | **Vysoká** | Context7 neobsahuje vlastní guidelines — jen mirror MS docs |
| Khorikov/Jon P Smith pozice | **Vysoká** | Přímo z jejich blogů |
| Roslyn NRT analyzer chování pro `?? throw` | **Střední** | Inferované ze spec a known behavior, ne přímo ze spec dokumentu |
| `init` + EF Core materializace | **Střední** | MS docs to implicitně předpokládají, ne explicitně dokumentováno |

---

## Poznámky k zdrojům

- **Context7** (`context7.com/dotnet/efcore`) neobsahuje vlastní entity design guidelines — je to auto-generated agregátor oficiální Microsoft dokumentace. Vlastní doporučení hledejte v MS Learn.
- **Vladimír Khorikov** psal v roce 2016 o preferenci NHibernate před EF Core pro DDD — EF Core od té doby výrazně dohnal ztrátu backing fields, `OwnsOne`, `IReadOnlyCollection<T>` podporou.
- `/ef/core/modeling/complex-types` dedikovaná stránka **neexistuje (404)** — kanonický zdroj pro Complex Types je stránka EF8 a EF10 „What's New".
- `/ef/core/modeling/backing-fields` (množné číslo) vrací **404** — správná URL je `/backing-field` (jednotné číslo).

---

## Footnotes

[^1]: [Creating and Configuring a Model — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/) — konfigurace tří úrovní
[^2]: [Infrastructure Persistence Layer Implementation — .NET Microservices](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-implementation-entity-framework-core) — Fluent API doporučení
[^3]: [context7.com/dotnet/efcore/llms.txt](https://context7.com/dotnet/efcore) — DbContext sekce, kanonický entity vzor
[^4]: [Microservice Domain Model — .NET Microservices](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-domain-model) — Order aggregate root vzor
[^5]: [Backing Field — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/backing-field) — konvence detekce backing field
[^6]: [PropertyAccessMode Enum — EF Core API Reference](https://learn.microsoft.com/en-us/dotnet/api/microsoft.entityframeworkcore.propertyaccessmode) — popis enum hodnot a výchozí hodnoty
[^7]: [Entity Constructors — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/constructors) — čtyři typy konstruktorů a binding pravidla
[^8]: [Creating Domain-Driven Design Entity Classes with EF Core — Jon P Smith](https://www.thereformedprogrammer.net/creating-domain-driven-design-entity-classes-with-entity-framework-core/) — factory metody a DDD přístup
[^9]: [Nullable Reference Types — EF Core](https://learn.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types) — `required` modifier a `[SetsRequiredMembers]`
[^10]: [Relationships — Navigations — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/relationships/navigations) — `init` accessor a setter požadavky
[^11]: [Relationships — Navigations — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/relationships/navigations) — reference navigation pravidla
[^12]: [Relationships — Navigations — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/relationships/navigations) — collection navigation pravidla
[^13]: [Relationships — Navigations — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/relationships/navigations) — HashSet a ReferenceEqualityComparer
[^14]: [Owned Entity Types — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/owned-entities) — owned entity konfigurace a omezení
[^15]: [What's New in EF Core 8 — Complex Types](https://learn.microsoft.com/en-us/ef/core/what-is-new/ef-core-8.0/whatsnew) — kompletní dokumentace complex types
[^16]: [What's New in EF Core 10](https://learn.microsoft.com/en-us/ef/core/what-is-new/ef-core-10.0/whatsnew) — nullable complex types, JSON mapping, struct support
[^17]: [Inheritance — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/inheritance) — TPH/TPT/TPC strategie a doporučení
[^18]: [Entity Properties — EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/entity-properties) — NRT a odvozování optionality
[^19]: [Nullable Reference Types — EF Core](https://learn.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types) — CS8618 a tři officiální řešení
[^20]: [Nullable Reference Types — EF Core](https://learn.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types) — sekce „Required navigation properties", tři filosofie
[^21]: [Nullable Reference Types — EF Core](https://learn.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types) — sekce „Required navigation properties", `?? throw` vzor
[^22]: [Null-Forgiving Operator — C# Reference](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/null-forgiving) — runtime chování a statická analýza
[^23]: [dotnet/efcore src/EFCore/PropertyAccessMode.cs](https://github.com/dotnet/efcore) — PreferField jako výchozí od EF Core 3.0
[^24]: [dotnet/efcore src/EFCore.Proxies/Proxies/Internal/LazyLoadingInterceptor.cs](https://github.com/dotnet/efcore) — lazy loading interceptor logika
[^25]: [Encapsulated Collections in EF Core — Ardalis](https://ardalis.com/encapsulated-collections-in-entity-framework-core/) + [Is the Repository Pattern Useful with EF Core? — Jon P Smith](https://www.thereformedprogrammer.net/is-the-repository-pattern-useful-with-entity-framework-core/) + [Always-Valid Domain Model — Khorikov](https://enterprisecraftsmanship.com/posts/always-valid-domain-model/) — anti-pattern přehled
