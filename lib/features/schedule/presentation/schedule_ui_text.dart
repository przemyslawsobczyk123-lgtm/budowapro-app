import 'package:budowapro/features/schedule/domain/schedule_event.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String scheduleKindLabel(AppLocalizations l10n, ScheduleEventKind kind) =>
    switch (kind) {
      ScheduleEventKind.task => l10n.scheduleKindTask,
      ScheduleEventKind.visit => l10n.scheduleKindVisit,
      ScheduleEventKind.delivery => l10n.scheduleKindDelivery,
      ScheduleEventKind.acceptance => l10n.scheduleKindAcceptance,
      ScheduleEventKind.payment => l10n.scheduleKindPayment,
    };

IconData scheduleKindIcon(ScheduleEventKind kind) => switch (kind) {
  ScheduleEventKind.task => Icons.task_alt_rounded,
  ScheduleEventKind.visit => Icons.groups_outlined,
  ScheduleEventKind.delivery => Icons.local_shipping_outlined,
  ScheduleEventKind.acceptance => Icons.fact_check_outlined,
  ScheduleEventKind.payment => Icons.payments_outlined,
};

String scheduleStatusLabel(AppLocalizations l10n, ScheduleEventStatus status) =>
    switch (status) {
      ScheduleEventStatus.planned => l10n.scheduleStatusPlanned,
      ScheduleEventStatus.inProgress => l10n.scheduleStatusInProgress,
      ScheduleEventStatus.blocked => l10n.scheduleStatusBlocked,
      ScheduleEventStatus.completed => l10n.scheduleStatusCompleted,
      ScheduleEventStatus.cancelled => l10n.scheduleStatusCancelled,
    };

String scheduleLeadLabel(AppLocalizations l10n, int minutes) {
  if (minutes == 0) return l10n.scheduleLeadAtTime;
  if (minutes % 1440 == 0) return l10n.scheduleLeadDays(minutes ~/ 1440);
  if (minutes % 60 == 0) return l10n.scheduleLeadHours(minutes ~/ 60);
  return l10n.scheduleLeadMinutes(minutes);
}

Color scheduleStatusColor(ColorScheme colors, ScheduleEventStatus status) {
  return switch (status) {
    ScheduleEventStatus.blocked => colors.error,
    ScheduleEventStatus.completed => colors.primary,
    ScheduleEventStatus.cancelled => colors.outline,
    ScheduleEventStatus.inProgress => colors.tertiary,
    ScheduleEventStatus.planned => colors.onSurfaceVariant,
  };
}
