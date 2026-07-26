import 'package:budowapro/features/stages/domain/stage_guidance.dart';
import 'package:budowapro/features/projects/domain/project_template.dart';
import 'package:budowapro/features/stages/presentation/stage_guidance_ui_text.dart';
import 'package:budowapro/l10n/app_localizations_pl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'grounding guidance covers ring and vertical electrodes without guesses',
    () {
      final content = stageGuidanceContent(
        AppLocalizationsPl(),
        StageGuidanceKey.foundationGrounding,
      );
      final checks = content.checks.join(' ');

      expect(content.summary, contains('uniwersalna rezystancja'));
      expect(content.summary, contains('pionowe elektrody uziemiające'));
      expect(checks, contains('uziomu otokowego'));
      expect(checks, contains('szpilkami'));
      expect(checks, contains('kryterium odbioru wynika z projektu'));
      expect(content.summary, isNot(contains('30×4')));
    },
  );

  test('later construction guidance is complete and readable', () {
    final l10n = AppLocalizationsPl();
    for (final stageKey in <ProjectStageKey>[
      ProjectStageKey.shellOpen,
      ProjectStageKey.shellClosed,
      ProjectStageKey.installations,
      ProjectStageKey.finishing,
    ]) {
      final definitions = StageGuidanceCatalog.forStage(stageKey);
      expect(definitions, isNotEmpty, reason: stageKey.name);
      for (final definition in definitions) {
        final content = stageGuidanceContent(l10n, definition.key);
        expect(content.title.trim(), isNotEmpty);
        expect(content.timing.trim(), isNotEmpty);
        expect(content.summary.trim(), isNotEmpty);
        expect(content.checks, isNotEmpty);
        expect(content.questions, isNotEmpty);
      }
    }
  });
}
