# Obecné principy — Barevná schémata pro sportovní weby

Tento dokument obsahuje obecné principy platné pro **všechna barevná schémata** v tomto prostoru. Jsou nezávislé na konkrétním klubu nebo schématu.

---

## 1. Psychologie barev ve sportovním webdesignu

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

### Hokejová specifika barev

| Barva | Hokejová asociace | Proč funguje |
|-------|-------------------|--------------|
| **Tmavá námořní** | Zimní stadion v noci, autorita, tradice | Hluboká, filmová, důvěryhodná |
| **Ledová modrá** | Povrch ledu, rychlost, čistota | Barva čerstvě upraveného ledu Zamboni |
| **Bílá** | Plocha ledu, linie rychlosti | Symbolizuje led a hru |
| **Červená** | Krevní sport, soupeření, góly, energie | Univerzální sportovní agresivita |
| **Zlatá** | Trofej, mistrovství, aspirace | Prémiový aspirační pocit |
| **Stříbrná** | Brusle, hokejky, mistrovské vybavení | Metalická modernost |

### Ověřené kombinace NHL klubů

| Klub | Barvy | Hex hodnoty |
|------|-------|-------------|
| Detroit Red Wings | Červená + bílá | `#CE1126` + `#FFFFFF` |
| Montréal Canadiens | Červená + námořní + bílá | `#AF1E2D` + `#192168` + `#FFFFFF` |
| Washington Capitals | Námořní + červená + bílá | `#041E42` + `#C8102E` + `#FFFFFF` |
| Boston Bruins | Zlatá + černá | `#FFB81C` + `#000000` |
| Toronto Maple Leafs | Námořní + bílá | `#00205B` + `#FFFFFF` |

> **Pozorování:** Kombinace červená + námořní modrá + bílá patří k nejčastěji používaným v hokejovém světě.

---

## 2. Dark Mode vs. Light Mode

Výzkum Nielsen Norman Group ukazuje:

| Aspekt | Light Mode | Dark Mode |
|--------|-----------|-----------|
| Vizuální ostrost (normální zrak) | ✅ Lepší | ❌ Horší |
| Čitelnost drobného textu | ✅ Výrazně lepší | ❌ Problematický |
| Noční používání | ✅ Lepší | ❌ Horší |
| Spotřeba baterie (OLED) | ❌ Vyšší | ✅ Nižší |
| Estetika ve sportu | ⚠️ Méně dramatická | ✅ Filmová, dynamická |
| Fanouškovský zážitek | Neutrální | ✅ Lépe odpovídá atmosféře stadionu |

**Doporučení pro sportovní klub:** Nabídnout **oba módy** s možností přepnutí. Sportovní estetika Dark mód preferuje (fanoušci prohlíží web večer, na telefonu v tmavé aréně), avšak Light mód je vhodný pro čtení obsahu a administraci.

### Klíčová pravidla Dark Mode

- **Nepoužívej čistou černou** (`#000`) jako pozadí — příliš drsná, akcentové barvy pak vypadají neonově
- **Zesvětluj tmavé barvy** — pokud je primární barva tmavá (např. námořní modrá), v dark modu ji odsvětli, aby byla viditelná na tmavém pozadí
- **Záře (glow) nahrazují stíny** — na tmavém pozadí `box-shadow` se stínem nahraď září (`glow`) v barvě značky
- Akcentové barvy (červená, zlatá) zpravidla fungují beze změny — vynikají na tmavém pozadí

---

## 3. Architektura tokenů

Všechna schémata v tomto prostoru používají tříúrovňovou hierarchii tokenů:

```
Layer 1 — PRIMITIVNÍ TOKENY   (např. --sport-red-500)
           ↓ nikdy přímo v komponentách
Layer 2 — SÉMANTICKÉ TOKENY   (např. --color-brand-primary)
           ↓ tyto se používají v CSS komponent
Layer 3 — KOMPONENTOVÉ TOKENY (např. --button-bg, --input-border) [volitelné]
```

### Primitivní tokeny

- Surové hodnoty barev bez kontextu
- Prefix schématu: `--{schema}-{barva}-{číslo}` (např. `--sport-red-500`)
- **Nikdy** se nepoužívají přímo v CSS komponent
- Tvoří základ pro sémantické tokeny

### Sémantické tokeny

- Mají kontextový název — říkají **co** dělají, ne **jakou barvu** mají
- Prefix `--color-` pro všechna schémata (sdílený namespace)
- Kategorie:
  - `--color-bg-*` — pozadí stránky
  - `--color-surface-*` — povrchy (karty, panely, modály)
  - `--color-brand-*` — značkové barvy (primární, sekundární)
  - `--color-text-*` — texty a nadpisy
  - `--color-border-*` — okraje a oddělovače
  - `--color-interactive-*` — interaktivní stavy
  - `--color-accent-*` — doplňkové akcenty
  - `--color-success/warning/error/info` — stavové barvy

---

## 4. Přístupnost — WCAG 2.1

Všechna schémata musí splňovat minimálně úroveň **WCAG 2.1 AA**.

| Typ prvku | Minimální kontrast (AA) | Minimální kontrast (AAA) |
|-----------|------------------------|--------------------------|
| Normální text (< 24px / < 18px bold) | **4,5:1** | 7:1 |
| Velký text (≥ 24px nebo ≥ 18px bold) | **3:1** | 4,5:1 |
| UI komponenty a grafika | **3:1** | — |

### Ověření kontrastu

Doporučené nástroje:
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) — webový nástroj i API
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/) — desktop aplikace
- [Who Can Use](https://www.whocanuse.com/) — simulace různých typů zrakových vad

### Focus stavy

- Každý interaktivní prvek musí mít viditelný focus ring
- Doporučeno: `--color-border-focus` v barvě primární značky (červená) — konzistentní se schématem
- Focus ring musí mít kontrast min. 3:1 vůči okolnímu prostředí
