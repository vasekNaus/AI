# 01 — Před návrhem: Checklist

> Platí pro: SQL Server 2017–2022 · EF Core 7+ · ASP.NET Core

**Databázový design je nejdražší věc na změnu. Udělej ho správně hned.**

Před napsáním prvního `CREATE TABLE` odpověz na tyto otázky:

---

## Povinné otázky

```
□ Mám definované domény (bounded contexts)?
    → Každá doména dostane vlastní schéma (helpdesk, hr, billing, crm …)

□ Jasný tenant model?
    → Single-tenant: Customer_Id na tabulkách
    → Multi-tenant: + Row-Level Security (security schéma)

□ Dědičnostní hierarchie — IS-A nebo HAS-A?
    → IS-A (Pes je Zvíře)      → TPC / TPT / TPH dle vzoru
    → HAS-A nebo per-domain    → 1:1 relace (není dědičnost!)

□ Přístupové vzory?
    → Kdo dotazuje co, jak často, s jakými filtry
    → OLTP (řádkové indexy) vs. OLAP/reporting (columnstore)

□ Platnostní data nebo auditní trail?
    → ValidFrom/ValidTo pro business validity
    → Temporal Tables (SYSTEM_VERSIONING) pro úplnou historii změn

□ EF Core dědičnostní strategie?
    → TPC (preferováno) / TPH / TPT / 1:1

□ Jak se generují ID?
    → IDENTITY(1,1)    — standard
    → SEQUENCE + HiLo  — TPC hierarchie (globálně unikátní přes tabulky)
    → NEWSEQUENTIALID() — GUID bez fragmentace
```

---

## Rychlé rozhodnutí: dědičnost

```
Je to IS-A vztah?
├── NE  → HasOne/WithOne (1:1 relace)
└── ANO →
    Dotazuješ vždy konkrétní typ?
    ├── ANO → TPC  (preferováno)
    ├── Polymorfní dotazy + malá hierarchie → TPH
    └── Base tabulka je FK target → TPT
```

---

## Přechod na další kroky

Po zodpovězení otázek pokračuj v tomto pořadí:

1. **02** — Konfigurace databáze
2. **03** — Schémata a naming konvence
3. **04** — Datové typy a primární klíče
4. **05** — Cizí klíče a indexy
5. **06** — Dědičnost (TPC / TPT / TPH)
6. **07** — Stored procedures
7. **08** — ValidFrom/ValidTo pattern
8. **09** — Bezpečnost (RLS, DDM)
9. **10** — EF Core integrace a migrace
10. **11** — Anti-patterns (zkontroluj!)
11. **12** — Deployment checklist
