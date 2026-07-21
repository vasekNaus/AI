# Originální výzkumná zpráva

> Tento soubor obsahuje kompletní výsledek výzkumu provedeného před vytvořením skills složky.
> Slouží jako zdroj pro případné doplnění nebo přepracování skills souborů.
>
> **Datum výzkumu:** 2026-07-20
> **Referenční projekt:** `Altairis.ReP.Web` (ASP.NET Core 10)
> **Demo projekt:** `Prezentation/03-02_EditorTemplates` (NET 8)

---

# EditorTemplates v ASP.NET Core Razor Pages – Instrukční soubor pro AI agenta

> **Verze:** 1.0 (neoptimaizováno)
> **Zdroj:** Altairis.ReP.Web (ASP.NET Core 10), Demo.DynamicUI (NET 8), Microsoft Learn, ASP.NET Core source

---

## Executive Summary

EditorTemplates jsou mechanismus v ASP.NET Core MVC/Razor Pages, který umožňuje generovat HTML formuláře automaticky na základě **metadat modelu** (datových atributů na DTO/InputModel třídách). Výsledkem je, že celý formulář administrační stránky lze vygenerovat jediným voláním `@Html.EditorFor(m => this.Model.Input)`. Projekt Altairis.ReP implementuje kompletní sadu 29 EditorTemplate souborů v `Pages/EditorTemplates/` a používá `Altairis.ConventionalMetadataProviders` pro automatické display names z centrálního `.resx` souboru.

**Klíčové výhody pro admin stránky:**
- Jeden řádek Razor kódu = celý formulář se správnými input typy, labely, popisky a validací
- Změna DTO automaticky změní formulář – žádná duplicita
- Konzistentní vzhled napříč všemi admin stránkami
- Lokalizace display names a validačních zpráv z jednoho místa

---

## 1. Jak EditorTemplates fungují – přehled

### 1.1 Princip

Když se zavolá `@Html.EditorFor(m => this.Model.Input)` na komplexní objekt (InputModel), engine:
1. Najde odpovídající šablonu (typicky `Object.cshtml`)
2. `Object.cshtml` iteruje přes všechny vlastnosti modelu
3. Pro každou vlastnost zavolá `@Html.Editor(prop.PropertyName)`
4. Engine vybere správnou šablonu pro danou vlastnost (viz sekce 2)
5. Šablona vygeneruje HTML pro daný input control

**Zdroj:** `learn.microsoft.com/en-us/aspnet/core/mvc/views/display-templates`

### 1.2 Tok zpracování

```
@Html.EditorFor(m => this.Model.Input)
    └─► Object.cshtml (komplexní typ → iteruje vlastnosti)
         ├─► Html.Editor("Name")       → String.cshtml → HtmlInput.cshtml → <input type="text">
         ├─► Html.Editor("Email")      → EmailAddress.cshtml → HtmlInput.cshtml → <input type="email">
         ├─► Html.Editor("Price")      → Decimal.cshtml → <input class="textbox">
         ├─► Html.Editor("BirthDate")  → Date.cshtml → <input type="date">
         ├─► Html.Editor("IsActive")   → Boolean.cshtml → <input type="checkbox">
         ├─► Html.Editor("Password")   → Password.cshtml → <input type="password"> + toggle
         ├─► Html.Editor("Notes")      → MultilineText.cshtml → <textarea>
         └─► Html.Editor("Body")       → Markdown.cshtml → <textarea class="markdown">
```

---

## 2. Pořadí výběru šablony (Template Resolution Order)

Engine hledá šablonu v tomto pořadí (první nalezená vyhrává):

```
1. Explicitně zadané jméno šablony v @Html.EditorFor(m => m.Prop, "MojeTemplate")
2. [UIHint("MojeTemplate")]        ← nejvyšší priorita u atributů
3. [DataType("Markdown")]          ← vlastní řetězcové jméno šablony
4. DataType enum název             ← např. DataType.Date → "Date"
5. Jméno CLR typu                  ← "String", "Int32", "Boolean", "DateTime", "Decimal"
6. Pro Enum: "Enum", pak "String"
7. Komplexní typ: jde nahoru hierarchií (BaseClass.Name...)
8. IEnumerable → "Collection"
9. "Object"                        ← finální fallback
```

**Zdroj:** `TemplateRenderer.cs:GetViewNames()` v ASP.NET Core zdroji

