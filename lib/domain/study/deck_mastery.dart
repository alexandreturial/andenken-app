import '../datetime/end_of_local_day.dart';
import '../entities/card.dart';

/// RN-M01: percentagem de cards que não estão due hoje.
class DeckMastery {
  const DeckMastery({
    required this.total,
    required this.dueCount,
    required this.percent,
  });

  factory DeckMastery.fromCards(List<Card> cards, DateTime now) {
    final until = endOfLocalDay(now);
    final dueCount = cards
        .where((card) => !card.nextReviewAt.isAfter(until))
        .length;
    final total = cards.length;
    final notDue = total - dueCount;
    final percent = total == 0 ? 0 : (100 * notDue / total).round();
    return DeckMastery(total: total, dueCount: dueCount, percent: percent);
  }

  final int total;
  final int dueCount;
  final int percent;
}
