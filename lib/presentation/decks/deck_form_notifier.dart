import 'package:flutter/foundation.dart';

import '../../domain/card/card_exception.dart';
import '../../domain/card/card_text.dart';
import '../../domain/deck/deck_exception.dart';
import '../../domain/deck/deck_name.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/usecases/create_card.dart';
import '../../domain/usecases/create_deck.dart';
import '../../domain/usecases/list_cards.dart';
import '../../domain/usecases/rename_deck.dart';
import '../../domain/usecases/update_card.dart';

enum DeckFormStatus { idle, loading, success, error }

class CardDraftInput {
  const CardDraftInput({
    this.cardId,
    required this.frontText,
    required this.backText,
  });

  final String? cardId;
  final String frontText;
  final String backText;

  bool get isExisting => cardId != null;

  bool get isBlank => frontText.trim().isEmpty && backText.trim().isEmpty;

  bool get isPartial {
    final frontEmpty = frontText.trim().isEmpty;
    final backEmpty = backText.trim().isEmpty;
    return frontEmpty != backEmpty;
  }
}

class DeckFormViewState {
  const DeckFormViewState({
    this.status = DeckFormStatus.idle,
    this.initialName,
    this.initialCards = const [],
    this.error,
  });

  final DeckFormStatus status;
  final String? initialName;
  final List<CardDraftInput> initialCards;
  final Object? error;
}

class DeckFormNotifier extends ValueNotifier<DeckFormViewState> {
  DeckFormNotifier({
    required CreateDeck createDeck,
    required RenameDeck renameDeck,
    required CreateCard createCard,
    required UpdateCard updateCard,
    required ListCards listCards,
    required DeckRepository decks,
    required String userId,
    String? deckId,
    DateTime Function()? clock,
  }) : _createDeck = createDeck,
       _renameDeck = renameDeck,
       _createCard = createCard,
       _updateCard = updateCard,
       _listCards = listCards,
       _decks = decks,
       _userId = userId,
       _deckId = deckId,
       _clock = clock ?? DateTime.now,
       super(
         DeckFormViewState(
           status: deckId == null
               ? DeckFormStatus.idle
               : DeckFormStatus.loading,
         ),
       );

  final CreateDeck _createDeck;
  final RenameDeck _renameDeck;
  final CreateCard _createCard;
  final UpdateCard _updateCard;
  final ListCards _listCards;
  final DeckRepository _decks;
  final String _userId;
  final String? _deckId;
  final DateTime Function() _clock;

  Future<void> load() async {
    final deckId = _deckId;
    if (deckId == null) {
      return;
    }
    value = const DeckFormViewState(status: DeckFormStatus.loading);
    try {
      final deck = await _decks.getById(userId: _userId, deckId: deckId);
      final cards = await _listCards(userId: _userId, deckId: deckId);
      value = DeckFormViewState(
        initialName: deck.name,
        initialCards: [
          for (final card in cards)
            CardDraftInput(
              cardId: card.id,
              frontText: card.frontText,
              backText: card.backText,
            ),
        ],
      );
    } on DeckException catch (error) {
      value = DeckFormViewState(status: DeckFormStatus.error, error: error);
    } on CardException catch (error) {
      value = DeckFormViewState(status: DeckFormStatus.error, error: error);
    } on StateError {
      value = const DeckFormViewState(
        status: DeckFormStatus.error,
        error: DeckNotFoundException(),
      );
    } catch (_) {
      value = const DeckFormViewState(
        status: DeckFormStatus.error,
        error: DeckNetworkException(),
      );
    }
  }

  Future<void> submit(
    String name, {
    List<CardDraftInput> drafts = const [],
  }) async {
    value = DeckFormViewState(
      status: DeckFormStatus.loading,
      initialName: value.initialName,
      initialCards: value.initialCards,
    );

    try {
      normalizeDeckName(name);
    } on InvalidDeckNameException catch (error) {
      value = DeckFormViewState(
        status: DeckFormStatus.error,
        initialName: value.initialName,
        initialCards: value.initialCards,
        error: error,
      );
      return;
    }

    final existing = <CardDraftInput>[];
    final pendingNew = <CardDraftInput>[];
    for (final draft in drafts) {
      if (draft.isExisting) {
        if (draft.isBlank || draft.isPartial) {
          value = DeckFormViewState(
            status: DeckFormStatus.error,
            initialName: value.initialName,
            initialCards: value.initialCards,
            error: const InvalidCardTextException(),
          );
          return;
        }
        existing.add(draft);
        continue;
      }
      if (draft.isBlank) {
        continue;
      }
      if (draft.isPartial) {
        value = DeckFormViewState(
          status: DeckFormStatus.error,
          initialName: value.initialName,
          initialCards: value.initialCards,
          error: const InvalidCardTextException(),
        );
        return;
      }
      pendingNew.add(draft);
    }

    try {
      for (final draft in [...existing, ...pendingNew]) {
        normalizeFrontText(draft.frontText);
        normalizeBackText(draft.backText);
      }
    } on InvalidCardTextException catch (error) {
      value = DeckFormViewState(
        status: DeckFormStatus.error,
        initialName: value.initialName,
        initialCards: value.initialCards,
        error: error,
      );
      return;
    }

    try {
      final now = _clock();
      final deckId = _deckId;
      if (deckId == null) {
        final created = await _createDeck(userId: _userId, name: name, now: now);
        await _persistNewCards(
          deckId: created.id,
          drafts: pendingNew,
          now: now,
        );
      } else {
        await _renameDeck(
          userId: _userId,
          deckId: deckId,
          name: name,
          now: now,
        );
        for (final draft in existing) {
          await _updateCard(
            userId: _userId,
            deckId: deckId,
            cardId: draft.cardId!,
            frontText: draft.frontText,
            backText: draft.backText,
            now: now,
          );
        }
        await _persistNewCards(deckId: deckId, drafts: pendingNew, now: now);
      }
      value = DeckFormViewState(
        status: DeckFormStatus.success,
        initialName: value.initialName,
        initialCards: value.initialCards,
      );
    } on DeckException catch (error) {
      value = DeckFormViewState(
        status: DeckFormStatus.error,
        initialName: value.initialName,
        initialCards: value.initialCards,
        error: error,
      );
    } on CardException catch (error) {
      value = DeckFormViewState(
        status: DeckFormStatus.error,
        initialName: value.initialName,
        initialCards: value.initialCards,
        error: error,
      );
    } catch (_) {
      value = DeckFormViewState(
        status: DeckFormStatus.error,
        initialName: value.initialName,
        initialCards: value.initialCards,
        error: const DeckNetworkException(),
      );
    }
  }

  Future<void> _persistNewCards({
    required String deckId,
    required List<CardDraftInput> drafts,
    required DateTime now,
  }) async {
    for (var i = 0; i < drafts.length; i++) {
      final draft = drafts[i];
      await _createCard(
        userId: _userId,
        deckId: deckId,
        frontText: draft.frontText,
        backText: draft.backText,
        now: now.add(Duration(milliseconds: i)),
      );
    }
  }
}
