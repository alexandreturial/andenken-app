import 'package:flutter/foundation.dart';

import '../../domain/card/card_exception.dart';
import '../../domain/card/card_text.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/usecases/create_card.dart';
import '../../domain/usecases/update_card.dart';

enum CardFormStatus { idle, loading, success, error }

class CardDraftInput {
  const CardDraftInput({required this.frontText, required this.backText});

  final String frontText;
  final String backText;

  bool get isBlank => frontText.trim().isEmpty && backText.trim().isEmpty;
}

class CardFormViewState {
  const CardFormViewState({
    this.status = CardFormStatus.idle,
    this.initialFront,
    this.initialBack,
    this.error,
  });

  final CardFormStatus status;
  final String? initialFront;
  final String? initialBack;
  final CardException? error;
}

class CardFormNotifier extends ValueNotifier<CardFormViewState> {
  CardFormNotifier({
    required CreateCard createCard,
    required UpdateCard updateCard,
    required CardRepository cards,
    required String userId,
    required String deckId,
    String? cardId,
    DateTime Function()? clock,
  }) : _createCard = createCard,
       _updateCard = updateCard,
       _cards = cards,
       _userId = userId,
       _deckId = deckId,
       _cardId = cardId,
       _clock = clock ?? DateTime.now,
       super(
         CardFormViewState(
           status: cardId == null
               ? CardFormStatus.idle
               : CardFormStatus.loading,
         ),
       );

  final CreateCard _createCard;
  final UpdateCard _updateCard;
  final CardRepository _cards;
  final String _userId;
  final String _deckId;
  final String? _cardId;
  final DateTime Function() _clock;

  bool get isEdit => _cardId != null;

  Future<void> load() async {
    final cardId = _cardId;
    if (cardId == null) {
      return;
    }
    value = const CardFormViewState(status: CardFormStatus.loading);
    try {
      final card = await _cards.getById(
        userId: _userId,
        deckId: _deckId,
        cardId: cardId,
      );
      value = CardFormViewState(
        initialFront: card.frontText,
        initialBack: card.backText,
      );
    } on CardException catch (error) {
      value = CardFormViewState(status: CardFormStatus.error, error: error);
    } on StateError {
      value = const CardFormViewState(
        status: CardFormStatus.error,
        error: CardNotFoundException(),
      );
    } catch (_) {
      value = const CardFormViewState(
        status: CardFormStatus.error,
        error: CardNetworkException(),
      );
    }
  }

  Future<void> submitDrafts(List<CardDraftInput> drafts) async {
    final pending = drafts.where((draft) => !draft.isBlank).toList();
    if (pending.isEmpty) {
      value = CardFormViewState(
        status: CardFormStatus.error,
        initialFront: value.initialFront,
        initialBack: value.initialBack,
        error: const InvalidCardTextException(),
      );
      return;
    }
    try {
      for (final draft in pending) {
        normalizeFrontText(draft.frontText);
        normalizeBackText(draft.backText);
      }
    } on InvalidCardTextException catch (error) {
      value = CardFormViewState(
        status: CardFormStatus.error,
        initialFront: value.initialFront,
        initialBack: value.initialBack,
        error: error,
      );
      return;
    }

    value = CardFormViewState(
      status: CardFormStatus.loading,
      initialFront: value.initialFront,
      initialBack: value.initialBack,
    );
    try {
      final now = _clock();
      for (var i = 0; i < pending.length; i++) {
        final draft = pending[i];
        await _createCard(
          userId: _userId,
          deckId: _deckId,
          frontText: draft.frontText,
          backText: draft.backText,
          now: now.add(Duration(milliseconds: i)),
        );
      }
      value = const CardFormViewState(status: CardFormStatus.success);
    } on CardException catch (error) {
      value = CardFormViewState(status: CardFormStatus.error, error: error);
    } catch (_) {
      value = const CardFormViewState(
        status: CardFormStatus.error,
        error: CardNetworkException(),
      );
    }
  }

  Future<void> submit({
    required String frontText,
    required String backText,
  }) async {
    value = CardFormViewState(
      status: CardFormStatus.loading,
      initialFront: value.initialFront,
      initialBack: value.initialBack,
    );
    try {
      final now = _clock();
      final cardId = _cardId;
      if (cardId == null) {
        await submitDrafts([
          CardDraftInput(frontText: frontText, backText: backText),
        ]);
        return;
      }
      await _updateCard(
        userId: _userId,
        deckId: _deckId,
        cardId: cardId,
        frontText: frontText,
        backText: backText,
        now: now,
      );
      value = CardFormViewState(
        status: CardFormStatus.success,
        initialFront: value.initialFront,
        initialBack: value.initialBack,
      );
    } on CardException catch (error) {
      value = CardFormViewState(
        status: CardFormStatus.error,
        initialFront: value.initialFront,
        initialBack: value.initialBack,
        error: error,
      );
    } catch (_) {
      value = CardFormViewState(
        status: CardFormStatus.error,
        initialFront: value.initialFront,
        initialBack: value.initialBack,
        error: const CardNetworkException(),
      );
    }
  }
}
