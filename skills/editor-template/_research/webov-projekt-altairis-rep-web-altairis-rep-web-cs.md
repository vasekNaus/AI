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

Pro každý kandidát engine hledá soubor `EditorTemplates/{jméno}.cshtml`:
1. Nejprve v adresáři aktuální stránky (relativní cesta)
2. Pak `Pages/Shared/EditorTemplates/`
3. Pak `Views/Shared/EditorTemplates/` (MVC)
4. Nakonec vestavěná C# implementace (`DefaultEditorTemplates.cs`)

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

### 3.3 Doporučená struktura projektu

```
MyApp/
├── Pages/
│   ├── _ViewImports.cshtml          ← globální using + tag helpers
│   ├── _ViewStart.cshtml            ← Layout = "_Layout"
│   ├── Shared/
│   │   ├── _Layout.cshtml           ← hlavní layout stránky
│   │   └── _ValidationScriptsPartial.cshtml  ← jquery.validate.unobtrusive
│   ├── EditorTemplates/             ← vlastní EditorTemplates
│   │   ├── _Layout.cshtml           ← minimální: @RenderBody() 
│   │   ├── HtmlInput.cshtml         ← sdílená base šablona pro <input>
│   │   ├── Object.cshtml            ← klíčová šablona pro komplexní typy
│   │   ├── String.cshtml
│   │   ├── Boolean.cshtml
│   │   ├── Date.cshtml
│   │   ├── DateTime.cshtml
│   │   ├── Time.cshtml
│   │   ├── Decimal.cshtml
│   │   ├── EmailAddress.cshtml
│   │   ├── Password.cshtml
│   │   ├── MultilineText.cshtml
│   │   ├── Markdown.cshtml          ← vlastní šablona pro Markdown
│   │   └── ...
│   └── Admin/
│       ├── Items/
│       │   ├── Create.cshtml        ← @Html.EditorFor(m => this.Model.Input)
│       │   ├── Create.cshtml.cs     ← InputModel s datovými atributy
│       │   ├── Edit.cshtml
│       │   └── Edit.cshtml.cs
│       └── Index.cshtml
├── Attributes/
│   └── MarkdownAttribute.cs         ← vlastní DataTypeAttribute
└── Resources/
    ├── Display.resx                 ← display names, descriptions, placeholders
    └── Validation.resx              ← validační zprávy
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
| `[HiddenInput(DisplayValue=false)]` | Pouze `<input type="hidden">`, skryje zobrazení | — |
| `[EmailAddress]` | Tag helper: `type="email"`; EditorFor: `EmailAddress.cshtml` | — |
| `[Phone]` | Tag helper: `type="tel"`; EditorFor: `PhoneNumber.cshtml` | — |
| `[Url]` | Tag helper: `type="url"`; EditorFor: `Url.cshtml` | — |

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

**Zdroj:** `learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations.datatype`

### 4.3 Atributy ovlivňující metadata (label, description, pořadí)

| Atribut | Vlastnost | Efekt v šabloně |
|---|---|---|
| `[Display(Name="Popis pole")]` | `ModelMetadata.DisplayName` | Text labelu |
| `[Display(Description="Nápověda")]` | `ModelMetadata.Description` | Popis pod polem |
| `[Display(Prompt="Placeholder text")]` | `ModelMetadata.Placeholder` | HTML placeholder |
| `[Display(Order=1)]` | Pořadí v Object.cshtml | Řadí vlastnosti |
| `[Display(GroupName="Skupina")]` | Seskupení v Object.cshtml | Collapsible group (`<details>`) |
| `[Display(AutoGenerateField=false)]` | `ShowForEdit = false` | Skryje z Object template |
| `[ScaffoldColumn(false)]` | `ShowForEdit = false` | Kompletně vynechá z iterace |

### 4.4 Atributy pro formátování hodnot

```csharp
[DisplayFormat(DataFormatString = "{0:d}", ApplyFormatInEditMode = true)]
public DateTime ReleaseDate { get; set; }

