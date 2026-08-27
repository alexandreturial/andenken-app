import '../repositories/card_repository.dart';
import '../repositories/deck_repository.dart';

class DeleteDeck {
  const DeleteDeck(this._decks, this._cards);

  final DeckRepository _decks;
  final CardRepository _cards;

  /// Hard delete (RN-D03). Apaga os Cards da subcoleção e depois o Deck
  /// (plan §6.2 — sem Cloud Function).
  Future<void> call({required String userId, required String deckId}) async {
    await _cards.deleteByDeck(userId: userId, deckId: deckId);
    await _decks.delete(userId: userId, deckId: deckId);
  }
}
