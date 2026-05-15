# EF Core: Nullable Reference Types (NRT)

> **Technologické zaměření:** .NET 10 / EF Core 10 / C# 13  
> **Zdroj:** Microsoft Learn (nullable-reference-types, entity-properties, relationships/navigations)

---

## Jak EF Core využívá NRT anotace

Při povolení NRT (`<Nullable>enable</Nullable>`) EF Core čte C# nullability anotace přímo pro odvozování optionality DB sloupců — eliminuje potřebu redundantních `[Required]` atributů nebo Fluent API volání.

| C# typ | NRT disabled | NRT enabled |
|---|---|---|
| `string` | Optional | **Required** |
| `string?` | Optional | Optional |
| `int` | Required | Required |
| `int?` | Optional | Optional |

> **Oficální doporučení:** *„Using nullable reference types is recommended since it flows the nullability expressed in C# code to EF Core's model and to the database, and obviates the use of the Fluent API or Data Annotations to express the same concept twice."*

> ⚠️ **Varování při migraci:** *„Exercise caution when enabling nullable reference types on an existing project: reference type properties which were previously configured as optional will now be configured as required, unless they are explicitly annotated to be nullable."*

---

## CS8618 — tři oficiální řešení

Při povolení NRT tento vzor vyvolá **CS8618** (uninitialized non-nullable property):

```csharp
public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; } // ⚠️ CS8618
}
```

### Řešení A: `required` modifier (C# 11+ — preferované pro EF Core 8+)

```csharp
public required string Name { get; set; }
```

- ✅ Kompilátor vynucuje inicializaci na call site
- ✅ EF Core automaticky obchází `required` při materializaci z DB
- ✅ Žádný boilerplate

### Řešení B: Constructor binding (C# 8/9/10)

```csharp
public class Customer
{
    public string Name { get; set; }

    public Customer(string name) { Name = name; }
}
```

- ✅ Funguje bez C# 11
- ⚠️ Navigační vlastnosti **nelze inicializovat přes konstruktor**

### Řešení C: `null!` null-forgiving operator (nejčastěji pro navigace)

```csharp
public Product Product { get; set; } = null!;
```

- ✅ Nejjednodušší pro navigační vlastnosti
- ⚠️ `!` nemá žádný runtime efekt — pouze mění null-stav v statické analýze kompilátoru
- ⚠️ Přístup k nenačtené navigaci → `NullReferenceException` bez popisné zprávy

---

## Filosofie pro required navigace — tři přístupy

### Filosofie 1: Non-nullable navigace (null! suppressor)

```csharp
public Customer Customer { get; set; } = null!;
```

> *„Should be non-nullable if it is considered a programmer error to access a navigation when it is not loaded."*  
> Přístup k nenačtené navigaci → `NullReferenceException` (bez popisu kontextu).

### Filosofie 2: Nullable navigace

```csharp
public Customer? Customer { get; set; }
```

> *„Should be nullable if it is acceptable for application code to check the navigation to determine whether or not the relationship is loaded."*  
> DB sloupec je stále NOT NULL — nullabilita platí pouze pro in-memory loaded/unloaded stav.

### Filosofie 3: Stricter approach — nullable backing field + non-null property s `?? throw`

```csharp
private Customer? _customer;

public Customer Customer
{
    set => _customer = value;
    get => _customer
           ?? throw new InvalidOperationException("Uninitialized property: " + nameof(Customer));
}
```

> Viz [`08-nullable-backing-field-pattern.md`](08-nullable-backing-field-pattern.md) — detailní analýza tohoto patternu.

---

## Kolekční navigace — vždy non-null

```csharp
// ✅ Vždy inicializovat inline:
public ICollection<Post> Posts { get; } = new List<Post>();

// ✅ Lazy init (také platné):
private ICollection<Post>? _posts;
public ICollection<Post> Posts => _posts ??= new List<Post>();
```

---

## DbSet vlastnosti v DbContext

```csharp
// EF Core 7+: CS8618 automaticky potlačeno přes reflection
public DbSet<Customer> Customers { get; set; }

// EF Core < 7.0 — dvě možnosti:
public DbSet<Customer> Customers => Set<Customer>();  // expression body
// nebo:
public DbSet<Customer> Customers { get; set; } = null!;  // null! suppressor
```

---

## `MemberNotNull` atribut pro helper inicializaci

```csharp
[MemberNotNull(nameof(Major))]
private void SetMajor(string? major = default)
{
    Major = major ?? "Undeclared";  // garantuje non-null po návratu
}
```

---

## Kdy použít jaké řešení NRT

| Vlastnost | Doporučené řešení |
|---|---|
| Skalární non-nullable string (C# 11+) | `required string Name { get; set; }` |
| Skalární non-nullable string (C# 8-10) | Konstruktor binding |
| Required reference navigace (jednoduché) | `= null!` (null-forgiving) |
| Required reference navigace (DDD, striktní) | `?? throw` backing field pattern |
| Optional reference navigace | `Customer? Customer { get; set; }` |
| Kolekce navigace | `= new List<T>()` nebo backing field |

## Viz také

- [`08-nullable-backing-field-pattern.md`](08-nullable-backing-field-pattern.md) — `?? throw` pattern detailně
- [`03-konstruktory-factory-required.md`](03-konstruktory-factory-required.md) — `required` a `init` v EF Core
- [`04-navigace-a-kolekce.md`](04-navigace-a-kolekce.md) — Inicializace kolekcí
