import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/backup/data/backup_providers.dart';
import 'package:budowapro/features/backup/domain/backup_gateway.dart';
import 'package:budowapro/features/backup/domain/backup_models.dart';
import 'package:budowapro/features/backup/presentation/backup_screen.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'creates, previews and confirms restore at 320 px without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final gateway = _FakeBackupGateway();
      await tester.pumpWidget(_app(gateway));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('createBackupButton')));
      await tester.pumpAndSettle();

      expect(gateway.createCalls, 1);
      await tester.drag(
        find.byKey(const ValueKey('backupScreenContent')),
        const Offset(0, -240),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backupSuccess')), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const ValueKey('pickBackupButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pickBackupButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('backupCandidateCard')), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(
        find.byKey(const ValueKey('restoreBackupButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('restoreBackupButton')));
      await tester.pumpAndSettle();

      expect(find.text('Zastąpić wszystkie dane?'), findsOneWidget);
      expect(gateway.restoreCalls, 0);

      await tester.tap(find.byKey(const ValueKey('confirmRestoreButton')));
      await tester.pumpAndSettle();

      expect(gateway.restoreCalls, 1);
      expect(find.byKey(const ValueKey('backupSuccess')), findsOneWidget);
      expect(find.byKey(const ValueKey('backupCandidateCard')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(BackupGateway gateway) {
  return ProviderScope(
    overrides: [backupGatewayProvider.overrideWith((ref) async => gateway)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: const BackupScreen(),
    ),
  );
}

final class _FakeBackupGateway implements BackupGateway {
  final preview = BackupPreview(
    createdAt: DateTime.utc(2026, 7, 25, 9, 30),
    schemaVersion: 8,
    projectCount: 3,
    payloadFileCount: 28,
    payloadBytes: 12 * 1024 * 1024,
    candidateToken: 'candidate-token',
  );

  var createCalls = 0;
  var restoreCalls = 0;

  @override
  Future<BackupPreview> createAndShare({required String shareTitle}) async {
    createCalls += 1;
    return preview;
  }

  @override
  Future<BackupSelection?> pickAndInspect() async {
    return BackupSelection(preview: preview, token: 'candidate-token');
  }

  @override
  Future<BackupPreview> restore(BackupSelection selection) async {
    restoreCalls += 1;
    return preview;
  }
}
