import 'package:andenken_app/domain/card/card_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/repositories/card_repository.dart';

class FakeCardRepository implements CardRepository {
  final Map<String, _StoredCard> _byId = {};

  CardException? forcedListError;
  CardException? forcedDeleteError;

  @override
  Future<List<Card>> listByDeck({
    required String userId,
    required String deckId,
  }) async {
    final forced = forcedListError;
    if (forced != null) {
      throw forced;
    }
    final listed = _byId.values
        .where(
          (stored) => stored.userId == userId && stored.card.deckId == deckId,
        )
        .map((stored) => stored.card)
        .toList();
    listed.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return listed;
  }

  @override
  Future<List<Card>> listDueByDeck({
    required String userId,
    required String deckId,
    required DateTime until,
  }) async {
    final forced = forcedListError;
    if (forced != null) {
      throw forced;
    }
    final listed = _byId.values
        .where(
          (stored) =>
              stored.userId == userId &&
              stored.card.deckId == deckId &&
              !stored.card.nextReviewAt.isAfter(until),
        )
        .map((stored) => stored.card)
        .toList();
    return listed;
  }

  @override
  Future<Card> getById({
    required String userId,
    required String deckId,
    required String cardId,
  }) async {
    final stored = _byId[cardId];
    if (stored == null ||
        stored.userId != userId ||
        stored.card.deckId != deckId) {
      throw StateError('card not found');
    }
    return stored.card;
  }

  @override
  Future<Card> create(Card card, {required String userId}) async {
    _byId[card.id] = _StoredCard(userId: userId, card: card);
    return card;
  }

  @override
  Future<Card> update(Card card, {required String userId}) async {
    final stored = _byId[card.id];
    if (stored == null ||
        stored.userId != userId ||
        stored.card.deckId != card.deckId) {
      throw StateError('card not found');
    }
    _byId[card.id] = _StoredCard(userId: userId, card: card);
    return card;
  }

  @override
  Future<void> delete({
    required String userId,
    required String deckId,
    required String cardId,
  }) async {
    final forced = forcedDeleteError;
    if (forced != null) {
      throw forced;
    }
    final stored = _byId[cardId];
    if (stored == null ||
        stored.userId != userId ||
        stored.card.deckId != deckId) {
      throw StateError('card not found');
    }
    _byId.remove(cardId);
  }

  @override
  Future<void> deleteByDeck({
    required String userId,
    required String deckId,
  }) async {
    _byId.removeWhere(
      (_, stored) => stored.userId == userId && stored.card.deckId == deckId,
    );
  }
}

class _StoredCard {
  const _StoredCard({required this.userId, required this.card});

  final String userId;
  final Card card;
}
