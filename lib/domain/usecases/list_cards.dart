import '../entities/card.dart';
import '../repositories/card_repository.dart';

class ListCards {
  const ListCards(this._cards);

  final CardRepository _cards;

  Future<List<Card>> call({
    required String userId,
    required String deckId,
  }) async {
    final listed = [...await _cards.listByDeck(userId: userId, deckId: deckId)];
    listed.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return listed;
  }
}
