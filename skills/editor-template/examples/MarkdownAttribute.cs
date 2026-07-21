// examples/MarkdownAttribute.cs
// Vlastní DataType atribut pro Markdown editor
// Zdroj: Prezentation/03-02_EditorTemplates/Attributes/MarkdownAttribute.cs

using System.ComponentModel.DataAnnotations;

namespace MyApp.Attributes;

/// <summary>
/// Označí string vlastnost jako Markdown obsah.
/// EditorFor použije šablonu Pages/Shared/EditorTemplates/Markdown.cshtml.
/// </summary>
public class MarkdownAttribute() : DataTypeAttribute("Markdown") { }

// ─── Použití v InputModel: ─────────────────────────────────────────────────
//
// using MyApp.Attributes;
//
// [Markdown]
// public string? Instructions { get; set; }
//
// ─── Alternativa bez vlastního atributu: ──────────────────────────────────
//
// [DataType("Markdown")]
// public string? Instructions { get; set; }
//
// ─── Markdown.cshtml šablona: ─────────────────────────────────────────────
//
// @{
//     this.Layout = "_Layout.cshtml";
// }
// <span class="control-icons"><i class="fa-brands fa-markdown" title="Markdown"></i></span>
// @Html.TextArea("", ViewData.TemplateInfo.FormattedModelValue.ToString())
//
// ─── Nebo bez Font Awesome, s CSS ikonou: ─────────────────────────────────
//
// @{
//     this.Layout = "_Layout.cshtml";
// }
// @Html.TextArea("", ViewData.TemplateInfo.FormattedModelValue.ToString(), new { @class = "markdown" })
//
// CSS:
// textarea.markdown {
//     background-image: url("data:image/svg+xml,...");
//     background-position: right top;
//     background-repeat: no-repeat;
//     background-size: 25px;
//     font-family: monospace;
// }
