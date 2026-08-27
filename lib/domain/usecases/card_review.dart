import '../entities/card.dart';
import '../sm2/grade.dart';
import '../sm2/sm2_policy.dart';

/// Aplica uma revisão ao card: valida a nota, pede o intervalo à política e
/// grava timestamps. Sem I/O (persistência entra no `ReviewCard` da Fase 6).
class CardReview {
  const CardReview({SpacedRepetitionPolicy policy = const Sm2Policy()})
    : _policy = policy;

  final SpacedRepetitionPolicy _policy;

  Card call(Card card, int grade, DateTime now) {
    final parsedGrade = Grade(grade);
    final outcome = _policy.apply(
      repetitions: card.repetitions,
      intervalDays: card.intervalDays,
      easeFactor: card.easeFactor,
      grade: parsedGrade,
    );

    return card.copyWith(
      easeFactor: outcome.easeFactor,
      intervalDays: outcome.intervalDays,
      repetitions: outcome.repetitions,
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(days: outcome.intervalDays)),
      updatedAt: now,
    );
  }
}
