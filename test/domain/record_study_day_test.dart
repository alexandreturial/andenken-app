import 'package:andenken_app/domain/study/record_study_day.dart';
import 'package:andenken_app/domain/study/study_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const record = RecordStudyDay();

  DateTime day(int d) => DateTime(2026, 8, d, 15);

  group('RecordStudyDay RN-K01', () {
    test('primeira revisão cria streak 1 no dia local', () {
      final stats = record(null, day(28));
      expect(stats.currentStreak, 1);
      expect(stats.lastStudyLocalDate, '2026-08-28');
    });

    test('mesmo dia não altera streak', () {
      const current = StudyStats(
        currentStreak: 4,
        lastStudyLocalDate: '2026-08-28',
      );
      final stats = record(current, day(28));
      expect(stats.currentStreak, 4);
      expect(stats.lastStudyLocalDate, '2026-08-28');
    });

    test('dia seguinte incrementa', () {
      const current = StudyStats(
        currentStreak: 4,
        lastStudyLocalDate: '2026-08-27',
      );
      final stats = record(current, day(28));
      expect(stats.currentStreak, 5);
      expect(stats.lastStudyLocalDate, '2026-08-28');
    });

    test('pulou um dia → streak volta a 1', () {
      const current = StudyStats(
        currentStreak: 12,
        lastStudyLocalDate: '2026-08-26',
      );
      final stats = record(current, day(28));
      expect(stats.currentStreak, 1);
      expect(stats.lastStudyLocalDate, '2026-08-28');
    });
  });

  group('StudyStreakWeek RN-K02', () {
    test('streak 5 com lastStudy sexta preenche M–F da semana', () {
      final last = DateTime(2026, 8, 28); // sexta
      final week = StudyStreakWeek.fromStats(
        const StudyStats(currentStreak: 5, lastStudyLocalDate: '2026-08-28'),
        last,
      );
      expect(week.filledMondayToSunday, [true, true, true, true, true, false, false]);
    });

    test('sem lastStudy todas vazias', () {
      final week = StudyStreakWeek.fromStats(null, DateTime(2026, 8, 28));
      expect(week.filledMondayToSunday, List.filled(7, false));
    });
  });
}
