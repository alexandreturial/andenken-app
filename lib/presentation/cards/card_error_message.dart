import '../../domain/card/card_exception.dart';
import '../../domain/deck/deck_exception.dart';
import '../decks/deck_error_message.dart';

String messageForCardException(CardException? error) {
  if (error is InvalidCardTextException) {
    return 'Frente (1–500) e verso (1–2000) são obrigatórios.';
  }
  if (error is CardNotFoundException) {
    return 'Este card não existe mais.';
  }
  if (error is CardNetworkException) {
    return 'Não foi possível carregar os cards. Verifique a rede.';
  }
  return 'Não foi possível carregar os cards.';
}

String messageForDetailError(Object? error) {
  if (error is CardException) {
    return messageForCardException(error);
  }
  if (error is DeckException) {
    return messageForDeckException(error);
  }
  return 'Não foi possível carregar o deck.';
}
