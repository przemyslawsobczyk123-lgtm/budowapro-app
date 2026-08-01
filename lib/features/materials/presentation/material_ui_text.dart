import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/l10n/app_localizations.dart';

String materialStatusLabel(AppLocalizations l10n, MaterialStatus value) =>
    switch (value) {
      MaterialStatus.planned => l10n.materialStatusPlanned,
      MaterialStatus.ordered => l10n.materialStatusOrdered,
      MaterialStatus.partiallyDelivered =>
        l10n.materialStatusPartiallyDelivered,
      MaterialStatus.delivered => l10n.materialStatusDelivered,
      MaterialStatus.delayed => l10n.materialStatusDelayed,
      MaterialStatus.returned => l10n.materialStatusReturned,
    };

String formatMaterialQuantity(MaterialQuantity value) {
  final digits = value.unscaledValue.toString().padLeft(value.scale + 1, '0');
  if (value.scale == 0) return digits;
  final split = digits.length - value.scale;
  return '${digits.substring(0, split)},${digits.substring(split)}';
}
