import 'package:budowapro/core/theme/app_theme.dart';
import 'package:budowapro/features/stages/domain/stage_plan.dart';
import 'package:budowapro/features/stages/presentation/stage_editor_dialogs.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates an own checklist position with practical details', (
    tester,
  ) async {
    NewChecklistItemInput? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showAddChecklistDialog(context);
              },
              child: const Text('Otwórz'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otwórz'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(0), 'Sprawdź przepust do ogrodu');
    await tester.enterText(fields.at(1), 'Elektryk');
    await tester.enterText(
      fields.at(2),
      'Potwierdzić średnicę i zakończenia z obu stron.',
    );
    await tester.enterText(
      fields.at(3),
      'Później trzeba będzie rozebrać podjazd.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Zapisz'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.title, 'Sprawdź przepust do ogrodu');
    expect(result!.details.status, ChecklistStatus.todo);
    expect(result!.details.assignee, 'Elektryk');
    expect(
      result!.details.note,
      'Potwierdzić średnicę i zakończenia z obu stron.',
    );
    expect(
      result!.details.riskIfSkipped,
      'Później trzeba będzie rozebrać podjazd.',
    );
  });
}
