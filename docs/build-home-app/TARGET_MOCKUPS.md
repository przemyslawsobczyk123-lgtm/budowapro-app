# Target Mockups: BudowaPro

## File

Open:

```text
docs/build-home-app-mockups/index.html
```

The mockups are a static, clickable prototype. They model the target product direction, not only the smallest MVP.

Verification:

```bash
node docs/build-home-app-mockups/verify.mjs
node --check docs/build-home-app-mockups/app.js
```

## Compact Navigation

The final mobile app uses only five primary tabs:

1. **Start** - today, risks, visits, quick capture and assistant.
2. **Plan** - stages, schedule, checklist, diary and decisions.
3. **Budzet** - costs, OCR, quotes, orders, returns and forecast.
4. **Budowa** - technical photos, plans, documents, defects and warranties.
5. **Wiecej** - rooms, contacts, calculators, reports, home record and settings.

The left rail in the prototype is a presentation index for reviewing every detailed screen. It is not the proposed mobile navigation.

## Screens

1. **Start** - project dashboard, budget state, critical stage risks, today's work.
2. **Koszty** - searchable cost register with filters, totals, status warnings.
3. **Dodaj** - manual cost form with stage, category, vendor, VAT, note and local attachment.
4. **Skan OCR** - receipt scan and OCR review before saving cost items.
5. **Etapy** - stage timeline and `Stan 0` checklist with high-risk tasks.
6. **Ekipy** - contacts, site visits and quote comparison.
7. **Dokumenty** - receipts, invoices, photos and warranties linked to costs/checklists.
8. **Techniczne** - stage photo albums, installation evidence, as-built maps and protocols.
9. **Pomieszczenia** - room-level renovation budget, finish choices and measurements.
10. **Zakupy** - material orders, deliveries, returns and quantity calculators.
11. **Odbiory** - punch list, defects, acceptance notes and warranty issues.
12. **Raporty** - budget vs actual, stage totals, export actions.
13. **Ustawienia** - local-first privacy, OCR and export controls.
14. **Wiecej** - compact hub for secondary tools without adding bottom tabs.
15. **Dziennik** - daily site log, decisions, change impact and approval history.
16. **Asystent** - offline risk checks plus clearly separated optional AI suggestions.
17. **Karta domu** - equipment, warranties, service reminders and permanent property record.

## UX Principles

- User reaches add cost or scan receipt in 1 tap from dashboard.
- Costs are structured records, not spreadsheet rows.
- OCR never changes budget without confirmation.
- Stage checklist items can hold evidence and risk.
- Documents are local and linked to decisions, not just stored in a folder.
- Every stage can have photo albums tagged by room, installation type and date.
- Technical photos help return to hidden installations after plaster, screed or backfill.
- Room mode supports renovations where decisions are grouped by bathroom, kitchen, salon, etc.
- Material tracking covers deliveries, partial delivery, leftovers and returns.
- Punch list records every defect with photo, responsible contact, due date and status.
- Reports answer investor questions without forcing Excel.
- A universal capture action creates a draft before classification.
- Decision changes show cost and schedule delta.
- Photos and defects can be pinned to a simple floor plan.
- Project health always explains the warnings behind its score.
- The same data remains useful after handover as a home record.
- Assistant actions create drafts and suggestions, never silent approvals or budget changes.

## Scope Notes

- No account in MVP.
- No backend in MVP.
- No automatic document upload.
- No receipt/contact/document telemetry.
- Collaboration and cloud sync are post-MVP decisions.
