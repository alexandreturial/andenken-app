import 'study_stats.dart';

class RecordStudyDay {
  const RecordStudyDay();

  StudyStats call(StudyStats? current, DateTime now) {
    final today = StudyStats.formatLocalDate(now);
    if (current == null) {
      return StudyStats(currentStreak: 1, lastStudyLocalDate: today);
    }
    final last = current.lastStudyDate;
    final todayDate = DateTime(
      now.toLocal().year,
      now.toLocal().month,
      now.toLocal().day,
    );
    final lastDate = DateTime(last.year, last.month, last.day);
    final diff = todayDate.difference(lastDate).inDays;
    if (diff == 0) {
      return current;
    }
    if (diff == 1) {
      return StudyStats(
        currentStreak: current.currentStreak + 1,
        lastStudyLocalDate: today,
      );
    }
    return StudyStats(currentStreak: 1, lastStudyLocalDate: today);
  }
}
