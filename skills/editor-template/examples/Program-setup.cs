// examples/Program-setup.cs
// Konfigurace Program.cs pro EditorTemplate systém s ConventionalMetadataProviders
// Zdroj: Altairis.ReP.Web/Program.cs

using Altairis.ConventionalMetadataProviders;
using MyApp.Resources;  // Generated classes from Display.resx and Validation.resx

var builder = WebApplication.CreateBuilder(args);

// ── Razor Pages + EditorTemplate konfigurace ─────────────────────────────────
builder.Services.AddRazorPages(options =>
{
    // Autorizace admin sekce (volitelné)
    options.Conventions.AuthorizeFolder("/Admin", "IsAdministrator");

    // Pokud nemáte autorizaci, stačí:
    // (žádné conventions)
})
.AddMvcOptions(options =>
{
    // KLÍČOVÁ ŘÁDKA: conventional metadata providers
    // Display = třída vygenerovaná z Resources/Display.resx
    // Validation = třída vygenerovaná z Resources/Validation.resx
    options.SetConventionalMetadataProviders<Display, Validation>();

    // Varianta jen s display metadata (bez custom validation messages):
    // options.SetConventionalMetadataProviders<Display>();
});

// ── Lokalizace (volitelné, pokud chcete vícejazyčnost) ───────────────────────
builder.Services.AddLocalization(options => options.ResourcesPath = "Resources");
builder.Services.Configure<RequestLocalizationOptions>(options =>
{
    options.SetDefaultCulture("cs-CZ");
    options.AddSupportedCultures("cs-CZ", "en-US");
    options.AddSupportedUICultures("cs-CZ", "en-US");
    // Použít pouze cookie pro výběr kultury (ne URL ani query string)
    options.RequestCultureProviders = [new CookieRequestCultureProvider()];
});

// ── Build a pipeline ─────────────────────────────────────────────────────────
var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRequestLocalization();  // zapnout pokud používáte lokalizaci výše
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();       // zapnout pokud používáte ASP.NET Core Identity
app.UseAuthorization();
app.MapRazorPages();
app.Run();
