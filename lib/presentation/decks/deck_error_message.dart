import '../../domain/deck/deck_exception.dart';

String messageForDeckException(DeckException? error) {
  if (error is InvalidDeckNameException) {
    return 'O nome deve ter entre 1 e 80 caracteres.';
  }
  if (error is DeckNotFoundException) {
    return 'Este deck não existe mais.';
  }
  if (error is DeckNetworkException) {
    return 'Não foi possível carregar os decks. Verifique a rede.';
  }
  return 'Não foi possível carregar os decks.';
}
