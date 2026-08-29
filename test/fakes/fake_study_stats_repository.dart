import 'package:andenken_app/domain/repositories/study_stats_repository.dart';
import 'package:andenken_app/domain/study/study_stats.dart';

class FakeStudyStatsRepository implements StudyStatsRepository {
  StudyStats? stored;

  @override
  Future<StudyStats?> get(String userId) async => stored;

  @override
  Future<void> save(String userId, StudyStats stats) async {
    stored = stats;
  }
}