[DisplayFormat(NullDisplayText = "[N/A]", ConvertEmptyStringToNull = true)]
public string? Size { get; set; }
```

- `DataFormatString` → `ViewData.TemplateInfo.FormattedModelValue`
- `ApplyFormatInEditMode = true` → formát se použije i v edit šabloně

### 4.5 Validační atributy (generují `data-val-*` pro jQuery Validation)

```csharp
[Required]
[MaxLength(50)]
[MinLength(3)]
[StringLength(100, MinimumLength = 3)]
[Range(0, 1440)]
[EmailAddress]
[Phone]
[Url]
[RegularExpression(@"^\d{5}$", ErrorMessage = "Neplatné PSČ")]
[Compare("OtherProperty")]
[CreditCard]
[FileExtensions(Extensions = "jpg,png")]
```

**CLR typy bez [Required] – automatické chování (s Nullable enable):**
- `string` bez `?` → implicitní `[Required]`
- `int`, `DateTime` → implicitní `[Required]` (hodnoty nejsou nullable)
- Chcete-li potlačit: `options.SuppressImplicitRequiredAttributeForNonNullableReferenceTypes = true`

---

## 5. Klíčové šablony – implementace

### 5.1 Object.cshtml – nejdůležitější šablona

Tato šablona se používá pro komplexní typy (InputModel). Je to srdce celého systému.

#### Varianta A: Jednoduchá (z projektu Altairis.ReP)

```cshtml
@{
    this.Layout = "_Layout.cshtml";

    foreach (var prop in ViewData.ModelMetadata.Properties.Where(metadata => metadata.ShowForEdit)) {
        if (prop.IsComplexType) {
            <fieldset>
                <legend>@prop.GetDisplayName()</legend>
                @if (!string.IsNullOrWhiteSpace(prop.Description)) {
                    <p class="description">@prop.Description</p>
                }
                @Html.Editor(prop.PropertyName)
            </fieldset>
        } else if (prop.HideSurroundingHtml) {
            @* Hidden inputs: bez wrapperu *@
            @Html.Editor(prop.PropertyName)
        } else if (prop.ModelType.Equals(typeof(bool))) {
            <p>
                @Html.Editor(prop.PropertyName)
                @Html.Label(prop.PropertyName)
                @if (!string.IsNullOrWhiteSpace(prop.Description)) {
                    <span class="description">@prop.Description</span>
                }
                @Html.ValidationMessage(prop.PropertyName)
            </p>
        } else {
            <p>
                @Html.Label(prop.PropertyName, prop.GetDisplayName() + ":")<br />
                @if (!string.IsNullOrWhiteSpace(prop.Description)) {
                    <span class="description">@prop.Description</span>
                }
                @Html.Editor(prop.PropertyName)
                @Html.ValidationMessage(prop.PropertyName)
            </p>
        }
    }
}
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/Object.cshtml`

#### Varianta B: S groupováním podle [Display(GroupName)] (z Demo.DynamicUI)

```cshtml
@using Microsoft.AspNetCore.Mvc.ModelBinding
@using System.ComponentModel.DataAnnotations
@{
    this.Layout = string.Empty;

    // Top-level vs nested complex type
    if (ViewData.TemplateInfo.TemplateDepth == 1) {
        RenderGroupedProperties(ViewData.ModelMetadata.Properties);
    } else {
        <div class="editor-complex-field">
            @{ RenderGroupedProperties(ViewData.ModelMetadata.Properties); }
        </div>
    }

    void RenderGroupedProperties(ModelPropertyCollection properties) {
        var groupedProperties =
            from mp in properties
            where mp.ShowForEdit
            orderby mp.Order
            let p = mp.ContainerType?.GetProperty(mp.PropertyName ?? string.Empty)
            let a = p?.GetCustomAttributes(true).OfType<DisplayAttribute>().FirstOrDefault()
            group p by a?.GroupName into g
            select new { Name = g.Key, PropertyNames = g.Select(x => x?.Name) };

        foreach (var group in groupedProperties) {
            var propsInGroup = properties.Where(p => group.PropertyNames.Contains(p.PropertyName));
            if (string.IsNullOrEmpty(group.Name)) {
                RenderProperties(propsInGroup);
            } else {
                <details>
                    <summary>@group.Name</summary>
                    @{ RenderProperties(propsInGroup); }
                </details>
            }
        }
    }

    void RenderProperties(IEnumerable<ModelMetadata> properties) {
        foreach (var prop in properties.Where(p => p.ShowForEdit).OrderBy(p => p.Order)) {
            if (prop.IsComplexType) {
                <div class="editor-label">@Html.Label(prop.PropertyName)</div>
                @Html.Editor(prop.PropertyName)
            } else if (prop.HideSurroundingHtml) {
                @Html.Editor(prop.PropertyName)
            } else if (prop.ModelType.Equals(typeof(bool))) {
                <div class="editor-field-checkbox">
                    @Html.Editor(prop.PropertyName) @Html.Label(prop.PropertyName)
                    @Html.ValidationMessage(prop.PropertyName)
                </div>
            } else {
                <div class="editor-label">@Html.Label(prop.PropertyName)</div>
                <div class="editor-field">
                    @Html.Editor(prop.PropertyName)
                    @Html.ValidationMessage(prop.PropertyName)
                </div>
            }
        }
    }
}
```

**Zdroj:** `Prezentation/03-02_EditorTemplates/Pages/EditorTemplates/Object.cshtml`

**Klíčové vlastnosti Object.cshtml:**
- `prop.ShowForEdit` – respektuje `[ScaffoldColumn(false)]` a `[Display(AutoGenerateField=false)]`
- `prop.HideSurroundingHtml` – respektuje `[HiddenInput(DisplayValue=false)]`
- `prop.IsComplexType` – detekuje vnořené objekty (rekurzivní volání)
- `prop.Order` – řazení vlastností dle `[Display(Order=N)]`
- `prop.Description` – zobrazí nápovědu dle `[Display(Description="...")]`
- `Html.Editor(prop.PropertyName)` – rekurzivní volání pro vlastnost

### 5.2 HtmlInput.cshtml – sdílená base šablona

Centrální šablona pro všechny `<input>` elementy. Ostatní šablony nastavují `ViewData["type"]` a delegují sem.

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    var htmlAttributes = new {
        @class = string.Join(" ", "textbox", ViewData["additionalCssClass"]),
        type = ViewData["type"],
        placeholder = ViewData.ModelMetadata.Placeholder,
    };
    @Html.TextBox("", ViewData.TemplateInfo.FormattedModelValue, htmlAttributes)
}
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/HtmlInput.cshtml`

### 5.3 Jednoduché šablony delegující na HtmlInput

```cshtml
@* String.cshtml *@
@{ ViewData["type"] = "text"; }
<partial name="HtmlInput.cshtml" />

@* EmailAddress.cshtml *@
@{ ViewData["type"] = "email"; }
<partial name="HtmlInput.cshtml" />

@* PhoneNumber.cshtml *@
@{ ViewData["type"] = "tel"; }
<partial name="HtmlInput.cshtml" />

@* Url.cshtml *@
@{ ViewData["type"] = "url"; }
<partial name="HtmlInput.cshtml" />

@* Color.cshtml *@
@{ ViewData["type"] = "color"; }
<partial name="HtmlInput.cshtml" />

@* Upload.cshtml *@
@{ ViewData["type"] = "file"; }
<partial name="HtmlInput.cshtml" />

@* Number.cshtml *@
@{ ViewData["type"] = "number"; }
<partial name="HtmlInput.cshtml" />

@* Int32.cshtml, Int64.cshtml, Byte.cshtml, ... *@
<partial name="Number.cshtml" />

@* Text.cshtml *@
<partial name="String.cshtml" />
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/`

### 5.4 Date.cshtml – datum

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    var value = string.Empty;
    if (ViewData.Model != null) {
        var dtVal = (DateTime)ViewData.Model;
        if (dtVal > DateTime.MinValue) { value = dtVal.ToString("yyyy-MM-dd"); }
    }
    var htmlAttributes = new {
        type = "date",
        @class = "textbox",
        placeholder = ViewData.ModelMetadata.Placeholder
    };
}
@Html.TextBox("", value, htmlAttributes)
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/Date.cshtml`

### 5.5 DateTime.cshtml – datum a čas

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    var value = string.Empty;
    if (ViewData.Model != null) {
        var dtVal = (DateTime)ViewData.Model;
        if (dtVal > DateTime.MinValue) { value = dtVal.ToString("yyyy-MM-ddTHH:mm:ss"); }
    }
    var htmlAttributes = new { type = "datetime-local", @class = "textbox" };
}
@Html.TextBox("", value, htmlAttributes)
```

### 5.6 Time.cshtml – čas (TimeSpan)

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    var value = string.Empty;
    if (ViewData.Model != null) {
        var tsVal = (TimeSpan)ViewData.Model;
        value = tsVal.ToString(@"hh\:mm");
    }
    var htmlAttributes = new { type = "time", @class = "textbox" };
}
@Html.TextBox("", value, htmlAttributes)
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/Time.cshtml`

### 5.7 Boolean.cshtml – zaškrtávací políčko nebo tri-state

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    bool? value = null;
    if (ViewData.Model != null) {
        value = Convert.ToBoolean(ViewData.Model, System.Globalization.CultureInfo.InvariantCulture);
    }

    if (ViewData.ModelMetadata.IsNullableValueType) {
        // bool? → tri-state dropdown
        var triStateValues = new List<SelectListItem> {
            new SelectListItem { Text = "Nenastaveno", Value = string.Empty, Selected = !value.HasValue },
            new SelectListItem { Text = "Ano", Value = "true", Selected = value.HasValue && value.Value },
            new SelectListItem { Text = "Ne", Value = "false", Selected = value.HasValue && !value.Value },
        };
        @Html.DropDownList("", triStateValues)
    } else {
        // bool → checkbox
        @Html.CheckBox("", value ?? false)
    }
}
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/Boolean.cshtml`

