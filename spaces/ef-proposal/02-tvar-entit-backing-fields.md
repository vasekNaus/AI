# EF Core: Tvar entit a Backing Fields

> **Technologické zaměření:** .NET 10 / EF Core 10  
> **Zdroj:** Microsoft Learn (backing-field), eShopOnContainers, Context7

---

## Kanonický vzor (Context7 / MS docs)

Context7 (`context7.com/dotnet/efcore`) neobsahuje vlastní entity design guidelines — agreguje oficiální Microsoft dokumentaci. Kanonický vzor z Microsoft/Context7:

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

## Tvar pro zapouzdřenou (DDD) entitu

Vzor z eShopOnContainers — Microsoft doporučuje pro agregátní kořeny:

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

## Typy vlastností podporované EF Core

| Typ | Popis | Poznámka |
|---|---|---|
| Skalární vlastnost (public getter/setter) | Standardní, auto-discovered | Výchozí a nejjednodušší |
| Vlastnost s private setter | EF Core ji vidí jako read-write | Vhodné pro zapouzdření |
| Vlastnost s backing field | EF přistupuje přes field, ne přes getter/setter | Viz níže |
| Field-only property | Žádná CLR property, jen private field | Potřeba explicitní Fluent konfigurace |
| Shadow property | Žádná CLR přítomnost vůbec | Pro metadata (audit, tenant ID) |

---

## Backing Fields — podpora a konfigurace

### Automatická detekce (konvence, pořadí priorit)

EF Core automaticky hledá backing field k property `Url` v tomto pořadí:

| Vzor | Příklad |
|---|---|
| `<camelCasedPropertyName>` | `url` |
| `_<camelCasedPropertyName>` | `_url` ✅ nejčastější |
| `_<PropertyName>` | `_Url` |
| `m_<camelCasedPropertyName>` | `m_url` |
| `m_<PropertyName>` | `m_Url` |

### Explicitní konfigurace backing field

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

### `PropertyAccessMode` — enum hodnoty

> **Výchozí hodnota od EF Core 3.0: `PreferField`**  
> (před EF Core 3.0 byl výchozí `PreferFieldDuringConstruction`)

| Hodnota | Při materializaci z DB | Při čtení v kódu |
|---|---|---|
| `Field` | Vždy field | Vždy field |
| `FieldDuringConstruction` | Field | Property getter |
| `Property` | Property setter | Property getter |
| **`PreferField`** ← **DEFAULT** | **Field pokud existuje, jinak property** | **Field pokud existuje, jinak property** |
| `PreferFieldDuringConstruction` | Field | Property getter |
| `PreferProperty` | Property setter | Property getter |

> 💡 `PreferField` je klíčový pro `?? throw` pattern — EF Core zapisuje přímo do backing field a **nikdy nevolá** property getter při materializaci z DB.

### Field-only property (bez CLR property)

```csharp
public class Blog
{
    private string _validatedUrl;

    public string GetUrl() => _validatedUrl;
    public void SetUrl(string url) { _validatedUrl = url; }
}

// Konfigurace — EF Core musí vědět o field-only property:
modelBuilder.Entity<Blog>().Property("_validatedUrl");

// LINQ přístup přes EF.Property:
var blogs = db.Blogs.OrderBy(b => EF.Property<string>(b, "_validatedUrl"));
```

## Viz také

- [`01-konfigurace-modelu.md`](01-konfigurace-modelu.md) — Fluent API a IEntityTypeConfiguration
- [`03-konstruktory-factory-required.md`](03-konstruktory-factory-required.md) — Konstruktory a factory metody
- [`08-nullable-backing-field-pattern.md`](08-nullable-backing-field-pattern.md) — `?? throw` pattern s backing field
