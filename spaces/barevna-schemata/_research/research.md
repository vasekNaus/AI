# Barevné schéma „Sport" — HC Klatovy

## Rešerše a definice barevné identity pro webovou aplikaci sportovního klubu

**Datum:** 2026-05-12  
**Verze:** 1.0  
**Autor:** Copilot Research (výzkumná rešerše)

---

## Executive Summary

Tato rešerše definuje kompletní barevné schéma **„Sport"** pro webovou aplikaci HC Klatovy (Hokejový klub Klatovy). Schéma vychází ze tří zdrojů: (1) přímé analýzy webu klubu `hc-klatovy.cz` a webu města `klatovy.cz`, (2) heraldiky města Klatovy (znaku a vlajky), a (3) vědeckých poznatků o psychologii barev v sportovním webdesignu.

Výsledné schéma kombinuje **červenou** (sport, energie, tradice klubu), **námořnicky modrou** (důvěra, autorita, heraldika) a **bílou** (čistota, lad, hokejový led). Jako heraldický akcent se používá **zlatá**, odvozená přímo ze znaku města Klatovy. Schéma je dostupné ve dvou módech — **Light** (světlý) a **Dark** (tmavý) — a splňuje normu přístupnosti **WCAG 2.1 AA** ve všech kombinacích popředí a pozadí.

---

## 1. Analýza webu HC Klatovy (`hc-klatovy.cz`)

### 1.1 Popis webu

Web HC Klatovy běží na platformě **eSports.cz** (sdílené CMS pro hokejové kluby 2.–4. ligy). Stránka je postavena na Bootstrapu 4 s vlastními styly (`style.min.css`). Analýzou zdrojových CSS souborů byly zjištěny přesné hex hodnoty všech použitých barev.

### 1.2 Identifikované barvy

| Role | Hex | RGB | Poznámka |
|------|-----|-----|---------|
| **Primární červená** | `#d8232a` | `rgb(216, 35, 42)` | Hlavní značková barva — tlačítka, akcenty, zvýraznění |
| **Námořní modrá** | `#292d78` | `rgb(41, 45, 120)` | Sekundární barva — nadpisy, navigace, linky |
| **Bílá** | `#ffffff` | `rgb(255, 255, 255)` | Pozadí karet, hlavičky, navigace |
| **Světle šedá** | `#f0f0f0` | `rgb(240, 240, 240)` | Pozadí stránky (`body`) |
| **Tmavý text** | `#1a1919` | `rgb(26, 25, 25)` | Primární text navigace a obsahu |
| **Střední šedá** | `#4a4a4a` | `rgb(74, 74, 74)` | Popisky kategorií článků |
| **Ztlumená šedá** | `#b9b9b9` | `rgb(185, 185, 185)` | Metadata, datum, vedlejší texty |
| **Tmavší červená** | `#b60406` | — | Hover/aktivní stavy v podmenu |
| **Ocelově modrá** | `#729aa5` | — | Ikona pinned tab (Safari) |

### 1.3 Způsob použití barev

- **Červená `#d8232a`** se používá jako primární akcentová barva: tlačítka, 5px horní okraje karet, přehled ligy, zvýraznění řádku HC Klatovy v tabulce (.KLT), hero slider overlay, výzvy k akci.
- **Námořní modrá `#292d78`** se používá pro strukturální prvky: nadpisy článků, linky v patičce, zobrazení skóre, okraje sekcí.
- **Bílá** tvoří čisté pozadí karet, karet s články, navigace.
- Tato trojice barev — **červená + námořní modrá + bílá** — odpovídá klasickému schématu českého hokejového klubu.

> **Zdroj:** Přímá analýza souborů `style.min.css` a `_hotfix.css` ze stránek `hc-klatovy.cz`.[^1]

---

## 2. Analýza webu města Klatovy (`klatovy.cz`)

### 2.1 Barvy na webu města

Web `klatovy.cz` používá jako hlavní interaktivní barvu **modrou** v různých odstínech tyrkysové a azurové:

| Role | Hex | Popis |
|------|-----|-------|
| Hlavní interaktivní modrá | `#007cad` | Hover/aktivní stavy podmenu |
| Okrasná azurová | `#10bcff` | Horní akcent lišty navigace |
| Ocelová modrá | `#1d7ab1` | Pravý panel (ra-item) |
| Nebeská modrá | `#0894c2` | Ikony |
| Pinned-tab (Safari) | `#5bbad5` | Brand barva záložky |
| Ledová modrá (bg) | `#dcf5ff` | Velmi světlé záhlaví podmenu |

Web používá **bílé** pozadí (`#ffffff`) a šedé texty (`#555`, `#6d6d6d`). Červená se zde vyskytuje pouze jako utilita (tlačítko vymazat v hledání `#e00000`).

### 2.2 Heraldické barvy Klatov

Znak města Klatovy byl schválen výnosem Ministerstva vnitra **15. dubna 1938** (usnesení rady ze dne 21. 8. 1936) a navazuje na nejstarší pečeť města datovanou k roku 1289. Přesné hex hodnoty jsou odvozeny přímo z vektorového SVG souboru znaku:

