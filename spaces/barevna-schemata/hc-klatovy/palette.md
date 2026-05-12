# Paleta — Schéma „Sport" HC Klatovy

Primitivní tokeny (surové hex hodnoty) a souhrn palety pro schéma „Sport".

> **Důležité:** Primitivní tokeny nikdy nepoužívej přímo v CSS komponent. Používej sémantické tokeny z `tokens.md`.

---

## Zdůvodnění volby barev

Barevné schéma **„Sport"** vychází z pěti pilířů:

1. **Tradice klubu** — červená + námořní modrá + bílá (ověřeno z webu a Wikipedie)
2. **Heraldika města Klatovy** — stejné barvy ve znaku (červeň, modř, stříbro) + zlatá makovice
3. **Psychologie sportu** — červená pro energii a CTA, námořní pro důvěru a stabilitu
4. **Hokejová estetika** — ledová bílá, námořní noc arény, zlatá mistrovství
5. **Dostupnost WCAG 2.1 AA** — všechny kombinace ověřeny na kontrastní poměr

---

## Primitivní tokeny

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

## Souhrn palety pro design

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

### Heraldická vazba

```
HC Klatovy web  →  #d8232a (červená)    ≈  Heraldika #D9261C (Gules)
HC Klatovy web  →  #292d78 (námořní)    ≈  Heraldika #005CA1 (Azure)
HC Klatovy web  →  #ffffff (bílá)       =  Heraldika #FFFFFF (Argent)
Heraldika znak  →  #FFF500 (zlatá)         Makovice věží — zlatý akcent
```
