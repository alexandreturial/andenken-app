import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/study_stats_repository.dart';
import '../../domain/study/study_stats.dart';

class FirestoreStudyStatsRepository implements StudyStatsRepository {
  FirestoreStudyStatsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String userId) {
    return _db.collection('users').doc(userId).collection('meta').doc('studyStats');
  }

  @override
  Future<StudyStats?> get(String userId) async {
    final snapshot = await _doc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    final streak = (data['currentStreak'] as num?)?.toInt() ?? 0;
    final date = data['lastStudyLocalDate'] as String? ?? '';
    if (date.isEmpty) {
      return null;
    }
    return StudyStats(currentStreak: streak, lastStudyLocalDate: date);
  }

  @override
  Future<void> save(String userId, StudyStats stats) {
    return _doc(userId).set({
      'currentStreak': stats.currentStreak,
      'lastStudyLocalDate': stats.lastStudyLocalDate,
    });
  }
}