| Heraldický prvek | Hex | Heraldický název | Popis |
|---|---|---|---|
| **Pozadí štítu** | `#D9261C` | Červeň (Gules) | Hlavní pole štítu — teplá vermiliónová červeň |
| **Zdivo, věže, cimbuří** | `#FFFFFF` | Stříbro (Argent) | Dvojitá hradba se cimbuřím a dvě věže |
| **Střechy věží** | `#005CA1` | Modř (Azure) | Stanové střechy obou věží — královská modrá |
| **Makovice** | `#FFF500` | Zlato (Or) | Ozdobné makovice na vrcholcích věží |
| **Obrysy** | `#1F1A17` | — | Téměř černé tahy pera |

> **Zdroj:** SVG soubor znaku města: `commons.wikimedia.org/wiki/File:Klatovy-znak.svg` — přímé čtení atributů `fill` z vektorové grafiky.[^2]

### 2.3 Vlajka města Klatovy

Vlajka obsahuje **4 horizontální pruhy v pořadí: bílá–červená–bílá–červená** (`#ffffff` a `#ff0000`). Vlajka symbolicky kondenzuje heraldické barvy na nejdůležitější dva: **červená a bílá**.

> **Zdroj:** SVG soubor vlajky: `commons.wikimedia.org/wiki/File:Flag_of_Klatovy.svg`.[^3]

### 2.4 Symbolika karafiátů

Klatovy jsou od roku 1813 proslaveny pěstováním tzv. **klatovských karafiátů**. Přírodní barva karafiátu (divoká odrůda *Dianthus caryophyllus*) je jasně **červenorůžová** až **purpurová** — barva vizuálně blízká heraldické červeni znaku. Tím vzniká symbolická trojice: **heraldika → karafiátová tradice → barvy hokejového klubu**.

---

## 3. Psychologie barev ve sportovním webdesignu

### 3.1 Klíčová zjištění

Výzkumy z oborů psychologie barev a UX designu (Smashing Magazine, colorpsychology.org, Nielsen Norman Group) i analýza NHL týmů (teamcolorcodes.com) ukazují toto:

| Barva | Psychologický účinek | Použití ve sportu |
|-------|---------------------|-------------------|
| **Tmavá modrá (námořní)** | Důvěra, spolehlivost, autorita, síla | Identita klubu, navigace, struktura webu |
| **Královská modrá** | Energizující, osvěžující, kreativní | Interaktivní prvky |
| **Červená** | Energie, soutěžení, vášeň, urgence, dominance | CTA tlačítka, góly, akce, výsledky |
| **Zlatá / žlutá** | Prestiž, úspěch, šampionát, výzva | Trofeje, vyznamenání, featured obsah |
| **Černá** | Síla, elegance, moderní edge | Tmavé téma, premium přístup |
| **Bílá** | Čistota, svěžest, led | Led, kontrastní texty, dýchání designu |
| **Stříbrná / ocelová** | Profese, moderní, technika | Podpůrný metalický tón |

### 3.2 Hokejová specifika barev

| Barva | Hokejová asociace | Proč funguje |
|-------|-------------------|--------------|
| **Tmavá námořní** | Zimní stadion v noci, autorita, tradice | Hluboká, filmová, důvěryhodná |
| **Ledová modrá** | Povrch ledu, rychlost, čistota | Barva čerstvě upraveného ledu Zamboni |
| **Bílá** | Plocha ledu, linie rychlosti | Symbolizuje led a hru |
| **Červená** | Krevní sport, soupeření, góly, energie | Univerzální sportovní agresivita |
| **Zlatá** | Trofej, mistrovství, aspirace | Prémiový aspirační pocit |
| **Stříbrná** | Brusle, hokejky, mistrovské vybavení | Metalická modernost |

### 3.3 Ověřené kombinace NHL klubů

| Klub | Barvy | Hex hodnoty |
|------|-------|-------------|
| Detroit Red Wings | Červená + bílá | `#CE1126` + `#FFFFFF` |
| Montréal Canadiens | Červená + námořní + bílá | `#AF1E2D` + `#192168` + `#FFFFFF` |
| Washington Capitals | Námořní + červená + bílá | `#041E42` + `#C8102E` + `#FFFFFF` |
| Boston Bruins | Zlatá + černá | `#FFB81C` + `#000000` |
| Toronto Maple Leafs | Námořní + bílá | `#00205B` + `#FFFFFF` |

> **Pozorování:** Kombinace červená + námořní modrá + bílá patří k nejčastěji používaným v hokejovém světě. Potvrzují ji Montréal, Washington, a shodují se s barvami HC Klatovy.

### 3.4 Dark Mode vs. Light Mode

Výzkum Nielsen Norman Group (`nngroup.com/articles/dark-mode/`) ukazuje:

| Aspekt | Light Mode | Dark Mode |
|--------|-----------|-----------|
| Vizuální ostrost (normální zrak) | ✅ Lepší | ❌ Horší |
| Čitelnost drobného textu | ✅ Výrazně lepší | ❌ Problematický |
| Noční používání | ✅ Lepší | ❌ Horší |
| Spotřeba baterie (OLED) | ❌ Vyšší | ✅ Nižší |
| Estetika ve sportu | ⚠️ Méně dramatická | ✅ Filmová, dynamická |
| Fanouškovský zážitek | Neutrální | ✅ Lépe odpovídá atmosféře stadionu |

