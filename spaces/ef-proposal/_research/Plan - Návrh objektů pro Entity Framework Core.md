# Deep research plan: Návrh objektů pro Entity Framework Core

## Problém
Potřebuji připravit hlubší research k návrhu objektového modelu pro Entity Framework Core tak, aby výstup:
- respektoval doporučení Microsoft dokumentace,
- zahrnoval ověřené best practices z webu,
- využil Context7 jako doplňkový zdroj dokumentace,
- samostatně zpracoval nullable reference types v doménových entitách,
- posoudil pattern s privátní nullable backing field a veřejnou non-null property s guardem, který při nenačtené / neinicializované hodnotě vyhazuje výjimku.
   - Příklad private Country? _country;
public Country Country
{
  set => _country = value;
  get => _country ?? throw new InvalidOperationException("Uninitialized property: " + nameof(Country));
}


## Aktuální stav repozitáře
- Repo je primárně znalostní / instrukční základna; v aktuálním stromu nejsou nalezeny aktivní `.csproj` ani běžící aplikační EF Core projekty.
- Nejrelevantnější interní podklady už dnes existují v:
  - `Instructions\DB Design\db-analysis-ef-design.md`
  - `Instructions\DB Design\db-design-rules.md`
  - `Instructions\DB Design\instructions\10-ef-core-migrace.md`
  - `Instructions\OpenApi\csharp-openapi-generation-rules.md`
- Stávající dokumentace už obsahuje silná doporučení pro Fluent API, `IEntityTypeConfiguration<T>`, `ApplyConfigurationsFromAssembly`, migrace a některé návrhové volby kolem dědičnosti.
- Nullable problematika je v repozitáři zachycená jen částečně a spíš v kontextu OpenAPI / multi-targetingu než jako ucelený EF Core design guideline.

## Navržený přístup
1. Zmapovat a shrnout aktuální interní guidance v repozitáři, aby nový research nenavazoval v rozporu se stávajícími pravidly.
2. Dohledat a porovnat doporučení z Microsoft Learn / EF Core docs pro:
   - návrh entit,
   - mapování hodnotových objektů / owned types / complex types,
   - konstruktory, backing fields, field-only properties,
   - navigace, kolekce, dědičnost, encapsulation.
3. Dohledat doplňkové best practices z kvalitních externích zdrojů a oddělit konsenzus od kontroverzních patternů.
4. Přes Context7 ověřit aktuální doporučení a API směr pro EF Core dokumentaci relevantní k entity designu a nullable referencím.
5. Samostatně rozebrat možnosti práce s nullable reference types:
   - čisté non-null properties s povinnou inicializací,
   - `required`,
   - ctor/factory enforcement,
   - nullable property + validační vrstva,
   - backing field pattern s výjimkou v getteru,
   - dopad na EF materializaci, lazy/eager loading a DX.
6. Vyhodnotit pattern "private nullable field + public non-null property throwing on null" z pohledu:
   - souladu s EF Core,
   - souladu s NRT analyzátory,
   - čitelnosti a debuggability,
   - rizika runtime výjimek,
   - vhodnosti pro scalar vs navigation properties.
7. Syntetizovat závěr do strukturovaného výstupu s doporučeným rozhodovacím rámcem a příklady "doporučeno / použít opatrně / nedoporučeno".

## Předběžné deliverables
- Research dokument shrnující doporučení a trade-offy.
- Samostatná sekce pro nullable reference types v EF Core entitách.
- Doporučení pro použití backing-field patternu s guard výjimkou.
- Pokud bude dávat smysl, doplnění nebo návaznost na existující dokumenty v `Instructions\DB Design`.

## Todo seznam
1. Inventarizovat interní guidance a overlap s existující dokumentací.
2. Dohledat Microsoft Learn / EF Core guidance pro návrh entit a encapsulation.
3. Dohledat Context7 podklady k EF Core designu a nullable patternům.
4. Porovnat externí best practices a identifikovat sporné oblasti.
5. Vyhodnotit nullable reference type strategie včetně backing-field guard patternu.
6. Navrhnout cílovou strukturu research výstupu a místo uložení v repozitáři.