---

## 3. Struktura adresářů

### 3.1 Konvenční umístění (dle Microsoft dokumentace)

| Typ aplikace | Umístění EditorTemplates |
|---|---|
| **Razor Pages** | `Pages/Shared/EditorTemplates/` |
| **MVC (sdílené)** | `Views/Shared/EditorTemplates/` |
| **MVC (per-controller)** | `Views/{ControllerName}/EditorTemplates/` |

### 3.2 Umístění v projektu Altairis.ReP

Projekt používá `Pages/EditorTemplates/` – sibling directory vedle admin stránek (ne v `Shared/`). Toto funguje, protože engine hledá i relativně od aktuální stránky.

### 3.3 Kompletní adresářová struktura projektu

```
Altairis.ReP.Web/
├── Pages/
│   ├── _ViewImports.cshtml
│   ├── _ViewStart.cshtml
│   ├── EditorTemplates/             ← VŠECHNY editor templates
│   │   ├── _Layout.cshtml           ← @RenderBody()
│   │   ├── HtmlInput.cshtml         ← sdílená base šablona pro <input>
│   │   ├── Object.cshtml            ← klíčová šablona pro komplexní typy
│   │   ├── Collection.cshtml        ← IEnumerable<T>
│   │   ├── String.cshtml            ← → HtmlInput, type="text"
│   │   ├── Text.cshtml              ← → String.cshtml
│   │   ├── EmailAddress.cshtml      ← → HtmlInput, type="email"
│   │   ├── PhoneNumber.cshtml       ← → HtmlInput, type="tel"
│   │   ├── Url.cshtml               ← → HtmlInput, type="url"
│   │   ├── Color.cshtml             ← → HtmlInput, type="color"
│   │   ├── Upload.cshtml            ← → HtmlInput, type="file"
│   │   ├── Number.cshtml            ← → HtmlInput, type="number"
│   │   ├── Int32.cshtml             ← → Number.cshtml
│   │   ├── Int64.cshtml             ← → Number.cshtml
│   │   ├── UInt32.cshtml            ← → Number.cshtml
│   │   ├── UInt64.cshtml            ← → Number.cshtml
│   │   ├── SByte.cshtml             ← → Number.cshtml
│   │   ├── Byte.cshtml              ← → Number.cshtml
│   │   ├── Single.cshtml            ← → Number.cshtml
│   │   ├── Decimal.cshtml           ← textbox, formát 0.00
│   │   ├── Boolean.cshtml           ← checkbox nebo tri-state dropdown
│   │   ├── Date.cshtml              ← type="date", formát yyyy-MM-dd
│   │   ├── DateTime.cshtml          ← type="datetime-local"
│   │   ├── Time.cshtml              ← type="time", formátuje TimeSpan
│   │   ├── MultilineText.cshtml     ← <textarea>
│   │   ├── Html.cshtml              ← <textarea class="html">
│   │   ├── Markdown.cshtml          ← <textarea> + markdown ikona
│   │   ├── Password.cshtml          ← type="password" + show/hide toggle
│   │   └── HiddenInput.cshtml       ← <input type="hidden"> + optional display
│   ├── Admin/
│   │   ├── Resources/
│   │   │   ├── Create.cshtml
│   │   │   ├── Create.cshtml.cs
│   │   │   ├── Edit.cshtml
│   │   │   └── Edit.cshtml.cs
│   │   └── ...
│   └── Shared/
│       └── _Layout.cshtml
├── Resources/
│   ├── Display.resx
│   ├── Display.Designer.cs
│   ├── Validation.resx
│   └── Validation.Designer.cs
└── Program.cs
```

---

## 4. Datové atributy (DataAnnotations) – kompletní reference

### 4.1 Atributy ovlivňující výběr šablony

