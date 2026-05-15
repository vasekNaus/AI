# Analýza databází ApolloHelpdesk a ApolloSmartFleet
## Návrh pro Entity Framework Core s TPC dědičností

---

## 1. Naming konvence (ze stávajících skriptů)

| Prvek | Konvence | Příklad |
|---|---|---|
| Tabulky, sloupce, indexy | **PascalCase** | `TicketStatus`, `ChangeDateSys` |
| Primární klíč | `Id` INT IDENTITY(1,1) | `[Id] [int] IDENTITY(1,1) NOT NULL` |
| Cizí klíč | `{Tabulka}_Id` | `Customer_Id`, `Ticket_Id` |
| Index | `IX_{Table}_{Column}` | `IX_Vehicle_Instance_Id` |
| PK constraint | `PK_{TableName}` | `PK_Vehicle`, `PK_Ticket` |
| Junction tabulky | Konkatenace obou entit | `CustomerCategory`, `DepotVehicle` |
| View | prefix `v` + název | `vProject`, `vTicketSummary` |
| Boolean sloupce | prefix `Is` | `IsActive`, `IsGroup`, `IsHalfDay` |
| Platnostní sloupce | `ValidFrom` / `ValidTo` | nullable `ValidTo` = aktuálně platný |
| Datetime typy | `datetime2` / `date` / `time` | `datetime2(0)` pro přesný čas |
| Geolokace | `geography` (SQL Server spatial) | `[Location] geography` |
| Schémata | doménový namespace | `helpdesk`, `hr`, `data`, `plan`, `track` |
| Uložené procedury | `{schema}.{Akce}{Entita}` | `plan.CreatePlanVersion` |

---

## 2. Kompletní seznam tabulek

### ApolloHelpdesk (schémata: dbo, helpdesk, hr, frm, acc, crm, cfg, wf)

#### dbo (infrastruktura + Identity)
| Tabulka | Popis |
|---|---|
| `dbo.Customer` | **Tenant** – zákazník systému (IC, DIC, Theme, GPS, Language, XML TextResources) |
| `dbo.User` | Uživatel sloučený s ASP.NET Identity (TPH nad IdentityUser) |
| `dbo.Role` | Role + Identity pole (NormalizedName, ConcurrencyStamp) + SysName, RoleGroup_Id |
| `dbo.RoleGroup` | Skupiny rolí (IsReport bit) |
| `dbo.RoleClaim` | Identity RoleClaims |
| `dbo.UserClaim` | Identity UserClaims |
| `dbo.UserLogin` | Identity external logins |
| `dbo.UserRole` | Identity UserRoles + `Customer_Id` (rozšíření!) |
| `dbo.UserToken` | Identity UserTokens + `IssueDateTime` |
| `dbo.UserSettings` | Uživatelská nastavení (Theme, Language, DefaultCustomer) |
| `dbo.UserFilter` | Uložené filtry (Value xml, Type, SubType) |
| `dbo.UserFilterEmailSettings` | Emailové notifikace k filtru |
| `dbo.UserFilterRole` | Filtr × Role (junction) |
| `dbo.UserAssociation` | Hierarchie uživatelů (Senior_Id, Junior_Id – self-referencing) |
| `dbo.Device` | Strom zařízení (self-referencing: Device_Id) |
| `dbo.DeviceType` | Typ zařízení |
| `dbo.DeviceKind` | Druh zařízení (DeviceType_Id) |
| `dbo.DeviceDepartment` | Zařízení × Customer (kdo má zařízení) |
| `dbo.DeviceTpl` | Šablona zařízení |
| `dbo.DevicePartTpl` | Část šablony zařízení |
| `dbo.DevicePart` | Část konkrétního zařízení |
| `dbo.File` | Soubor (FILESTREAM, FileId uniqueidentifier ROWGUIDCOL) |
| `dbo.Message` | **Základní třída zprávy** (Id, Date, Type, TextMessage, IsSend) |
| `dbo.MailMessage` | TPT: emailová zpráva (Message_Id PK+FK, Subject, AlternateText) |
| `dbo.SmsMessage` | TPT: SMS zpráva (Message_Id PK+FK – žádné extra sloupce) |
| `dbo.Attachment` | Příloha zprávy (Message_Id) |
| `dbo.BlackList` | Blacklist IP adres |
| `dbo.Board` | Nástěnka (oznamovací zprávy) |
| `dbo.CustomerBoard` | Customer × Board (junction) |
| `dbo.CustomerDomain` | E-mailové domény zákazníka |
| `dbo.Country` | Číselník zemí |
| `dbo.Priority` | Číselník priorit |
| `dbo.FreeDay` | Volné dny (svátky) |
| `dbo.OutOfOffice` | Nepřítomnost uživatele (From, To) |
| `dbo.LoginReport` | Log přihlášení |
| `dbo.ActivityReport` | Log aktivit (stránek) |

