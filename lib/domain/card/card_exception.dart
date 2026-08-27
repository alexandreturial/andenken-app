/// Falhas de Card no domínio (RN-C01–C04).
abstract class CardException implements Exception {
  const CardException();
}

class InvalidCardTextException extends CardException {
  const InvalidCardTextException();
}

class CardNotFoundException extends CardException {
  const CardNotFoundException();
}

class CardNetworkException extends CardException {
  const CardNetworkException();
}
