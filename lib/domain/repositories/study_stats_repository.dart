import '../study/study_stats.dart';

abstract class StudyStatsRepository {
  Future<StudyStats?> get(String userId);

  Future<void> save(String userId, StudyStats stats);
}
