# Použití — Schéma „Sport" HC Klatovy

Jak implementovat schéma „Sport" v CSS a HTML.

> Sémantické tokeny jsou v `tokens.md`. Primitivní tokeny jsou v `palette.md`.

---

## Přepínání módů

### HTML atribut

```html
<!-- Světlý mód (výchozí) -->
<html data-theme="light">

<!-- Tmavý mód -->
<html data-theme="dark">
```

### JavaScript přepínač

```javascript
document.documentElement.setAttribute(
  'data-theme',
  document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark'
);
```

### Respektování systémové preference

```css
/* Automatické přepnutí podle OS preference */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    /* sem zkopíruj tokeny z dark mode sekce v tokens.md */
  }
}
```

---

## Příklady použití v CSS

### Primární tlačítko (CTA)

```css
.btn-primary {
  background-color: var(--color-brand-primary);      /* červená */
  color:            var(--color-on-brand-primary);   /* bílá */
  border:           none;
  box-shadow:       var(--shadow-brand);
}
.btn-primary:hover {
  background-color: var(--color-brand-primary-hover);
}
.btn-primary:focus-visible {
  outline: 3px solid var(--color-border-focus);
  outline-offset: 2px;
}
```

### Hlavička / navigace

```css
.site-header {
  background-color: var(--color-brand-secondary);    /* námořní */
  color:            var(--color-text-inverse);       /* bílá */
}
```

### Karta článku

```css
.article-card {
  background-color: var(--color-surface-1);          /* bílá / tmavá karta */
  color:            var(--color-text-primary);       /* tmavá / světlá */
  border-top:       4px solid var(--color-brand-primary); /* červená horní linka */
  box-shadow:       var(--shadow-md);
}
```

### Zlatý zvýrazněný prvek (trofeje, úspěchy)

```css
.highlight-gold {
  color:            var(--color-accent-gold);        /* zlatá */
  border-left:      3px solid var(--color-accent-gold);
}
```

### Sekundární tlačítko (námořní)

```css
.btn-secondary {
  background-color: var(--color-brand-secondary);
  color:            var(--color-on-brand-secondary);
}
.btn-secondary:hover {
  background-color: var(--color-brand-secondary-hover);
}
```

### Stavová zpráva (chyba)

```css
.alert-error {
  background-color: var(--color-error-subtle);
  color:            var(--color-error-text);
  border:           1px solid var(--color-error);
}
```

### Odkaz v obsahu

```css
a {
  color:           var(--color-text-brand);          /* tmavší červená v light, zesvětlená v dark */
  text-decoration: underline;
}
a:hover {
  color:           var(--color-brand-primary);
}
```

---

## Pravidla a doporučení

- **Nikdy** nepoužívej primitivní tokeny (`--sport-red-500`) v CSS komponent — použij sémantické tokeny (`--color-brand-primary`)
- Pro červenou jako barvu textu v malém písmu (<24px, <18px bold) si ověř kontrast — splňuje AA (5.1:1), ale ne AAA
- Zlatou (`--color-accent-gold`) používej střídmě — pouze pro prémiové prvky, trofeje, vyznamenání
- V Dark modu hover stav tlačítek je **světlejší** (ne tmavší jako v Light modu) — `--color-brand-primary-hover` je `#ff2d42`
- Záře (`--glow-brand`, `--glow-brand-strong`) používej místo stínů v Dark modu pro hero sekce a featured karty