#### helpdesk (ticketing)
| Tabulka | Popis |
|---|---|
| `helpdesk.Ticket` | Ticket (Customer_Id, Device_Id, Project_Id, Classification_Id, Title, StatusTicketFirst/Last_Id) |
| `helpdesk.TicketStatus` | Stav ticketu (timeline záznam: ChangeDate, SolutionTime, Response) |
| `helpdesk.TicketStatusFull` | Rozšíření TicketStatus (State_Id, TicketTemplate_Id, SolutionTime) |
| `helpdesk.TicketUser` | Uživatelé přiřazení k TicketStatus (Role_Id, IsGuarantor) |
| `helpdesk.TicketAttachment` | Přílohy ticketu |
| `helpdesk.TicketAlert` | **Základní třída WatchDog** (Id, Ticket_Id, AlertType) |
| `helpdesk.WatchDogMail` | TPT: WatchDog emailové upozornění (WatchDog_Id PK+FK, Role_Id, UserGroup_Id) |
| `helpdesk.WatchDogState` | TPT: WatchDog při změně stavu (WatchDog_Id PK+FK, StateNew_Id) |
| `helpdesk.Category` | Kategorie ticketů (self-referencing? viz CustomerCategory) |
| `helpdesk.CustomerCategory` | Customer × Category (junction) |
| `helpdesk.CustomerUser` | Customer × User × Role × Category |
| `helpdesk.UserGroup` | Skupiny uživatelů (Customer_Id) |
| `helpdesk.UserGroupMember` | UserGroup × User × Role |
| `helpdesk.Project` | Hierarchie projektů (self-referencing, ProjectType_Id CHAR(1)) |
| `helpdesk.Classification` | Klasifikace (IsGratis, IsGroup) |
| `helpdesk.ServiceList` | Servisní list (Ticket_Id, RepairType_Id) |
| `helpdesk.DeviceServiceList` | Device × ServiceList |
| `helpdesk.Customer` | Helpdesk nastavení zákazníka (Customer_Id PK+FK → TPT nad dbo.Customer) |

#### hr (docházka)
| Tabulka | Popis |
|---|---|
| `hr.Activity` | **Základní třída aktivit** (User_Id, Date, SysDate, IsClosed, Note, ActivityTemplate_Id) |
| `hr.Work` | Pracovní den (Activity_Id PK+FK, From, To, IsHomeOffice, Department_Id) |
| `hr.Holiday` | Dovolená (Activity_Id PK+FK, IsHalfDay, Hours) |
| `hr.Illness` | Nemoc (Activity_Id PK+FK – žádné extra sloupce) |
| `hr.WorkShop` | Workshop (Activity_Id PK+FK, From, To, Name) |
| `hr.SickDay` | SickDay (Activity_Id PK+FK – žádné extra sloupce) |
| `hr.Doctor` | Lékař (Activity_Id PK+FK, From, To) |
| `hr.WorkDetail` | Výkaz práce na projektu (Work_Id → hr.Work, Project_Id, SolutionTime) |
| `hr.Department` | Oddělení |
| `hr.ActivityTemplate` | Šablona aktivity |
| `hr.ServiceEffort` | Typ úsilí / sazba (YearQuotient) |

#### frm (formuláře)
| Tabulka | Popis |
|---|---|
| `frm.Form` | Formulář (Customer_Id, Name, VariantName, ControlId) |
| `frm.FormVariant` | Varianta formuláře |
| `frm.FormState` | Stav formuláře |
| `frm.FormInstance` | Instance formuláře (datum, uživatel, xml) |
| `frm.TaskGroup` | Skupiny uživatelů pro formuláře |
| `frm.TaskGroupUser` | TaskGroup × User |
| `frm.TaskGroupUserGroup` | TaskGroup × UserGroup |
| `frm.FormTaskGroup` | Form × TaskGroup |
| `frm.Customer` | Formulářové nastavení zákazníka (Customer_Id PK+FK → TPT nad dbo.Customer) |
| `frm.DeletedFormInstance` | Auditní log smazaných instancí |