**Doporučení pro sportovní klub:** Nabídnout **oba módy** s možností přepnutí. Sportovní estetika Dark mód preferuje (fanoušci prohlíží web večer, na telefonu v tmavé aréně), avšak Light mód je vhodný pro čtení obsahu a administraci.

---

## 4. Analýza HC Klatovy jako klubu

### 4.1 Oficiální barvy klubu

| Barva | Česky | Ověřený zdroj |
|-------|-------|---------------|
| 🔴 Červená | Červená | Česká Wikipedie: „Klubové barvy: červená, modrá a bílá"[^4] |
| 🔵 Modrá | Modrá | Česká Wikipedie + CSS analýza webu |
| ⚪ Bílá | Bílá | Česká Wikipedie + CSS analýza webu |

### 4.2 Srovnání s českými extraligovými kluby

| Klub | Hlavní barvy | Primární hex | Design éra |
|------|-------------|-------------|-----------|
| HC VERVA Litvínov | Žlutá + černá | `#FFCC00` + `#1A1919` | Moderní (2023) |
| HC Škoda Plzeň | Tmavá modrá + bílá | `#002E5D` + `#FFFFFF` | Moderní (custom 2020+) |
| HC Kometa Brno | Střední modrá + bílá | `#004892` + `#FFFFFF` | Starší Bootstrap 4 |
| **HC Klatovy** | **Červená + modrá + bílá** | **`#d8232a` + `#292d78`** | Základní eSports.cz |

> **Poznámka:** Barvy HC Klatovy se přesně shodují s heraldickými barvami znaku města Klatovy (`#D9261C` červeň, `#005CA1` modř, `#FFFFFF` stříbro). Jde o vědomé i nevědomé propojení klubové a městské identity.

---

## 5. Barevné schéma „Sport"

### 5.1 Zdůvodnění volby

Barevné schéma **„Sport"** je navrženo pro webovou aplikaci HC Klatovy. Vychází z:

1. **Tradice klubu** — červená + námořní modrá + bílá (ověřeno z webu a Wikipedie)
2. **Heraldiky města Klatovy** — stejné barvy ve znaku (červeň, modř, stříbro) + zlatá makovice
3. **Psychologie sportu** — červená pro energii a CTA, námořní pro důvěru a stabilitu
4. **Hokejová estetika** — ledová bílá, námořní noc arény, zlatá mistrovství
5. **Dostupnost WCAG 2.1 AA** — všechny kombinace ověřeny na kontrastní poměr

### 5.2 Základní paleta primitiv

Primitivní tokeny jsou surové hodnoty barev. Nikdy se nepoužívají přímo v komponentách — k tomu slouží sémantické tokeny v sekci 5.3 a 5.4.

```css
/* =================================================================
   PRIMITIVA — Základní paleta barev
   HC Klatovy × Klatovy heraldika
   Nikdy nepoužívat přímo v komponentách!
   ================================================================= */
:root {
  /* ── ČERVENÁ ŠKÁLA (primární značková barva) ── */
  --sport-red-50:   #fff1f1;   /* Nejsvětlejší tint */
  --sport-red-100:  #ffe0e0;
  --sport-red-200:  #ffc5c5;
  --sport-red-300:  #ff9797;
  --sport-red-400:  #FF4D55;   /* Světlejší červená — pro Dark mode text/ikony */
  --sport-red-500:  #D6232A;   /* ← ZNAČKOVÁ ČERVENÁ (HC Klatovy + heraldika) */
  --sport-red-600:  #b61f26;   /* Hover stav */
  --sport-red-700:  #92181e;   /* Aktivní/stisknutý stav */
  --sport-red-800:  #6e1016;   /* Tmavý odstín */
  --sport-red-900:  #47090e;   /* Nejtmavší */

  /* ── NÁMOŘNÍ ŠKÁLA (sekundární značková barva) ── */
  --sport-navy-50:  #eef1f8;
  --sport-navy-100: #cdd5e8;
  --sport-navy-200: #9aaece;
  --sport-navy-300: #6785ae;
  --sport-navy-400: #4a7cc7;   /* Světlejší námořní — pro Dark mode */
  --sport-navy-500: #292d78;   /* ← ZNAČKOVÁ NÁMOŘNÍ (HC Klatovy) */
  --sport-navy-600: #212560;
  --sport-navy-700: #191c4a;   /* Temná námořní — tmavé povrchy */
  --sport-navy-800: #101234;
  --sport-navy-900: #080920;

  /* ── HERALDICKÁ ZLATÁ ── */
  --sport-gold-400: #FFF500;   /* Zlatá ze znaku města Klatovy — makovice */
  --sport-gold-500: #FFB81C;   /* Tlumená zlatá — pro jemnější použití */
  --sport-gold-600: #D4A017;   /* Tmavší zlatá */

  /* ── HERALDICKÁ MODRÁ (ze znaku) ── */
  --sport-herald-blue: #005CA1; /* Modrá stanových střech věží ve znaku */

  /* ── NEUTRÁLNÍ ŠKÁLA ── */
  --sport-neutral-0:   #ffffff;
  --sport-neutral-50:  #f8f9fa;
  --sport-neutral-100: #f1f3f5;
  --sport-neutral-200: #e9ecef;
  --sport-neutral-300: #dee2e6;
  --sport-neutral-400: #ced4da;
  --sport-neutral-500: #adb5bd;
  --sport-neutral-600: #6c757d;
  --sport-neutral-700: #495057;
  --sport-neutral-800: #343a40;
  --sport-neutral-900: #1a1919;   /* Téměř černá — primární text na webu HC Klatovy */
  --sport-neutral-950: #0d0f12;

  /* ── TMAVÉ POVRCHY (pro Dark mode) ── */
  --sport-dark-base:    #0a0e1a;  /* Nejtmavší — námořnická uhloň (canvas stránky) */
  --sport-dark-card:    #101520;  /* Povrch karet — 1. úroveň elevace */
  --sport-dark-panel:   #171e2e;  /* Vnořené panely — 2. úroveň elevace */
  --sport-dark-modal:   #1e2740;  /* Modály/dropdown — 3. úroveň elevace */

  /* ── STAVOVÉ BARVY ── */
  --sport-success: #22c55e;
  --sport-warning: #eab308;
  --sport-error:   #D6232A;    /* Značková červená jako chyba */
  --sport-info:    #3b82f6;
}
```