| Atribut | Efekt na šablonu | Příklad |
|---|---|---|
| `[UIHint("Template")]` | Přímo specifikuje jméno šablony | `[UIHint("ColorPicker")]` |
| `[DataType(DataType.Password)]` | Použije `Password.cshtml` | — |
| `[DataType(DataType.Date)]` | Použije `Date.cshtml` | — |
| `[DataType(DataType.Time)]` | Použije `Time.cshtml` | — |
| `[DataType(DataType.DateTime)]` | Použije `DateTime.cshtml` | — |
| `[DataType(DataType.MultilineText)]` | Použije `MultilineText.cshtml` | — |
| `[DataType(DataType.EmailAddress)]` | Použije `EmailAddress.cshtml` | — |
| `[DataType(DataType.PhoneNumber)]` | Použije `PhoneNumber.cshtml` | — |
| `[DataType(DataType.Url)]` | Použije `Url.cshtml` | — |
| `[DataType(DataType.Currency)]` | Použije `Currency.cshtml` | — |
| `[DataType(DataType.PostalCode)]` | Použije `PostalCode.cshtml` | — |
| `[DataType(DataType.Upload)]` | Použije `Upload.cshtml` | `<input type="file">` |
| `[DataType(DataType.Html)]` | Použije `Html.cshtml` | — |
| `[DataType("Markdown")]` | Použije `Markdown.cshtml` (vlastní) | — |
| `[HiddenInput]` | Použije `HiddenInput.cshtml` | `<input type="hidden">` + zobrazí hodnotu |
| `[HiddenInput(DisplayValue=false)]` | Pouze `<input type="hidden">` | — |
| `[EmailAddress]` | `EmailAddress.cshtml` | — |
| `[Phone]` | `PhoneNumber.cshtml` | — |
| `[Url]` | `Url.cshtml` | — |

### 4.2 Kompletní výčet DataType enum hodnot

```csharp
public enum DataType {
    Custom = 0,       // vlastní jméno šablony
    DateTime = 1,     // datum a čas
    Date = 2,         // pouze datum
    Time = 3,         // pouze čas
    Duration = 4,     // trvání
    PhoneNumber = 5,  // telefon → type="tel"
    Currency = 6,     // měna
    Text = 7,         // text
    Html = 8,         // HTML editor
    MultilineText = 9,// víceřádkový text → <textarea>
    EmailAddress = 10,// email → type="email"
    Password = 11,    // heslo → type="password"
    Url = 12,         // URL → type="url"
    ImageUrl = 13,    // URL obrázku
    CreditCard = 14,  // číslo kreditní karty
    PostalCode = 15,  // PSČ
    Upload = 16       // nahrání souboru → type="file"
}
```

---

## 5. Klíčové šablony – implementace

### 5.1 Object.cshtml – nejdůležitější šablona

Viz zdrojový soubor v `Altairis.ReP.Web/Pages/EditorTemplates/Object.cshtml`.

Klíčové vlastnosti při iteraci:
- `prop.ShowForEdit` – respektuje `[ScaffoldColumn(false)]`
- `prop.HideSurroundingHtml` – respektuje `[HiddenInput(DisplayValue=false)]`
- `prop.IsComplexType` – detekuje vnořené objekty
- `prop.ModelType.Equals(typeof(bool))` – speciální handling pro checkbox
- `prop.GetDisplayName()` – label text
- `prop.Description` – popis pod polem
- `prop.Order` – pořadí dle `[Display(Order=...)]`

### 5.2 Demo projekt (Prezentation/03-02_EditorTemplates)

Demo projekt demonstruje pokročilé vzory:
- **Groupování** pomocí `[Display(GroupName="...")]` a `<details>/<summary>`
- **Vlastní atributy s parametry**: `SliderAttribute(min, max, step)`, `SelectAttribute(listPropertyName?)`
- **Reflexe v šabloně** pro čtení atributů ze sibling properties
- **Nested models**: `StreetModel.cshtml` – šablona pojmenovaná přímo po CLR typu
- **Typ-specifické šablony**: `Currency.cshtml`, `PostalCode.cshtml`

---

## 6. Altairis.ConventionalMetadataProviders

### 6.1 Registrace

```csharp
// Program.cs
builder.Services.AddRazorPages(options => { ... })
    .AddMvcOptions(options => {
        options.SetConventionalMetadataProviders<Display, Validation>();
    });
```

### 6.2 Konvence vyhledávání klíče

Pro vlastnost `Email` na třídě `MyApp.Pages.Admin.CreateModel`:
```
Hledá klíče (od nejspecifičtějšího):
  MyApp_Pages_Admin_CreateModel_Email
  Pages_Admin_CreateModel_Email
  Admin_CreateModel_Email
  CreateModel_Email
  Email                            ← nejčastěji stačí
```

### 6.3 Dostupná metadata z Display.resx

