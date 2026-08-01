import 'package:budowapro/features/diary/presentation/journal_form_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses optional signed decision cost delta', () {
    expect(parseJournalCostDelta(''), isNull);
    expect(parseJournalCostDelta('+1 250,50'), 125050);
    expect(parseJournalCostDelta('-300.00'), -30000);
    expect(() => parseJournalCostDelta('12,345'), throwsFormatException);
  });

  test('parses optional signed schedule delta', () {
    expect(parseJournalScheduleDelta(''), isNull);
    expect(parseJournalScheduleDelta('+2'), 2);
    expect(parseJournalScheduleDelta('-5'), -5);
    expect(() => parseJournalScheduleDelta('2,5'), throwsFormatException);
    expect(() => parseJournalScheduleDelta('36501'), throwsRangeError);
  });
}