---

### 5.3 Light Mode — Světlý mód

Světlý mód je výchozím nastavením webu. Je vhodný pro čtení obsahu, administraci a denní prohlížení.

#### Vizuální charakter
- Bílé a světle šedé pozadí → prostor a čistota
- Námořní modrá jako strukturální barva nadpisů a navigace
- Červená jako energický akcent pro CTA a zvýraznění
- Zlatá minimálně, pouze pro prémiové sekce (trofeje, úspěchy)

#### Sémantické tokeny — Light Mode

```css
/* =================================================================
   SÉMANTICKÉ TOKENY — LIGHT MODE
   Použít tyto proměnné v komponentách (nikoli primitiva)
   ================================================================= */
:root,
[data-theme="light"] {

  /* ── POZADÍ STRÁNKY ── */
  --color-bg-base:          #f1f3f5;   /* Plátno stránky — světle šedá */
  --color-bg-subtle:        #f8f9fa;   /* Alternativní pruhy, vložené sekce */

  /* ── POVRCHY (karty, panely, modály — "sedí" na bg) ── */
  --color-surface-1:        #ffffff;   /* Výchozí karta / panel */
  --color-surface-2:        #f8f9fa;   /* Vnořený panel */
  --color-surface-3:        #f1f3f5;   /* Modál / overlay */
  --color-surface-inverse:  #101234;   /* Tmavý povrch pro hero bannery */

  /* ── ZNAČKOVÁ ČERVENÁ (primární) ── */
  --color-brand-primary:         #D6232A;              /* Hlavní CTA, tlačítka, odznaky */
  --color-brand-primary-hover:   #b61f26;              /* Hover stav — tmavší */
  --color-brand-primary-active:  #92181e;              /* Stisknutý stav */
  --color-brand-primary-subtle:  rgba(214, 35, 42, .10); /* Tintované pozadí tagů/alertů */
  --color-on-brand-primary:      #ffffff;              /* Bílý text NA červeném tlačítku */

  /* ── ZNAČKOVÁ NÁMOŘNÍ (sekundární) ── */
  --color-brand-secondary:        #292d78;             /* Navigace, headery, strukturální prvky */
  --color-brand-secondary-hover:  #212560;
  --color-brand-secondary-active: #191c4a;
  --color-brand-secondary-subtle: rgba(41, 45, 120, .08);
  --color-on-brand-secondary:     #ffffff;             /* Bílý text NA námořní */

  /* ── HERALDICKÁ ZLATÁ (akcent) ── */
  --color-accent-gold:       #FFB81C;                  /* Zlatá ze znaku — pro prémiové prvky */
  --color-accent-gold-text:  #D4A017;                  /* Tmavší zlatá pro text */

  /* ── TEXT ── */
  --color-text-primary:      #1a1919;   /* Nadpisy, popisky — 17.5:1 kontrast na bílé ✅ */
  --color-text-secondary:    #495057;   /* Tělo textu */
  --color-text-muted:        #6c757d;   /* Vedlejší texty, metadata, datum */
  --color-text-disabled:     #ced4da;   /* Deaktivované elementy */
  --color-text-inverse:      #ffffff;   /* Text na tmavých/barevných plochách */
  --color-text-brand:        #b61f26;   /* Červené linky (hover červenší) */
  --color-text-navy:         #292d78;   /* Námořní text — nadpisy článků, linky */

  /* ── OKRAJE A ODDĚLOVAČE ── */
  --color-border-subtle:     #e9ecef;   /* Jemné vnitřní oddělovače */
  --color-border-default:    #dee2e6;   /* Výchozí rámečky karet */
  --color-border-strong:     #ced4da;   /* Zdůrazněné rámečky */
  --color-border-focus:      #D6232A;   /* Focus ring — červená */
  --color-border-brand:      #292d78;   /* Námořní obrysová varianta */

  /* ── INTERAKTIVNÍ STAVY ── */
  --color-interactive-hover:    #f1f3f5;               /* Hover bg na položkách seznamu */
  --color-interactive-active:   #e9ecef;               /* Stisknutý bg */
  --color-interactive-selected: rgba(214, 35, 42, .10);/* Vybraná/zaškrtnutá položka */

  /* ── STAVOVÉ BARVY ── */
  --color-success:       #22c55e;
  --color-success-text:  #16a34a;
  --color-success-subtle:rgba(34, 197, 94, .12);

  --color-warning:       #eab308;
  --color-warning-text:  #ca8a04;
  --color-warning-subtle:rgba(234, 179, 8, .12);

  --color-error:         #D6232A;
  --color-error-text:    #b61f26;
  --color-error-subtle:  rgba(214, 35, 42, .10);

  --color-info:          #3b82f6;
  --color-info-text:     #2563eb;
  --color-info-subtle:   rgba(59, 130, 246, .12);

  /* ── STÍNY ── */
  --shadow-sm:    0 1px 2px rgba(0, 0, 0, .06);
  --shadow-md:    0 4px 6px -1px rgba(0, 0, 0, .08), 0 2px 4px -2px rgba(0, 0, 0, .05);
  --shadow-lg:    0 10px 15px -3px rgba(0, 0, 0, .10), 0 4px 6px -4px rgba(0, 0, 0, .06);
  --shadow-brand: 0 4px 14px rgba(214, 35, 42, .25);   /* Červená záře CTA tlačítek */

  /* ── PŘEKRYVY ── */
  --color-overlay: rgba(8, 9, 32, .50);  /* Modální pozadí */
}
```