| Konvence klíče | Metadata |
|---|---|
| `PropertyName` | DisplayName |
| `PropertyName_Description` | Description |
| `PropertyName_Placeholder` | Placeholder |
| `PropertyName_Null` | NullDisplayText |
| `PropertyName_DisplayFormat` | DisplayFormatString |
| `PropertyName_EditFormat` | EditFormatString |

### 6.4 Reálné klíče z Altairis.ReP Display.resx

```
BackgroundColor, ClosingTime, Comment, CurrentPassword, Date,
DateBegin, DateEnd, DayOfWeek, Description, DisplayName, Email, Enabled,
ForegroundColor, IsAdministrator, IsMaster, Language, MaximumReservationTime,
MaximumReservationTime_Description, Name, NewPassword, OpeningHours,
OpeningTime, Password, PhoneNumber, RememberMe, ResourceEnabled, ResourceId,
SendNews, SendNotifications, ShowInMemberDirectory, System, Text, Title,
UserEnabled, UserName, Instructions, Instructions_Description, ...
```

---

## 7. ViewData dostupné v šablonách

```
ViewData.Model                              → aktuální hodnota
ViewData.TemplateInfo.FormattedModelValue   → formátovaná hodnota
ViewData.ModelMetadata.DisplayName          → label text
ViewData.ModelMetadata.Description          → popis pod polem
ViewData.ModelMetadata.Placeholder          → HTML placeholder
ViewData.ModelMetadata.IsRequired           → true když [Required]
ViewData.ModelMetadata.IsNullableValueType  → true pro bool?, int?,...
ViewData.ModelMetadata.HideSurroundingHtml  → true pro [HiddenInput(DisplayValue=false)]
ViewData.ModelMetadata.DataTypeName         → z [DataType(...)]
ViewData.ModelMetadata.ShowForEdit          → false při [ScaffoldColumn(false)]
ViewData.TemplateInfo.HtmlFieldPrefix       → prefix pro HTML name atribut
ViewData.TemplateInfo.TemplateDepth         → hloubka zanořování (1 = top-level)
```

---

## 8. Vzory admin stránek

Všechny admin Create/Edit stránky v Altairis.ReP používají identický vzor:

```cshtml
@* Create.cshtml *@
<form method="post">
    @Html.EditorFor(m => this.Model.Input)
    <footer>
        <div asp-validation-summary="All"></div>
        <input type="submit" value="@UI._Submit" />
        <a asp-page="Index" class="button secondary">@UI._Cancel</a>
    </footer>
</form>
```

Výjimky (přímé Tag Helpers):
- `Admin/OpeningHours.cshtml` – inline checkbox list s custom tag helper
- `Admin/Users/Create.cshtml` – custom layout pro uživatelská práva

---

## 9. Souhrn InputModel atributů z reálných stránek

### Resources/Create.cshtml.cs

```csharp
public class InputModel {
    [Required, MaxLength(50)]
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    [DataType("Markdown")]
    public string? Instructions { get; set; }
    [Required, Range(0, 1440)]
    public int MaximumReservationTime { get; set; }
    [Required, Color]
    public string ForegroundColor { get; set; } = "#000000";
    [Required, Color]
    public string BackgroundColor { get; set; } = "#ffffff";
    public bool ResourceEnabled { get; set; } = true;
}
```

### DirectoryEntries/Create.cshtml.cs

```csharp
public class InputModel {
    [Required, MaxLength(100)]
    public string DisplayName { get; set; } = string.Empty;
    [MaxLength(100), EmailAddress]
    public string? Email { get; set; }
    [MaxLength(50), Phone]
    public string? PhoneNumber { get; set; }
}
```

### OpeningHours.cshtml.cs (InputModel s TimeSpan)

```csharp
public class InputModel {
    [DataType(DataType.Date)]
    public DateTime Date { get; set; } = DateTime.Today.AddDays(1);
    [DataType(DataType.Time), Range(typeof(TimeSpan), "00:00:00", "23:59:59")]
    public TimeSpan OpeningTime { get; set; } = TimeSpan.Zero;
    [DataType(DataType.Time), Range(typeof(TimeSpan), "00:00:00", "23:59:59"), GreaterThan(nameof(OpeningTime), AllowEqual = true)]
    public TimeSpan ClosingTime { get; set; } = TimeSpan.Zero;
}
```

---

## 10. Prezentation demo – vlastní atributy

### MarkdownAttribute.cs

