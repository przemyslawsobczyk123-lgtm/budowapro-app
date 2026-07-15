import 'package:budowapro/features/costs/domain/cost_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'cost query requires project context and excludes drafts by default',
    () {
      final query = CostQuery(projectId: ' project-1 ');

      expect(query.projectId, 'project-1');
      expect(query.includeDrafts, isFalse);
      expect(() => CostQuery(projectId: ' '), throwsArgumentError);
    },
  );

  test('summary query cannot request draft inclusion', () {
    final query = CostSummaryQuery(projectId: 'project-1');

    expect(query.projectId, 'project-1');
  });
}