### 5.8 MultilineText.cshtml – víceřádkový text

```cshtml
@{
    this.Layout = "_Layout.cshtml";
}
@Html.TextArea("", ViewData.TemplateInfo.FormattedModelValue.ToString())
```

### 5.9 Password.cshtml – heslo se show/hide tlačítkem

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    var passwordId = Html.GenerateIdFromName(ViewData.TemplateInfo.GetFullHtmlFieldName(string.Empty));
    var checkboxId = "Hide_" + passwordId;
    var jsCode = $"document.getElementById('{passwordId}').type = this.checked ? 'password' : 'text';";
}
@Html.Password("", ViewData.TemplateInfo.FormattedModelValue, new { style = "margin-bottom: 1em" })<br />
<input id="@checkboxId" type="checkbox" onclick="@jsCode" checked="checked" />
<label for="@checkboxId">Skrýt heslo při psaní</label>
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/Password.cshtml`

### 5.10 Decimal.cshtml – desetinné číslo

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    object formattedValue;
    if (ViewData.TemplateInfo.FormattedModelValue == Model) {
        formattedValue = string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0:0.00}", Model);
    } else {
        formattedValue = ViewData.TemplateInfo.FormattedModelValue;
    }
}
@Html.TextBox("", formattedValue, new { @class = "textbox" })
```

### 5.11 HiddenInput.cshtml – skryté pole

```cshtml
@{
    this.Layout = "_Layout.cshtml";
    object? modelValue;
    if (ViewData.Model is byte[] byteArray) {
        modelValue = Convert.ToBase64String(byteArray);
    } else {
        modelValue = ViewData.TemplateInfo.FormattedModelValue;
    }
}
@if (!Html.ViewContext.ViewData.ModelMetadata.HideSurroundingHtml) {
    <text>@ViewData.TemplateInfo.FormattedModelValue</text>
}
@Html.Hidden("", modelValue)
```

### 5.12 Markdown.cshtml – Markdown editor

```cshtml
@{
    this.Layout = "_Layout.cshtml";
}
<span class="control-icons"><i class="fa-brands fa-markdown" title="Markdown"></i></span>
@Html.TextArea("", ViewData.TemplateInfo.FormattedModelValue.ToString())
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/Markdown.cshtml`

### 5.13 Collection.cshtml – kolekce

```cshtml
@{
    this.Layout = "_Layout.cshtml";

    var originalPrefix = ViewData.TemplateInfo.HtmlFieldPrefix;
    if (Model is IEnumerable items) {
        int index = 0;
        foreach (var item in items) {
            ViewData.TemplateInfo.HtmlFieldPrefix = $"{originalPrefix}[{index}]";
            @Html.EditorFor(_ => item)
            index++;
        }
        ViewData.TemplateInfo.HtmlFieldPrefix = originalPrefix;
    }
}
```

### 5.14 _Layout.cshtml uvnitř EditorTemplates – minimální layout

```cshtml
@RenderBody()
```

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/_Layout.cshtml`

Šablony nastavují `this.Layout = "_Layout.cshtml"` (nebo `this.Layout = string.Empty;` v Demo.DynamicUI). Důvod: bez explicitního nastavení by šablona dědila layout stránky a generovala by HTML stránku uvnitř formulářového pole.

---

## 6. Vlastní DataType atributy

### 6.1 Jak vytvořit vlastní DataType atribut

Pro vlastní šablonu `Markdown.cshtml` stačí:

```csharp
using System.ComponentModel.DataAnnotations;

namespace MyApp.Attributes;

// Vlastní atribut → routes to EditorTemplates/Markdown.cshtml
public class MarkdownAttribute() : DataTypeAttribute("Markdown") { }
```

Použití na DTO:
```csharp
[Markdown]
public string Notes { get; set; } = string.Empty;
```

**Zdroj:** `Prezentation/03-02_EditorTemplates/Attributes/MarkdownAttribute.cs`

### 6.2 Atribut s parametry (příklad Slider)

```csharp
public class SliderAttribute(int min, int max, int step = 1) : DataTypeAttribute("Slider") {
    public int Min { get; } = min;
    public int Max { get; } = max;
    public int Step { get; } = step;
    public string ExtraFieldSuffix { get; set; } = "Extra";
}
```

Použití v šabloně – čtení parametrů přes reflexi:

```cshtml
@using MyApp.Attributes
@{
    this.Layout = string.Empty;

    T? getPropertyAttribute<T>() where T : Attribute {
        var propertyName = this.ViewData.ModelExplorer.Metadata.PropertyName;
        if (propertyName == null) return null;
        var propertyInfo = this.ViewData.ModelExplorer.Container.Model
            .GetType().GetProperty(propertyName);
        return propertyInfo?.GetCustomAttributes(typeof(T), false).FirstOrDefault() as T;
    }

    var sliderAttr = getPropertyAttribute<SliderAttribute>();
    var numberAttrs = new {
        type = "number",
        min = sliderAttr?.Min, max = sliderAttr?.Max, step = sliderAttr?.Step,
        oninput = "this.nextElementSibling.value = this.value",
        @class = "isextra"
    };
    var rangeAttrs = new {
        type = "range",
        min = sliderAttr?.Min, max = sliderAttr?.Max, step = sliderAttr?.Step,
        oninput = "this.previousElementSibling.value = this.value",
        @class = "hasextra"
    };
}
@Html.TextBox("Extra", ViewData.TemplateInfo.FormattedModelValue, numberAttrs)
@Html.TextBox("", ViewData.TemplateInfo.FormattedModelValue, rangeAttrs)
```

**Zdroj:** `Prezentation/03-02_EditorTemplates/Attributes/SliderAttribute.cs`, `Pages/EditorTemplates/Slider.cshtml`

### 6.3 Atribut pro výběr ze seznamu (Select)

```csharp
// Konvence: data pro dropdown jsou ve vlastnosti "{PropertyName}List" na stejném modelu
public class SelectAttribute(string? listPropertyName = null) : DataTypeAttribute("Select") {
    public string? ListPropertyName { get; } = listPropertyName;
}
```

Šablona Select.cshtml (čte seznam přes reflexi ze sibling property):

```cshtml
@using MyApp.Attributes
@{
    this.Layout = string.Empty;

    T? getPropertyAttribute<T>() where T : Attribute {
        var propertyName = this.ViewData.ModelExplorer.Metadata.PropertyName;
        if (propertyName == null) return null;
        var propertyInfo = this.ViewData.ModelExplorer.Container.Model.GetType().GetProperty(propertyName);
        return propertyInfo?.GetCustomAttributes(typeof(T), false).FirstOrDefault() as T;
    }

    var listItems = new List<SelectListItem>();
    var model = ViewData.ModelExplorer.Container.Model;
    if (model != null) {
        var listPropertyName = getPropertyAttribute<SelectAttribute>()?.ListPropertyName
            ?? $"{this.ViewData.ModelExplorer.Metadata.Name}List";
        var listPropertyInfo = model.GetType().GetProperty(listPropertyName);
        if (listPropertyInfo != null) {
            var result = listPropertyInfo.GetValue(model) as IEnumerable<SelectListItem>;
            if (result != null) listItems.AddRange(result);
        }
    }
}
@Html.DropDownList(string.Empty, listItems)
```

**Zdroj:** `Prezentation/03-02_EditorTemplates/Attributes/SelectAttribute.cs`, `Pages/EditorTemplates/Select.cshtml`

### 6.4 Šablona pojmenovaná podle typu (model-typed template)

Pro komplexní vlastní typ lze vytvořit šablonu pojmenovanou přímo po CLR typu:

```cshtml
@* StreetModel.cshtml – automaticky použita pro vlastnosti typu StreetModel *@
@model MyApp.Models.StreetModel
@{
    this.Layout = string.Empty;
}
<input asp-for="@Model.StreetName" class="hasextra" />
<input asp-for="@Model.StreetNumber" class="isextra" />
<span asp-validation-for="@Model.StreetName"></span>
<span asp-validation-for="@Model.StreetNumber"></span>
```

**Zdroj:** `Prezentation/03-02_EditorTemplates/Pages/EditorTemplates/StreetModel.cshtml`

---

## 7. ViewData v šablonách – dostupné hodnoty

### 7.1 Vestavěné ViewData klíče dostupné v každé šabloně

```cshtml
@* Hodnota vlastnosti *@
ViewData.Model                              → aktuální hodnota (object)
ViewData.TemplateInfo.FormattedModelValue   → formátovaná hodnota (respektuje [DisplayFormat])