#### acc (fakturace)
| Tabulka | Popis |
|---|---|
| `acc.Customer` | Fakturační nastavení zákazníka (Customer_Id PK+FK → TPT nad dbo.Customer) |
| `acc.CustomerInvoice` | Faktura zákazníka (rok, měsíc) |
| `acc.HourlyRate` | Hodinová sazba (Rate, Discount, FreeHours, ValidFrom/ValidTo) |
| `acc.HourlyRateClassification` | HourlyRate × Classification |
| `acc.HourlyRateDevice` | HourlyRate × Device |
| `acc.HourlyRateProject` | HourlyRate × Project |
| `acc.HourlyRateUser` | HourlyRate × User |
| `acc.Period` | Číselník fakturačních period |
| `acc.RateType` | Typ sazby |

#### crm (CRM modul)
| Tabulka | Popis |
|---|---|
| `crm.Ticket` | CRM ticket (odlišný od helpdesk.Ticket!) |
| `crm.TicketStatus` | Stav CRM ticketu |
| `crm.TicketUser` | Uživatelé CRM ticketu |
| `crm.TicketAttachment` | Přílohy CRM ticketu |
| `crm.Session` | Komunikační session (Subject, CreatedDate, SessionContactFirst/Last_Id) |
| `crm.SessionContact` | Kontakt v rámci session (Note nvarchar(max), ResolutionTime) |
| `crm.SessionContactUser` | SessionContact × User × Role |
| `crm.SessionAttachment` | Příloha session |
| `crm.Category` | Kategorie CRM |
| `crm.CategoryUser` | Category × User × Role |
| `crm.Customer` | CRM nastavení zákazníka (Customer_Id PK+FK → TPT nad dbo.Customer) |
| `crm.Role` | Číselník CRM rolí |
| `crm.State` | Stav CRM ticketu |
| `crm.StateMatrix` | Povolené přechody stavů |
| `crm.Message` | Zpráva v CRM (Guid, Message_Id, Role_Id, IsExclude) |
| `crm.DeletedTicket` | Auditní log smazaných ticketů |

#### cfg (konfigurace)
| Tabulka | Popis |
|---|---|
| `cfg.BlackList` | Konfigurace brute-force blacklistu (Minutes, Count) |
| `cfg.OutOfOffice` | Vzory pro auto-odpověď (Text, Compare, Type) |
| `cfg.Theme` | Themes (SysName PK, IsDefault) |

---

### ApolloSmartFleet (schémata: dbo, data, plan, track)

#### dbo (infrastruktura + Identity)
| Tabulka | Popis |
|---|---|
| `dbo.Instance` | **Tenant** |
| `dbo.User` | ASP.NET Identity uživatel (IsActive, Language, FirstName, LastName) |
| `dbo.Role` | ASP.NET Identity role |
| `dbo.RoleClaim`, `UserClaim`, `UserLogin`, `UserRole`, `UserToken` | Standardní Identity tabulky |
| `dbo.Manufacturer` | Výrobce vozidla |
| `dbo.Model` | Model vozidla (Manufacturer_Id) |
| `dbo.MapProvider` | Poskytovatel map |
| `dbo.MapCategory` | Kategorie mapy |
| `dbo.Route` | Předpočítaná trasa (AddressStart_Id, AddressEnd_Id, MapProvider_Id, Distance, Time) |
| `dbo.DeliveryStatus` | Stav závozu (číselník) |
| `dbo.WorkerJob` | Background job (Id uniqueidentifier PK, Status, DateCreated/Started/Completed, Param/Result JSON) |
| `dbo.__EFMigrationsHistory` | EF Core migrations (DB je již spravovaná přes EF) |

