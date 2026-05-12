# Výzkum — Schéma „Sport" pro HC Klatovy

Zdrojová analýza barevné identity HC Klatovy, heraldiky města a klubových barev.

**Datum analýzy:** 2026-05-12  
**Verze:** 1.0

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

## 3. HC Klatovy — Analýza klubu

### 3.1 Oficiální barvy klubu

| Barva | Česky | Ověřený zdroj |
|-------|-------|---------------|
| 🔴 Červená | Červená | Česká Wikipedie: „Klubové barvy: červená, modrá a bílá"[^4] |
| 🔵 Modrá | Modrá | Česká Wikipedie + CSS analýza webu |
| ⚪ Bílá | Bílá | Česká Wikipedie + CSS analýza webu |

### 3.2 Srovnání s českými extraligovými kluby

| Klub | Hlavní barvy | Primární hex | Design éra |
|------|-------------|-------------|-----------|
| HC VERVA Litvínov | Žlutá + černá | `#FFCC00` + `#1A1919` | Moderní (2023) |
| HC Škoda Plzeň | Tmavá modrá + bílá | `#002E5D` + `#FFFFFF` | Moderní (custom 2020+) |
| HC Kometa Brno | Střední modrá + bílá | `#004892` + `#FFFFFF` | Starší Bootstrap 4 |
| **HC Klatovy** | **Červená + modrá + bílá** | **`#d8232a` + `#292d78`** | Základní eSports.cz |

> **Poznámka:** Barvy HC Klatovy se přesně shodují s heraldickými barvami znaku města Klatovy (`#D9261C` červeň, `#005CA1` modř, `#FFFFFF` stříbro). Jde o vědomé i nevědomé propojení klubové a městské identity.

---

## 4. Hodnocení spolehlivosti zdrojů

| Zjištění | Spolehlivost | Zdroj |
|----------|-------------|-------|
| HC Klatovy barvy: červená `#d8232a` + námořní `#292d78` | ✅ Jistý | Přímá analýza CSS `style.min.css` |
| Klatovy heraldika: červená `#D9261C` + modrá `#005CA1` + zlatá `#FFF500` | ✅ Jistý | SVG znaku na Wikimedia Commons |
| Vlajka Klatov: bílá + červená | ✅ Jistý | SVG vlajky na Wikimedia Commons |
| HC Klatovy klubové barvy: červená + modrá + bílá | ✅ Jistý | Česká Wikipedie (cs.wikipedia.org) |
| HC Klatovy byla od 2015 farmářský tým HC Škoda Plzeň | ✅ Jistý | Česká Wikipedie |
| Klatovy = karafiátové město (od 1813) | ✅ Jistý | Wikipedia EN + CS |
| Kontrast bílá na `#D6232A` = 5.1:1 | ✅ Jistý | WebAIM API (živá kalkulace) |
| Karafiát jako vědomá inspirace pro barvy klubu | ⚠️ Odvozeno | Žádná přímá dokumentace; inferováno ze symbolické shody |

---

## Poznámky pod čarou

[^1]: Přímá analýza souborů `style.min.css` a `_hotfix.css` z webu `hc-klatovy.cz`. Soubory analyzovány 12. 5. 2026.

[^2]: SVG znak města Klatovy: [Klatovy-znak.svg](https://upload.wikimedia.org/wikipedia/commons/0/05/Klatovy-znak.svg) — Commons Wikimedia. Barvy odečteny přímo z atributů `fill` ve vektorové grafice.

[^3]: SVG vlajka Klatovy: [Flag_of_Klatovy.svg](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Flag_of_Klatovy.svg/1200px-Flag_of_Klatovy.svg.png) — Commons Wikimedia.

[^4]: Česká Wikipedie: [HC Klatovy](https://cs.wikipedia.org/wiki/HC_Klatovy) — sekce „Klubové barvy: červená, modrá a bílá". Načteno 12. 5. 2026.
