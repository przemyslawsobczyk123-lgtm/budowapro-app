# ADR 0001: Local-first Clean Architecture

## Status

Accepted

## Date

2026-07-15

## Context

BudowaPRO stores budgets, schedules, contacts, documents, photos, and construction records. This information is private and must remain useful without an account or network connection. The MVP also needs predictable delivery without the cost and failure modes of authentication, synchronization, and backend operations.

## Decision

BudowaPRO will use a local-first Clean Architecture organized by feature.

- SQLite is the source of truth for structured data, relationships, migrations, and transactional updates.
- The application filesystem stores original attachments, previews, and generated exports. SQLite stores metadata and relative file references.
- Presentation renders state and sends user intent. Domain owns entities, value objects, use cases, validation, and repository contracts. Data implements repositories and owns SQLite, files, plugins, and Android integrations.
- The MVP has no backend, account, synchronization, or automatic upload. Export, sharing, and backup happen only after an explicit user action.

## Consequences

- Core workflows work offline and private data stays on the device by default.
- Database migrations, transactional file operations, backup, restore, and device storage limits require dedicated tests.
- Repository and service boundaries allow a future synchronization or cloud adapter without adding network concerns to domain or presentation code.
- Multi-device collaboration and server recovery are outside MVP scope and require a separate ADR.

## Alternatives Considered

### Backend-first storage

Rejected for MVP. It would require accounts, connectivity, hosting, privacy controls, synchronization, and operational support before local workflows deliver value.

### Files without SQLite

Rejected. Budgets, links, filters, aggregates, migrations, and atomic updates need structured transactional storage.

### SQLite blobs for all attachments

Rejected. Large photos and documents are better handled as files, while SQLite retains searchable metadata and relationships.