#### data (doménová data)
| Tabulka | Popis |
|---|---|
| `data.Address` | **Základní třída lokace** (Id IDENTITY, Code, Name, Street, ZIPCode, City, Location geography) |
| `data.Depot` | Sklad/depo (Id NOT IDENTITY = FK na Address.Id, Instance_Id) |
| `data.Outlet` | Pobočka/odběrné místo (Id NOT IDENTITY = FK na Address.Id, Customer_Id, ExternalId, IC) |
| `data.DepotConfiguration` | Konfigurace depa (ValidFrom/ValidTo, loadingSlots, timeSeconds) |
| `data.DepotTimeFrame` | Depo × TimeFrame (provozní doby) |
| `data.DepotDriver` | Depo × Driver |
| `data.DepotUser` | Depo × User |
| `data.DepotVehicle` | Depo × Vehicle (ValidFrom/ValidTo) |
| `data.OutletConfiguration` | Konfigurace pobočky (ValidFrom/ValidTo) |
| `data.OutletTimeFrame` | Pobočka × TimeFrame |
| `data.OutletBinaryConstraint` | Pobočka × BinaryConstraint (ValidFrom/ValidTo) |
| `data.Vehicle` | Vozidlo (Manufacturer_Id, Model_Id, LicensePlate, Vin, cargo dimensions) |
| `data.VehicleConfiguration` | Konfigurace vozidla (ValidFrom/ValidTo, kapacity, časy) |
| `data.VehicleBinaryConstraint` | Vozidlo × BinaryConstraint (ValidFrom/ValidTo) |
| `data.TimeFrameVehicle` | TimeFrame × Vehicle (validní časový rámec) |
| `data.Driver` | Řidič (Instance_Id) |
| `data.DriverVehicle` | Driver × Vehicle |
| `data.Customer` | Zákazník (Instance_Id) |
| `data.Category` | Kategorie vozidel (Instance_Id, MapCategory_Id) |
| `data.Order` | Objednávka (Depot_Id, Outlet_Id, DeliveryDate) |
| `data.Delivery` | Závoze (Order_Id, DeliveryDate, TimeFrom/TimeTo, váhy, objemy) |
| `data.TimeFrame` | Časový rámec (DayOfWeek, TimeFrom/TimeTo, ValidFrom/ValidTo) |
| `data.BinaryConstraint` | Binární omezení (kompatibilita vozidel/odběrných míst) |

#### plan (plánování tras)
| Tabulka | Popis |
|---|---|
| `plan.PlanVersion` | Verze plánu (Instance_Id, Depot_Id, Date, Name) |
| `plan.Plan` | Plán – iterace optimalizace (Version + PlanVersion_Id = PK) |
| `plan.Route` | Trasa (Vehicle_Id, Plan FK) |
| `plan.Step` | Krok trasy (Route_Id, AddressStart_Id, AddressEnd_Id, DriveStart/End) |
| `plan.VehicleDay` | Snapshot vozidla pro PlanVersion (denormalizovaná data) |
| `plan.DepotDay` | Snapshot depa pro PlanVersion |
| `plan.OutletDay` | Snapshot pobočky pro PlanVersion |
| `plan.DeliveryDay` | Snapshot závoze pro PlanVersion |
| `plan.VehicleDayBinaryConstraint` | Snapshot BinaryConstraint vozidla pro PlanVersion |
| `plan.OutletDayBinaryConstraint` | Snapshot BinaryConstraint pobočky pro PlanVersion |
| `plan.DeliveryStep` | Junction: Delivery × Step |
| `plan.UnServicedDelivery` | Nezapojené závoze v plánování |

#### track (GPS tracking)
| Tabulka | Popis |
|---|---|
| `track.Tracker` | GPS zařízení (IMEI bigint PK) |
| `track.Tracking` | GPS log (Tracker_IMEI, Vehicle_Id, TrackingDateUtc, Location geography, Speed, Angle) |
| `track.VehicleTracker` | Vozidlo × Tracker (ValidFrom/ValidTo) |

---

## 3. Identifikované dědičnostní hierarchie

### 3.1 hr.Activity → **Doporučení: TPC**

```
hr.Activity (User_Id, Date, SysDate, IsClosed, Note, ActivityTemplate_Id)
  ├── hr.Work         (+From, To, IsHomeOffice, Department_Id)
  ├── hr.Holiday      (+IsHalfDay, Hours)
  ├── hr.Illness      (žádné extra sloupce)
  ├── hr.WorkShop     (+From, To, Name)
  ├── hr.SickDay      (žádné extra sloupce)
  └── hr.Doctor       (+From, To)
```

