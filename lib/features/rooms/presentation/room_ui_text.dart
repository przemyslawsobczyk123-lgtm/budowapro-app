import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/l10n/app_localizations.dart';

String roomStandardLabel(AppLocalizations l10n, RoomStandard value) =>
    switch (value) {
      RoomStandard.basic => l10n.roomStandardBasic,
      RoomStandard.standard => l10n.roomStandardStandard,
      RoomStandard.elevated => l10n.roomStandardElevated,
      RoomStandard.custom => l10n.roomStandardCustom,
    };

String roomChoiceStatusLabel(AppLocalizations l10n, RoomChoiceStatus value) =>
    switch (value) {
      RoomChoiceStatus.open => l10n.roomChoiceStatusOpen,
      RoomChoiceStatus.selected => l10n.roomChoiceStatusSelected,
      RoomChoiceStatus.cancelled => l10n.roomChoiceStatusCancelled,
    };

String formatRoomDimension(int millimeters) {
  final whole = millimeters ~/ 1000;
  final fraction = (millimeters % 1000).toString().padLeft(3, '0');
  return '$whole,${fraction.replaceFirst(RegExp(r'0+$'), '')}'.replaceFirst(
    RegExp(r',$'),
    '',
  );
}

String formatRoomQuantity(BigInt unscaled, int scale) {
  if (scale == 0) return unscaled.toString();
  final digits = unscaled.toString().padLeft(scale + 1, '0');
  final split = digits.length - scale;
  final result = '${digits.substring(0, split)},${digits.substring(split)}';
  return result
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r',$'), '');
}
