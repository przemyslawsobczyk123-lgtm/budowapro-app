import 'package:budowapro/features/quotes/domain/contractor_quote.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String quoteStatusLabel(
  AppLocalizations l10n,
  ContractorQuote quote, {
  DateTime? now,
}) {
  if (quote.isExpiredAt(now ?? DateTime.now())) {
    return l10n.quoteStatusExpired;
  }
  return switch (quote.status) {
    ContractorQuoteStatus.received => l10n.quoteStatusReceived,
    ContractorQuoteStatus.accepted => l10n.quoteStatusAccepted,
    ContractorQuoteStatus.rejected => l10n.quoteStatusRejected,
  };
}

String quoteStatusFilterLabel(
  AppLocalizations l10n,
  ContractorQuoteStatus value,
) => switch (value) {
  ContractorQuoteStatus.received => l10n.quoteStatusReceived,
  ContractorQuoteStatus.accepted => l10n.quoteStatusAccepted,
  ContractorQuoteStatus.rejected => l10n.quoteStatusRejected,
};

Color quoteStatusColor(ColorScheme colors, ContractorQuote quote) {
  if (quote.isExpiredAt(DateTime.now())) return colors.error;
  return switch (quote.status) {
    ContractorQuoteStatus.received => colors.primary,
    ContractorQuoteStatus.accepted => colors.tertiary,
    ContractorQuoteStatus.rejected => colors.outline,
  };
}

String quotePresenceLabel(AppLocalizations l10n, QuoteScopePresence presence) =>
    switch (presence) {
      QuoteScopePresence.included => l10n.quotePresenceIncluded,
      QuoteScopePresence.excluded => l10n.quotePresenceExcluded,
      QuoteScopePresence.notSpecified => l10n.quotePresenceNotSpecified,
    };

IconData quotePresenceIcon(QuoteScopePresence presence) => switch (presence) {
  QuoteScopePresence.included => Icons.check_circle_outline,
  QuoteScopePresence.excluded => Icons.remove_circle_outline,
  QuoteScopePresence.notSpecified => Icons.help_outline,
};
