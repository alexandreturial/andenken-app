import '../../domain/repositories/study_stats_repository.dart';
import '../../domain/study/study_stats.dart';

/// In-memory. Usado nos testes que injetam fakes de Deck/Card.
class MemoryStudyStatsRepository implements StudyStatsRepository {
  StudyStats? _stats;

  @override
  Future<StudyStats?> get(String userId) async => _stats;

  @override
  Future<void> save(String userId, StudyStats stats) async {
    _stats = stats;
  }
}