**Stávající SQL**: TPT (každý subtyp má vlastní tabulku, Activity_Id jako PK+FK)  
**Doporučení: TPC** – každý subtyp má vlastní tabulku se VŠEMI sloupci  
**Zdůvodnění**: Aktivity se vždy dotazují jako konkrétní typ (kalendář řadí typy samostatně). Žádný cross-type JOIN není nutný.

```csharp
// EF konfigurace
modelBuilder.Entity<Activity>().UseTpcMappingStrategy();
modelBuilder.Entity<Work>().ToTable("Work", "hr");
modelBuilder.Entity<Holiday>().ToTable("Holiday", "hr");
// ... atd.
```

> ⚠️ **Pozor**: `hr.WorkDetail` referencuje `hr.Work` přes `Work_Id`. Ve SmartFleet se `Activity_Id` stane plnohodnotným `IDENTITY(1,1)` na každé TPC tabulce. EF Core používá `HiLo` nebo `Sequence` pro generování ID u TPC, aby nevznikly konflikty.

---

### 3.2 dbo.Message → **Doporučení: TPC**

```
dbo.Message (Id, Date, Type int, TextMessage, IsSend, ErrorMessage)
  ├── dbo.MailMessage  (+Subject, AlternateText)
  └── dbo.SmsMessage   (žádné extra sloupce)
```

**Stávající SQL**: TPT  
**Doporučení: TPC** – `MailMessage` a `SmsMessage` jsou dotazovány vždy typově. `Type` sloupec slouží jako diskriminátor → v TPC je nadbytečný, lze zachovat pro zpětnou kompatibilitu.

```csharp
modelBuilder.Entity<Message>().UseTpcMappingStrategy();
modelBuilder.Entity<MailMessage>().ToTable("MailMessage", "dbo");
modelBuilder.Entity<SmsMessage>().ToTable("SmsMessage", "dbo");
```

---

### 3.3 helpdesk.TicketAlert (WatchDog) → **Doporučení: TPC**

```
helpdesk.TicketAlert (Id, Ticket_Id, AlertType)
  ├── helpdesk.WatchDogMail   (+Role_Id, UserGroup_Id)
  └── helpdesk.WatchDogState  (+StateNew_Id)
```

**Doporučení: TPC** – typy jsou vždy dotazovány odděleně (kdo dostane mail vs. při jakém stavu).

---

### 3.4 data.Address/Depot/Outlet → **Doporučení: TPT (zachovat)**

```
data.Address (Id IDENTITY, Code, Name, Street, ZIPCode, City, Location geography)
  ├── data.Depot  (+Instance_Id)
  └── data.Outlet (+Customer_Id, ExternalId, IC)
```

**Stávající SQL**: TPT (Depot.Id a Outlet.Id jsou NOT IDENTITY, FK na Address.Id s CASCADE DELETE)  
**Doporučení: Zachovat TPT** – `Address` je referencována jako FK z jiných tabulek (`plan.Step.AddressStart_Id`, `dbo.Route.AddressStart_Id`). EF TPT správně namapuje sdílené Id.

```csharp
modelBuilder.Entity<Address>().ToTable("Address", "data");
modelBuilder.Entity<Depot>()
    .ToTable("Depot", "data")
    .Property(d => d.Id).ValueGeneratedNever(); // NOT IDENTITY
modelBuilder.Entity<Outlet>()
    .ToTable("Outlet", "data")
    .Property(o => o.Id).ValueGeneratedNever();
```

---

### 3.5 dbo.Customer – doménová rozšíření → **NENÍ dědičnost – 1:1 relace**

Tabulky `helpdesk.Customer`, `acc.Customer`, `crm.Customer`, `frm.Customer` mají každá `Customer_Id` jako PK+FK na `dbo.Customer`. Toto **NENÍ** IS-A vztah, ale per-domain konfigurační rozšíření.

**Doporučení**: Mapovat jako samostatné entity s `HasOne / WithOne` navigacemi:

```csharp
// dbo.Customer je hlavní entita
public class Customer {
    public HelpdeskCustomer? HelpdeskSettings { get; set; }
    public AccountingCustomer? AccountingSettings { get; set; }
    public CrmCustomer? CrmSettings { get; set; }
    public FormsCustomer? FormsSettings { get; set; }
}

modelBuilder.Entity<Customer>()
    .HasOne(c => c.HelpdeskSettings)
    .WithOne()
    .HasForeignKey<HelpdeskCustomer>(h => h.CustomerId);
```

---

