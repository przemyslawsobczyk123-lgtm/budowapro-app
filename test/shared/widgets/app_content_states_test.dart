import 'package:budowapro/shared/widgets/app_content_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loading state exposes progress and a readable label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppLoadingState(label: 'Ładowanie projektu')),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Ładowanie projektu'), findsOneWidget);
  });

  testWidgets('empty state renders title and message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppEmptyState(
          icon: Icons.home_work_outlined,
          title: 'Brak projektu',
          message: 'Dodaj pierwszy projekt.',
        ),
      ),
    );

    expect(find.text('Brak projektu'), findsOneWidget);
    expect(find.text('Dodaj pierwszy projekt.'), findsOneWidget);
  });

  testWidgets('error state can retry', (WidgetTester tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppErrorState(
          title: 'Nie udało się wczytać danych',
          retryLabel: 'Spróbuj ponownie',
          onRetry: () => retried = true,
        ),
      ),
    );

    await tester.tap(find.text('Spróbuj ponownie'));

    expect(retried, isTrue);
  });
}
