# EF Core: Navigační Vlastnosti a Kolekce

> **Technologické zaměření:** .NET 10 / EF Core 10  
> **Zdroj:** Microsoft Learn (relationships/navigations), eShopOnContainers, Ardalis

---

## Reference navigace — pravidla NRT

```csharp
// ✅ Povinná navigace (required relationship, non-nullable):
public Blog TheBlog { get; set; } = null!;

// ✅ Volitelná navigace (optional relationship, musí být nullable):
public Blog? TheBlog { get; set; }

// ❌ Anti-pattern — inicializace na nenullovou hodnotu:
public Blog TheBlog { get; set; } = new Blog();  // Zakrývá chybějící načtení navigace
```

> **Pravidlo:** Pokud je vztah v DB NOT NULL (required), použij non-nullable typ. Pokud je vztah nullable (optional), použij nullable typ. NRT v C# tak přesně mapuje na nullabilitu DB sloupce.

---

## Kolekce — pravidla a typy

> **Pravidlo:** *„Collection navigations, which contain references to multiple related entities, should always be non-nullable. An empty collection means no related entities exist, but the list itself should never be null."* — Microsoft Learn

### Varianty kolekčního vzoru (od nejslabšího po nejsilnější zapouzdření)

```csharp
// ❌ Anti-pattern — žádné zapouzdření, možnost externího přidávání
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

---

## HashSet pro velké kolekce

```csharp
// MUSÍ použít ReferenceEqualityComparer — entity používají referenční rovnost
public ICollection<Post> Posts { get; } =
    new HashSet<Post>(ReferenceEqualityComparer.Instance);
```

Dle EF Core docs:
- `List<T>` — efektivní pro malý počet entit, zachovává pořadí
- `HashSet<T>` — efektivní pro velké kolekce (efektivní vyhledávání, bez stabilního pořadí)

---

## Srovnání kolekčních typů

| Typ | Zapouzdření | EF Core podpora | Poznámka |
|---|---|---|---|
| `public List<T>` | ❌ Žádné | ✅ Nativní | Anti-pattern pro DDD |
| `public ICollection<T>` | ❌ Žádné | ✅ Nativní | Anti-pattern pro DDD |
| `IReadOnlyCollection<T>` (backed by `List<T>`) | ✅ Dobré | ✅ S Fluent API | **Doporučení Microsoft/eShopOnContainers** |
| `IEnumerable<T> => _list.AsReadOnly()` | ✅ Dobré | ✅ S Fluent API | **Doporučení Ardalis** |
| `IEnumerable<T> => _list.ToList()` | ✅ Nejlepší | ✅ S Fluent API | Overhead při každém přístupu |

---

## `AutoInclude` — povinné automatické načítání

```csharp
// Navigace vždy includována — eliminuje riziko zapomenutého Include()
modelBuilder.Entity<Order>()
    .Navigation(e => e.Customer)
    .AutoInclude();
```

> 💡 `AutoInclude()` je klíčová mitigace pro `?? throw` pattern — zaručuje, že navigace je vždy načtena.

---

## Kontroverzní: `IReadOnlyCollection<T>` vs `IEnumerable<T>`

Komunita se neshoduje:

| Zdroj | Preferovaný typ | Důvod |
|---|---|---|
| **Microsoft / eShopOnContainers** | `IReadOnlyCollection<T>` | Poskytuje `Count` + read přístup |
| **Ardalis** | `IEnumerable<T>` s `.AsReadOnly()` | Bezpečnější — nelze přetypovat na `IList<T>` |
| **Arthur Vickers (EF team)** | Obojí platné; `.ToList()` defenzivní | Nejbezpečnější, ale s overhead |

## Viz také

- [`08-nullable-backing-field-pattern.md`](08-nullable-backing-field-pattern.md) — `?? throw` pro reference navigace
- [`03-konstruktory-factory-required.md`](03-konstruktory-factory-required.md) — Inicializace kolekcí v konstruktoru
- [`09-anti-patterny-a-kontroverze.md`](09-anti-patterny-a-kontroverze.md) — Anti-patterny pro kolekce