## 4. Speciální EF mapování

### 4.1 ASP.NET Identity

**ApolloHelpdesk** – `dbo.User` je sloučen s Identity v jedné tabulce (de facto TPH nad IdentityUser):

```csharp
public class ApplicationUser : IdentityUser<int>
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public int? Customer_Id { get; set; }
    public bool IsGroup { get; set; }
    public bool IsActive { get; set; }
    public bool IsRoot { get; set; }
    public string? Room { get; set; }
    public string? Building { get; set; }
    public string? Phone { get; set; }
    public string? Mobil { get; set; }
    // ...
    [Timestamp]
    public byte[] Version { get; set; } // timestamp → RowVersion
}
```

> `dbo.UserRole` má navíc `Customer_Id` – tenant-scoped role. Vyžaduje vlastní `IdentityUserRole<int>` subclass.

**ApolloSmartFleet** – standardní Identity, čisté rozšíření:

```csharp
public class ApplicationUser : IdentityUser<string>
{
    public bool IsActive { get; set; }
    public string Language { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
}
```

---

### 4.2 Geolokace (geography)

Použít **NetTopologySuite**:

```csharp
// Program.cs / DbContext
optionsBuilder.UseSqlServer(connectionString, o => o.UseNetTopologySuite());

// Entity
using NetTopologySuite.Geometries;
public class Address {
    public Point? Location { get; set; }  // geography → Point
}
```

---

### 4.3 FILESTREAM (dbo.File v HelpDesk)

```csharp
public class File {
    public int Id { get; set; }
    public Guid FileId { get; set; }
    [NotMapped] // nebo načítat jen explicitně
    public byte[]? Data { get; set; }
    public string Name { get; set; }
    public string ContentType { get; set; }
}

// Fluent API
modelBuilder.Entity<File>()
    .Property(f => f.FileId)
    .ValueGeneratedOnAdd(); // ROWGUIDCOL
```

---

### 4.4 XML sloupce

```csharp
// dbo.Customer.TextResources, frm.FormInstance.StaticFormXml, dbo.UserFilter.Value
modelBuilder.Entity<Customer>()
    .Property(c => c.TextResources)
    .HasColumnType("xml");
// Mapovat jako string v C#
```

---

### 4.5 Composite PK (plan schema)

```csharp
// plan.Plan má kompozitní PK: (Version, PlanVersion_Id)
modelBuilder.Entity<Plan>()
    .HasKey(p => new { p.Version, p.PlanVersionId });

// plan.OutletDay má kompozitní PK: (Outlet_Id, PlanVersion_Id)
modelBuilder.Entity<OutletDay>()
    .HasKey(o => new { o.OutletId, o.PlanVersionId });
```

---

### 4.6 Tracker IMEI jako PK (bigint, not identity)

```csharp
public class Tracker {
    public long IMEI { get; set; } // bigint PK, not identity
}
modelBuilder.Entity<Tracker>()
    .HasKey(t => t.IMEI);
modelBuilder.Entity<Tracker>()
    .Property(t => t.IMEI)
    .ValueGeneratedNever();
```

---

### 4.7 Computed columns

```csharp
// crm.TicketStatus.Status – computed column
modelBuilder.Entity<TicketStatus>()
    .Property(t => t.Status)
    .HasComputedColumnSql("case when [RequestDate]<=getdate() then 'Z' when [ReminderDate]<=getdate() then 'U' else '' end");
```

---

### 4.8 ValidFrom/ValidTo pattern – doporučená interface

```csharp
public interface ITemporalValidity {
    DateTime ValidFrom { get; set; }
    DateTime? ValidTo { get; set; }
}

// Extension method pro EF query
public static IQueryable<T> ValidAt<T>(this IQueryable<T> query, DateTime date)
    where T : ITemporalValidity
    => query.Where(e => e.ValidFrom <= date && (e.ValidTo == null || e.ValidTo >= date));
```

Používají: `acc.HourlyRate`, `data.DepotVehicle`, `data.VehicleConfiguration`, `data.DepotConfiguration`, `data.OutletConfiguration`, `data.VehicleBinaryConstraint`, `data.OutletBinaryConstraint`, `track.VehicleTracker`, `data.TimeFrame`.

---

### 4.9 WorkerJob (SmartFleet – background jobs)

