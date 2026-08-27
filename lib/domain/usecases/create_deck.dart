import 'package:uuid/uuid.dart';

import '../deck/deck_name.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

class CreateDeck {
  const CreateDeck(this._decks, {this.generateId});

  final DeckRepository _decks;
  final String Function()? generateId;

  Future<Deck> call({
    required String userId,
    required String name,
    required DateTime now,
  }) {
    final trimmed = normalizeDeckName(name);
    return _decks.create(
      Deck(
        id: generateId?.call() ?? const Uuid().v4(),
        userId: userId,
        name: trimmed,
        createdAt: now,
      ),
    );
  }
}