@* Metadata vlastnosti *@
ViewData.ModelMetadata.DisplayName          → z [Display(Name=...)] nebo konvence
ViewData.ModelMetadata.Description          → z [Display(Description=...)] nebo konvence
ViewData.ModelMetadata.Placeholder          → z [Display(Prompt=...)] nebo konvence
ViewData.ModelMetadata.IsRequired           → true když [Required]
ViewData.ModelMetadata.IsNullableValueType  → true pro bool?, int?, ...
ViewData.ModelMetadata.HideSurroundingHtml  → true pro [HiddenInput(DisplayValue=false)]
ViewData.ModelMetadata.DataTypeName         → z [DataType(...)]
ViewData.ModelMetadata.PropertyName         → jméno vlastnosti
ViewData.ModelMetadata.ModelType            → CLR typ

@* Kontext formuláře *@
ViewData.TemplateInfo.HtmlFieldPrefix       → prefix pro HTML name atribut
ViewData.TemplateInfo.GetFullHtmlFieldName(string.Empty) → plné jméno pole
ViewData.TemplateInfo.TemplateDepth         → hloubka zanořování (1 = top-level)
Html.GenerateIdFromName(fieldName)          → generuje id z name
```

### 7.2 Předávání vlastních dat do šablony

**Metoda 1: additionalViewData parametr při volání EditorFor**

```cshtml
@* Volání z Razor stránky *@
@Html.EditorFor(model => model.Notes, additionalViewData: new {
    additionalCssClass = "wide-textarea",
    rows = 10
})
```

```cshtml
@* Šablona: přístup k vlastním datům *@
@{
    var cssClass = ViewData["additionalCssClass"] as string ?? string.Empty;
    var rows = (int?)ViewData["rows"] ?? 5;
}
```

**Metoda 2: Nastavení ViewData uvnitř šablony před delegací**

```cshtml
@* Color.cshtml → nastaví type a deleguje na HtmlInput *@
@{
    ViewData["type"] = "color";
    ViewData["additionalCssClass"] = "color-picker";
}
<partial name="HtmlInput.cshtml" />
```

**Zdroj:** `learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.mvc.rendering.htmlhelpereditorextensions.editorfor`

---

## 8. Altairis.ConventionalMetadataProviders

### 8.1 Co to je a proč to použít

Místo psaní `[Display(Name = nameof(Display.Email), ResourceType = typeof(Display))]` na každou vlastnost, tato knihovna **automaticky mapuje display names a validační zprávy** z centrálního `.resx` souboru dle konvence.

**NuGet:** `Altairis.ConventionalMetadataProviders`  
**GitHub:** `github.com/ridercz/Altairis.ConventionalMetadataProviders`

### 8.2 Registrace

```csharp
// Program.cs
builder.Services.AddRazorPages(options => {
    // ... authorization conventions ...
}).AddMvcOptions(options => {
    options.SetConventionalMetadataProviders<Display, Validation>();
    // nebo s vlastním binding resource:
    // options.SetConventionalMetadataProviders<Display, Validation, Binding>();
});
```

- `Display` = generovaná třída z `Display.resx`
- `Validation` = generovaná třída z `Validation.resx`

**Zdroj:** `Altairis.ReP.Web/Program.cs`

### 8.3 Struktura Display.resx

```xml
<!-- Display.resx -->
<!-- Základní display name: klíč = jméno vlastnosti -->
<data name="Email"><value>E-mail</value></data>
<data name="Password"><value>Heslo</value></data>
<data name="Name"><value>Název</value></data>

<!-- Popis pod polem: klíč = {Vlastnost}_Description -->
<data name="MaximumReservationTime"><value>Maximální čas rezervace</value></data>
<data name="MaximumReservationTime_Description"><value>v minutách, 0 = neomezeno</value></data>

<!-- Placeholder: klíč = {Vlastnost}_Placeholder -->
<data name="Email_Placeholder"><value>vas@email.cz</value></data>

<!-- Null text: klíč = {Vlastnost}_Null -->
<data name="Note_Null"><value>(bez poznámky)</value></data>
```

### 8.4 Struktura Validation.resx

```xml
<!-- Validation.resx -->
<!-- Klíč = jméno atributu (bez "Attribute" suffixu) -->
<data name="Required"><value>Pole {0} je povinné.</value></data>
<data name="MaxLength"><value>Pole {0} může mít maximálně {1} znaků.</value></data>
<data name="Range"><value>Pole {0} musí být v rozsahu od {1} do {2}.</value></data>
<data name="EmailAddress"><value>Pole {0} musí obsahovat platnou e-mailovou adresu.</value></data>

