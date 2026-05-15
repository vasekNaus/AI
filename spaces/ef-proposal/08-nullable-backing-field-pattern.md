# EF Core: Nullable Backing Field Pattern (`?? throw`)

> **Technologické zaměření:** .NET 10 / EF Core 10 / C# 13  
> **Zdroj:** Microsoft Learn (nullable-reference-types), EF Core source (PropertyAccessMode)

---

## Popis patternu

```csharp
private Customer? _customer;

public Customer Customer
{
    set => _customer = value;
    get => _customer
           ?? throw new InvalidOperationException("Uninitialized property: " + nameof(Customer));
}
```

Backing field `_customer` je **nullable** (`Customer?`), zatímco public property `Customer` je **non-nullable** (`Customer`). Getter vyhodí výjimku s popisnou zprávou, pokud navigace nebyla načtena.

---

## Dokumentace Microsoftu — explicitní

**ANO — Microsoft tento pattern explicitně dokumentuje.**

Zdroj: `learn.microsoft.com/en-us/ef/core/miscellaneous/nullable-reference-types`, sekce *„Required navigation properties"*

Microsoftův popis (doslova):
> *„If you'd like a stricter approach, you can have a non-nullable property with a nullable backing field. As long as the navigation is properly loaded, the dependent will be accessible via the property. If, however, the property is accessed without first properly loading the related entity, an `InvalidOperationException` is thrown, since the API contract has been used incorrectly."*

---

## Chování C# NRT analyzátoru

Roslyn NRT flow analyzátor **správně vidí vlastnost jako non-null** na všech call sites:

- Backing field `_customer?` je typován jako `Customer?` (nullable)
- Property `Customer` je typována jako `Customer` (non-nullable)
- Výraz `?? throw` je C# *throw expression* — Roslyn ví, že každá větev, která dosáhne returnu, musí mít nenullový `_customer` (tzv. „null divergence" analýza)
- Na call sites: `order.Customer.Name` — kompilátor **nevydá žádné CS8602 upozornění**
- Setter `set => _customer = value` — přijímá `Customer` (non-nullable), přiřazení `null` je kompilační chyba

---

## Chování EF Core při materializaci

**Pattern funguje správně s výchozím nastavením EF Core.**

Výchozí `PropertyAccessMode.PreferField` (od EF Core 3.0) způsobuje, že EF Core při materializaci entity z DB:

1. Najde backing field konvencí (např. `_customer` pro property `Customer`)
2. **Zapíše přímo do backing field** přes reflection, zcela obchází property getter
3. `?? throw` getter **není nikdy volán** při DB materializaci — volá ho pouze aplikační kód

| PropertyAccessMode | Při materializaci z DB | Riziko s `?? throw` |
|---|---|---|
| `PreferField` **(výchozí)** | Zapisuje do `_customer` přímo | **Pattern funguje správně** |
| `Field` | Zapisuje do `_customer` přímo | **Pattern funguje správně** |
| `FieldDuringConstruction` | Zapisuje do field | **Pattern funguje správně** |
| `Property` | Volá property setter | **Funguje pokud setter není null-guarded** |

---

## Runtime rizika — kdy dojde k neočekávané výjimce

### Riziko 1: Serializace přes `System.Text.Json` nebo Newtonsoft.Json 🔴 VYSOKÉ

`System.Text.Json` serializuje voláním property getterů. Pokud navigace nebyla includována:

```
System.InvalidOperationException: Uninitialized property: Customer
```

**Mitigace:**
- `[JsonIgnore]` na navigační vlastnosti
- Používat DTO/projekce místo serializace entit přímo
- Zajistit include všech navigací před serializací

### Riziko 2: Detached entity 🔴 VYSOKÉ

```csharp
context.Entry(order).State = EntityState.Detached;
var name = order.Customer.Name; // THROWS pokud Customer nebyl načten
```

**Mitigace:** `AsNoTracking()` s explicitním `Include()`, nebo zajistit načtení před detach.

### Riziko 3: Navigation Fixup non-determinismus 🟡 STŘEDNÍ

EF Core change tracker „fixup" naplní navigace, pokud jsou related entity v trackeru. Chování `?? throw` patternu může být nedeterministické:

```csharp
// Customer je v change trackeru z předchozího dotazu:
var orders = context.Orders.ToList(); // Customer IS fixed up → no throw
// vs.
var orders = context.Orders.AsNoTracking().ToList(); // NO fixup → throw on access
```

### Riziko 4: Chybějící ThenInclude v kaskádě 🟡 STŘEDNÍ

```csharp
var orders = await context.Orders
    .Include(o => o.Customer)
    // .ThenInclude(c => c.Address)  ← zapomenuto!
    .ToListAsync();
var city = orders[0].Customer.Address.City; // THROWS: "Uninitialized property: Address"
```

> 💡 Chybová zpráva je výmluvná — přesně identifikuje chybějící článek kaskády.

### Riziko 5: Lazy loading s detached entitami 🔴 VYSOKÉ

Lazy loading interceptor načte navigaci před voláním gettera — ale pouze pokud je entita tracked a loader je dostupný. Pro detached entity interceptor nic nedělá a getter hodí výjimku místo vrácení `null`.

---

## Kompatibilita s Lazy Loading Proxies

- **Vyžaduje `virtual` vlastnost** — Castle DynamicProxy může interceptovat pouze `virtual` metody
- **Funguje pokud entita je tracked a kontext je dostupný** — loader načte navigaci PŘED voláním gettera
- **Selhává pro detached entity** — hodí `InvalidOperationException` místo vrácení `null`
- **Mění detached contract**: `null!` suppressor vrací `null` pro detached navigace (null-check funguje); `?? throw` hodí výjimku (null-check nelze použít)

---

## Srovnání variant pro required navigace

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

---

## Komunita — sentiment

| Skupina | Postoj |
|---|---|
| DDD zastánci | **Silně pozitivní** — „nevystavuj surové null z domény" |
| Architekti service layer | **Pozitivní** — lepší chybová zpráva vs. tichý NRE |
| API/serializační týmy | **Negativní** — způsobuje neočekávaná serializační selhání |
| Lazy loading uživatelé | **Opatrný** — nutné `virtual`, riziko pro detached entity |
| „Simple is better" škola | **Preferuje `null!`** — méně ceremonie, stejný výsledek |

---

## Mitigace rizik

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

## Komunitní terminologie

Pattern nemá formální jméno v Microsoft docs. V komunitních diskusích je označován jako:
- **„Nullable backing field pattern"** (nejčastěji)
- **„Throw-on-access navigation"**
- **„Strict navigation property"**
- **„Guarded navigation"**

V kontextu funkcionálního programování jde o variaci **Maybe monady** (viz GitHub issue #22504).

## Viz také

- [`07-nullable-reference-types.md`](07-nullable-reference-types.md) — NRT obecně, srovnání všech tří filosofií
- [`02-tvar-entit-backing-fields.md`](02-tvar-entit-backing-fields.md) — PropertyAccessMode a backing fields
- [`04-navigace-a-kolekce.md`](04-navigace-a-kolekce.md) — AutoInclude jako mitigace
