import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/study/deck_mastery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 28, 10);

  Card card({
    required String id,
    required DateTime nextReviewAt,
  }) {
    return Card(
      id: id,
      deckId: 'd1',
      frontText: id,
      backText: 'b',
      nextReviewAt: nextReviewAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('DeckMastery RN-M01', () {
    test('deck vazio tem percent 0, total 0, due 0', () {
      final mastery = DeckMastery.fromCards(const [], now);
      expect(mastery.total, 0);
      expect(mastery.dueCount, 0);
      expect(mastery.percent, 0);
    });

    test('todos due → 0% mastery e cards left = total', () {
      final mastery = DeckMastery.fromCards([
        card(id: 'a', nextReviewAt: now),
        card(id: 'b', nextReviewAt: now.subtract(const Duration(days: 1))),
      ], now);
      expect(mastery.total, 2);
      expect(mastery.dueCount, 2);
      expect(mastery.percent, 0);
    });

    test('1 due de 4 → 75% e 1 cards left', () {
      final later = now.add(const Duration(days: 3));
      final mastery = DeckMastery.fromCards([
        card(id: 'due', nextReviewAt: now),
        card(id: 'ok1', nextReviewAt: later),
        card(id: 'ok2', nextReviewAt: later),
        card(id: 'ok3', nextReviewAt: later),
      ], now);
      expect(mastery.total, 4);
      expect(mastery.dueCount, 1);
      expect(mastery.percent, 75);
    });
  });
}
