import 'package:budowapro/features/stages/domain/stage_guidance.dart';
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
}
