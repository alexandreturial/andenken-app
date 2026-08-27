/// Falhas de Deck no domínio (RN-D01).
abstract class DeckException implements Exception {
  const DeckException();
}

class InvalidDeckNameException extends DeckException {
  const InvalidDeckNameException();
}

class DeckNotFoundException extends DeckException {
  const DeckNotFoundException();
}

class DeckNetworkException extends DeckException {
  const DeckNetworkException();
}
