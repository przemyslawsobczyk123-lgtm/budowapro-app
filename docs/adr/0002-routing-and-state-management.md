# ADR 0002: Routing and state management

## Status

Accepted

## Date

2026-07-15

## Context

BudowaPRO has five primary tabs: Start, Plan, Budzet, Budowa, and Wiecej. Each tab must preserve its navigation stack and screen state while users switch between project workflows. Detailed screens must support predictable system back navigation and deep links. UI state also needs testable ownership outside widgets.

## Decision

- Use `go_router` for declarative routing, nested navigation, deep links, and back behavior.
- Implement the five primary tabs with `StatefulShellRoute.indexedStack`. Each branch owns a navigator and retains its tab stack through an `IndexedStack`.
- Use `flutter_riverpod` for dependency injection and presentation state.
- Keep these responsibilities separate:
  - View: renders immutable state and dispatches user actions. It contains no business logic, SQL, filesystem, or plugin calls.
  - ViewModel: owns presentation state and coordinates domain use cases. It exposes loading, empty, error, and data states.
  - Repository: exposes domain-facing data contracts; data-layer implementations coordinate persistence and queries.
  - Service: wraps SQLite setup, filesystem operations, plugins, and Android platform capabilities behind focused interfaces.
- Views depend on ViewModels. ViewModels depend on domain use cases and contracts, not concrete data or platform implementations.

## Consequences

- Switching tabs preserves scroll position, local state, and nested navigation history.
- Route definitions and tab branch ownership must remain centralized and covered by navigation tests.
- Riverpod providers form the composition boundary for ViewModels, repositories, and services.
- Stateful tab branches consume more memory than rebuilding a single navigator, accepted for predictable navigation and fast tab switching.

## Alternatives Considered

### Single Navigator with manual tab state

Rejected. Preserving five independent stacks and system back behavior would require custom coordination already provided by `StatefulShellRoute`.

### Navigator API without go_router

Rejected. Manual route parsing, nested navigation, and deep-link handling add unnecessary application code.

### Stateful widgets as the main state layer

Rejected. Business and persistence coordination would leak into views and become harder to test and reuse.
