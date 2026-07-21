// examples/AdminCreate.cshtml.cs
// Kompletní Create admin page model
// Nahraďte namespace, IItemRepository a Item za své typy

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.ComponentModel.DataAnnotations;

namespace MyApp.Pages.Admin.Items;

public class CreateModel : PageModel
{
    private readonly IItemRepository _repo;

    [BindProperty]
    public InputModel Input { get; set; } = new();

    public class InputModel
    {
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        [DataType("Markdown")]
        public string? Description { get; set; }

        [DataType(DataType.Date)]
        public DateTime ValidFrom { get; set; } = DateTime.Today;

        public bool IsActive { get; set; } = true;
    }

    public CreateModel(IItemRepository repo)
    {
        _repo = repo;
    }

    // GET – vrátí prázdný formulář
    public void OnGet() { }

    // POST – zpracuje formulář
    public async Task<IActionResult> OnPostAsync()
    {
        if (!this.ModelState.IsValid) return this.Page();

        await _repo.CreateAsync(new Item
        {
            Name = Input.Name,
            Description = Input.Description,
            ValidFrom = Input.ValidFrom,
            IsActive = Input.IsActive
        });

        return this.RedirectToPage("Index");
    }
}