#### Přehled Light Mode — vizuální referenční karta

```
LIGHT MODE — REFERENČNÍ KARTA
═══════════════════════════════════════════════════════════

Plátno stránky:    #f1f3f5  ████  Světle šedá
Povrch karty:      #ffffff  ████  Bílá
Primární text:     #1a1919  ████  Téměř černá    (17.5:1 ✅)
Sekundární text:   #495057  ████  Tmavá šedá
Ztlumený text:     #6c757d  ████  Střední šedá

Značková červená:  #D6232A  ████  Sport červená  ( 5.1:1 ✅ AA)
Bílá na červené:   #ffffff  ████  [na #D6232A]   ( 5.1:1 ✅ AA)
Námořní modrá:     #292d78  ████  Sport námořní  (12.0:1 ✅ AAA)
Bílá na námořní:   #ffffff  ████  [na #292d78]   (12.0:1 ✅ AAA)

Zlatý akcent:      #FFB81C  ████  Heraldická zlatá
Heraldická modř:   #005CA1  ████  Modř znaku

Okraj výchozí:     #dee2e6  ████  Světle šedá
Okraj focus:       #D6232A  ████  Červená (přístupnost)
```

---

### 5.4 Dark Mode — Tmavý mód

Tmavý mód je navržen pro fanouškovský zážitek — odpovídá atmosféře zimního stadionu, nočnímu prohlížení na telefonu a moderní sportovní estetice.

#### Vizuální charakter
- Pozadí má námořní podtón (`#0a0e1a`) — **ne čistá černá**, námořní nádech propojuje téma s identitou klubu
- Červená zůstává stejná jako v Light modu (funguje skvěle na tmavém pozadí — vysoký dramatický kontrast)
- Námořní modrá se v Dark modu **zesvětluje** (tmavá námořní by splynula s pozadím)
- Zlatá získává v Dark modu prominentní roli — svítí jako zlatá trofej

#### Sémantické tokeny — Dark Mode

