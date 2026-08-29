import '../../domain/repositories/study_stats_repository.dart';
import '../../domain/study/record_study_day.dart';
import '../../domain/study/study_stats.dart';

class PersistStudyDay {
  const PersistStudyDay(
    this._stats, {
    this.recordStudyDay = const RecordStudyDay(),
  });

  final StudyStatsRepository _stats;
  final RecordStudyDay recordStudyDay;

  Future<StudyStats> call({
    required String userId,
    required DateTime now,
  }) async {
    final current = await _stats.get(userId);
    final next = recordStudyDay(current, now);
    await _stats.save(userId, next);
    return next;
  }
}
