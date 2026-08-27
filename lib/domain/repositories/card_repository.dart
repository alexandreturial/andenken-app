import '../entities/card.dart';

abstract class CardRepository {
  Future<List<Card>> listByDeck({
    required String userId,
    required String deckId,
  });

  /// Cards com `nextReviewAt <= until` (RN-S01). A ordenação RN-S02 fica no use-case.
  Future<List<Card>> listDueByDeck({
    required String userId,
    required String deckId,
    required DateTime until,
  });

  Future<Card> getById({
    required String userId,
    required String deckId,
    required String cardId,
  });

  Future<Card> create(Card card, {required String userId});

  Future<Card> update(Card card, {required String userId});

  Future<void> delete({
    required String userId,
    required String deckId,
    required String cardId,
  });

  Future<void> deleteByDeck({required String userId, required String deckId});
}
