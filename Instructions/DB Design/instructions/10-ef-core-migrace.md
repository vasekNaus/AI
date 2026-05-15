# 10 — EF Core integrace a migrace

> Explicitní mapping · 3-krokové NOT NULL · HasColumnName pro legacy · Identity vzory

---

## Fluent API vs. Data Annotations

**Vždy Fluent API** (`IEntityTypeConfiguration<T>`) — ne DataAnnotations na entitách.

```csharp
// ✅ Správně — konfigurace oddělena od entity
public class TicketConfiguration : IEntityTypeConfiguration<Ticket>
{
    public void Configure(EntityTypeBuilder<Ticket> builder)
    {
        builder.ToTable("Ticket", "helpdesk");
        builder.HasKey(t => t.Id);

        builder.Property(t => t.Title)
            .IsRequired()  // ⚠️ S NRT enabled (<Nullable>enable</Nullable>) redundantní pro non-nullable string — EF Core odvozuje NOT NULL z C# nullability anotace
            .HasMaxLength(300);

        builder.Property(t => t.CreatedAt)
            .HasColumnType("datetime2(0)")
            .HasDefaultValueSql("SYSUTCDATETIME()");

        // FK s legacy pojmenováním (podtržítko!)
        builder.Property(t => t.CustomerId)
            .HasColumnName("Customer_Id");  // ⚠️ povinné pro legacy sloupce! .IsRequired() je s NRT redundantní

        builder.HasOne(t => t.Customer)
            .WithMany(c => c.Tickets)
            .HasForeignKey(t => t.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

// Registrace v DbContext
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
}
```

---

## Legacy sloupce s podtržítkem — HasColumnName

