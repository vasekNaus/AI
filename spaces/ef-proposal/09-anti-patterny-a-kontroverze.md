# EF Core: Anti-Patterny a Kontroverzní Oblasti

> **Technologické zaměření:** .NET 10 / EF Core 10  
> **Zdroj:** Microsoft, Jon P Smith, Ardalis, Vladimir Khorikov, Arthur Vickers (EF team)

---

## Anti-Patterny v EF Core Entity Design

| Anti-Pattern | Proč je špatný | Správné řešení |
|---|---|---|
| `public List<T>` navigační kolekce | Umožňuje obejít metody aggregate root | `private readonly List<T>` + `IReadOnlyCollection<T>` |
| Veřejný bezparametrický konstruktor na DDD entitě | Umožňuje vytvoření v neplatném stavu | Protected/private ctor pro EF + pojmenovaný public konstruktor |
| Fluent API pro konfiguraci dostupnou přes Data Annotations | Zbytečná ceremony — konfigurace oddělena od entity, vyžaduje extra třídu | Použít příslušný Data Annotation atribut (`[Table]`, `[Column]`, `[MaxLength]`, `[BackingField]` apod.) |
| Anemic domain model (gettery/settery pro vše) | Logika fragmentována do service vrstvy | Metody a chování na entitách (pro komplexní domény) |
| Inicializace reference navigace na non-null default: `= new Blog()` | Zakrývá chybějící načtení navigace | `null!` nebo `?? throw` nebo `Customer?` |
| Expression-bodied kolekce `=> new List<T>()` | Vytváří nový seznam při každém přístupu | `{ get; } = new List<T>()` nebo backing field |
| `IsValid()` vzor | Entita musí vstoupit do neplatného stavu pro validaci — porušuje invarianty | CanExecute/Execute vzor nebo always-valid model |
| Přímá navigace na jiné agregáty (reference, ne FK) | Porušuje aggregate boundary | Pouze FK pole mezi agregáty |
| DbContext injection do metod entity | Přímá vazba entity na EF Core | Hodnoty předávat jako parametry, nebo přijmout DM completeness kompromis |

### Anti-Pattern: Inicializace navigace na `new Blog()`

```csharp
// ❌ Anti-pattern
public Blog TheBlog { get; set; } = new Blog();  // vytváří phantom entitu

// ✅ Správně
public Blog TheBlog { get; set; } = null!;         // null-forgiving
// nebo
public Blog? TheBlog { get; set; }                 // nullable
```

### Anti-Pattern: Expression-bodied kolekce

```csharp
// ❌ Anti-pattern — nový seznam při každém přístupu!
public ICollection<Post> Posts => new List<Post>();

// ✅ Správně — jedna instance
public ICollection<Post> Posts { get; } = new List<Post>();
```

---

## Kontroverzní Oblasti — Kde se Komunita Neshoduje

### 1. DbContext injection do entity metod

Různí odborníci mají fundamentálně odlišné pohledy:

| Autor | Postoj |
|---|---|
| **Jon P Smith** | Akceptuje — injektuje `DbContext` do `AddReview(DbContext context)` pro správu agregátů |
| **Ardalis** | „entity jsou těsně svázány s EF Core — to není dobré" |
| **Khorikov** | Silně odmítá — volí domain model purity nad completeness |

### 2. Repository pattern s EF Core

| Autor | Postoj |
|---|---|
| **Jon P Smith, Rob Conery** | Proti generickému repository nad EF Core — `DbContext` je již Unit of Work + Repository |
| **Ardalis, Microsoft official** | Pro custom repositories (se specification pattern) |

### 3. `IReadOnlyCollection<T>` vs `IEnumerable<T>` pro kolekce

| Zdroj | Preferovaný typ | Důvod |
|---|---|---|
| **Microsoft / eShopOnContainers** | `IReadOnlyCollection<T>` | Poskytuje `Count` + read přístup |
| **Ardalis** | `IEnumerable<T>` s `.AsReadOnly()` | Bezpečnější — nelze přetypovat na `IList<T>` |
| **Arthur Vickers (EF team)** | Obojí platné; `.ToList()` defenzivní | Nejbezpečnější, ale s overhead |

### 4. Separátní persistence model vs. přímé ORM mapování

| Pohled | Postoj |
|---|---|
| **Striktní DDD puristé** | Pro — doménové objekty mají být persistence-agnostické |
| **Khorikov (aktualizovaný postoj)** | Proti — příliš drahé; EF Core/NHibernate umí mapovat rich domain modely přímo |
| **Praktický konsenzus (2024)** | EF Core Fluent API + backing fields je dostatečné; separátní model je vzácně ospravedlnitelný |

---

## Confidence Assessment rešerše

| Oblast | Jistota | Poznámka |
|---|---|---|
| EF Core dokumentace (MS Learn) | **Vysoká** | Přímo načteno z Microsoft Learn |
| `PropertyAccessMode` enum | **Vysoká** | Ověřeno z MS Learn + EF Core source |
| `?? throw` pattern dokumentace | **Vysoká** | Explicitně citován v MS NRT docs |
| EF Core 10 Complex Types | **Vysoká** | Z EF10 What's New |
| Lazy loading interceptor chování | **Střední** | Z EF Core source kódu (může se lišit verzí) |
| Context7 vlastní guidelines | **Vysoká** | Context7 neobsahuje vlastní guidelines — jen mirror MS docs |
| Khorikov/Jon P Smith pozice | **Vysoká** | Přímo z jejich blogů |
| Roslyn NRT analyzer chování pro `?? throw` | **Střední** | Inferované ze spec a known behavior |
| `init` + EF Core materializace | **Střední** | MS docs to implicitně předpokládají, ne explicitně dokumentováno |

---

## Poznámky k zdrojům

- **Context7** (`context7.com/dotnet/efcore`) neobsahuje vlastní entity design guidelines — je to auto-generated agregátor oficiální Microsoft dokumentace. Vlastní doporučení hledejte v MS Learn.
- **Vladimir Khorikov** psal v roce 2016 o preferenci NHibernate před EF Core pro DDD — EF Core od té doby výrazně dohnal ztrátu backing fields, `OwnsOne`, `IReadOnlyCollection<T>` podporou.
- `/ef/core/modeling/complex-types` dedikovaná stránka **neexistuje (404)** — kanonický zdroj pro Complex Types je stránka EF8 a EF10 „What's New".
- `/ef/core/modeling/backing-fields` (množné číslo) vrací **404** — správná URL je `/backing-field` (jednotné číslo).

## Viz také

- [`02-tvar-entit-backing-fields.md`](02-tvar-entit-backing-fields.md) — Správné vzory pro entity shape
- [`03-konstruktory-factory-required.md`](03-konstruktory-factory-required.md) — Factory metody místo veřejného konstruktoru
- [`04-navigace-a-kolekce.md`](04-navigace-a-kolekce.md) — Správné vzory pro kolekce