<!-- Pro vlastní validační atribut [GreaterThanAttribute]: klíč = GreaterThan -->
<data name="GreaterThan"><value>Pole {0} musí být větší než {1}.</value></data>
```

### 8.5 Konvence vyhledávání klíčů

Pro vlastnost `Email` na třídě `MyApp.Pages.Admin.CreateModel`:
```
Hledá klíče v pořadí (od nejspecifičtějšího):
  MyApp_Pages_Admin_CreateModel_Email
  Pages_Admin_CreateModel_Email
  Admin_CreateModel_Email
  CreateModel_Email
  Email                            ← nejčastěji toto stačí
```

Díky tomu klíč `Email` v `Display.resx` pokryje **všechny vlastnosti nazvané `Email`** v celé aplikaci.

**Zdroj:** `ridercz/Altairis.ConventionalMetadataProviders:ResourceManagerExtensions.cs`

### 8.6 Automatické [Required] pro hodnotové typy

`ConventionalValidationMetadataProvider` automaticky přidává `[Required]` na non-nullable value typy (`int`, `DateTime`, `bool`, `TimeSpan` atd.). Není tedy potřeba explicitně psát `[Required]` na tyto vlastnosti.

---

## 9. Vzory pro admin stránky – podle projektu Altairis.ReP

### 9.1 Minimální vzor pro Create stránku

**`Pages/Admin/Items/Create.cshtml`**
```cshtml
@page
@model MyApp.Pages.Admin.Items.CreateModel
@{ this.ViewBag.Title = "Vytvořit položku"; }

<form method="post">
    @Html.EditorFor(m => this.Model.Input)
    <footer>
        <div asp-validation-summary="All"></div>
        <input type="submit" value="Uložit" />
        <a asp-page="Index" class="button secondary">Zrušit</a>
    </footer>
</form>
```

**`Pages/Admin/Items/Create.cshtml.cs`**
```csharp
public class CreateModel : PageModel {
    private readonly IItemService _service;

    [BindProperty]
    public InputModel Input { get; set; } = new();

    public class InputModel {
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        [DataType("Markdown")]
        public string? Description { get; set; }

        [Required]
        [DataType(DataType.Date)]
        public DateTime ValidFrom { get; set; } = DateTime.Today;

        public bool IsActive { get; set; } = true;
    }

    public CreateModel(IItemService service) {
        _service = service;
    }

    public async Task<IActionResult> OnPostAsync() {
        if (!this.ModelState.IsValid) return this.Page();
        
        await _service.CreateAsync(new Item {
            Name = Input.Name,
            Description = Input.Description,
            ValidFrom = Input.ValidFrom,
            IsActive = Input.IsActive
        });
        
        return this.RedirectToPage("Index");
    }
}
```

**Zdroj:** `Altairis.ReP.Web/Pages/Admin/Resources/Create.cshtml`, `.cshtml.cs`

### 9.2 Edit stránka (s Delete tlačítkem)

**`Pages/Admin/Items/Edit.cshtml`**
```cshtml
@page "{id:int}"
@model MyApp.Pages.Admin.Items.EditModel
@{ this.ViewBag.Title = "Upravit položku"; }

<form method="post">
    <input type="hidden" asp-for="Input.Id" />
    @Html.EditorFor(m => this.Model.Input)
    <footer>
        <div asp-validation-summary="All"></div>
        <input type="submit" value="Uložit" />
        <a asp-page="Index" class="button secondary">Zrušit</a>
        <input type="submit" asp-page-handler="Delete" class="button danger" 
               value="Smazat"
               data-confirm-message="Opravdu smazat tuto položku?" />
    </footer>
</form>
```

**`Pages/Admin/Items/Edit.cshtml.cs`**
```csharp
public class EditModel : PageModel {
    [BindProperty]
    public InputModel Input { get; set; } = new();

    public class InputModel {
        [HiddenInput(DisplayValue = false)]
        public int Id { get; set; }

        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        // ...další vlastnosti...
    }

    public async Task<IActionResult> OnGetAsync(int id) {
        var item = await _service.GetByIdAsync(id);
        if (item == null) return this.NotFound();
        
        Input = new InputModel {
            Id = item.Id,
            Name = item.Name,
            // ...mapování...
        };
        return this.Page();
    }

    public async Task<IActionResult> OnPostAsync() {
        if (!this.ModelState.IsValid) return this.Page();
        await _service.UpdateAsync(/* ... */);
        return this.RedirectToPage("Index");
    }

    public async Task<IActionResult> OnPostDeleteAsync() {
        await _service.DeleteAsync(Input.Id);
        return this.RedirectToPage("Index");
    }
}
```

### 9.3 InputModel se všemi typy polí (reference)

```csharp
public class InputModel {
    // Textové pole (type="text")
    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    // Nepovinný text
    public string? Description { get; set; }

    // Email (type="email")
    [EmailAddress, MaxLength(200)]
    public string? Email { get; set; }

    // Telefon (type="tel")
    [Phone, MaxLength(20)]
    public string? PhoneNumber { get; set; }

    // URL (type="url")
    [Url, MaxLength(500)]
    public string? Website { get; set; }

    // Datum (type="date")
    [DataType(DataType.Date)]
    public DateTime ValidFrom { get; set; } = DateTime.Today;

    // Datum a čas (type="datetime-local")
    [DataType(DataType.DateTime)]
    public DateTime StartAt { get; set; } = DateTime.Now;

    // Čas (type="time") – vyžaduje Time.cshtml s TimeSpan support
    [DataType(DataType.Time)]
    public TimeSpan OpeningTime { get; set; } = TimeSpan.Zero;

    // Číslo (type="number")
    [Range(0, 1440)]
    public int MaxMinutes { get; set; }

    // Desetinné číslo
    [Range(0, 9999.99)]
    public decimal Price { get; set; }

    // Barva (type="color") – vyžaduje Color.cshtml
    [Required]
    public string ForegroundColor { get; set; } = "#000000";
    // nebo: [DataType("Color")] pro custom color template

    // Zaškrtávací políčko (bool → checkbox)
    public bool IsActive { get; set; } = true;

    // Tri-state (bool? → dropdown)
    public bool? OptionalFlag { get; set; }

    // Víceřádkový text (<textarea>)
    [DataType(DataType.MultilineText)]
    public string? Notes { get; set; }

    // Markdown editor
    [DataType("Markdown")]
    public string? MarkdownContent { get; set; }