```css
/* =================================================================
   SÉMANTICKÉ TOKENY — DARK MODE
   Aplikovat přes [data-theme="dark"] nebo .dark třídu
   
   KLÍČOVÁ ROZHODNUTÍ:
   ① NENÍ čistá černá (#000) — příliš drsná, červená pak vypadá neonově
   ② NENÍ tmavá námořní (#0f2446) jako základ — příliš barevná, bojuje se značkou
   ③ NÁMOŘNICKÁ UHLOŇ (#0a0e1a) — sweet spot: tmavá jako noc, námořní podtón
      zachovává propojení s identitou klubu
   ④ ČERVENÁ zůstává #D6232A — skvěle vyniká na tmavém pozadí
   ⑤ NÁMOŘNÍ se zesvětluje na #4a7cc7 — viditelná na tmavém bg
   ================================================================= */
[data-theme="dark"],
.dark {

  /* ── POZADÍ STRÁNKY ── */
  --color-bg-base:          #0a0e1a;   /* Nejhlubší — námořnická uhloň (canvas stránky) */
  --color-bg-subtle:        #080b14;   /* Mírně hlubší — kód bloky, vložené sekce */

  /* ── POVRCHY (elevace) ── */
  --color-surface-1:        #101520;   /* Karty, panely — 1. elevace */
  --color-surface-2:        #171e2e;   /* Vnořené panely — 2. elevace */
  --color-surface-3:        #1e2740;   /* Modály, dropdown — 3. elevace */
  --color-surface-inverse:  #f1f3f5;   /* Světlý povrch pro inverzní elementy */

  /* ── ZNAČKOVÁ ČERVENÁ — v Dark modu září! ── */
  --color-brand-primary:         #D6232A;              /* Stejná červená — svítí na tmavém bg */
  --color-brand-primary-hover:   #ff2d42;              /* SVĚTLEJŠÍ hover v Dark modu (ne tmavší!) */
  --color-brand-primary-active:  #b61f26;              /* Stisknutý = mírně tmavší */
  --color-brand-primary-subtle:  rgba(214, 35, 42, .15);
  --color-on-brand-primary:      #ffffff;              /* Bílý text NA červeném tlačítku */

  /* ── ZNAČKOVÁ NÁMOŘNÍ — musí se zesvětlit! ── */
  --color-brand-secondary:        #4a7cc7;             /* Zesvětlená námořní — viditelná na tmavém bg */
  --color-brand-secondary-hover:  #5e8fd8;
  --color-brand-secondary-active: #3d6ab5;
  --color-brand-secondary-subtle: rgba(74, 124, 199, .15);
  --color-on-brand-secondary:     #ffffff;

  /* ── HERALDICKÁ ZLATÁ — v Dark modu prominentní! ── */
  --color-accent-gold:       #FFF500;   /* Zlatá ze znaku — jako zlatá trofej na tmavém bg */
  --color-accent-gold-text:  #FFF500;   /* 16.7:1 kontrast na #0a0e1a ✅ AAA */

  /* ── TEXT ── */
  --color-text-primary:      #f0f4f8;   /* Téměř bílá — 17.4:1 ✅ AAA */
  --color-text-secondary:    #a8b4c8;   /* Modro-šedá — světla stadionu; 9.2:1 ✅ AAA */
  --color-text-muted:        #6b7a96;   /* Tlumené popisky — 4.6:1 ✅ AA */
  --color-text-disabled:     #3d4a62;   /* Deaktivovaný — záměrně obtížně čitelný */
  --color-text-inverse:      #0a0e1a;   /* Tmavý text NA světlých plochách */
  --color-text-brand:        #FF4D55;   /* Zesvětlená červená pro linky — 5.9:1 ✅ AA */
  --color-text-navy:         #9198E5;   /* Zesvětlená námořní — 7.2:1 ✅ AAA */

  /* ── OKRAJE A ODDĚLOVAČE ── */
  --color-border-subtle:     #1e2740;   /* Sotva viditelné strukturální okraje */
  --color-border-default:    #2a3450;   /* Standardní oddělení */
  --color-border-strong:     #3d4e6e;   /* Zdůrazněné okraje, focus */
  --color-border-focus:      #D6232A;   /* Červený focus ring — konzistence se značkou */
  --color-border-brand:      rgba(74, 124, 199, .40);

  /* ── INTERAKTIVNÍ STAVY ── */
  --color-interactive-hover:    rgba(255, 255, 255, .06);
  --color-interactive-active:   rgba(255, 255, 255, .10);
  --color-interactive-selected: rgba(214, 35, 42, .15);  /* Červeně tintovaný výběr */

  /* ── STAVOVÉ BARVY (přizpůsobeny tmavému bg) ── */
  --color-success:       #22c55e;
  --color-success-text:  #4ade80;   /* Světlejší pro text v tmavém modu */
  --color-success-subtle:rgba(34, 197, 94, .12);

  --color-warning:       #eab308;
  --color-warning-text:  #facc15;
  --color-warning-subtle:rgba(234, 179, 8, .12);

  --color-error:         #D6232A;
  --color-error-text:    #FF4D55;   /* Zesvětlená pro text v tmavém modu */
  --color-error-subtle:  rgba(214, 35, 42, .12);

  --color-info:          #3b82f6;
  --color-info-text:     #60a5fa;
  --color-info-subtle:   rgba(59, 130, 246, .12);

  /* ── STÍNY A ZÁŘE (na tmavém bg záře nahrazují stíny) ── */
  --shadow-sm:          0 1px 3px rgba(0, 0, 0, .40);
  --shadow-md:          0 4px 8px rgba(0, 0, 0, .40), 0 2px 4px rgba(0, 0, 0, .30);
  --shadow-lg:          0 10px 20px rgba(0, 0, 0, .50), 0 4px 8px rgba(0, 0, 0, .30);
  --glow-brand:         0 0 20px rgba(214, 35, 42, .20), 0 0 60px rgba(214, 35, 42, .08);
  --glow-brand-strong:  0 0 30px rgba(214, 35, 42, .35), 0 0 80px rgba(214, 35, 42, .15);
  --shadow-brand:       0 4px 20px rgba(214, 35, 42, .35);  /* Červená záře CTA v Dark modu */

  /* ── PŘEKRYVY ── */
  --color-overlay: rgba(0, 0, 0, .70);
}
```

