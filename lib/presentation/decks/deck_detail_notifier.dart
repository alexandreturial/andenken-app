import 'package:flutter/foundation.dart';

import '../../domain/card/card_exception.dart';
import '../../domain/deck/deck_exception.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/usecases/delete_card.dart';
import '../../domain/usecases/delete_deck.dart';
import '../../domain/usecases/list_cards.dart';

enum DeckDetailStatus { loading, data, empty, error, deleted }

class DeckDetailViewState {
  const DeckDetailViewState({
    this.status = DeckDetailStatus.loading,
    this.deck,
    this.cards = const [],
    this.error,
  });

  final DeckDetailStatus status;
  final Deck? deck;
  final List<Card> cards;
  final Object? error;

  bool get canStudy => cards.isNotEmpty;
}

class DeckDetailNotifier extends ValueNotifier<DeckDetailViewState> {
  DeckDetailNotifier({
    required DeckRepository decks,
    required ListCards listCards,
    required DeleteCard deleteCard,
    required DeleteDeck deleteDeck,
    required String userId,
    required String deckId,
  }) : _decks = decks,
       _listCards = listCards,
       _deleteCard = deleteCard,
       _deleteDeck = deleteDeck,
       _userId = userId,
       _deckId = deckId,
       super(const DeckDetailViewState());

  final DeckRepository _decks;
  final ListCards _listCards;
  final DeleteCard _deleteCard;
  final DeleteDeck _deleteDeck;
  final String _userId;
  final String _deckId;

  Future<void> load() async {
    value = const DeckDetailViewState();
    try {
      final deck = await _decks.getById(userId: _userId, deckId: _deckId);
      final cards = await _listCards(userId: _userId, deckId: _deckId);
      if (cards.isEmpty) {
        value = DeckDetailViewState(status: DeckDetailStatus.empty, deck: deck);
        return;
      }
      value = DeckDetailViewState(
        status: DeckDetailStatus.data,
        deck: deck,
        cards: cards,
      );
    } on DeckException catch (error) {
      value = DeckDetailViewState(status: DeckDetailStatus.error, error: error);
    } on CardException catch (error) {
      value = DeckDetailViewState(status: DeckDetailStatus.error, error: error);
    } on StateError {
      value = const DeckDetailViewState(
        status: DeckDetailStatus.error,
        error: DeckNotFoundException(),
      );
    } catch (_) {
      value = const DeckDetailViewState(
        status: DeckDetailStatus.error,
        error: DeckNetworkException(),
      );
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _deleteCard(userId: _userId, deckId: _deckId, cardId: cardId);
    } on CardException catch (error) {
      value = DeckDetailViewState(
        status: DeckDetailStatus.error,
        deck: value.deck,
        cards: value.cards,
        error: error,
      );
      return;
    } catch (_) {
      value = DeckDetailViewState(
        status: DeckDetailStatus.error,
        deck: value.deck,
        cards: value.cards,
        error: const CardNetworkException(),
      );
      return;
    }
    await load();
  }

  Future<void> deleteDeck() async {
    try {
      await _deleteDeck(userId: _userId, deckId: _deckId);
      value = const DeckDetailViewState(status: DeckDetailStatus.deleted);
    } on DeckException catch (error) {
      value = DeckDetailViewState(
        status: DeckDetailStatus.error,
        deck: value.deck,
        cards: value.cards,
        error: error,
      );
    } catch (_) {
      value = DeckDetailViewState(
        status: DeckDetailStatus.error,
        deck: value.deck,
        cards: value.cards,
        error: const DeckNetworkException(),
      );
    }
  }
}