    // HTML editor
    [DataType(DataType.Html)]
    public string? HtmlContent { get; set; }

    // Nahrání souboru (type="file")
    [DataType(DataType.Upload)]
    public IFormFile? Attachment { get; set; }

    // Heslo (type="password")
    [DataType(DataType.Password), MinLength(8)]
    public string? NewPassword { get; set; }

    // Skryté pole (odesílá se s formulářem, ale nezobrazuje)
    [HiddenInput(DisplayValue = false)]
    public int EntityId { get; set; }

    // Skryté pole se zobrazením hodnoty
    [HiddenInput]
    public string? VersionTag { get; set; }

    // Kompletně vynechat ze scaffoldingu
    [ScaffoldColumn(false)]
    public List<SelectListItem> CategoryOptions { get; } = new();

    // Pořadí a groupování
    [Display(GroupName = "Kontaktní údaje", Order = 1)]
    public string ContactName { get; set; } = string.Empty;

    [Display(GroupName = "Kontaktní údaje", Order = 2)]
    public string ContactEmail { get; set; } = string.Empty;
}
```

### 9.4 Kdy použít EditorFor vs. přímé Tag Helpers

| Situace | Doporučení |
|---|---|
| Standardní admin CRUD formuláře | `@Html.EditorFor(m => this.Model.Input)` |
| Formulář s nestandartním rozložením (2 sloupce, inline pole) | Přímé Tag Helpers `<input asp-for>` |
| Radio buttony / checkbox list | Přímé Tag Helpers nebo vlastní šablona |
| Pole vyžadující specifický wrapper HTML | Přímé Tag Helpers |
| Dynamicky generované pole (AJAX) | Přímé Tag Helpers |

**Zdroj:** `Altairis.ReP.Web/Pages/Admin/OpeningHours.cshtml` (příklad přímých Tag Helpers), ostatní admin stránky (příklady EditorFor)

---

## 10. Nastavení projektu – Program.cs a _ViewImports.cshtml

### 10.1 Program.cs

```csharp
using Altairis.ConventionalMetadataProviders;
using MyApp.Resources;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages(options => {
    // Autorizace admin sekcí
    options.Conventions.AuthorizeFolder("/Admin", "IsAdministrator");
})
.AddMvcOptions(options => {
    // Conventionální metadata providers (display names + validace z .resx)
    options.SetConventionalMetadataProviders<Display, Validation>();
});

// Lokalizace (volitelné)
builder.Services.AddLocalization();
builder.Services.Configure<RequestLocalizationOptions>(options => {
    options.SetDefaultCulture("cs-CZ");
    options.AddSupportedCultures("cs-CZ", "en-US");
    options.AddSupportedUICultures("cs-CZ", "en-US");
    options.RequestCultureProviders = [new CookieRequestCultureProvider()];
});

var app = builder.Build();