EF Core **nepáruje** automaticky `Customer_Id` (DB) s `CustomerId` (C# property).

```csharp
// Každý FK sloupec s podtržítkem MUSÍ mít explicitní HasColumnName!
builder.Property(t => t.CustomerId).HasColumnName("Customer_Id");
builder.Property(t => t.ProjectId).HasColumnName("Project_Id");
builder.Property(t => t.DeviceId).HasColumnName("Device_Id");
builder.Property(t => t.UserId).HasColumnName("User_Id");
```

---

## Bezpečný vzor pro EF Core migrace

### NOT NULL sloupec na existující tabulku — VŽDY 3 kroky

```csharp
// ❌ NIKDY jedním krokem (způsobí chybu na neprázdné tabulce)
migrationBuilder.AddColumn<string>("Status", "Ticket", "helpdesk",
    nullable: false);

// ✅ VŽDY 3 kroky:

// KROK 1: Přidat jako nullable s default hodnotou
migrationBuilder.AddColumn<string>(
    name: "Status",
    schema: "helpdesk",
    table: "Ticket",
    nullable: true,
    defaultValue: "Open");

// KROK 2: Backfill existujících dat
migrationBuilder.Sql(
    "UPDATE [helpdesk].[Ticket] SET [Status] = 'Open' WHERE [Status] IS NULL");

// KROK 3: Přidat NOT NULL constraint
migrationBuilder.AlterColumn<string>(
    name: "Status",
    schema: "helpdesk",
    table: "Ticket",
    nullable: false,
    oldNullable: true);
```

### Přidání indexu v migraci (online)

```csharp
migrationBuilder.Sql(
    "CREATE NONCLUSTERED INDEX [IX_Ticket_Customer_Id] " +
    "ON [helpdesk].[Ticket] ([Customer_Id]) WITH (ONLINE = ON)");
// ONLINE = ON: index se vytvoří bez výpadku (Enterprise/Developer edice)
```

---

## ASP.NET Identity — vzory

### Rozšíření ApplicationUser

```csharp
public class ApplicationUser : IdentityUser<int>
{
    // Vlastní sloupce
    public string  FirstName  { get; set; } = string.Empty;
    public string  LastName   { get; set; } = string.Empty;
    public string  Login      { get; set; } = string.Empty;  // vlastní login sloupec
    public bool    IsActive   { get; set; } = true;
    public int?    Customer_Id { get; set; }

    // rowversion → EF optimistická souběžnost (konfigurovat přes Fluent API, ne [Timestamp])
    public byte[] Version { get; set; } = [];
}

// Konfigurace rowversion přes Fluent API (preferováno před [Timestamp] atributem):
builder.Property(u => u.Version).IsRowVersion().HasColumnName("Version");

// ⚠️ Login vs. UserName:
// UserName = Identity standard (normalizace, validace hesla)
// Login    = vlastní sloupec v DB
// Při registraci nastavit obě!
user.UserName = user.Login = loginValue;
```

### Registrace Identity v DbContext

```csharp
public class AppDbContext : IdentityDbContext<ApplicationUser, ApplicationRole, int,
    IdentityUserClaim<int>, ApplicationUserRole, IdentityUserLogin<int>,
    IdentityRoleClaim<int>, IdentityUserToken<int>>
{
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // ⚠️ Explicitní mapování tabulek (Identity defaultuje na AspNetUsers apod.)
        builder.Entity<ApplicationUser>()
            .ToTable("User", "dbo");
        builder.Entity<ApplicationRole>()
            .ToTable("Role", "dbo");
        builder.Entity<ApplicationUserRole>()
            .ToTable("UserRole", "dbo");
        builder.Entity<IdentityUserClaim<int>>()
            .ToTable("UserClaim", "dbo");
        builder.Entity<IdentityUserLogin<int>>()
            .ToTable("UserLogin", "dbo");
        builder.Entity<IdentityRoleClaim<int>>()
            .ToTable("RoleClaim", "dbo");
        builder.Entity<IdentityUserToken<int>>()
            .ToTable("UserToken", "dbo");
    }
}
```

### UserRole s rozšiřujícím sloupcem

```csharp
// Když UserRole má extra sloupec (např. Customer_Id pro tenant-scoped role)
public class ApplicationUserRole : IdentityUserRole<int>
{
    public int? Customer_Id { get; set; }
    public Customer? Customer { get; set; }
}

// Konfigurace
builder.Entity<ApplicationUserRole>()
    .ToTable("UserRole", "dbo")
    .HasKey(ur => new { ur.UserId, ur.RoleId });

builder.Entity<ApplicationUserRole>()
    .Property(ur => ur.Customer_Id)
    .HasColumnName("Customer_Id");
```

---

## Speciální mapování

### rowversion (optimistická souběžnost)

```csharp
builder.Entity<Ticket>()
    .Property(t => t.Version)
    .IsRowVersion()
    .HasColumnName("Version");
// Poznámka: [Timestamp] atribut je ekvivalent, ale preferujeme Fluent API (pravidlo: Data Annotations nekontaminují doménový model)
```

### XML sloupec jako string

```csharp
builder.Entity<Customer>()
    .Property(c => c.TextResources)
    .HasColumnType("xml");  // uloženo jako xml, C# vidí jako string
```

### geography (NetTopologySuite)

```csharp
// Program.cs / DbContext konfigurace
optionsBuilder.UseSqlServer(cs, o => o.UseNetTopologySuite());

// Entita
using NetTopologySuite.Geometries;
public class Address {
    public Point? Location { get; set; }  // geography → NTS Point
}
```

### FILESTREAM

```csharp
public class File
{
    public int  Id     { get; set; }
    public Guid FileId { get; set; }  // ROWGUIDCOL

    // FILESTREAM — načítat samostatně raw SQL nebo file storage
    // [NotMapped] záměrně přesunuto do Fluent API (viz konfigurace níže)
    public byte[]? Data { get; set; }
}

builder.Entity<File>()
    .Ignore(f => f.Data)                  // nahrazuje [NotMapped]
    .Property(f => f.FileId)
    .HasDefaultValueSql("NEWID()");
```

---

## Struktura EF Core projektu

```
src/
  MyApp.Data/
    Entities/
      Dbo/        -- User, Role, Customer, File, Log
      Helpdesk/   -- Ticket, TicketStatus, Project
      Hr/         -- Activity (abstract), Work, Holiday, Illness
      Billing/    -- Invoice, HourlyRate
    Configurations/   -- IEntityTypeConfiguration<T> — jedna třída per entita
    AppDbContext.cs
    Migrations/
```
