import '../card/card_exception.dart';
import '../card/card_text.dart';
import '../entities/card.dart';
import '../repositories/card_repository.dart';

class UpdateCard {
  const UpdateCard(this._cards);

  final CardRepository _cards;

  Future<Card> call({
    required String userId,
    required String deckId,
    required String cardId,
    required String frontText,
    required String backText,
    required DateTime now,
  }) async {
    final front = normalizeFrontText(frontText);
    final back = normalizeBackText(backText);
    try {
      final existing = await _cards.getById(
        userId: userId,
        deckId: deckId,
        cardId: cardId,
      );
      return _cards.update(
        existing.copyWith(frontText: front, backText: back, updatedAt: now),
        userId: userId,
      );
    } on CardException {
      rethrow;
    } on StateError {
      throw const CardNotFoundException();
    }
  }
}
