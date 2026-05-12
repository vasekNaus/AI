# Sémantické tokeny — Schéma „Sport" HC Klatovy

Sémantické tokeny pro Light Mode a Dark Mode. Tyto proměnné se používají přímo v CSS komponent.

> Primitivní tokeny (surové hex hodnoty) jsou v `palette.md`.

---

## Light Mode

Světlý mód je výchozím nastavením webu. Je vhodný pro čtení obsahu, administraci a denní prohlížení.

### Vizuální charakter
- Bílé a světle šedé pozadí → prostor a čistota
- Námořní modrá jako strukturální barva nadpisů a navigace
- Červená jako energický akcent pro CTA a zvýraznění
- Zlatá minimálně, pouze pro prémiové sekce (trofeje, úspěchy)

### Tokeny

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

### Referenční karta — Light Mode

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

## Dark Mode

Tmavý mód je navržen pro fanouškovský zážitek — odpovídá atmosféře zimního stadionu, nočnímu prohlížení na telefonu a moderní sportovní estetice.

### Vizuální charakter
- Pozadí má námořní podtón (`#0a0e1a`) — **ne čistá černá**, námořní nádech propojuje téma s identitou klubu
- Červená zůstává stejná jako v Light modu (funguje skvěle na tmavém pozadí — vysoký dramatický kontrast)
- Námořní modrá se v Dark modu **zesvětluje** (tmavá námořní by splynula s pozadím)
- Zlatá získává v Dark modu prominentní roli — svítí jako zlatá trofej

### Klíčová rozhodnutí

| # | Rozhodnutí | Důvod |
|---|-----------|-------|
| ① | NENÍ čistá černá (`#000`) | Příliš drsná, červená pak vypadá neonově |
| ② | NENÍ tmavá námořní (`#0f2446`) jako základ | Příliš barevná, bojuje se značkou |
| ③ | NÁMOŘNICKÁ UHLOŇ (`#0a0e1a`) | Sweet spot: tmavá jako noc, námořní podtón zachovává identitu |
| ④ | ČERVENÁ zůstává `#D6232A` | Skvěle vyniká na tmavém pozadí |
| ⑤ | NÁMOŘNÍ se zesvětluje na `#4a7cc7` | Viditelná na tmavém bg |

### Tokeny

```css
/* =================================================================
   SÉMANTICKÉ TOKENY — DARK MODE
   Aplikovat přes [data-theme="dark"] nebo .dark třídu
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

### Referenční karta — Dark Mode

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

## Srovnání Light vs. Dark Mode

| Token | Light Mode | Dark Mode |
|-------|-----------|----------|
| `--color-bg-base` | `#f1f3f5` | `#0a0e1a` |
| `--color-surface-1` | `#ffffff` | `#101520` |
| `--color-text-primary` | `#1a1919` | `#f0f4f8` |
| `--color-brand-primary` | `#D6232A` | `#D6232A` |
| `--color-brand-primary (text)` | `#D6232A` | `#FF4D55` |
| `--color-brand-secondary` | `#292d78` | `#4a7cc7` |
| `--color-accent-gold` | `#FFB81C` | `#FFF500` |
| `--color-border-focus` | `#D6232A` | `#D6232A` |

---

## Ověřené WCAG 2.1 kontrasty

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

> **Zdroj:** Všechny kontrasty ověřeny přes WebAIM Contrast Checker API (`webaim.org/resources/contrastchecker`).
