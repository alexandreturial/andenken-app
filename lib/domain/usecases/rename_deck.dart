import '../deck/deck_name.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

class RenameDeck {
  const RenameDeck(this._decks);

  final DeckRepository _decks;

  Future<Deck> call({
    required String userId,
    required String deckId,
    required String name,
    required DateTime now,
  }) {
    final trimmed = normalizeDeckName(name);
    return _decks.rename(
      userId: userId,
      deckId: deckId,
      name: trimmed,
      updatedAt: now,
    );
  }
}
