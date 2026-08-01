import 'package:budowapro/features/diary/domain/journal_entry.dart';
import 'package:budowapro/features/punch_list/domain/punch_models.dart';
import 'package:budowapro/l10n/app_localizations.dart';

String defectStatusLabel(AppLocalizations l10n, JournalEntryStatus status) {
  return switch (status) {
    JournalEntryStatus.open => l10n.punchStatusOpen,
    JournalEntryStatus.inProgress => l10n.punchStatusInProgress,
    JournalEntryStatus.recheck => l10n.punchStatusRecheck,
    JournalEntryStatus.fixed => l10n.punchStatusFixed,
    JournalEntryStatus.closed => l10n.punchStatusClosed,
    JournalEntryStatus.draft ||
    JournalEntryStatus.proposal ||
    JournalEntryStatus.pending ||
    JournalEntryStatus.approved ||
    JournalEntryStatus.rejected ||
    JournalEntryStatus.implemented => status.name,
  };
}

String defectSeverityLabel(AppLocalizations l10n, DefectSeverity severity) {
  return switch (severity) {
    DefectSeverity.low => l10n.punchSeverityLow,
    DefectSeverity.medium => l10n.punchSeverityMedium,
    DefectSeverity.high => l10n.punchSeverityHigh,
    DefectSeverity.critical => l10n.punchSeverityCritical,
  };
}

String acceptanceProtocolStatusLabel(
  AppLocalizations l10n,
  AcceptanceProtocolStatus status,
) {
  return switch (status) {
    AcceptanceProtocolStatus.draft => l10n.protocolStatusDraft,
    AcceptanceProtocolStatus.finalized => l10n.protocolStatusFinalized,
    AcceptanceProtocolStatus.signed => l10n.protocolStatusSigned,
  };
}
