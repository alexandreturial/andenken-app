import 'grade.dart';

/// Resultado puro do SM-2: o use-case só aplica isso no [Card].
class Sm2Outcome {
  const Sm2Outcome({
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
  });

  final double easeFactor;
  final int intervalDays;
  final int repetitions;
}

/// Política de espaçamento. [CardReview] depende desta abstração (DIP).
abstract class SpacedRepetitionPolicy {
  Sm2Outcome apply({
    required int repetitions,
    required int intervalDays,
    required double easeFactor,
    required Grade grade,
  });
}

/// SM-2 (algoritmo §4–§6). Só fórmulas; sem timestamps nem persistência (SRP).
class Sm2Policy implements SpacedRepetitionPolicy {
  const Sm2Policy();

  static const double minEaseFactor = 1.3;
  static const int firstIntervalDays = 1;
  static const int secondIntervalDays = 6;

  @override
  Sm2Outcome apply({
    required int repetitions,
    required int intervalDays,
    required double easeFactor,
    required Grade grade,
  }) {
    final nextEase = _nextEaseFactor(easeFactor, grade);
    if (!grade.isSuccess) {
      return Sm2Outcome(
        easeFactor: nextEase,
        intervalDays: firstIntervalDays,
        repetitions: 0,
      );
    }
    return Sm2Outcome(
      easeFactor: nextEase,
      intervalDays: _successIntervalDays(
        repetitions: repetitions,
        intervalDays: intervalDays,
        easeFactor: nextEase,
      ),
      repetitions: repetitions + 1,
    );
  }

  double _nextEaseFactor(double current, Grade grade) {
    final q = grade.value;
    final raw = current + (0.1 - (5 - q) * (0.08 + 0.02 * (5 - q)));
    final rounded = (raw * 100).round() / 100;
    return rounded < minEaseFactor ? minEaseFactor : rounded;
  }

  int _successIntervalDays({
    required int repetitions,
    required int intervalDays,
    required double easeFactor,
  }) {
    if (repetitions == 0) {
      return firstIntervalDays;
    }
    if (repetitions == 1) {
      return secondIntervalDays;
    }
    final grown = (intervalDays * easeFactor).ceil();
    return grown < 1 ? 1 : grown;
  }
}
