import 'package:andenken_app/domain/usecases/persist_study_day.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_study_stats_repository.dart';

void main() {
  test('PersistStudyDay grava streak 1 na primeira vez', () async {
    final repo = FakeStudyStatsRepository();
    final persist = PersistStudyDay(repo);
    final stats = await persist(
      userId: 'u1',
      now: DateTime(2026, 8, 28, 10),
    );
    expect(stats.currentStreak, 1);
    expect(repo.stored?.lastStudyLocalDate, '2026-08-28');
  });
}
