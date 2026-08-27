import '../card/card_exception.dart';
import '../repositories/card_repository.dart';

class DeleteCard {
  const DeleteCard(this._cards);

  final CardRepository _cards;

  Future<void> call({
    required String userId,
    required String deckId,
    required String cardId,
  }) async {
    try {
      await _cards.delete(userId: userId, deckId: deckId, cardId: cardId);
    } on CardException {
      rethrow;
    } on StateError {
      throw const CardNotFoundException();
    }
  }
}