## Otevřené body
- Má být výsledkem nový samostatný research dokument, nebo aktualizace existujících dokumentů v `Instructions\DB Design`?
- Má být research zaměřený na poslední stabilní EF Core / .NET LTS, nebo má zůstat verzově obecný?
- Má výstup skončit jen analyticky, nebo i explicitními doporučeními pro tento repozitář / budoucí generování návrhů?

## Poznámky
- Protože repozitář neobsahuje aktivní aplikační EF Core řešení, plán předpokládá dokumentační / analytický výstup, ne implementaci běžícího kódu.
- Je potřeba hlídat rozdíl mezi doporučeními pro persistence model a pro čistý domain model; u nullable patternů se často liší ideální DDD přístup a praktické EF Core kompromisy.

## Upřesnění po prvním kole otázek
- Bezprostředním cílem není samotný research dokument, ale **připravit kvalitní zadání / brief pro navazující research úlohu**.
- Technologické zaměření má být **.NET 10 / odpovídající EF Core generace**.
- Požadovaný charakter výstupu je zatím **analysis only** — tedy analytické zhodnocení variant, ne definice závazného standardu pro tento repozitář.
- Další krok: doplnit parametry budoucího research zadání (hloubka, struktura, požadované zdroje, forma závěru, explicitní otázky k nullable patternu).

## Upřesnění po druhém kole otázek
- Výsledkem má být **structured brief + hotový prompt** pro navazující research úlohu.
- Zadání má být připravené **v češtině**.
- Research má čerpat **široce**: Microsoft docs, Context7, kvalitní externí články, blogy, GitHub diskuse a další komunitní zdroje — s jasným oddělením autoritativních a komunitních doporučení.
- V zadání mají být explicitně zdůrazněna tato témata:
  - shape entit a persistence-friendly objektový model,
  - konstruktory / factories / `required` / `init`,
  - navigace a kolekce,
  - owned / complex types a value objects,
  - dědičnost,
  - nullable reference types obecně,
  - pattern s privátní nullable backing field a veřejnou non-null property, která při `null` vyhazuje výjimku.
  - databázová vrstva nebude využívat lazy loading. Navigační property nebudou obsahovat klíčové slovo virtual
  - v případě  M-N vazby chci vytvořit obě referenční kolekce jak "Skip collection navigation" - tzn. přímo kolekce druhých objektů, tak "navigation collection" - tzn. kolekce vazebních objektů
  - vše, co je možné řešit přes data atributy,  například `Key`, `StringLength(50)`, `PrimaryKey`, `Table` - u Table používat název schématu.
  - nepoužívat v data atributech magické stringy, ale funkci nameof()
  - minimum věcí řešit pomocí fluent api zápisu v metodě OnModelCreating



## Finální podoba plánu
1. Shrnu současný stav interních dokumentů v repozitáři a vytáhnu z nich body, které musí navazující research respektovat nebo validovat.
2. Připravím osnovu navazující research úlohy rozdělenou na:
   - cíl,
   - scope,
   - zdrojovou strategii,
   - konkrétní výzkumné otázky,
   - očekávanou strukturu výsledku,
   - kritéria hodnocení jednotlivých návrhových variant.
3. Do briefu explicitně zapracuję požadavek na rozlišení:
   - oficiálních Microsoft doporučení,
   - Context7 dokumentace,
   - komunitního konsenzu,
   - kontroverzních nebo situačních patternů.
4. Do promptu pro research úlohu zahrnu i povinnost:
   - srovnat přístupy pro NRT v EF Core entitách,
   - vyhodnotit backing-field guard pattern,
   - odlišit doporučení pro scalar properties, required navigations a optional navigations,
   - upozornit na dopady na EF materializaci, lazy loading, serializaci, analyzátory a ergonomii doménového modelu.
5. Výstupem této plánované práce bude:
   - krátký structured brief pro zadání,
   - hotový research prompt v češtině,
   - případně doprovodné poznámky, co musí být ve výsledném research deliverable povinně pokryto.