if (!app.Environment.IsDevelopment()) {
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRequestLocalization(); // pokud používáte lokalizaci
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapRazorPages();
app.Run();
```

### 10.2 Pages/_ViewImports.cshtml

```cshtml
@namespace MyApp.Pages

@using MyApp.Resources    ← přístup k Display.xxx, Validation.xxx, UI.xxx

@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
@addTagHelper *, MyApp     ← vlastní tag helpery (pokud existují)
```

### 10.3 Pages/_ViewStart.cshtml

```cshtml
@{ Layout = "_Layout"; }
```

---

## 11. Validace a client-side scripty

### 11.1 Nutné NuGet balíčky

- `Microsoft.AspNetCore.Mvc.NewtonsoftJson` (volitelně)
- jQuery Validation via LibMan nebo npm/webpack

### 11.2 _ValidationScriptsPartial.cshtml

```cshtml
@* Pages/Shared/_ValidationScriptsPartial.cshtml *@
<script src="~/lib/jquery-validation/dist/jquery.validate.min.js"></script>
<script src="~/lib/jquery-validation-unobtrusive/jquery.validate.unobtrusive.min.js"></script>
```

### 11.3 Jak DataAnnotations generují client-side validaci

```html
<!-- Z [Required] + [EmailAddress] na InputModel.Email: -->
<input type="email"
       data-val="true"
       data-val-required="Pole E-mail je povinné."
       data-val-email="Pole E-mail musí obsahovat platnou e-mailovou adresu."
       id="Input_Email" name="Input.Email" value="" />
```

`jquery.validate.unobtrusive` tyto `data-val-*` atributy automaticky načte a registruje validační pravidla bez dalšího JS kódu.

### 11.4 Validation summary ve formuláři

```cshtml
<form method="post">
    @Html.EditorFor(m => this.Model.Input)
    <footer>
        <div asp-validation-summary="All"></div>    ← zobrazí všechny chyby
        <input type="submit" value="Uložit" />
    </footer>
</form>
```

---

## 12. CSS vzory pro EditorTemplates

### 12.1 Základní CSS struktura (inspirace z Demo.DynamicUI)

```css
/* Šablony generují tuto HTML strukturu (z Object.cshtml): */

div.editor-label {          /* Label nad polem */
    margin-top: 1em;
    margin-bottom: .5ex;
}
div.editor-label::after {   /* Dvojtečka za labelem */
    content: ":";
}

div.editor-field {          /* Wrapper pro input + validation */
    /* standardně žádné speciální styly */
}

div.editor-field-checkbox { /* Boolean pole: checkbox vedle labelu */
    margin-top: 1em;
}

div.editor-complex-field {  /* Vnořený komplexní objekt */
    border: 1px solid #090;
    border-radius: 5px;
    padding: 0 1em 1em 1em;
}

details {                   /* Collapsible group */
    border: 1px solid #090;
    border-radius: 5px;
    padding: 1em;
    margin-top: 1em;
}

details summary {
    cursor: pointer;
    color: #090;
}

/* Validace */
.input-validation-error {
    border: 1px solid red;
}

span.field-validation-error {
    display: block;
    color: red;
    margin-top: .5ex;
}

div.validation-summary-valid { display: none; }
div.validation-summary-errors { color: red; }

/* Inline pole (dvě pole vedle sebe) */
input.hasextra {
    width: calc(100% - 4em);
}
input.isextra {
    float: right;
    width: 3em;
}

/* Krátká pole (PSČ, číslo) */
input[type=date],
input[type=number],
input.short {
    max-width: 10em;
}

/* Markdown textarea se symbolem */
textarea.markdown {
    font-family: monospace;
    background-image: url("...markdown SVG icon...");
    background-position: right top;
    background-repeat: no-repeat;
    background-size: 25px;
}
```

**Zdroj:** `Prezentation/03-02_EditorTemplates/wwwroot/Content/Styles/Site.css`

---

## 13. Komplexní vzory – pokročilé techniky

### 13.1 Šablona pojmenovaná po CLR typu (auto-discovery)

```cshtml
@* AddressModel.cshtml – automaticky použita pro vlastnosti typu AddressModel *@
@model MyApp.Models.AddressModel
@{
    this.Layout = string.Empty;
}
<div class="address-editor">
    <label asp-for="@Model.Street"></label>
    <input asp-for="@Model.Street" />
    <span asp-validation-for="@Model.Street"></span>

    <label asp-for="@Model.City"></label>
    <input asp-for="@Model.City" />

    <div class="inline-group">
        <input asp-for="@Model.Zip" class="short" />
        <input asp-for="@Model.Country" />
    </div>
</div>
```

### 13.2 Vnořené modely v InputModel

```csharp
public class InputModel {
    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    // Vnořený model – AddressModel.cshtml se použije automaticky
    [Display(GroupName = "Fakturační adresa")]
    public AddressModel BillingAddress { get; set; } = new();

    [Display(GroupName = "Dodací adresa")]
    public AddressModel DeliveryAddress { get; set; } = new();
}
```

### 13.3 TemplateDepth – ochrana proti nekonečné rekurzi

V Object.cshtml lze použít `ViewData.TemplateInfo.TemplateDepth` pro různé chování na různých úrovních zanořování:

```cshtml
@{
    if (ViewData.TemplateInfo.TemplateDepth == 1) {
        // Top-level: renderuj flat
        RenderProperties(ViewData.ModelMetadata.Properties);
    } else {
        // Zanořený objekt: obal do styled div
        <div class="editor-complex-field">
            @{ RenderProperties(ViewData.ModelMetadata.Properties); }
        </div>
    }
}
```

### 13.4 Html.Editor vs Html.EditorFor

| Metoda | Použití | Kde |
|---|---|---|
| `@Html.EditorFor(m => m.Input)` | Expression lambda, strong-typed | Razor stránka |
| `@Html.Editor("PropertyName")` | String jméno vlastnosti | Uvnitř Object.cshtml |
| `@Html.EditorFor(m => m.Input, "TemplateName")` | Explicitní šablona | Razor stránka |
| `@Html.EditorFor(m => m.Input, additionalViewData: new { key = val })` | Předání dat do šablony | Razor stránka |

---

## 14. Kompletní inventář šablon projektu Altairis.ReP

| Soubor | Triggery | HTML výstup |
|---|---|---|
| `_Layout.cshtml` | — | `@RenderBody()` (minimální layout) |
| `HtmlInput.cshtml` | Sdílená base | `<input class="textbox" type="?" placeholder="?">` |
| `Object.cshtml` | Komplexní typ | Iteruje vlastnosti, generuje label+field páry |
| `Collection.cshtml` | `IEnumerable<T>` | Indexed EditorFor pro každý prvek |
| `String.cshtml` | `string` | → HtmlInput, type="text" |
| `Text.cshtml` | `[DataType(DataType.Text)]` | → String.cshtml |
| `EmailAddress.cshtml` | `[EmailAddress]`, `[DataType(DataType.EmailAddress)]` | → HtmlInput, type="email" |
| `PhoneNumber.cshtml` | `[Phone]`, `[DataType(DataType.PhoneNumber)]` | → HtmlInput, type="tel" |
| `Url.cshtml` | `[Url]`, `[DataType(DataType.Url)]` | → HtmlInput, type="url" |
| `Color.cshtml` | `[Color]` (custom) | → HtmlInput, type="color" |
| `Upload.cshtml` | `[DataType(DataType.Upload)]` | → HtmlInput, type="file" |
| `Number.cshtml` | Čísla (přes Int32 atd.) | → HtmlInput, type="number" |
| `Int32.cshtml` | `int` | → Number.cshtml |
| `Int64.cshtml` | `long` | → Number.cshtml |
| `UInt32.cshtml` | `uint` | → Number.cshtml |
| `UInt64.cshtml` | `ulong` | → Number.cshtml |
| `SByte.cshtml` | `sbyte` | → Number.cshtml |
| `Byte.cshtml` | `byte` | → Number.cshtml |
| `Single.cshtml` | `float` | → Number.cshtml |
| `Decimal.cshtml` | `decimal` | `<input class="textbox">` (formát 0.00) |
| `Boolean.cshtml` | `bool` / `bool?` | `<input type="checkbox">` nebo tri-state `<select>` |
| `Date.cshtml` | `[DataType(DataType.Date)]`, `DateTime` | `<input type="date">` (yyyy-MM-dd) |
| `DateTime.cshtml` | `DateTime` bez DataType | `<input type="datetime-local">` |
| `Time.cshtml` | `[DataType(DataType.Time)]`, `TimeSpan` | `<input type="time">` (hh:mm) |
| `MultilineText.cshtml` | `[DataType(DataType.MultilineText)]` | `<textarea>` |
| `Html.cshtml` | `[DataType(DataType.Html)]` | `<textarea class="html">` |
| `Markdown.cshtml` | `[DataType("Markdown")]` | `<textarea>` + markdown ikona |
| `Password.cshtml` | `[DataType(DataType.Password)]` | `<input type="password">` + show/hide toggle |
| `HiddenInput.cshtml` | `[HiddenInput]` | `<input type="hidden">` (± zobrazení hodnoty) |

**Zdroj:** `Altairis.ReP.Web/Pages/EditorTemplates/`

---

## 15. Časté problémy a řešení (Gotchas)

### 15.1 Šablona zdědila layout stránky

**Problém:** Šablona vykresluje celou HTML stránku místo fragmentu.  
**Řešení:** Na začátek každé šablony přidat:
```cshtml
@{ this.Layout = "_Layout.cshtml"; }
```
nebo pro Altairis.ReP styl: vytvořit `_Layout.cshtml` v EditorTemplates složce obsahující pouze `@RenderBody()`.

### 15.2 Object.cshtml renderuje prázdné vlastnosti

**Problém:** Vlastnosti označené `[ScaffoldColumn(false)]` nebo `IEnumerable` pro datasource se zobrazují jako pole.  
**Řešení:** Použít `prop.ShowForEdit` v iteraci, nebo explicitně přidat `[ScaffoldColumn(false)]`.

### 15.3 Validace nefunguje

**Problém:** `data-val-*` atributy se negenerují nebo jQuery Validation nepracuje.  
**Řešení:**
1. Ověřit, že je `jquery.validate.unobtrusive.js` načteno po `jquery.validate.js`
2. Pro dynamicky přidané formuláře volat `$.validator.unobtrusive.parse(form)`
3. Ověřit registraci `ConventionalMetadataProviders` v Program.cs

### 15.4 Šablona se nenachází / fallback na default

**Problém:** Vlastní šablona se nepoužívá.  
**Řešení:**
1. Zkontrolovat přesný název souboru – `DataType.EmailAddress` → `EmailAddress.cshtml` (ne `Email.cshtml`)
2. Zkontrolovat umístění složky (`EditorTemplates/` správně pojmenovaná, case-sensitive na Linuxu)
3. Zkontrolovat, že atribut je správně aplikován

### 15.5 TimeSpan není nativně podporován

**Problém:** `TimeSpan` typ nemá vestavěnou šablonu.  
**Řešení:** Vytvořit `Time.cshtml` který explicitně castuje model na `TimeSpan` a formátuje ho.

### 15.6 Html.EditorFor vs Html.Editor uvnitř Object.cshtml

```cshtml
@* SPRÁVNĚ uvnitř Object.cshtml: *@
@Html.Editor(prop.PropertyName)          ← string jméno vlastnosti

@* ŠPATNĚ uvnitř Object.cshtml: *@
@Html.EditorFor(m => m.PropertyName)     ← nefunguje, m je ViewData.Model
```

### 15.7 Zanořené objekty za depth 1

Vestavěný `ObjectTemplate` renderuje objekty za hloubkou 1 jako text (`GetSimpleDisplayText()`). Vlastní `Object.cshtml` přidáte div wrapper:
```cshtml
if (ViewData.TemplateInfo.TemplateDepth == 1) {
    // flat render
} else {
    <div class="editor-complex-field">
        @{ /* renderuj rekurzivně */ }
    </div>
}
```

### 15.8 Kolize klíčů v additionalViewData

**Problém:** Název vlastnosti v `additionalViewData` koliduje s vestavěným ViewData klíčem.  
**Řešení:** Používat unikátní prefixy: `additionalCssClass` místo `class`, `editorType` místo `type`.

---

## 16. Rychlý návod – krok za krokem pro nový admin formulář

### Krok 1: Vytvořte EditorTemplates (jednorázově)

1. Vytvořte složku `Pages/EditorTemplates/`
2. Přidejte `_Layout.cshtml` s obsahem `@RenderBody()`
3. Přidejte `Object.cshtml` (viz sekce 5.1 výše)
4. Přidejte `HtmlInput.cshtml` (viz sekce 5.2)
5. Přidejte šablony pro základní typy: `String.cshtml`, `Boolean.cshtml`, `Date.cshtml`, `DateTime.cshtml`, `Time.cshtml`, `Decimal.cshtml`, `EmailAddress.cshtml`, `PhoneNumber.cshtml`, `Password.cshtml`, `MultilineText.cshtml`, `HiddenInput.cshtml`
6. Přidejte vlastní šablony: `Markdown.cshtml`, `Color.cshtml`

### Krok 2: Nakonfigurujte projekt (jednorázově)

1. Přidejte NuGet: `Altairis.ConventionalMetadataProviders`
2. Vytvořte `Resources/Display.resx` a `Resources/Validation.resx`
3. Zaregistrujte v `Program.cs`:
   ```csharp
   .AddMvcOptions(options => {
       options.SetConventionalMetadataProviders<Display, Validation>();
   });
   ```
4. V `Pages/_ViewImports.cshtml` přidejte `@using MyApp.Resources`

### Krok 3: Pro každou novou admin stránku

1. **Vytvořte InputModel** s datovými atributy:
   ```csharp
   public class InputModel {
       [Required, MaxLength(100)]
       public string Name { get; set; } = string.Empty;
       // ... další vlastnosti
   }
   ```

2. **Přidejte display names** do `Display.resx`:
   ```xml
   <data name="Name"><value>Název</value></data>
   ```

3. **Vytvořte Razor stránku** s jediným voláním:
   ```cshtml
   <form method="post">
       @Html.EditorFor(m => this.Model.Input)
       <footer>
           <div asp-validation-summary="All"></div>
           <input type="submit" value="Uložit" />
       </footer>
   </form>
   ```

4. **Hotovo** – formulář se vygeneruje automaticky.

---

## 17. Reference a zdroje

| Zdroj | URL / Cesta |
|---|---|
| Microsoft Learn – EditorTemplates | `learn.microsoft.com/en-us/aspnet/core/mvc/views/display-templates` |
| Microsoft Learn – DataAnnotations namespace | `learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations` |
| Microsoft Learn – DataType enum | `learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations.datatype` |
| Microsoft Learn – UIHintAttribute | `learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations.uihintattribute` |
| Microsoft Learn – DisplayAttribute | `learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations.displayattribute` |
| Microsoft Learn – Working with Forms | `learn.microsoft.com/en-us/aspnet/core/mvc/views/working-with-forms` |
| Microsoft Learn – Model Validation | `learn.microsoft.com/en-us/aspnet/core/mvc/models/validation` |
| Altairis.ReP projekt | `github.com/vasekNaus/ReP` |
| Altairis.ConventionalMetadataProviders | `github.com/ridercz/Altairis.ConventionalMetadataProviders` |
| ASP.NET Core TemplateRenderer.cs (source) | `github.com/dotnet/aspnetcore:src/Mvc/Mvc.ViewFeatures/src/TemplateRenderer.cs` |
| ASP.NET Core DefaultEditorTemplates.cs | `github.com/dotnet/aspnetcore:src/Mvc/Mvc.ViewFeatures/src/DefaultEditorTemplates.cs` |
| Demo projekt (Prezentation) | `Altairis.ReP/Prezentation/03-02_EditorTemplates/` |

---

## Confidence Assessment

**Vysoká jistota (ověřeno přímou inspekcí kódu):**
- Celý inventář EditorTemplate souborů z `Altairis.ReP.Web/Pages/EditorTemplates/` (přímé čtení)
- Vzory admin stránek z `Pages/Admin/` (přímé čtení)
- Demo projekt kód z `Prezentation/03-02_EditorTemplates/` (přímé čtení)
- `ConventionalMetadataProviders` implementace z GitHub zdroje (přímé čtení)
- Pořadí výběru šablony z `TemplateRenderer.cs` (přímé čtení ASP.NET Core zdroje)
- Microsoft Learn dokumentace (přímé načtení stránek)

**Střední jistota (odvozeno z dokumentace):**
- Kompletní seznam vestavěných template jmen (z `DefaultEditorTemplates.cs`)
- Chování `TemplateDepth` pro zanořené objekty

**Předpoklady:**
- CSS ukázky jsou inspirovány `Demo.DynamicUI/Site.css`, konkrétní projekt může mít jiný styling
- Instrukce jsou primárně pro Razor Pages; pro MVC jsou cesty složek jiné (viz sekce 3.1)