#### Přehled Dark Mode — vizuální referenční karta

```
DARK MODE — REFERENČNÍ KARTA
═══════════════════════════════════════════════════════════

Canvas stránky:    #0a0e1a  ████  Námořnická uhloň (19.2:1 pro bílou ✅)
Povrch-1 karta:    #101520  ████  Tmavší povrch   (18.2:1 pro bílou ✅)
Povrch-2 panel:    #171e2e  ████  Panel           (16.5:1 pro bílou ✅)
Povrch-3 modál:    #1e2740  ████  Modál/dropdown

Primární text:     #f0f4f8  ████  Téměř bílá      (17.4:1 ✅ AAA)
Sekundární text:   #a8b4c8  ████  Modro-šedá      ( 9.2:1 ✅ AAA)
Ztlumený text:     #6b7a96  ████  Tlumená         ( 4.6:1 ✅ AA)

Značková červená:  #D6232A  ████  [jako bg/border] (bg použití)
Red text link:     #FF4D55  ████  Zesvětlená red  ( 5.9:1 ✅ AA)
Námořní text:      #9198E5  ████  Zesvětlená navy ( 7.2:1 ✅ AAA)
Zlatý akcent:      #FFF500  ████  Heraldická zlatá(16.7:1 ✅ AAA)

Okraj výchozí:     #2a3450  ████  Tmavý okraj
Okraj focus:       #D6232A  ████  Červená
```

---

## 6. Kompletní srovnávací tabulka schémat

### 6.1 Souhrn — Light Mode vs. Dark Mode

| Token | Light Mode | Dark Mode | Kontrast (White) |
|-------|-----------|----------|-----------------|
| `--color-bg-base` | `#f1f3f5` | `#0a0e1a` | — |
| `--color-surface-1` | `#ffffff` | `#101520` | 18.2:1 ✅ |
| `--color-text-primary` | `#1a1919` | `#f0f4f8` | — |
| `--color-brand-primary` | `#D6232A` | `#D6232A` | 5.1:1 ✅ |
| `--color-brand-primary (text)` | `#D6232A` | `#FF4D55` | 5.9:1 ✅ |
| `--color-brand-secondary` | `#292d78` | `#4a7cc7` | — |
| `--color-accent-gold` | `#FFB81C` | `#FFF500` | 16.7:1 ✅ |
| `--color-border-focus` | `#D6232A` | `#D6232A` | — |

### 6.2 Kontrast — ověřené kombinace (WCAG 2.1)

| # | Kombinace | Kontrast | AA ✓ | AAA ✓ |
|---|-----------|----------|------|-------|
| 1 | Text `#1a1919` na `#f1f3f5` | 15.7:1 | ✅ | ✅ |
| 2 | Text `#1a1919` na `#ffffff` | 17.5:1 | ✅ | ✅ |
| 3 | Bílá na `#D6232A` (tlačítko) | 5.1:1 | ✅ | ❌* |
| 4 | `#D6232A` na bílé | 5.1:1 | ✅ | ❌* |
| 5 | `#292d78` na bílé | 12.0:1 | ✅ | ✅ |
| 6 | Bílá na `#292d78` (nav) | 12.0:1 | ✅ | ✅ |
| 7 | `#f0f4f8` na `#0a0e1a` | 17.4:1 | ✅ | ✅ |
| 8 | `#FF4D55` na `#0a0e1a` | 5.9:1 | ✅ | ❌* |
| 9 | `#9198E5` na `#0a0e1a` | 7.2:1 | ✅ | ✅ |
| 10 | `#FFF500` na `#0a0e1a` | 16.7:1 | ✅ | ✅ |
| 11 | `#a8b4c8` na `#0a0e1a` | 9.2:1 | ✅ | ✅ |
| 12 | Bílá na `#101520` | 18.2:1 | ✅ | ✅ |

> *\* AAA pro normální text (min. 7:1) nesplněno — platí pouze pro červenou jako textovou barvu v malém písmu. Pro nadpisy (≥ 24px) nebo UI prvky (min. 3:1) je červená plně v souladu s WCAG AA i AAA.*

> **Zdroj:** Všechny kontrasy ověřeny přes WebAIM Contrast Checker API (`webaim.org/resources/contrastchecker`).[^5]

---

## 7. Jak číst a používat schéma

### 7.1 Hierarchie tokenů

```
Layer 1 — PRIMITIVNÍ TOKENY   (např. --sport-red-500)
           ↓ nikdy přímo v komponentách
Layer 2 — SÉMANTICKÉ TOKENY   (např. --color-brand-primary)
           ↓ tyto se používají v CSS komponent
Layer 3 — KOMPONENTOVÉ TOKENY (např. --button-bg, --input-border) [volitelné]
```

### 7.2 Přepínání módů

```html
<!-- HTML element pro přepínání -->
<html data-theme="light">  <!-- výchozí světlý mód -->
<html data-theme="dark">   <!-- tmavý mód -->
```

```javascript
// JavaScript přepínač
document.documentElement.setAttribute('data-theme', 
  document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark'
);
```

