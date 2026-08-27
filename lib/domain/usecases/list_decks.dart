import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

class ListDecks {
  const ListDecks(this._decks);

  final DeckRepository _decks;

  Future<List<Deck>> call({required String userId}) {
    return _decks.listByUser(userId);
  }
}
