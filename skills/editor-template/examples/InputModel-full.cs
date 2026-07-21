// examples/InputModel-full.cs
// Kompletní ukázka InputModel se všemi typy polí pro admin stránku
// Použití: zkopírujte a upravte jako základ pro Create/Edit stránku

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.ComponentModel.DataAnnotations;

namespace MyApp.Pages.Admin.Items;

public class CreateModel
{
    // Definujte InputModel jako vnořenou třídu uvnitř PageModel
    public class InputModel
    {
        // ── Textová pole ─────────────────────────────────────────────────────
        // Povinný text s max délkou → <input type="text">
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        // Volitelný text → <input type="text">
        [MaxLength(500)]
        public string? Description { get; set; }

        // Víceřádkový text → <textarea>
        [DataType(DataType.MultilineText)]
        public string? Notes { get; set; }

        // Markdown editor → <textarea class="markdown">
        [DataType("Markdown")]
        public string? MarkdownBody { get; set; }

        // HTML editor → <textarea class="html">
        [DataType(DataType.Html)]
        public string? HtmlContent { get; set; }

        // ── Kontaktní údaje ──────────────────────────────────────────────────
        // Email → <input type="email">
        [EmailAddress, MaxLength(200)]
        public string? Email { get; set; }

        // Telefon → <input type="tel">
        [Phone, MaxLength(20)]
        public string? PhoneNumber { get; set; }

        // URL → <input type="url">
        [Url, MaxLength(500)]
        public string? Website { get; set; }

        // ── Datum a čas ──────────────────────────────────────────────────────
        // Datum → <input type="date">
        [DataType(DataType.Date)]
        public DateTime ValidFrom { get; set; } = DateTime.Today;

        // Datum a čas → <input type="datetime-local">
        [DataType(DataType.DateTime)]
        public DateTime StartAt { get; set; } = DateTime.Now;

        // Čas (TimeSpan) → <input type="time"> (vyžaduje Time.cshtml šablonu)
        [DataType(DataType.Time)]
        [Range(typeof(TimeSpan), "00:00:00", "23:59:59")]
        public TimeSpan OpeningTime { get; set; } = TimeSpan.Zero;

        [DataType(DataType.Time)]
        [Range(typeof(TimeSpan), "00:00:00", "23:59:59")]
        public TimeSpan ClosingTime { get; set; } = new TimeSpan(18, 0, 0);

        // ── Čísla ────────────────────────────────────────────────────────────
        // Celé číslo s rozsahem → <input type="number">
        [Range(0, 1440)]
        public int MaxMinutes { get; set; }

        // Desetinné číslo → textbox s formátem 0.00
        [Range(0.0, 9999.99)]
        public decimal Price { get; set; }

        // ── Barvy ────────────────────────────────────────────────────────────
        // Color picker → <input type="color">
        // Použijte [UIHint("Color")] nebo vlastní [Color] atribut
        [Required]
        [UIHint("Color")]
        public string ForegroundColor { get; set; } = "#000000";

        [Required]
        [UIHint("Color")]
        public string BackgroundColor { get; set; } = "#ffffff";

        // ── Boolean ──────────────────────────────────────────────────────────
        // bool → checkbox
        public bool IsActive { get; set; } = true;

        // bool? → tri-state dropdown (Ano/Ne/Nenastaveno)
        public bool? OptionalFlag { get; set; }

        // ── Heslo ────────────────────────────────────────────────────────────
        [DataType(DataType.Password)]
        [MinLength(8)]
        public string? NewPassword { get; set; }

        // ── Nahrání souboru ──────────────────────────────────────────────────
        [DataType(DataType.Upload)]
        public IFormFile? Attachment { get; set; }

        // ── Skrytá pole ──────────────────────────────────────────────────────
        // Pro Edit formulář: posílá ID, ale nezobrazuje jako textbox
        [HiddenInput(DisplayValue = false)]
        public int Id { get; set; }

        // Skryté pole které zobrazí hodnotu jako text
        [HiddenInput]
        public string? VersionTag { get; set; }

        // ── Vyloučení z formuláře ────────────────────────────────────────────
        // Datasource pro dropdown – Object.cshtml ho vynechá
        [ScaffoldColumn(false)]
        public IEnumerable<SelectListItem> CategoryList { get; set; } = new List<SelectListItem>();

        // ── Seskupení a pořadí ───────────────────────────────────────────────
        // Vlastnosti se stejným GroupName se seskupí do <details> (verze B Object.cshtml)
        [Display(GroupName = "Kontaktní údaje", Order = 100)]
        [EmailAddress, MaxLength(200)]
        public string? ContactEmail { get; set; }

        [Display(GroupName = "Kontaktní údaje", Order = 101)]
        [Phone, MaxLength(20)]
        public string? ContactPhone { get; set; }

        // ── PSČ ──────────────────────────────────────────────────────────────
        [DataType(DataType.PostalCode)]
        [MaxLength(10)]
        public string? PostalCode { get; set; }

        // ── Měna ─────────────────────────────────────────────────────────────
        [DataType(DataType.Currency)]
        [Range(0, 1000000)]
        public decimal Amount { get; set; }
    }
}