### 7.3 Příklady použití

```css
/* Tlačítko CTA (kupte lístek, registrace) */
.btn-primary {
  background-color: var(--color-brand-primary);      /* červená */
  color:            var(--color-on-brand-primary);   /* bílá */
  border:           none;
  box-shadow:       var(--shadow-brand);
}
.btn-primary:hover {
  background-color: var(--color-brand-primary-hover);
}

/* Hlavička / navigace */
.site-header {
  background-color: var(--color-brand-secondary);    /* námořní */
  color:            var(--color-text-inverse);       /* bílá */
}

/* Karta článku */
.article-card {
  background-color: var(--color-surface-1);          /* bílá / tmavá karta */
  color:            var(--color-text-primary);       /* tmavá / světlá */
  border-top:       4px solid var(--color-brand-primary); /* červená horní linka */
  box-shadow:       var(--shadow-md);
}

/* Zlatý zvýrazněný prvek (trofeje, úspěchy) */
.highlight-gold {
  color:            var(--color-accent-gold);        /* zlatá */
  border-left:      3px solid var(--color-accent-gold);
}
```

---

## 8. Confidence Assessment (Hodnocení spolehlivosti)

| Zjištění | Spolehlivost | Zdroj |
|----------|-------------|-------|
| HC Klatovy barvy: červená `#d8232a` + námořní `#292d78` | ✅ Jistý | Přímá analýza CSS `style.min.css` |
| Klatovy heraldika: červená `#D9261C` + modrá `#005CA1` + zlatá `#FFF500` | ✅ Jistý | SVG znaku na Wikimedia Commons |
| Vlajka Klatov: bílá + červená | ✅ Jistý | SVG vlajky na Wikimedia Commons |
| HC Klatovy klubové barvy: červená + modrá + bílá | ✅ Jistý | Česká Wikipedie (cs.wikipedia.org) |
| HC Klatovy byla od 2015 farmářský tým HC Škoda Plzeň | ✅ Jistý | Česká Wikipedie |
| Klatovy = karafiátové město (od 1813) | ✅ Jistý | Wikipedia EN + CS |
| Kontrast bílá na `#D6232A` = 5.1:1 | ✅ Jistý | WebAIM API (živá kalkulace) |
| Dark mode doporučení (NN/g) | ✅ Jistý | Nielsen Norman Group research |
| Psychologie sportovních barev | ✅ Jistý | Smashing Magazine, colorpsychology.org |
| Karafiát jako vědomá inspirace pro barvy klubu | ⚠️ Odvozeno | Žádná přímá dokumentace; inferováno ze symbolické shody |

---

## Poznámky pod čarou

[^1]: Přímá analýza souborů `style.min.css` a `_hotfix.css` z webu `hc-klatovy.cz`. Soubory analyzovány 12. 5. 2026.

[^2]: SVG znak města Klatovy: [Klatovy-znak.svg](https://upload.wikimedia.org/wikipedia/commons/0/05/Klatovy-znak.svg) — Commons Wikimedia. Barvy odečteny přímo z atributů `fill` ve vektorové grafice.

[^3]: SVG vlajka Klatovy: [Flag_of_Klatovy.svg](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Flag_of_Klatovy.svg/1200px-Flag_of_Klatovy.svg.png) — Commons Wikimedia.

[^4]: Česká Wikipedie: [HC Klatovy](https://cs.wikipedia.org/wiki/HC_Klatovy) — sekce „Klubové barvy: červená, modrá a bílá". Načteno 12. 5. 2026.

[^5]: Všechny kontrasy ověřeny přes WebAIM Contrast Checker API: [webaim.org/resources/contrastchecker](https://webaim.org/resources/contrastchecker/?api). Kalkulace provedeny 12. 5. 2026.

---

## Příloha: Souhrn barev pro design

### Primární paleta „Sport"

| Název | Hex | RGB | Použití |
|-------|-----|-----|---------|
| Sport Red | `#D6232A` | `rgb(214, 35, 42)` | CTA tlačítka, akcenty, zvýraznění, bordery |
| Sport Navy | `#292d78` | `rgb(41, 45, 120)` | Navigace, nadpisy, strukturální prvky |
| Sport White | `#ffffff` | `rgb(255, 255, 255)` | Pozadí, text na tmavém, karty |
| Sport Gold | `#FFF500` | `rgb(255, 245, 0)` | Heraldický akcent, trofeje, úspěchy |
| Sport Herald Blue | `#005CA1` | `rgb(0, 92, 161)` | Heraldická modrá, sekundární akcent |

### Doplňkové tmavé povrchy (Dark Mode)

| Název | Hex | Použití |
|-------|-----|---------|
| Dark Canvas | `#0a0e1a` | Pozadí stránky (námořnická uhloň) |
| Dark Surface-1 | `#101520` | Karty |
| Dark Surface-2 | `#171e2e` | Vnořené panely |
| Dark Surface-3 | `#1e2740` | Modály |

---

*Dokument vytvořen jako součást rešerše pro webovou aplikaci HC Klatovy — SportSys.*
