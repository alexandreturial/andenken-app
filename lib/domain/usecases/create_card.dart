import 'package:uuid/uuid.dart';

import '../card/card_text.dart';
import '../entities/card.dart';
import '../repositories/card_repository.dart';

class CreateCard {
  const CreateCard(this._cards, {this.generateId});

  final CardRepository _cards;
  final String Function()? generateId;

  Future<Card> call({
    required String userId,
    required String deckId,
    required String frontText,
    required String backText,
    required DateTime now,
  }) {
    return _cards.create(
      Card.newCard(
        id: generateId?.call() ?? const Uuid().v4(),
        deckId: deckId,
        frontText: normalizeFrontText(frontText),
        backText: normalizeBackText(backText),
        createdAt: now,
      ),
      userId: userId,
    );
  }
}
