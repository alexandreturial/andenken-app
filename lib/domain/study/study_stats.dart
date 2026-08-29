class StudyStats {
  const StudyStats({
    required this.currentStreak,
    required this.lastStudyLocalDate,
  });

  final int currentStreak;

  /// `yyyy-MM-dd` no fuso local.
  final String lastStudyLocalDate;

  DateTime get lastStudyDate {
    final parts = lastStudyLocalDate.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String formatLocalDate(DateTime date) {
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// RN-K02: sete flags M→S da semana local corrente.
class StudyStreakWeek {
  const StudyStreakWeek(this.filledMondayToSunday);

  final List<bool> filledMondayToSunday;

  factory StudyStreakWeek.fromStats(StudyStats? stats, DateTime now) {
    if (stats == null || stats.currentStreak <= 0) {
      return const StudyStreakWeek([
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ]);
    }
    final last = stats.lastStudyDate;
    final streakStart = last.subtract(Duration(days: stats.currentStreak - 1));
    final local = now.toLocal();
    final monday = DateTime(
      local.year,
      local.month,
      local.day,
    ).subtract(Duration(days: local.weekday - DateTime.monday));
    final filled = List<bool>.generate(7, (index) {
      final day = DateTime(monday.year, monday.month, monday.day + index);
      return !day.isBefore(streakStart) && !day.isAfter(last);
    });
    return StudyStreakWeek(filled);
  }
}