```csharp
public class MarkdownAttribute() : DataTypeAttribute("Markdown") { }
```

### SelectAttribute.cs

```csharp
public class SelectAttribute(string? listPropertyName = null) : DataTypeAttribute("Select") {
    public string? ListPropertyName { get; } = listPropertyName;
}
```

Šablona Select.cshtml čte list property přes reflexi ze sibling property `{PropertyName}List`.

### SliderAttribute.cs

```csharp
public class SliderAttribute(int min, int max, int step = 1) : DataTypeAttribute("Slider") {
    public int Min { get; } = min;
    public int Max { get; } = max;
    public int Step { get; } = step;
    public string ExtraFieldSuffix { get; set; } = "Extra";
}
```

Šablona Slider.cshtml renderuje `<input type="number">` + `<input type="range">` synchronizované přes JS.

---

## 11. CSS vzory

### Základní struktura (z Demo.DynamicUI/Site.css)

```css
div.editor-label { margin-top: 1em; margin-bottom: .5ex; }
div.editor-label::after { content: ":"; }
div.editor-field-checkbox { margin-top: 1em; }
div.editor-complex-field { border: 1px solid #090; border-radius: 5px; padding: 0 1em 1em 1em; }

details { border: 1px solid #090; border-radius: 5px; padding: 1em; margin-top: 1em; }
details summary { cursor: pointer; color: #090; }

.input-validation-error { border: 1px solid #c00; }
span.field-validation-error { display: block; margin-top: .5ex; color: #c00; }
div.validation-summary-valid { display: none; }
div.validation-summary-errors { color: #c00; }

/* Inline pole (dvě vedle sebe) */
input.hasextra { width: calc(100% - 4em); }
input.isextra { float: right; width: 3em; }

/* Kratší pole */
input[type=date], input[type=number], input.short { max-width: 10em; }

/* Markdown textarea */
textarea.markdown {
    font-family: monospace;
    background-image: url("data:image/svg+xml,..."); /* M↓ ikona */
    background-position: right top;
    background-repeat: no-repeat;
    background-size: 25px;
}
```

---

## 12. Gotchas

| Problém | Řešení |
|---|---|
| Šablona zdědila layout stránky | Přidat `this.Layout = "_Layout.cshtml"` nebo `string.Empty` |
| Šablona se nenachází | Ověřit jméno souboru, složku, case-sensitivity |
| `[ScaffoldColumn(false)]` vs `[HiddenInput]` | ScaffoldColumn = vynechání, HiddenInput = skrytý input |
| `Html.Editor` vs `Html.EditorFor` v Object.cshtml | Vždy `Html.Editor("PropertyName")` uvnitř Object.cshtml |
| TimeSpan bez šablony | Vytvořit `Time.cshtml` s expliclitním castem na TimeSpan |
| Boolean s labelem nad checkboxem | Testovat `prop.ModelType.Equals(typeof(bool))` před obecnou větví |
| Template depth > 1 renderuje text | Vlastní Object.cshtml s `TemplateDepth` kontrolou |
| Validace po AJAX | Volat `$.validator.unobtrusive.parse(form)` po vložení formuláře |

---

## 13. Zdroje

| Zdroj | URL / Cesta |
|---|---|
| Microsoft Learn – EditorTemplates | `learn.microsoft.com/en-us/aspnet/core/mvc/views/display-templates` |
| Microsoft Learn – DataAnnotations | `learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations` |
| Microsoft Learn – Working with Forms | `learn.microsoft.com/en-us/aspnet/core/mvc/views/working-with-forms` |
| Microsoft Learn – Model Validation | `learn.microsoft.com/en-us/aspnet/core/mvc/models/validation` |
| Altairis.ConventionalMetadataProviders | `github.com/ridercz/Altairis.ConventionalMetadataProviders` |
| ASP.NET Core TemplateRenderer.cs | `github.com/dotnet/aspnetcore:src/Mvc/Mvc.ViewFeatures/src/TemplateRenderer.cs` |
| ASP.NET Core DefaultEditorTemplates.cs | `github.com/dotnet/aspnetcore:src/Mvc/Mvc.ViewFeatures/src/DefaultEditorTemplates.cs` |
| Referenční projekt | `github.com/vasekNaus/ReP` |
| Demo projekt | `Altairis.ReP/Prezentation/03-02_EditorTemplates/` |
