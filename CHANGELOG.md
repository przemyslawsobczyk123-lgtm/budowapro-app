# Changelog

## 1.0.0 - release candidate

- Added the iOS platform target with the BudowaPRO bundle identifier, app icon
  set and iOS 15.5 deployment target.
- Added native iOS VisionKit receipt scanning, system contact selection and
  local storage capacity probing while keeping Android implementations intact.
- Added iOS local-notification permission and scheduling support.
- Added an in-app privacy and legal center with offline privacy policy, terms,
  privacy status and open-source licenses.
- Added a confirmed, phrase-protected action to delete the local database,
  project files and temporary private caches.
- Kept Android release signing and publisher metadata fail-closed; release
  artifacts still require the owner's real Play Console data and upload key.
- Added local OCR review, projects, stages, checklists, costs, contacts,
  documents, schedule, reports, capture inbox, backup and restore coverage.
- Added material, labor and mixed cost classification across manual entries,
  OCR lines, budget filters, summaries, reports and CSV exports.
- Added an OCR document-stage selector, bulk cost-component assignment and
  required per-line classification before a scanned document can affect the
  budget.
- Added project rooms with dimensions, finish standards, planned budgets,
  linked actual costs and searchable room summaries.
- Added finish choice cards with price variants, quantity, waste, order date,
  explicit selection and duplicate-safe creation of a planned material-cost
  draft, journal decision or material proposal.
- Added a compact room relation manager for existing costs, decisions,
  technical photos, defects and contractor contacts.
- Added project-scoped material records with stage, room, supplier, cost and
  receipt/invoice links; partial deliveries, shortages, damage, returns,
  expected refunds and explicit overdelivery confirmation are included.
- Added cost-to-room and cost-to-material reverse navigation, dashboard quick
  actions for technical evidence, and a reliable refresh after saving costs.
- Added a real-device Android integration smoke test and CI coverage for API
  28 and 36, plus an Xcode 26 unsigned iOS gate.
- Added deployable privacy, terms and support pages, Polish store listings,
  privacy declaration worksheets and final-size Google Play artwork.
- Separated the seven-day `Plan` from project `Etapy`, promoted stages and
  checklists to the primary navigation, and moved construction documents to
  `Więcej` while preserving the legacy `/build` route.
- Replaced primary navigation, project tools and dashboard quick-action icons
  with a consistent scalable line set based on the approved BudowaPRO mockup.
- Fixed fresh-install SQLite configuration on native Android and prevented an
  asynchronous dashboard refresh from updating a disposed controller.
