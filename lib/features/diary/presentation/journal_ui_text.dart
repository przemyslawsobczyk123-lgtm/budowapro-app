import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String journalTypeLabel(AppLocalizations l10n, JournalEntryType type) {
  return switch (type) {
    JournalEntryType.daily => l10n.journalTypeDaily,
    JournalEntryType.note => l10n.journalTypeNote,
    JournalEntryType.decision => l10n.journalTypeDecision,
    JournalEntryType.defect => l10n.journalTypeDefect,
    JournalEntryType.scopeChange => l10n.journalTypeScopeChange,
  };
}

String journalStatusLabel(AppLocalizations l10n, JournalEntryStatus status) {
  return switch (status) {
    JournalEntryStatus.draft => l10n.journalStatusDraft,
    JournalEntryStatus.open => l10n.journalStatusOpen,
    JournalEntryStatus.inProgress => l10n.journalStatusInProgress,
    JournalEntryStatus.proposal => l10n.journalStatusProposal,
    JournalEntryStatus.pending => l10n.journalStatusPending,
    JournalEntryStatus.approved => l10n.journalStatusApproved,
    JournalEntryStatus.rejected => l10n.journalStatusRejected,
    JournalEntryStatus.implemented => l10n.journalStatusImplemented,
    JournalEntryStatus.recheck => l10n.journalStatusRecheck,
    JournalEntryStatus.fixed => l10n.journalStatusFixed,
    JournalEntryStatus.closed => l10n.journalStatusClosed,
  };
}

String journalRevisionActionLabel(AppLocalizations l10n, String action) {
  return switch (action) {
    'created' => l10n.journalRevisionCreated,
    'status_changed' => l10n.journalRevisionStatusChanged,
    _ => l10n.journalRevisionUpdated,
  };
}

IconData journalTypeIcon(JournalEntryType type) {
  return switch (type) {
    JournalEntryType.daily => Icons.today_outlined,
    JournalEntryType.note => Icons.notes_outlined,
    JournalEntryType.decision => Icons.alt_route_rounded,
    JournalEntryType.defect => Icons.build_circle_outlined,
    JournalEntryType.scopeChange => Icons.compare_arrows_rounded,
  };
}