```csharp
public class WorkerJob {
    public Guid Id { get; set; } // uniqueidentifier PK
    public string Status { get; set; }
    public DateTime DateCreated { get; set; }
    public DateTime? DateStarted { get; set; }
    public DateTime? DateCompleted { get; set; }
    public string? Param { get; set; } // JSON
    public string? Result { get; set; } // JSON
}
modelBuilder.Entity<WorkerJob>()
    .Property(j => j.Id)
    .HasDefaultValueSql("newid()");
```

---

## 5. Shrnutí TPC vs TPT vs TPH rozhodnutí

| Hierarchie | Stávající SQL | Doporučení | Zdůvodnění |
|---|---|---|---|
| `hr.Activity` (Work, Holiday, Illness, WorkShop, SickDay, Doctor) | TPT | **TPC** | Každý typ dotazován samostatně, žádný cross-type SELECT |
| `dbo.Message` (MailMessage, SmsMessage) | TPT | **TPC** | Typy jsou vždy odlišné, žádné polymorfní dotazy |
| `helpdesk.TicketAlert` (WatchDogMail, WatchDogState) | TPT | **TPC** | Malá, uzavřená hierarchie |
| `data.Address` (Depot, Outlet) | TPT | **TPT zachovat** | Address je FK target z jiných tabulek |
| `dbo.User` + Identity | TPH (sloučená tabulka) | **TPH zachovat** | Identity framework vyžaduje jedinou tabulku |
| `dbo.Customer` + per-domain rozšíření | TPT-like (Customer_Id PK+FK) | **1:1 relace** (ne dědičnost) | Není IS-A, ale konfigurační rozšíření |
| `helpdesk.Project.ProjectType_Id` (CHAR(1) diskriminátor) | TPH (v jedné tabulce s diskriminátorem) | **TPH zachovat** | Hierarchie v jedné tabulce, přirozené TPH |

---

## 6. Doporučená struktura EF projektů

```
src/
  ApolloHelpdesk.Data/
    Entities/
      Dbo/            -- Customer, User, Device, Message, File, ...
      Helpdesk/       -- Ticket, TicketStatus, Project, Category, ...
      Hr/             -- Activity (abstract), Work, Holiday, Illness, ...
      Frm/            -- Form, FormInstance, TaskGroup, ...
      Acc/            -- HourlyRate, CustomerInvoice, ...
      Crm/            -- Session, Ticket (CRM), ...
    Configurations/   -- IEntityTypeConfiguration<T> per entity
    HelpdeskDbContext.cs

  ApolloSmartFleet.Data/
    Entities/
      Dbo/            -- Instance, User, WorkerJob, Route, ...
      Data/           -- Address, Depot, Outlet, Vehicle, Driver, Order, ...
      Plan/           -- PlanVersion, Plan, Route, Step, VehicleDay, ...
      Track/          -- Tracker, Tracking, VehicleTracker
    Configurations/
    SmartFleetDbContext.cs
```

---

## 7. Potenciální problémy a doporučení

| Problém | Popis | Řešení |
|---|---|---|
| HelpDesk `COMPATIBILITY_LEVEL = 100` | SQL Server 2008 mód (starší funkce) | Zvýšit na 150+ při migraci |
| HelpDesk `AUTO_SHRINK ON` | Anti-pattern, způsobuje fragmentaci | Vypnout: `ALTER DATABASE SET AUTO_SHRINK OFF` |
| Smíšené `varchar` vs `nvarchar` | Starší HelpDesk DB používá varchar | Při redesignu standardizovat na `nvarchar` |
| `dbo.UserFilter.Value xml` | XML jako datový typ | Mapovat jako `string`, zvážit JSON v nové DB |
| `dbo.Customer.TextResources xml` | XML konfigurace per tenant | Mapovat jako `string`, zvážit přechod na JSON |
| `dbo.File.Data varbinary(max) FILESTREAM` | EF nepodporuje FILESTREAM nativně | `[NotMapped]` + raw SQL nebo file storage service |
| `helpdesk.Project` ORDER computed column | SSMS pojmenování konfliktu s SQL ORDER klíčovým slovem | Přejmenovat na `OrderIndex` nebo `ProjectOrder` |
| `plan.Plan` composite PK (Version, PlanVersion_Id) | Kompozitní klíč s int verzemi | Fluent API `HasKey(p => new { p.Version, p.PlanVersionId })` |
| TPC s `hr.Activity` – generování ID | TPC vyžaduje globálně unikátní ID přes všechny podtabulky | EF Core: použít `UseHiLo()` nebo sequence `CREATE SEQUENCE hr.ActivityIdSeq` |
| `data.Depot.Id` a `data.Outlet.Id` NOT IDENTITY | ID je přebíráno z Address (TPT pattern) | `ValueGeneratedNever()`, EF TPT to zvládne automaticky |
| `track.Tracker.IMEI bigint` jako PK | Nestandardní PK | `ValueGeneratedNever()` |
| SmartFleet `dbo.Route` vs `plan.Route` | Dvě různé tabulky s názvem Route v různých schématech | Pojmenovat C# entity jako `CachedRoute` (dbo) a `PlanRoute` (plan) |
| `dbo.UserRole` v HelpDesk + `Customer_Id` | Nestandardní rozšíření Identity UserRole | Vlastní `ApplicationUserRole : IdentityUserRole<int>` |

