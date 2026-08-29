import 'package:andenken_app/domain/entities/deck.dart';
import 'package:andenken_app/domain/study/pick_study_deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Deck deck(String id, DateTime createdAt) =>
      Deck(id: id, userId: 'u1', name: id, createdAt: createdAt);

  group('pickStudyDeck RN-N01', () {
    test('sem decks retorna null', () {
      expect(pickStudyDeck(const [], {}), isNull);
    });

    test('escolhe o deck com mais due', () {
      final a = deck('a', DateTime(2026, 8, 1));
      final b = deck('b', DateTime(2026, 8, 2));
      expect(pickStudyDeck([a, b], {'a': 1, 'b': 4})?.id, 'b');
    });

    test('empate de due usa createdAt mais antigo', () {
      final later = deck('later', DateTime(2026, 8, 10));
      final earlier = deck('earlier', DateTime(2026, 8, 1));
      expect(
        pickStudyDeck([later, earlier], {'later': 2, 'earlier': 2})?.id,
        'earlier',
      );
    });
  });
}
