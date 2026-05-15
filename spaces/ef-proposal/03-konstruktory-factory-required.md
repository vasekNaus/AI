# EF Core: Konstruktory, Factory Metody, `required`, `init`

> **Technologické zaměření:** .NET 10 / EF Core 10 / C# 13  
> **Zdroj:** Microsoft Learn (constructors), Jon P Smith, Ardalis, Khorikov

---

## Čtyři typy konstruktorů podporované EF Core

### Typ 1: Výchozí bezparametrický konstruktor

```csharp
public class Blog
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<Post> Posts { get; } = new List<Post>();
}
```

> ✅ Nejjednodušší — EF Core automaticky použije bezparametrický konstruktor.  
> ⚠️ Anti-pattern pro DDD entity — umožňuje vytvoření v neplatném stavu.

### Typ 2: Parametrizovaný konstruktor (binding na properties)

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

### Typ 3: Read-only vlastnosti s private setters

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

### Typ 4: Pravé read-only vlastnosti s field-only klíčem

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

---

## Factory metody a Named Constructor Pattern

Všichni odborníci (Jon P Smith, Ardalis, Khorikov, Microsoft eShopOnContainers) se shodují: **veřejný bezparametrický konstruktor je anti-pattern** pro DDD entity — umožňuje vytvoření neplatného stavu.

### Doporučený vzor

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

---

## `required` modifier (C# 11+ — preferovaný přístup pro EF Core 8+)

```csharp
public class Customer
{
    public int Id { get; set; }
    public required string Name { get; set; }   // ✅ Kompilátor vynucuje inicializaci
}
```

**Jak `required` funguje s EF Core:**
- EF Core 7+ automaticky obchází `required` constraint při materializaci z DB (interně používá reflection/expression trees)
- `required` ≠ non-nullable: `required string? Name` je syntakticky platné. Pro NOT NULL sloupce kombinuj `required string` (non-nullable required)
- Pro konstruktor inicializaci použij `[SetsRequiredMembers]`:

```csharp
public class Person
{
    public Person() { }

    [SetsRequiredMembers]
    public Person(string firstName) => FirstName = firstName;

    public required string FirstName { get; init; }  // init: immutable po konstrukci
}
```

---

## `init` accessor v EF Core entitách

EF Core podporuje `init` vlastnosti — materializace z DB se považuje za „object construction", takže EF může `init` vlastnosti nastavit.

```csharp
public class Address
{
    public required string Street { get; init; }
    public required string City { get; init; }
    public string? PostCode { get; init; }
}
```

**Omezení `init` v EF Core:**
- EF Core **nemůže** aktualizovat `init` vlastnost po zahájení trackingu (typicky žádoucí pro immutable value properties)
- Pro **navigační vlastnosti** je nutný setter (ne jen `init`): reference navigations must have a setter, although it does not need to be public

---

## Kdy použít jaký přístup

| Situace | Doporučení |
|---|---|
| Jednoduchá CRUD entita | Bezparametrický konstruktor + `required` pro strings |
| Immutable scalar property | `required string Prop { get; init; }` |
| DDD agregátní kořen | Protected ctor + pojmenovaný public konstruktor |
| Vynucení invariantů s error propagation | Static factory → `Result<T>` |
| Navigační vlastnost | Private setter, nikoli `init` |

## Viz také

- [`07-nullable-reference-types.md`](07-nullable-reference-types.md) — CS8618 a tři řešení NRT
- [`04-navigace-a-kolekce.md`](04-navigace-a-kolekce.md) — Navigační vlastnosti a jejich inicializace
- [`09-anti-patterny-a-kontroverze.md`](09-anti-patterny-a-kontroverze.md) — Anti-pattern: veřejný bezparametrický konstruktor