---

## 8. Vzorová C# třída pro TPC (hr.Activity)

```csharp
// Abstraktní bázová třída (nemá vlastní tabulku v TPC)
public abstract class Activity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; }
    public DateOnly Date { get; set; }
    public DateTime SysDate { get; set; }
    public bool IsClosed { get; set; }
    public string? Note { get; set; }
    public int? ActivityTemplateId { get; set; }
    public ActivityTemplate? ActivityTemplate { get; set; }
}

public class Work : Activity
{
    public TimeOnly From { get; set; }
    public TimeOnly To { get; set; }
    public bool IsHomeOffice { get; set; }
    public int? DepartmentId { get; set; }
    public Department? Department { get; set; }
    public ICollection<WorkDetail> WorkDetails { get; set; } = [];
}

public class Holiday : Activity
{
    public bool IsHalfDay { get; set; }
    public decimal Hours { get; set; }
}

public class Illness : Activity { }   // žádné extra vlastnosti
public class SickDay : Activity { }   // žádné extra vlastnosti

public class Doctor : Activity
{
    public TimeOnly From { get; set; }
    public TimeOnly To { get; set; }
}

public class WorkShop : Activity
{
    public TimeOnly From { get; set; }
    public TimeOnly To { get; set; }
    public string Name { get; set; }
}

// EF konfigurace
public class ActivityConfiguration : IEntityTypeConfiguration<Activity>
{
    public void Configure(EntityTypeBuilder<Activity> builder)
    {
        builder.UseTpcMappingStrategy();
        // EF Core použije sequence nebo HiLo pro globální ID
        builder.Property(a => a.Id)
               .UseHiLo("ActivityHiLoSequence", "hr");
    }
}

public class WorkConfiguration : IEntityTypeConfiguration<Work>
{
    public void Configure(EntityTypeBuilder<Work> builder)
    {
        builder.ToTable("Work", "hr");
    }
}
```

---

## 9. Doporučené databázové sequence pro TPC

```sql
-- Pro hr.Activity TPC hierarchii
CREATE SEQUENCE [hr].[ActivityIdSequence]
    AS INT
    START WITH 1
    INCREMENT BY 10  -- HiLo blok
    NO MAXVALUE;

-- Pro dbo.Message TPC hierarchii  
CREATE SEQUENCE [dbo].[MessageIdSequence]
    AS INT
    START WITH 1
    INCREMENT BY 10;
```

---

## 10. Klíčové indexy k zachování / přidat

### SmartFleet (z existujících indexů)
- `IX_Tracking_Vehicle_Id_Tracker_IMEI_TrackingDateUtc` – kompozitní, kritický pro GPS queries
- `IX_OutletDayBinaryConstraint_PlanVersion_Id_IsValid` – covering index s INCLUDE
- `IX_VehicleDayBinaryConstraint_PlanVersion_Id_IsValid` – covering index s INCLUDE

### HelpDesk (doporučení pro nový design)
- `IX_Ticket_Customer_Id_StatusTicketLast_Id` – nejčastější dotaz
- `IX_TicketStatus_Ticket_Id` – timeline ticketu
- `IX_Activity_User_Id_Date` – docházkové přehledy

---

*Dokument vytvořen na základě analýzy `ApolloHelpdesk.sql` (~3150 řádků) a `ApolloSmartFleet.sql` (2825 řádků). Obě databáze plně přečteny.*
